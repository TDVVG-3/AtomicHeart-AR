<#
.SYNOPSIS
  Takes a read-only snapshot of the game folder so any change outside ~mods can be proven
  (or disproven) after an install/uninstall.

.DESCRIPTION
  Records, as JSON:
    - game root: every file (name, size, sha256 for files <= 50 MB) and every directory name
    - Paks directory: every file (name, size, lastWriteUtc)
    - Paks\~mods: every file (name, size, lastWriteUtc, sha256)
  Nothing is written inside the game folder. Hash cost stays small (our paks + small root files).
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [Parameter(Mandatory = $true)][string]$Out
)
$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$game = Get-Content (Join-Path $RepoRoot 'config\game.json') -Raw | ConvertFrom-Json
$gameRoot = $game.game_path
$paksDir = $game.paks_path
$modsPath = $game.mods_path
if (-not $gameRoot) { throw 'config/game.json has no game_path' }

function Snap-Files([string]$dir, [switch]$Hash) {
    $out = New-Object System.Collections.Generic.List[object]
    if (-not (Test-Path $dir)) { return $out }
    foreach ($f in (Get-ChildItem $dir -File | Sort-Object Name)) {
        $o = [ordered]@{
            name = $f.Name; size = $f.Length
            modifiedUtc = $f.LastWriteTimeUtc.ToString('o')
        }
        if ($Hash -and $f.Length -le 52428800) { $o.sha256 = (Get-FileHash $f.FullName -Algorithm SHA256).Hash.ToLower() }
        $out.Add([pscustomobject]$o)
    }
    return $out
}

$snap = [ordered]@{
    taken_utc = (Get-Date).ToUniversalTime().ToString('o')
    game_root = $gameRoot
    paks_dir = $paksDir
    mods_dir = $modsPath
    root_files = Snap-Files $gameRoot -Hash
    root_dirs = @(if (Test-Path $gameRoot) { (Get-ChildItem $gameRoot -Directory | Sort-Object Name | ForEach-Object { $_.Name }) })
    paks_files = Snap-Files $paksDir
    mods_files = Snap-Files $modsPath -Hash
}
$json = $snap | ConvertTo-Json -Depth 6
[IO.File]::WriteAllText($Out, $json, (New-Object Text.UTF8Encoding($false)))
Write-Output ('[snapshot] root_files {0} | paks_files {1} | mods_files {2} -> {3}' -f $snap.root_files.Count, $snap.paks_files.Count, $snap.mods_files.Count, $Out)
