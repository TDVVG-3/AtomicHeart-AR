$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
$repo = 'C:\AtomicHeart-AR'
$uniq = Import-Csv (Join-Path $repo 'build\c6\unique_official.tsv') -Delimiter "`t"
$byId = @{}
foreach ($u in $uniq) { $byId[$u.id] = $u }

$all = @{}
$dups = 0
Get-ChildItem (Join-Path $repo 'build\c6\ar') -Filter 'chunk_*.fixed.tsv' | Sort-Object Name | ForEach-Object {
    $rows = Import-Csv $_.FullName -Delimiter "`t"
    foreach ($r in $rows) {
        if ($all.ContainsKey($r.id)) { $dups++ }
        $all[$r.id] = $r.ar
    }
}
$missing = @($byId.Keys | Where-Object { -not $all.ContainsKey($_) })
$out = New-Object System.Collections.Generic.List[string]
$out.Add("id`tru`tar")
foreach ($u in $uniq) {
    if (-not $all.ContainsKey($u.id)) { continue }
    $out.Add(($u.id + "`t" + $u.ru + "`t" + $all[$u.id]))
}
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\translations_official.tsv'), $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('translations ' + ($out.Count - 1) + ' | unique ids ' + $byId.Count + ' | missing ' + $missing.Count + ' | dups ' + $dups)
