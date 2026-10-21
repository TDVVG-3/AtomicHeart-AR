$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$TAB = [char]9
$inv = [Globalization.CultureInfo]::InvariantCulture
$src = 'C:\AtomicHeart-AR\localization\master\atomic-heart-ar.tsv'
$dst = 'C:\AtomicHeart-AR\build\variants\atomic-heart-ar_p11b.tsv'
$rep = 'C:\AtomicHeart-AR\reports\p11b_marker_retime.md'
New-Item -ItemType Directory -Force -Path (Split-Path $dst -Parent) | Out-Null

$lines = [IO.File]::ReadAllLines($src, [Text.Encoding]::UTF8)
$out = New-Object System.Collections.Generic.List[string]
$out.Add($lines[0])
$rows = 0; $changed = 0; $sumRatio = 0.0; $minR = 9.9; $maxR = 0.0
$examples = New-Object System.Collections.Generic.List[string]
$rx = [regex]'\*([0-9]+(?:\.[0-9]+)?)(?:-([0-9]+(?:\.[0-9]+)?))?\*'
$ratio = 1.15
for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split $TAB
    if ($f.Count -ne 13) { $out.Add($lines[$i]); continue }
    $en = $f[5]; $ar = $f[6]
    if (-not $rx.IsMatch($ar) -or -not $rx.IsMatch($en)) { $out.Add($lines[$i]); continue }
    $rows++
    $sumRatio += $ratio
    if ($ratio -lt $minR) { $minR = $ratio }
    if ($ratio -gt $maxR) { $maxR = $ratio }
    $before = $ar
    $newAr = $rx.Replace($ar, {
        param($m)
        $v1 = [double]::Parse($m.Groups[1].Value, $inv)
        $s1 = ($v1 * $ratio).ToString('0.00', $inv)
        if ($m.Groups[2].Success) {
            $v2 = [double]::Parse($m.Groups[2].Value, $inv)
            $s2 = ($v2 * $ratio).ToString('0.00', $inv)
            return '*' + $s1 + '-' + $s2 + '*'
        }
        return '*' + $s1 + '*'
    })
    if ($newAr -ne $before) {
        $changed++
        if ($examples.Count -lt 8) { $examples.Add(('L' + ($i + 1) + '  r=' + $ratio.ToString('0.000', $inv) + '  ' + ($rx.Matches($before)[0].Value) + ' -> ' + ($rx.Matches($newAr)[0].Value))) }
    }
    $f[6] = $newAr
    $out.Add(($f -join $TAB))
}
[IO.File]::WriteAllLines($dst, $out, (New-Object Text.UTF8Encoding($false)))

$mean = if ($rows -gt 0) { $sumRatio / $rows } else { 0 }
$r = New-Object System.Collections.Generic.List[string]
$r.Add('# p11b marker-retime variant (experiment)')
$r.Add('')
$r.Add('Generated from the master by slowing every subtitle cue by 15%: each marker number in')
$r.Add('the Arabic cell is multiplied by 1.15. Marker count, order and format are unchanged.')
$r.Add('Hypothesis under test: if the Arabic pages disappear too early / play too fast, a uniform')
$r.Add('15% lengthening should be visible; if the markers are absolute audio cues, this variant')
$r.Add('will desync progressively and the p11 (byte-exact English markers) build wins.')
$r.Add('')
$r.Add(('Rows with markers in both EN and AR: {0} | rows retimed: {1}' -f $rows, $changed))
$r.Add(('Ratio: mean {0} | min {1} | max {2}' -f $mean.ToString('0.000', $inv), $minR.ToString('0.000', $inv), $maxR.ToString('0.000', $inv)))
$r.Add('')
$r.Add('## Examples')
$r.Add('')
foreach ($e in $examples) { $r.Add('- ' + $e) }
$r.Add('')
$r.Add('This variant is NOT validated by scripts/subtitle_timing_audit.ps1 on purpose: the audit')
$r.Add('proves the shipped master keeps the English marker values byte-exact, and this file is the')
$r.Add('deliberate counter-example for the in-game A/B test. Only the pak built from it is shipped,')
$r.Add('as an alternative (p11b), never as the default.')
[IO.File]::WriteAllLines($rep, $r, (New-Object Text.UTF8Encoding($false)))
Write-Output ('p11b variant: rows {0} | retimed {1} | mean ratio {2}' -f $rows, $changed, $mean.ToString('0.000', $inv))
Write-Output ('variant: ' + $dst)
Write-Output ('report: ' + $rep)
