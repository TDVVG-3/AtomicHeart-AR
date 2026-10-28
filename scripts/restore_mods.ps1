param(
    [Parameter(Mandatory=$true)][string]$ModsPath,
    [Parameter(Mandatory=$true)][string]$BackupDir
)
$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$backupManifestPath = Join-Path $BackupDir 'backup_manifest.json'
if (-not (Test-Path $backupManifestPath)) { throw "backup manifest missing: $backupManifestPath" }
$bm = Get-Content $backupManifestPath -Raw | ConvertFrom-Json
$backupNames = @($bm.files | ForEach-Object { $_.name })

# Verify every backup byte before touching ~mods.
foreach ($b in $bm.files) {
    $p = Join-Path $BackupDir $b.name
    if (-not (Test-Path $p)) { throw ('backup file missing: ' + $b.name) }
    $h = (Get-FileHash $p -Algorithm SHA256).Hash.ToLower()
    if ($h -ne $b.sha256) { throw ('backup file hash mismatch: ' + $b.name) }
}

if (-not (Test-Path $ModsPath)) { New-Item -ItemType Directory -Force -Path $ModsPath | Out-Null }
$current = @(Get-ChildItem $ModsPath -File | Sort-Object Name)

# Only remove files this project could have installed. Refuse to delete anything unknown.
foreach ($f in $current) {
    if ($backupNames -contains $f.Name) { continue }
    if ($f.Name -notmatch '^zzz_atomicheart-ar_.+\.pak$' -and $f.Name -ne 'atomic-heart-ar-install-manifest.json') {
        throw ('refusing rollback: unknown file in ~mods: ' + $f.Name)
    }
}
foreach ($f in $current) {
    if ($backupNames -contains $f.Name) { continue }
    Remove-Item $f.FullName -Force
    Write-Output ('[restore] removed ' + $f.Name)
}

foreach ($b in $bm.files) {
    $src = Join-Path $BackupDir $b.name
    $dst = Join-Path $ModsPath $b.name
    Copy-Item $src $dst -Force
    $h = (Get-FileHash $dst -Algorithm SHA256).Hash.ToLower()
    if ($h -ne $b.sha256) { throw ('restored file hash mismatch: ' + $b.name) }
}

$restored = @(Get-ChildItem $ModsPath -File | Sort-Object Name)
$restoredNames = @($restored | ForEach-Object { $_.Name })
if (($restoredNames -join '|') -ne (($backupNames | Sort-Object) -join '|')) {
    throw ('restored set does not match backup: ' + ($restoredNames -join ', '))
}
foreach ($b in $bm.files) {
    $p = Join-Path $ModsPath $b.name
    if ((Get-Item $p).Length -ne $b.size) { throw ('restored size mismatch: ' + $b.name) }
}
Write-Output ('[restore] exact set restored: ' + $restoredNames.Count + ' files')
