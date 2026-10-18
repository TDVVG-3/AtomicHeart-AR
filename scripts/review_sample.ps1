<#
.SYNOPSIS
  Builds the per-batch AR/EN review sample (DEC-023 step 10): 40 master rows that
  already carry Arabic, chosen as a random-but-deterministic spread, plus the longest
  rows, plus tag-bearing rows. Output: reports/review_sample.md

.DESCRIPTION
  Selection (deterministic, re-runnable):
    20 rows  spread   : sorted by a stable hash of (scope + key + english)
     5 rows  longest  : highest Arabic character count
    15 rows  tagged   : Arabic contains a rich-text tag or a placeholder
  Duplicates are removed by (scope, key, english). Arabic first, English below.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [int]$Total = 40
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$outPath = Join-Path $RepoRoot 'reports\review_sample.md'

$lines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$rows = New-Object System.Collections.Generic.List[object]
$sha1 = [System.Security.Cryptography.SHA1]::Create()
for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    if (-not $f[6].Trim()) { continue }
    $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $seedBytes = [Text.Encoding]::UTF8.GetBytes($scope + '|' + $f[4] + '|' + $f[5])
    $hashHex = -join ($sha1.ComputeHash($seedBytes) | ForEach-Object { $_.ToString('x2') })
    $rows.Add([pscustomobject]@{
        id = $f[0]; scope = $scope; key = $f[4]; en = $f[5]; ar = $f[6]; cat = $f[9]; notes = $f[11]
        arlen = $f[6].Length; hash = $hashHex
        tagged = [bool]($f[6] -match '<[^>]+>|\{[0-9]+\}|%[sdif]')
    })
}

$chosen = New-Object System.Collections.Generic.List[object]
$seen = New-Object 'System.Collections.Generic.HashSet[string]'
function Add-Row($row, $reason) {
    $id = $row.scope + "\u0001" + $row.key + "\u0001" + $row.en
    if ($seen.Contains($id)) { return }
    [void]$seen.Add($id)
    $chosen.Add([pscustomobject]@{ reason = $reason; scope = $row.scope; key = $row.key; cat = $row.cat; en = $row.en; ar = $row.ar; notes = $row.notes })
}
$spreadCount = [int][Math]::Floor($Total / 2)
foreach ($r in ($rows | Sort-Object hash | Select-Object -First $spreadCount)) { Add-Row $r 'spread' }
foreach ($r in ($rows | Sort-Object { -$_.arlen }, hash | Select-Object -First 5)) { Add-Row $r 'longest' }
foreach ($r in ($rows | Where-Object { $_.tagged } | Sort-Object hash)) {
    if ($chosen.Count -ge $Total) { break }
    Add-Row $r 'tagged'
}
foreach ($r in ($rows | Sort-Object hash)) {
    if ($chosen.Count -ge $Total) { break }
    Add-Row $r 'spread'
}

$out = New-Object System.Collections.Generic.List[string]
$out.Add('# AR/EN review sample (pilot)')
$out.Add('')
$out.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$out.Add(('Rows with Arabic available: {0} | sample size: {1}' -f $rows.Count, $chosen.Count))
$out.Add('')
$out.Add('Read each block as: Arabic (what the player sees) then the English source it came from.')
$out.Add('')
$n = 0
foreach ($c in $chosen) {
    $n++
    $out.Add(('### {0}. [{1}] {2}' -f $n, $c.scope, $c.cat))
    $out.Add(('reason: {0} | key: {1} | notes: {2}' -f $c.reason, $c.key, $c.notes))
    $out.Add('')
    $out.Add(('AR: {0}' -f $c.ar))
    $out.Add('')
    $out.Add(('EN: {0}' -f $c.en))
    $out.Add('')
}
[IO.File]::WriteAllLines($outPath, $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('[sample] rows with Arabic {0} | sample {1} | written {2}' -f $rows.Count, $chosen.Count, $outPath)
