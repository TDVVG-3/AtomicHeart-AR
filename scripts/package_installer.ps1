[CmdletBinding()]
param([string]$PayloadZip = '')
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$version = '1.0.2'
$stage = Join-Path $repo ('build\installer-' + [guid]::NewGuid().ToString('N'))
$name = if ($PayloadZip) { 'AtomicHeart-AR-' + $version + '-win-x64' } else { 'AtomicHeart-AR-AppOnly-' + $version + '-win-x64' }
$bundle = Join-Path $stage $name
New-Item -ItemType Directory -Path $bundle -Force | Out-Null
$env:MSBuildEnableWorkloadResolver = 'false'
& dotnet publish (Join-Path $repo 'app\AtomicHeartAR.Installer\AtomicHeartAR.Installer.csproj') -c Release -r win-x64 --self-contained true -t:Rebuild -o $bundle
if ($LASTEXITCODE -ne 0) { throw 'Application publish failed.' }

if ($PayloadZip) {
    $zipPath = (Resolve-Path -LiteralPath $PayloadZip).Path
    $expectedZipHash = '078bd3a295a7947d8deec249250608b3bb52cfbfcfc258b86ae33a5f74cc0eb5'
    if ((Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expectedZipHash) {
        throw 'Payload ZIP does not match the approved 1.0.2 translation payload.'
    }
    $expected = @{}
    foreach ($line in [IO.File]::ReadAllLines((Join-Path $repo 'docs\releases\v1.0.2-payload-SHA256SUMS.txt'))) {
        $fields = $line -split '\s+', 2
        if ($fields.Count -eq 2) { $expected[$fields[1].Trim()] = $fields[0] }
    }
    if ($expected.Count -ne 3) { throw 'Expected exactly three approved payload PAKs.' }
    $payload = Join-Path $bundle 'payload'
    New-Item -ItemType Directory -Path $payload | Out-Null
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [IO.Compression.ZipFile]::OpenRead($zipPath)
    try {
        foreach ($file in $expected.Keys) {
            $entries = @($archive.Entries | Where-Object { $_.FullName -ceq ('payload/' + $file) })
            if ($entries.Count -ne 1 -or $entries[0].Length -gt 10MB) { throw ('Invalid payload entry: ' + $file) }
            $target = Join-Path $payload $file
            [IO.Compression.ZipFileExtensions]::ExtractToFile($entries[0], $target)
            if ((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected[$file]) {
                throw ('Payload hash mismatch: ' + $file)
            }
        }
    } finally { $archive.Dispose() }
    Copy-Item -LiteralPath (Join-Path $repo 'docs\releases\v1.0.2-payload-SHA256SUMS.txt') -Destination (Join-Path $payload 'SHA256SUMS.txt')
    Copy-Item -LiteralPath (Join-Path $repo 'fonts\licenses\IBM-Plex-Sans-Arabic-OFL-1.1.txt') -Destination $bundle
}
$assets = Get-Content -LiteralPath (Join-Path $repo 'app\AtomicHeartAR.Installer\obj\project.assets.json') -Raw | ConvertFrom-Json
foreach ($framework in $assets.project.frameworks.PSObject.Properties.Value) {
    foreach ($dependency in $framework.downloadDependencies) {
        if ($dependency.name -notin @('Microsoft.NETCore.App.Runtime.win-x64', 'Microsoft.WindowsDesktop.App.Runtime.win-x64')) { continue }
        if ($dependency.version -notmatch '^\[([^,\]]+)') { throw 'Unknown runtime package version.' }
        $runtimeVersion = $Matches[1]
        $runtimeFolder = $null
        foreach ($packageRoot in $assets.packageFolders.PSObject.Properties.Name) {
            $candidate = Join-Path $packageRoot ($dependency.name.ToLowerInvariant() + '\' + $runtimeVersion)
            if (Test-Path -LiteralPath $candidate) { $runtimeFolder = $candidate; break }
        }
        if (-not $runtimeFolder) { throw 'Runtime redistribution notices not found.' }
        $notices = Join-Path $bundle ('licenses\' + $dependency.name)
        New-Item -ItemType Directory -Path $notices -Force | Out-Null
        $licenseFound = $false
        foreach ($notice in @('LICENSE', 'LICENSE.TXT', 'THIRD-PARTY-NOTICES.TXT')) {
            $noticePath = Join-Path $runtimeFolder $notice
            if (Test-Path -LiteralPath $noticePath) {
                Copy-Item -LiteralPath $noticePath -Destination $notices
                if ($notice -like 'LICENSE*') { $licenseFound = $true }
            }
        }
        if (-not $licenseFound) { throw 'Runtime redistribution license not found.' }
    }
}
$testRoot = Join-Path $repo ('build\installer-tests-' + [guid]::NewGuid().ToString('N'))
$testArgs = @('run', '--project', (Join-Path $repo 'app\AtomicHeartAR.Tests'), '-c', 'Release', '--', $testRoot)
if ($PayloadZip) { $testArgs += (Join-Path $bundle 'payload') }
& dotnet @testArgs
if ($LASTEXITCODE -ne 0) { throw 'Installer safety tests failed; refusing to create release ZIP.' }
Copy-Item -LiteralPath (Join-Path $repo 'LICENSE') -Destination $bundle
Copy-Item -LiteralPath (Join-Path $repo 'THIRD_PARTY_LICENSES.md') -Destination $bundle
Copy-Item -LiteralPath (Join-Path $repo 'app\README.md') -Destination (Join-Path $bundle 'README.md')
$dist = Join-Path $repo 'dist'
New-Item -ItemType Directory -Path $dist -Force | Out-Null
$outputZip = Join-Path $dist ($name + '.zip')
if (Test-Path -LiteralPath $outputZip) { Remove-Item -LiteralPath $outputZip }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory($stage, $outputZip, [IO.Compression.CompressionLevel]::Optimal, $false)
$hash = (Get-FileHash -LiteralPath $outputZip -Algorithm SHA256).Hash.ToLowerInvariant()
[IO.File]::WriteAllText(($outputZip + '.sha256'), ($hash + '  ' + [IO.Path]::GetFileName($outputZip) + [Environment]::NewLine), (New-Object Text.UTF8Encoding($false)))
Write-Output ('PACKAGE: ' + $outputZip)
Write-Output ('SHA256: ' + $hash)
