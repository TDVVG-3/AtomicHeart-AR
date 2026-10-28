$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$repo = 'C:\AtomicHeart-AR'
$masterPath = Join-Path $repo 'localization\master\atomic-heart-ar.tsv'
$koPath = Join-Path $repo 'localization\working\keep_original.tsv'
$reportPath = Join-Path $repo 'reports\keep_original_additions.md'
$utf8 = New-Object Text.UTF8Encoding($false)

$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$ko = [IO.File]::ReadAllLines($koPath, [Text.Encoding]::UTF8)

$enSet = @{}
$pair = @{}
for ($i = 1; $i -lt $ko.Count; $i++) {
    $f = $ko[$i] -split "`t"
    if ($f.Count -lt 5) { continue }
    $enSet[$f[3]] = 1
    $pair[$f[1] + '|' + $f[2]] = 1
}

$adds = New-Object System.Collections.Generic.List[string]
$report = New-Object System.Collections.Generic.List[string]
$report.Add('# Keep-original additions')
$report.Add('')
$report.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')))
$report.Add('')
$report.Add('Duplicate UI/asset labels whose English cell exactly matches a known item name. They are added to `keep_original.tsv` so the carrier copies the English name instead of the Arabic translation.')
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
    $en = $f[5].Trim()
    if (-not $enSet.ContainsKey($en)) { continue }
    if ($f[4] -match 'Desc|desc|Description|ShortDescription|Tooltip|Hint') { continue }
    $sig = $scope + '|' + $f[4]
    if ($pair.ContainsKey($sig)) { continue }
    $pair[$sig] = 1
    $adds.Add($f[0] + "`t" + $scope + "`t" + $f[4] + "`t" + $en + "`tkeep original name")
    $report.Add(('| {0} | {1} | `{2}` | {3} | {4} |' -f ($i + 1), $scope, $f[4], $en, $cat))
}

$out = New-Object System.Collections.Generic.List[string]
for ($i = 0; $i -lt $ko.Count; $i++) { $out.Add($ko[$i]) }
foreach ($a in $adds) { $out.Add($a) }
[IO.File]::WriteAllLines($koPath, $out, $utf8)
[IO.File]::WriteAllLines($reportPath, $report, $utf8)
Write-Output ('[keep-original] added {0} duplicate UI item-name rows -> {1}' -f $adds.Count, $koPath)
Write-Output ('[keep-original] additions report -> {0}' -f $reportPath)
