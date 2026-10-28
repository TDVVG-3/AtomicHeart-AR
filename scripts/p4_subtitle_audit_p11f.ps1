# p11f / p11ef text-only audit.
# Base and variant must have identical markers and identical page segmentation; only the
# page segments listed in p11f_applied.tsv may differ, and each new segment must match the
# validated replacement exactly.
param(
    [Parameter(Mandatory=$true)][string]$BaseTsV,
    [Parameter(Mandatory=$true)][string]$VarTsV,
    [Parameter(Mandatory=$true)][string]$ReportPath,
    [string]$EditsTsV = 'C:\AtomicHeart-AR\build\p4\p11f_applied.tsv'
)
$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$TAB = [char]9
$rx = [regex]'\*([0-9]+(?:\.[0-9]+)?)(?:-([0-9]+(?:\.[0-9]+)?))?\*'

$edits = @{}
foreach ($line in ([IO.File]::ReadAllLines($EditsTsV, [Text.Encoding]::UTF8) | Select-Object -Skip 1)) {
    if (-not $line.Trim()) { continue }
    $f = $line -split $TAB
    if ($f.Count -lt 10) { continue }
    $edits[([int]$f[0]).ToString() + '|' + $f[1]] = $f[9]
}
$base = [IO.File]::ReadAllLines($BaseTsV, [Text.Encoding]::UTF8)
$var = [IO.File]::ReadAllLines($VarTsV, [Text.Encoding]::UTF8)
if ($base.Count -ne $var.Count) { throw ('row count differs: ' + $base.Count + ' vs ' + $var.Count) }

$rows = 0; $changedPages = 0; $viol = 0; $seen = @{}
$details = New-Object System.Collections.Generic.List[string]
for ($i = 1; $i -lt $base.Count; $i++) {
    if (-not $base[$i].Trim()) { continue }
    $a = $base[$i] -split $TAB
    $b = $var[$i] -split $TAB
    if ($a.Count -ne 13 -or $b.Count -ne 13) { $viol++; $details.Add(('L' + ($i + 1) + ' bad column count')); continue }
    for ($c = 0; $c -lt 13; $c++) {
        if ($c -eq 6) { continue }
        if ($a[$c] -cne $b[$c]) { $viol++; $details.Add(('L' + ($i + 1) + ' column ' + $c + ' changed')) }
    }
    $am = $rx.Matches($a[6]); $bm = $rx.Matches($b[6])
    if ($am.Count -ne $bm.Count) { $viol++; $details.Add(('L' + ($i + 1) + ' marker count changed')); continue }
    for ($j = 0; $j -lt $am.Count; $j++) {
        if ($am[$j].Value -cne $bm[$j].Value) { $viol++; $details.Add(('L' + ($i + 1) + ' marker ' + $j + ' changed: ' + $am[$j].Value + ' -> ' + $bm[$j].Value)) }
    }
    if ($am.Count -gt 0) { $rows++ }
    for ($j = 0; $j -lt $am.Count; $j++) {
        $as = $am[$j].Index + $am[$j].Length
        $ae = if ($j + 1 -lt $am.Count) { $am[$j + 1].Index } else { $a[6].Length }
        $bs = $bm[$j].Index + $bm[$j].Length
        $be = if ($j + 1 -lt $bm.Count) { $bm[$j + 1].Index } else { $b[6].Length }
        $oldSeg = $a[6].Substring($as, $ae - $as)
        $newSeg = $b[6].Substring($bs, $be - $bs)
        $key = ([int]($i + 1)).ToString() + '|' + ($j + 1)
        if ($edits.ContainsKey($key)) {
            $seen[$key] = $true
            if ($newSeg -cne $edits[$key]) { $viol++; $details.Add(('L' + ($i + 1) + ' p' + ($j + 1) + ' does not match validated replacement')) }
            if ($oldSeg -ceq $newSeg) { $viol++; $details.Add(('L' + ($i + 1) + ' p' + ($j + 1) + ' target page did not change')) }
            $changedPages++
        } elseif ($oldSeg -cne $newSeg) {
            $viol++; $details.Add(('L' + ($i + 1) + ' p' + ($j + 1) + ' non-target page changed'))
        }
    }
}
foreach ($k in $edits.Keys) { if (-not $seen.ContainsKey($k)) { $viol++; $details.Add('edit not found: ' + $k) } }

$r = New-Object System.Collections.Generic.List[string]
$r.Add('# p11f text audit')
$r.Add('')
$r.Add(('Generated: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')))
$r.Add('')
$r.Add(('Base: `' + $BaseTsV + '`'))
$r.Add(('Variant: `' + $VarTsV + '`'))
$r.Add(('Rows with Arabic markers: {0} | target pages changed: {1} | violations: {2}' -f $rows, $changedPages, $viol))
$r.Add('')
$r.Add('Checks: row/column count; twelve non-Arabic columns byte-identical; every Arabic marker byte-identical;' )
$r.Add('all non-target page segments byte-identical; every target segment equals the validated p11f text exactly.')
$r.Add('')
if ($viol -gt 0) {
    $r.Add('## Violations')
    $r.Add('')
    foreach ($d in ($details | Select-Object -First 100)) { $r.Add('- ' + $d) }
}
[IO.File]::WriteAllLines($ReportPath, $r, (New-Object Text.UTF8Encoding($false)))
Write-Output ('{0}: rows={1} changedPages={2} violations={3}' -f (Split-Path $ReportPath -Leaf), $rows, $changedPages, $viol)
Write-Output ('report: ' + $ReportPath)
if ($viol -gt 0) { exit 1 }
