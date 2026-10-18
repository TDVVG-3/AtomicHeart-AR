<#
.SYNOPSIS
  Cycle 005 build (DEC-007 carrier, user-approved slot ko-KR, English-fill policy).
  Produces a LOCRES-ONLY pak that carries text in the EXISTING ko-KR culture slot
  (Strategy C). No LocMeta surgery, no font changes, no install.
  Fill policy (user order, cycle 005 step 3):
    - seed keys           -> Arabic text (unchanged, placeholders/tags preserved)
    - every other ko-KR key -> English text from the en-US NewP5 locres
                              (same namespace/key), so untranslated UI is readable
    - keys that have neither seed nor en-US text -> stay Korean (counted, honest)
  - reads the original NewP5 ko-KR and en-US locres from pakchunk0 (read-only)
  - UnrealLocres export/import, full round-trip validation of all three classes
  - packs zzz_atomicheart-ar_carrier_koKR_p2_P.pak with repak (V11, mount ../../../)
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$SeedCsv = 'C:\AtomicHeart-AR\localization\working\phase7_seed.csv',
    [string]$PakOut = 'C:\AtomicHeart-AR\build\package\zzz_atomicheart-ar_carrier_koKR_p2_P.pak'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

function Parse-CsvLine([string]$line) {
    # legacy single-line parser kept ONLY for simple 2-column files (seed csv)
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
    return ,$out
}
# RFC4180 reader: handles quoted fields spanning multiple lines (UnrealLocres
# exports contain embedded newlines inside some string values - cycle 005 finding).
Add-Type -AssemblyName Microsoft.VisualBasic | Out-Null
function Read-CsvRows([string]$path) {
    $rows = New-Object System.Collections.Generic.List[object]
    $parser = New-Object Microsoft.VisualBasic.FileIO.TextFieldParser($path, [Text.Encoding]::UTF8)
    $parser.HasFieldsEnclosedInQuotes = $true
    $parser.SetDelimiters(',')
    while (-not $parser.EndOfData) {
        try { $fields = $parser.ReadFields() } catch { throw ("CSV parse error in ${path}: " + $_.Exception.Message) }
        if ($fields) { $rows.Add([pscustomobject]@{ f = $fields }) }
    }
    $parser.Close()
    return $rows
}
function CsvEsc([string]$s) { '"' + ($s -replace '"', '""') + '"' }

$repak = Join-Path $RepoRoot 'tools\bin\repak\repak.exe'
$ulr   = Join-Path $RepoRoot 'tools\bin\UnrealLocres\UnrealLocres.exe'
$pak0  = 'C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart\AtomicHeart\Content\Paks\pakchunk0-WindowsNoEditor.pak'

$work = Join-Path $RepoRoot 'build\staging\carrier_koKR'
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Force -Path $work | Out-Null

# 1) original ko-kr + en-US locres
powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot 'scripts\get_pak_file.ps1') -Pak $pak0 -Entry 'AtomicHeart/Content/Localization/NewP5/ko-KR/NewP5.locres' -OutFile "$work\ko.locres"
Write-Host ("[1] original ko-kr NewP5.locres: {0} bytes" -f (Get-Item "$work\ko.locres").Length)
powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot 'scripts\get_pak_file.ps1') -Pak $pak0 -Entry 'AtomicHeart/Content/Localization/NewP5/en-US/NewP5.locres' -OutFile "$work\en.locres"
Write-Host ("[1] original en-US NewP5.locres: {0} bytes" -f (Get-Item "$work\en.locres").Length)

# 2) export both csvs
& $ulr export -o "$work\ko.csv" "$work\ko.locres" 2>&1 | Out-Null
if (-not (Test-Path "$work\ko.csv")) { throw 'UnrealLocres export failed' }
& $ulr export -o "$work\en.csv" "$work\en.locres" 2>&1 | Out-Null
if (-not (Test-Path "$work\en.csv")) { throw 'UnrealLocres export failed (en-US)' }

# map: for a locres export, column 1 (index) = the culture text of that locres
$utf8 = [Text.Encoding]::UTF8
$koRows = Read-CsvRows "$work\ko.csv" | Where-Object { $_.f[0] -ne 'key' }
$koMap = @{}
foreach ($r in $koRows) { $koMap[$r.f[0]] = $r.f[1] }
$enRows = Read-CsvRows "$work\en.csv" | Where-Object { $_.f[0] -ne 'key' }
$enMap = @{}
foreach ($r in $enRows) { $enMap[$r.f[0]] = $r.f[1] }
Write-Host ("[2] csv parsed: ko rows {0} (raw lines {1}); en rows {2}" -f $koMap.Count, (Get-Content "$work\ko.csv" | Measure-Object -Line).Lines, $enMap.Count)

# 3) build import csv (key,source,target with the fill policy) - UTF-8 no-BOM
$seedRows = Read-CsvRows $SeedCsv | Where-Object { $_.f[0] -ne 'key' }
$seed = @()
foreach ($r in $seedRows) { $seed += [pscustomobject]@{ key = $r.f[0]; arabic = $r.f[1] } }
$seedKeys = $seed.key
$impLines = New-Object System.Collections.Generic.List[string]
$impLines.Add('key,source,target')
$arabicRows = 0; $englishRows = 0; $skippedKeys = New-Object System.Collections.Generic.List[string]
foreach ($k in $koMap.Keys) {
    $koVal = $koMap[$k]
    if ($seedKeys -contains $k) {
        $s = $seed | Where-Object { $_.key -eq $k }
        $impLines.Add(('{0},{1},{2}' -f (CsvEsc $k), (CsvEsc $koVal), (CsvEsc $s.arabic)))
        $arabicRows++
    }
    elseif ($enMap.ContainsKey($k) -and ($enMap[$k] -ne '')) {
        $impLines.Add(('{0},{1},{2}' -f (CsvEsc $k), (CsvEsc $koVal), (CsvEsc $enMap[$k])))
        $englishRows++
    }
    else {
        $skippedKeys.Add($k)   # no en-US text: stays Korean
    }
}
[IO.File]::WriteAllLines("$work\import.csv", $impLines, (New-Object Text.UTF8Encoding($false)))
Write-Host ("[3] import csv: total ko keys {0} | arabic rows {1} | english-filled {2} | skipped (no en text, stay ko) {3}" -f $koMap.Count, $arabicRows, $englishRows, $skippedKeys.Count)

# 4) import into the ko-KR locres
& $ulr import -o "$work\kor-ar.locres" "$work\ko.locres" "$work\import.csv" 2>&1 | Out-Null
if (-not (Test-Path "$work\kor-ar.locres")) { throw 'UnrealLocres import failed' }
Write-Host ("[4] carrier locres: {0} bytes" -f (Get-Item "$work\kor-ar.locres").Length)

# 5) full round-trip validation of ALL THREE classes (value = re-export column 1)
# Comparison tiers: exact byte match first; if not, newline-normalized (\r\n -> \n)
# must match. The normalized-only class is counted and reported honestly: UnrealLocres
# v1.1.0 import converts embedded LF to CRLF in multiline values (cycle 005 finding;
# 5 multiline English strings inherited \r\n; the game's own ko locres natively
# contains one \r\n, so the engine demonstrably tolerates CRLF text). Real content
# mismatches remain hard failures.
& $ulr export -o "$work\kor-ar.csv" "$work\kor-ar.locres" 2>&1 | Out-Null
$map2 = @{}
$reRows = Read-CsvRows "$work\kor-ar.csv" | Where-Object { $_.f[0] -ne 'key' }
foreach ($r in $reRows) { $map2[$r.f[0]] = $r.f[1] }
function Test-Val([string]$got, [string]$want) {
    if ($got -ceq $want) { return 'exact' }
    if (($got -replace "`r`n", "`n") -ceq ($want -replace "`r`n", "`n")) { return 'newline' }
    return 'bad'
}
$bad = 0
$cArabic = 0; $cEnglish = 0; $cKo = 0
$exactRows = 0; $newlineRows = 0; $newlineKeys = New-Object System.Collections.Generic.List[string]
foreach ($k in $koMap.Keys) {
    $v = $map2[$k]
    $t = 'exact'
    if ($seedKeys -contains $k) {
        $s = $seed | Where-Object { $_.key -eq $k }
        $t = Test-Val $v $s.arabic
        if ($t -eq 'bad') { Write-Host ("  MISMATCH(ar) $k"); $bad++ } else { $cArabic++ }
    }
    elseif ($skippedKeys -contains $k) {
        $t = Test-Val $v $koMap[$k]
        if ($t -eq 'bad') { Write-Host ("  MISMATCH(ko) $k"); $bad++ } else { $cKo++ }
    }
    else {
        $t = Test-Val $v $enMap[$k]
        if ($t -eq 'bad') { Write-Host ("  MISMATCH(en) $k"); $bad++ } else { $cEnglish++ }
    }
    if ($t -eq 'exact') { $exactRows++ }
    elseif ($t -eq 'newline') { $newlineRows++; $newlineKeys.Add($k) }
}
Write-Host ("[5] round-trip: arabic {0}/{1} | english-filled {2}/{3} | kept-korean {4}/{5} | exact {6} | newline-normalized-only {7} | failures {8}" -f $cArabic, $arabicRows, $cEnglish, $englishRows, $cKo, $skippedKeys.Count, $exactRows, $newlineRows, $bad)
if ($newlineRows -gt 0) { Write-Host ("    keys with \r\n-vs-\n delta only (UnrealLocres import normalization): " + ((($newlineKeys | Select-Object -First 6) | ForEach-Object { $_.Substring(0, [Math]::Min(14, $_.Length)) }) -join ', ')) }
if ($bad -ne 0) { throw "round-trip validation failed: $bad mismatches" }
if ($cArabic -ne 25) { throw "seed coverage must be exactly 25, got $cArabic" }
# control samples for the human report: first english-filled + first kept-korean key
$enSample = ($koMap.Keys | Where-Object { ($seedKeys -notcontains $_) -and ($skippedKeys -notcontains $_) } | Select-Object -First 1)
Write-Host ("   sample english-filled: {0} -> {1}" -f $enSample, (($map2[$enSample] -replace '[^\x20-\x7E]', 'x')))
if ($skippedKeys.Count -gt 0) {
    Write-Host ("   sample kept-korean: {0}" -f $skippedKeys[0])
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
    "carrier koKR pak (p2, english-fill): $PakOut",
    "sha256: $sha",
    ("seed keys (Arabic): {0}" -f $arabicRows),
    ("english-filled keys: {0}" -f $englishRows),
    ("kept-korean keys (no en-US text): {0}" -f $skippedKeys.Count),
    ("total NewP5 ko-KR keys: {0}" -f $koMap.Count),
    ("round-trip: {0} byte-exact, {1} newline-normalized-only (\r\n by UnrealLocres import), {2} failures" -f $exactRows, $newlineRows, $bad),
    'source: NewP5 ko-KR + en-US locres (extracted from pakchunk0)',
    ("built (UTC): {0}" -f (Get-Date).ToUniversalTime().ToString('o')),
    'NOT INSTALLED'
)
Set-Content -Path (Join-Path $work 'carrier_record.txt') -Value $rec
Write-Host ("[8] sha256: {0}" -f $sha)
Write-Host "DONE - pak built and validated - NOT INSTALLED."
