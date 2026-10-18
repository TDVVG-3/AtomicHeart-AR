<#
.SYNOPSIS
  PHASE 7 prototype builder: font override pak. Replaces the raw .ufont payload of
  selected game UI FontFaces with the Arabic-capable font shipped in Engine Slate
  (NotoNaskhArabicUI-Regular.ttf, OFL-licensed), so Latin text degrades but Arabic
  shaping/RTL can be tested in game.

.DESCRIPTION
  Evidence (2026-10-18): .ufont sidecar files are RAW sfnt font data (OTTO / TTF magic
  at offset 0). No UE wrapper. A payload byte swap is therefore valid.

  Faces overridden (Sidecar paths exactly as extracted via font_manifest.json):
   - BlenderPro-Book, BlenderPro-Medium, BlenderPro-Bold, BrutalType  (UI body/display)
   - Gotham-BookItalic, Gotham-Black                                  (NTD doc font)
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$PakOut
)
$ErrorActionPreference = 'Stop'
if (-not $PakOut) { $PakOut = Join-Path $RepoRoot 'build\package\zzz_atomicheart-ar_font_p1_P.pak' }
$repak = Join-Path $RepoRoot 'tools\bin\repak\repak.exe'
$noto = Join-Path $RepoRoot 'source\original\fonts\pakchunk0-WindowsNoEditor.pak\Engine\Content\Slate\Fonts\NotoNaskhArabicUI-Regular.ttf'
if (-not (Test-Path $noto)) { throw "Noto source not found: $noto" }
$payload = [System.IO.File]::ReadAllBytes($noto)

$faces = @(
    'AtomicHeart/Content/Development/UI/Fonts/BlenderPro-Book.ufont',
    'AtomicHeart/Content/Development/UI/Fonts/BlenderPro-Medium.ufont',
    'AtomicHeart/Content/Development/UI/Fonts/BlenderPro-Bold.ufont',
    'AtomicHeart/Content/Development/UI/Fonts/BrutalType.ufont',
    'AtomicHeart/Content/Development/NTD/Fonts/Gotham-BookItalic.ufont',
    'AtomicHeart/Content/Development/NTD/Fonts/Gotham-Black.ufont'
)
$work = Join-Path $RepoRoot 'build\staging\font_p1'
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
foreach ($face in $faces) {
    # locate the extracted raw copy (may sit under pakchunk0 or pakchunk5 tree)
    $leaf = Split-Path $face -Leaf
    $src = Get-ChildItem (Join-Path $RepoRoot 'source\original\fonts') -Recurse -Filter $leaf |
        Select-Object -First 1
    if (-not $src) { throw "extracted sidecar not found for $face" }
    $rel = ($face -replace '^AtomicHeart/Content/', 'AtomicHeart/Content/')
    $rel = ($face -replace '^AtomicHeart/Content/', 'AtomicHeart/Content/')
    $dest = Join-Path $work ("modpakfont\" + ($rel -replace '/', '\'))
    New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
    # keep original length only for reference; payload swapped with whole Noto file
    [System.IO.File]::WriteAllBytes($dest, $payload)
    Write-Host ("[OK] {0}  ({1} -> {2} bytes, Noto payload)" -f $face, $src.Length, $payload.Length)
}

New-Item -ItemType Directory -Force -Path (Split-Path $PakOut -Parent) | Out-Null
& $repak pack --version V11 --mount-point '../../../' (Join-Path $work 'modpakfont') $PakOut 2>&1 | Select-Object -Last 2
if (-not (Test-Path $PakOut)) { throw 'repak pack failed' }

# verify: list + unzip + cmap-scan one replaced face to prove FULL Arabic coverage inside the pak
$chk = Join-Path $work 'unpack_check'
if (Test-Path $chk) { Remove-Item $chk -Recurse -Force }
& $repak unpack $PakOut --output $chk 2>&1 | Out-Null
$check = Join-Path $chk 'AtomicHeart\Content\Development\UI\Fonts\BlenderPro-Book.ufont'
powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot 'scripts\font_glyph_scan.ps1') -FontsRoot (Split-Path $check -Parent) -OutPath (Join-Path $work 'verify_fontpak_coverage.txt') | Select-Object -Last 2
Write-Host ("[DONE] font pak: {0} ({1} bytes)" -f $PakOut, (Get-Item $PakOut).Length)
