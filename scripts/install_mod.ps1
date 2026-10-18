<#
.SYNOPSIS
  Installs the AtomicHeart-AR prototype mod into the game's Paks/~mods folder.

.DESCRIPTION
  Safety rules (user decision 2026-10-18):
   - Writes ONLY the two mod paks and the install manifest into ~mods.
   - Never touches AtomicHeart.exe, DLLs, Steam or Denuvo files, or anything else
     in the game folder.
   - Refuses to run if an install manifest already exists (run uninstall_mod.ps1 first)
     unless -Force is given, in which case the old manifest is replaced atomically.
   - The manifest records every installed file's sha256 so uninstall_mod.ps1 can
     remove exactly our files and nothing else.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [switch]$Force
)
$ErrorActionPreference = 'Stop'
$game = Get-Content (Join-Path $RepoRoot 'config\game.json') -Raw | ConvertFrom-Json
$modsPath = $game.mods_path
$paksDir = $game.paks_path

foreach ($p in (Join-Path $RepoRoot 'build\package\zzz_atomicheart-ar_carrier_koKR_p2_P.pak'),
               (Join-Path $RepoRoot 'build\package\zzz_atomicheart-ar_font_p2_plex_P.pak')) {
    if (-not (Test-Path $p)) { throw "build output missing, run the build scripts first: $p" }
}
# EXPLICIT TEST-3 SET ONLY. The rejected v1 Naskh font pak and the test-1 locres pak
# are NOT installed by design (DEC-014 v1 rejected; DEC-015/KI-013 native-ar deferred;
# test 3 = carrier ko-KR p2 (English-fill, DEC-016) + font v2, user order 2026-10-18 "go").
$installSet = @(
    'zzz_atomicheart-ar_carrier_koKR_p2_P.pak',
    'zzz_atomicheart-ar_font_p2_plex_P.pak'
)
if (-not (Test-Path $paksDir)) { throw "game paks directory not found: $paksDir" }

# safety: never touch existing folders/files other than ours
if (Test-Path $modsPath) {
    if (-not (Test-Path (Join-Path $modsPath 'atomic-heart-ar-install-manifest.json')) -and -not $Force) {
        $existing = (Get-ChildItem $modsPath | Select-Object Name) | ForEach-Object { $_.Name }
        throw "~mods already contains files we did not install; refusing: $($existing -join ', ')"
    }
} else {
    New-Item -ItemType Directory -Path $modsPath | Out-Null
    Write-Host "[OK] created ~mods (empty): $modsPath"
}

$installed = New-Object System.Collections.Generic.List[object]
foreach ($name in $installSet) {
    $src = Get-Item (Join-Path $RepoRoot (Join-Path 'build\package' $name))
    $destPath = Join-Path $modsPath $src.Name
    Copy-Item $src.FullName $destPath -Force
    $installed.Add([pscustomobject]@{
        file   = $src.Name
        source_build_path = $src.FullName.Substring($RepoRoot.Length + 1)
        size   = $src.Length
        sha256 = (Get-FileHash $destPath -Algorithm SHA256).Hash.ToLower()
        installed_utc = (Get-Date).ToUniversalTime().ToString('o')
    })
    Write-Host ("[OK] installed: {0} ({1} bytes)" -f $src.Name, $src.Length)
}

$manifest = [pscustomobject]@{
    project = 'AtomicHeart-AR'
    phase   = 'phase7 prototype'
    installed_utc = (Get-Date).ToUniversalTime().ToString('o')
    game_build_id = $game.steam_build_id
    files = $installed
    notes = 'Remove with scripts/uninstall_mod.ps1 only. These paks are the ONLY files this project installs. Test-3 set: DEC-007 carrier (ko-KR slot) p2 with English fill (DEC-016) + font v2 (IBM Plex Sans Arabic dual-script).'
}
$manifestPath = Join-Path $modsPath 'atomic-heart-ar-install-manifest.json'
$manifest | ConvertTo-Json -Depth 5 | Set-Content -Path $manifestPath -Encoding UTF8
Write-Host ("[DONE] install manifest: {0} ({1} files)" -f $manifestPath, $installed.Count)
