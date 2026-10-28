<#
.SYNOPSIS
  Verifies an install: takes a fresh read-only snapshot of the game folder, diffs it against
  a "before" snapshot, and checks the install manifest hashes. Writes reports/install_verification.md

.DESCRIPTION
  PASS requires ALL of:
    - no file added/removed/changed outside the Paks\~mods folder
    - no directory added/removed outside Paks\~mods
    - every stock pak in Paks unchanged (name, size, last-write time)
    - every manifest-recorded file present with a matching sha256
    - ~mods contains exactly the manifest files + the manifest itself
  The exe is covered by the root-file hash list.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [Parameter(Mandatory = $true)][string]$Before,
    [string]$Out = 'C:\AtomicHeart-AR\reports\install_verification.md'
)
$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

$afterJson = Join-Path $env:TEMP ('ah_snapshot_after_' + (Get-Date -Format 'HHmmss') + '.json')
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot 'scripts\snapshot_game_folder.ps1') -RepoRoot $RepoRoot -Out $afterJson | Out-Null
$b = Get-Content $Before -Raw | ConvertFrom-Json
$a = Get-Content $afterJson -Raw | ConvertFrom-Json

$problems = New-Object System.Collections.Generic.List[string]
$changes = New-Object System.Collections.Generic.List[string]

function Diff-Set($beforeList, $afterList, [string]$label, [string]$key, [switch]$HashCompare) {
    $bd = @{}; foreach ($x in @($beforeList)) { if ($x) { $bd[$x.$key] = $x } }
    $ad = @{}; foreach ($x in @($afterList))  { if ($x) { $ad[$x.$key] = $x } }
    $added = @($ad.Keys | Where-Object { -not $bd.ContainsKey($_) })
    $removed = @($bd.Keys | Where-Object { -not $ad.ContainsKey($_) })
    $changed = New-Object System.Collections.Generic.List[string]
    foreach ($k in $ad.Keys) {
        if (-not $bd.ContainsKey($k)) { continue }
        $bo = $bd[$k]; $ao = $ad[$k]
        if ($bo.size -ne $ao.size) { $changed.Add($k) ; continue }
        if ($HashCompare -and $bo.sha256 -ne $ao.sha256) { $changed.Add($k) }
    }
    return [pscustomobject]@{ label = $label; added = $added; removed = $removed; changed = $changed }
}

$rRoot  = Diff-Set $b.root_files $a.root_files 'game root files' 'name' -HashCompare
$rPaks  = Diff-Set $b.paks_files $a.paks_files 'Paks directory' 'name'

foreach ($r in @($rRoot, $rPaks)) {
    if ($r.added.Count)   { $problems.Add(('{0}: added {1}' -f $r.label, ($r.added -join ', '))) }
    if ($r.removed.Count) { $problems.Add(('{0}: removed {1}' -f $r.label, ($r.removed -join ', '))) }
    if ($r.changed.Count) { $problems.Add(('{0}: changed {1}' -f $r.label, ($r.changed -join ', '))) }
}

# directories (plain string lists)
$bd = @{}; foreach ($x in @($b.root_dirs)) { $bd[[string]$x] = $true }
$ad = @{}; foreach ($x in @($a.root_dirs)) { $ad[[string]$x] = $true }
$dirAdded = @($ad.Keys | Where-Object { -not $bd.ContainsKey($_) })
$dirRemoved = @($bd.Keys | Where-Object { -not $ad.ContainsKey($_) })
if ($dirAdded.Count)   { $problems.Add('game root dirs: added ' + ($dirAdded -join ', ')) }
if ($dirRemoved.Count) { $problems.Add('game root dirs: removed ' + ($dirRemoved -join ', ')) }

# manifest check
$game = Get-Content (Join-Path $RepoRoot 'config\game.json') -Raw | ConvertFrom-Json
$modsPath = $game.mods_path
$manifestPath = Join-Path $modsPath 'atomic-heart-ar-install-manifest.json'
$manifest = $null
$expectedFiles = New-Object System.Collections.Generic.List[string]
if (Test-Path $manifestPath) {
    $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
    foreach ($f in $manifest.files) {
        $p = Join-Path $modsPath $f.file
        $expectedFiles.Add($f.file)
        if (-not (Test-Path $p)) { $problems.Add(('manifest file missing: {0}' -f $f.file)); continue }
        $h = (Get-FileHash $p -Algorithm SHA256).Hash.ToLower()
        if ($h -ne $f.sha256) { $problems.Add(('manifest hash mismatch: {0} ({1} != {2})' -f $f.file, $h, $f.sha256)) }
    }
} else { $problems.Add('install manifest missing') }
$expectedFiles.Add('atomic-heart-ar-install-manifest.json')
$actualMods = @(Get-ChildItem $modsPath -File | Sort-Object Name)
foreach ($f in $actualMods) { if (-not ($expectedFiles -contains $f.Name)) { $problems.Add(('unexpected file in ~mods: {0}' -f $f.Name)) } }
foreach ($e in $expectedFiles) { if (-not (@($actualMods | ForEach-Object { $_.Name }) -contains $e)) { $problems.Add(('expected file missing from ~mods: {0}' -f $e)) } }

# stock pak comparison (Paks dir minus ~mods)
$bPakNames = @($b.paks_files | ForEach-Object { $_.name })
$aPakNames = @($a.paks_files | ForEach-Object { $_.name })
$stockBefore = @($bPakNames | Where-Object { $_ -like '*.pak' })
$stockAfter  = @($aPakNames | Where-Object { $_ -like '*.pak' })
if ($stockBefore.Count -ne $stockAfter.Count) { $problems.Add(('stock pak count changed: {0} -> {1}' -f $stockBefore.Count, $stockAfter.Count)) }
foreach ($n in $stockBefore) {
    $bo = @($b.paks_files | Where-Object { $_.name -eq $n })[0]
    $ao = @($a.paks_files | Where-Object { $_.name -eq $n })[0]
    if (-not $ao) { $problems.Add(('stock pak removed: {0}' -f $n)); continue }
    if ($bo.size -ne $ao.size -or $bo.modifiedUtc -ne $ao.modifiedUtc) { $problems.Add(('stock pak changed: {0}' -f $n)) }
}

$verdict = if ($problems.Count -eq 0) { 'PASS' } else { 'FAIL' }

$md = New-Object System.Collections.Generic.List[string]
$md.Add('# Install verification')
$md.Add('')
$md.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$md.Add(('Game root: `{0}`' -f $b.game_root))
$md.Add(('Before snapshot: `{0}`' -f $Before))
$md.Add('')
$md.Add(('VERDICT: **{0}**' -f $verdict))
$md.Add('')
$md.Add('## ~mods contents (with hashes)')
$md.Add('')
$md.Add('| file | size | sha256 |')
$md.Add('|---|---|---|')
foreach ($f in $actualMods) {
    $md.Add(('| {0} | {1} | `{2}` |' -f $f.Name, $f.Length, (Get-FileHash $f.FullName -Algorithm SHA256).Hash.ToLower()))
}
$md.Add('')
$md.Add('## Outside ~mods')
$md.Add('')
$rootLine = '- game root files: added {0}, removed {1}, changed {2}' -f $rRoot.added.Count, $rRoot.removed.Count, $rRoot.changed.Count
$dirsLine = '- game root dirs: added {0}, removed {1}' -f $dirAdded.Count, $dirRemoved.Count
$paksLine = '- Paks directory: added {0}, removed {1}, changed {2} (stock paks: {3} before, {4} after)' -f $rPaks.added.Count, $rPaks.removed.Count, $rPaks.changed.Count, $stockBefore.Count, $stockAfter.Count
$md.Add($rootLine)
$md.Add($dirsLine)
$md.Add($paksLine)
$md.Add('- AtomicHeart.exe: ' + $(if (@($rRoot.changed) -contains 'AtomicHeart.exe') { 'CHANGED' } else { 'unchanged' }))
$md.Add('')
if ($manifest) {
    $md.Add('## Manifest')
    $md.Add('')
    $md.Add('- installed_utc: ' + $manifest.installed_utc)
    $md.Add('- variant: ' + $manifest.variant)
    $md.Add('- superseded (removed, hash-verified): ' + $(if ($manifest.superseded) { (@($manifest.superseded) | ForEach-Object { $_.file + ' (' + $_.sha256 + ')' }) -join ', ' } else { 'none' }))
    $md.Add('')
}
$md.Add('## Problems')
$md.Add('')
if ($problems.Count -eq 0) { $md.Add('None. The only changes in the game folder are inside `Paks\~mods`.') }
else { foreach ($p in $problems) { $md.Add('- ' + $p) } }
$md.Add('')
[IO.File]::WriteAllLines($Out, $md, (New-Object Text.UTF8Encoding($false)))

Write-Output ('VERIFY INSTALL {0}: problems {1}' -f $verdict, $problems.Count)
foreach ($p in $problems) { Write-Output ('  PROBLEM: ' + $p) }
Write-Output ('report: ' + $Out)
if ($verdict -eq 'FAIL') { exit 2 }
