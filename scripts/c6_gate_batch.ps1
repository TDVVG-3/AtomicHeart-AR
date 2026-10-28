param([string]$Chunks)
$ErrorActionPreference = 'Stop'
$repo = 'C:\AtomicHeart-AR'
$list = $Chunks -split ',' | ForEach-Object { [int]$_ }
foreach ($n in $list) {
    $nn = $n.ToString('0000')
    $in = Join-Path $repo ('build\c6\ar\chunk_' + $nn + '.tsv')
    if (-not (Test-Path $in)) { Write-Output ($nn + ' MISSING'); continue }
    $fixed = Join-Path $repo ('build\c6\ar\chunk_' + $nn + '.fixed.tsv')
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo 'scripts\c6_apply_fixups.ps1') -In $in -Out $fixed | Out-Null
    $gate = Join-Path $repo ('build\c6\ar\chunk_' + $nn + '.gate.txt')
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo 'scripts\c6_gate_chunk.ps1') -Chunk (Join-Path $repo ('build\c6\chunks_official\chunk_' + $nn + '.tsv')) -Ar $fixed -Out $gate | Out-Null
    $first = (Get-Content $gate -TotalCount 2)[1]
    Write-Output ($nn + ' | ' + $first)
}
