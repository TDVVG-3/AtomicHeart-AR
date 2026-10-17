<#
.SYNOPSIS
  Phase 5 deliverable: cross-references every extracted StringTable/DataTable text dump
  (ascii key candidates) against ALL en-US locres exports to measure which tables have
  their strings present in the locres corpus (culture-mediated) and which do not.

.DESCRIPTION
  Locres key format observed (UnrealLocres csv): "<namespace>/<key>" (namespace may be
  empty, or may differ from the asset name, e.g. 'All_Const_dlc2/Kolobok').
  So keys are matched by their SUFFIX (the part after the last '/').

  Output: reports/stringtable_coverage.csv
    asset, container, asciiKeys, keysFound, locresTargets, verdict
    verdict: COVERED (all keys found) / PARTIAL (some) / NOT-COVERED (none), and
    'no-keys' for dumps with no exploitable ascii keys (e.g. non-stringtables).
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'

$csvRoot = Join-Path $RepoRoot 'localization\generated\locres_csv'
$dumpRoot = Join-Path $RepoRoot 'localization\extracted\uasset_text'
$outPath = Join-Path $RepoRoot 'reports\stringtable_coverage.csv'

# 1. Build key-suffix -> csv name map from every en-US locres export
$suffixMap = @{}
foreach ($csv in (Get-ChildItem $csvRoot -Filter '*.csv')) {
    foreach ($line in (Get-Content $csv.FullName -Encoding UTF8)) {
        $comma = $line.IndexOf(',')
        if ($comma -lt 2) { continue }
        $locresKey = $line.Substring(0, $comma)
        if ($locresKey -eq 'key') { continue }
        $slash = $locresKey.LastIndexOf('/')
        $suffix = if ($slash -ge 0) { $locresKey.Substring($slash + 1) } else { $locresKey }
        if ($suffix.Length -ge 4 -and -not $suffixMap.ContainsKey($suffix)) {
            $suffixMap[$suffix] = $csv.BaseName
        }
    }
}
Write-Host ("[OK] locres key suffixes loaded: {0}" -f $suffixMap.Count)

# 2. For each text dump, take the asset name and its ascii key candidates
$rows = New-Object System.Collections.Generic.List[string]
$rows.Add('asset,container,asciiKeys,keysFound,locresTargets,verdict')

foreach ($dump in (Get-ChildItem $dumpRoot -Filter '*.txt' | Sort-Object Name)) {
    $lines = Get-Content $dump.FullName -Encoding UTF8
    if ($lines.Count -lt 2) { continue }
    $header = $lines[0]
    if ($header -notmatch '([A-Za-z0-9_]+)\.uexp') { continue }
    $assetName = $Matches[1]
    $parsed = $false
    # container from dump file name prefix "pakchunkN-WindowsNoEditor__<base>.txt"
    $container = ($dump.BaseName -split '__')[0]

    # ascii section = after the '## ASCII' marker; candidate keys = lines with
    # lowercase/underscore snake style, len >= 6, not class/property names
    $asciiStart = $false
    $keys = New-Object System.Collections.Generic.List[string]
    foreach ($l in $lines) {
        if ($l -match '^## ASCII') { $asciiStart = $true; continue }
        if ($asciiStart) {
            if ($l -match '^[a-z][a-z0-9_]{5,}$') { $keys.Add($l) }
            elseif ($l -match '^[A-Z][A-Za-z0-9_]{2,}$') { $keys.Add($l) }
        }
    }
    $keys = ($keys | Select-Object -Unique) | Select-Object -First 400

    $targets = New-Object System.Collections.Generic.List[string]
    $found = 0
    foreach ($k in $keys) {
        if ($suffixMap.ContainsKey($k)) { $found++; if ($targets -notcontains $suffixMap[$k]) { $targets.Add($suffixMap[$k]) } }
    }
    $n = $keys.Count
    $verdict = if ($n -eq 0) { 'no-keys' }
               elseif ($found -eq $n) { 'COVERED' }
               elseif ($found -gt 0) { 'PARTIAL' }
               else { 'NOT-COVERED' }
    $rows.Add(('{0},{1},{2},{3},"{4}",{5}' -f $assetName, $container, $n, $found, ($targets -join '+'), $verdict))
}

Set-Content -Path $outPath -Value $rows -Encoding UTF8
# summary
$summary = $rows | Select-Object -Skip 1 | ForEach-Object { ($_ -split ',')[-1] } | Group-Object
Write-Host '=== coverage verdict summary ==='
$summary | ForEach-Object { Write-Host ("  {0,-12} {1}" -f $_.Name, $_.Count) }
Write-Host "[DONE] $outPath"
