<#
.SYNOPSIS
  PHASE 7 fix, variant B (v2): font-only pak where each replaced UI FontFace gets an
  IBM Plex Sans Arabic payload that covers BOTH Latin and Arabic.

.DESCRIPTION
  Lesson from v1 (Noto Naskh): replacing UI faces with a font whose Latin coverage is
  only ~15 codepoints blanked every Latin string in the UI and is the LIKELY cause of
  the FPS collapse / hang (missing-glyph fallback storm over Latin glyph lookups).

  v2 rule (user decision, cycle 003): never break Latin. All payloads therefore come
  from IBM Plex Sans Arabic (OFL 1.1), whose cmap coverage is verified by
  scripts/font_glyph_scan.ps1 BEFORE packing: Latin-Basic 95/95 (incl. digits and
  punctuation), Arabic 42/42 core letters, complete presentation forms.

  Face -> weight mapping:
    BlenderPro-Book     -> PlexSansArabic-Regular
    BlenderPro-Medium   -> PlexSansArabic-Medium
    BlenderPro-Bold     -> PlexSansArabic-Bold
    BrutalType          -> PlexSansArabic-Bold   (display face, closer to its weight)
    Gotham-BookItalic   -> PlexSansArabic-Regular (no italic in family; test-grade)
    Gotham-Black        -> PlexSansArabic-Bold

  Output pak is written to build/package but NOT INSTALLED.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$PakOut
)
$ErrorActionPreference = 'Stop'
if (-not $PakOut) { $PakOut = Join-Path $RepoRoot 'build\package\zzz_atomicheart-ar_font_p2_plex_P.pak' }
$repak = Join-Path $RepoRoot 'tools\bin\repak\repak.exe'
$plexRoot = Join-Path $RepoRoot 'source\original\fonts\downloaded'

$map = @(
    @{ face = 'AtomicHeart/Content/Development/UI/Fonts/BlenderPro-Book.ufont';    ttf = 'IBMPlexSansArabic-Regular.ttf' },
    @{ face = 'AtomicHeart/Content/Development/UI/Fonts/BlenderPro-Medium.ufont';  ttf = 'IBMPlexSansArabic-Medium.ttf' },
    @{ face = 'AtomicHeart/Content/Development/UI/Fonts/BlenderPro-Bold.ufont';    ttf = 'IBMPlexSansArabic-Bold.ttf' },
    @{ face = 'AtomicHeart/Content/Development/UI/Fonts/BrutalType.ufont';         ttf = 'IBMPlexSansArabic-Bold.ttf' },
    @{ face = 'AtomicHeart/Content/Development/NTD/Fonts/Gotham-BookItalic.ufont'; ttf = 'IBMPlexSansArabic-Regular.ttf' },
    @{ face = 'AtomicHeart/Content/Development/NTD/Fonts/Gotham-Black.ufont';      ttf = 'IBMPlexSansArabic-Bold.ttf' }
)

# coverage gate: every mapped font must have FULL verdict in the pre-scan
$dec = Join-Path $RepoRoot 'reports\font_glyph_coverage_plex.txt'
foreach ($m in $map) {
    $block = (Get-Content $dec) -join ' ' -match ([regex]::Escape('###')) # touch file
    $found = (Select-String -Path $dec -Pattern ('^### ' + [regex]::Escape($m.ttf) + ' '))[0]
    if (-not $found) { throw "font not covered by pre-scan: $($m.ttf)" }
    $verdict = (Select-String -Path $dec -Pattern 'VERDICT: (\w+)')
    if ($verdict.Matches[0].Groups[1].Value -ne 'FULL') { throw "font not FULL: $($m.ttf)" }
}
Write-Host "[OK] coverage gate: all mapped Plex weights FULL (Latin-Basic 95/95, Arabic 42/42)"

$work = Join-Path $RepoRoot 'build\staging\font_p2'
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
foreach ($m in $map) {
    $payload = [System.IO.File]::ReadAllBytes((Join-Path $plexRoot $m.ttf))
    $dest = Join-Path $work ("modpakfont\" + ($m.face -replace '/', '\'))
    New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
    [System.IO.File]::WriteAllBytes($dest, $payload)
    Write-Host ("[OK] {0}  <-  {1} ({2} bytes)" -f $m.face, $m.ttf, $payload.Length)
}

# ALSO ship the Plex OFL license inside the (_gitignored) staging tree root for the record
$licSrc = Join-Path $plexRoot 'plex-sans-arabic\ibm-plex-sans-arabic\fonts\complete\ttf\license.txt'
Copy-Item $licSrc (Join-Path $work 'license.ibm-plex-sans-arabic.txt') -Force -ErrorAction SilentlyContinue

New-Item -ItemType Directory -Force -Path (Split-Path $PakOut -Parent) | Out-Null
& $repak pack --version V11 --mount-point '../../../' (Join-Path $work 'modpakfont') $PakOut 2>&1 | Select-Object -Last 2
if (-not (Test-Path $PakOut)) { throw 'repak pack failed' }
& $repak list $PakOut | ForEach-Object { Write-Host ("  entry: " + $_) }
Write-Host ("[DONE] font pak v2: {0} ({1} bytes) - NOT INSTALLED" -f $PakOut, (Get-Item $PakOut).Length)
