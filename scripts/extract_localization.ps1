<#
.SYNOPSIS
  Phase 5: extracts ALL .locres and .locmeta files from every game pak and builds
  the immutable source manifest (MASTER_PROMPT sections 25, 9).

.DESCRIPTION
  - Input: reports/localization_candidates.txt (produced by scan_localization.ps1).
  - For each candidate entry "pakname :: path", extracts the file with repak get
    into localization/extracted/<Prefix>/<relative path> (game folder untouched).
  - Computes SHA256 for every extracted file.
  - Writes source/manifests/localization_manifest.json with path, size, sha256,
    container (pak), culture, resource type.
  - Never writes to the game folder; never overwrites existing translation work.
    Re-running fills gaps only; files that already exist and match the manifest are skipped.
#>
[CmdletBinding()]
param(
    [string]$GamePath = 'C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart',
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)

$ErrorActionPreference = 'Stop'
$repak = Join-Path $RepoRoot 'tools\bin\repak\repak.exe'
$paksPath = Join-Path $GamePath 'AtomicHeart\Content\Paks'
$candsPath = Join-Path $RepoRoot 'reports\localization_candidates.txt'
$extractRoot = Join-Path $RepoRoot 'localization\extracted'
$manifestPath = Join-Path $RepoRoot 'source\manifests\localization_manifest.json'
if (-not (Test-Path $repak)) { throw "repak not found at $repak" }
if (-not (Test-Path $candsPath)) { throw "run scan_localization.ps1 first" }

$entries = Get-Content $candsPath | Where-Object { $_ -match ':: ' -and $_ -match '\.loc(res|meta)$' } |
    ForEach-Object {
        # format: "pakname :: full/internal/path"
        $idx = $_.IndexOf(' :: ')
        [pscustomobject]@{ pak = $_.Substring(0, $idx); path = $_.Substring($idx + 4) }
    } | Sort-Object pak, path -Unique
Write-Host ("[OK] {0} locres/locmeta entries to extract" -f $entries.Count)

# Existing manifest (do not lose prior work)
$manifest = @()
if (Test-Path $manifestPath) {
    $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
    Write-Host ("[OK] existing manifest entries: {0}" -f $manifest.Count)
}

$pakCache = @{}
$newItems = @()
$i = 0
foreach ($e in $entries) {
    $i++
    $already = $manifest | Where-Object { $_.container -eq $e.pak -and $_.relative_path -eq $e.path }
    if ($already) { continue }

    if (-not $pakCache.ContainsKey($e.pak)) { $pakCache[$e.pak] = Join-Path $paksPath $e.pak }
    $pak = $pakCache[$e.pak]

    # strip a leading "../../../" style prefix if present in the index listing
    $rel = $e.path -replace '^(((\.\./)+)?(Engine|AtomicHeart)/)', '$2/'
    $rel = $e.path -replace '^(\.\./)+', ''
    $dest = Join-Path $extractRoot $rel
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }

    $tmp = "$dest.tmp"
    cmd /c "`"$repak`" get `"$pak`" `"$($e.path)`" > `"$tmp`"" 2>$null
    if (-not (Test-Path $tmp) -or ((Get-Item $tmp).Length -eq 0)) {
        Write-Host ("[WARN] empty/failed: {0} :: {1}" -f $e.pak, $e.path)
        if (Test-Path $tmp) { Remove-Item $tmp -Force }
        continue
    }
    Move-Item -Path $tmp -Destination $dest -Force

    $item = Get-Item $dest
    $culture = '(native)'
    if ($rel -match '/([a-z]{2}-[A-Z]{2}|[a-z]{2})/[^/]+\.locres$') { $culture = $Matches[1] }
    if ($rel -notmatch '\.locres$') { $culture = '' }

    $newItems += [pscustomobject]@{
        relative_path = $rel
        size          = $item.Length
        sha256        = (Get-FileHash $dest -Algorithm SHA256).Hash.ToLower()
        container     = $e.pak
        culture       = $culture
        resource_type = if ($rel -match '\.locres$') { 'locres' } else { 'locmeta' }
        extracted_utc = (Get-Date).ToUniversalTime().ToString('o')
    }
    if ($i % 50 -eq 0) { Write-Host ("  ... {0}/{1}" -f $i, $entries.Count) }
}

$all = @()
if ($manifest) { $all += $manifest }
if ($newItems) { $all += $newItems }
$all = $all | Sort-Object relative_path -Unique
$all | ConvertTo-Json -Depth 4 | Set-Content -Path $manifestPath -Encoding UTF8

Write-Host ''
Write-Host ("[DONE] manifest total: {0} files; new this run: {1}" -f $all.Count, $newItems.Count)
Write-Host "[DONE] manifest: $manifestPath"
