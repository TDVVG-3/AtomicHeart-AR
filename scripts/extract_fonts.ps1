<#
.SYNOPSIS
  Phase 6: extracts every font-related file (.ufont/.ttf/.otf + Fonts/*.uasset/.uexp)
  from the game paks into source/original/fonts/ (gitignored) and builds a manifest.

.DESCRIPTION
  - repak list per pak, cached to reports/paklists/<pak>.txt for fast re-runs.
  - Extract ONLY font files. Never writes to the game folder.
  - Writes source/manifests/font_manifest.json with sha256 per file.
  - Raw font binaries of commercial typefaces stay in the gitignored area; they are
    for LOCAL analysis only and are never committed or redistributed.
#>
[CmdletBinding()]
param(
    [string]$GamePath = 'C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart',
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
$repak = Join-Path $RepoRoot 'tools\bin\repak\repak.exe'
$paksPath = Join-Path $GamePath 'AtomicHeart\Content\Paks'
$listCache = Join-Path $RepoRoot 'reports\paklists'
$rawRoot = Join-Path $RepoRoot 'source\original\fonts'
$manifestPath = Join-Path $RepoRoot 'source\manifests\font_manifest.json'
New-Item -ItemType Directory -Force -Path $listCache, $rawRoot | Out-Null

$paks = Get-ChildItem $paksPath -Filter '*.pak' | Sort-Object Name
$entries = @()
foreach ($pak in $paks) {
    $cacheFile = Join-Path $listCache $pak.Name
    if (Test-Path $cacheFile) {
        $list = Get-Content $cacheFile
        Write-Host ("[CACHE] {0}" -f $pak.Name)
    } else {
        Write-Host ("[LIST ] {0}" -f $pak.Name)
        $list = & $repak list $pak.FullName 2>&1 | Where-Object { $_ -match '\S' }
        Set-Content -Path $cacheFile -Value $list -Encoding UTF8
    }
    $hits = $list | Where-Object {
        $_ -match '\.ufont$' -or
        $_ -match '\.(ttf|otf|ttc)$' -or
        ($_ -match '/Fonts/' -and $_ -match '\.uasset$')
    }
    if ($hits | Where-Object { $_ }) {
        Write-Host ("[OK   ] {0} hits in {1}" -f @($hits).Count, $pak.Name)
        foreach ($h in $hits) { $entries += [pscustomobject]@{ pak = $pak.Name; path = ($h.ToString().Trim()) } }
    }
}
Write-Host "[OK] total font-related entries: $($entries.Count)"

$newItems = @()
$pakCache = @{}
foreach ($e in ($entries | Sort-Object pak, path -Unique)) {
    if (-not $pakCache.ContainsKey($e.pak)) { $pakCache[$e.pak] = Join-Path $paksPath $e.pak }
    $rel = ($e.path -replace '^(\.\./)+', '')
    $dest = Join-Path $rawRoot (Join-Path $e.pak ($rel -replace '/', '\'))
    if (Test-Path $dest) { continue }   # resume support
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
    $tmp = "$dest.tmp"
    cmd /c "`"$repak`" get `"$($pakCache[$e.pak])`" `"$($e.path)`" > `"$tmp`"" 2>$null
    if ((Test-Path $tmp) -and ((Get-Item $tmp).Length -gt 0)) {
        Move-Item $tmp $dest -Force
        $item = Get-Item $dest
        $newItems += [pscustomobject]@{
            relative_path = $rel
            container     = $e.pak
            size          = $item.Length
            sha256        = (Get-FileHash $dest -Algorithm SHA256).Hash.ToLower()
            extracted_utc = (Get-Date).ToUniversalTime().ToString('o')
        }
    } else {
        if (Test-Path $tmp) { Remove-Item $tmp -Force }
        Write-Host ("[WARN] failed: {0} :: {1}" -f $e.pak, $e.path)
    }
}

$all = @()
if (Test-Path $manifestPath) { $all += (Get-Content $manifestPath -Raw | ConvertFrom-Json) }
if ($newItems) { $all += $newItems }
$all = $all | Sort-Object relative_path -Unique
$all | ConvertTo-Json -Depth 4 | Set-Content -Path $manifestPath -Encoding UTF8
Write-Host ''
Write-Host ("[DONE] font manifest total: {0} files (new: {1})" -f $all.Count, $newItems.Count)
Write-Host "[DONE] raw fonts in (gitignored): $rawRoot"
