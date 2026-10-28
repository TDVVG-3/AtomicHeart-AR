param(
    [Parameter(Mandatory=$true)][string]$ModsPath,
    [Parameter(Mandatory=$true)][string]$OutDir
)
$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

if (-not (Test-Path $ModsPath)) { throw "mods path not found: $ModsPath" }
if (Test-Path $OutDir) { Remove-Item $OutDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$files = @(Get-ChildItem $ModsPath -File | Sort-Object Name)
$manifestFiles = New-Object System.Collections.Generic.List[object]
foreach ($f in $files) {
    $dst = Join-Path $OutDir $f.Name
    Copy-Item $f.FullName $dst -Force
    $srcHash = (Get-FileHash $f.FullName -Algorithm SHA256).Hash.ToLower()
    $dstHash = (Get-FileHash $dst -Algorithm SHA256).Hash.ToLower()
    if ($srcHash -ne $dstHash) { throw ('backup hash mismatch: ' + $f.Name) }
    $manifestFiles.Add([pscustomobject]@{
        name = $f.Name
        size = $f.Length
        sha256 = $srcHash
        modifiedUtc = $f.LastWriteTimeUtc.ToString('o')
    })
}
$manifest = [pscustomobject]@{
    taken_utc = (Get-Date).ToUniversalTime().ToString('o')
    source_mods = $ModsPath
    files = $manifestFiles
}
$manifest | ConvertTo-Json -Depth 6 | Set-Content -Path (Join-Path $OutDir 'backup_manifest.json') -Encoding UTF8
Write-Output ('[backup] {0} files -> {1}' -f $manifestFiles.Count, $OutDir)
