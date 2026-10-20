<#
.SYNOPSIS
  KI-026 evidence: the 30 longest Arabic UI labels, with the English they came from.

.DESCRIPTION
  UI strings must stay short (brief section 5). This report lists the 30 longest
  Arabic cells in category UI, so the layout risk can be reviewed in game.
  Output: reports/ui_length_watch.md

  ASCII-only script; all text comes from the UTF-8 master.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [int]$Top = 30
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$outPath = Join-Path $RepoRoot 'reports\ui_length_watch.md'
$lines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)

$ui = New-Object System.Collections.Generic.List[object]
$count = 0; $over40 = 0; $max = 0
$docs = 0; $docMax = 0
for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    if ($f[6] -notmatch '\p{IsArabic}') { continue }
    if ($f[9] -ne 'UI') { continue }
    $count++
    $len = $f[6].Length
    if ($len -gt $max) { $max = $len }
    # document-style cells (letters, diaries, terminal articles) are not labels: keep them out
    # of the layout watch and count them separately (cycle 015)
    if ($len -gt 200) { $docs++; if ($len -gt $docMax) { $docMax = $len }; continue }
    if ($len -gt 40) { $over40++ }
    $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $ui.Add([pscustomobject]@{ line = $i + 1; scope = $scope; key = $f[4]; en = $f[5]; ar = $f[6]; len = $len })
}

$out = New-Object System.Collections.Generic.List[string]
$out.Add('# UI label length watch (KI-026)')
$out.Add('')
$out.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$out.Add(('UI rows with Arabic: {0} | label rows (<=200 chars): {1} | document-style cells excluded: {2} (longest {3} chars) | labels longer than 40 chars: {4} | longest label: {5}' -f $count, $ui.Count, $docs, $docMax, $over40, (($ui | Measure-Object -Property len -Maximum).Maximum)))
$out.Add('')
$out.Add(('The {0} longest Arabic UI labels (Arabic length in characters, English source below):' -f $Top))
$n = 0
foreach ($r in ($ui | Sort-Object @{ Expression = 'len'; Descending = $true }, @{ Expression = 'scope' } | Select-Object -First $Top)) {
    $n++
    $out.Add('')
    $out.Add(('{0}. [{1}] {2} chars | line {3} | key {4}' -f $n, $r.scope, $r.len, $r.line, $r.key))
    $out.Add(('AR: {0}' -f $r.ar))
    $out.Add(('EN: {0}' -f $r.en))
}
[IO.File]::WriteAllLines($outPath, $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('[ui-length] UI rows {0} | >40 chars {1} | longest {2} | written {3}' -f $count, $over40, $max, $outPath)
