$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

# P4.2 - p11c: hold subtitle pages slightly longer by extending EXPLICIT range ends.
# Units: marker numbers are minutes into the voice clip (ru-RU 0.00-0.25 = 15 s).
#   end' = max(end + 0.005 min (=0.3 s), start + 1.15*span) for long rows,
#   capped strictly below the next page start inside the same row; never shrinks a page.
# Singleton-only pages have no end marker and are left untouched (documented as UNKNOWN).

$TAB = [char]9
$inv = [Globalization.CultureInfo]::InvariantCulture
$src = 'C:\AtomicHeart-AR\localization\master\atomic-heart-ar.tsv'
$dst = 'C:\AtomicHeart-AR\build\variants\atomic-heart-ar_p11c.tsv'
$rep = 'C:\AtomicHeart-AR\reports\p11c_marker_hold.md'
New-Item -ItemType Directory -Force -Path (Split-Path $dst -Parent) | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path $rep -Parent) | Out-Null

$lines = [IO.File]::ReadAllLines($src, [Text.Encoding]::UTF8)
$out = New-Object System.Collections.Generic.List[string]
$out.Add($lines[0])
$rx = [regex]'\*([0-9]+(?:\.[0-9]+)?)(?:-([0-9]+(?:\.[0-9]+)?))?\*'
$vis = [regex]'\*[0-9][0-9.\-]*\*|&[^&]{1,40}&'

$rows = 0; $rangeRows = 0; $singletonRows = 0; $changedRows = 0; $ranges = 0; $changedEnds = 0
$longRows = 0; $capped = 0; $noCapLast = 0
$sumDelta = 0.0; $maxDelta = 0.0; $minDelta = 9.9; $sumSpanRatio = 0.0
$examples = New-Object System.Collections.Generic.List[string]
$violations = New-Object System.Collections.Generic.List[string]

for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split $TAB
    if ($f.Count -ne 13) { $out.Add($lines[$i]); continue }
    $ar = $f[6]
    $ms = $rx.Matches($ar)
    if ($ms.Count -eq 0) { $out.Add($lines[$i]); continue }

    $rows++
    $hasRange = $false
    foreach ($m in $ms) { if ($m.Groups[2].Success) { $hasRange = $true } }
    if (-not $hasRange) { $singletonRows++; $out.Add($lines[$i]); continue }
    $rangeRows++

    $visible = $vis.Replace($ar, '')
    $isLong = ($visible.Length -ge 100)
    if ($isLong) { $longRows++ }

    $sb = New-Object Text.StringBuilder
    $pos = 0
    $rowChanged = $false
    for ($j = 0; $j -lt $ms.Count; $j++) {
        $m = $ms[$j]
        $sb.Append($ar.Substring($pos, $m.Index - $pos)) | Out-Null
        if ($m.Groups[2].Success) {
            $ranges++
            $a = [double]::Parse($m.Groups[1].Value, $inv)
            $b = [double]::Parse($m.Groups[2].Value, $inv)
            $span = $b - $a
            $nextStart = $null
            if ($j + 1 -lt $ms.Count) { $nextStart = [double]::Parse($ms[$j + 1].Groups[1].Value, $inv) }

            if ($span -lt 0) {
                $violations.Add(('L' + ($i + 1) + ' negative span ' + $m.Value))
                $sb.Append($m.Value) | Out-Null
                $pos = $m.Index + $m.Length
                continue
            }

            $cand = $b + 0.005
            if ($isLong) {
                $stretch = $a + ($span * 1.15)
                if ($stretch -gt $cand) { $cand = $stretch }
            }
            if ($null -ne $nextStart) {
                $cap = $nextStart - 0.005
                if ($cand -gt $cap) { $cand = $cap; $capped++ }
                if ($cand -lt $b) { $cand = $b }
            } else {
                $noCapLast++
            }
            if ($cand -lt $b) { $cand = $b }
            $cand = [math]::Round($cand, 3)
            $newEnd = $cand.ToString('0.###', $inv)
            $newTok = '*' + $m.Groups[1].Value + '-' + $newEnd + '*'
            if ($newEnd -ne $m.Groups[2].Value) {
                $changedEnds++; $rowChanged = $true
                $d = $cand - $b
                $sumDelta += $d; if ($d -gt $maxDelta) { $maxDelta = $d }; if ($d -lt $minDelta) { $minDelta = $d }
                if ($span -gt 0) { $sumSpanRatio += (($cand - $a) / $span) }
                if ($examples.Count -lt 10) {
                    $examples.Add(('L' + ($i + 1) + '  ' + $m.Value + ' -> ' + $newTok + '  (span ' + $span.ToString('0.000', $inv) + ' -> ' + ($cand - $a).ToString('0.000', $inv) + ' min)'))
                }
                if ($cand -gt $b -and $null -ne $nextStart -and $cand -ge $nextStart) {
                    $violations.Add(('L' + ($i + 1) + ' end ' + $newEnd + ' >= next start ' + $nextStart.ToString('0.###', $inv)))
                }
            }
            $sb.Append($newTok) | Out-Null
        } else {
            $sb.Append($m.Value) | Out-Null
        }
        $pos = $m.Index + $m.Length
    }
    $sb.Append($ar.Substring($pos)) | Out-Null
    $newAr = $sb.ToString()
    if ($rowChanged) { $changedRows++ }
    $f[6] = $newAr
    $out.Add(($f -join $TAB))
}

if ($violations.Count -gt 0) {
    $violations | Select-Object -First 20 | ForEach-Object { Write-Output ('VIOLATION ' + $_) }
    throw ('p11c violations: ' + $violations.Count)
}

[IO.File]::WriteAllLines($dst, $out, (New-Object Text.UTF8Encoding($false)))

# --- independent byte/structural check of the result
$v = [IO.File]::ReadAllLines($dst, [Text.Encoding]::UTF8)
$bad = 0
for ($i = 1; $i -lt $v.Count; $i++) {
    if (-not $v[$i].Trim()) { continue }
    $a = $v[$i] -split $TAB; $b = $lines[$i] -split $TAB
    if ($a.Count -ne 13) { $bad++; continue }
    for ($c = 0; $c -lt 13; $c++) {
        if ($c -eq 6) { continue }
        if ($a[$c] -cne $b[$c]) { $bad++; break }
    }
    $ma = $rx.Matches($a[6]); $mb = $rx.Matches($b[6])
    if ($ma.Count -ne $mb.Count) { $bad++; continue }
    for ($j = 0; $j -lt $mb.Count; $j++) {
        if ($ma[$j].Groups[1].Value -cne $mb[$j].Groups[1].Value) { $bad++; break }
        if ($ma[$j].Groups[2].Success -ne $mb[$j].Groups[2].Success) { $bad++; break }
        if ($mb[$j].Groups[2].Success) {
            $oldEnd = [double]::Parse($mb[$j].Groups[2].Value, $inv)
            $newEnd = [double]::Parse($ma[$j].Groups[2].Value, $inv)
            if ($newEnd -lt $oldEnd) { $bad++ }
        }
    }
}
if ($bad -ne 0) { throw ('p11c structural check failed: ' + $bad) }

$meanDelta = if ($changedEnds -gt 0) { $sumDelta / $changedEnds } else { 0 }
$meanRatio = if ($changedEnds -gt 0) { $sumSpanRatio / $changedEnds } else { 1 }

$r = New-Object System.Collections.Generic.List[string]
$r.Add('# p11c - subtitle page hold variant')
$r.Add('')
$r.Add(('Generated: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')))
$r.Add('')
$r.Add('Built from `localization/master/atomic-heart-ar.tsv`. Only the Arabic cell (column 6)')
$r.Add('changes, and only the END of an explicit range marker:')
$r.Add('')
$r.Add('```')
$r.Add('new_end = max(end + 0.005 min (= 0.3 s), start + 1.15 * span)   # 1.15 only for long rows')
$r.Add('new_end = min(new_end, next_page_start - 0.005 min)              # never overlap')
$r.Add('new_end = max(new_end, end)                                     # never shrink')
$r.Add('```')
$r.Add('')
$r.Add('Units are minutes into the voice clip (ru-RU `0.00-0.25` = 15 s). Singleton-only pages')
$r.Add('carry no end marker; their lifetime is the audio end and they are untouched.')
$r.Add('')
$r.Add(('Rows with Arabic markers: {0} | with ranges: {1} | singleton-only: {2} | changed rows: {3}' -f $rows, $rangeRows, $singletonRows, $changedRows))
$r.Add(('Explicit ranges: {0} | ends extended: {1} | capped by next start: {2} | last-range (no cap): {3}' -f $ranges, $changedEnds, $capped, $noCapLast))
$r.Add(('Long rows (visible Arabic >= 100 chars): {0}' -f $longRows))
$r.Add(('End delta (min): mean {0} | min {1} | max {2}' -f $meanDelta.ToString('0.000', $inv), $minDelta.ToString('0.000', $inv), $maxDelta.ToString('0.000', $inv)))
$r.Add(('Span ratio after edit: mean {0} (x1.15 target for long ranges)' -f $meanRatio.ToString('0.000', $inv)))
$r.Add('')
$r.Add('## Structural gate')
$r.Add('')
$r.Add('- all 12 non-Arabic columns byte-identical to the master')
$r.Add('- every row keeps its marker count and order; every range stays a range')
$r.Add('- every marker START value byte-identical; no end shrinks; no end reaches the next start')
$r.Add(('- violations: 0 (checked rows: {0})' -f ($v.Count - 1)))
$r.Add('')
$r.Add('## Examples')
$r.Add('')
foreach ($e in $examples) { $r.Add('- ' + $e) }
$r.Add('')
$r.Add('The stock `subtitle_timing_audit.ps1` compares AR markers to EN byte-exact; by design it')
$r.Add('reports this variant as different (intended end-only change). The adapted audit')
$r.Add('`scripts/p4_subtitle_audit_p11c.ps1` is the gate for this file.')
[IO.File]::WriteAllLines($rep, $r, (New-Object Text.UTF8Encoding($false)))

Write-Output ('p11c: rows {0} | ranges {1} | ends changed {2} | rows changed {3} | long rows {4} | capped {5}' -f $rows, $ranges, $changedEnds, $changedRows, $longRows, $capped)
Write-Output ('mean end delta min: ' + $meanDelta.ToString('0.000', $inv) + ' | mean span ratio: ' + $meanRatio.ToString('0.000', $inv))
Write-Output ('variant: ' + $dst)
Write-Output ('report: ' + $rep)
