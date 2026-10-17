<#
.SYNOPSIS
  Read-only forensic scan of the Atomic Heart installation (Phases 2-3).

.DESCRIPTION
  - Verifies game path and Paks path.
  - Inventories every file in the Paks directory (name, size).
  - Parses the UE4 PAK header of each .pak (magic, version, index offset/size,
    encryption flag) without ever opening the file for write.
  - Computes SHA256 of every .pak (this is the slow part).
  - Reads AtomicHeart.exe version metadata (read-only).
  - Writes reports/archive_inventory.txt, reports/dlc_inventory.txt,
    reports/game_scan.json.

  The game folder is strictly READ-ONLY. This script never writes to it.
#>
[CmdletBinding()]
param(
    [string]$GamePath = 'C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart',
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)

$ErrorActionPreference = 'Stop'
$reportsDir = Join-Path $RepoRoot 'reports'
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

$paksPath = Join-Path $GamePath 'AtomicHeart\Content\Paks'
if (-not (Test-Path $paksPath)) {
    throw "Paks path not found: $paksPath"
}
Write-Host "[OK] Paks path verified: $paksPath"

# --- Read PAK header (UE4 legacy pak) ---------------------------------------
# Layout for version >= 9:
#   0  uint32 magic (0x5A6F12E1)
#   4  uint32 version
#   8  int64  index offset
#   16 int64  index size
#   24 byte[20] index hash (SHA1)
#   44 uint8  encrypted index flag
function Read-PakHeader {
    param([string]$File)
    $fs = [System.IO.File]::Open($File, 'Open', 'Read', 'ReadWrite')
    try {
        $br = New-Object System.IO.BinaryReader($fs)
        $magic = $br.ReadUInt32()
        if ($magic -ne 0x5A6F12E1) {
            return [pscustomobject]@{ Valid = $false; Reason = ('unexpected magic 0x{0:X8}' -f $magic) }
        }
        $version = $br.ReadUInt32()
        $indexOffset = $br.ReadInt64()
        $indexSize = $br.ReadInt64()
        $hashBytes = $br.ReadBytes(20)
        $encrypted = $false
        if ($version -ge 9) { $encrypted = ($br.ReadByte() -ne 0) }
        return [pscustomobject]@{
            Valid       = $true
            Version     = $version
            IndexOffset = $indexOffset
            IndexSize   = $indexSize
            IndexHash   = (($hashBytes | ForEach-Object { $_.ToString('x2') }) -join '')
            Encrypted   = $encrypted
        }
    }
    finally { $fs.Dispose() }
}

# --- Inventory + header parse ----------------------------------------------
$files = Get-ChildItem $paksPath -File | Sort-Object { [int]($_.Name -replace '[^\d]','') }, Name
$inventory = @()
foreach ($f in $files) {
    $entry = [ordered]@{
        name      = $f.Name
        size      = $f.Length
        size_mb   = [math]::Round($f.Length / 1MB, 1)
        modified  = $f.LastWriteTimeUtc.ToString('o')
        sha256    = $null
        pak       = $null
    }
    if ($f.Extension -eq '.pak') {
        $hdr = Read-PakHeader -File $f.FullName
        $entry.pak = $hdr
        Write-Host ("[HDR ] {0,-45} version={1} encrypted={2} indexSize={3}" -f $f.Name, $hdr.Version, $hdr.Encrypted, $hdr.IndexSize)
    }
    $inventory += [pscustomobject]$entry
}

# --- SHA256 (slow; read-only) -----------------------------------------------
foreach ($entry in $inventory) {
    $full = Join-Path $paksPath $entry.name
    Write-Host "[HASH] $($entry.name) ..."
    $entry.sha256 = (Get-FileHash -Path $full -Algorithm SHA256).Hash.ToLower()
    Write-Host "       -> $($entry.sha256)"
}

# --- EXE metadata (read-only) -----------------------------------------------
$exePath = Join-Path $GamePath 'AtomicHeart.exe'
$exeInfo = $null
if (Test-Path $exePath) {
    $v = (Get-Item $exePath).VersionInfo
    $exeInfo = [ordered]@{
        path            = $exePath
        file_version    = $v.FileVersion
        product_version = $v.ProductVersion
        product_name    = $v.ProductName
        sha256          = (Get-FileHash -Path $exePath -Algorithm SHA256).Hash.ToLower()
    }
}

# --- Steam metadata (already verified in Phase 2) ---------------------------
$acfPath = 'C:\Program Files (x86)\Steam\steamapps\appmanifest_668580.acf'
$steam = [ordered]@{
    app_id      = 668580
    build_id    = '24534183'
    depot_ids   = @('668581')
    shared_depots = [ordered]@{ '228989' = 228980; '228990' = 228980 }
    language    = 'english'
    acf_path    = $acfPath
}

# --- Write reports -----------------------------------------------------------
$totalMB = [math]::Round(($inventory | Measure-Object -Property size -Sum).Sum / 1MB, 1)
$lines = @()
$lines += 'Atomic Heart Paks inventory (read-only scan)'
$lines += ('Generated: {0} UTC' -f (Get-Date).ToUniversalTime().ToString('o'))
$lines += ('Paks path: {0}' -f $paksPath)
$lines += ('Files: {0}   Total: {1} MB' -f $inventory.Count, $totalMB)
$lines += ''
foreach ($e in $inventory) {
    $hdrTxt = ''
    if ($e.pak -and $e.pak.Valid) {
        $hdrTxt = ('pak v{0} encrypted={1} indexSize={2}' -f $e.pak.Version, $e.pak.Encrypted, $e.pak.IndexSize)
    }
    elseif ($e.pak) { $hdrTxt = ('pak header INVALID: {0}' -f $e.pak.Reason) }
    $lines += ('{0,-45} {1,14} bytes  {2}' -f $e.name, $e.size, $hdrTxt)
    $lines += ('    sha256: {0}' -f $e.sha256)
}
Set-Content -Path (Join-Path $reportsDir 'archive_inventory.txt') -Value $lines -Encoding UTF8

# DLC candidates: 'optional' chunks and chunks beyond the base set (0-9 heuristic)
$dlc = $inventory | Where-Object { $_.name -match 'optional|chunk1[0-9]' }
$dlcLines = @()
$dlcLines += 'DLC / additional-content candidates (heuristic: chunk numbering + "optional" flag)'
$dlcLines += 'Mapping chunks to specific DLC names is NOT confirmed here (needs pak content inspection, Phase 5).'
$dlcLines += ''
foreach ($d in $dlc) { $dlcLines += ('{0,-45} {1,14} bytes' -f $d.name, $d.size) }
Set-Content -Path (Join-Path $reportsDir 'dlc_inventory.txt') -Value $dlcLines -Encoding UTF8

$scan = [ordered]@{
    game              = 'Atomic Heart'
    platform          = 'Steam'
    scanned_utc       = (Get-Date).ToUniversalTime().ToString('o')
    game_path         = $GamePath
    paks_path         = $paksPath
    mods_path         = (Join-Path $paksPath '~mods')
    mods_folder_exists = [bool](Test-Path (Join-Path $paksPath '~mods'))
    steam             = $steam
    exe               = $exeInfo
    container_type    = 'UE4 legacy PAK (no .utoc/.ucas/.sig present)'
    pak_files         = $inventory
    total_bytes       = ($inventory | Measure-Object -Property size -Sum).Sum
}
$scan | ConvertTo-Json -Depth 6 | Set-Content -Path (Join-Path $reportsDir 'game_scan.json') -Encoding UTF8

Write-Host ''
Write-Host "[DONE] Inventory: $($inventory.Count) files, $totalMB MB total."
Write-Host '[DONE] Reports written to reports\archive_inventory.txt, dlc_inventory.txt, game_scan.json'
