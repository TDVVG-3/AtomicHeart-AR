$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

# P4.2 adapted subtitle audit for p11c.
# The stock audit proves AR == EN marker multiset byte-exact. p11c deliberately changes
# only the END of explicit ranges, so this gate proves:
#   - marker count, order, types and START values are still byte-identical to English
#   - every range end is >= the English end (never shrinks)
#   - no range end reaches the next page start (no new overlap)
#   - the Arabic text with markers stripped is byte-identical to the master
$TAB = [char]9
$inv = [Globalization.CultureInfo]::InvariantCulture
$master = 'C:\AtomicHeart-AR\localization\master\atomic-heart-ar.tsv'
$var = 'C:\AtomicHeart-AR\build\variants\atomic-heart-ar_p11c.tsv'
$rep = 'C:\AtomicHeart-AR\reports\p11c_audit.md'
$rx = [regex]'\*([0-9]+(?:\.[0-9]+)?)(?:-([0-9]+(?:\.[0-9]+)?))?\*'
$mk = [regex]'\*[0-9][0-9.\-]*\*'

$m = [IO.File]::ReadAllLines($master, [Text.Encoding]::UTF8)
$v = [IO.File]::ReadAllLines($var, [Text.Encoding]::UTF8)
if ($m.Count -ne $v.Count) { throw ('row count differs: ' + $m.Count + ' vs ' + $v.Count) }

$rows = 0; $ranges = 0; $changed = 0; $viol = 0
$sumDelta = 0.0; $maxDelta = 0.0
$details = New-Object System.Collections.Generic.List[string]
$examples = New-Object System.Collections.Generic.List[string]

for ($i = 1; $i -lt $m.Count; $i++) {
    if (-not $m[$i].Trim()) { continue }
    $a = $m[$i] -split $TAB; $b = $v[$i] -split $TAB
    if ($a.Count -ne 13 -or $b.Count -ne 13) { $viol++; $details.Add(('L' + ($i + 1) + ' bad column count')); continue }
    for ($c = 0; $c -lt 13; $c++) {
        if ($c -eq 6) { continue }
        if ($a[$c] -cne $b[$c]) { $viol++; $details.Add(('L' + ($i + 1) + ' column ' + $c + ' changed')) }
    }
    if (($a[6] -replace $mk, '') -cne ($b[6] -replace $mk, '')) { $viol++; $details.Add(('L' + ($i + 1) + ' visible Arabic text changed')) }

    $em = $rx.Matches($a[5])
    $am = $rx.Matches($a[6])
    $bm = $rx.Matches($b[6])
    if ($am.Count -ne $bm.Count) { $viol++; $details.Add(('L' + ($i + 1) + ' AR marker count changed')); continue }
    if ($em.Count -ne $am.Count) { continue }   # 2 rows with no Arabic markers: stock audit handles
    $rows++
    for ($j = 0; $j -lt $am.Count; $j++) {
        if ($em[$j].Groups[1].Value -cne $bm[$j].Groups[1].Value) { $viol++; $details.Add(('L' + ($i + 1) + ' start[' + $j + '] ' + $em[$j].Groups[1].Value + ' != ' + $bm[$j].Groups[1].Value)) }
        if ($em[$j].Groups[2].Success -ne $bm[$j].Groups[2].Success) { $viol++; $details.Add(('L' + ($i + 1) + ' type[' + $j + '] changed')) }
        if ($bm[$j].Groups[2].Success) {
            $ranges++
            $oe = [double]::Parse($am[$j].Groups[2].Value, $inv)
            $ne = [double]::Parse($bm[$j].Groups[2].Value, $inv)
            $s  = [double]::Parse($bm[$j].Groups[1].Value, $inv)
            if ($ne -lt $oe - 0.0001) { $viol++; $details.Add(('L' + ($i + 1) + ' end[' + $j + '] shrank ' + $oe + ' -> ' + $ne)) }
            if ($ne -gt $oe + 0.0001) { $changed++; $d = $ne - $oe; $sumDelta += $d; if ($d -gt $maxDelta) { $maxDelta = $d } }
            $next = $null
            if ($j + 1 -lt $bm.Count) { $next = [double]::Parse($bm[$j + 1].Groups[1].Value, $inv) }
            if ($null -ne $next -and $ne -gt $oe + 0.0001 -and $ne -ge $next) {
                $viol++; $details.Add(('L' + ($i + 1) + ' end[' + $j + '] ' + $ne + ' reaches next start ' + $next))
            }
            if ($examples.Count -lt 6 -and $ne -gt $oe + 0.0001) {
                $examples.Add(('L' + ($i + 1) + '  ' + $am[$j].Value + ' -> ' + $bm[$j].Value))
            }
        }
    }
}

$r = New-Object System.Collections.Generic.List[string]
$r.Add('# p11c adapted subtitle audit')
$r.Add('')
$r.Add(('Generated: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')))
$r.Add('')
$r.Add('Gate for the intended end-marker change. The stock audit compares AR to EN byte-exact and')
$r.Add('is expected to differ; this audit allows only an end increase on explicit ranges.')
$r.Add('')
$r.Add(('Rows compared: {0} | explicit ranges: {1} | ends extended: {2}' -f $rows, $ranges, $changed))
$r.Add(('Mean end delta: {0} min | max: {1} min' -f $(if ($changed) { ($sumDelta / $changed).ToString('0.000', $inv) } else { '0.000' }), $maxDelta.ToString('0.000', $inv)))
$r.Add(('Violations: {0}' -f $viol))
$r.Add('')
$r.Add('Checks: 12 non-Arabic columns byte-identical; visible Arabic text byte-identical;')
$r.Add('marker count/order/type/start identical to English; no end shrinks; no new overlap.')
$r.Add('')
$r.Add('## Examples')
$r.Add('')
foreach ($e in $examples) { $r.Add('- ' + $e) }
$r.Add('')
if ($viol -gt 0) {
    $r.Add('## Violations')
    $r.Add('')
    foreach ($d in ($details | Select-Object -First 50)) { $r.Add('- ' + $d) }
}
[IO.File]::WriteAllLines($rep, $r, (New-Object Text.UTF8Encoding($false)))
Write-Output ('p11c audit: rows {0} | ranges {1} | extended {2} | violations {3}' -f $rows, $ranges, $changed, $viol)
Write-Output ('report: ' + $rep)
if ($viol -gt 0) { exit 1 }
