<#
.SYNOPSIS
  Dialogue program - Phase F (finalize): turn the raw count pass into
   1. reports/dialogue_inventory.md       (exact 100% TOTAL + per-scope tables + split rule)
   2. reports/dialogue_ru_only.md         (RU-only assets, same class as KI-010; excluded from TOTAL)
   3. reports/dialogue_inventory_raw/sources_st.tsv (ordered ASSET sources for the batch tool)

.DESCRIPTION
  Scope rules (DEC-017/DEC-019, evidence-based):
   - INCLUDE paths: Maps/Development/Dialogue_Test narrative trees (Narrative_LS,
     Localisation_LS, OpenWorldCorpses, Schebetars_Subs, Dialog_VDNH), /Narrative/,
     GooseRunner, /Radio/, and dialogue/Subs/Cutscene/Radio/Sentences/Hints-named
     StringTables or LevelSequences whose dump carries actual strings.
   - EXCLUDE: tips/input-tips/UI-text assets (GameTips belong to the UI program, not
     dialogue), NTD notes (StringDataBase / NTD_ notes tables), the dev leftover folder
     DONT_USE_TEST_DIALOG_FOR_LQA (folder name is explicit), anything with zero strings.
   - Per-culture duplicate trees (Localisation_LS/<lang>/...): collapse to ONE logical
     source per base name. Variant preference: English-prose-bearing variant first,
     then the single surviving variant.
   - String counting rule: DEC-019 prose filter (scripts/dialogue_strings_lib.ps1),
     the same function used by the batch tool.
   - RU-only: chosen variant has Cyrillic prose but Latin prose = 0 -> listed in
     reports/dialogue_ru_only.md, NOT counted in TOTAL and NOT batched.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
. (Join-Path $RepoRoot 'scripts\dialogue_strings_lib.ps1')

$tsvPath   = Join-Path $RepoRoot 'reports\dialogue_st_counts.tsv'
$invRawDir = Join-Path $RepoRoot 'reports\dialogue_inventory_raw'
$dumpDir   = Join-Path $RepoRoot 'localization\extracted\dialogue'
$ruOut     = Join-Path $RepoRoot 'reports\dialogue_ru_only.md'
$invOut    = Join-Path $RepoRoot 'reports\dialogue_inventory.md'
$stOut     = Join-Path $invRawDir 'sources_st.tsv'

$inc = 'Dialogue_Test/(Narrative_LS|Localisation_LS|OpenWorldCorpses|Schebetars_Subs|Dialog_)|/Narrative/|GooseRunner|/Radio/|Sentences|_Hints|Gossip'
$incDialogName = 'Dialog|Dialogue|Cutscene|CutScene|_Sub\.|_Subs|/Subs|NarrSubs|Subtitles'
$exc = 'Tips|InputTips|GameTips|StringDataBase|/NTD/|DONT_USE_TEST_DIALOG_FOR_LQA|/Developers/|Zametki|LoreText|ItemText|TerminalText|/Tests/|_Debug'

$raw = [IO.File]::ReadAllLines($tsvPath, [Text.Encoding]::UTF8)
$assets = New-Object System.Collections.Generic.List[object]
for ($i = 1; $i -lt $raw.Count; $i++) {
    if (-not $raw[$i].Trim()) { continue }
    $p = $raw[$i] -split "`t"
    $assets.Add([pscustomobject]@{
        pak = $p[0]; path = $p[1]; cls = $p[2]; utf = [int]$p[3]; ascii = [int]$p[4]
        latin = [int]$p[5]; cyr = [int]$p[6]; dump = $p[7]
    })
}
Write-Output ("[counts] rows: " + $assets.Count)

$inScope = $assets | Where-Object {
    ($_.path -match $inc -or $_.path -match $incDialogName) -and $_.path -notmatch $exc -and ($_.utf -ge 1 -or $_.ascii -ge 1)
}
Write-Output ("[scope] in-scope assets with strings: " + @($inScope).Count)

# --- apply the DEC-019 prose filter per asset (cached)
$proseCache = @{}
function Get-Prose([object]$a) {
    if ($proseCache.ContainsKey($a.dump)) { return $proseCache[$a.dump] }
    $dp = Join-Path $dumpDir $a.dump
    $res = @()
    if (Test-Path $dp) { $res = @(Get-DialogueStrings ([IO.File]::ReadAllText($dp, [Text.Encoding]::UTF8))) }
    $proseCache[$a.dump] = $res
    return $res
}

# --- base-name collapse
function Get-BaseName([string]$path) {
    $n = [IO.Path]::GetFileNameWithoutExtension($path)
    $prev = $null
    while ($prev -ne $n) {
        $prev = $n
        $n = $n -replace '(_RU(_(US|BR|PL|ES|FR|CN|JP|CZ|TR|DE|UK|IT|KO|TH|AR))?|_Rus|_EN|_En|_ENX|_EN_|_test|test)+$', ''
        $n = $n -replace '_$', ''
    }
    return $n
}
$groups = @{}
foreach ($a in $inScope) {
    $b = Get-BaseName $a.path
    if (-not $groups.ContainsKey($b)) { $groups[$b] = New-Object System.Collections.Generic.List[object] }
    $groups[$b].Add($a)
}
Write-Output ("[collapse] logical sources: " + $groups.Count)

function Get-Kind([object]$a) { if ($a.cls -eq 'LS') { return 'LS' } elseif ($a.cls -eq 'ST') { return 'ST' } else { return 'OTHER' } }
function Get-Dlc([string]$path) {
    if ($path -match '/DLC4/') { return 'DLC4' }
    if ($path -match '/DLC3/') { return 'DLC3' }
    if ($path -match '/DLC2/') { return 'DLC2' }
    if ($path -match 'Content/DLC[0-9]*/|_dlc1') { return 'DLC1' }
    return 'base'
}
function Get-ScopeClass([string]$path) {
    if ($path -match 'Cutscene|CutScene') { return 'Cutscene' }
    if ($path -match '_Sub|Subs|Subtitles|NarrSubs') { return 'Subtitles' }
    return 'Dialogue'
}
function Test-HasLatinProse($strings) { foreach ($s in $strings) { if ($s -match '[A-Za-z]{3,}') { return $true } }; return $false }
function Test-HasCyrProse($strings) { foreach ($s in $strings) { if ($s -cmatch '[\u0410-\u044F]{3,}') { return $true } }; return $false }

$chosen = New-Object System.Collections.Generic.List[object]
$ruOnly = New-Object System.Collections.Generic.List[object]
foreach ($b in $groups.Keys) {
    $pick = $null
    foreach ($a in $groups[$b]) { $pr = Get-Prose $a; if ($pr.Count -gt 0 -and (Test-HasLatinProse $pr)) { $pick = $a; break } }
    if (-not $pick) {
        foreach ($a in $groups[$b]) { $pr = Get-Prose $a; if ($pr.Count -gt 0) { $pick = $a; break } }
    }
    if (-not $pick) { continue }
    $pp = Get-Prose $pick
    $rec = [pscustomobject]@{ a = $pick; strings = $pp; latin = (Test-HasLatinProse $pp); cyr = (Test-HasCyrProse $pp) }
    if (-not $rec.latin -and $rec.cyr) { $ruOnly.Add($rec) } elseif ($rec.latin) { $chosen.Add($rec) }
}
Write-Output ("[collapse] EN-source sources: " + $chosen.Count + " | RU-only sources: " + $ruOnly.Count)

# --- order: base/DLC then kind then path; ord continues after 14
$ord = 14
$tab = [char]9
$stLines = New-Object System.Collections.Generic.List[string]
$stLines.Add(('order' + $tab + 'kind' + $tab + 'source' + $tab + 'container' + $tab + 'dlc' + $tab + 'scopeClass' + $tab + 'count' + $tab + 'pak' + $tab + 'basekind'))
$dlcRank = @{ base = 0; DLC1 = 1; DLC2 = 2; DLC3 = 3; DLC4 = 4 }
$ordered = $chosen | ForEach-Object {
    [pscustomobject]@{ rec = $_; dlc = (Get-Dlc $_.a.path); sc = (Get-ScopeClass $_.a.path); bk = (Get-Kind $_.a) }
} | Sort-Object { $dlcRank[$_.dlc] }, { $_.bk }, { $_.rec.a.path }
$enTotal = 0
foreach ($o in $ordered) {
    $ord++
    $cnt = $o.rec.strings.Count
    $enTotal += $cnt
    $stLines.Add([string]$ord + $tab + 'ASSET' + $tab + $o.rec.a.path + $tab + $o.rec.a.pak + $tab + $o.dlc + $tab + $o.sc + $tab + [string]$cnt + $tab + $o.rec.a.pak + $tab + $o.bk)
}
[IO.File]::WriteAllLines($stOut, $stLines, (New-Object Text.UTF8Encoding($false)))
Write-Output ("[total] EN-source asset strings (DEC-019 prose): " + $enTotal)

# --- ru-only report
$ruStrings = 0
$ruLines = New-Object System.Collections.Generic.List[string]
$ruLines.Add('# RU-only dialogue/cutscene strings (no English source anywhere)')
$ruLines.Add('')
$ruLines.Add('Same class as KI-010: these sources carry Russian text only; per the standing')
$ruLines.Add('rule they are listed separately and are NEVER placed into the English source')
$ruLines.Add('column of the master TSV, and they do not count into the localizable TOTAL.')
$ruLines.Add('')
$ruLines.Add('| asset | strings | sample |')
$ruLines.Add('|---|---|---|')
foreach ($r in ($ruOnly | Sort-Object { $_.a.path })) {
    $ruStrings += $r.strings.Count
    $sample = (($r.strings | Select-Object -First 1) -replace '\|', '/')
    if ($sample -and $sample.Length -gt 90) { $sample = $sample.Substring(0, 90) + '...' }
    $ruLines.Add('| ' + $r.a.path + ' | ' + $r.strings.Count + ' | ' + $sample + ' |')
}
$ruLines.Add('')
$ruLines.Add(('**RU-only assets: {0}, strings: {1}**' -f $ruOnly.Count, $ruStrings))
[IO.File]::WriteAllLines($ruOut, $ruLines, (New-Object Text.UTF8Encoding($false)))
Write-Output ("[ru-only] assets " + $ruOnly.Count + ", strings " + $ruStrings)

# --- inventory report
$locresTotal = 10394
$total = $locresTotal + $enTotal
$inv = New-Object System.Collections.Generic.List[string]
$inv.Add('# Dialogue and cutscene text inventory (exact)')
$inv.Add('')
$inv.Add(('Generated: {0}; count pass: reports/dialogue_st_counts.tsv ({1} candidate assets scanned, DEC-018 parallel pass).' -f (Get-Date).ToString('yyyy-MM-dd HH:mm'), $assets.Count))
$inv.Add('')
$inv.Add('## 100% TOTAL')
$inv.Add('')
$inv.Add(('**TOTAL = {0} dialogue/cutscene strings with an English source.**' -f $total))
$inv.Add('')
$inv.Add(('- locres sources (en-US locres, already in the master TSV): {0}' -f $locresTotal))
$inv.Add(('- non-locres cooked sources (unique EN-source assets after collapse, DEC-019 prose filter): {0}' -f $enTotal))
$inv.Add(('- RU-only strings (reported separately in reports/dialogue_ru_only.md, NOT in TOTAL): {0}' -f $ruStrings))
$inv.Add('')
$inv.Add('Every percentage in the batch reports is quoted as "N of TOTAL (X%)".')
$inv.Add('')
$inv.Add('## Locres sources (14 scopes, exact; calibrated: Academy_Dialogues fresh export = 282 rows = master rows)')
$inv.Add('')
$inv.Add('| # | scope | group | class | strings |')
$inv.Add('|---|---|---|---|---|')
$lr = @(
    @('Academy_Dialogues','base','Dialogue',282), @('Chelomey_Dialogues','base','Dialogue',1204),
    @('ChelomeyFinal_Dialogues','base','Dialogue',214), @('CUTSCENES','base','Cutscene',840),
    @('DIALOGUES FOR LQA','base','Dialogue',746), @('OpenWorldVDNKh_Dialogues','base','Dialogue',443),
    @('Pavlov_Dialogues','base','Dialogue',520), @('Polygon_Dialogues','base','Dialogue',199),
    @('Schebetar_Subs','base','Subtitles',361), @('Theatre_Dialogues','base','Dialogue',629),
    @('Vavilov_Dialogues','base','Dialogue',2427), @('VDNKh_Dialogues','base','Dialogue',1292),
    @('Cutscenes_dlc1','DLC1','Cutscene',421), @('Locations_dlc2','DLC2','Dialogue',816)
)
$i = 0
foreach ($e in $lr) { $i++; $inv.Add(('| {0} | {1} | {2} | {3} | {4} |' -f $i, $e[0], $e[1], $e[2], $e[3])) }
$inv.Add('')
$inv.Add('## Non-locres cooked sources (per kind and DLC)')
$inv.Add('')
$inv.Add('| kind | base | DLC1 | DLC2 | DLC3 | DLC4 | strings |')
$inv.Add('|---|---|---|---|---|---|---|')
$gstat = @{}
foreach ($o in $ordered) {
    $k = $o.bk
    if (-not $gstat.ContainsKey($k)) { $gstat[$k] = @{ base = 0; DLC1 = 0; DLC2 = 0; DLC3 = 0; DLC4 = 0; n = 0 } }
    $gstat[$k][$o.dlc] += $o.rec.strings.Count
    $gstat[$k].n++
}
foreach ($k in ($gstat.Keys | Sort-Object)) {
    $g = $gstat[$k]
    $inv.Add(('| {0} | {1} | {2} | {3} | {4} | {5} | {6} |' -f $k, $g['base'], $g['DLC1'], $g['DLC2'], $g['DLC3'], $g['DLC4'], ($g['base'] + $g['DLC1'] + $g['DLC2'] + $g['DLC3'] + $g['DLC4'])))
}
$inv.Add('')
$inv.Add(('Non-locres EN-source assets: {0}; RU-only assets: {1} (reports/dialogue_ru_only.md).' -f $chosen.Count, $ruOnly.Count))
$inv.Add(('String rule: DEC-019 prose filter (scripts/dialogue_strings_lib.ps1), identical in the inventory and the batch tool.'))
$inv.Add('')
$inv.Add('## Batch split rule (DEC-017)')
$inv.Add('')
$inv.Add('Cumulative batches 25/50/75/100% of TOTAL. Order: locres scopes (base alphabetical,')
$inv.Add('then DLC1, DLC2), then cooked ASSET sources (DLC then kind then path). Batches cut at')
$inv.Add('cumulative string counts; batch N includes everything before it.')
$inv.Add('')
$b1 = [Math]::Round($total * 0.25, [MidpointRounding]::AwayFromZero)
$b2 = [Math]::Round($total * 0.5, [MidpointRounding]::AwayFromZero)
$b3 = [Math]::Round($total * 0.75, [MidpointRounding]::AwayFromZero)
$inv.Add(('Batch cutoffs: batch 1 = {0}; batch 2 = {1}; batch 3 = {2}; batch 4 = {3}.' -f $b1, $b2, $b3, $total))
[IO.File]::WriteAllLines($invOut, $inv, (New-Object Text.UTF8Encoding($false)))
Write-Output ("[inventory] TOTAL = " + $total + " (locres " + $locresTotal + " + assets " + $enTotal + "); written " + $invOut)
