<#
.SYNOPSIS
  Scene apply (Cycle 009): fills the master Arabic column for the opening bridge/PA
  scene rows from two UTF-8 data files, sets Status=DRAFT, and refreshes the union
  translation memory.

.DESCRIPTION
  Row identity is (scope, key) AND the English must be byte-identical to the value in
  localization/working/scene_opening_rows.tsv, so a row can never be touched by accident.
  Every Arabic string lives in localization/working/scene_opening_ar.tsv (UTF-8 data);
  this script is pure ASCII (KI-021: PowerShell 5.1 parses .ps1 as ANSI without a BOM).

  Reads : localization/working/scene_opening_rows.tsv  (scope, key, english)
          localization/working/scene_opening_ar.tsv    (key, arabic)
  Writes: localization/master/atomic-heart-ar.tsv (Arabic, Status, Notes)
          localization/working/tm.tsv (union TM, appended english -> arabic)
  Idempotent: running twice produces the same master and the same TM.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$rowsPath   = Join-Path $RepoRoot 'localization\working\scene_opening_rows.tsv'
$arPath     = Join-Path $RepoRoot 'localization\working\scene_opening_ar.tsv'
$tmPath     = Join-Path $RepoRoot 'localization\working\tm.tsv'
$utf8NoBom  = New-Object Text.UTF8Encoding($false)
$note       = 'scene:bridge-opening'

# --- 1) authored Arabic (key -> arabic)
$arabic = @{}
$arLines = [IO.File]::ReadAllLines($arPath, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $arLines.Count; $i++) {
    if (-not $arLines[$i].Trim()) { continue }
    $f = $arLines[$i] -split "`t"
    if ($f.Count -lt 2) { throw ("scene_opening_ar.tsv row $($i+1): $($f.Count) fields (expected 2)") }
    $k = $f[0].Trim()
    if ($k -notmatch '^/') { throw ("scene_opening_ar.tsv row $($i+1): first field is not a locres key: $k") }
    if ($arabic.ContainsKey($k)) { throw ("scene_opening_ar.tsv: duplicate key $k") }
    if (-not $f[1].Trim()) { throw ("scene_opening_ar.tsv: empty Arabic for key $k") }
    $arabic[$k] = $f[1]
}
Write-Output ('[ar] authored rows: {0}' -f $arabic.Count)

# --- 2) scene row list (scope, key, english) - authoritative, generated from the master
$scene = New-Object System.Collections.Generic.List[object]
$rowLines = [IO.File]::ReadAllLines($rowsPath, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $rowLines.Count; $i++) {
    if (-not $rowLines[$i].Trim()) { continue }
    $f = $rowLines[$i] -split "`t"
    if ($f.Count -ne 3) { throw ("scene_opening_rows.tsv row $($i+1): $($f.Count) fields (expected 3)") }
    $scene.Add([pscustomobject]@{ scope = $f[0]; key = $f[1]; english = $f[2] })
}
Write-Output ('[rows] scene rows: {0}' -f $scene.Count)

# --- 3) key sets must match exactly (no missing, no stray)
$missing = New-Object System.Collections.Generic.List[string]
$sceneKeys = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($r in $scene) {
    [void]$sceneKeys.Add($r.key)
    if (-not $arabic.ContainsKey($r.key)) { $missing.Add($r.key) }
}
$stray = New-Object System.Collections.Generic.List[string]
foreach ($k in $arabic.Keys) { if (-not $sceneKeys.Contains($k)) { $stray.Add($k) } }
if ($missing.Count -gt 0) { Write-Output ('MISSING Arabic for {0} key(s):' -f $missing.Count); foreach ($k in $missing) { Write-Output ('   ' + $k) } }
if ($stray.Count -gt 0) { Write-Output ('STRAY keys (not in scene rows): {0}' -f $stray.Count); foreach ($k in $stray) { Write-Output ('   ' + $k) } }
if ($missing.Count -gt 0 -or $stray.Count -gt 0) { throw 'scene/arabic key sets do not match' }

# --- 4) master walk: apply by (scope, key) with exact English check
$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$out = New-Object System.Collections.Generic.List[string]
$out.Add($mlines[0])
$applied = New-Object System.Collections.Generic.List[object]
$already = 0; $mismatch = 0; $notfound = 0
$done = New-Object 'System.Collections.Generic.HashSet[string]'
for ($i = 1; $i -lt $mlines.Count; $i++) {
    if (-not $mlines[$i].Trim()) { $out.Add($mlines[$i]); continue }
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { $out.Add($mlines[$i]); continue }
    $scope = 'other'
    if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $id = $scope + "`u{0000}" + $f[4]
    $hit = $null
    foreach ($r in $scene) { if ($r.key -eq $f[4] -and $r.scope -eq $scope) { $hit = $r; break } }
    if (-not $hit) { $out.Add($mlines[$i]); continue }
    [void]$done.Add($id)
    if ($hit.english -cne $f[5]) {
        $mismatch++
        Write-Output ('   ENGLISH MISMATCH ' + $scope + ' ' + $f[4])
        $out.Add($mlines[$i]); continue
    }
    $ar = $arabic[$f[4]]
    if ($f[6] -ceq $ar) { $already++ }
    $f[6] = $ar
    $f[10] = 'DRAFT'
    $f[11] = $note
    $applied.Add([pscustomobject]@{ scope = $scope; key = $f[4] })
    $out.Add(($f -join "`t"))
}
foreach ($r in $scene) {
    $id = $r.scope + "`u{0000}" + $r.key
    if (-not $done.Contains($id)) { $notfound++; Write-Output ('   NOT FOUND in master: ' + $r.scope + ' ' + $r.key) }
}
if ($mismatch -gt 0 -or $notfound -gt 0) { throw ('aborting: english mismatches ' + $mismatch + ', rows not found ' + $notfound) }
[IO.File]::WriteAllLines($masterPath, $out, $utf8NoBom)
Write-Output ('[apply] master rows updated: {0} (already identical before this run: {1})' -f $applied.Count, $already)

# --- 5) union translation memory: append english -> arabic for scene rows
$tmlines = [IO.File]::ReadAllLines($tmPath, [Text.Encoding]::UTF8)
$tmOut = New-Object System.Collections.Generic.List[string]
$tmOut.Add($tmlines[0])
$existing = New-Object 'System.Collections.Generic.HashSet[string]'
for ($i = 1; $i -lt $tmlines.Count; $i++) {
    if (-not $tmlines[$i].Trim()) { continue }
    $tf = $tmlines[$i] -split "`t"
    if ($tf.Count -ge 1) { [void]$existing.Add($tf[0]) }
    $tmOut.Add($tmlines[$i])
}
$added = 0
foreach ($r in $scene) {
    if ($existing.Contains($r.english)) { continue }
    $tmOut.Add($r.english + "`t" + $arabic[$r.key] + "`t" + 'scene')
    [void]$existing.Add($r.english)
    $added++
}
[IO.File]::WriteAllLines($tmPath, $tmOut, $utf8NoBom)
Write-Output ('[tm] entries before: {0} | appended: {1} | entries now: {2}' -f ($tmlines.Count - 1), $added, ($tmOut.Count - 1))

# --- 6) totals
$written = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$total = 0; $withAr = 0
for ($i = 1; $i -lt $written.Count; $i++) {
    $f = $written[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $total++
    if ($f[6].Trim()) { $withAr++ }
}
$pct = ('{0:N2}' -f (100.0 * $withAr / $total))
Write-Output ''
Write-Output ('[total] master rows {0} | rows with Arabic {1} ({2}%)' -f $total, $withAr, $pct)
Write-Output ('[total] coverage: {0} of {1} ({2}%)' -f $withAr, $total, $pct)
Write-Output ('[done] master: {0}' -f $masterPath)
Write-Output ('[done] tm:     {0}' -f $tmPath)
