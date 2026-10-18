<#
.SYNOPSIS
  Regenerates localization/references/AR_EN_REFERENCE.md (DEC-023 step 9, style guide 9.1).

.DESCRIPTION
  Lists ONLY master rows whose Arabic column is non-empty. Arabic first, English below,
  grouped by scope, with a header table and per-scope counts. Deterministic and re-runnable.

  ASCII-only rule does NOT apply to this reference file: it must show the Arabic so a
  reviewer can read the actual text. The file is written as UTF-8 (no BOM).
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$outPath = Join-Path $RepoRoot 'localization\references\AR_EN_REFERENCE.md'

$lines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$byScope = [ordered]@{}
$total = 0
$totalUnique = New-Object 'System.Collections.Generic.HashSet[string]'
for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    if (-not $f[6].Trim()) { continue }
    $file = $f[2]; $scope = 'other'
    if ($file -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    if (-not $byScope.Contains($scope)) { $byScope[$scope] = New-Object System.Collections.Generic.List[object] }
    $byScope[$scope].Add([pscustomobject]@{ key = $f[4]; en = $f[5]; ar = $f[6]; cat = $f[9]; notes = $f[11] })
    $total++
    [void]$totalUnique.Add($f[5])
}

$r = New-Object System.Collections.Generic.List[string]
$r.Add('# AR <-> EN reference (rows that already carry Arabic)')
$r.Add('')
$r.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$r.Add(('Cycles: translation program, DRAFT rows only.'))
$r.Add('')
$r.Add('Rule: this file lists ONLY master rows whose Arabic column is non-empty.')
$r.Add('Arabic is shown FIRST, the English source BELOW it, followed by the locres key.')
$r.Add('')
$r.Add('| rows with Arabic | unique English strings | scopes |')
$r.Add('|---|---|---|')
$r.Add(('| {0} | {1} | {2} |' -f $total, $totalUnique.Count, $byScope.Keys.Count))
$r.Add('')
$r.Add('| scope | rows |')
$r.Add('|---|---|')
foreach ($k in $byScope.Keys) { $r.Add(('| {0} | {1} |' -f $k, $byScope[$k].Count)) }
$r.Add('')

foreach ($k in $byScope.Keys) {
    $r.Add(('## {0} ({1} rows)' -f $k, $byScope[$k].Count))
    $r.Add('')
    foreach ($row in $byScope[$k]) {
        $r.Add(('- `{0}`  [{1}] {2}' -f $row.key, $row.cat, $row.notes))
        $r.Add(('  - AR: {0}' -f $row.ar))
        $r.Add(('  - EN: {0}' -f $row.en))
    }
    $r.Add('')
}
$r.Add('## How to regenerate')
$r.Add('')
$r.Add('    powershell -NoProfile -ExecutionPolicy Bypass -File scripts\build_reference.ps1')
$r.Add('')
[IO.File]::WriteAllLines($outPath, $r, (New-Object Text.UTF8Encoding($false)))
Write-Output ('[reference] rows with Arabic: {0} | unique English: {1} | scopes: {2}' -f $total, $totalUnique.Count, $byScope.Keys.Count)
Write-Output ('[reference] written: {0} ({1} bytes)' -f $outPath, (Get-Item $outPath).Length)
