<#
.SYNOPSIS
  Workstream B (P3 shimmer): font pak v3 / v3b, built from IBM Plex Sans Arabic with
  the TrueType hinting program removed (scripts/strip_font_hinting.ps1).

.DESCRIPTION
  Same six faces, same face -> weight mapping as the installed v2 pak
  (build_fontpak_p2_plex.ps1), so the only difference is the payload:

    v3  (default) : fpgm/prep removed, head.flags 0x0003  (H4: unhinted, like the
                    original CFF faces which carry no hint program at all)
    v3b (experiment): v3 + original vertical metrics (hhea/OS/2 800/-200/200,
                    win 800/200) so the line box is 1.20 em like BlenderPro
                    instead of Plex's 1.50 em (H5)

  Coverage gate: the probe report for the exact payload file names must show
  Latin-Basic 95/95 and Arabic-core 42/42 (and Cyrillic/Hangul reporting follows the
  same exemption rule as v2; pass -AllowMissingCyrillicHangul after review).

  The output pak is written to build/package and NOT installed.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\build_fontpak_p3_unhinted.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\build_fontpak_p3_unhinted.ps1 -FontSet v3b
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [ValidateSet('v3', 'v3b')][string]$FontSet = 'v3',
    [string]$PakOut,
    [string]$Probe,
    [switch]$AllowMissingCyrillicHangul
)
$ErrorActionPreference = 'Stop'
if (-not $PakOut) {
    if ($FontSet -eq 'v3') { $PakOut = Join-Path $RepoRoot 'build\package\zzz_atomicheart-ar_font_p3_unhinted_P.pak' }
    else { $PakOut = Join-Path $RepoRoot 'build\package\zzz_atomicheart-ar_font_p3b_linemetrics_P.pak' }
}
if (-not $Probe) { $Probe = Join-Path $RepoRoot 'build\fonts\probe_v3.txt' }
$repak = Join-Path $RepoRoot 'tools\bin\repak\repak.exe'
$fontRoot = Join-Path $RepoRoot ('build\fonts\' + $FontSet)

if ($FontSet -eq 'v3') {
    $map = @(
        @{ face = 'AtomicHeart/Content/Development/UI/Fonts/BlenderPro-Book.ufont';    ttf = 'IBMPlexSansArabic-Regular.unhinted.ttf' },
        @{ face = 'AtomicHeart/Content/Development/UI/Fonts/BlenderPro-Medium.ufont';  ttf = 'IBMPlexSansArabic-Medium.unhinted.ttf' },
        @{ face = 'AtomicHeart/Content/Development/UI/Fonts/BlenderPro-Bold.ufont';    ttf = 'IBMPlexSansArabic-Bold.unhinted.ttf' },
        @{ face = 'AtomicHeart/Content/Development/UI/Fonts/BrutalType.ufont';         ttf = 'IBMPlexSansArabic-Bold.unhinted.ttf' },
        @{ face = 'AtomicHeart/Content/Development/NTD/Fonts/Gotham-BookItalic.ufont'; ttf = 'IBMPlexSansArabic-Regular.unhinted.ttf' },
        @{ face = 'AtomicHeart/Content/Development/NTD/Fonts/Gotham-Black.ufont';      ttf = 'IBMPlexSansArabic-Bold.unhinted.ttf' }
    )
} else {
    $map = @(
        @{ face = 'AtomicHeart/Content/Development/UI/Fonts/BlenderPro-Book.ufont';    ttf = 'IBMPlexSansArabic-Regular.precomputed.ttf' },
        @{ face = 'AtomicHeart/Content/Development/UI/Fonts/BlenderPro-Medium.ufont';  ttf = 'IBMPlexSansArabic-Medium.precomputed.ttf' },
        @{ face = 'AtomicHeart/Content/Development/UI/Fonts/BlenderPro-Bold.ufont';    ttf = 'IBMPlexSansArabic-Bold.precomputed.ttf' },
        @{ face = 'AtomicHeart/Content/Development/UI/Fonts/BrutalType.ufont';         ttf = 'IBMPlexSansArabic-Bold.precomputed.ttf' },
        @{ face = 'AtomicHeart/Content/Development/NTD/Fonts/Gotham-BookItalic.ufont'; ttf = 'IBMPlexSansArabic-Regular.precomputed.ttf' },
        @{ face = 'AtomicHeart/Content/Development/NTD/Fonts/Gotham-Black.ufont';      ttf = 'IBMPlexSansArabic-Bold.precomputed.ttf' }
    )
}

if (-not (Test-Path $Probe)) { throw "probe report missing: $Probe (run scripts/probe_font_blocks.ps1 on the $FontSet payloads)" }
function Get-BlockCount($lines, [string]$block) {
    $rx = '^\s*' + [regex]::Escape($block) + ':\s*(\d+)'
    foreach ($l in $lines) { if ($l -match $rx) { return [int]$Matches[1] } }
    throw "block $block count not found in probe output"
}
foreach ($m in $map) {
    $fontLines = @(); $hit = $false
    foreach ($l in (Get-Content $Probe)) {
        if ($l -like ('### ' + $m.ttf + '*')) { $hit = $true; $fontLines = @(); continue }
        if ($hit) { if ($l -match '^\s{4}\S') { $fontLines += $l } elseif ($l -match '^###') { break } }
    }
    if (-not $hit) { throw "font not probed: $($m.ttf) (add it to the probe -Fonts list and rerun)" }
    $latin = Get-BlockCount $fontLines 'Latin-Basic'
    $arabic = Get-BlockCount $fontLines 'Arabic-core'
    $cyr = Get-BlockCount $fontLines 'Cyrillic'
    $hSyll = Get-BlockCount $fontLines 'Hangul-Syllables'
    if ($latin -lt 95) { throw "Latin-Basic below 95 for $($m.ttf): $latin" }
    if ($arabic -lt 42) { throw "Arabic-core below 42 for $($m.ttf): $arabic" }
    if ($cyr -eq 0 -and -not $AllowMissingCyrillicHangul) { throw "Cyrillic ABSENT for $($m.ttf) - pass -AllowMissingCyrillicHangul after human review" }
    if ($hSyll -eq 0 -and -not $AllowMissingCyrillicHangul) { throw "Hangul-Syllables ABSENT for $($m.ttf) - pass -AllowMissingCyrillicHangul after human review" }
    Write-Host ("[OK] $($m.ttf): Latin {0}/95, Arabic {1}/42, Cyrillic {2}, Hangul {3}" -f $latin, $arabic, $cyr, $hSyll)
}
Write-Host ("[OK] coverage gate: all $FontSet payloads FULL (Latin-Basic 95/95, Arabic 42/42)")

$work = Join-Path $RepoRoot ('build\staging\font_' + $FontSet)
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
foreach ($m in $map) {
    $src = Join-Path $fontRoot $m.ttf
    if (-not (Test-Path $src)) { throw "payload missing: $src (run scripts/strip_font_hinting.ps1 first)" }
    $payload = [System.IO.File]::ReadAllBytes($src)
    $dest = Join-Path $work ('modpakfont\' + ($m.face -replace '/', '\'))
    New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
    [System.IO.File]::WriteAllBytes($dest, $payload)
    Write-Host ("[OK] {0}  <-  {1} ({2} bytes)" -f $m.face, $m.ttf, $payload.Length)
}

New-Item -ItemType Directory -Force -Path (Split-Path $PakOut -Parent) | Out-Null
& $repak pack --version V11 --mount-point '../../../' (Join-Path $work 'modpakfont') $PakOut 2>&1 | Select-Object -Last 2
if (-not (Test-Path $PakOut)) { throw 'repak pack failed' }
$entries = @(& $repak list $PakOut)
Write-Host ("[OK] pak entries: " + $entries.Count)
$entries | ForEach-Object { Write-Host ('  entry: ' + $_) }

# round-trip check: unpack and compare payload bytes with the source TTF
$check = Join-Path $RepoRoot ('build\verify\font_' + $FontSet)
if (Test-Path $check) { Remove-Item $check -Recurse -Force }
& $repak unpack -o $check -f $PakOut 2>&1 | Select-Object -Last 1 | Out-Null
$bad = 0
foreach ($m in $map) {
    $src = [IO.File]::ReadAllBytes((Join-Path $fontRoot $m.ttf))
    $dstPath = Join-Path $check ($m.face -replace '/', '\')
    if (-not (Test-Path $dstPath)) { Write-Host ("  [BAD] missing in pak: " + $m.face); $bad++; continue }
    $dst = [IO.File]::ReadAllBytes($dstPath)
    $same = ($src.Length -eq $dst.Length)
    if ($same) { for ($i = 0; $i -lt $src.Length; $i++) { if ($src[$i] -ne $dst[$i]) { $same = $false; break } } }
    if (-not $same) { Write-Host ("  [BAD] payload differs: " + $m.face); $bad++ }
}
if ($bad -ne 0) { throw "round-trip verification failed for $bad face(s)" }
Write-Host '[OK] round-trip: all 6 payloads byte-identical inside the pak'
Write-Host ("[DONE] font pak {0}: {1} ({2} bytes) - NOT INSTALLED" -f $FontSet, $PakOut, (Get-Item $PakOut).Length)
