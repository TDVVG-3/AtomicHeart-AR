<#
.SYNOPSIS
  Normalizes trailing whitespace in the master Arabic column (and the union TM).

.DESCRIPTION
  Some English source strings end with a space and the translation preserved it, but the
  locres export/import round-trip used by scripts/build_carrier_locres_pak.ps1 strips
  trailing whitespace, so those rows failed the byte-identical check (15 NewP5 rows in
  batch 1). Trailing whitespace at the very end of a value is invisible in game, so it is
  removed here instead of weakening the round-trip gate. DEC-027.

  Reads/writes: localization/master/atomic-heart-ar.tsv (Arabic column only)
                localization/working/tm.tsv              (arabic column)
  ASCII-only script (KI-021).
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$tmPath     = Join-Path $RepoRoot 'localization\working\tm.tsv'
$utf8       = New-Object Text.UTF8Encoding($false)

$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$fixed = 0
$fixedEnglish = New-Object 'System.Collections.Generic.HashSet[string]'
for ($i = 1; $i -lt $mlines.Count; $i++) {
    if (-not $mlines[$i].Trim()) { continue }
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    if (-not $f[6]) { continue }
    $t = $f[6].TrimEnd(' ', "`t")
    if ($t -cne $f[6]) {
        $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
        $f[6] = $t
        $mlines[$i] = ($f -join "`t")
        [void]$fixedEnglish.Add($f[5])
        $fixed++
        Write-Output ('  trimmed [{0}] {1} ({2} -> {3} chars)' -f $scope, $f[4], ($t.Length + 1), $t.Length)
    }
}
Write-Output ('[trim] master rows trimmed: {0}' -f $fixed)
if (-not $DryRun -and $fixed -gt 0) {
    [IO.File]::WriteAllLines($masterPath, $mlines, $utf8)
    $tmlines = [IO.File]::ReadAllLines($tmPath, [Text.Encoding]::UTF8)
    $tmFixed = 0
    for ($i = 1; $i -lt $tmlines.Count; $i++) {
        if (-not $tmlines[$i].Trim()) { continue }
        $tf = $tmlines[$i] -split "`t"
        if ($tf.Count -lt 2) { continue }
        $t = $tf[1].TrimEnd(' ', "`t")
        if ($t -cne $tf[1]) { $tf[1] = $t; $tmlines[$i] = ($tf -join "`t"); $tmFixed++ }
    }
    [IO.File]::WriteAllLines($tmPath, $tmlines, $utf8)
    Write-Output ('[trim] master written, tm rows trimmed: {0}' -f $tmFixed)
}
