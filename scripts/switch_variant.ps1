<#
.SYNOPSIS
  Switches the installed AtomicHeart-AR variant (carrier + font) in one command, with a
  read-only before-snapshot, SHA256s, install-manifest reconciliation and post-install proof.

.DESCRIPTION
  Variants:
    p11    carrier p11 (text passes: quote pass + tone pass + glossary) + font v3 (unhinted)
    p11b   carrier p11b (every subtitle cue slowed by 15% - timing experiment) + font v3
    p11b3b carrier p11b + font v3b (original vertical metrics / 1.20 em line box)
    p11_3b carrier p11 + font v3b
    p10    rollback to the last known-good delivered set: carrier p10 + font p2_plex

  P4 variants (built, NOT installed during the current A/B test):
    p11c            carrier p11c (subtitle explicit-range end hold) + font v3
    tips_x125       carrier p11 + font v3 + tip/notification durations x1.25
    tips_x150       carrier p11 + font v3 + tip/notification durations x1.5
    p11c_tips_x125  carrier p11c + font v3 + tips x1.25
    p11c_tips_x150  carrier p11c + font v3 + tips x1.5

  Safety: the only writes are inside Paks\~mods, performed by scripts/install_mod.ps1,
  which deletes a superseded file only when its on-disk SHA256 matches the previous
  manifest. scripts/verify_install.ps1 then proves nothing outside ~mods changed.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p11
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p11b
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p11c_tips_x150
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p10
#>
[CmdletBinding()]
param(
    [ValidateSet('p11', 'p11b', 'p11b3b', 'p11_3b', 'p10', 'p11c', 'tips_x125', 'tips_x150', 'p11c_tips_x125', 'p11c_tips_x150')]
    [string]$Variant = 'p11',
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

$carrier = ''
$font = ''
$tips = ''
switch ($Variant) {
    'p11'            { $carrier = 'p11';        $font = 'p3_unhinted' }
    'p11b'           { $carrier = 'p11b_retime'; $font = 'p3_unhinted' }
    'p11b3b'         { $carrier = 'p11b_retime'; $font = 'p3b_linemetrics' }
    'p11_3b'         { $carrier = 'p11';        $font = 'p3b_linemetrics' }
    'p10'            { $carrier = 'p10';        $font = 'p2_plex' }
    'p11c'           { $carrier = 'p11c';       $font = 'p3_unhinted' }
    'tips_x125'      { $carrier = 'p11';        $font = 'p3_unhinted'; $tips = 'x125' }
    'tips_x150'      { $carrier = 'p11';        $font = 'p3_unhinted'; $tips = 'x150' }
    'p11c_tips_x125' { $carrier = 'p11c';       $font = 'p3_unhinted'; $tips = 'x125' }
    'p11c_tips_x150' { $carrier = 'p11c';       $font = 'p3_unhinted'; $tips = 'x150' }
}
$buildDir = Join-Path $RepoRoot 'build\package'
$carrierFile = "zzz_atomicheart-ar_carrier_koKR_${carrier}_P.pak"
$fontFile = "zzz_atomicheart-ar_font_${font}_P.pak"
$fileSet = @($carrierFile, $fontFile)
if ($tips) { $fileSet += "zzz_atomicheart-ar_tips_${tips}_P.pak" }
foreach ($n in $fileSet) {
    $p = Join-Path $buildDir $n
    if (-not (Test-Path $p)) { throw "missing build output: $p" }
}

Write-Output ('variant: ' + $Variant)
foreach ($n in $fileSet) {
    $p = Join-Path $buildDir $n
    $h = (Get-FileHash $p -Algorithm SHA256).Hash.ToLower()
    Write-Output ('  {0}  {1} bytes  sha256 {2}' -f $n, (Get-Item $p).Length, $h)
}

$snapDir = Join-Path $RepoRoot 'build\snapshots'
New-Item -ItemType Directory -Force -Path $snapDir | Out-Null
$before = Join-Path $snapDir ('before_' + $Variant + '_' + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.json')

if ($DryRun) {
    Write-Output '[DRY RUN] would snapshot, install and verify; nothing written.'
    return
}

& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot 'scripts\snapshot_game_folder.ps1') -RepoRoot $RepoRoot -Out $before
if ($LASTEXITCODE -ne 0) { throw 'snapshot failed' }
Write-Output ('[OK] before-snapshot: ' + $before)

& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot 'scripts\install_mod.ps1') -RepoRoot $RepoRoot -Carrier $carrier -Font $font -Tips $tips
if ($LASTEXITCODE -ne 0) { throw 'install failed' }

& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot 'scripts\verify_install.ps1') -RepoRoot $RepoRoot -Before $before
if ($LASTEXITCODE -ne 0) { throw 'install verification failed' }

Write-Output ('[DONE] variant {0} installed. Rollback: powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p10' -f $Variant)
