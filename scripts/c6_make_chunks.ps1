$ErrorActionPreference = 'Stop'
$repo = 'C:\AtomicHeart-AR'
$size = 300
$src = Join-Path $repo 'build\c6\unique_official.tsv'
$rows = Import-Csv $src -Delimiter "`t"
$dir = Join-Path $repo 'build\c6\chunks_official'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
Remove-Item (Join-Path $dir 'chunk_*.tsv') -Force -ErrorAction SilentlyContinue
$n = 0; $i = 0
$batch = New-Object System.Collections.Generic.List[string]
$batch.Add("id`tru`tcategory`tspeakers`tasset`tmarkers")
foreach ($r in $rows) {
    $short = ($r.first_asset -split '/')[-1]
    $batch.Add(($r.id + "`t" + $r.ru + "`t" + $r.category + "`t" + $r.speakers + "`t" + $short + "`t" + $r.markers))
    $i++
    if ($i -ge $size) {
        $n++
        [IO.File]::WriteAllLines((Join-Path $dir ('chunk_' + $n.ToString('0000') + '.tsv')), $batch, (New-Object Text.UTF8Encoding($false)))
        $batch = New-Object System.Collections.Generic.List[string]
        $batch.Add("id`tru`tcategory`tspeakers`tasset`tmarkers")
        $i = 0
    }
}
if ($i -gt 0) {
    $n++
    [IO.File]::WriteAllLines((Join-Path $dir ('chunk_' + $n.ToString('0000') + '.tsv')), $batch, (New-Object Text.UTF8Encoding($false)))
}
Write-Output ('chunks: ' + $n + ' | rows: ' + $rows.Count)
