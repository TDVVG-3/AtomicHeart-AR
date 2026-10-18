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

foreach ($p in (Join-Path $RepoRoot 'build\package\zzz_atomicheart-ar_locres_p1_P.pak'),
               (Join-Path $RepoRoot 'build\package\zzz_atomicheart-ar_font_p1_P.pak')) {
    if (-not (Test-Path $p)) { throw "build output missing, run the build scripts first: $p" }
}
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
foreach ($src in (Get-ChildItem (Join-Path $RepoRoot 'build\package') -Filter 'zzz_atomicheart-ar_*_P.pak')) {
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
    notes = 'Remove with scripts/uninstall_mod.ps1 only. These two paks are the ONLY files this project installs.'
}
$manifestPath = Join-Path $modsPath 'atomic-heart-ar-install-manifest.json'
$manifest | ConvertTo-Json -Depth 5 | Set-Content -Path $manifestPath -Encoding UTF8
Write-Host ("[DONE] install manifest: {0} ({1} files)" -f $manifestPath, $installed.Count)
