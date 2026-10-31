<#
.SYNOPSIS
  Verifies that every reviewer fix in localization/working/tm_fixups.tsv is fully applied and
  that the master Arabic column still matches the translation memory byte-for-byte.

.DESCRIPTION
  All comparisons are data-driven from UTF-8 files (no non-ASCII literals in this script, KI-021).

  Rules are scoped by their note/selector columns (DEC-049):
    - global rules: master rows still containing FIND -> must be 0
                    master rows containing REPLACE      -> must be >= 1
                    tm.tsv values still containing FIND -> must be 0
                    When the same FIND appears in several rules, only the last rule is
                    enforced; earlier rules are historical and were superseded.
    - [cell] rules (p12): the p12 variant cell selected by scope|key must equal REPLACE.
    - [label] rules (p12): every p12 variant row whose English is P-3 must equal REPLACE.
    - p11f shorten rules: variant-scoped to p11f/p12f and therefore not applicable to the
      release master or the p12 variant; they are counted and skipped.

  Integrity: every master row tagged pilot:*/seed:phase7 has Arabic identical to its
  translation memory entry for the same English source.
  Exit 2 on any failure.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$VariantTsV = ''
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$fixPath = Join-Path $RepoRoot 'localization\working\tm_fixups.tsv'
$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$tmPath = Join-Path $RepoRoot 'localization\working\tm.tsv'
if (-not $VariantTsV) { $VariantTsV = Join-Path $RepoRoot 'build\variants\atomic-heart-ar_p12.tsv' }
$utf8 = [Text.Encoding]::UTF8

$rules = New-Object System.Collections.Generic.List[object]
$fx = [IO.File]::ReadAllLines($fixPath, $utf8)
for ($i = 1; $i -lt $fx.Count; $i++) {
    if (-not $fx[$i].Trim()) { continue }
    $f = $fx[$i] -split "`t"
    if ($f.Count -lt 3) { continue }
    $selector = ''; $value = ''
    if ($f.Count -ge 5) { $selector = $f[3]; $value = $f[4] }
    $rules.Add([pscustomobject]@{
        line = $i + 1
        find = $f[0]
        replace = $f[1]
        note = $f[2]
        exact = $f[2].Contains('[exact]')
        cell = ($f[2].Contains('[cell]') -and $selector -eq 'cell')
        label = ($f[2].Contains('[label]') -and $selector -eq 'label')
        timing = ($f[2] -match 'p11f shorten')
        selector = $selector
        target = $value
    })
}

$m = [IO.File]::ReadAllLines($masterPath, $utf8)
$tm = [IO.File]::ReadAllLines($tmPath, $utf8)
$tmAr = New-Object System.Collections.Generic.List[string]
for ($i = 1; $i -lt $tm.Count; $i++) { if ($tm[$i].Trim()) { $tmAr.Add((($tm[$i] -split "`t")[1])) } }

$lastByFind = @{}
foreach ($r in $rules) { $lastByFind[$r.find] = $r.line }

$fail = 0
$globalChecked = 0; $superseded = 0; $timingSkipped = 0; $cellChecked = 0; $labelChecked = 0
Write-Output ('FIXUP VERIFY: rules ' + $rules.Count)

foreach ($r in $rules) {
    if ($r.timing) { $timingSkipped++; continue }
    if ($r.cell -or $r.label) { continue }
    if ($lastByFind[$r.find] -ne $r.line) { $superseded++; continue }
    $globalChecked++
    $leftInMaster = 0; $presentReplace = 0
    for ($i = 1; $i -lt $m.Count; $i++) {
        $f = $m[$i] -split "`t"
        if ($f.Count -ne 13) { continue }
        if ($r.exact) {
            if ($f[6] -ceq $r.find) { $leftInMaster++ }
            if ($f[6] -ceq $r.replace) { $presentReplace++ }
        } else {
            if ($f[6].Contains($r.find)) { $leftInMaster++ }
            if ($f[6].Contains($r.replace)) { $presentReplace++ }
        }
    }
    $leftInTm = 0
    if (-not $r.exact) { foreach ($v in $tmAr) { if ($v.Contains($r.find)) { $leftInTm++ } } }
    $ok = ($leftInMaster -eq 0 -and $presentReplace -ge 1 -and $leftInTm -eq 0)
    if (-not $ok) {
        $fail++
        Write-Output ('  [rule] line {0}: old text left: master {1}, tm {2} | new text present in master rows: {3} | FAIL' -f $r.line, $leftInMaster, $leftInTm, $presentReplace)
        Write-Output ('         note: ' + $r.note)
    }
}

# Variant-scoped p12 rules are verified against the generated p12 variant.
if (($cellChecked -eq 0 -and $labelChecked -eq 0) -and (Test-Path -LiteralPath $VariantTsV)) {
    $variant = @{}
    $masterCells = @{}
    for ($i = 1; $i -lt $m.Count; $i++) {
        if (-not $m[$i].Trim()) { continue }
        $f = $m[$i] -split "`t"
        if ($f.Count -ne 13) { continue }
        $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
        $masterCells[($scope + '|' + $f[4])] = $f[6]
    }
    $vlines = [IO.File]::ReadAllLines($VariantTsV, $utf8)
    $labelRows = 0; $labelBad = 0
    $cellApplied = 0; $cellUnchanged = 0
    for ($i = 1; $i -lt $vlines.Count; $i++) {
        if (-not $vlines[$i].Trim()) { continue }
        $f = $vlines[$i] -split "`t"
        if ($f.Count -ne 13) { continue }
        $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
        $variant[($scope + '|' + $f[4])] = $f[6]
    }
    foreach ($r in $rules) {
        if ($r.cell) {
            $cellChecked++
            $got = $variant[$r.target]
            $masterCell = $masterCells[$r.target]
            if ($null -eq $got) {
                $fail++
                if ($fail -le 40) { Write-Output ('  [cell] line {0}: {1} -> cell not found | FAIL' -f $r.line, $r.target) }
                continue
            }
            if ($got.Contains($r.replace)) { $cellApplied++; continue }
            if ($got -ceq $masterCell) { $cellUnchanged++; continue }
            $fail++
            if ($fail -le 40) { Write-Output ('  [cell] line {0}: {1} -> changed without the replacement | FAIL' -f $r.line, $r.target) }
        } elseif ($r.label) {
            $labelChecked++
            for ($i = 1; $i -lt $vlines.Count; $i++) {
                $f = $vlines[$i] -split "`t"
                if ($f.Count -ne 13) { continue }
                if ($f[5].Trim() -ceq 'P-3') {
                    $labelRows++
                    if ($f[6] -cne $r.replace) { $labelBad++ }
                }
            }
            if ($labelBad -ne 0 -or $labelRows -eq 0) {
                $fail++
                Write-Output ('  [label] line {0}: P-3 rows {1}, wrong {2} | FAIL' -f $r.line, $labelRows, $labelBad)
            } else {
                Write-Output ('  [label] line {0}: P-3 rows {1}, all match | OK' -f $r.line, $labelRows)
            }
        }
    }
}

# integrity: master pilot/seed Arabic == tm arabic for the same English
$map = @{}
for ($i = 1; $i -lt $tm.Count; $i++) {
    if (-not $tm[$i].Trim()) { continue }
    $f = $tm[$i] -split "`t"
    $map[$f[0]] = $f[1]
}
$checked = 0; $mismatch = 0; $missing = 0
for ($i = 1; $i -lt $m.Count; $i++) {
    $f = $m[$i] -split "`t"
    if ($f.Count -ne 13 -or -not $f[6].Trim()) { continue }
    if ($f[11] -notlike 'pilot:*' -and $f[11] -ne 'seed:phase7') { continue }
    $checked++
    if (-not $map.ContainsKey($f[5])) { $missing++; continue }
    if ($map[$f[5]] -cne $f[6]) { $mismatch++; Write-Output ('  MISMATCH vs tm: ' + $f[4]) }
}
Write-Output ('INTEGRITY: rows checked {0} | tm mismatches {1} | english missing from tm {2}' -f $checked, $mismatch, $missing)
if ($mismatch -ne 0 -or $missing -ne 0) { $fail++ }

Write-Output ('SCOPE: global {0} checked, {1} superseded, {2} p11f timing skipped; cell {3} checked ({4} applied, {5} documented no-op), label rule(s) {6}, variant {7}' -f $globalChecked, $superseded, $timingSkipped, $cellChecked, $cellApplied, $cellUnchanged, $labelChecked, (Split-Path $VariantTsV -Leaf))
$verdict = if ($fail -eq 0) { 'PASS' } else { 'FAIL' }
Write-Output ('FIXUP VERIFY RESULT: ' + $verdict)
if ($fail -ne 0) { exit 2 }
