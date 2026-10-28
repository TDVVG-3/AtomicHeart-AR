$ErrorActionPreference = 'Stop'
$repo = 'C:\AtomicHeart-AR'

function Read-TsvRaw([string]$path) {
    $lines = [IO.File]::ReadAllLines($path, [Text.Encoding]::UTF8)
    $head = $lines[0] -split "`t"
    $rows = New-Object System.Collections.Generic.List[object]
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Length -eq 0) { continue }
        $c = $lines[$i] -split "`t"
        $o = [ordered]@{}
        for ($j = 0; $j -lt $head.Count; $j++) { $o[$head[$j]] = if ($j -lt $c.Count) { $c[$j] } else { '' } }
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

$trans = Read-TsvRaw (Join-Path $repo 'build\c6\translations_all.tsv')
$byNorm = @{}
foreach ($t in $trans) { $byNorm[(Norm $t.ru)] = $t.ar }

$all = Read-TsvRaw (Join-Path $repo 'build\c6\all_strings.tsv')
$out = New-Object System.Collections.Generic.List[string]
$out.Add("asset`tkind`tfield`tlen`ttext_b64`ttext_escaped")
$byAsset = @{}
$total = 0
foreach ($r in $all) {
    $t = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($r.text_b64))
    if ($byNorm.ContainsKey((Norm $t))) { continue }
    $total++
    $out.Add(($r.asset + "`t" + $r.kind + "`t" + $r.field + "`t" + $t.Length + "`t" + $r.text_b64 + "`t" + $r.text_escaped))
    $k = $r.asset
    if (-not $byAsset.ContainsKey($k)) { $byAsset[$k] = 0 }
    $byAsset[$k]++
}
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\unmatched_all.tsv'), $out, (New-Object Text.UTF8Encoding($false)))
$sum = New-Object System.Collections.Generic.List[string]
$sum.Add("asset`tunmatched")
foreach ($k in ($byAsset.Keys | Sort-Object)) { $sum.Add(($k + "`t" + $byAsset[$k])) }
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\unmatched_by_asset.tsv'), $sum, (New-Object Text.UTF8Encoding($false)))
Write-Output ('unmatched ' + $total + ' assets ' + $byAsset.Count)
