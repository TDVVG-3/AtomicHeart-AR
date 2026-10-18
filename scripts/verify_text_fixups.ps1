<#
.SYNOPSIS
  Verifies that every reviewer fix in localization/working/tm_fixups.tsv is fully applied and
  that the master Arabic column still matches the translation memory byte-for-byte.

.DESCRIPTION
  All comparisons are data-driven from UTF-8 files (no non-ASCII literals in this script, KI-021):
    1. for each rule: master rows still containing FIND  -> must be 0
                      master rows containing REPLACE      -> must be >= 1
                      tm.tsv values still containing FIND -> must be 0
    2. integrity: every master row tagged pilot:*/seed:phase7 has Arabic identical to its
       translation memory entry for the same English source.
  Exit 2 on any failure.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$fixPath = Join-Path $RepoRoot 'localization\working\tm_fixups.tsv'
$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$tmPath = Join-Path $RepoRoot 'localization\working\tm.tsv'
$utf8 = [Text.Encoding]::UTF8

$rules = New-Object System.Collections.Generic.List[object]
$fx = [IO.File]::ReadAllLines($fixPath, $utf8)
for ($i = 1; $i -lt $fx.Count; $i++) {
    if (-not $fx[$i].Trim()) { continue }
    $f = $fx[$i] -split "`t"
    if ($f.Count -lt 3) { continue }
    $rules.Add([pscustomobject]@{ find = $f[0]; replace = $f[1]; note = $f[2] })
}

$m = [IO.File]::ReadAllLines($masterPath, $utf8)
$tm = [IO.File]::ReadAllLines($tmPath, $utf8)
$tmAr = New-Object System.Collections.Generic.List[string]
for ($i = 1; $i -lt $tm.Count; $i++) { if ($tm[$i].Trim()) { $tmAr.Add((($tm[$i] -split "`t")[1])) } }

$fail = 0
Write-Output ('FIXUP VERIFY: rules ' + $rules.Count)
foreach ($r in $rules) {
    $leftInMaster = 0; $presentReplace = 0
    for ($i = 1; $i -lt $m.Count; $i++) {
        $f = $m[$i] -split "`t"
        if ($f.Count -ne 13) { continue }
        if ($f[6].Contains($r.find)) { $leftInMaster++ }
        if ($f[6].Contains($r.replace)) { $presentReplace++ }
    }
    $leftInTm = 0
    foreach ($v in $tmAr) { if ($v.Contains($r.find)) { $leftInTm++ } }
    $ok = ($leftInMaster -eq 0 -and $presentReplace -ge 1 -and $leftInTm -eq 0)
    if (-not $ok) { $fail++ }
    Write-Output ('  [rule] old text left: master {0}, tm {1} | new text present in master rows: {2} | {3}' -f $leftInMaster, $leftInTm, $presentReplace, $(if ($ok) { 'OK' } else { 'FAIL' }))
    Write-Output ('         note: ' + $r.note)
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

$verdict = if ($fail -eq 0) { 'PASS' } else { 'FAIL' }
Write-Output ('FIXUP VERIFY RESULT: ' + $verdict)
if ($fail -ne 0) { exit 2 }
