$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$repo = 'C:\AtomicHeart-AR'
$masterPath = Join-Path $repo 'localization\master\atomic-heart-ar.tsv'
$koPath = Join-Path $repo 'localization\working\keep_original.tsv'
$reportPath = Join-Path $repo 'reports\keep_original_upgrades.md'
$utf8 = New-Object Text.UTF8Encoding($false)

$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$ko = [IO.File]::ReadAllLines($koPath, [Text.Encoding]::UTF8)
$pair = @{}
for ($i = 1; $i -lt $ko.Count; $i++) {
    $f = $ko[$i] -split "`t"
    if ($f.Count -lt 5) { continue }
    $pair[$f[1] + '|' + $f[2]] = 1
}

$adds = New-Object System.Collections.Generic.List[string]
$report = New-Object System.Collections.Generic.List[string]
$report.Add('# Keep-original weapon upgrade / recipe NAME rows')
$report.Add('')
$report.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')))
$report.Add('')
$report.Add('DLC and base-game weapon upgrade/recipe names that are inventory/equipment items. Skill/hint names are excluded.')
$report.Add('')
$report.Add('| master line | scope | key | English | category |')
$report.Add('|---:|---|---|---|---|')
for ($i = 1; $i -lt $mlines.Count; $i++) {
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $scope = 'other'
    if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    if ($scope -notmatch '^(NewP5|Tech_dlc\d*)$') { continue }
    $cat = $f[9]
    if ($cat -notin @('UI', 'Unknown', '')) { continue }
    $key = $f[4]
    if ($key -notmatch '(_Name|Recipe_Name)$') { continue }
    if ($key -match 'Hint|Raft|Skill') { continue }
    if ($f[5].Length -gt 80) { continue }
    $sig = $scope + '|' + $key
    if ($pair.ContainsKey($sig)) { continue }
    $pair[$sig] = 1
    $adds.Add($f[0] + "`t" + $scope + "`t" + $key + "`t" + $f[5] + "`tkeep original name")
    $report.Add(('| {0} | {1} | `{2}` | {3} | {4} |' -f ($i + 1), $scope, $key, $f[5], $cat))
}

$out = New-Object System.Collections.Generic.List[string]
for ($i = 0; $i -lt $ko.Count; $i++) { $out.Add($ko[$i]) }
foreach ($a in $adds) { $out.Add($a) }
[IO.File]::WriteAllLines($koPath, $out, $utf8)
[IO.File]::WriteAllLines($reportPath, $report, $utf8)
Write-Output ('[keep-original] added {0} upgrade/recipe NAME rows -> {1}' -f $adds.Count, $koPath)
Write-Output ('[keep-original] upgrade report -> {0}' -f $reportPath)
