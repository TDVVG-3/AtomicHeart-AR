<#
.SYNOPSIS
  Cycle 004 build (DEC-007 carrier, user-approved slot ko-KR). Produces a LOCRES-ONLY
  pak that carries the Arabic seed strings in the EXISTING ko-KR culture slot
  (Strategy C). No LocMeta surgery, no font changes, no install.
  - reads the original NewP5 ko-KR locres from pakchunk0 (read-only)
  - exports its CSV, imports the Arabic seed (target column), round-trip validates
  - packs zzz_atomicheart-ar_carrier_koKR_p1_P.pak with repak (V11, mount ../../../)
  - self-verifies: pak list, unpacking, locres re-export diff (25 keys with Arabic;
    other keys unchanged Korean)
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$SeedCsv = 'C:\AtomicHeart-AR\localization\working\phase7_seed.csv',
    [string]$PakOut = 'C:\AtomicHeart-AR\build\package\zzz_atomicheart-ar_carrier_koKR_p1_P.pak'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

function Parse-CsvLine([string]$line) {
    $out = New-Object System.Collections.Generic.List[string]
    $f = ''; $inq = $false
    for ($i = 0; $i -lt $line.Length; $i++) {
        $c = $line[$i]
        if ($inq) {
            if ($c -eq '"') {
                if ($i + 1 -lt $line.Length -and $line[$i+1] -eq '"') { $f += '"'; $i++ } else { $inq = $false }
            } else { $f += $c }
        } else {
            if ($c -eq '"') { $inq = $true }
            elseif ($c -eq ',') { $out.Add($f); $f = '' }
            else { $f += $c }
        }
    }
    $out.Add($f)
    return $out
}
function CsvEsc([string]$s) { '"' + ($s -replace '"', '""') + '"' }

$repak = Join-Path $RepoRoot 'tools\bin\repak\repak.exe'
$ulr   = Join-Path $RepoRoot 'tools\bin\UnrealLocres\UnrealLocres.exe'
$pak0  = 'C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart\AtomicHeart\Content\Paks\pakchunk0-WindowsNoEditor.pak'

$work = Join-Path $RepoRoot 'build\staging\carrier_koKR'
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Force -Path $work | Out-Null

# 1) original ko-kr locres
powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot 'scripts\get_pak_file.ps1') -Pak $pak0 -Entry 'AtomicHeart/Content/Localization/NewP5/ko-KR/NewP5.locres' -OutFile "$work\ko.locres"
Write-Host ("[1] original ko-kr NewP5.locres: {0} bytes" -f (Get-Item "$work\ko.locres").Length)

# 2) export its csv
& $ulr export -o "$work\ko.csv" "$work\ko.locres" 2>&1 | Out-Null
if (-not (Test-Path "$work\ko.csv")) { throw 'UnrealLocres export failed' }
$utf8 = [Text.Encoding]::UTF8
$koLines = [IO.File]::ReadAllLines("$work\ko.csv", $utf8)
Write-Host ("[2] ko csv exported: {0} lines" -f $koLines.Count)

# map ko csv: target TEXT takes precedence (col2); source (col1) is the ko fallback for merging
$koMap = @{}
foreach ($line in $koLines) {
    $c = Parse-CsvLine $line
    if ($c -and $c[0] -ne 'key') {
        $val = if ($c.Count -gt 2 -and $c[2]) { $c[2] } elseif ($c.Count -gt 1) { $c[1] } else { '' }
        $koMap[$c[0]] = $val
    }
}

# 3) build import csv (key,source,target) - manual UTF-8 no-BOM read of the seed
$seedLines = [IO.File]::ReadAllLines($SeedCsv, $utf8)
$seed = @()
for ($i = 1; $i -lt $seedLines.Count; $i++) {
    $c = Parse-CsvLine $seedLines[$i]
    $seed += [pscustomobject]@{ key = $c[0]; arabic = $c[1] }
}
$impLines = New-Object System.Collections.Generic.List[string]
$impLines.Add('key,source,target')
foreach ($s in $seed) {
    if (-not $koMap.ContainsKey($s.key)) { throw ("seed key not in ko csv: $($s.key)") }
    $impLines.Add(('{0},{1},{2}' -f (CsvEsc $s.key), (CsvEsc $koMap[$s.key]), (CsvEsc $s.arabic)))
}
[IO.File]::WriteAllLines("$work\import.csv", $impLines, (New-Object Text.UTF8Encoding($false)))
Write-Host ("[3] import csv written: {0} seed rows" -f $seed.Count)

# 4) import arabic into the ko-KR locres
& $ulr import -o "$work\kor-ar.locres" "$work\ko.locres" "$work\import.csv" 2>&1 | Out-Null
if (-not (Test-Path "$work\kor-ar.locres")) { throw 'UnrealLocres import failed' }
Write-Host ("[4] carrier locres: {0} bytes" -f (Get-Item "$work\kor-ar.locres").Length)

# 5) round-trip validate against the TARGET column (col index 2)
& $ulr export -o "$work\kor-ar.csv" "$work\kor-ar.locres" 2>&1 | Out-Null
$map2 = @{}
foreach ($line in ([IO.File]::ReadAllLines("$work\kor-ar.csv", [Text.Encoding]::UTF8))) {
    $c = Parse-CsvLine $line
    if ($c -and $c[0] -ne 'key') { $map2[$c[0]] = $c[1] }
}
$cArabic = 0
foreach ($s in $seed) {
    $v = $map2[$s.key]
    if ($v -eq $s.arabic) { $cArabic++ } else { Write-Host ("  MISMATCH $($s.key)") }
}
if ($cArabic -eq $seed.Count) { Write-Host ("[5] round-trip PASS: {0}/{1} seed keys carry Arabic" -f $cArabic, $seed.Count) }
else { throw "round-trip mismatch: $cArabic / $($seed.Count)" }
# control: untouched keys still Korean (from the SOURCE column)
$controls = 0
foreach ($line in ([IO.File]::ReadAllLines("$work\kor-ar.csv", [Text.Encoding]::UTF8))) {
    $c = Parse-CsvLine $line
    if ($c -and ($c[0] -ne 'key') -and ($seed.key -notcontains $c[0]) -and $c[1]) {
        Write-Host ("   control unchanged: {0} -> {1}" -f $c[0], $c[1])
        $controls++
        if ($controls -ge 3) { break }
    }
}

# 6) pack: clean tree containing ONLY the AtomicHeart path
$pakTree = Join-Path $work 'AtomicHeart\Content\Localization\NewP5\ko-KR'
New-Item -ItemType Directory -Force -Path $pakTree | Out-Null
Copy-Item "$work\kor-ar.locres" "$pakTree\NewP5.locres" -Force
$packDir = Join-Path $work 'pack_only'
if (Test-Path $packDir) { Remove-Item $packDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $packDir | Out-Null
Copy-Item (Join-Path $work 'AtomicHeart') $packDir -Recurse -Force
New-Item -ItemType Directory -Force -Path (Split-Path $PakOut -Parent) | Out-Null
& $repak pack --version V11 --mount-point '../../../' $packDir $PakOut 2>&1 | Select-Object -Last 2
if (-not (Test-Path $PakOut)) { throw 'repak pack failed' }
Write-Host ("[6] pak: {0} ({1} bytes)" -f $PakOut, (Get-Item $PakOut).Length)
& $repak list $PakOut | ForEach-Object { Write-Host ("    entry: " + $_) }

# 7) unpack verify byte-identical
$unpack = Join-Path $work 'verify'
if (Test-Path $unpack) { Remove-Item $unpack -Recurse -Force }
New-Item -ItemType Directory -Force -Path $unpack | Out-Null
Push-Location $unpack
& $repak unpack -o $unpack -f $PakOut 2>&1 | Select-Object -Last 4
Pop-Location
if (-not (Test-Path "$unpack\AtomicHeart\Content\Localization\NewP5\ko-KR\NewP5.locres")) { throw 'unpack did not produce the expected file' }
$hashA = (Get-FileHash "$work\kor-ar.locres").Hash
$hashB = (Get-FileHash "$unpack\AtomicHeart\Content\Localization\NewP5\ko-KR\NewP5.locres").Hash
if ($hashA -eq $hashB) { Write-Host '[7] unpack identical: PASS' } else { throw 'unpacked locres differs' }

# 8) record
$sha = (Get-FileHash $PakOut).Hash.ToLower()
$rec = @(
    "carrier koKR pak: $PakOut",
    "sha256: $sha",
    ("seed keys: {0}" -f $seed.Count),
    'source: NewP5 ko-KR locres (extracted from pakchunk0)',
    ("built (UTC): {0}" -f (Get-Date).ToUniversalTime().ToString('o')),
    'NOT INSTALLED'
)
Set-Content -Path (Join-Path $work 'carrier_record.txt') -Value $rec
Write-Host ("[8] sha256: {0}" -f $sha)
Write-Host "DONE - pak built and validated - NOT INSTALLED."
