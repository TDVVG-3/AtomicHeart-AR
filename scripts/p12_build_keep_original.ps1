$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$repo = 'C:\AtomicHeart-AR'
$masterPath = Join-Path $repo 'localization\master\atomic-heart-ar.tsv'
$keysPath = Join-Path $repo 'build\p4\item_name_keys.tsv'
$outPath = Join-Path $repo 'localization\working\keep_original.tsv'
$qPath = Join-Path $repo 'reports\keep_original_questions.md'
$utf8 = New-Object Text.UTF8Encoding($false)

# Master rows by line number.
$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$masterByLine = @{}
for ($i = 1; $i -lt $mlines.Count; $i++) {
    if (-not $mlines[$i].Trim()) { continue }
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $masterByLine[$i + 1] = $f
}

# Key-based exclusions (ASCII only; KI-021). These rows are not inventory/weapon
# item NAME rows, or their source cell is not a usable English item name.
$excludeKeys = @(
    '/E9269E5C43C7E0547510C2AF219A75B2',  # Extra Capacity Cartridges - character skill, DA_CassetteCapacity
    '/E6ECF9EC46E601E855388C9748089247',  # Cell Division - character skill, DA_ConsumableAfterHealRegen
    '/9541C5DD48051484015ECDA23731F438',  # COMMUNICATOR (DLC2) - source cell is Russian
    '/BAEB863F47A0F3CC4AD19488FB83C33C',  # KS-23 COLLIMATOR - source has Cyrillic K
    '/26AD73004FF45B5AFD4D8A9B8002F8FB'   # KS-23 THERMAL SCOPE - source has Cyrillic K
)

$seen = @{}
$rows = New-Object System.Collections.Generic.List[string]
$rows.Add("id`tscope`tkey`tenglish`treason")
$excluded = New-Object System.Collections.Generic.List[object]
$totalItemRows = 0
$itemLines = [IO.File]::ReadAllLines($keysPath, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $itemLines.Count; $i++) {
    if (-not $itemLines[$i].Trim()) { continue }
    $f = $itemLines[$i] -split "`t"
    if ($f.Count -lt 9) { continue }
    if ($f[8] -eq 'NOT-IN-MASTER') { continue }
    $line = [int]$f[3]
    if (-not $masterByLine.ContainsKey($line)) { continue }
    $m = $masterByLine[$line]
    $scope = ''; if ($m[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    if (-not $scope) { $scope = 'other' }
    $key = $m[4]
    $id = $m[0]
    $en = $m[5]
    $sig = $line.ToString() + "`t" + $scope + "`t" + $key
    if ($seen.ContainsKey($sig)) { continue }
    $seen[$sig] = 1
    $totalItemRows++
    if ($excludeKeys -contains $key) {
        $excluded.Add([pscustomobject]@{ Line = $line; Scope = $scope; Key = $key; English = $en; Arabic = $m[6]; Asset = $f[1]; Reason = 'not an inventory/weapon item NAME row, or source is not an English item name' })
        continue
    }
    $rows.Add($id + "`t" + $scope + "`t" + $key + "`t" + $en + "`tkeep original name")
}
[IO.File]::WriteAllLines($outPath, $rows, $utf8)

$q = New-Object System.Collections.Generic.List[string]
$q.Add('# Keep-original item-name questions')
$q.Add('')
$q.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')))
$q.Add('')
$q.Add('These rows were found in item-definition assets but are **not** changed to English by default.')
$q.Add('They are excluded from `localization/working/keep_original.tsv` and left exactly as they are in the master.')
$q.Add('')
$q.Add('## Excluded rows')
$q.Add('')
$q.Add('| master line | scope | key | source English | current Arabic | asset | why excluded |')
$q.Add('|---:|---|---|---|---|---|---|')
foreach ($e in $excluded) {
    $q.Add(('| {0} | {1} | `{2}` | {3} | {4} | `{5}` | {6} |' -f $e.Line, $e.Scope, $e.Key, $e.English, $e.Arabic, ($e.Asset -replace '^AtomicHeart/Content/', ''), $e.Reason))
}
$q.Add('')
$q.Add('## Reviewed and resolved as items/weapons')
$q.Add('')
$q.Add('The following short terms could look like abilities or locations. They were checked against the item asset path and are kept in English:')
$q.Add('')
$q.Add('- `JAB` - `DA_Item_Shprits` (syringe weapon)')
$q.Add('- `BINGUN` - `DA_Item_Bidonist` (weapon)')
$q.Add('- `CAROUSEL` - `DA_Item_Karusel` (weapon)')
$q.Add('- `ECHIDNA` - `DA_Item_Dikobraz` (weapon)')
$q.Add('- `PARAGRAPH` - `DA_Item_Abzac` (weapon)')
$q.Add('- `SINGER` - `DA_Item_Zinger` (weapon)')
$q.Add('- `ROOSTER` - `DA_Item_Petuh` (weapon)')
$q.Add('- `DYNAMO` - `DA_Consumable_energetic` (consumable)')
$q.Add('- `SPIRAL` - `DA_Item_Metal_Spiral` (metal resource)')
$q.Add('- `CHEMISTRY` - `DA_Item_Resources_Chemicals` (resource)')
$q.Add('- `VALVE` - `DA_item_Ventel` (quest item)')
$q.Add('- `ORB` - `DA_Item_PuzzleBall` (puzzle item)')
$q.Add('- `Launch module` - `DA_Consumable_Alenka` (quest consumable)')
$q.Add('- `Candle` - `DA_Item_PickupableBall` (DLC3 quest item)')
$q.Add('- `Keycard` - `DA_Item_UnderwaterBallon` (DLC3 quest item)')
$q.Add('- `Scuba gear` - `DA_Item_Scuba` (DLC3 equipment)')
$q.Add('- `Repair Module` - `DA_Item_ModuleForRepair` (DLC3 item)')
$q.Add('- `Thunderclap` - `DA_Item_Gromoverzhec` (DLC3 melee weapon)')
$q.Add('- `KM-4 Kuzmich` - `DA_Item_Kuzmich` (DLC3 ranged weapon)')
$q.Add('- `NECHAEV''S FAVORITE CANISTER` - `DA_Item_LimboPuzzle` (DLC2 quest item; the character name is part of the item name)')
$q.Add('- `DebugGun` / `DebugMelee` - `DA_Item_DebugGun` / `DA_Item_DebugMelee` (debug weapons; kept for completeness, not expected in normal play)')
$q.Add('')
$q.Add('## Open question')
$q.Add('')
$q.Add('`КОММУНИКАТОР` (Tech_dlc2) is the DLC2 audio-diary item. Its source cell is Russian, not English, so copying it would put Russian in the Arabic UI, and translating it would break the keep-original rule. It is left as the current Arabic `جهاز الاتصال`. If a reviewer wants this one unified with the base item `COMMUNICATOR`, add a copy-class row for it explicitly.')
$q.Add('')
$q.Add('`КS-23—COLLIMATOR` and `КS-23—THERMAL SCOPE` use a Cyrillic `К` in the source. They are weapon upgrades, but copying the mixed-script source would inject Cyrillic into the Arabic cell. They are left translated. If the Cyrillic is a source typo, the correct English form should be `KS-23—COLLIMATOR` / `KS-23—THERMAL SCOPE`; add them explicitly after review.')
[IO.File]::WriteAllLines($qPath, $q, $utf8)

Write-Output ('[keep-original] item NAME rows found: {0} | kept: {1} | excluded: {2} -> {3}' -f $totalItemRows, ($rows.Count - 1), $excluded.Count, $outPath)
Write-Output ('[keep-original] questions -> {0}' -f $qPath)
