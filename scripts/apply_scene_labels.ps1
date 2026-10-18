<#
.SYNOPSIS
  Applies one dialogue scene plus the speaker-name labels it uses into the master
  (Cycle 011: D_0072_Sipuha_BringSoda, the Chelomey canal/boat scene).

.DESCRIPTION
  Two UTF-8 data inputs, both authored outside this script (KI-021: PowerShell 5.1
  parses .ps1 as ANSI, so no Arabic may live in a script):

    localization/working/scene_chelomey_soda_rows.tsv
        header: scope<TAB>key<TAB>english<TAB>arabic
        A row is applied only when scope AND key match AND the English cell is
        byte-identical to the file. Notes = -SceneNote, Status = DRAFT.

    localization/working/speaker_labels.tsv
        header: english<TAB>arabic<TAB>note
        Applied to EVERY master row whose English cell is byte-identical to the
        label English (speaker-name rows are duplicated per dialogue asset, so the
        same label text must resolve to the same Arabic everywhere). An existing
        non-empty different Arabic is a HARD ERROR (consistency rule), never an
        overwrite. Notes = the note column, Status = DRAFT.

  Nothing is written unless there is no error: a scene row that is missing, an
  English mismatch, a label conflict or a stray label aborts the run with exit 1.

  The union TM gets english -> arabic for every applied pair (existing different
  entries are reported as conflicts, never overwritten).

  ASCII-only script. Idempotent: a second run reports everything as already identical.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$SceneRows = 'localization\working\scene_chelomey_soda_rows.tsv',
    [string]$Labels = 'localization\working\speaker_labels.tsv',
    [string]$SceneNote = 'scene:chelomey-soda',
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$tmPath     = Join-Path $RepoRoot 'localization\working\tm.tsv'
$rowsPath   = Join-Path $RepoRoot $SceneRows
$labelPath  = Join-Path $RepoRoot $Labels
$utf8       = New-Object Text.UTF8Encoding($false)

# ---------- 1) scene rows ----------
$scene = New-Object 'System.Collections.Generic.Dictionary[string,object]' ([StringComparer]::Ordinal)
$sl = [IO.File]::ReadAllLines($rowsPath, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $sl.Count; $i++) {
    if (-not $sl[$i].Trim()) { continue }
    $f = $sl[$i] -split "`t"
    if ($f.Count -ne 4) { throw ("scene rows line $($i+1): $($f.Count) fields (expected 4)") }
    if ($f[1] -notmatch '^/') { throw ("scene rows line $($i+1): key is not a locres key: " + $f[1]) }
    if (-not $f[3].Trim()) { throw ("scene rows line $($i+1): empty Arabic for " + $f[1]) }
    if ($scene.ContainsKey($f[1])) { throw ('scene rows: duplicate key ' + $f[1]) }
    $scene[$f[1]] = [pscustomobject]@{ scope = $f[0]; key = $f[1]; english = $f[2]; arabic = $f[3] }
}
Write-Output ('[scene] authored rows: {0}' -f $scene.Count)

# ---------- 2) speaker labels ----------
$labelAr   = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::Ordinal)
$labelNote = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::Ordinal)
$ll = [IO.File]::ReadAllLines($labelPath, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $ll.Count; $i++) {
    if (-not $ll[$i].Trim()) { continue }
    $f = $ll[$i] -split "`t"
    if ($f.Count -ne 3) { throw ("labels line $($i+1): $($f.Count) fields (expected 3)") }
    if (-not $f[1].Trim()) { throw ("labels line $($i+1): empty Arabic for " + $f[0]) }
    $labelAr[$f[0]]   = $f[1]
    $labelNote[$f[0]] = $f[2]
}
Write-Output ('[labels] label texts: {0} ({1})' -f $labelAr.Count, (($labelAr.Keys) -join ', '))

# ---------- 3) master walk ----------
$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$out = New-Object System.Collections.Generic.List[string]
$out.Add($mlines[0])
$sceneApplied = 0; $sceneSame = 0
$labApplied = 0;   $labSame = 0
$foundLabels = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
$doneScene = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
$mismatch = New-Object System.Collections.Generic.List[string]
$conflict = New-Object System.Collections.Generic.List[string]
$tmPairs  = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::Ordinal)

for ($i = 1; $i -lt $mlines.Count; $i++) {
    if (-not $mlines[$i].Trim()) { $out.Add($mlines[$i]); continue }
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { $out.Add($mlines[$i]); continue }
    $scope = 'other'
    if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $changed = $false

    # 3a) scene row (scope + key + exact English)
    if ($scene.ContainsKey($f[4]) -and $f[4].Substring(0,1) -eq '/') {
        $r = $scene[$f[4]]
        if ($r.scope -ceq $scope) {
            if ($r.english -cne $f[5]) {
                $mismatch.Add(('{0} {1}: master English differs from the scene file' -f $scope, $f[4]))
            } else {
                [void]$doneScene.Add($scope + "`u{0000}" + $f[4])
                if ($f[6] -ceq $r.arabic) { $sceneSame++ } else { $sceneApplied++ }
                $f[6] = $r.arabic
                $f[10] = 'DRAFT'
                $f[11] = $SceneNote
                $changed = $true
                $tmPairs[$r.english] = $r.arabic
            }
        }
    }

    # 3b) speaker label (exact English, anywhere in the master)
    if ($labelAr.ContainsKey($f[5])) {
        $ar = $labelAr[$f[5]]
        if ($f[6].Trim() -and ($f[6] -cne $ar)) {
            $conflict.Add(('EN={0}: master has [{1}], speaker_labels.tsv wants [{2}] ({3})' -f $f[5], $f[6], $ar, $scope))
        } else {
            [void]$foundLabels.Add($f[5])
            if ($f[6] -ceq $ar) { $labSame++ } else { $labApplied++ }
            $f[6] = $ar
            $f[10] = 'DRAFT'
            $f[11] = $labelNote[$f[5]]
            $changed = $true
            $tmPairs[$f[5]] = $ar
        }
    }

    if ($changed) { $out.Add(($f -join "`t")) } else { $out.Add($mlines[$i]) }
}

foreach ($k in $scene.Keys) {
    $r = $scene[$k]
    if (-not $doneScene.Contains($r.scope + "`u{0000}" + $k)) { $mismatch.Add(('scene row not found in master: {0} {1}' -f $r.scope, $k)) }
}
foreach ($e in $labelAr.Keys) {
    if (-not $foundLabels.Contains($e)) { $conflict.Add(('label English not present in the master: ' + $e)) }
}

Write-Output ('[scene] rows applied: {0} | already identical: {1}' -f $sceneApplied, $sceneSame)
Write-Output ('[labels] rows applied: {0} | already identical: {1}' -f $labApplied, $labSame)
if ($mismatch.Count -gt 0) { Write-Output ('MISMATCHES ({0}):' -f $mismatch.Count); foreach ($x in $mismatch) { Write-Output ('   ' + $x) } }
if ($conflict.Count -gt 0) { Write-Output ('CONFLICTS ({0}):' -f $conflict.Count); foreach ($x in $conflict) { Write-Output ('   ' + $x) } }
if ($mismatch.Count -gt 0 -or $conflict.Count -gt 0) { Write-Output '[abort] nothing written'; exit 1 }

if ($DryRun) { Write-Output '[dryrun] master/TM not written'; exit 0 }

[IO.File]::WriteAllLines($masterPath, $out, $utf8)
Write-Output ('[master] written: {0}' -f $masterPath)

# ---------- 4) union TM ----------
$tmlines = [IO.File]::ReadAllLines($tmPath, [Text.Encoding]::UTF8)
$tmOut = New-Object System.Collections.Generic.List[string]
$tmOut.Add($tmlines[0])
$have = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::Ordinal)
for ($i = 1; $i -lt $tmlines.Count; $i++) {
    if (-not $tmlines[$i].Trim()) { continue }
    $tf = $tmlines[$i] -split "`t"
    if ($tf.Count -ge 2) { $have[$tf[0]] = $tf[1] }
    $tmOut.Add($tmlines[$i])
}
$tmAdded = 0; $tmSame = 0; $tmConf = 0
foreach ($e in $tmPairs.Keys) {
    if ($have.ContainsKey($e)) {
        if ($have[$e] -ceq $tmPairs[$e]) { $tmSame++ } else { $tmConf++; Write-Output ('   TM CONFLICT: ' + $e) }
    } else {
        $tmOut.Add($e + "`t" + $tmPairs[$e] + "`t" + 'scene-011')
        [void]$have.Add($e, $tmPairs[$e])
        $tmAdded++
    }
}
[IO.File]::WriteAllLines($tmPath, $tmOut, $utf8)
Write-Output ('[tm] entries {0} -> {1} | appended {2} | already identical {3} | conflicts {4}' -f ($tmlines.Count - 1), ($tmOut.Count - 1), $tmAdded, $tmSame, $tmConf)

# ---------- 5) totals ----------
$written = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$total = 0; $withAr = 0
for ($i = 1; $i -lt $written.Count; $i++) {
    $f = $written[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $total++
    if ($f[6].Trim()) { $withAr++ }
}
Write-Output ('[coverage] rows with Arabic: {0} of {1} ({2}%)' -f $withAr, $total, [Math]::Round(100.0 * $withAr / $total, 2))
