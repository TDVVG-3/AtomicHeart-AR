$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
$repo = 'C:\AtomicHeart-AR'
$uniq = Import-Csv (Join-Path $repo 'build\c6\unique_all.tsv') -Delimiter "`t"
$all = @{}
$dups = 0
$files = @()
$files += Get-ChildItem (Join-Path $repo 'build\c6\ar') -Filter 'chunk_*.fixed.tsv'
$files += Get-ChildItem (Join-Path $repo 'build\c6\ar') -Filter 'extra_*.fixed.tsv'
foreach ($f in $files) {
    $rows = Import-Csv $f.FullName -Delimiter "`t"
    foreach ($r in $rows) {
        if ($all.ContainsKey($r.id)) { $dups++ }
        $all[$r.id] = $r.ar
    }
}
$missing = @($uniq | Where-Object { -not $all.ContainsKey($_.id) })
$out = New-Object System.Collections.Generic.List[string]
$out.Add("id`tru`tar")
foreach ($u in $uniq) {
    if (-not $all.ContainsKey($u.id)) { continue }
    $out.Add(($u.id + "`t" + $u.ru + "`t" + $all[$u.id]))
}
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\translations_all.tsv'), $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('translations ' + ($out.Count - 1) + ' | unique ' + $uniq.Count + ' | missing ' + $missing.Count + ' | dups ' + $dups)
if ($missing.Count -gt 0) { $missing | Select-Object -First 5 | ForEach-Object { Write-Output ('MISSING ' + $_.id) } }
