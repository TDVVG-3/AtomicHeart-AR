$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$TAB = [char]9
$repo = 'C:\AtomicHeart-AR'
$masterPath = Join-Path $repo 'build\variants\atomic-heart-ar_p12.tsv'
$termsPath = Join-Path $repo 'localization\working\p3_search_terms.tsv'
$labelPath = Join-Path $repo 'localization\working\p3_label.tsv'
$outPath = Join-Path $repo 'reports\p3_name_occurrences.md'
$utf8 = New-Object Text.UTF8Encoding($false)

$terms = @{}
foreach ($line in [IO.File]::ReadAllLines($termsPath, [Text.Encoding]::UTF8) | Select-Object -Skip 1) {
    $f = $line -split $TAB
    if ($f.Count -ge 2) { $terms[$f[0]] = $f[1] }
}
$major = ''
foreach ($line in [IO.File]::ReadAllLines($labelPath, [Text.Encoding]::UTF8) | Select-Object -Skip 1) {
    $f = $line -split $TAB
    if ($f.Count -ge 2 -and $f[0] -ceq 'P-3') { $major = $f[1] }
}
if (-not $terms.ContainsKey('NECHAEV') -or -not $terms.ContainsKey('P3')) { throw 'p3_search_terms.tsv is incomplete' }

$lines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$rows = New-Object System.Collections.Generic.List[object]
$byScope = @{}
$total = 0; $nN = 0; $nM = 0; $nP = 0; $nAny = 0
for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split $TAB
    if ($f.Count -ne 13) { continue }
    $en = $f[5].Trim()
    if ($en -ceq 'P-3') { continue }   # speaker label, not body text
    $ar = $f[6]
    $hasN = $ar.Contains($terms['NECHAEV'])
    $hasM = $hasN -and $major -and $ar.Contains($major)
    $hasP = $ar.Contains($terms['P3'])
    if (-not ($hasN -or $hasP)) { continue }
    $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    if (-not $byScope.ContainsKey($scope)) { $byScope[$scope] = @{ rows = 0; n = 0; m = 0; p = 0; any = 0 } }
    $d = $byScope[$scope]
    $d.rows++; $d.any++
    if ($hasN) { $d.n++ }
    if ($hasM) { $d.m++ }
    if ($hasP) { $d.p++ }
    $total++; if ($hasN) { $nN++ }; if ($hasM) { $nM++ }; if ($hasP) { $nP++ }; $nAny++
    $flags = @()
    if ($hasN) { $flags += 'N' }
    if ($hasM) { $flags += 'M' }
    if ($hasP) { $flags += 'P' }
    $enSnip = $en; if ($enSnip.Length -gt 180) { $enSnip = $enSnip.Substring(0, 177) + '...' }
    $arSnip = $ar.Trim(); if ($arSnip.Length -gt 180) { $arSnip = $arSnip.Substring(0, 177) + '...' }
    $rows.Add([pscustomobject]@{
        line = $i + 1; scope = $scope; key = $f[4]; cat = $f[9]
        flags = ($flags -join '+'); en = $enSnip.Replace('|','/'); ar = $arSnip.Replace('|','/')
    })
}

$r = New-Object System.Collections.Generic.List[string]
$r.Add('# P-3 / Nechaev body-text occurrences')
$r.Add('')
$r.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')))
$r.Add(('Source: `{0}`' -f $masterPath))
$r.Add('')
$r.Add('Exact speaker-label rows whose English source is `P-3` are excluded (1,140 rows; they are rendered as the Major label). Everything below is body text and was not changed by CHANGE 2.')
$r.Add('')
$r.Add('| flag | meaning |')
$r.Add('| --- | --- |')
$r.Add('| N | Arabic contains the Nechaev term (`p3_search_terms.tsv`) |')
$r.Add('| M | Arabic contains both the Major label (`p3_label.tsv`) and the Nechaev term |')
$r.Add('| P | Arabic contains the literal code `P-3` |')
$r.Add('')
$r.Add('## Totals')
$r.Add('')
$r.Add('| metric | rows |')
$r.Add('| --- | ---: |')
$r.Add(('| body-text rows with N, M or P | {0} |' -f $total))
$r.Add(('| N - Nechaev term | {0} |' -f $nN))
$r.Add(('| M - Major label + Nechaev term | {0} |' -f $nM))
$r.Add(('| P - literal `P-3` | {0} |' -f $nP))
$r.Add('')
$r.Add('## Per scope')
$r.Add('')
$r.Add('| scope | rows | N | M | P |')
$r.Add('| --- | ---: | ---: | ---: | ---: |')
foreach ($s in ($byScope.Keys | Sort-Object)) {
    $d = $byScope[$s]
    $r.Add(('| {0} | {1} | {2} | {3} | {4} |' -f $s, $d.rows, $d.n, $d.m, $d.p))
}
$r.Add('')
$r.Add('## Rows')
$r.Add('')
$r.Add('| line | scope | key | flags | category | English (truncated) | Arabic (truncated) |')
$r.Add('| ---: | --- | --- | --- | --- | --- | --- |')
foreach ($x in $rows) {
    $r.Add(('| {0} | {1} | `{2}` | {3} | {4} | {5} | {6} |' -f $x.line, $x.scope, $x.key, $x.flags, $x.cat, $x.en, $x.ar))
}
[IO.File]::WriteAllLines($outPath, $r, $utf8)
Write-Output ('[p3 occurrences] body rows {0} | N {1} | M {2} | P {3} -> {4}' -f $total, $nN, $nM, $nP, $outPath)
