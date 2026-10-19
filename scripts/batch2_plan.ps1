<#
.SYNOPSIS
  Batch-2 planner (cycle 012, DEC-029). Produces a translation work order that follows
  GAME PROGRESSION instead of the batch-1 tier order.

.DESCRIPTION
  Within the prologue area the order comes from the data, not from guesswork: each
  base-game dialogue scope has a subtitle DataTable dump (DT_Subtitles_*). The FText
  keys appear in that dump in the table's own row order, which is the order the game
  plays them in, so the dump supplies a real per-scope playback index.

  Work order:
    1. Chelomey_Dialogues   - prologue: boat narration, arrival, first quests
    2. CUTSCENES            - story cutscene subtitles
    3..10 remaining base-game dialogue/subtitle scopes
    11..   mail, signage, LQA mirror, then DLC1..DLC4
    last   UI scopes (NewP5, PearTerminals, Misc) - kept for later, per requirement

  Outputs (localization/working/batch2/):
    plan.tsv         seq, scope, key, category, english   (every untranslated row, ordered)
    plan_unique.tsv  id, english, occurrences, scope, key, category, en_len  (stable b####)
    plan_summary.txt per-scope counts
  ASCII-only script; all text stays in the master (already UTF-8).
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$dumpDir    = Join-Path $RepoRoot 'localization\extracted\dialogue'
$work       = Join-Path $RepoRoot 'localization\working\batch2'
$utf8       = New-Object Text.UTF8Encoding($false)
if (-not (Test-Path $work)) { New-Item -ItemType Directory -Force -Path $work | Out-Null }

# scope -> subtitle dump (playback order source)
$dumpMap = [ordered]@{
    'Chelomey_Dialogues'      = 'pakchunk0-WindowsNoEditor__DT_Subtitles_Chelomey.txt'
    'CUTSCENES'               = 'pakchunk0-WindowsNoEditor__DT_Subtitles_Cutscenes.txt'
    'VDNKh_Dialogues'         = 'pakchunk0-WindowsNoEditor__DT_Subtitles_VDNH.txt'
    'Vavilov_Dialogues'       = 'pakchunk0-WindowsNoEditor__DT_Subtitles_Vavilov.txt'
    'Pavlov_Dialogues'        = 'pakchunk0-WindowsNoEditor__DT_Subtitles_Pavlov.txt'
    'Polygon_Dialogues'       = 'pakchunk0-WindowsNoEditor__DT_Subtitles_Polygons.txt'
    'Theatre_Dialogues'       = 'pakchunk0-WindowsNoEditor__DT_Subtitles_Theatre.txt'
    'OpenWorldVDNKh_Dialogues'= 'pakchunk0-WindowsNoEditor__DT_Subtitles_OpenWorld.txt'
    'ChelomeyFinal_Dialogues' = 'pakchunk0-WindowsNoEditor__DT_Subtitles_ChelomeyFinal.txt'
    'Academy_Dialogues'       = 'pakchunk0-WindowsNoEditor__DT_Subtitles_Academy.txt'
    'Schebetar_Subs'          = 'pakchunk0-WindowsNoEditor__DT_Subtitles_Schebetars.txt'
    'Cutscenes_dlc1'          = 'pakchunk13-WindowsNoEditor__DT_Subtitles_DLC01_Cutscenes.txt'
    'Locations_dlc2'          = 'pakchunk14-WindowsNoEditor__DT_Subtitles_DLC02_GooseRunner.txt'
    'Chelomey_dlc3'           = 'pakchunk15-WindowsNoEditor__DT_Subtitles_DLC03_Chelomey.txt'
    'Triton_dlc3'             = 'pakchunk15-WindowsNoEditor__DT_Subtitles_DLC03_Triton.txt'
    'Sakhalin_dlc3'           = 'pakchunk15-WindowsNoEditor__DT_Subtitles_DLC03_Sakhalin.txt'
    'CrystalComplex_dlc4'     = 'pakchunk16-WindowsNoEditor__DT_Subtitles_DLC4_CrystalComplex.txt'
    'Phasatron_dlc4'          = 'pakchunk16-WindowsNoEditor__DT_Subtitles_DLC4_Phasatron.txt'
    'WavePlatform_dlc4'       = 'pakchunk16-WindowsNoEditor__DT_Subtitles_DLC4_WavePlatform.txt'
    'LebedevLab_dlc4'         = 'pakchunk16-WindowsNoEditor__DT_Subtitles_DLC4_LebedevLab.txt'
}

# narrative scope order (rank 0 = first)
$order = @(
    'Chelomey_Dialogues',
    'CUTSCENES',
    'VDNKh_Dialogues',
    'Vavilov_Dialogues',
    'Pavlov_Dialogues',
    'Polygon_Dialogues',
    'Theatre_Dialogues',
    'OpenWorldVDNKh_Dialogues',
    'ChelomeyFinal_Dialogues',
    'Academy_Dialogues',
    'Schebetar_Subs',
    'Mails_01',
    'NTD',
    'DIALOGUES FOR LQA',
    'Marshes_dlc1','Mendeleev_dlc1','Schebetars_dlc1','Cutscenes_dlc1',
    'Locations_dlc2','Mails_Shebetars_dlc2','Tech_dlc2',
    'Chelomey_dlc3','Sakhalin_dlc3','Triton_dlc3','Tech_dlc3','Mails_Shebetars_Tech_dlc3',
    'CrystalComplex_dlc4','LebedevLab_dlc4','Phasatron_dlc4','WavePlatform_dlc4','Tech_dlc4','Mails_Shebetars_dlc4',
    'PearTerminals','NewP5','Misc'
)
$rank = New-Object 'System.Collections.Generic.Dictionary[string,int]' ([StringComparer]::Ordinal)
for ($i = 0; $i -lt $order.Count; $i++) { if (-not $rank.ContainsKey($order[$i])) { $rank[$order[$i]] = $i } }

# playback index per scope, from the subtitle dumps
$play = New-Object 'System.Collections.Generic.Dictionary[string,object]' ([StringComparer]::Ordinal)
foreach ($sc in $dumpMap.Keys) {
    $p = Join-Path $dumpDir $dumpMap[$sc]
    if (-not (Test-Path $p)) { Write-Output ('[warn] dump missing for ' + $sc + ': ' + $dumpMap[$sc]); continue }
    $map = New-Object 'System.Collections.Generic.Dictionary[string,int]' ([StringComparer]::Ordinal)
    $n = 0
    foreach ($ln in [IO.File]::ReadAllLines($p, [Text.Encoding]::UTF8)) {
        foreach ($m in [regex]::Matches($ln, '[0-9A-F]{32}')) {
            $k = '/' + $m.Value
            if (-not $map.ContainsKey($k)) { $map[$k] = $n; $n++ }
        }
    }
    $play[$sc] = $map
    Write-Output ('[order] {0,-26} playback keys: {1}' -f $sc, $map.Count)
}

# master walk
$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$rows = New-Object System.Collections.Generic.List[object]
for ($i = 1; $i -lt $mlines.Count; $i++) {
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    if ($f[6].Trim()) { continue }          # already has Arabic
    $scope = 'other'
    if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    if (-not $f[5].Trim()) { continue }
    $r = 9999
    if ($rank.ContainsKey($scope)) { $r = $rank[$scope] }
    $pi = 999999
    if ($play.ContainsKey($scope)) { $m = $play[$scope]; if ($m.ContainsKey($f[4])) { $pi = $m[$f[4]] } }
    $rows.Add([pscustomobject]@{ rank = $r; play = $pi; line = $i + 1; scope = $scope; key = $f[4]; category = $f[9]; english = $f[5] })
}
$rows = @($rows | Sort-Object rank, play, line, key)
Write-Output ('[plan] untranslated rows in work order: {0}' -f $rows.Count)

# unique english in first-appearance order (ordinal, KI-023)
$seen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
$uniq = New-Object 'System.Collections.Generic.List[object]'
$idx  = New-Object 'System.Collections.Generic.Dictionary[string,int]' ([StringComparer]::Ordinal)
foreach ($r in $rows) {
    if ($seen.Contains($r.english)) { continue }
    [void]$seen.Add($r.english)
    $idx[$r.english] = $uniq.Count
    $uniq.Add([pscustomobject]@{ id = ('b{0:D4}' -f ($uniq.Count + 1)); english = $r.english; occurrences = 0; scope = $r.scope; key = $r.key; category = $r.category; en_len = $r.english.Length })
}
foreach ($r in $rows) { $uniq[$idx[$r.english]].occurrences++ }
Write-Output ('[plan] unique strings: {0}' -f $uniq.Count)

# outputs
$p1 = New-Object System.Collections.Generic.List[string]
$p1.Add(('seq' + "`t" + 'scope' + "`t" + 'key' + "`t" + 'category' + "`t" + 'play' + "`t" + 'english'))
for ($i = 0; $i -lt $rows.Count; $i++) {
    $r = $rows[$i]
    $p1.Add((($i + 1), $r.scope, $r.key, $r.category, $r.play, $r.english) -join "`t")
}
[IO.File]::WriteAllLines((Join-Path $work 'plan.tsv'), $p1, $utf8)

$p2 = New-Object System.Collections.Generic.List[string]
$p2.Add(('id' + "`t" + 'english' + "`t" + 'occurrences' + "`t" + 'scope' + "`t" + 'key' + "`t" + 'category' + "`t" + 'en_len'))
foreach ($u in $uniq) { $p2.Add(($u.id, $u.english, $u.occurrences, $u.scope, $u.key, $u.category, $u.en_len) -join "`t") }
[IO.File]::WriteAllLines((Join-Path $work 'plan_unique.tsv'), $p2, $utf8)

$p3 = New-Object System.Collections.Generic.List[string]
$p3.Add('scope`tuntranslated_rows')
$per = New-Object 'System.Collections.Generic.Dictionary[string,int]' ([StringComparer]::Ordinal)
foreach ($r in $rows) { if (-not $per.ContainsKey($r.scope)) { $per[$r.scope] = 0 }; $per[$r.scope]++ }
foreach ($k in ($per.Keys | Sort-Object { if ($rank.ContainsKey($_)) { $rank[$_] } else { 9999 } }, { $_ })) { $p3.Add(($k + "`t" + $per[$k])) }
[IO.File]::WriteAllLines((Join-Path $work 'plan_summary.txt'), $p3, $utf8)
Write-Output ('[plan] written: plan.tsv, plan_unique.tsv, plan_summary.txt')
foreach ($l in $p3) { Write-Output ('   ' + $l) }
