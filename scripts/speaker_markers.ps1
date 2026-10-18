<#
.SYNOPSIS
  Speaks-marker evidence: finds &Speaker& tokens in the master English column and reports
  which names exist, how often, and in which scopes, so the display question can be answered
  with facts. Output: reports/speaker_markers.md

.DESCRIPTION
  Looks for two marker shapes used by the game's subtitle text:
    &Name&        speaker labels embedded in a subtitle line
    *0.00-0.08*   timing/segment markers
  Only the English source column is scanned; nothing is modified.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$outPath = Join-Path $RepoRoot 'reports\speaker_markers.md'
$lines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)

$rowsWithSpeaker = 0
$names = @{}
$scopesWithSpeaker = @{}
$rowsWithTiming = 0
$examples = New-Object System.Collections.Generic.List[string]
$translatedWithSpeaker = 0

for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $en = $f[5]; $ar = $f[6]
    $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $m = [regex]::Matches($en, '&([^&\r\n]{1,40}?)&')
    if ($m.Count -gt 0) {
        $rowsWithSpeaker++
        if (-not $scopesWithSpeaker.ContainsKey($scope)) { $scopesWithSpeaker[$scope] = 0 }
        $scopesWithSpeaker[$scope]++
        foreach ($x in $m) {
            $n = $x.Groups[1].Value.Trim()
            if (-not $names.ContainsKey($n)) { $names[$n] = 0 }
            $names[$n]++
        }
        if ($ar.Trim()) {
            $translatedWithSpeaker++
            if ($examples.Count -lt 6) {
                $examples.Add(('scope {0} | key {1}' -f $scope, $f[4]))
                $examples.Add(('   EN: ' + $en.Substring(0, [Math]::Min(150, $en.Length))))
                $examples.Add(('   AR: ' + $ar.Substring(0, [Math]::Min(150, $ar.Length))))
                $arNames = [regex]::Matches($ar, '&([^&\r\n]{1,40}?)&')
                $enList = (@($m | ForEach-Object { $_.Groups[1].Value.Trim() }) | Sort-Object) -join ', '
                $arList = (@($arNames | ForEach-Object { $_.Groups[1].Value.Trim() }) | Sort-Object) -join ', '
                $same = ($enList -eq $arList)
                $examples.Add(('   AR markers present: {0} ; names identical to EN: {1} [{2}]' -f $arNames.Count, $same, $arList))
            }
        }
    }
    if ($en -match '\*[0-9][0-9.\-]*\*') { $rowsWithTiming++ }
}

$r = New-Object System.Collections.Generic.List[string]
$r.Add('# Speaker / timing markers in the English source (evidence for the display question)')
$r.Add('')
$r.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$r.Add(('Master: {0} rows' -f ($lines.Count - 1)))
$r.Add('')
$r.Add('| metric | value |')
$r.Add('|---|---|')
$r.Add(('| rows with an &Speaker& marker | {0} |' -f $rowsWithSpeaker))
$r.Add(('| of those, rows that already carry Arabic | {0} |' -f $translatedWithSpeaker))
$r.Add(('| distinct speaker tokens | {0} |' -f $names.Keys.Count))
$r.Add(('| rows with a *timing* marker | {0} |' -f $rowsWithTiming))
$r.Add('')
$r.Add('## Distinct speaker tokens (count)')
$r.Add('')
$r.Add('| token | occurrences |')
$r.Add('|---|---|')
foreach ($k in ($names.Keys | Sort-Object { -$names[$_] }, { $_ })) { $r.Add(('| {0} | {1} |' -f $k, $names[$k])) }
$r.Add('')
$r.Add('## Scopes that use speaker markers')
$r.Add('')
$r.Add('| scope | rows with a marker |')
$r.Add('|---|---|')
foreach ($k in ($scopesWithSpeaker.Keys | Sort-Object)) { $r.Add(('| {0} | {1} |' -f $k, $scopesWithSpeaker[$k])) }
$r.Add('')
if ($examples.Count -gt 0) {
    $r.Add('## Translated rows that carry markers (already in the master + installed p3)')
    $r.Add('')
    foreach ($e in $examples) { $r.Add('- ' + $e) }
    $r.Add('')
}
[IO.File]::WriteAllLines($outPath, $r, (New-Object Text.UTF8Encoding($false)))

Write-Output ('SPEAKER MARKERS: rows with marker {0} | distinct tokens {1} | rows with timing marker {2} | translated rows with marker {3}' -f $rowsWithSpeaker, $names.Keys.Count, $rowsWithTiming, $translatedWithSpeaker)
Write-Output 'Top tokens:'
foreach ($k in ($names.Keys | Sort-Object { -$names[$_] } | Select-Object -First 20)) { Write-Output ('  {0}  x{1}' -f $k, $names[$k]) }
Write-Output ('report: ' + $outPath)
