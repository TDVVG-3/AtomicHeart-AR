<#
.SYNOPSIS
  PHASE 7 prototype builder: creates the native-`ar` locres pak for NewP5.

.DESCRIPTION
  Inputs:
   - localization/working/phase7_seed.csv        (key,arabic -> 25 translated rows)
   - localization/generated/locres_csv/NewP5-en-US.csv  (base corpus)
   - localization/extracted/.../NewP5/en-US/NewP5.locres (base locres)
   - source/original/locmeta/NewP5.locmeta       (locmeta surgery template)

  Steps:
   1. Merge seed into the NewP5 CSV (target column) — quotes preserved byte-exact
      for all non-seed rows. Never alters Namespace/Key.
   2. UnrealLocres import -> NewP5-ar.locres (Arabic replaces source strings only
      for seeded keys; all other keys keep their English text as fallback).
   3. Validate: re-export the produced locres and diff translated-row counts.
   4. LocMeta surgery: keep the 16-byte constant signature + header, bump the
      culture count and insert "ar" before "be-BY" (alphabetical).
   5. repak pack into build/package/zzz_atomicheart-ar_locres_p1_P.pak.
   6. Round-trip verify: repak info/list + unpack byte-compare + export check.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$SeedCsv,
    [string]$PakOut
)
$ErrorActionPreference = 'Stop'
if (-not $SeedCsv) { $SeedCsv = Join-Path $RepoRoot 'localization\working\phase7_seed.csv' }
if (-not $PakOut)  { $PakOut = Join-Path $RepoRoot 'build\package\zzz_atomicheart-ar_locres_p1_P.pak' }

$unreal = Join-Path $RepoRoot 'tools\bin\unreallocres\UnrealLocres.exe'
$repak  = Join-Path $RepoRoot 'tools\bin\repak\repak.exe'
$baseCsv    = Join-Path $RepoRoot 'localization\generated\locres_csv\NewP5-en-US.csv'
$baseLocres = Join-Path $RepoRoot 'localization\extracted\AtomicHeart\Content\Localization\NewP5\en-US\NewP5.locres'
$baseLocmeta = Join-Path $RepoRoot 'source\original\locmeta\NewP5.locmeta'

$work = Join-Path $RepoRoot 'build\staging\locres_p1'
$stage = Join-Path $work 'modpak\AtomicHeart\Content\Localization\NewP5'
New-Item -ItemType Directory -Force -Path (Join-Path $stage 'ar') | Out-Null

# ---- 1. merge seed into csv ----
$seed = @{}
foreach ($r in (Import-Csv $SeedCsv)) { $seed[$r.key] = $r.arabic }
Write-Host ("[OK] seed keys: {0}" -f $seed.Count)

$merged = Join-Path $work 'NewP5_import.csv'
$lines = New-Object System.Collections.Generic.List[string]
$n = 0
foreach ($line in [System.IO.File]::ReadAllLines($baseCsv)) {
    $comma = $line.IndexOf(',')
    if ($comma -lt 1) { $lines.Add($line); continue }
    $key = $line.Substring(0, $comma)
    if ($seed.ContainsKey($key)) {
        $esc = $seed[$key] -replace '"', '""'
        $lines.Add(($line.TrimEnd(',') + ',"' + $esc + '"'))
        $n++
    } else {
        $lines.Add($line)
    }
}
[System.IO.File]::WriteAllLines($merged, $lines)
Write-Host ("[OK] merged csv: {0} rows translated -> {1}" -f $n, $merged)
if ($n -ne $seed.Count) { throw "seed merge mismatch: expected $($seed.Count), wrote $n" }

# ---- 2. import -> ar locres ----
$arLocres = Join-Path $stage 'ar\NewP5.locres'
Copy-Item $baseLocres $arLocres -Force
& $unreal import -o $arLocres $arLocres $merged 2>&1 | Out-String | Write-Verbose
if (-not (Test-Path $arLocres)) { throw "import produced no output" }
Write-Host ("[OK] ar locres: {0} ({1} bytes)" -f $arLocres, (Get-Item $arLocres).Length)

# ---- 3. validation round-trip ----
$valCsv = Join-Path $work 'NewP5_ar_validation.csv'
& $unreal export -f csv -o $valCsv $arLocres 2>&1 | Select-String 'Exported' | Out-Null
$found = 0
foreach ($line in [System.IO.File]::ReadAllLines($valCsv)) {
    $comma = $line.IndexOf(',')
    if ($comma -lt 1) { continue }
    $key = $line.Substring(0, $comma)
    if ($seed.ContainsKey($key)) {
        # value column present and non-empty AND not equal to the english source line
        $tail = $line.Substring($comma + 1)
        $qt = $tail.LastIndexOf(',"')
        $val = $tail.Substring($qt + 2).TrimEnd('"')
        if ($val.Length -gt 0 -and $val -match '[\u0600-\u06FF]') { $found++ }
        else { throw "validation: '$key' has no Arabic target in produced locres" }
    }
}
if ($found -ne $seed.Count) { throw "validation: found $found Arabic rows, expected $($seed.Count)" }
Write-Host ("[OK] validation: {0}/{0} seeded rows contain Arabic in round-tripped locres" -f $found)

# ---- 4. locmeta surgery ----
$meta = [System.IO.File]::ReadAllBytes($baseLocmeta)
[byte[]]$sig = $meta[0..16]   # 16-byte constant signature + 1 version byte (empirically decoded)
if ($sig[16] -ne 0x01) { throw "unexpected locmeta version byte: $($sig[16])" }
$out = New-Object System.Collections.Generic.List[byte]
$out.AddRange($sig)
# header part before culture count: native-culture string + resource string
$i = 17
$hdrToCount = New-Object System.Collections.Generic.List[byte]
for ($s = 0; $s -lt 2; $s++) {
    $len = [BitConverter]::ToInt32($meta, $i)
    if ($len -lt 1 -or (($i + 4 + $len) -gt $meta.Length)) { throw "locmeta string length implausible at offset $i" }
    $hdrToCount.AddRange([BitConverter]::GetBytes([int32]$len))
    for ($j = 0; $j -lt $len; $j++) { $hdrToCount.Add($meta[$i + 4 + $j]) }    $i += 4 + $len
}
$count = [BitConverter]::ToInt32($meta, $i)
# sanity: count should equal number of culture entries remaining (len-prefixed strings)
$expect = 0
$p = $i + 4
while (($p + 4) -le $meta.Length) { $l = [BitConverter]::ToInt32($meta, $p); if ($l -lt 1 -or (($p + 4 + $l) -gt $meta.Length)) { break }; $p += 4 + $l; $expect++ }
if ($count -ne $expect) { throw "locmeta count mismatch: field=$count entries=$expect" }
$count ++    # + our new culture
$out.AddRange($hdrToCount)
$out.AddRange([BitConverter]::GetBytes([int32]$count))
# culture entries; insert our 'ar' (len=3: 'a','r',0) before 'be-BY' (alphabetical)
function Add-Entry([System.Collections.Generic.List[byte]]$dst, [int32]$preLen, [byte[]]$str) {
    $dst.AddRange([BitConverter]::GetBytes([int32]$preLen)); foreach ($b in $str) { $dst.Add($b) }
}
$arLen = 3; $arStr = [byte[]](0x61, 0x72, 0x00)
$added = $false
$p = $i + 4
while (($p + 4) -le $meta.Length) {
    $l = [BitConverter]::ToInt32($meta, $p)
    if ($l -lt 1 -or (($p + 4 + $l) -gt $meta.Length)) { break }
    [byte[]]$str = $meta[($p + 4)..($p + 4 + $l - 1)]
    $label = ([System.Text.Encoding]::ASCII.GetString($str)).TrimEnd([char]0)
    if (-not $added -and $label -eq 'be-BY') { Add-Entry $out $arLen $arStr; $added = $true }
    Add-Entry $out $l $str
    $p += 4 + $l
}
[System.IO.File]::WriteAllBytes((Join-Path $stage 'NewP5.locmeta'), $out.ToArray())
Write-Host ("[OK] locmeta: {0} -> {1} bytes; cultures {2} (format from empirical decode)" -f ($meta.Length + 4 + 3), $out.Count, $count)
if (-not $added) { throw 'locmeta surgery did not insert the ar culture entry' }

# ---- 5. pack ----
New-Item -ItemType Directory -Force -Path (Split-Path $PakOut -Parent) | Out-Null
$packDir = Join-Path $work 'modpak'
& $repak pack --version V11 --mount-point '../../../' $packDir $PakOut 2>&1 | Out-String | Write-Host
if (-not (Test-Path $PakOut)) { throw "repak pack failed" }

# ---- 6. round-trip verify ----
$info = (& $repak info $PakOut) -join "`n"
Write-Host $info
$list = & $repak list $PakOut
Write-Host "[LIST] entries:"; $list | ForEach-Object { Write-Host ("  " + $_) }
$chkDir = Join-Path $work 'unpack_check'
if (Test-Path $chkDir) { Remove-Item $chkDir -Recurse -Force }
& $repak unpack $PakOut --output $chkDir 2>&1 | Out-Null
$origBytes = [System.IO.File]::ReadAllBytes($arLocres)
$chkBytes  = [System.IO.File]::ReadAllBytes((Join-Path $chkDir 'AtomicHeart\Content\Localization\NewP5\ar\NewP5.locres'))
if ($origBytes.Length -ne $chkBytes.Length) { throw 'roundtrip: locres size mismatch' }
for ($z = 0; $z -lt $origBytes.Length; $z += 4096) {
    $end = [Math]::Min($z + 4096, $origBytes.Length) - 1
    $a = $origBytes[$z..$end]; $b = $chkBytes[$z..$end]
    for ($k = 0; $k -lt $a.Length; $k++) { if ($a[$k] -ne $b[$k]) { throw 'roundtrip: locres byte mismatch' } }
}
Write-Host '[OK] round-trip byte-identical'
Write-Host ("[DONE] pak: {0} ({1} bytes)" -f $PakOut, (Get-Item $PakOut).Length)
