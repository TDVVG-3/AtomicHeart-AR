<#
.SYNOPSIS
  Scans every .pak in the game's Paks folder using repak and catalogs:
    - all localization resources (.locres / .locmeta)
    - all font candidates (.ttf/.otf/.ufont/Font assets)
    - all StringTable / DataTable candidates
  and writes aggregated reports to reports/.

.DESCRIPTION
  Read-only. Uses tools/bin/repak/repak.exe. Never writes to the game folder.
  Outputs:
    reports/localization_candidates.txt
    reports/font_candidates.txt
    reports/asset_candidates.txt
    reports/pak_index_summary.txt
#>
[CmdletBinding()]
param(
    [string]$GamePath = 'C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart',
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)

$ErrorActionPreference = 'Stop'
$paksPath = Join-Path $GamePath 'AtomicHeart\Content\Paks'
$repak = Join-Path $RepoRoot 'tools\bin\repak\repak.exe'
$reportsDir = Join-Path $RepoRoot 'reports'
if (-not (Test-Path $repak)) { throw "repak not found at $repak" }

$paks = Get-ChildItem $paksPath -Filter '*.pak' | Sort-Object Name

$locLines = New-Object System.Collections.Generic.List[string]
$fontLines = New-Object System.Collections.Generic.List[string]
$assetLines = New-Object System.Collections.Generic.List[string]
$summary = New-Object System.Collections.Generic.List[string]

$locLines.Add('# Localization candidates (.locres / .locmeta) found by repak list')
$locLines.Add('# Generated (UTC): ' + (Get-Date).ToUniversalTime().ToString('o'))
$locLines.Add('')
$fontLines.Add('# Font candidates found by repak list')
$fontLines.Add('# Generated (UTC): ' + (Get-Date).ToUniversalTime().ToString('o'))
$fontLines.Add('')
$assetLines.Add('# StringTable / DataTable / Subtitle / Dialogue asset candidates')
$assetLines.Add('# Generated (UTC): ' + (Get-Date).ToUniversalTime().ToString('o'))
$assetLines.Add('')

$summary.Add('# Pak index summary (repak info)')
$summary.Add('# Generated (UTC): ' + (Get-Date).ToUniversalTime().ToString('o'))
$summary.Add('')

foreach ($pak in $paks) {
    Write-Host ("[SCAN] {0}" -f $pak.Name)
    $info = & $repak info $pak.FullName 2>&1 | Out-String
    $summary.Add('=== ' + $pak.Name + ' ===')
    $summary.Add($info.Trim())
    $summary.Add('')

    $files = & $repak list $pak.FullName 2>&1 | Out-String
    $entries = $files -split "`r?`n" | Where-Object { $_ -match '\S' }
    Write-Host ("       {0} entries" -f $entries.Count)

    foreach ($e in $entries) {
        if ($e -match '\.locres$|\.locmeta$') {
            $locLines.Add(('{0} :: {1}' -f $pak.Name, $e))
        }
        if ($e -match '\.ttf$|\.otf$|\.ufont$|/Fonts?/|Font[A-Za-z0-9_]*\.uasset$|\.woff') {
            $fontLines.Add(('{0} :: {1}' -f $pak.Name, $e))
        }
        if ($e -match 'StringTable|DataTable|Subtitle|Dialog|\.locres$|/Text/|/T_.*Text|GameplayTags') {
            $assetLines.Add(('{0} :: {1}' -f $pak.Name, $e))
        }
    }
}

Set-Content -Path (Join-Path $reportsDir 'localization_candidates.txt') -Value $locLines -Encoding UTF8
Set-Content -Path (Join-Path $reportsDir 'font_candidates.txt') -Value $fontLines -Encoding UTF8
Set-Content -Path (Join-Path $reportsDir 'asset_candidates.txt') -Value $assetLines -Encoding UTF8
Set-Content -Path (Join-Path $reportsDir 'pak_index_summary.txt') -Value $summary -Encoding UTF8

Write-Host ''
Write-Host ("[DONE] locres/locmeta lines: {0}" -f ($locLines.Count - 3))
Write-Host ("[DONE] font candidate lines: {0}" -f ($fontLines.Count - 3))
Write-Host ("[DONE] asset candidate lines: {0}" -f ($assetLines.Count - 3))
