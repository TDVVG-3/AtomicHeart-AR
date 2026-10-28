$ErrorActionPreference = 'Stop'
$repo = 'C:\AtomicHeart-AR'
$src = Join-Path $repo 'build\c6\unique_unmatched.tsv'
$lines = [IO.File]::ReadAllLines($src, [Text.Encoding]::UTF8)
# Clear speakers column (index 3) to avoid wrong attributions.
for ($i = 1; $i -lt $lines.Count; $i++) {
    $c = $lines[$i] -split "`t"
    if ($c.Count -ge 4) { $c[3] = '' }
    $lines[$i] = ($c -join "`t")
}
[IO.File]::WriteAllLines($src, $lines, (New-Object Text.UTF8Encoding($false)))

$dir = Join-Path $repo 'build\c6\chunks_unmatched'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
Remove-Item (Join-Path $dir '*.tsv') -Force -ErrorAction SilentlyContinue
$size = 300
$n = 0
for ($start = 1; $start -lt $lines.Count; $start += $size) {
    $n++
    $end = [Math]::Min($start + $size - 1, $lines.Count - 1)
    $chunk = New-Object System.Collections.Generic.List[string]
    $chunk.Add($lines[0])
    for ($i = $start; $i -le $end; $i++) { $chunk.Add($lines[$i]) }
    $name = 'chunk_' + $n.ToString('0000') + '.tsv'
    [IO.File]::WriteAllLines((Join-Path $dir $name), $chunk, (New-Object Text.UTF8Encoding($false)))
    Write-Output ($name + ' rows ' + ($chunk.Count - 1))
}
Write-Output ('chunks ' + $n)
