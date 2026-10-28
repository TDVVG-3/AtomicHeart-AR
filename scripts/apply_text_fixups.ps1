<#
.SYNOPSIS
  Applies reviewer text fixes to the master TSV, the translation memory and the seed CSV.

.DESCRIPTION
  Rules live in a UTF-8 DATA file (default localization/working/tm_fixups.tsv) because
  PowerShell 5.1 mangles non-ASCII literals inside .ps1 files (KI-021).

  Supported rule shapes (tab-separated):
    3 columns: find, replace, note
       - global literal replacement (all master/tm/seed rows)
       - note containing [exact] means "whole Arabic cell equals find"
    5 columns: find, replace, note, selector, value
       - selector=cell,  value=scope|key : replace a weapon/item name inside that one
         master cell only. Boundary-safe; tags, placeholders and timing markers are
         checked before the row is written. TM/seed are skipped because they do not
         carry scope+key.
       - selector=label, value=English : fill an EMPTY Arabic cell whose English source
         is exactly value (speaker labels such as P-3). Non-empty cells are never
         overwritten; a differing value is logged as a conflict.

  Rows are never created, deleted or reordered. Idempotent: running twice changes nothing.
  Writes reports/text_fixups_log.md with per-rule counts and a bounded list of rows.

  -DryRun reports what would change without writing anything.
  -MasterTsV overrides the master path (use a variant master).
  -MasterOnly skips tm.tsv / phase7_seed.csv (cell/label rules are master-only anyway).
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$Fixups = '',
    [string]$MasterTsV = '',
    [string]$LogPath = '',
    [switch]$MasterOnly,
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

if (-not $Fixups) { $Fixups = Join-Path $RepoRoot 'localization\working\tm_fixups.tsv' }
if (-not $MasterTsV) { $MasterTsV = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv' }
$masterPath = $MasterTsV
$tmPath     = Join-Path $RepoRoot 'localization\working\tm.tsv'
$seedPath   = Join-Path $RepoRoot 'localization\working\phase7_seed.csv'
if (-not $LogPath) { $LogPath = Join-Path $RepoRoot 'reports\text_fixups_log.md' }
$logPath    = $LogPath
$utf8NoBom  = New-Object Text.UTF8Encoding($false)
$TAB = [char]9

$rules = New-Object System.Collections.Generic.List[object]
$fx = [IO.File]::ReadAllLines($Fixups, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $fx.Count; $i++) {
    if (-not $fx[$i].Trim()) { continue }
    $f = $fx[$i] -split "`t"
    if ($f.Count -lt 3) { throw "fixups line $($i+1) needs at least 3 tab-separated fields" }
    $selector = ''; $value = ''
    if ($f.Count -ge 5) { $selector = $f[3].Trim(); $value = $f[4] }
    if ($selector -and $selector -notin @('cell','label')) { throw "fixups line $($i+1): unknown selector '$selector'" }
    $rules.Add([pscustomobject]@{
        find = $f[0]; replace = $f[1]; note = $f[2]
        selector = $selector; value = $value
        exact = $f[2].Contains('[exact]')
        hits = New-Object System.Collections.Generic.List[string]
        changed = 0
        skipped = 0
    })
}

function Get-Scope([string]$file) {
    $s = 'other'
    if ($file -match '/Localization/(.+?)/en-US/') { $s = $Matches[1] }
    return $s
}
function Test-ArabicLetter([char]$c) {
    return [bool]($c -match '[\u0621-\u064A\u0660-\u0669\u066E-\u06D3\u06D5\u06E5-\u06E6\u06EE-\u06EF\u06FA-\u06FC\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]')
}
function Test-LatinLetter([char]$c) {
    return [bool](($c -ge [char]'A' -and $c -le [char]'Z') -or ($c -ge [char]'a' -and $c -le [char]'z'))
}
function Has-ArabicLetter([string]$s) {
    return [bool]([regex]::IsMatch($s, '[\u0621-\u064A\u0660-\u0669\u066E-\u06D3\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF]'))
}
function Test-TrailingPunct([char]$c) {
    # Arabic comma/semicolon/question, ASCII sentence punctuation, ellipsis.
    # A closing guillemet is NOT included: «NAME» must stay tight.
    return ($c -in @([char]0x060C, [char]0x061B, [char]0x061F, [char]0x003A, [char]0x002E, [char]0x0021, [char]0x2026))
}
function Get-Protected([string]$s) {
    $tags = [regex]::Matches($s, '<[^<>]*>') | ForEach-Object { $_.Value } | Sort-Object
    $ph   = [regex]::Matches($s, '\{[^{}]*\}|%[sdifx]|\\[nrt]') | ForEach-Object { $_.Value } | Sort-Object
    $mk   = [regex]::Matches($s, '\*[0-9][0-9.\-]*\*|&[^&]{1,40}&') | ForEach-Object { $_.Value } | Sort-Object
    return (($tags -join '|') + '#' + ($ph -join '|') + '#' + ($mk -join '|'))
}
function Replace-CellName([string]$text, [string]$find, [string]$replace) {
    if (-not $find -or -not $text) { return [pscustomobject]@{ Text = $text; Count = 0 } }
    $sb = New-Object Text.StringBuilder
    $pos = 0; $count = 0
    while (($idx = $text.IndexOf($find, $pos, [StringComparison]::Ordinal)) -ge 0) {
        $beforeOk = ($idx -eq 0) -or (-not (Test-ArabicLetter $text[$idx - 1]))
        $afterIdx = $idx + $find.Length
        $afterOk = ($afterIdx -ge $text.Length) -or (-not (Test-ArabicLetter $text[$afterIdx]))
        if ($beforeOk -and $afterOk) {
            $sb.Append($text.Substring($pos, $idx - $pos)) | Out-Null
            $sb.Append($replace) | Out-Null
            if ($afterIdx -lt $text.Length -and $replace.Length -gt 0 -and (Test-LatinLetter $replace[$replace.Length - 1]) -and (Test-TrailingPunct $text[$afterIdx])) {
                $sb.Append(' ') | Out-Null
            }
            $pos = $afterIdx
            $count++
        } else {
            $sb.Append($text.Substring($pos, ($afterIdx - $pos))) | Out-Null
            $pos = $afterIdx
        }
    }
    $sb.Append($text.Substring($pos)) | Out-Null
    return [pscustomobject]@{ Text = $sb.ToString(); Count = $count }
}

$log = New-Object System.Collections.Generic.List[string]
$log.Add('# Reviewer text fixes')
$log.Add('')
$log.Add(('Applied: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$log.Add(('Rules: `{0}`' -f $Fixups))
$log.Add(('Master: `{0}`' -f $masterPath))
$log.Add(('Mode: {0}' -f $(if ($DryRun) { 'DRY RUN (nothing written)' } else { 'apply' })))
$log.Add('')

# --- master
$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$masterChanged = 0
for ($i = 1; $i -lt $mlines.Count; $i++) {
    if (-not $mlines[$i].Trim()) { continue }
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $scope = Get-Scope $f[2]
    $sig = $scope + '|' + $f[4]
    $en = $f[5]; $ar = $f[6]
    $new = $ar
    $rowChanged = $false
    foreach ($r in $rules) {
        if ($r.selector -eq 'cell') {
            if ($sig -cne $r.value) { continue }
            $res = Replace-CellName $new $r.find $r.replace
            if ($res.Count -gt 0) {
                $candidate = $res.Text
                if ((Get-Protected $candidate) -ne (Get-Protected $ar)) {
                    throw ("line {0}: protected tag/placeholder/marker changed by cell rule '{1}'" -f ($i + 1), $r.note)
                }
                # Never turn a translated sentence into an English-only cell. That is a
                # keep-original NAME row, handled by COPY, not by an in-sentence rule.
                if ((Has-ArabicLetter $ar) -and -not (Has-ArabicLetter $candidate)) {
                    $r.skipped++
                    if ($r.hits.Count -lt 20) { $r.hits.Add(('SKIP would remove all Arabic L{0} | {1} | {2}' -f ($i + 1), $scope, $f[4])) }
                    continue
                }
                $new = $candidate
                $r.changed += $res.Count
                if ($r.hits.Count -lt 20) { $r.hits.Add(('L{0} | {1} | {2}' -f ($i + 1), $scope, $f[4])) }
                $rowChanged = $true
            }
            continue
        }
        if ($r.selector -eq 'label') {
            if ($en.Trim() -cne $r.value) { continue }
            if (-not $ar.Trim()) {
                $new = $r.replace
                if ($f[10] -in @('', 'UNTRANSLATED')) { $f[10] = 'DRAFT' }
                if ($f[11] -notmatch 'speaker label filled') {
                    $f[11] = if ($f[11].Trim()) { $f[11] + '; speaker label filled' } else { 'speaker label filled' }
                }
                $r.changed++
                if ($r.hits.Count -lt 20) { $r.hits.Add(('L{0} | {1} | {2}' -f ($i + 1), $scope, $f[4])) }
                $rowChanged = $true
            } elseif ($ar -cne $r.replace) {
                $r.skipped++
                if ($r.hits.Count -lt 20) { $r.hits.Add(('SKIP non-empty L{0} | {1} | {2}' -f ($i + 1), $scope, $f[4])) }
            }
            continue
        }
        # global rule
        if ($r.exact) {
            if ($new -ceq $r.find) {
                $new = $r.replace
                $r.changed++
                if ($r.hits.Count -lt 20) { $r.hits.Add(('L{0} | {1} | {2}' -f ($i + 1), $scope, $f[4])) }
                $rowChanged = $true
            }
            continue
        }
        if ($new.Contains($r.find)) {
            $new = $new.Replace($r.find, $r.replace)
            $r.changed++
            if ($r.hits.Count -lt 20) { $r.hits.Add(('L{0} | {1} | {2}' -f ($i + 1), $scope, $f[4])) }
            $rowChanged = $true
        }
    }
    if ($new -ne $ar) {
        $f[6] = $new
        $mlines[$i] = ($f -join "`t")
        $masterChanged++
    }
}
if (-not $DryRun) { [IO.File]::WriteAllLines($masterPath, $mlines, $utf8NoBom) }

# --- translation memory (global + label rules; cell rules need scope+key)
$tmChanged = 0
if (-not $MasterOnly -and (Test-Path $tmPath)) {
    $tlines = [IO.File]::ReadAllLines($tmPath, [Text.Encoding]::UTF8)
    for ($i = 1; $i -lt $tlines.Count; $i++) {
        if (-not $tlines[$i].Trim()) { continue }
        $f = $tlines[$i] -split "`t"
        if ($f.Count -lt 2) { continue }
        $new = $f[1]
        foreach ($r in $rules) {
            if ($r.selector -eq 'cell') { continue }
            if ($r.selector -eq 'label') {
                if ($f[0].Trim() -ceq $r.value -and -not $new.Trim()) { $new = $r.replace }
                continue
            }
            if ($r.exact) { if ($new -ceq $r.find) { $new = $r.replace }; continue }
            if ($new.Contains($r.find)) { $new = $new.Replace($r.find, $r.replace) }
        }
        if ($new -ne $f[1]) { $f[1] = $new; $tlines[$i] = ($f -join "`t"); $tmChanged++ }
    }
    if (-not $DryRun) { [IO.File]::WriteAllLines($tmPath, $tlines, $utf8NoBom) }
}

# --- seed csv (global rules only; it has no English column)
$seedChanged = 0
if (-not $MasterOnly -and (Test-Path $seedPath)) {
    $slines = [IO.File]::ReadAllLines($seedPath, [Text.Encoding]::UTF8)
    for ($i = 1; $i -lt $slines.Count; $i++) {
        if (-not $slines[$i].Trim()) { continue }
        $idx = $slines[$i].IndexOf(',')
        if ($idx -lt 1) { continue }
        $key = $slines[$i].Substring(0, $idx)
        $val = $slines[$i].Substring($idx + 1)
        $new = $val
        foreach ($r in $rules) {
            if ($r.selector) { continue }
            if ($r.exact) { if ($new -ceq $r.find) { $new = $r.replace }; continue }
            if ($new.Contains($r.find)) { $new = $new.Replace($r.find, $r.replace) }
        }
        if ($new -ne $val) { $slines[$i] = ($key + ',' + $new); $seedChanged++ }
    }
    if (-not $DryRun) { [IO.File]::WriteAllLines($seedPath, $slines, $utf8NoBom) }
}

$cellRules = @($rules | Where-Object { $_.selector -eq 'cell' })
$labelRules = @($rules | Where-Object { $_.selector -eq 'label' })
$globalRules = @($rules | Where-Object { -not $_.selector })

Write-Output ('TEXT FIXUPS {0}: master rows {1} | tm rows {2} | seed rows {3} | rules {4} (global {5}, cell {6}, label {7})' -f $(if ($DryRun) { 'DRY RUN' } else { 'APPLIED' }), $masterChanged, $tmChanged, $seedChanged, $rules.Count, $globalRules.Count, $cellRules.Count, $labelRules.Count)
$log.Add(('master rows changed: {0} | tm rows changed: {1} | seed rows changed: {2}' -f $masterChanged, $tmChanged, $seedChanged))
$log.Add(('rules: {0} (global {1}, cell {2}, label {3})' -f $rules.Count, $globalRules.Count, $cellRules.Count, $labelRules.Count))
$log.Add('')
$idx = 0
foreach ($r in $rules) {
    $idx++
    $kind = 'global'; if ($r.selector) { $kind = $r.selector }
    $log.Add(('## {0}. [{1}] {2} -> {3}' -f $idx, $kind, $r.find, $r.replace))
    $log.Add('')
    $log.Add(('note: {0}' -f $r.note))
    if ($r.selector) { $log.Add(('selector: {0} = {1}' -f $r.selector, $r.value)) }
    $log.Add(('changed: {0} | skipped/conflicts: {1}' -f $r.changed, $r.skipped))
    foreach ($h in $r.hits) { $log.Add(('- ' + $h)) }
    if ($r.changed -gt $r.hits.Count) { $log.Add(('- ... {0} more' -f ($r.changed - $r.hits.Count))) }
    $log.Add('')
    if ($r.changed -gt 0) {
        $short = $r.note.Substring(0, [Math]::Min(50, $r.note.Length))
        Write-Output ('  [{0}] {1} -> changed {2}, skipped {3}' -f $kind, $short, $r.changed, $r.skipped)
    }
}
[IO.File]::WriteAllLines($logPath, $log, $utf8NoBom)
Write-Output ('log: ' + $logPath)
