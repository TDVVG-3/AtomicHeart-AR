$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
$repo = 'C:\AtomicHeart-AR'

function Read-Tsv([string]$path) {
    $lines = [IO.File]::ReadAllLines($path, [Text.Encoding]::UTF8)
    $head = $lines[0] -split "`t"
    $rows = New-Object System.Collections.Generic.List[object]
    for ($i=1; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Length -eq 0) { continue }
        $c = $lines[$i] -split "`t"
        if ($c.Count -lt $head.Count) { continue }
        $o = [ordered]@{}
        for ($j=0; $j -lt $head.Count; $j++) { $o[$head[$j]] = $c[$j] }
        $rows.Add([pscustomobject]$o)
    }
    return $rows
}
function Norm([string]$t) {
    if ($null -eq $t) { return '' }
    $x = $t.Replace("`r", '').Replace("`n", ' ').Replace('"', '')
    $x = [regex]::Replace($x, '\s+', ' ').Trim()
    return $x
}

$trans = Read-Tsv (Join-Path $repo 'build\c6\translations_all.tsv')
$byNorm = @{}
$conflicts = 0
foreach ($t in $trans) {
    $n = Norm $t.ru
    if ($byNorm.ContainsKey($n) -and $byNorm[$n] -ne $t.ar) { $conflicts++ }
    $byNorm[$n] = $t.ar
}
Write-Output ('translations ' + $trans.Count + ' | norm keys ' + $byNorm.Count + ' | conflicts ' + $conflicts)

$all = Read-Tsv (Join-Path $repo 'build\c6\all_strings.tsv')
$mapDir = Join-Path $repo 'build\c6\maps_exact'
New-Item -ItemType Directory -Force -Path $mapDir | Out-Null
Remove-Item (Join-Path $mapDir '*.tsv') -Force -ErrorAction SilentlyContinue

$byAsset = [ordered]@{}
$matched = 0; $unmatched = 0
foreach ($r in $all) {
    $t = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($r.text_b64))
    $n = Norm $t
    if (-not $byNorm.ContainsKey($n)) { $unmatched++; continue }
    $ar = $byNorm[$n]
    if (-not $byAsset.Contains($r.asset)) { $byAsset[$r.asset] = New-Object System.Collections.Generic.List[object] }
    $byAsset[$r.asset].Add([pscustomobject]@{ kind=$r.kind; field=$r.field; text=$t; ar=$ar })
    $matched++
}

$manifest = New-Object System.Collections.Generic.List[string]
$manifest.Add("idx`tasset`tmap`trows`tdistinct_targets")
$idx = 0; $totalMap = 0
foreach ($asset in $byAsset.Keys) {
    $idx++
    $seen = @{}
    $map = New-Object System.Collections.Generic.List[string]
    $map.Add("kind`tfield`told_b64`tnew_b64")
    foreach ($r in $byAsset[$asset]) {
        $k = $r.kind + "\u0001" + $r.field + "\u0001" + $r.text
        if ($seen.ContainsKey($k)) { continue }
        $seen[$k] = $true
        $oldB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($r.text))
        $newB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($r.ar))
        $map.Add(($r.kind + "`t" + $r.field + "`t" + $oldB64 + "`t" + $newB64))
    }
    $name = $idx.ToString('0000') + '.tsv'
    [IO.File]::WriteAllLines((Join-Path $mapDir $name), $map, (New-Object Text.UTF8Encoding($false)))
    $totalMap += ($map.Count - 1)
    $manifest.Add(($idx.ToString('0000') + "`t" + $asset + "`t" + $name + "`t" + $byAsset[$asset].Count + "`t" + ($map.Count - 1)))
}
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\maps_exact_manifest.tsv'), $manifest, (New-Object Text.UTF8Encoding($false)))
Write-Output ('all rows ' + $all.Count + ' | matched ' + $matched + ' | unmatched ' + $unmatched + ' | assets ' + $byAsset.Count + ' | map rows ' + $totalMap)
