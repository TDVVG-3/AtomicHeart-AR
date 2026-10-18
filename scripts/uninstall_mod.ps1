<#
.SYNOPSIS
  Uninstalls the AtomicHeart-AR prototype mod, removing EXACTLY the files recorded in
  the install manifest (and nothing else).

.DESCRIPTION
  For every recorded file: verifies the on-disk SHA256 matches the manifest before
  deletion. A mismatch means the file on disk is not the one we installed: it is
  reported and left untouched. After removing our paks, the manifest is deleted and
  the ~mods folder is removed if it has become empty (leaving nothing behind).
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
$game = Get-Content (Join-Path $RepoRoot 'config\game.json') -Raw | ConvertFrom-Json
$modsPath = $game.mods_path

if (-not (Test-Path $modsPath)) { Write-Host '[SKIP] ~mods does not exist; nothing to remove'; return }
$manifestPath = Join-Path $modsPath 'atomic-heart-ar-install-manifest.json'
if (-not (Test-Path $manifestPath)) { throw "install manifest not found; refusing to delete anything: $manifestPath" }
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json

$removed = 0
foreach ($f in $manifest.files) {
    $p = Join-Path $modsPath $f.file
    if (-not (Test-Path $p)) { Write-Host ("[SKIP] not present: {0}" -f $f.file); continue }
    $hash = (Get-FileHash $p -Algorithm SHA256).Hash.ToLower()
    if ($hash -ne $f.sha256) {
        Write-Host ("[REFUSE] hash mismatch for {0}: on-disk file was not installed by us; left untouched" -f $f.file)
        continue
    }
    Remove-Item $p -Force
    $removed++
    Write-Host ("[OK] removed: {0}" -f $f.file)
}
Remove-Item $manifestPath -Force
Write-Host "[OK] manifest removed"
$left = Get-ChildItem $modsPath -ErrorAction SilentlyContinue
if (-not $left) {
    Remove-Item $modsPath -Force
    Write-Host '[OK] ~mods folder was empty and has been removed'
} else {
    Write-Host ("[NOTE] ~mods still holds non-project files, left untouched: {0}" -f (($left | ForEach-Object { $_.Name }) -join ', '))
}
Write-Host "[DONE] uninstalled ($removed files removed)"
