$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$repo = 'C:\AtomicHeart-AR'
$masterPath = Join-Path $repo 'localization\master\atomic-heart-ar.tsv'
$koPath = Join-Path $repo 'localization\working\keep_original.tsv'
$outPath = Join-Path $repo 'build\p4\item_name_occurrences.tsv'
$utf8 = New-Object Text.UTF8Encoding($false)

# Common-noun / ability / location names. They stay English as item NAME rows, but
# replacing them inside prose would change ordinary words. Default: leave prose alone.
$ambiguous = @(
    'NEPTUNE','FOX','ROOSTER','KEY','CHEMISTRY','CORN','RADIO','VALVE',
    'SURGEON','SINGER','JAB','PARAGRAPH','CAROUSEL','ECHIDNA','GREASER',
    'LUMBERJACK','CRICKET','SNOWBALL','SPIRAL','HAMMER','AXE','BOBBIN','COIN',
    'SWEDE','CANDLE','CLAIRE''S HEAD','CLAIRE''S LEFT ARM','CLAIRE''S LEFT LEG',
    'CLAIRE''S RIGHT ARM','TERESHKOVA''S HAND','VIKTOR''S HEAD','CONTAINER WITH THE HEAD'
)
$amb = @{}
foreach ($a in $ambiguous) { $amb[$a.ToUpperInvariant()] = 1 }

# Names that are safe and useful to replace inside prose. Generic weapon-type
# nouns (PISTOL, SHOTGUN, MACHINE GUN, ...) and technical upgrade names are left
# translated in sentences; their NAME rows are still English in the UI.
$whitelist = @(
    'NEUROPOLYMER','SECATEUR','SECATEUR AMMO','VODKA','ELECTRO','FAT BOY',
    'FAT BOY ROCKETS','FAT BOY AMMO','Klusha','KALASH','KALASH ROUNDS',
    'KS-23','PM','PM AMMO','PASHTET','ZVEZDOCHKA','RAILGUN','DOMINATOR',
    'Thunderclap','DYNAMO','LOCKPICK','SMALL CALIBER AMMO','CONDENSED MILK',
    'BIOMATERIALS','SYNTHETIC MATERIAL','CIGARETTES','YELLOW ACTIVATION CARD',
    'BLUE ACTIVATION CARD','ALGAE WORKSHOP CANISTER','HOT WORKSHOP CANISTER',
    'Launch module','Scuba gear','Klondike','Muffin','Karamel Candy','Kholodok',
    'Fudge','Eskimo','Ladyfinger','Funnel Cake','BINGUN','NEUROMED CAPSULE',
    'ADRENALINE CAPSULE','METAL PARTS','MICROELECTRONICS','SUPERCONDUCTOR',
    'PLASTIC PIPE','ENERGY MODULE','NEUROMODULE','BLUE KEY CARD','KEY DISK',
    'CAR KEY','ANCHOVY','CIGARETTES'
)
$white = @{}
foreach ($w in $whitelist) { $white[$w.ToUpperInvariant()] = 1 }

$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$byPair = @{}
for ($i = 1; $i -lt $mlines.Count; $i++) {
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $scope = 'other'
    if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $sig = $scope + '|' + $f[4]
    if (-not $byPair.ContainsKey($sig)) { $byPair[$sig] = New-Object System.Collections.Generic.List[object] }
    $byPair[$sig].Add([pscustomobject]@{ line = $i + 1; scope = $scope; key = $f[4]; en = $f[5]; ar = $f[6] })
}
$ko = [IO.File]::ReadAllLines($koPath, [Text.Encoding]::UTF8)
$itemRows = @{}
$names = New-Object System.Collections.Generic.List[object]
$seenName = @{}
for ($i = 1; $i -lt $ko.Count; $i++) {
    $f = $ko[$i] -split "`t"
    if ($f.Count -lt 5) { continue }
    $scope = $f[1]; $key = $f[2]; $en = $f[3]
    $sig = $scope + '|' + $key
    if (-not $byPair.ContainsKey($sig)) { continue }
    foreach ($r in $byPair[$sig]) {
        $itemRows[($r.line.ToString())] = 1
        $ar = $r.ar.Trim()
        if (-not $ar) { continue }
        if ($amb.ContainsKey($en.ToUpperInvariant())) { continue }
        if ($seenName.ContainsKey($ar + '|' + $en)) { continue }
        $seenName[$ar + '|' + $en] = 1
        $names.Add([pscustomobject]@{ ar = $ar; en = $en })
    }
}
Write-Host ('[occurrences] safe item names with Arabic: ' + $names.Count)

$arabicClass = '[\u0621-\u064A\u064B-\u0652\u0670\u0640]'
$prepared = New-Object System.Collections.Generic.List[object]
foreach ($n in $names) {
    $v = New-Object System.Collections.Generic.List[string]
    $v.Add($n.ar)
    $base = $n.ar
    $al = [string][char]0x0627 + [char]0x0644
    if ($base.StartsWith($al)) { $base = $base.Substring(2) }
    if ($base -ne $n.ar) { $v.Add($base) }
    else { $v.Add($al + $n.ar) }
    $variants = @($v | Select-Object -Unique | Sort-Object Length -Descending)
    $enEsc = [regex]::Escape($n.en)
    $enRx = [regex]::new('(?i)(?<![A-Za-z0-9])' + $enEsc + '(?![A-Za-z0-9])')
    foreach ($var in $variants) {
        $prepared.Add([pscustomobject]@{
            en = $n.en; arName = $n.ar; variant = $var; enRx = $enRx
            arRx = [regex]::new('(?<!' + $arabicClass + ')' + [regex]::Escape($var) + '(?!' + $arabicClass + ')')
        })
    }
}

$out = New-Object System.Collections.Generic.List[string]
$out.Add("line`tscope`tkey`tenglish_source`tarabic_cell`tarabic_name`tenglish_name`tmatched_variant`tstart`tlength")
$hits = 0
for ($i = 1; $i -lt $mlines.Count; $i++) {
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $line = $i + 1
    if ($itemRows.ContainsKey($line.ToString())) { continue }
    if ($f[4] -match 'Hint|Skill|NTD_StringTable|Stikers|_Name$') { continue }
    $ar = $f[6]
    if (-not $ar.Trim()) { continue }
    $en = $f[5]
    # Body text that mentions P-3 must not change; only the exact speaker label is filled.
    if ($en -match 'P-3') { continue }
    # Only prose/sentence rows. Short UI labels stay fully Arabic or are copied
    # whole in keep_original.tsv; replacing one word inside them reads badly.
    if ($en -notmatch '[.!?\u2026]') { continue }
    $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $cands = New-Object System.Collections.Generic.List[object]
    foreach ($p in $prepared) {
        if (-not $white.ContainsKey($p.en.ToUpperInvariant())) { continue }
        if (-not $p.enRx.IsMatch($en)) { continue }
        if ($p.en -eq 'Launch module' -and $en -match '(?i)neuropolymeric\s+launch\s+module') { continue }
        $m = $p.arRx.Match($ar)
        if (-not $m.Success) { continue }
        $cands.Add([pscustomobject]@{ name = $p; start = $m.Index; length = $m.Length; variant = $m.Value })
    }
    if ($cands.Count -eq 0) { continue }
    # Prefer the longest non-overlapping names in this cell.
    $accepted = New-Object System.Collections.Generic.List[object]
    foreach ($c in ($cands | Sort-Object @{Expression = 'length'; Descending = $true}, @{Expression = 'start'; Descending = $false})) {
        $overlap = $false
        foreach ($a in $accepted) {
            if ($c.start -lt ($a.start + $a.length) -and $a.start -lt ($c.start + $c.length)) { $overlap = $true; break }
        }
        if (-not $overlap) { $accepted.Add($c) }
    }
    foreach ($c in ($accepted | Sort-Object start)) {
        $out.Add($line.ToString() + "`t" + $scope + "`t" + $f[4] + "`t" + $en + "`t" + $ar + "`t" + $c.name.arName + "`t" + $c.name.en + "`t" + $c.variant + "`t" + $c.start + "`t" + $c.length)
        $hits++
    }
}
[IO.File]::WriteAllLines($outPath, $out, $utf8)
Write-Output ('[occurrences] rows: {0} -> {1}' -f $hits, $outPath)
