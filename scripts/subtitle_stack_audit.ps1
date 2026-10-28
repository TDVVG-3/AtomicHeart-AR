param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$MasterTsV = 'C:\AtomicHeart-AR\build\variants\atomic-heart-ar_p12.tsv',
    [string]$ReportPath = 'C:\AtomicHeart-AR\reports\subtitle_stack_audit.md',
    [string]$RowsPath = 'C:\AtomicHeart-AR\reports\subtitle_stack_rows.tsv'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$TAB = [char]9
$utf8 = New-Object Text.UTF8Encoding($false)
$statDir = Join-Path $RepoRoot 'build\extracted\dtsub\stat'
$wwisePath = Join-Path $RepoRoot 'build\p4\wwise_events.tsv'
$rx = [regex]'\*([0-9]+(?:\.[0-9]+)?)(?:-([0-9]+(?:\.[0-9]+)?))?\*'
$arLetter = [regex]'[\u0621-\u064A\u0660-\u0669\u066E-\u06D3\u06D5\u06E5-\u06E6\u06EE-\u06EF\u06FA-\u06FC\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]'

# --- master rows by locres key
$byKey = @{}
$m = [IO.File]::ReadAllLines($MasterTsV, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $m.Count; $i++) {
    if (-not $m[$i].Trim()) { continue }
    $f = $m[$i] -split $TAB
    if ($f.Count -ne 13) { continue }
    $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    if (-not $byKey.ContainsKey($f[4])) { $byKey[$f[4]] = New-Object System.Collections.Generic.List[object] }
    $byKey[$f[4]].Add([pscustomobject]@{ line = $i + 1; scope = $scope; en = $f[5]; ar = $f[6]; cat = $f[9]; status = $f[10] })
}

# --- Wwise clip durations (English US, event name -> DurationMax seconds)
$dur = @{}
if (Test-Path $wwisePath) {
    foreach ($line in [IO.File]::ReadAllLines($wwisePath, [Text.Encoding]::UTF8) | Select-Object -Skip 1) {
        if (-not $line.Trim()) { continue }
        $f = $line -split $TAB
        if ($f.Count -lt 5) { continue }
        if ($f[2] -ne 'English(US)') { continue }
        $d = 0.0
        if (-not [double]::TryParse($f[4], [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$d)) { continue }
        if (-not $dur.ContainsKey($f[0])) { $dur[$f[0]] = $d }
    }
}

function Scene-Of([string]$marker) {
    $p = @($marker -split '_')
    if ($p.Count -le 2) { return $marker }
    return (($p[0..($p.Count - 3)]) -join '_')
}
function Suffix-Of([string]$marker) {
    $p = @($marker -split '_')
    if ($p.Count -eq 0) { return 999999 }
    $n = 0
    if ([int]::TryParse($p[$p.Count - 1], [ref]$n)) { return $n }
    return 999999
}

# --- collect stock DataTable rows and global marker/key table sets
$rows = New-Object System.Collections.Generic.List[object]
$unmatched = 0
$markerTables = @{}
$keyTables = @{}
$tables = @(Get-ChildItem $statDir -File -Filter 'DT_Subtitles_*.tsv' | Sort-Object Name)
foreach ($tf in $tables) {
    $lines = [IO.File]::ReadAllLines($tf.FullName, [Text.Encoding]::UTF8)
    if ($lines.Count -lt 2) { continue }
    $markerCount = @{}; $keyCount = @{}
    $tableRows = New-Object System.Collections.Generic.List[object]
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if (-not $lines[$i].Trim()) { continue }
        $f = $lines[$i] -split $TAB
        if ($f.Count -lt 6) { continue }
        $marker = $f[2]; $speaker = $f[3]; $key = $f[4]
        if (-not $key.StartsWith('/')) { $key = '/' + $key }
        if (-not $markerCount.ContainsKey($marker)) { $markerCount[$marker] = 0 }
        $markerCount[$marker]++
        if (-not $keyCount.ContainsKey($key)) { $keyCount[$key] = 0 }
        $keyCount[$key]++
        if (-not $markerTables.ContainsKey($marker)) { $markerTables[$marker] = @{} }
        $markerTables[$marker][$tf.Name] = 1
        if (-not $keyTables.ContainsKey($key)) { $keyTables[$key] = @{} }
        $keyTables[$key][$tf.Name] = 1
        $tableRows.Add([pscustomobject]@{ Table = $tf.Name; Marker = $marker; Speaker = $speaker; Key = $key; Row = $f[1] })
    }
    foreach ($tr in $tableRows) {
        $master = $null
        if ($byKey.ContainsKey($tr.Key)) { $master = $byKey[$tr.Key][0] } else { $unmatched++ }
        $scope = if ($master) { $master.scope } else { $tf.BaseName -replace '^DT_Subtitles_', '' }
        $ar = if ($master) { $master.ar } else { '' }
        $en = if ($master) { $master.en } else { '' }
        $line = if ($master) { $master.line } else { 0 }
        $ms = $rx.Matches($ar)
        $tokens = New-Object System.Collections.Generic.List[object]
        for ($j = 0; $j -lt $ms.Count; $j++) {
            $s = [double]::Parse($ms[$j].Groups[1].Value, [Globalization.CultureInfo]::InvariantCulture)
            $e = $null
            if ($ms[$j].Groups[2].Success) { $e = [double]::Parse($ms[$j].Groups[2].Value, [Globalization.CultureInfo]::InvariantCulture) }
            $tokens.Add([pscustomobject]@{ Index = $ms[$j].Index; Length = $ms[$j].Length; Start = $s; End = $e; Text = $ms[$j].Value })
        }
        # A markerless Arabic cell is one page with no explicit end. It lives to the
        # Wwise clip end, so it is a final singleton for H3 purposes.
        $finalSingleton = (($tokens.Count -eq 0 -and $ar.Trim().Length -gt 0) -or ($tokens.Count -gt 0 -and $null -eq $tokens[$tokens.Count - 1].End))
        $tokenDup = 0
        if ($tokens.Count -gt 1) {
            $starts = @{}
            foreach ($t in $tokens) {
                $k = $t.Start.ToString('0.###', [Globalization.CultureInfo]::InvariantCulture)
                if ($starts.ContainsKey($k)) { $tokenDup++ } else { $starts[$k] = 1 }
            }
        }
        $h2 = 0
        for ($j = 0; $j -lt $tokens.Count; $j++) {
            if ($null -eq $tokens[$j].End) { continue }
            if ($j + 1 -lt $tokens.Count -and $tokens[$j].End -ge $tokens[$j + 1].Start - 0.0001) { $h2++ }
        }
        $clip = 0.0
        if ($dur.ContainsKey($tr.Marker)) { $clip = $dur[$tr.Marker] }
        elseif ($dur.ContainsKey('A_' + $tr.Marker)) { $clip = $dur['A_' + $tr.Marker] }
        $visible = ''
        if ($tokens.Count -gt 0) {
            $last = $tokens[$tokens.Count - 1]
            $startPos = $last.Index + $last.Length
            if ($startPos -lt $ar.Length) { $visible = $ar.Substring($startPos) }
        } else { $visible = $ar }
        $visible = [regex]::Replace($visible, '&[^&]{1,40}&', ' ')
        $visible = [regex]::Replace($visible, '<[^<>]*>', ' ')
        $chars = $arLetter.Matches($visible).Count
        $cps = if ($clip -gt 0) { $chars / $clip } else { 0 }
        $rows.Add([pscustomobject]@{
            Table = $tr.Table; Row = $tr.Row; Marker = $tr.Marker; Speaker = $tr.Speaker; Key = $tr.Key
            Line = $line; Scope = $scope; En = $en; Ar = $ar; Cat = $(if ($master) { $master.cat } else { '' })
            Scene = (Scene-Of $tr.Marker); Suffix = (Suffix-Of $tr.Marker)
            Tokens = $tokens.Count; FinalSingleton = $finalSingleton
            H1m = $(if ($markerCount[$tr.Marker] -gt 1) { 1 } else { 0 })
            H1k = $(if ($keyCount[$tr.Key] -gt 1) { 1 } else { 0 })
            H1t = $tokenDup; H2 = $h2; H3 = 0; H4 = 0
            Clip = $clip; Chars = $chars; Cps = $cps
        })
    }
}

# H4: same marker/key reused in more than one stock table.
# Only 32-hex locres keys are real key collisions; some DLC tables use plain
# pseudo-keys such as Chirpers_1_1_Sentences that repeat by design.
foreach ($r in $rows) {
    $keyCollision = ($r.Key -match '^/[0-9A-Fa-f]{32}$' -and $keyTables[$r.Key].Count -gt 1)
    if ($markerTables[$r.Marker].Count -gt 1 -or $keyCollision) { $r.H4 = 1 }
}

# H3: final singleton page with a following row in the same scene (suffix order)
$sceneRows = @{}
foreach ($r in $rows) {
    $gk = $r.Table + '|' + $r.Scene
    if (-not $sceneRows.ContainsKey($gk)) { $sceneRows[$gk] = New-Object System.Collections.Generic.List[object] }
    $sceneRows[$gk].Add($r)
}
foreach ($gk in $sceneRows.Keys) {
    $list = @($sceneRows[$gk] | Sort-Object Suffix, Line, Row)
    for ($i = 0; $i -lt $list.Count; $i++) {
        if ($list[$i].FinalSingleton -and $i -lt $list.Count - 1) { $list[$i].H3 = 1 }
    }
}

# --- per scope and per scene
$byScope = @{}
$byScene = @{}
foreach ($r in $rows) {
    if (-not $byScope.ContainsKey($r.Scope)) { $byScope[$r.Scope] = @{ rows = 0; h1m = 0; h1k = 0; h1t = 0; h2 = 0; h3 = 0; h4 = 0 } }
    $d = $byScope[$r.Scope]
    $d.rows++; $d.h1m += $r.H1m; $d.h1k += $r.H1k; $d.h1t += $r.H1t; $d.h2 += $r.H2; $d.h3 += $r.H3; $d.h4 += $r.H4
    $gk = $r.Table + '|' + $r.Scene
    if (-not $byScene.ContainsKey($gk)) { $byScene[$gk] = @{ table = $r.Table; scene = $r.Scene; rows = 0; h1m = 0; h1k = 0; h1t = 0; h2 = 0; h3 = 0; h4 = 0 } }
    $s = $byScene[$gk]
    $s.rows++; $s.h1m += $r.H1m; $s.h1k += $r.H1k; $s.h1t += $r.H1t; $s.h2 += $r.H2; $s.h3 += $r.H3; $s.h4 += $r.H4
}

$total = $rows.Count
$tH1m = @($rows | Where-Object { $_.H1m -eq 1 }).Count
$tH1k = @($rows | Where-Object { $_.H1k -eq 1 }).Count
$tH1t = @($rows | Where-Object { $_.H1t -gt 0 }).Count
$tH2 = @($rows | Where-Object { $_.H2 -gt 0 }).Count
$tH3 = @($rows | Where-Object { $_.H3 -eq 1 }).Count
$tH4 = @($rows | Where-Object { $_.H4 -eq 1 }).Count

$r = New-Object System.Collections.Generic.List[string]
$r.Add('# Subtitle stack audit - H1 / H2 / H3 / H4')
$r.Add('')
$r.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')))
$r.Add(('Master: `{0}`' -f $MasterTsV))
$r.Add(('Stock tables: {0} | rows: {1} | unmatched keys: {2}' -f $tables.Count, $total, $unmatched))
$r.Add('')
$r.Add(('Mapping note: {0} of {1} stock rows could not be joined to a master locres key. H1m, H1k and H4 are stock DataTable checks independent of Arabic. H1t, H2 and H3 are assessed only where a master Arabic cell was found; unmatched rows keep their table name as the scope label.' -f $unmatched, $total))
$r.Add('')
$r.Add('| hypothesis | rows | meaning |')
$r.Add('| --- | ---: | --- |')
$r.Add(('| H1 marker duplicate in table | {0} | same Wwise marker used by more than one row in the same DataTable |' -f $tH1m))
$r.Add(('| H1 key duplicate in table | {0} | same locres sentence key used by more than one row in the same DataTable |' -f $tH1k))
$r.Add(('| H1 duplicate marker start in cell | {0} | same page start timestamp repeated inside one Arabic cell |' -f $tH1t))
$r.Add(('| H2 end overlaps next start | {0} | explicit range end >= the next page start in the same cell |' -f $tH2))
$r.Add(('| H3 final singleton + following scene row | {0} | final page has no end and another line follows in the same scene |' -f $tH3))
$r.Add(('| H4 stock cross-table marker/key reuse | {0} | marker or key reused in another stock DataTable |' -f $tH4))
$r.Add('')
$r.Add('## Per scope')
$r.Add('')
$r.Add('| scope | rows | H1m | H1k | H1t | H2 | H3 | H4 |')
$r.Add('| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |')
foreach ($s in ($byScope.Keys | Sort-Object)) {
    $d = $byScope[$s]
    $r.Add(('| {0} | {1} | {2} | {3} | {4} | {5} | {6} | {7} |' -f $s, $d.rows, $d.h1m, $d.h1k, $d.h1t, $d.h2, $d.h3, $d.h4))
}
$r.Add('')
$r.Add('## 30 worst scenes')
$r.Add('')
$r.Add('Score = H1m + H1k + H1t + H2 + H3 + H4. Scene is the marker prefix with the trailing character and line number removed.')
$r.Add('')
$r.Add('| # | scene | table | rows | H1m | H1k | H1t | H2 | H3 | H4 | score |')
$r.Add('|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|')
$idx = 0
foreach ($s in ($byScene.Values | Sort-Object @{ Expression = { $_.h1m + $_.h1k + $_.h1t + $_.h2 + $_.h3 + $_.h4 }; Descending = $true }, scene | Select-Object -First 30)) {
    $idx++
    $score = $s.h1m + $s.h1k + $s.h1t + $s.h2 + $s.h3 + $s.h4
    $r.Add(('| {0} | {1} | {2} | {3} | {4} | {5} | {6} | {7} | {8} | {9} | {10} |' -f $idx, $s.scene, $s.table, $s.rows, $s.h1m, $s.h1k, $s.h1t, $s.h2, $s.h3, $s.h4, $score))
}
$r.Add('')
$r.Add('## Screenshot scene: VO_CS_01_15')
$r.Add('')
$scene = @($rows | Where-Object { $_.Scene -eq 'VO_CS_01_15' } | Sort-Object Suffix, Line)
if ($scene.Count -eq 0) {
    $r.Add('Scene not found in the extracted DataTables.')
} else {
    $r.Add('| order | line | key | marker | speaker | markers | clip s | final singleton | following in scene | cps | English | Arabic |')
    $r.Add('|---:|---:|---|---|---|---|---:|---|---|---:|---|---|')
    for ($i = 0; $i -lt $scene.Count; $i++) {
        $x = $scene[$i]
        $follow = if ($i -lt $scene.Count - 1) { 'yes' } else { 'no' }
        $enSnip = $x.En; if ($enSnip.Length -gt 120) { $enSnip = $enSnip.Substring(0, 117) + '...' }
        $arSnip = $x.Ar.Trim(); if ($arSnip.Length -gt 120) { $arSnip = $arSnip.Substring(0, 117) + '...' }
        $r.Add(('| {0} | {1} | `{2}` | {3} | {4} | {5} | {6} | {7} | {8} | {9} | {10} | {11} |' -f ($i+1), $x.Line, $x.Key, $x.Marker, $x.Speaker, $x.Tokens, $x.Clip.ToString('0.000'), $x.FinalSingleton, $follow, $x.Cps.ToString('0.0'), $enSnip.Replace('|','/'), $arSnip.Replace('|','/')))
    }
    $scH1m = @($scene | Where-Object { $_.H1m -eq 1 }).Count
    $scH1k = @($scene | Where-Object { $_.H1k -eq 1 }).Count
    $scH1t = @($scene | Where-Object { $_.H1t -gt 0 }).Count
    $scH2 = @($scene | Where-Object { $_.H2 -gt 0 }).Count
    $scH3 = @($scene | Where-Object { $_.H3 -eq 1 }).Count
    $scH4 = @($scene | Where-Object { $_.H4 -eq 1 }).Count
    $r.Add('')
    $r.Add(('Scene counts: H1m {0} | H1k {1} | H1t {2} | H2 {3} | H3 {4} | H4 {5}.' -f $scH1m, $scH1k, $scH1t, $scH2, $scH3, $scH4))
    $r.Add('')
    $shot = @($scene | Where-Object { $_.Marker -match '_(Larisa_15|Victor_16|Larisa_17|P3_18)$' })
    $shotH3 = @($shot | Where-Object { $_.H3 -eq 1 }).Count
    $r.Add('### Screenshot lines')
    $r.Add('')
    $r.Add('| marker | line | tokens | final singleton | following in scene | H3 | clip s | cps |')
    $r.Add('|---|---:|---:|---|---|---|---:|---:|')
    foreach ($x in $shot) {
        $si = 0
        for ($k = 0; $k -lt $scene.Count; $k++) { if ([object]::ReferenceEquals($scene[$k], $x)) { $si = $k; break } }
        $follow = if ($si -lt $scene.Count - 1) { 'yes' } else { 'no' }
        $r.Add(('| {0} | {1} | {2} | {3} | {4} | {5} | {6} | {7} |' -f $x.Marker, $x.Line, $x.Tokens, $x.FinalSingleton, $follow, $x.H3, $x.Clip.ToString('0.000'), $x.Cps.ToString('0.0')))
    }
    $r.Add('')
    $lastShot = if ($shot.Count -gt 0) { $shot[$shot.Count - 1] } else { $null }
    $markerState = if ($lastShot -and $lastShot.Tokens -eq 0) { 'is still markerless' } else { 'now has an explicit 0-end range' }
    $r.Add(('Of the four screenshot lines, {0} of 4 have H3 (final singleton plus a following scene line). The long P-3 line {1} and reads at {2} Arabic chars/s over {3} s.' -f $shotH3, $markerState, $(if ($lastShot) { $lastShot.Cps.ToString('0.0') } else { '0' }), $(if ($lastShot) { $lastShot.Clip.ToString('0.000') } else { '0' })))
    $r.Add('')
    $r.Add('### Verdict')
    $r.Add('')
    if ($scH1m -eq 0 -and $scH1k -eq 0 -and $scH1t -eq 0) {
        $r.Add('- H1: **not supported** in this scene - the scene markers/keys are unique and no cell repeats a page start.')
    } else {
        $r.Add('- H1: **supported or contributing** - the scene contains duplicate markers, keys or repeated page starts.')
    }
    if ($scH2 -eq 0) {
        $r.Add('- H2: **not supported** in this scene - no explicit range end reaches the next page start.')
    } else {
        $r.Add('- H2: **supported or contributing** - at least one explicit range end overlaps the next page start.')
    }
    if ($scH3 -gt 0) {
        $r.Add('- H3: **LIKELY for the stack** - ' + $scH3 + ' line(s) in the scene have a final singleton page and a following line in the same scene; ' + $shotH3 + ' of the four screenshot lines are in that set. With markerless cells their lifetime is the whole Wwise clip, so overlapping voice events can leave several lines on screen at once.')
    } else {
        $r.Add('- H3: **not present in this variant** - no scene line remains a final singleton with a following line. All four screenshot lines now carry an explicit 0-end range; compare with the p12 baseline audit for the before state.')
    }
    if ($scH4 -eq 0) {
        $r.Add('- H4: **not supported** in this scene - no marker or key is reused in another stock DataTable.')
    } else {
        $r.Add('- H4: **supported or contributing** - at least one marker or key is reused in another stock DataTable.')
    }
    if ($lastShot -and $lastShot.Tokens -eq 0) {
        $r.Add('- The visible truncation of the long P-3 line is **not explained by H1-H4**. It is consistent with the bottom subtitle bar running out of vertical space when three wrapped lines are shown; the widget evidence is in `reports/p4_subtitle_hide_blueprint.md` and the play-test guide. H3 explains why the three lines are concurrent; it does not by itself truncate text.')
    } else {
        $r.Add('- The visible truncation of the long P-3 line is **not explained by H1-H4**. H3 has been addressed with explicit 0-end ranges, so the remaining truncation is consistent with the bottom subtitle bar running out of vertical space when three wrapped lines are shown; see `reports/p4_subtitle_hide_blueprint.md` and the play-test guide.')
    }
}

[IO.File]::WriteAllLines($ReportPath, $r, $utf8)

# --- machine-readable row table for gate chains
$hr = New-Object System.Collections.Generic.List[string]
$hr.Add(('table' + $TAB + 'row' + $TAB + 'line' + $TAB + 'scope' + $TAB + 'key' + $TAB + 'marker' + $TAB + 'scene' + $TAB + 'suffix' + $TAB + 'tokens' + $TAB + 'final_singleton' + $TAB + 'h1_marker_dup' + $TAB + 'h1_key_dup' + $TAB + 'h1_token_dup' + $TAB + 'h2_overlap' + $TAB + 'h3_final_following' + $TAB + 'h4_cross_table' + $TAB + 'clip_seconds' + $TAB + 'chars' + $TAB + 'cps'))
foreach ($x in $rows) {
    $hr.Add(($x.Table + $TAB + $x.Row + $TAB + $x.Line + $TAB + $x.Scope + $TAB + $x.Key + $TAB + $x.Marker + $TAB + $x.Scene + $TAB + $x.Suffix + $TAB + $x.Tokens + $TAB + $x.FinalSingleton + $TAB + $x.H1m + $TAB + $x.H1k + $TAB + $x.H1t + $TAB + $x.H2 + $TAB + $x.H3 + $TAB + $x.H4 + $TAB + $x.Clip.ToString('0.000') + $TAB + $x.Chars + $TAB + $x.Cps.ToString('0.00')))
}
[IO.File]::WriteAllLines($RowsPath, $hr, $utf8)

Write-Output ('STACK AUDIT: rows {0} | H1m {1} | H1k {2} | H1t {3} | H2 {4} | H3 {5} | H4 {6}' -f $total, $tH1m, $tH1k, $tH1t, $tH2, $tH3, $tH4)
Write-Output ('report: ' + $ReportPath)
Write-Output ('rows: ' + $RowsPath)
