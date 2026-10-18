<#
.SYNOPSIS
  Pilot apply (DEC-023 step 5): fills the master Arabic column for the pilot rows
  (from localization/working/pilot_tm.tsv) plus the 25 phase-7 seed rows
  (from localization/working/phase7_seed.csv), sets Status=DRAFT, and writes the
  translation memory to localization/working/tm.tsv.

.DESCRIPTION
  Matching rule (row identity): (scope from File, Key, exact English). The English must
  match the selection's English exactly, so a row is never touched by accident.
  Idempotent: running twice produces the same master.
  Encoding: UTF-8, no BOM, for every file written.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$selPath    = Join-Path $RepoRoot 'reports\pilot_selection.tsv'
$tmPath     = Join-Path $RepoRoot 'localization\working\pilot_tm.tsv'
$seedPath   = Join-Path $RepoRoot 'localization\working\phase7_seed.csv'
$tmOut      = Join-Path $RepoRoot 'localization\working\tm.tsv'
$fixPath    = Join-Path $RepoRoot 'localization\working\glossary_fixups.tsv'
$utf8NoBom  = New-Object Text.UTF8Encoding($false)

# --- 0) glossary fixups (regex pattern -> replacement), read from a UTF-8 DATA file.
# PowerShell 5.1 parses .ps1 files as ANSI unless they carry a BOM, so Arabic must NEVER
# be written as a literal inside a script (KI-019b); it lives in data files only.
$fixups = New-Object System.Collections.Generic.List[object]
if (Test-Path $fixPath) {
    $fx = [IO.File]::ReadAllLines($fixPath, [Text.Encoding]::UTF8)
    for ($i = 1; $i -lt $fx.Count; $i++) {
        if (-not $fx[$i].Trim()) { continue }
        $p = $fx[$i] -split "`t"
        if ($p.Count -lt 2) { continue }
        $fixups.Add([pscustomobject]@{ pattern = $p[0]; replacement = $p[1] })
    }
}
Write-Output ('[fix] glossary fixup rules: {0}' -f $fixups.Count)

function Split-Tsv([string]$line) { return ,($line -split "`t") }

# --- 1) translation memory from the pilot sheet
$tmLines = [IO.File]::ReadAllLines($tmPath, [Text.Encoding]::UTF8)
$tm = @{}
$tmOrder = New-Object System.Collections.Generic.List[string]
$dupTm = New-Object System.Collections.Generic.List[string]
for ($i = 1; $i -lt $tmLines.Count; $i++) {
    if (-not $tmLines[$i].Trim()) { continue }
    $f = $tmLines[$i] -split "`t"
    if ($f.Count -lt 2) { throw ("pilot_tm.tsv row $($i+1) has $($f.Count) fields (expected >= 2)") }
    if ($tm.ContainsKey($f[0])) { $dupTm.Add($f[0]); continue }
    $tm[$f[0]] = $f[1]
    $tmOrder.Add($f[0])
}
Write-Output ('[tm] pilot entries: {0} (duplicate english rows skipped: {1})' -f $tm.Count, $dupTm.Count)

# --- 2) pilot selection rows to fill
$selLines = [IO.File]::ReadAllLines($selPath, [Text.Encoding]::UTF8)
$selKeys = New-Object 'System.Collections.Generic.HashSet[string]'   # scope\u0000key\u0000english
$selGroup = @{}
for ($i = 1; $i -lt $selLines.Count; $i++) {
    if (-not $selLines[$i].Trim()) { continue }
    $f = $selLines[$i] -split "`t"
    $id = ($f[2] + "`u{0000}" + $f[3] + "`u{0000}" + $f[7])
    [void]$selKeys.Add($id)
    $selGroup[$id] = $f[0]
}
Write-Output ('[sel] selection rows: {0}' -f $selKeys.Count)

# --- 3) seed rows
$seedLines = [IO.File]::ReadAllLines($seedPath, [Text.Encoding]::UTF8)
$seed = @{}
for ($i = 1; $i -lt $seedLines.Count; $i++) {
    if (-not $seedLines[$i].Trim()) { continue }
    $idx = $seedLines[$i].IndexOf(',')
    if ($idx -lt 1) { continue }
    $k = $seedLines[$i].Substring(0, $idx).Trim('"')
    $v = $seedLines[$i].Substring($idx + 1).Trim()
    if ($v.StartsWith('"') -and $v.EndsWith('"') -and $v.Length -ge 2) { $v = $v.Substring(1, $v.Length - 2) }
    $v = $v.Replace('""', '"')   # CSV-escaped quotes in the seed file (p2 defect, see KI-019)
    foreach ($fxr in $fixups) { $v = [regex]::Replace($v, $fxr.pattern, $fxr.replacement) }
    $seed[$k] = $v
}
Write-Output ('[seed] seed keys: {0}' -f $seed.Count)

# --- 4) master walk
$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$out = New-Object System.Collections.Generic.List[string]
$out.Add($mlines[0])
$nPilot = 0; $nSeed = 0; $nMissingTm = 0
$pilotCovered = New-Object 'System.Collections.Generic.HashSet[string]'
$seedCovered  = New-Object 'System.Collections.Generic.HashSet[string]'
for ($i = 1; $i -lt $mlines.Count; $i++) {
    if (-not $mlines[$i].Trim()) { $out.Add($mlines[$i]); continue }
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { $out.Add($mlines[$i]); continue }
    $file = $f[2]; $key = $f[4]; $en = $f[5]
    $scope = 'other'
    if ($file -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }

    $id = ($scope + "`u{0000}" + $key + "`u{0000}" + $en)
    if ($selKeys.Contains($id)) {
        if (-not $tm.ContainsKey($en)) { $nMissingTm++; $out.Add($mlines[$i]); continue }
        $f[6] = $tm[$en]
        $f[10] = 'DRAFT'
        $f[11] = 'pilot:' + $selGroup[$id]
        [void]$pilotCovered.Add($en)
        $nPilot++
        $out.Add(($f -join "`t"))
        continue
    }
    if ($scope -eq 'NewP5' -and $seed.ContainsKey($key)) {
        $f[6] = $seed[$key]
        $f[10] = 'DRAFT'
        $f[11] = 'seed:phase7'
        [void]$seedCovered.Add($key)
        $nSeed++
        $out.Add(($f -join "`t"))
        continue
    }
    $out.Add($mlines[$i])
}

[IO.File]::WriteAllLines($masterPath, $out, $utf8NoBom)

# --- 5) translation memory file (union of pilot + seed, english -> arabic)
$tmOutLines = New-Object System.Collections.Generic.List[string]
$tmOutLines.Add(('english' + "`t" + 'arabic' + "`t" + 'source'))
foreach ($en in $tmOrder) { $tmOutLines.Add(($en + "`t" + $tm[$en] + "`t" + 'pilot')) }
# seed english lookup from the master we just wrote
$written = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $written.Count; $i++) {
    $f = $written[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    if ($f[11] -eq 'seed:phase7' -and -not $tm.ContainsKey($f[5])) {
        $tmOutLines.Add(($f[5] + "`t" + $f[6] + "`t" + 'seed'))
    }
}
[IO.File]::WriteAllLines($tmOut, $tmOutLines, $utf8NoBom)

Write-Output ''
Write-Output ('[apply] pilot rows filled: {0}  (unique pilot strings covered: {1} of {2})' -f $nPilot, $pilotCovered.Count, $tm.Count)
Write-Output ('[apply] seed rows filled:  {0} of {1}' -f $nSeed, $seed.Count)
Write-Output ('[apply] selection rows with no TM entry: {0}' -f $nMissingTm)
$coveredTotal = @([IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8) | Where-Object { $f = $_ -split "`t"; $f.Count -eq 13 -and $f[6].Trim() }).Count
Write-Output ('[apply] master rows with Arabic now: {0}' -f $coveredTotal)
Write-Output ('[apply] master written: {0}' -f $masterPath)
Write-Output ('[apply] tm written:     {0} ({1} lines)' -f $tmOut, $tmOutLines.Count)
if ($nMissingTm -gt 0) { exit 2 }
