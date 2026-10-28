$ErrorActionPreference = 'Stop'
$repo = 'C:\AtomicHeart-AR'
$out = New-Object System.Collections.Generic.List[string]
$rows = Import-Csv (Join-Path $repo 'build\c6\selected_orphans.tsv') -Delimiter "`t"
foreach ($r in $rows) {
    if ([int]$r.orphans -le 0) { continue }
    $out.Add('ASSET ' + $r.asset)
    foreach ($s in ($r.selectedText -split ' \| ')) { $out.Add('  ORPHAN ' + $s) }
}
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\orphans.txt'), $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('lines ' + $out.Count)
