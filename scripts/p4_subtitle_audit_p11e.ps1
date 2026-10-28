$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

# p11e structural + formula audit.
# Only the final singleton Arabic marker may become a range. Every start, every earlier
# marker, every other marker type and all twelve non-Arabic columns must stay byte-identical.
$TAB = [char]9
$inv = [Globalization.CultureInfo]::InvariantCulture
$masterPath = 'C:\AtomicHeart-AR\localization\master\atomic-heart-ar.tsv'
$varPath = 'C:\AtomicHeart-AR\build\variants\atomic-heart-ar_p11e.tsv'
$clipPath = 'C:\AtomicHeart-AR\build\p4\clip_durations.tsv'
$reportPath = 'C:\AtomicHeart-AR\reports\p11e_audit.md'
$rx = [regex]'\*([0-9]+(?:\.[0-9]+)?)(?:-([0-9]+(?:\.[0-9]+)?))?\*'
$mk = [regex]'\*[0-9][0-9.\-]*\*'
$arLetter = [regex]'[\u0621-\u064A\u0660-\u0669\u066E-\u06D3\u06D5\u06E5-\u06E6\u06EE-\u06EF\u06FA-\u06FC\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]'

$clip = @{}
foreach ($line in [IO.File]::ReadAllLines($clipPath, [Text.Encoding]::UTF8) | Select-Object -Skip 1) {
    $f = $line -split $TAB
    if ($f.Count -lt 9) { continue }
    $clip[[int]$f[0]] = [pscustomobject]@{ Seconds = [double]::Parse($f[7], $inv); Confidence = $f[9] }
}
$m = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$v = [IO.File]::ReadAllLines($varPath, [Text.Encoding]::UTF8)
if ($m.Count -ne $v.Count) { throw ('row count differs: ' + $m.Count + ' vs ' + $v.Count) }

$rows = 0; $changed = 0; $viol = 0
$details = New-Object System.Collections.Generic.List[string]
$examples = New-Object System.Collections.Generic.List[string]
for ($i = 1; $i -lt $m.Count; $i++) {
    if (-not $m[$i].Trim()) { continue }
    $a = $m[$i] -split $TAB
    $b = $v[$i] -split $TAB
    if ($a.Count -ne 13 -or $b.Count -ne 13) { $viol++; $details.Add(('L' + ($i + 1) + ' bad column count')); continue }
    for ($c = 0; $c -lt 13; $c++) {
        if ($c -eq 6) { continue }
        if ($a[$c] -cne $b[$c]) { $viol++; $details.Add(('L' + ($i + 1) + ' column ' + $c + ' changed')) }
    }
    if (($a[6] -replace $mk, '') -cne ($b[6] -replace $mk, '')) { $viol++; $details.Add(('L' + ($i + 1) + ' visible Arabic text changed')) }
    $am = $rx.Matches($a[6]); $bm = $rx.Matches($b[6])
    if ($am.Count -ne $bm.Count) { $viol++; $details.Add(('L' + ($i + 1) + ' Arabic marker count changed')); continue }
    if ($am.Count -eq 0) { continue }
    $rows++
    $strict = $true
    for ($j = 1; $j -lt $am.Count; $j++) {
        $p0 = [double]::Parse($am[$j - 1].Groups[1].Value, $inv)
        $p1 = [double]::Parse($am[$j].Groups[1].Value, $inv)
        if ($p1 -le $p0) { $strict = $false; break }
    }
    for ($j = 0; $j -lt $am.Count; $j++) {
        $oldStart = $am[$j].Groups[1].Value
        $newStart = $bm[$j].Groups[1].Value
        if ($oldStart -cne $newStart) { $viol++; $details.Add(('L' + ($i + 1) + ' start[' + $j + '] ' + $oldStart + ' != ' + $newStart)) }
        $oldRange = $am[$j].Groups[2].Success
        $newRange = $bm[$j].Groups[2].Success
        if ($oldRange -ne $newRange -and $j -ne $am.Count - 1) {
            $viol++; $details.Add(('L' + ($i + 1) + ' non-final type[' + $j + '] changed'))
        }
        if ($oldRange -and -not $newRange) {
            $viol++; $details.Add(('L' + ($i + 1) + ' range[' + $j + '] became a singleton'))
        }
        if ($oldRange -and $bm[$j].Groups[2].Success) {
            $oe = [double]::Parse($am[$j].Groups[2].Value, $inv)
            $ne = [double]::Parse($bm[$j].Groups[2].Value, $inv)
            if ($ne -lt $oe - 0.0001) { $viol++; $details.Add(('L' + ($i + 1) + ' end[' + $j + '] shrank ' + $oe + ' -> ' + $ne)) }
            if ($ne -gt $oe + 0.0001 -and $j + 1 -lt $bm.Count) {
                $next = [double]::Parse($bm[$j + 1].Groups[1].Value, $inv)
                if ($ne -ge $next) { $viol++; $details.Add(('L' + ($i + 1) + ' end[' + $j + '] reaches next start')) }
            }
        }
    }
    $oldLastSingleton = -not $am[$am.Count - 1].Groups[2].Success
    $newLastRange = $bm[$bm.Count - 1].Groups[2].Success
    if ($oldLastSingleton -and $newLastRange) {
        if (-not $strict) {
            $viol++; $details.Add(('L' + ($i + 1) + ' non-monotonic final marker was converted'))
        } else {
            $changed++
            $last = $bm[$bm.Count - 1]
            $newEnd = [double]::Parse($last.Groups[2].Value, $inv)
            $start = [double]::Parse($last.Groups[1].Value, $inv)
            if ($newEnd -le $start + 0.0001) { $viol++; $details.Add(('L' + ($i + 1) + ' final range does not advance')) }
            $segStart = $last.Index + $last.Length
            $seg = if ($segStart -lt $b[6].Length) { $b[6].Substring($segStart) } else { '' }
            $seg = $mk.Replace($seg, '')
            $seg = [regex]::Replace($seg, '&[^&]*&', '')
            $chars = $arLetter.Matches($seg).Count
            $needMin = ($chars / 15.0 + 1.2) / 60.0
            $expected = [Math]::Max($needMin, $start + $needMin)
            if ($clip.ContainsKey($i + 1)) { $expected = [Math]::Max($clip[($i + 1)].Seconds / 60.0, $start + $needMin) }
            if ($newEnd -lt $expected - 0.0015) {
                $viol++; $details.Add(('L' + ($i + 1) + ' end below formula ' + $newEnd.ToString('0.###', $inv) + ' < ' + $expected.ToString('0.###', $inv)))
            }
            if ($examples.Count -lt 8) { $examples.Add(('L' + ($i + 1) + '  ' + $am[$am.Count - 1].Value + ' -> ' + $last.Value + ' (' + $chars + ' chars)')) }
        }
    } elseif ($oldLastSingleton -and -not $newLastRange) {
        if ($strict) { $viol++; $details.Add(('L' + ($i + 1) + ' strict final singleton was not converted')) }
    } elseif (-not $oldLastSingleton -and $newLastRange) {
        $oe = [double]::Parse($am[$am.Count - 1].Groups[2].Value, $inv)
        $ne = [double]::Parse($bm[$bm.Count - 1].Groups[2].Value, $inv)
        if ([Math]::Abs($ne - $oe) -gt 0.0001) { $viol++; $details.Add(('L' + ($i + 1) + ' existing final range was changed')) }
    }
}

$r = New-Object System.Collections.Generic.List[string]
$r.Add('# p11e structural and formula audit')
$r.Add('')
$r.Add(('Generated: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')))
$r.Add('')
$r.Add(('Rows with Arabic markers: {0} | final singleton converted: {1} | violations: {2}' -f $rows, $changed, $viol))
$r.Add('')
$r.Add('Checks: row/column count; 12 non-Arabic columns byte-identical; visible Arabic text byte-identical;')
$r.Add('marker count/order and every start identical; only the final singleton may gain an end; no earlier')
$r.Add('marker type changes; no end reaches a later start; end >= max(clip end, t + Arabic chars/15 + 1.2 s).')
$r.Add('')
$r.Add('## Examples')
$r.Add('')
foreach ($e in $examples) { $r.Add('- ' + $e) }
$r.Add('')
if ($viol -gt 0) {
    $r.Add('## Violations')
    $r.Add('')
    foreach ($d in ($details | Select-Object -First 80)) { $r.Add('- ' + $d) }
}
[IO.File]::WriteAllLines($reportPath, $r, (New-Object Text.UTF8Encoding($false)))
Write-Output ('p11e audit: rows {0} | converted {1} | violations {2}' -f $rows, $changed, $viol)
Write-Output ('report: ' + $reportPath)
if ($viol -gt 0) { exit 1 }
