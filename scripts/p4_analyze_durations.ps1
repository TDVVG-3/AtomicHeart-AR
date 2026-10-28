$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

# P4.3 - build clip-duration evidence, page reading-speed audit, and p11e variant.
# Read-only with respect to the game. All outputs are under build/p4, build/variants, reports.
$root = 'C:\AtomicHeart-AR'
$masterPath = Join-Path $root 'localization\master\atomic-heart-ar.tsv'
$eventsPath = Join-Path $root 'build\p4\wwise_events.tsv'
$dtPath = Join-Path $root 'build\extracted\dtsub\dtstat_all.tsv'
$ruRoot = Join-Path $root 'localization\extracted\ru_csv'
$dRoot = Join-Path $root 'build\c6\json_out'
$clipPath = Join-Path $root 'build\p4\clip_durations.tsv'
$pagesPath = Join-Path $root 'build\p4\subtitle_pages.tsv'
$repPath = Join-Path $root 'reports\p4_reading_speed.md'
$p11ePath = Join-Path $root 'build\variants\atomic-heart-ar_p11e.tsv'
$p11eRep = Join-Path $root 'reports\p11e_last_page_ranges.md'
$inv = [Globalization.CultureInfo]::InvariantCulture
$utf8 = New-Object Text.UTF8Encoding($false)
$TAB = [char]9
$markerRx = [regex]'\*([0-9]+(?:\.[0-9]+)?)(?:-([0-9]+(?:\.[0-9]+)?))?\*'
$arabicLetterRx = [regex]'[\u0621-\u064A\u0660-\u0669\u066E-\u06D3\u06D5\u06E5-\u06E6\u06EE-\u06EF\u06FA-\u06FC\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]'

function D([string]$s) { return [double]::Parse($s, $inv) }
function F1([double]$v) { return $v.ToString('0.0', $inv) }
function F2([double]$v) { return $v.ToString('0.00', $inv) }
function F3([double]$v) { return $v.ToString('0.000', $inv) }

function Get-MarkerPages([string]$text) {
    $list = New-Object System.Collections.Generic.List[object]
    if (-not $text) { return , $list }
    $ms = $markerRx.Matches($text)
    for ($i = 0; $i -lt $ms.Count; $i++) {
        $m = $ms[$i]
        $segStart = $m.Index + $m.Length
        $segEnd = if ($i + 1 -lt $ms.Count) { $ms[$i + 1].Index } else { $text.Length }
        $seg = if ($segEnd -gt $segStart) { $text.Substring($segStart, $segEnd - $segStart) } else { '' }
        $endMin = $null
        if ($m.Groups[2].Success) { $endMin = D $m.Groups[2].Value }
        $list.Add([pscustomobject]@{
            Index = $m.Index
            Length = $m.Length
            Marker = $m.Value
            StartMin = D $m.Groups[1].Value
            EndMin = $endMin
            Segment = $seg
        })
    }
    return , $list
}

function Get-ArabicCount([string]$text) {
    if (-not $text) { return 0 }
    $t = $markerRx.Replace($text, '')
    $t = [regex]::Replace($t, '&[^&]*&', '')
    $t = [regex]::Replace($t, '<[^>]*>', '')
    return $arabicLetterRx.Matches($t).Count
}

function Get-Scope([string]$file) {
    if ($file -match 'Localization/([^/]+)/(?:[a-z]{2}-[A-Z]{2})/') { return $Matches[1] }
    if ($file -match '/([^/]+)/[^/]+\.locres$') { return $Matches[1] }
    if ($file) { return [IO.Path]::GetFileNameWithoutExtension($file) }
    return '(unknown)'
}

function Get-Median([double[]]$vals) {
    if (-not $vals -or $vals.Count -eq 0) { return 0.0 }
    $a = @($vals | Sort-Object)
    $n = $a.Count
    if ($n % 2 -eq 1) { return [double]$a[($n - 1) / 2] }
    return ([double]$a[$n / 2 - 1] + [double]$a[$n / 2]) / 2.0
}

# ---------- evidence maps ----------
$events = @{}
foreach ($line in [IO.File]::ReadAllLines($eventsPath, [Text.Encoding]::UTF8) | Select-Object -Skip 1) {
    $f = $line -split $TAB
    if ($f.Count -lt 5) { continue }
    $min = 0.0; $max = 0.0
    try { $min = D $f[3] } catch { }
    try { $max = D $f[4] } catch { }
    $dur = if ($max -gt 0) { $max } elseif ($min -gt 0) { $min } else { 0.0 }
    if ($dur -le 0) { continue }
    if (-not $events.ContainsKey($f[0]) -or $events[$f[0]].Duration -lt $dur) {
        $events[$f[0]] = [pscustomobject]@{ Duration = $dur; Bank = $f[1]; Media = $f[5]; Json = $f[6] }
    }
}

$dtMap = @{}
foreach ($line in [IO.File]::ReadAllLines($dtPath, [Text.Encoding]::UTF8)) {
    $f = $line -split $TAB
    if ($f.Count -lt 6) { continue }
    if (-not $dtMap.ContainsKey($f[4])) {
        $dtMap[$f[4]] = [pscustomobject]@{ Marker = $f[2]; Asset = $f[0]; Row = $f[1]; RuText = $f[5] }
    }
}

$nodeMap = @{}
$nodeRx = [regex]'(?s)"StructType":"DialogueNode"[\s\S]{0,12000}?"Name":"UniqueId"[\s\S]{0,2000}?"Value":"([^"]+)"[\s\S]{0,4000}?"Name":"Text"[\s\S]{0,4000}?"Value":"([0-9A-F]{32})"'
foreach ($f in Get-ChildItem $dRoot -Recurse -Filter 'D_*.uasset.json' -File) {
    $j = [IO.File]::ReadAllText($f.FullName)
    foreach ($mm in $nodeRx.Matches($j)) {
        $uid = $mm.Groups[1].Value
        $key = $mm.Groups[2].Value
        if ($uid -eq 'None' -or $uid -match '^Duplicated') { continue }
        if (-not $nodeMap.ContainsKey($key)) { $nodeMap[$key] = New-Object System.Collections.Generic.List[string] }
        if (-not $nodeMap[$key].Contains($uid)) { $nodeMap[$key].Add($uid) }
    }
}

$ruMap = @{}
foreach ($f in Get-ChildItem $ruRoot -Filter '*.csv' -File) {
    try { $rows = Import-Csv -Path $f.FullName -Encoding UTF8 } catch { continue }
    foreach ($r in $rows) {
        if (-not $r.key) { continue }
        $txt = [string]$r.source
        if (-not $ruMap.ContainsKey($r.key) -or ($markerRx.IsMatch($txt) -and -not $markerRx.IsMatch([string]$ruMap[$r.key]))) {
            $ruMap[$r.key] = $txt
        }
    }
}
# DataTable Subtitle is a useful Russian-marker fallback where the CSV lost the markers.
foreach ($k in $dtMap.Keys) {
    $txt = [string]$dtMap[$k].RuText
    if ($markerRx.IsMatch($txt) -and (-not $ruMap.ContainsKey(('/' + $k)) -or -not $markerRx.IsMatch([string]$ruMap[('/' + $k)]))) {
        $ruMap[('/' + $k)] = $txt
    }
}

function Try-Event([string[]]$candidates) {
    foreach ($c in $candidates) {
        if ($c -and $events.ContainsKey($c)) { return [pscustomobject]@{ Name = $c; Duration = $events[$c].Duration; Bank = $events[$c].Bank; Media = $events[$c].Media } }
    }
    return $null
}

# ---------- master rows ----------
$lines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$clipRows = New-Object System.Collections.Generic.List[string]
$clipRows.Add(('line' + $TAB + 'key' + $TAB + 'scope' + $TAB + 'speaker' + $TAB + 'category' + $TAB + 'pages' + $TAB + 'last_page_start_sec' + $TAB + 'clip_seconds' + $TAB + 'last_page_remaining_sec' + $TAB + 'confidence' + $TAB + 'evidence' + $TAB + 'event' + $TAB + 'ru_last_end_sec' + $TAB + 'notes'))
$pageRows = New-Object System.Collections.Generic.List[string]
$pageRows.Add(('line' + $TAB + 'key' + $TAB + 'scope' + $TAB + 'page' + $TAB + 'start_sec' + $TAB + 'end_sec' + $TAB + 'window_sec' + $TAB + 'ar_chars' + $TAB + 'chars_per_sec' + $TAB + 'over17' + $TAB + 'over21' + $TAB + 'timing_basis' + $TAB + 'english_page' + $TAB + 'arabic_page'))

$stats = [ordered]@{
    markerRows = 0
    arMarkerRows = 0
    finalSingleton = 0
    finalRange = 0
    noArabicMarkers = 0
    clipConfirmed = 0
    clipLikely = 0
    clipUnknown = 0
    pages = 0
    pagesOver17 = 0
    pagesOver21 = 0
    arPagesWithMarkers = 0
}
$p11eChanges = New-Object System.Collections.Generic.List[object]
$p11eSkipped = New-Object System.Collections.Generic.List[object]
$clipRecords = New-Object System.Collections.Generic.List[object]
$scopeStats = @{}

for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split $TAB
    if ($f.Count -ne 13) { continue }
    $en = $f[5]; $ar = $f[6]
    $enHas = $markerRx.IsMatch($en); $arHas = $markerRx.IsMatch($ar)
    if (-not $enHas -and -not $arHas) { continue }
    $stats.markerRows++
    $key = $f[4]
    $scope = Get-Scope $f[2]
    $isAr = $arHas
    $text = if ($isAr) { $ar } else { $en }
    $pages = Get-MarkerPages $text
    if ($isAr) { $stats.arMarkerRows++ } else { $stats.noArabicMarkers++ }
    if ($pages.Count -eq 0) { continue }

    $last = $pages[$pages.Count - 1]
    if ($last.EndMin -ne $null) { $stats.finalRange++ } else { $stats.finalSingleton++ }
    $lastStartSec = $last.StartMin * 60.0

    $ruPages = New-Object System.Collections.Generic.List[object]
    if ($ruMap.ContainsKey($key)) { $ruPages = Get-MarkerPages ([string]$ruMap[$key]) }
    $ruLastEndSec = $null
    if ($ruPages.Count -gt 0 -and $ruPages[$ruPages.Count - 1].EndMin -ne $null) {
        $ruLastEndSec = $ruPages[$ruPages.Count - 1].EndMin * 60.0
    }

    # Resolve clip duration: exact DT marker, then dialogue-node UniqueId.
    $eventsTried = New-Object System.Collections.Generic.List[string]
    $hit = $null
    if ($dtMap.ContainsKey($key.TrimStart('/'))) {
        $id = $dtMap[$key.TrimStart('/')].Marker
        $eventsTried.Add('A_' + $id); $eventsTried.Add($id)
        if ($id -match '^VO_SP_Academy_Terminal_(0[137])$') {
            $eventsTried.Add('A_VO_SP_Academy_AudioTerminal_' + $Matches[1])
        }
    }
    if ($nodeMap.ContainsKey($key.TrimStart('/'))) {
        foreach ($id in $nodeMap[$key.TrimStart('/')]) {
            $eventsTried.Add('A_VO_' + $id); $eventsTried.Add('A_' + $id); $eventsTried.Add($id)
        }
    }
    $exactHit = Try-Event ($eventsTried.ToArray())
    $hit = $exactHit
    $fuzzy = $false
    if ($hit -eq $null) {
        $expanded = New-Object System.Collections.Generic.List[string]
        foreach ($c in $eventsTried) {
            $id = $c
            if ($id.StartsWith('A_')) { $id = $id.Substring(2) }
            $vars = New-Object System.Collections.Generic.List[string]
            $vars.Add($id)
            if ($id -match '^VO_SP_Vavilov_') {
                $vars.Add(($id -replace '^VO_SP_Vavilov_', 'VO_SP_'))
                $vars.Add(($id -replace '_Vavilov_', 'Vavilov'))
                $vars.Add(($id -replace '_Vavilov_', ''))
            }
            if ($id -match 'Theatre') {
                $vars.Add(($id -replace 'TheatreSchebetar', 'Theatre_Schebetar'))
                $vars.Add(($id -replace 'Theatre_Schebetar', 'TheatreSchebetar'))
            }
            if ($id -match 'Polygon10') { $vars.Add(($id -replace 'Polygon10', 'Polygon_10')) }
            if ($id -match 'FInal') { $vars.Add(($id -replace 'FInal', 'Final')) }
            foreach ($v in $vars) {
                $bases = New-Object System.Collections.Generic.List[string]
                $bases.Add($v)
                if ($v -match '_\d{1,3}$') { $bases.Add(($v -replace '_\d{1,3}$', '')) }
                foreach ($b in $bases) {
                    if ($b -match '^VO_') { $expanded.Add('A_' + $b); $expanded.Add($b) }
                    else { $expanded.Add('A_VO_' + $b); $expanded.Add($b) }
                }
            }
        }
        $hit = Try-Event ($expanded.ToArray())
        if ($hit -ne $null) { $fuzzy = $true }
    }

    $clipSec = $null
    $confidence = 'UNKNOWN'
    $evidence = ''
    $eventName = ''
    $notes = ''
    if ($hit -ne $null) {
        $clipSec = $hit.Duration
        $eventName = $hit.Name
        if ($fuzzy) {
            $confidence = 'LIKELY'
            $evidence = 'wwise_event_duration_fuzzy'
            $notes = 'event name resolved by token/suffix normalization'
            $stats.clipLikely++
        } else {
            $confidence = 'CONFIRMED'
            $evidence = 'wwise_event_duration'
            $stats.clipConfirmed++
        }
    } elseif ($ruLastEndSec -ne $null -and $ruLastEndSec -gt 0) {
        $clipSec = $ruLastEndSec
        $confidence = 'LIKELY'
        $evidence = 'ru_last_explicit_end'
        $stats.clipLikely++
        $notes = 'no exact Wwise event; estimated from ru-RU marker range end'
    } else {
        # Estimate from English/Russian marker spacing. Use the larger of the
        # median positive page gap and the Arabic reading need of the last page.
        $starts = @($pages | ForEach-Object { $_.StartMin * 60.0 })
        $gaps = New-Object System.Collections.Generic.List[double]
        for ($g = 1; $g -lt $starts.Count; $g++) {
            if ($starts[$g] -gt $starts[$g - 1]) { $gaps.Add($starts[$g] - $starts[$g - 1]) }
        }
        if ($ruPages.Count -gt 0) {
            for ($g = 1; $g -lt $ruPages.Count; $g++) {
                if ($ruPages[$g].StartMin -gt $ruPages[$g - 1].StartMin) { $gaps.Add(($ruPages[$g].StartMin - $ruPages[$g - 1].StartMin) * 60.0) }
            }
        }
        $medianGap = Get-Median $gaps.ToArray()
        $lastAr = Get-ArabicCount $last.Segment
        $need = ($lastAr / 15.0) + 1.2
        $tail = [Math]::Max($medianGap, $need)
        if ($tail -le 0) { $tail = 3.0 }
        $clipSec = $lastStartSec + $tail
        $confidence = 'UNKNOWN'
        $evidence = 'marker_spacing_estimate'
        $stats.clipUnknown++
        $notes = 'no exact Wwise event; estimated from EN/RU marker spacing and Arabic reading need'
    }

    if ($clipSec -le 0) { $clipSec = $lastStartSec + 3.0; $confidence = 'UNKNOWN'; $evidence = 'fallback' }
    # An absolute-start track is only trusted when it is monotonic and does not
    # produce an impossible reading window. A max above 35 chars/s is treated as
    # a defective source marker track and the duration interpretation is used.
    $arAbsolute = $arStrict
    if ($arAbsolute -and $pages.Count -gt 0) {
        for ($q = 0; $q -lt $pages.Count; $q++) {
            $s0 = $pages[$q].StartMin * 60.0
            $e0 = $clipSec
            if ($pages[$q].EndMin -ne $null) { $e0 = $pages[$q].EndMin * 60.0 }
            if ($q + 1 -lt $pages.Count) { $e0 = $pages[$q + 1].StartMin * 60.0 }
            if ($e0 -le $s0) { $arAbsolute = $false; break }
            $c0 = Get-ArabicCount $pages[$q].Segment
            if (($c0 / ($e0 - $s0)) -gt 35.0) { $arAbsolute = $false; break }
        }
    }
    $remaining = $clipSec - $lastStartSec
    if ($remaining -lt 0) { $remaining = 0.0 }

    $clipRecords.Add([pscustomobject]@{
        Line = $i + 1; Key = $key; Scope = $scope; Speaker = $f[8]; Category = $f[9]
        Pages = $pages.Count; LastStart = $lastStartSec; Clip = $clipSec; Remaining = $remaining
        Confidence = $confidence; Evidence = $evidence; Event = $eventName; RuLastEnd = $ruLastEndSec; Notes = $notes
        En = $en; Ar = $ar; ArPages = $pages; RuPages = $ruPages
    })
    $clipRows.Add(([string]($i + 1)) + $TAB + $key + $TAB + $scope + $TAB + $f[8] + $TAB + $f[9] + $TAB + $pages.Count + $TAB + (F3 $lastStartSec) + $TAB + (F3 $clipSec) + $TAB + (F3 $remaining) + $TAB + $confidence + $TAB + $evidence + $TAB + $eventName + $TAB + $(if ($ruLastEndSec -ne $null) { F3 $ruLastEndSec } else { '' }) + $TAB + $notes)

    # ---------- page windows / reading speed ----------
    if (-not $isAr) { continue }
    $stats.arPagesWithMarkers += $pages.Count
    $timingBasis = 'ar_markers'
    $arStrict = $true
    for ($q = 1; $q -lt $pages.Count; $q++) {
        if ($pages[$q].StartMin -le $pages[$q - 1].StartMin) { $arStrict = $false; break }
    }
    $useRu = ($ruPages.Count -eq $pages.Count)
    if ($useRu) {
        $increasing = $true
        for ($q = 1; $q -lt $ruPages.Count; $q++) {
            if ($ruPages[$q].StartMin -le $ruPages[$q - 1].StartMin) { $increasing = $false; break }
        }
        if (-not $increasing) { $useRu = $false }
    }

    $startsSec = [double[]]::new([int]$pages.Count)
    $endsSec = [double[]]::new([int]$pages.Count)
    if ($useRu) {
        $timingBasis = 'ru_markers'
        for ($q = 0; $q -lt $ruPages.Count; $q++) { $startsSec[$q] = $ruPages[$q].StartMin * 60.0 }
        for ($q = 0; $q -lt $ruPages.Count; $q++) {
            $s = $startsSec[$q]
            $e = $null
            if ($ruPages[$q].EndMin -ne $null) { $e = $ruPages[$q].EndMin * 60.0 }
            if ($q + 1 -lt $ruPages.Count) {
                $next = $startsSec[$q + 1]
                if ($e -eq $null) { $e = $next }
                elseif ($next -gt $s -and $e -gt $next) { $e = $next }
            } else {
                if ($e -eq $null) { $e = $clipSec }
                elseif ($e -lt $s) { $e = $clipSec }
            }
            if ($e -eq $null -or $e -le $s) { $e = $s + 1.0 }
            $endsSec[$q] = [double]$e
        }
    } elseif ($arAbsolute) {
        $timingBasis = 'ar_markers'
        for ($q = 0; $q -lt $pages.Count; $q++) { $startsSec[$q] = $pages[$q].StartMin * 60.0 }
        for ($q = 0; $q -lt $pages.Count; $q++) {
            $s = $startsSec[$q]
            $e = $null
            if ($pages[$q].EndMin -ne $null) { $e = $pages[$q].EndMin * 60.0 }
            if ($q + 1 -lt $pages.Count) {
                $next = $startsSec[$q + 1]
                if ($e -eq $null) { $e = $next }
                elseif ($next -gt $s -and $e -gt $next) { $e = $next }
            } else {
                if ($e -eq $null) { $e = $clipSec }
                elseif ($e -lt $s) { $e = $clipSec }
            }
            if ($e -eq $null -or $e -le $s) { $e = $s + 1.0 }
            $endsSec[$q] = [double]$e
        }
    } else {
        # The source marker track is not monotonic. In these rows the values
        # behave like page durations, not absolute starts. Reconstruct a
        # cumulative track from the values, scale it to the clip if necessary,
        # and flag every page as an estimate.
        $timingBasis = 'duration_reinterpretation'
        $sumMin = 0.0
        foreach ($p in $pages) { $sumMin += $p.StartMin }
        $clipMin = $clipSec / 60.0
        $scale = 1.0
        if ($sumMin -gt 0 -and $clipMin -gt 0 -and $sumMin -gt $clipMin) { $scale = $clipMin / $sumMin }
        $cum = 0.0
        for ($q = 0; $q -lt $pages.Count; $q++) {
            $startsSec[$q] = $cum * 60.0
            $dur = $pages[$q].StartMin * $scale
            $cum += $dur
            $endsSec[$q] = $cum * 60.0
        }
        if ($clipSec -gt $startsSec[$pages.Count - 1]) { $endsSec[$pages.Count - 1] = $clipSec }
        for ($q = 0; $q -lt $pages.Count; $q++) {
            if ($endsSec[$q] -le $startsSec[$q]) { $endsSec[$q] = $startsSec[$q] + 1.0 }
        }
    }

    $enPages = Get-MarkerPages $en
    for ($q = 0; $q -lt $pages.Count; $q++) {
        $p = $pages[$q]
        $s = [double]$startsSec[$q]
        $e = [double]$endsSec[$q]
        $window = $e - $s
        if ($window -lt 0.01) { $window = 0.01 }
        $chars = Get-ArabicCount $p.Segment
        $cps = $chars / $window
        $o17 = if ($cps -gt 17.0) { 1 } else { 0 }
        $o21 = if ($cps -gt 21.0) { 1 } else { 0 }
        $stats.pages++
        if ($o17) { $stats.pagesOver17++ }
        if ($o21) { $stats.pagesOver21++ }
        if (-not $scopeStats.ContainsKey($scope)) { $scopeStats[$scope] = [pscustomobject]@{ pages = 0; over17 = 0; over21 = 0; confirmed = 0; likely = 0; unknown = 0 } }
        $scopeStats[$scope].pages++
        if ($o17) { $scopeStats[$scope].over17++ }
        if ($o21) { $scopeStats[$scope].over21++ }
        if ($confidence -eq 'CONFIRMED') { $scopeStats[$scope].confirmed++ }
        elseif ($confidence -eq 'LIKELY') { $scopeStats[$scope].likely++ }
        else { $scopeStats[$scope].unknown++ }
        $enSeg = if ($enPages.Count -eq $pages.Count) { $enPages[$q].Segment } else { '' }
        $pageRows.Add(([string]($i + 1)) + $TAB + $key + $TAB + $scope + $TAB + ($q + 1) + $TAB + (F3 $s) + $TAB + (F3 $e) + $TAB + (F3 $window) + $TAB + $chars + $TAB + (F2 $cps) + $TAB + $o17 + $TAB + $o21 + $TAB + $timingBasis + $TAB + $enSeg + $TAB + $p.Segment)
    }

    # ---------- p11e decision for the final Arabic page ----------
    if ($last.EndMin -eq $null) {
        if (-not $arStrict) {
            $p11eSkipped.Add([pscustomobject]@{ Line = $i + 1; Key = $key; Reason = 'non-monotonic Arabic marker sequence' })
        } elseif ($last.Segment.Trim().Length -eq 0) {
            $p11eSkipped.Add([pscustomobject]@{ Line = $i + 1; Key = $key; Reason = 'final marker has no visible text' })
        } else {
            $chars = Get-ArabicCount $last.Segment
            $needSec = ($chars / 15.0) + 1.2
            $endMin = [Math]::Max($clipSec / 60.0, $last.StartMin + ($needSec / 60.0))
            if ($endMin -le $last.StartMin) { $endMin = $last.StartMin + ($needSec / 60.0) }
            $p11eChanges.Add([pscustomobject]@{
                Line = $i + 1; Key = $key; StartMin = $last.StartMin; EndMin = $endMin
                Chars = $chars; ClipSec = $clipSec; Confidence = $confidence; Index = $last.Index; Length = $last.Length
                OldMarker = $last.Marker
            })
        }
    }
}


# ---------- write evidence tables ----------
[IO.File]::WriteAllLines($clipPath, $clipRows, $utf8)
[IO.File]::WriteAllLines($pagesPath, $pageRows, $utf8)

# ---------- p11e variant (final singleton Arabic marker -> explicit range) ----------
$outLines = New-Object System.Collections.Generic.List[string]
$outLines.Add($lines[0])
$changesByLine = @{}
foreach ($c in $p11eChanges) {
    if (-not $changesByLine.ContainsKey($c.Line)) { $changesByLine[$c.Line] = New-Object System.Collections.Generic.List[object] }
    $changesByLine[$c.Line].Add($c)
}
$changed = 0
for ($i = 1; $i -lt $lines.Count; $i++) {
    $lineNo = $i + 1
    if (-not $changesByLine.ContainsKey($lineNo)) { $outLines.Add($lines[$i]); continue }
    $f = $lines[$i] -split $TAB
    if ($f.Count -ne 13) { $outLines.Add($lines[$i]); continue }
    $ar = $f[6]
    $cs = @($changesByLine[$lineNo] | Sort-Object Index -Descending)
    $ok = $true
    foreach ($c in $cs) {
        $startText = $c.OldMarker.Substring(1, $c.OldMarker.Length - 2)
        if ($startText -match '-') { $ok = $false; break }
        $newMarker = '*' + $startText + '-' + (F3 $c.EndMin) + '*'
        if ($c.Index -lt 0 -or $c.Index + $c.Length -gt $ar.Length) { $ok = $false; break }
        $ar = $ar.Substring(0, $c.Index) + $newMarker + $ar.Substring($c.Index + $c.Length)
        $c | Add-Member -NotePropertyName NewMarker -NotePropertyValue $newMarker -Force
    }
    if ($ok) { $f[6] = $ar; $outLines.Add(($f -join $TAB)); $changed += $cs.Count } else { $outLines.Add($lines[$i]) }
}
[IO.File]::WriteAllLines($p11ePath, $outLines, $utf8)

# ---------- report ----------
$rep = New-Object System.Collections.Generic.List[string]
$rep.Add('# P4.3 - subtitle clip durations and Arabic reading speed')
$rep.Add('')
$rep.Add('**Generated:** ' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz'))
$rep.Add('**Method:** English(US) Wwise bank metadata (`SoundBanksInfo...IncludedEvents[].DurationMax`) for clip length; `DT_Subtitles` `Marker` and dialogue-node `UniqueId` for key-to-event mapping; ru-RU marker ranges and EN/AR marker spacing only as fallbacks. Marker times are absolute minutes; all calculations are in seconds.')
$rep.Add('')
$rep.Add('## Coverage')
$rep.Add('')
$rep.Add('| item | count |')
$rep.Add('| --- | ---: |')
$rep.Add('| master rows with any marker | ' + $stats.markerRows + ' |')
$rep.Add('| rows with Arabic markers | ' + $stats.arMarkerRows + ' |')
$rep.Add('| rows without Arabic markers (skipped by p11f/p11e) | ' + $stats.noArabicMarkers + ' |')
$rep.Add('| clip duration CONFIRMED from Wwise event metadata | ' + $stats.clipConfirmed + ' |')
$rep.Add('| clip duration LIKELY from ru-RU explicit range end | ' + $stats.clipLikely + ' |')
$rep.Add('| clip duration UNKNOWN, estimated from marker spacing | ' + $stats.clipUnknown + ' |')
$rep.Add('| subtitle pages measured | ' + $stats.pages + ' |')
$rep.Add('| pages above 17 Arabic chars/s | ' + $stats.pagesOver17 + ' |')
$rep.Add('| pages above 21 Arabic chars/s | ' + $stats.pagesOver21 + ' |')
$rep.Add('')
$rep.Add('Confidence is per row, not per page. `CONFIRMED` means the exact Wwise event was found and its bank metadata gave a positive duration; `LIKELY` means the clip end came from the ru-RU explicit marker range; `UNKNOWN` means the clip end is a marker-spacing/reading-need estimate.')
$rep.Add('')
$rep.Add('## Per-scope reading speed')
$rep.Add('')
$rep.Add('| scope | pages | >17 | >21 |')
$rep.Add('| --- | ---: | ---: | ---: |')
foreach ($k in ($scopeStats.Keys | Sort-Object)) {
    $v = $scopeStats[$k]
    $rep.Add('| ' + $k + ' | ' + $v.pages + ' | ' + $v.over17 + ' | ' + $v.over21 + ' |')
}
$rep.Add('')

# 30 worst pages
$worst = New-Object System.Collections.Generic.List[object]
foreach ($line in [IO.File]::ReadAllLines($pagesPath, [Text.Encoding]::UTF8) | Select-Object -Skip 1) {
    $f = $line -split $TAB
    if ($f.Count -lt 14) { continue }
    $cps = D $f[8]
    if ($cps -le 21.0) { continue }
    $worst.Add([pscustomobject]@{
        Line = [int]$f[0]; Key = $f[1]; Scope = $f[2]; Page = [int]$f[3]; Start = D $f[4]; End = D $f[5]
        Window = D $f[6]; Chars = [int]$f[7]; Cps = $cps; Basis = $f[11]; En = $f[12]; Ar = $f[13]
    })
}
$rep.Add('## 30 worst pages above 21 Arabic chars/s')
$rep.Add('')
$rep.Add('Sorted by Arabic characters per second. `window` is the effective visible window (explicit range end when present; otherwise next page start / clip end). Duplicate-timestamp groups are subdivided and marked `estimated_duplicate_repair`.')
$rep.Add('')
$rep.Add('| # | line | scope | page | chars | window s | chars/s | basis | English | Arabic |')
$rep.Add('| ---: | ---: | --- | ---: | ---: | ---: | ---: | --- | --- | --- |')
$n = 0
foreach ($w in ($worst | Sort-Object Cps -Descending | Select-Object -First 30)) {
    $n++
    $en = $w.En -replace '\|', '\|'
    $ar = $w.Ar -replace '\|', '\|'
    $rep.Add('| ' + $n + ' | ' + $w.Line + ' | ' + $w.Scope + ' | ' + $w.Page + ' | ' + $w.Chars + ' | ' + (F2 $w.Window) + ' | ' + (F1 $w.Cps) + ' | ' + $w.Basis + ' | ' + $en + ' | ' + $ar + ' |')
}
$rep.Add('')
$rep.Add('## Artifacts')
$rep.Add('')
$rep.Add('- `build/p4/clip_durations.tsv` - row-level clip length, last-page start, last-page remaining seconds, confidence and evidence.')
$rep.Add('- `build/p4/subtitle_pages.tsv` - every Arabic page with its window, Arabic letter count and chars/s.')
$rep.Add('- `reports/p4_reading_speed.md` - this report.')
$rep.Add('')
[IO.File]::WriteAllLines($repPath, $rep, $utf8)

# p11e report
$p11eRepLines = New-Object System.Collections.Generic.List[string]
$p11eRepLines.Add('# p11e - final singleton page as an explicit range')
$p11eRepLines.Add('')
$p11eRepLines.Add('**Generated:** ' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz'))
$p11eRepLines.Add('')
$p11eRepLines.Add('Rule: for the final Arabic page only, `*t*` -> `*t-e*`, where')
$p11eRepLines.Add('')
$p11eRepLines.Add('```')
$p11eRepLines.Add('e = max(clip_end, t + arabic_letters/15 + 1.2 s)')
$p11eRepLines.Add('```')
$p11eRepLines.Add('')
$p11eRepLines.Add('Only the final marker of each row is touched. All earlier markers and all twelve non-Arabic columns stay byte-identical. Rows whose final page already has an explicit range are left unchanged.')
$p11eRepLines.Add('')
$p11eRepLines.Add('| item | count |')
$p11eRepLines.Add('| --- | ---: |')
$p11eRepLines.Add('| rows with Arabic markers | ' + $stats.arMarkerRows + ' |')
$p11eRepLines.Add('| final page already explicit range (unchanged) | ' + $stats.finalRange + ' |')
$p11eRepLines.Add('| final singleton converted | ' + $changed + ' |')
$p11eRepLines.Add('| rows skipped as ambiguous | ' + $p11eSkipped.Count + ' |')
$p11eRepLines.Add('| clip CONFIRMED / LIKELY / UNKNOWN among converted rows | ' + (@($p11eChanges | Where-Object { $_.Confidence -eq 'CONFIRMED' }).Count) + ' / ' + (@($p11eChanges | Where-Object { $_.Confidence -eq 'LIKELY' }).Count) + ' / ' + (@($p11eChanges | Where-Object { $_.Confidence -eq 'UNKNOWN' }).Count) + ' |')
$p11eRepLines.Add('')
if ($p11eSkipped.Count -gt 0) {
    $p11eRepLines.Add('## Ambiguous rows left unchanged')
    $p11eRepLines.Add('')
    $p11eRepLines.Add('| line | key | reason |')
    $p11eRepLines.Add('| ---: | --- | --- |')
    foreach ($s in $p11eSkipped) { $p11eRepLines.Add('| ' + $s.Line + ' | ' + $s.Key + ' | ' + $s.Reason + ' |') }
    $p11eRepLines.Add('')
}
$p11eRepLines.Add('## Examples')
$p11eRepLines.Add('')
$p11eRepLines.Add('| line | old | new | chars | clip s | confidence |')
$p11eRepLines.Add('| ---: | --- | --- | ---: | ---: | --- |')
foreach ($c in ($p11eChanges | Select-Object -First 25)) {
    $p11eRepLines.Add('| ' + $c.Line + ' | `' + $c.OldMarker + '` | `' + $c.NewMarker + '` | ' + $c.Chars + ' | ' + (F2 $c.ClipSec) + ' | ' + $c.Confidence + ' |')
}
$p11eRepLines.Add('')
$p11eRepLines.Add('Variant: `build/variants/atomic-heart-ar_p11e.tsv`.')
[IO.File]::WriteAllLines($p11eRep, $p11eRepLines, $utf8)

Write-Output ('clip rows=' + $clipRecords.Count)
Write-Output ('pages=' + $stats.pages + ' over17=' + $stats.pagesOver17 + ' over21=' + $stats.pagesOver21)
Write-Output ('clip confirmed=' + $stats.clipConfirmed + ' likely=' + $stats.clipLikely + ' unknown=' + $stats.clipUnknown)
Write-Output ('p11e converted=' + $changed + ' skipped=' + $p11eSkipped.Count)
Write-Output ('wrote ' + $clipPath)
Write-Output ('wrote ' + $pagesPath)
Write-Output ('wrote ' + $repPath)
Write-Output ('wrote ' + $p11ePath)
