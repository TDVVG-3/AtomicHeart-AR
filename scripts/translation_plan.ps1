<#
.SYNOPSIS
  Phase 0 (translation program): builds reports/translation_plan.md - the exact TOTAL,
  the priority order of work, and the cumulative 25/50/75/100% cutoffs.

.DESCRIPTION
  TOTAL (user definition, 2026-10-18): all master rows with a NON-EMPTY English source,
  excluding Status TECHNICAL and BLOCKED.  U = number of UNIQUE English strings (the
  translation-memory size: each unique English string is translated once).

  Priority order (user order, cycle 006 phase 0):
    1. system UI, menus, HUD, tutorials, items, weapons, skills, objectives
    2. dialogue / subtitles / cutscenes
    3. lore, DLC, credits
  Tiers are assigned by the master Category column plus the scope (File) name:
    - any scope whose name carries a DLC marker (_dlcN or /DLCn) -> tier 3
    - else Category UI        -> tier 1
    - else Category Dialogue/Cutscene/Subtitles -> tier 2
    - else (Lore / Unknown / Misc base scopes)  -> tier 3
  Within a tier, scopes are ordered by tier then by descending row count, then by name
  (deterministic).  Batch count N covers the FIRST round(TOTAL*N/4) rows of that order.

  Output is a text report only; it never modifies the master.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$master = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$outPath = Join-Path $RepoRoot 'reports\translation_plan.md'

$lines = [IO.File]::ReadAllLines($master, [Text.Encoding]::UTF8)
$rows = New-Object System.Collections.Generic.List[object]
for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split "`t"
    if ($f.Count -lt 13) { throw ("row {0} has {1} fields" -f ($i + 1), $f.Count) }
    $file = $f[2]
    $scope = 'unknown'
    if ($file -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $rows.Add([pscustomobject]@{
        id     = $f[0]
        file   = $file
        scope  = $scope
        key    = $f[4]
        en     = $f[5]
        cat    = $f[9]
        status = $f[10]
    })
}

# --- TOTAL definition
$eligible = $rows | Where-Object { $_.en -and $_.en.Trim() -and $_.status -ne 'TECHNICAL' -and $_.status -ne 'BLOCKED' }
$TECH = @($rows | Where-Object { $_.status -eq 'TECHNICAL' }).Count
$BLK  = @($rows | Where-Object { $_.status -eq 'BLOCKED' }).Count
$uniqAll = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($r in $eligible) { [void]$uniqAll.Add($r.en) }
$TOTAL = @($eligible).Count
$U = $uniqAll.Count

# --- tier assignment
$tierName = @{ 1 = 'Tier 1 - system UI, menus, HUD, tutorials, items, weapons, skills, objectives'; 2 = 'Tier 2 - dialogue, subtitles, cutscenes'; 3 = 'Tier 3 - lore, DLC content, credits' }

$scopeStats = @{}
foreach ($r in $eligible) {
    if (-not $scopeStats.ContainsKey($r.scope)) {
        $scopeStats[$r.scope] = [pscustomobject]@{ scope = $r.scope; rows = 0; tier = 0; cats = @{} }
    }
    $scopeStats[$r.scope].rows++
    $c = $r.cat
    if (-not $scopeStats[$r.scope].cats.ContainsKey($c)) { $scopeStats[$r.scope].cats[$c] = 0 }
    $scopeStats[$r.scope].cats[$c]++
}
# --- explicit work order (user priority; deterministic, not size-based)
#   tier 1: system UI / menus / HUD / tutorials / items / weapons / skills / objectives
#   tier 2: dialogue / subtitles / cutscenes (base game)
#   tier 3: lore (base), then DLC 1..4, then credits
$order = @(
    @{ s = 'NewP5'; t = 1 }, @{ s = 'Misc'; t = 1 }, @{ s = 'PearTerminals'; t = 1 },
    @{ s = 'Academy_Dialogues'; t = 2 }, @{ s = 'Chelomey_Dialogues'; t = 2 }, @{ s = 'ChelomeyFinal_Dialogues'; t = 2 },
    @{ s = 'CUTSCENES'; t = 2 }, @{ s = 'DIALOGUES FOR LQA'; t = 2 }, @{ s = 'OpenWorldVDNKh_Dialogues'; t = 2 },
    @{ s = 'Pavlov_Dialogues'; t = 2 }, @{ s = 'Polygon_Dialogues'; t = 2 }, @{ s = 'Schebetar_Subs'; t = 2 },
    @{ s = 'Theatre_Dialogues'; t = 2 }, @{ s = 'Vavilov_Dialogues'; t = 2 }, @{ s = 'VDNKh_Dialogues'; t = 2 },
    @{ s = 'NTD'; t = 3 }, @{ s = 'Mails_01'; t = 3 },
    @{ s = 'Cutscenes_dlc1'; t = 3 }, @{ s = 'Marshes_dlc1'; t = 3 }, @{ s = 'Mendeleev_dlc1'; t = 3 }, @{ s = 'Schebetars_dlc1'; t = 3 },
    @{ s = 'Locations_dlc2'; t = 3 }, @{ s = 'Mails_Shebetars_dlc2'; t = 3 }, @{ s = 'Tech_dlc2'; t = 3 },
    @{ s = 'Chelomey_dlc3'; t = 3 }, @{ s = 'Mails_Shebetars_Tech_dlc3'; t = 3 }, @{ s = 'Sakhalin_dlc3'; t = 3 },
    @{ s = 'Tech_dlc3'; t = 3 }, @{ s = 'Triton_dlc3'; t = 3 },
    @{ s = 'CrystalComplex_dlc4'; t = 3 }, @{ s = 'LebedevLab_dlc4'; t = 3 }, @{ s = 'Mails_Shebetars_dlc4'; t = 3 },
    @{ s = 'Phasatron_dlc4'; t = 3 }, @{ s = 'Tech_dlc4'; t = 3 }, @{ s = 'WavePlatform_dlc4'; t = 3 }
)
$tierOf = @{}
foreach ($o in $order) { if ($tierOf.ContainsKey($o.s)) { throw ("scope listed twice: {0}" -f $o.s) }; $tierOf[$o.s] = $o.t }
$missing = @($scopeStats.Keys | Where-Object { -not $tierOf.ContainsKey($_) })
if ($missing.Count -gt 0) { throw ("scopes missing from the work order: " + ($missing -join ', ')) }

foreach ($k in $scopeStats.Keys) { $scopeStats[$k].tier = $tierOf[$k] }

$ordered = New-Object System.Collections.Generic.List[object]
foreach ($o in $order) {
    if (-not $scopeStats.ContainsKey($o.s)) { continue }   # scope has no eligible rows
    $ordered.Add($scopeStats[$o.s])
}

# --- cumulative table
$cumRows = 0
$seen = New-Object 'System.Collections.Generic.HashSet[string]'
$scopeTable = New-Object System.Collections.Generic.List[string]
$order = 0
$cut = @{}
foreach ($s in $ordered) {
    $order++
    $s | Add-Member -NotePropertyName order -NotePropertyValue $order
    $s | Add-Member -NotePropertyName cum -NotePropertyValue ($cumRows + $s.rows)
    $cumRows += $s.rows
    foreach ($r in ($eligible | Where-Object { $_.scope -eq $s.scope })) { [void]$seen.Add($r.en) }
    $s | Add-Member -NotePropertyName cumU -NotePropertyValue $seen.Count
    $catStr = (($s.cats.GetEnumerator() | Sort-Object { -$_.Value } | ForEach-Object { $_.Key + '=' + $_.Value }) -join ' ')
    $scopeLine = '| {0} | {1} | {2} | {3} | {4} | {5} | {6} |' -f @($s.order, $s.tier, $s.scope, $s.rows, $s.cum, $s.cumU, $catStr)
    $scopeTable.Add($scopeLine)
}
if ($cumRows -ne $TOTAL) { throw ("scope rows {0} != TOTAL {1}" -f $cumRows, $TOTAL) }

for ($n = 1; $n -le 4; $n++) {
    $mark = [int][Math]::Round($TOTAL * $n / 4, [MidpointRounding]::AwayFromZero)
    # cumulative unique + scope reached at this row cutoff
    $cr = 0; $cu = 0; $reached = ''
    $seen2 = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($s in $ordered) {
        $scopeRows = @($eligible | Where-Object { $_.scope -eq $s.scope })
        foreach ($r in $scopeRows) {
            if ($cr -ge $mark) { break }
            $cr++
            [void]$seen2.Add($r.en)
            $reached = $s.scope
        }
        if ($cr -ge $mark) { break }
    }
    $cu = $seen2.Count
    $cut[$n] = [pscustomobject]@{ pct = ($n * 25); rows = $mark; cumU = $cu; reachedScope = $reached }
}

$t = [char]9
$L = New-Object System.Collections.Generic.List[string]
$L.Add('# Translation plan - Arabic (4 cumulative batches)')
$L.Add('')
$L.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$L.Add('')
$L.Add('## TOTAL (the 100%)')
$L.Add('')
$L.Add(('- TOTAL = **{0} rows** (master rows with a non-empty English source, excluding Status TECHNICAL/BLOCKED).' -f $TOTAL))
$L.Add(('- U = **{0} unique English strings** (translation memory: each unique English string is translated once and reused only when the context matches).' -f $U))
$L.Add(('- Excluded: Status TECHNICAL = {0} rows, Status BLOCKED = {1} rows (both zero today).' -f $TECH, $BLK))
$L.Add(('- Master rows read: {0}.  Rows that repeat an English string: {1} (translation reuse, not new translation work).' -f $rows.Count, ($TOTAL - $U)))
$L.Add('')
$L.Add('## Priority order and cutoffs')
$L.Add('')
$L.Add('Batches are CUMULATIVE: batch N covers the first `round(TOTAL*N/4)` rows of the order below.')
$L.Add('')
$L.Add('| batch | % | cumulative row cutoff | cumulative unique strings | last scope touched |')
$L.Add('|---|---|---|---|---|')
for ($n = 1; $n -le 4; $n++) {
    $c = $cut[$n]
    $L.Add(('| {0} | {1}% | {2} of {3} | {4} | {5} |' -f $n, $c.pct, $c.rows, $TOTAL, $c.cumU, $c.reachedScope))
}
$L.Add('')
$t1 = 0; $t2 = 0; $t3 = 0
foreach ($s in $ordered) { if ($s.tier -eq 1) { $t1 += $s.rows } elseif ($s.tier -eq 2) { $t2 += $s.rows } else { $t3 += $s.rows } }
$L.Add('## Tiers')
$L.Add('')
$L.Add('| tier | description | rows | share |')
$L.Add('|---|---|---|---|')
$L.Add(('| 1 | system UI, menus, HUD, tutorials, items, weapons, skills, objectives | {0} | {1}% |' -f $t1, [Math]::Round($t1 / $TOTAL * 100, 1)))
$L.Add(('| 2 | dialogue, subtitles, cutscenes | {0} | {1}% |' -f $t2, [Math]::Round($t2 / $TOTAL * 100, 1)))
$L.Add(('| 3 | lore, DLC content, credits | {0} | {1}% |' -f $t3, [Math]::Round($t3 / $TOTAL * 100, 1)))
$L.Add('')
$L.Add('## Ordered scope list (the exact work order)')
$L.Add('')
$L.Add('| # | tier | scope | rows | cumulative rows | cumulative unique | categories |')
$L.Add('|---|---|---|---|---|---|---|')
foreach ($ln in $scopeTable) { $L.Add($ln) }
$L.Add('')
$L.Add('## Batch boundary notes')
$L.Add('')
$L.Add('The cutoffs do NOT align with scope boundaries; a scope can be split across two')
$L.Add('batches. The rule is: rows are taken in the order above until the cumulative count')
$L.Add('reaches the cutoff. A scope is "delivered" when its last row is inside a batch.')
$L.Add('')
$L.Add('Rules that apply to every batch (see DEC-023):')
$L.Add('- translate each UNIQUE English string once; reuse across rows only when the context matches;')
$L.Add('- Arabic column filled, Status set to DRAFT, never overwrite a reviewed row;')
$L.Add('- placeholders/rich-text tags/escapes preserved exactly;')
$L.Add('- glossary terms transliterated/translated/preserved exactly as in glossary/glossary.tsv;')
$L.Add('- validation via scripts/validate_translation.py (placeholders, tags, UTF-8, empty Arabic, untranslated English, glossary, length).')
$L.Add('')
[IO.File]::WriteAllLines($outPath, $L, (New-Object Text.UTF8Encoding($false)))

Write-Output ('[plan] TOTAL {0} rows / U {1} unique' -f $TOTAL, $U)
for ($n = 1; $n -le 4; $n++) { $c = $cut[$n]; Write-Output ('  batch {0} ({1}%): rows {2} | unique {3} | last scope {4}' -f $n, $c.pct, $c.rows, $c.cumU, $c.reachedScope) }
Write-Output ('[plan] written {0}' -f $outPath)
