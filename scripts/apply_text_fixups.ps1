<#
.SYNOPSIS
  Applies reviewer text fixes to the master TSV, the translation memory and the seed CSV.

.DESCRIPTION
  Rules live in localization/working/tm_fixups.tsv (find, replace, note) - a UTF-8 DATA file,
  because PowerShell 5.1 mangles non-ASCII literals inside .ps1 files (KI-021).

  Every rule is a literal (not regex) replacement applied to:
    - localization/master/atomic-heart-ar.tsv   (Arabic column only, index 6)
    - localization/working/tm.tsv               (arabic column)
    - localization/working/phase7_seed.csv      (value side of key,value)
  Rows are never created, deleted or reordered. Idempotent: running twice changes nothing.
  Writes reports/text_fixups_log.md with per-rule counts and the affected rows.

  -DryRun reports what would change without writing anything.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$Fixups = '',
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

if (-not $Fixups) { $Fixups = Join-Path $RepoRoot 'localization\working\tm_fixups.tsv' }
$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$tmPath     = Join-Path $RepoRoot 'localization\working\tm.tsv'
$seedPath   = Join-Path $RepoRoot 'localization\working\phase7_seed.csv'
$logPath    = Join-Path $RepoRoot 'reports\text_fixups_log.md'
$utf8NoBom  = New-Object Text.UTF8Encoding($false)

$rules = New-Object System.Collections.Generic.List[object]
$fx = [IO.File]::ReadAllLines($Fixups, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $fx.Count; $i++) {
    if (-not $fx[$i].Trim()) { continue }
    $f = $fx[$i] -split "`t"
    if ($f.Count -lt 3) { throw "tm_fixups.tsv line $($i+1) needs 3 tab-separated fields" }
    $rules.Add([pscustomobject]@{ find = $f[0]; replace = $f[1]; note = $f[2]; exact = $f[2].Contains('[exact]') })
}

$log = New-Object System.Collections.Generic.List[string]
$log.Add('# Reviewer text fixes')
$log.Add('')
$log.Add(('Applied: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$log.Add(('Mode: {0}' -f $(if ($DryRun) { 'DRY RUN (nothing written)' } else { 'apply' })))
$log.Add('')

# --- master
$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$masterHits = @{}
foreach ($r in $rules) { $masterHits[$r.find] = New-Object System.Collections.Generic.List[string] }
$masterChanged = 0
for ($i = 1; $i -lt $mlines.Count; $i++) {
    if (-not $mlines[$i].Trim()) { continue }
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $ar = $f[6]
    $new = $ar
    foreach ($r in $rules) {
        if ($r.exact) {
            if ($new -ceq $r.find) {
                $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
                $masterHits[$r.find].Add(('{0} | {1} | {2}' -f $scope, $f[4], $f[9]))
                $new = $r.replace
            }
            continue
        }
        if ($new.Contains($r.find)) {
            $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
            $masterHits[$r.find].Add(('{0} | {1} | {2}' -f $scope, $f[4], $f[9]))
            $new = $new.Replace($r.find, $r.replace)
        }
    }
    if ($new -ne $ar) {
        $f[6] = $new
        $mlines[$i] = ($f -join "`t")
        $masterChanged++
    }
}
if (-not $DryRun) { [IO.File]::WriteAllLines($masterPath, $mlines, $utf8NoBom) }

# --- translation memory
$tmChanged = 0
if (Test-Path $tmPath) {
    $tlines = [IO.File]::ReadAllLines($tmPath, [Text.Encoding]::UTF8)
    for ($i = 1; $i -lt $tlines.Count; $i++) {
        if (-not $tlines[$i].Trim()) { continue }
        $f = $tlines[$i] -split "`t"
        if ($f.Count -lt 2) { continue }
        $new = $f[1]
        foreach ($r in $rules) {
            if ($r.exact) { if ($new -ceq $r.find) { $new = $r.replace }; continue }
            if ($new.Contains($r.find)) { $new = $new.Replace($r.find, $r.replace) }
        }
        if ($new -ne $f[1]) { $f[1] = $new; $tlines[$i] = ($f -join "`t"); $tmChanged++ }
    }
    if (-not $DryRun) { [IO.File]::WriteAllLines($tmPath, $tlines, $utf8NoBom) }
}

# --- seed csv (keep the reproduction source in sync)
$seedChanged = 0
if (Test-Path $seedPath) {
    $slines = [IO.File]::ReadAllLines($seedPath, [Text.Encoding]::UTF8)
    for ($i = 1; $i -lt $slines.Count; $i++) {
        if (-not $slines[$i].Trim()) { continue }
        $idx = $slines[$i].IndexOf(',')
        if ($idx -lt 1) { continue }
        $key = $slines[$i].Substring(0, $idx)
        $val = $slines[$i].Substring($idx + 1)
        $new = $val
        foreach ($r in $rules) {
            if ($r.exact) { if ($new -ceq $r.find) { $new = $r.replace }; continue }
            if ($new.Contains($r.find)) { $new = $new.Replace($r.find, $r.replace) }
        }
        if ($new -ne $val) { $slines[$i] = ($key + ',' + $new); $seedChanged++ }
    }
    if (-not $DryRun) { [IO.File]::WriteAllLines($seedPath, $slines, $utf8NoBom) }
}

Write-Output ('TEXT FIXUPS {0}: master rows {1} | tm rows {2} | seed rows {3}' -f $(if ($DryRun) { 'DRY RUN' } else { 'APPLIED' }), $masterChanged, $tmChanged, $seedChanged)
$log.Add(('master rows changed: {0} | tm rows changed: {1} | seed rows changed: {2}' -f $masterChanged, $tmChanged, $seedChanged))
$log.Add('')
foreach ($r in $rules) {
    $log.Add(('## {0} -> {1}' -f $r.find, $r.replace))
    $log.Add('')
    $log.Add(('note: {0}' -f $r.note))
    $log.Add(('master rows matched: {0}' -f $masterHits[$r.find].Count))
    foreach ($h in $masterHits[$r.find]) { $log.Add(('- ' + $h)) }
    $log.Add('')
    Write-Output ('  rule [{0}] -> master rows {1}' -f $r.note.Substring(0, [Math]::Min(40, $r.note.Length)), $masterHits[$r.find].Count)
    foreach ($h in $masterHits[$r.find]) { Write-Output ('      ' + $h) }
}
[IO.File]::WriteAllLines($logPath, $log, $utf8NoBom)
Write-Output ('log: ' + $logPath)
