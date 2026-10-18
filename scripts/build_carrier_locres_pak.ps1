<#
.SYNOPSIS
  Carrier builder (DEC-007 / DEC-016 / DEC-023). Builds a LOCRES-ONLY pak that carries
  text in the EXISTING ko-KR culture slot for EVERY ko-KR locres scope with user-visible
  text (35 scopes: UI, dialogue, subtitles, cutscenes, mail, DLC), not just NewP5.

.DESCRIPTION
  Fill policy, per ko-KR key, in this order:
    1. Arabic  - the master row for (scope, key) has a non-empty Arabic column
    2. English - the en-US locres has non-empty text for the same key (readable fallback)
    3. Korean  - neither: the original Korean text is kept (counted honestly)
  No LocMeta surgery, no font changes, no install.

  Per scope: extract ko-KR + en-US locres from pakchunk0 (read-only), UnrealLocres
  export/import, full round-trip validation of all three fill classes, then the
  locres is placed in the pak tree. Finally the pak is packed (repak V11, mount
  ../../../) and unpacked again for a byte-identical check of every entry.

  Outputs: the pak, build\staging\carrier_koKR_all\carrier_record.txt, and
           reports\carrier_build.md (per-scope table).
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$MasterTsV = '',
    [string]$PakOut = 'C:\AtomicHeart-AR\build\package\zzz_atomicheart-ar_carrier_koKR_p3_P.pak',
    [string]$VariantLabel = 'p3',
    [string]$OnlyScopes = ''      # optional comma-separated subset, for debugging
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

if (-not $MasterTsV) { $MasterTsV = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv' }
$repak = Join-Path $RepoRoot 'tools\bin\repak\repak.exe'
$ulr   = Join-Path $RepoRoot 'tools\bin\UnrealLocres\UnrealLocres.exe'
$pak0  = 'C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart\AtomicHeart\Content\Paks\pakchunk0-WindowsNoEditor.pak'
$work  = Join-Path $RepoRoot 'build\staging\carrier_koKR_all'
$reportPath = Join-Path $RepoRoot 'reports\carrier_build.md'

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
function Test-Val([string]$got, [string]$want) {
    if ($got -ceq $want) { return 'exact' }
    if (($got -replace "`r`n", "`n") -ceq ($want -replace "`r`n", "`n")) { return 'newline' }
    return 'bad'
}

# --- 0) scope list from the game pak (single source of truth)
$koEntries = @(& $repak list $pak0 2>$null | Where-Object { $_ -match '/ko-KR/.*\.locres$' })
$scopes = New-Object System.Collections.Generic.List[string]
foreach ($e in $koEntries) { $scopes.Add((($e -split '/')[5] -replace '\.locres$', '')) }
$scopes = @($scopes | Sort-Object)
if ($OnlyScopes) {
    $want = $OnlyScopes -split ','
    $scopes = @($scopes | Where-Object { $want -contains $_ })
}
if ($scopes.Count -eq 0) { throw 'no ko-KR locres scopes found' }

# --- 1) master Arabic lookup: scope -> key -> arabic
$masterAr = @{}
$mlines = [IO.File]::ReadAllLines($MasterTsV, [Text.Encoding]::UTF8)
$masterRows = 0; $masterArabic = 0
for ($i = 1; $i -lt $mlines.Count; $i++) {
    if (-not $mlines[$i].Trim()) { continue }
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $masterRows++
    if (-not $f[6].Trim()) { continue }
    $s = 'other'
    if ($f[2] -match '/Localization/(.+?)/en-US/') { $s = $Matches[1] }
    if (-not $masterAr.ContainsKey($s)) { $masterAr[$s] = @{} }
    $masterAr[$s][$f[4]] = $f[6]
    $masterArabic++
}
Write-Host ("[0] scopes {0} | master rows {1} | master rows with Arabic {2}" -f $scopes.Count, $masterRows, $masterArabic)

if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Force -Path $work | Out-Null
$packTree = Join-Path $work 'packtree'
New-Item -ItemType Directory -Force -Path $packTree | Out-Null

$stats = New-Object System.Collections.Generic.List[object]
$grandArabic = 0; $grandEnglish = 0; $grandKorean = 0; $grandKeys = 0; $grandFail = 0
$grandExact = 0; $grandNewline = 0

foreach ($scope in $scopes) {
    $safe = $scope -replace '[^A-Za-z0-9_\-]', '_'
    $sdir = Join-Path $work $safe
    New-Item -ItemType Directory -Force -Path $sdir | Out-Null
    $koEntry = "AtomicHeart/Content/Localization/$scope/ko-KR/$scope.locres"
    $enEntry = "AtomicHeart/Content/Localization/$scope/en-US/$scope.locres"

    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot 'scripts\get_pak_file.ps1') -Pak $pak0 -Entry $koEntry -OutFile "$sdir\ko.locres" *> $null
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot 'scripts\get_pak_file.ps1') -Pak $pak0 -Entry $enEntry -OutFile "$sdir\en.locres" *> $null

    & $ulr export -o "$sdir\ko.csv" "$sdir\ko.locres" 2>&1 | Out-Null
    & $ulr export -o "$sdir\en.csv" "$sdir\en.locres" 2>&1 | Out-Null
    $koMap = @{}
    foreach ($r in (Read-CsvRows "$sdir\ko.csv" | Where-Object { $_.f[0] -ne 'key' })) { $koMap[$r.f[0]] = $r.f[1] }
    $enMap = @{}
    foreach ($r in (Read-CsvRows "$sdir\en.csv" | Where-Object { $_.f[0] -ne 'key' })) { $enMap[$r.f[0]] = $r.f[1] }
    $arMap = @{}
    if ($masterAr.ContainsKey($scope)) { $arMap = $masterAr[$scope] }

    $imp = New-Object System.Collections.Generic.List[string]
    $imp.Add('key,source,target')
    $nAr = 0; $nEn = 0; $nKo = New-Object System.Collections.Generic.List[string]
    foreach ($k in $koMap.Keys) {
        $koVal = $koMap[$k]
        if ($arMap.ContainsKey($k) -and $arMap[$k].Trim()) {
            $imp.Add(('{0},{1},{2}' -f (CsvEsc $k), (CsvEsc $koVal), (CsvEsc $arMap[$k])))
            $nAr++
        } elseif ($enMap.ContainsKey($k) -and $enMap[$k] -ne '') {
            $imp.Add(('{0},{1},{2}' -f (CsvEsc $k), (CsvEsc $koVal), (CsvEsc $enMap[$k])))
            $nEn++
        } else {
            $nKo.Add($k)
        }
    }
    [IO.File]::WriteAllLines("$sdir\import.csv", $imp, (New-Object Text.UTF8Encoding($false)))

    & $ulr import -o "$sdir\carrier.locres" "$sdir\ko.locres" "$sdir\import.csv" 2>&1 | Out-Null
    if (-not (Test-Path "$sdir\carrier.locres")) { throw "UnrealLocres import failed for scope $scope" }

    & $ulr export -o "$sdir\re.csv" "$sdir\carrier.locres" 2>&1 | Out-Null
    $reMap = @{}
    foreach ($r in (Read-CsvRows "$sdir\re.csv" | Where-Object { $_.f[0] -ne 'key' })) { $reMap[$r.f[0]] = $r.f[1] }

    $bad = 0; $exact = 0; $newline = 0
    foreach ($k in $koMap.Keys) {
        if ($arMap.ContainsKey($k) -and $arMap[$k].Trim()) { $want = $arMap[$k] }
        elseif ($enMap.ContainsKey($k) -and $enMap[$k] -ne '') { $want = $enMap[$k] }
        else { $want = $koMap[$k] }
        $t = Test-Val $reMap[$k] $want
        if ($t -eq 'bad') { $bad++; Write-Host ("   MISMATCH ${scope} $k") }
        elseif ($t -eq 'exact') { $exact++ }
        else { $newline++ }
    }

    $dest = Join-Path $packTree "AtomicHeart\Content\Localization\$scope\ko-KR"
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Copy-Item "$sdir\carrier.locres" (Join-Path $dest "$scope.locres") -Force

    $stats.Add([pscustomobject]@{
        scope = $scope; keys = $koMap.Count; arabic = $nAr; english = $nEn; korean = $nKo.Count
        exact = $exact; newline = $newline; bad = $bad
    })
    $grandArabic += $nAr; $grandEnglish += $nEn; $grandKorean += $nKo.Count; $grandKeys += $koMap.Count
    $grandFail += $bad; $grandExact += $exact; $grandNewline += $newline
    Write-Host ("[{0}] keys {1} | arabic {2} | english {3} | kept-korean {4} | exact {5} | newline-only {6} | FAIL {7}" -f $scope, $koMap.Count, $nAr, $nEn, $nKo.Count, $exact, $newline, $bad)
}
if ($grandFail -ne 0) { throw "round-trip validation failed: $grandFail mismatches" }

# --- pack
New-Item -ItemType Directory -Force -Path (Split-Path $PakOut -Parent) | Out-Null
if (Test-Path $PakOut) { Remove-Item $PakOut -Force }
& $repak pack --version V11 --mount-point '../../../' $packTree $PakOut 2>&1 | Select-Object -Last 2
if (-not (Test-Path $PakOut)) { throw 'repak pack failed' }
$pakEntries = @(& $repak list $PakOut)
Write-Host ("[pack] {0} ({1} bytes) entries {2}" -f $PakOut, (Get-Item $PakOut).Length, $pakEntries.Count)

# --- unpack verify byte-identical for every entry
$unpack = Join-Path $work 'verify'
New-Item -ItemType Directory -Force -Path $unpack | Out-Null
& $repak unpack -o $unpack -f $PakOut 2>&1 | Select-Object -Last 1 | Out-Null
$verifyBad = 0; $verifyOk = 0
foreach ($e in $pakEntries) {
    $src = Join-Path $packTree ($e -replace '/', '\')
    $dst = Join-Path $unpack ($e -replace '/', '\')
    if (-not (Test-Path $src) -or -not (Test-Path $dst)) { $verifyBad++; continue }
    if ((Get-FileHash $src).Hash -eq (Get-FileHash $dst).Hash) { $verifyOk++ } else { $verifyBad++; Write-Host ("   UNPACK DIFF: $e") }
}
Write-Host ("[verify] unpack byte-identical {0}/{1} (bad {2})" -f $verifyOk, $pakEntries.Count, $verifyBad)
if ($verifyBad -ne 0) { throw 'unpack verification failed' }

# --- record + report
$sha = (Get-FileHash $PakOut).Hash.ToLower()
$rec = @(
    "carrier pak variant $VariantLabel (english-fill, all 35 ko-KR scopes)",
    "path: $PakOut",
    "sha256: $sha",
    ("scopes: {0}" -f $scopes.Count),
    ("total ko keys: {0}" -f $grandKeys),
    ("Arabic rows: {0}" -f $grandArabic),
    ("english-filled keys: {0}" -f $grandEnglish),
    ("kept-korean keys (no en-US text): {0}" -f $grandKorean),
    ("round-trip: {0} byte-exact, {1} newline-normalized-only, {2} failures" -f $grandExact, $grandNewline, $grandFail),
    ("unpack verify: {0} entries byte-identical" -f $verifyOk),
    'source: ko-KR + en-US locres extracted from pakchunk0 (read-only)',
    ("built (UTC): {0}" -f (Get-Date).ToUniversalTime().ToString('o')),
    'NOT INSTALLED'
)
[IO.File]::WriteAllLines((Join-Path $work 'carrier_record.txt'), $rec, (New-Object Text.UTF8Encoding($false)))

$r = New-Object System.Collections.Generic.List[string]
$r.Add('# Carrier pak build report')
$r.Add('')
$r.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$r.Add(('Variant: **{0}**  |  pak: `{1}`' -f $VariantLabel, $PakOut))
$r.Add(('sha256: `{0}`  |  size: {1} bytes' -f $sha, (Get-Item $PakOut).Length))
$r.Add('')
$r.Add('Fill policy: Arabic (master non-empty) > English (en-US same key) > keep Korean.')
$r.Add('')
$r.Add('| metric | value |')
$r.Add('|---|---|')
$r.Add(('| scopes covered | {0} |' -f $scopes.Count))
$r.Add(('| total ko-KR keys | {0} |' -f $grandKeys))
$r.Add(('| Arabic rows | {0} |' -f $grandArabic))
$r.Add(('| english-filled keys | {0} |' -f $grandEnglish))
$r.Add(('| kept Korean (no en-US text) | {0} |' -f $grandKorean))
$r.Add(('| round-trip exact | {0} |' -f $grandExact))
$r.Add(('| round-trip newline-normalized only | {0} |' -f $grandNewline))
$r.Add(('| round-trip failures | {0} |' -f $grandFail))
$r.Add(('| unpack byte-identical entries | {0} of {1} |' -f $verifyOk, $pakEntries.Count))
$r.Add('')
$r.Add('## Per scope')
$r.Add('')
$r.Add('| scope | ko keys | Arabic | English | kept Korean | exact | newline-only | fail |')
$r.Add('|---|---|---|---|---|---|---|---|')
foreach ($s in $stats) {
    $r.Add(('| {0} | {1} | {2} | {3} | {4} | {5} | {6} | {7} |' -f $s.scope, $s.keys, $s.arabic, $s.english, $s.korean, $s.exact, $s.newline, $s.bad))
}
$r.Add('')
$r.Add('## Pak entries')
$r.Add('')
foreach ($e in $pakEntries) { $r.Add('- ' + $e) }
$r.Add('')
[IO.File]::WriteAllLines($reportPath, $r, (New-Object Text.UTF8Encoding($false)))

Write-Host ''
Write-Host ("TOTAL: keys {0} | arabic {1} | english {2} | korean {3} | exact {4} | newline {5} | fail {6}" -f $grandKeys, $grandArabic, $grandEnglish, $grandKorean, $grandExact, $grandNewline, $grandFail)
Write-Host ("sha256: {0}" -f $sha)
Write-Host ("report: {0}" -f $reportPath)
Write-Host "DONE - carrier pak built and validated - NOT INSTALLED."
