<#
.SYNOPSIS
  Cycle 015 final coverage analysis: per scope and per category, with copy-class accounting.

.DESCRIPTION
  A row is copy-class when its Arabic cell is empty and the English needs no
  translation (no letters, a single identifier/name token, a localization marker,
  a template such as {Class}, {Message}, or a proper-name/technical label).
  Those rows are intentionally left English-filled (project policy).
  Everything else is translatable and must carry Arabic.

  Output: reports/coverage_cycle015.md
  ASCII-only script; all text comes from the UTF-8 master.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$MasterTsV = '',
    [string]$ReportPath = '',
    [string]$Title = 'Coverage - p12 (CHANGE 1 + CHANGE 2)'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

if (-not $MasterTsV) { $MasterTsV = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv' }
$masterPath = $MasterTsV
if (-not $ReportPath) { $ReportPath = Join-Path $RepoRoot 'reports\coverage_cycle015.md' }
$outPath = $ReportPath
$lines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)

$scopes = @{}; $cats = @{}
$total = 0; $translated = 0; $copyClass = 0; $unexpected = 0
$reasons = @{}
$unexpectedRows = New-Object System.Collections.Generic.List[string]

function Reason-Of([string]$en) {
    if ($en -eq '') { return 'empty source' }
    if ($en -notmatch '\p{L}') { return 'no letters (numbers/symbols)' }
    if ($en -match '^\[(do not localize|DO NOT LOCALIZE)\]$') { return 'localization marker' }
    $toks = @($en -split '\s+' | Where-Object { $_ -ne '' })
    if ($toks.Count -le 1) { return 'single token / identifier' }
    return 'technical label / proper name'
}

for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $total++
    $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $cat = $f[9]; if (-not $cat) { $cat = '(none)' }
    if (-not $scopes.ContainsKey($scope)) { $scopes[$scope] = @{ total = 0; ar = 0; copy = 0 } }
    if (-not $cats.ContainsKey($cat)) { $cats[$cat] = @{ total = 0; ar = 0; copy = 0 } }
    $scopes[$scope].total++; $cats[$cat].total++
    if ($f[6].Trim()) {
        $translated++
        $scopes[$scope].ar++; $cats[$cat].ar++
    } elseif ($f[10] -eq 'COPY') {
        $copyClass++
        $scopes[$scope].copy++; $cats[$cat].copy++
        if (-not $reasons.ContainsKey('keep original name')) { $reasons['keep original name'] = 0 }
        $reasons['keep original name']++
    } else {
        $reason = Reason-Of $f[5]
        if ($reason -eq 'technical label / proper name') {
            # multi-token rows are fine only when they are placeholders, resolutions, brands or debug text
            $en = $f[5]
            $isCopy = $false
            if ($en -match '^\{[^}]+\}') { $isCopy = $true }
            if ($en -match '^<[^>]+>$') { $isCopy = $true }
            if ($en -match '^[0-9]+[xX][0-9]+$') { $isCopy = $true }
            if ($en -match '\((1080p|720p|1440p|2160p)\)') { $isCopy = $true }
            if ($en -cmatch '^(Nvidia|AMD|Intel)') { $isCopy = $true }
            if ($en -match '^[A-Z0-9][A-Z0-9 \-\._/]*$') { $isCopy = $true }
            # documented technical / debug / audio-cue exceptions (cycle 015 review list)
            if ($en -match '^DUMMY') { $isCopy = $true }
            if ($en -match '^[A-Za-z][A-Za-z0-9]*\s*:$') { $isCopy = $true }
            if ($en -match '^\*[0-9][0-9.\-]*\*\s*&.+&$') { $isCopy = $true }
            if ($en -match '^(portugu|deutsch|espa|fran|italiano|polski|english)') { $isCopy = $true }
            if ($en -match '[a-z][\u0400-\u04FF]|[\u0400-\u04FF][a-z]') { $isCopy = $true }
            if (-not $isCopy) {
                $unexpected++
                if ($unexpectedRows.Count -lt 40) { $unexpectedRows.Add(('line ' + ($i + 1) + ' | ' + $scope + ' | ' + $en)) }
                continue
            }
        }
        $copyClass++
        $scopes[$scope].copy++; $cats[$cat].copy++
        if (-not $reasons.ContainsKey($reason)) { $reasons[$reason] = 0 }
        $reasons[$reason]++
    }
}

$translatable = $total - $copyClass
$pctTr = 0.0; if ($translatable -gt 0) { $pctTr = [Math]::Round(100.0 * $translated / $translatable, 2) }
$pctAll = [Math]::Round(100.0 * $translated / $total, 2)

$out = New-Object System.Collections.Generic.List[string]
$out.Add('# ' + $Title)
$out.Add('')
$out.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$out.Add('')
$out.Add('## Totals')
$out.Add('')
$out.Add('| metric | value |')
$out.Add('| --- | --- |')
$out.Add(('| master rows | {0} |' -f $total))
$out.Add(('| rows with Arabic | {0} |' -f $translated))
$out.Add(('| copy-class rows left English-filled | {0} |' -f $copyClass))
$out.Add(('| translated or copy-class | {0} of {1} |' -f ($translated + $copyClass), $total))
$out.Add(('| translatable rows | {0} |' -f $translatable))
$out.Add(('| coverage of translatable rows | {0} of {1} ({2}%) |' -f $translated, $translatable, $pctTr))
$out.Add(('| coverage of all rows | {0} of {1} ({2}%) |' -f $translated, $total, $pctAll))
$out.Add(('| rows needing review (not copy-class, still empty) | {0} |' -f $unexpected))
$out.Add('')
$out.Add('## Copy-class reasons')
$out.Add('')
$out.Add('| reason | rows |')
$out.Add('| --- | --- |')
foreach ($k in ($reasons.Keys | Sort-Object { -$reasons[$_] })) { $out.Add(('| {0} | {1} |' -f $k, $reasons[$k])) }
$out.Add('')
$out.Add('## Per scope')
$out.Add('')
$out.Add('| scope | rows | Arabic | copy-class | coverage of translatable |')
$out.Add('| --- | --- | --- | --- | --- |')
foreach ($s in ($scopes.Keys | Sort-Object)) {
    $d = $scopes[$s]; $tr = $d.total - $d.copy
    $p = 0.0; if ($tr -gt 0) { $p = [Math]::Round(100.0 * $d.ar / $tr, 2) }
    $out.Add(('| {0} | {1} | {2} | {3} | {4} of {5} ({6}%) |' -f $s, $d.total, $d.ar, $d.copy, $d.ar, $tr, $p))
}
$out.Add('')
$out.Add('## Per category')
$out.Add('')
$out.Add('| category | rows | Arabic | copy-class | coverage of translatable |')
$out.Add('| --- | --- | --- | --- | --- |')
foreach ($c in ($cats.Keys | Sort-Object)) {
    $d = $cats[$c]; $tr = $d.total - $d.copy
    $p = 0.0; if ($tr -gt 0) { $p = [Math]::Round(100.0 * $d.ar / $tr, 2) }
    $out.Add(('| {0} | {1} | {2} | {3} | {4} of {5} ({6}%) |' -f $c, $d.total, $d.ar, $d.copy, $d.ar, $tr, $p))
}
if ($unexpected -gt 0) {
    $out.Add('')
    $out.Add('## Rows needing review')
    $out.Add('')
    foreach ($r in $unexpectedRows) { $out.Add('- ' + $r) }
}
[IO.File]::WriteAllLines($outPath, $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('[coverage] rows {0} | arabic {1} | copy-class {2} | translated-or-copy {3} of {0} | translatable {4} | coverage {5}% of translatable | review-needed {6}' -f $total, $translated, $copyClass, ($translated + $copyClass), $translatable, $pctTr, $unexpected)
Write-Output ('[coverage] written: ' + $outPath)
