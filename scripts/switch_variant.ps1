<#
.SYNOPSIS
  Switches the installed AtomicHeart-AR variant (carrier + font) in one command, with a
  read-only before-snapshot, SHA256s, install-manifest reconciliation and post-install proof.

.DESCRIPTION
  Current installed set after this release: p12_tips_x150 = carrier p12 + font v3 + tips x1.5.

  Variants:
    p11    carrier p11 (text passes: quote pass + tone pass + glossary) + font v3 (unhinted)
    p11b   carrier p11b (every subtitle cue slowed by 15% - timing experiment) + font v3
    p11b3b carrier p11b + font v3b (original vertical metrics / 1.20 em line box)
    p11_3b carrier p11 + font v3b
    p10    rollback to the last known-good delivered set: carrier p10 + font p2_plex

  P4 variants:
    p11c            carrier p11c (subtitle explicit-range end hold) + font v3
    tips_x125       carrier p11 + font v3 + tip/notification durations x1.25
    tips_x150       carrier p11 + font v3 + tip/notification durations x1.5
    p11c_tips_x125  carrier p11c + font v3 + tips x1.25
    p11c_tips_x150  carrier p11c + font v3 + tips x1.5
    p11e            carrier p11e (final singleton page explicit range) + font v3
    p11f            carrier p11f (153 long subtitle pages shortened) + font v3
    p11ef           carrier p11ef (p11e + p11f) + font v3
    p11e_tips_x150  carrier p11e + font v3 + tips x1.5
    p11f_tips_x150  carrier p11f + font v3 + tips x1.5
    p11ef_tips_x150 carrier p11ef + font v3 + tips x1.5

  p12 family (built and gated 2026-10-28):
    p12             clean canonical baseline + CHANGE 1 + CHANGE 2
    p12g            p12 + H1 marker-offset, H2 end-cap, H3 final-page cap/insert
    p12c            p11c + p12 changes + H2 end-cap
    p12e            p11e + p12 changes + H2 end-cap
    p12f            p11f + p12 changes + H2 end-cap
    p12ef           p11ef + p12 changes + H2 end-cap
    <p12 variant>_tips_x150  same carrier + font v3 + tips x1.5

  Optional add-on (built and verified, NOT installed):
    -RuOnly   also install zzz_atomicheart-ar_ruonly_p1_P.pak (Arabic for the
              RU-only cooked dialogue assets). Omit it for the normal set.
              Remove it with: -Variant p11c_tips_x150

  Safety: the only writes are inside Paks\~mods, performed by scripts/install_mod.ps1,
  which deletes a superseded file only when its on-disk SHA256 matches the previous
  manifest. Before installing, the current ~mods set is byte-copied to
  build/install_backup/<variant>_<stamp>. scripts/verify_install.ps1 then proves nothing
  outside ~mods changed. On any install/verify failure the backup is restored exactly and
  the script prints ROLLED BACK TO <previous set>.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p11
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p11b
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p11c_tips_x150
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p11e
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p11f_tips_x150
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p11ef -RuOnly
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12g
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12c
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12e
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12ef
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12g -RuOnly
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p11c_tips_x150
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p10
#>
[CmdletBinding()]
param(
    [ValidateSet('p11', 'p11b', 'p11b3b', 'p11_3b', 'p10', 'p11c', 'tips_x125', 'tips_x150', 'p11c_tips_x125', 'p11c_tips_x150', 'p11e', 'p11f', 'p11ef', 'p11e_tips_x150', 'p11f_tips_x150', 'p11ef_tips_x150', 'p12', 'p12g', 'p12c', 'p12e', 'p12f', 'p12ef', 'p12_tips_x150', 'p12g_tips_x150', 'p12c_tips_x150', 'p12e_tips_x150', 'p12f_tips_x150', 'p12ef_tips_x150')]
    [string]$Variant = 'p11',
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [switch]$RuOnly,
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
    'p11e'            { $carrier = 'p11e';       $font = 'p3_unhinted' }
    'p11f'            { $carrier = 'p11f';       $font = 'p3_unhinted' }
    'p11ef'           { $carrier = 'p11ef';      $font = 'p3_unhinted' }
    'p11e_tips_x150'  { $carrier = 'p11e';       $font = 'p3_unhinted'; $tips = 'x150' }
    'p11f_tips_x150'  { $carrier = 'p11f';       $font = 'p3_unhinted'; $tips = 'x150' }
    'p11ef_tips_x150' { $carrier = 'p11ef';      $font = 'p3_unhinted'; $tips = 'x150' }
    'p12'             { $carrier = 'p12';        $font = 'p3_unhinted' }
    'p12g'            { $carrier = 'p12g';       $font = 'p3_unhinted' }
    'p12c'            { $carrier = 'p12c';       $font = 'p3_unhinted' }
    'p12e'            { $carrier = 'p12e';       $font = 'p3_unhinted' }
    'p12f'            { $carrier = 'p12f';       $font = 'p3_unhinted' }
    'p12ef'           { $carrier = 'p12ef';      $font = 'p3_unhinted' }
    'p12_tips_x150'   { $carrier = 'p12';        $font = 'p3_unhinted'; $tips = 'x150' }
    'p12g_tips_x150'  { $carrier = 'p12g';       $font = 'p3_unhinted'; $tips = 'x150' }
    'p12c_tips_x150'  { $carrier = 'p12c';       $font = 'p3_unhinted'; $tips = 'x150' }
    'p12e_tips_x150'  { $carrier = 'p12e';       $font = 'p3_unhinted'; $tips = 'x150' }
    'p12f_tips_x150'  { $carrier = 'p12f';       $font = 'p3_unhinted'; $tips = 'x150' }
    'p12ef_tips_x150' { $carrier = 'p12ef';      $font = 'p3_unhinted'; $tips = 'x150' }
}
$buildDir = Join-Path $RepoRoot 'build\package'
$carrierFile = "zzz_atomicheart-ar_carrier_koKR_${carrier}_P.pak"
$fontFile = "zzz_atomicheart-ar_font_${font}_P.pak"
$fileSet = @($carrierFile, $fontFile)
if ($tips) { $fileSet += "zzz_atomicheart-ar_tips_${tips}_P.pak" }
if ($RuOnly) { $fileSet += 'zzz_atomicheart-ar_ruonly_p1_P.pak' }
foreach ($n in $fileSet) {
    $p = Join-Path $buildDir $n
    if (-not (Test-Path $p)) { throw "missing build output: $p" }
}

Write-Output ('variant: ' + $Variant + $(if ($RuOnly) { ' + ruonly' } else { '' }))
foreach ($n in $fileSet) {
    $p = Join-Path $buildDir $n
    $h = (Get-FileHash $p -Algorithm SHA256).Hash.ToLower()
    Write-Output ('  {0}  {1} bytes  sha256 {2}' -f $n, (Get-Item $p).Length, $h)
}

if ($DryRun) {
    Write-Output '[DRY RUN] resolved set above; nothing written.'
    return
}

$game = Get-Content (Join-Path $RepoRoot 'config\game.json') -Raw | ConvertFrom-Json
$modsPath = $game.mods_path
$manifestPath = Join-Path $modsPath 'atomic-heart-ar-install-manifest.json'
$previousVariant = 'previous set'
if (Test-Path $manifestPath) {
    $oldManifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
    $bits = @()
    foreach ($f in @($oldManifest.files | ForEach-Object { $_.file })) {
        if ($f -match '^zzz_atomicheart-ar_carrier_koKR_(.+)_P\.pak$') { $bits += ('carrier ' + $Matches[1]) }
        elseif ($f -match '^zzz_atomicheart-ar_font_(.+)_P\.pak$') { $bits += ('font ' + $Matches[1]) }
        elseif ($f -match '^zzz_atomicheart-ar_tips_(.+)_P\.pak$') { $bits += ('tips ' + $Matches[1]) }
        elseif ($f -eq 'zzz_atomicheart-ar_ruonly_p1_P.pak') { $bits += 'ruonly' }
    }
    if ($bits.Count -gt 0) { $previousVariant = ($bits -join ' + ') }
    elseif ($oldManifest.variant) { $previousVariant = [string]$oldManifest.variant }
}

$snapDir = Join-Path $RepoRoot 'build\snapshots'
New-Item -ItemType Directory -Force -Path $snapDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$before = Join-Path $snapDir ('before_' + $Variant + $(if ($RuOnly) { '_ruonly' } else { '' }) + '_' + $stamp + '.json')

& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot 'scripts\snapshot_game_folder.ps1') -RepoRoot $RepoRoot -Out $before
if ($LASTEXITCODE -ne 0) { throw 'snapshot failed; nothing was written' }
Write-Output ('[OK] before-snapshot: ' + $before)

$backupRoot = Join-Path $RepoRoot ('build\install_backup\' + $Variant + $(if ($RuOnly) { '_ruonly' } else { '' }) + '_' + $stamp)
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot 'scripts\backup_mods.ps1') -ModsPath $modsPath -OutDir $backupRoot
if ($LASTEXITCODE -ne 0) { throw 'mods backup failed; nothing was written' }
Write-Output ('[OK] backup of current ~mods: ' + $backupRoot)

function Invoke-Rollback([string]$reason) {
    Write-Output ('[ROLLBACK] ' + $reason)
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot 'scripts\restore_mods.ps1') -ModsPath $modsPath -BackupDir $backupRoot
    if ($LASTEXITCODE -ne 0) {
        Write-Output '[ROLLBACK FAILED] manual restore required from ' + $backupRoot
        exit 3
    }
    Write-Output ('ROLLED BACK TO ' + $previousVariant)
    exit 1
}

$installArgs = @(
    '-NoProfile', '-ExecutionPolicy', 'Bypass',
    '-File', (Join-Path $RepoRoot 'scripts\install_mod.ps1'),
    '-RepoRoot', $RepoRoot,
    '-Carrier', $carrier,
    '-Font', $font,
    '-ModsPath', $modsPath
)
if ($tips) { $installArgs += @('-Tips', $tips) }
if ($RuOnly) { $installArgs += '-RuOnly' }

try {
    & powershell @installArgs
    $installRc = $LASTEXITCODE
} catch {
    Write-Output ('[install] ' + $_.Exception.Message)
    $installRc = 1
}
if ($installRc -ne 0) { Invoke-Rollback 'install failed' }

try {
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot 'scripts\verify_install.ps1') -RepoRoot $RepoRoot -Before $before
    $verifyRc = $LASTEXITCODE
} catch {
    Write-Output ('[verify] ' + $_.Exception.Message)
    $verifyRc = 1
}
if ($verifyRc -ne 0) { Invoke-Rollback 'install verification failed' }

Write-Output ('[DONE] variant {0} installed. Rollback: powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p10' -f $Variant)
Write-Output ('[backup kept] ' + $backupRoot)

