$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
$repo = 'C:\AtomicHeart-AR'

function Read-RawTsv([string]$path) {
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
    return ,$rows
}

$uniq = Read-RawTsv (Join-Path $repo 'build\c6\unique_unmatched.tsv')
$ar = @{}
$dup = 0
foreach ($n in 1..6) {
    $p = Join-Path $repo ('build\c6\ar\unmatched_' + $n.ToString('0000') + '.tsv')
    foreach ($r in (Read-RawTsv $p)) {
        if ($ar.ContainsKey($r.id)) { $dup++ }
        $ar[$r.id] = $r.ar
    }
}
$missing = @($uniq | Where-Object { -not $ar.ContainsKey($_.id) })
$base = Read-RawTsv (Join-Path $repo 'build\c6\translations_all.tsv')
$out = New-Object System.Collections.Generic.List[string]
$out.Add("id`tru`tar")
$seen = @{}
foreach ($b in $base) { $out.Add(($b.id + "`t" + $b.ru + "`t" + $b.ar)); $seen[$b.id] = $true }
foreach ($u in $uniq) {
    if (-not $ar.ContainsKey($u.id)) { continue }
    $out.Add(($u.id + "`t" + $u.ru + "`t" + $ar[$u.id]))
}
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\translations_full.tsv'), $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('base ' + $base.Count + ' unmatched ' + $uniq.Count + ' ar ' + $ar.Count + ' missing ' + $missing.Count + ' dup ' + $dup + ' full ' + ($out.Count - 1))
