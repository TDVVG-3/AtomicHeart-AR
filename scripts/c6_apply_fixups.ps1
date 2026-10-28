param(
    [Parameter(Mandatory=$true)][string]$In,
    [Parameter(Mandatory=$true)][string]$Out
)
$ErrorActionPreference = 'Stop'
$repo = 'C:\AtomicHeart-AR'
$fix = Import-Csv (Join-Path $repo 'build\c6\fixups.tsv') -Delimiter "`t"
$lines = [IO.File]::ReadAllLines($In, [Text.Encoding]::UTF8)
$res = New-Object System.Collections.Generic.List[string]
foreach ($line in $lines) {
    $t = $line
    foreach ($f in $fix) { $t = $t.Replace($f.from, $f.to) }
    $res.Add($t)
}
[IO.File]::WriteAllLines($Out, $res, (New-Object Text.UTF8Encoding($false)))
Write-Output ('fixed ' + $res.Count + ' lines -> ' + $Out)
