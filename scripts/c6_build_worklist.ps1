$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
$repo = 'C:\AtomicHeart-AR'
$rows = Import-Csv (Join-Path $repo 'build\c6\collected.tsv') -Delimiter "`t"
$scope = Import-Csv (Join-Path $repo 'build\c6\scope_analysis.tsv') -Delimiter "`t"

# triggered set: asset + text (scope file text is flattened same as collected)
$trig = @{}
foreach ($s in $scope) { if ($s.triggered -eq 'True') { $trig[$s.asset + "\u0001" + $s.text] = $true } }

$byText = [ordered]@{}
foreach ($r in $rows) {
    $t = $r.text
    if (-not $byText.Contains($t)) {
        $byText[$t] = [pscustomobject]@{
            text = $t
            category = $r.category
            speakers = New-Object System.Collections.Generic.HashSet[string]
            assets = New-Object System.Collections.Generic.HashSet[string]
            firstAsset = $r.asset
            firstKey = $r.key
            markers = $r.markers
            official = $false
            occurrences = 0
        }
    }
    $o = $byText[$t]
    $o.occurrences++
    [void]$o.assets.Add($r.asset)
    if ($r.speaker) { [void]$o.speakers.Add($r.speaker) }
    if ($trig.ContainsKey($r.asset + "\u0001" + $r.text)) { $o.official = $true }
}

$items = @($byText.Values | Sort-Object firstAsset, firstKey)
$out = New-Object System.Collections.Generic.List[string]
$out.Add("id`tru`tcategory`tspeakers`tassets_count`tfirst_asset`tfirst_key`tmarkers`tchars`tofficial")
$i = 0
foreach ($o in $items) {
    $i++
    $id = 'C6U' + $i.ToString('00000')
    $sp = (($o.speakers | Sort-Object) -join ';')
    $out.Add(($id + "`t" + $o.text + "`t" + $o.category + "`t" + $sp + "`t" + $o.assets.Count + "`t" + $o.firstAsset + "`t" + $o.firstKey + "`t" + $o.markers + "`t" + $o.text.Length + "`t" + $o.official))
}
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\unique_all.tsv'), $out, (New-Object Text.UTF8Encoding($false)))
$out2 = New-Object System.Collections.Generic.List[string]
$out2.Add($out[0])
foreach ($line in $out | Select-Object -Skip 1) { if ($line -match "`tTrue$") { $out2.Add($line) } }
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\unique_official.tsv'), $out2, (New-Object Text.UTF8Encoding($false)))
Write-Output ('unique all ' + ($out.Count - 1) + ' | official ' + ($out2.Count - 1))
