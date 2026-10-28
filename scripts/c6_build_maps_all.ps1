$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
$repo = 'C:\AtomicHeart-AR'
$col = Import-Csv (Join-Path $repo 'build\c6\collected.tsv') -Delimiter "`t"
$translations = Import-Csv (Join-Path $repo 'build\c6\translations_all.tsv') -Delimiter "`t"
$byText = @{}
foreach ($t in $translations) { $byText[$t.ru] = $t.ar }

$mapDir = Join-Path $repo 'build\c6\maps_all'
New-Item -ItemType Directory -Force -Path $mapDir | Out-Null
Remove-Item (Join-Path $mapDir '*.tsv') -Force -ErrorAction SilentlyContinue

$byAsset = [ordered]@{}
foreach ($r in $col) {
    if (-not $byAsset.Contains($r.asset)) { $byAsset[$r.asset] = New-Object System.Collections.Generic.List[object] }
    $byAsset[$r.asset].Add($r)
}

$manifest = New-Object System.Collections.Generic.List[string]
$manifest.Add("idx`tasset`tmap`trows`tdistinct_targets")
$idx = 0
$missingTrans = 0
$totalMap = 0
foreach ($asset in $byAsset.Keys) {
    $idx++
    $rows = $byAsset[$asset]
    $seen = @{}
    $map = New-Object System.Collections.Generic.List[string]
    $map.Add("kind`tfield`told_b64`tnew_b64")
    foreach ($r in $rows) {
        if (-not $byText.ContainsKey($r.text)) { $missingTrans++; continue }
        $k = $r.kind + "\u0001" + $r.field + "\u0001" + $r.text
        if ($seen.ContainsKey($k)) { continue }
        $seen[$k] = $true
        $oldB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($r.text))
        $newB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($byText[$r.text]))
        $map.Add(($r.kind + "`t" + $r.field + "`t" + $oldB64 + "`t" + $newB64))
    }
    $name = $idx.ToString('0000') + '.tsv'
    [IO.File]::WriteAllLines((Join-Path $mapDir $name), $map, (New-Object Text.UTF8Encoding($false)))
    $totalMap += ($map.Count - 1)
    $manifest.Add(($idx.ToString('0000') + "`t" + $asset + "`t" + $name + "`t" + $rows.Count + "`t" + ($map.Count - 1)))
}
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\maps_all_manifest.tsv'), $manifest, (New-Object Text.UTF8Encoding($false)))
Write-Output ('assets ' + $byAsset.Count + ' | map rows ' + $totalMap + ' | missing translations ' + $missingTrans)
