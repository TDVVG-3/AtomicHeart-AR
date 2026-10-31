<#
.SYNOPSIS
  Packages the AtomicHeart-AR 1.0.3 payload ZIPs from the gated carriers.
.DESCRIPTION
  Verifies the exact carrier/font/tips hashes, writes README-INSTALL.txt and
  SHA256SUMS.txt into each payload set, then creates deterministic ZIPs in dist/.
  The source archive is produced separately from the release tag.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$version = '1.0.3'
$utf8 = New-Object Text.UTF8Encoding($false)
$packageDir = Join-Path $RepoRoot 'build\package'
$stageRoot = Join-Path $RepoRoot ('build\release\' + $version)
$dist = Join-Path $RepoRoot 'dist'
New-Item -ItemType Directory -Force -Path $stageRoot, $dist | Out-Null

$fontName = 'zzz_atomicheart-ar_font_p3_unhinted_P.pak'
$tipsName = 'zzz_atomicheart-ar_tips_x150_P.pak'
$fontHash = 'f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4'
$tipsHash = '36de01c37231a8b88ec9fc744c4f663bb8461a56adede9a6a2151d78c7ef7fcc'

function Sha256([string]$path) {
    return (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function New-Payload([string]$label, [string]$carrierSource, [string]$carrierName, [string]$readmeSource, [string]$carrierHash) {
    $dir = Join-Path $stageRoot ($label + '_payload')
    if (Test-Path -LiteralPath $dir) { Remove-Item -LiteralPath $dir -Recurse -Force }
    New-Item -ItemType Directory -Path $dir | Out-Null

    if (-not (Test-Path -LiteralPath $carrierSource)) { throw ('missing carrier: ' + $carrierSource) }
    if ((Sha256 $carrierSource) -ne $carrierHash) { throw ('carrier hash mismatch: ' + $carrierSource) }
    Copy-Item -LiteralPath $carrierSource -Destination (Join-Path $dir $carrierName)
    Copy-Item -LiteralPath (Join-Path $packageDir $fontName) -Destination (Join-Path $dir $fontName)
    Copy-Item -LiteralPath (Join-Path $packageDir $tipsName) -Destination (Join-Path $dir $tipsName)
    Copy-Item -LiteralPath $readmeSource -Destination (Join-Path $dir 'README-INSTALL.txt')

    foreach ($pair in @(@($carrierName, $carrierHash), @($fontName, $fontHash), @($tipsName, $tipsHash))) {
        $actual = Sha256 (Join-Path $dir $pair[0])
        if ($actual -ne $pair[1]) { throw ('packaged hash mismatch: ' + $pair[0]) }
    }
    $sumLines = @(
        ($carrierHash + '  ' + $carrierName),
        ($fontHash + '  ' + $fontName),
        ($tipsHash + '  ' + $tipsName)
    )
    [IO.File]::WriteAllLines((Join-Path $dir 'SHA256SUMS.txt'), $sumLines, $utf8)
    return $dir
}

function New-DeterministicZip([string]$srcDir, [string]$zipPath) {
    Add-Type -AssemblyName System.IO.Compression | Out-Null
    if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
    $names = @('README-INSTALL.txt', 'SHA256SUMS.txt') + @(Get-ChildItem -LiteralPath $srcDir -File | Where-Object { $_.Extension -eq '.pak' } | Sort-Object Name | ForEach-Object { $_.Name })
    $stream = [IO.File]::Open($zipPath, [IO.FileMode]::Create, [IO.FileAccess]::Write, [IO.FileShare]::None)
    try {
        $archive = New-Object IO.Compression.ZipArchive($stream, [IO.Compression.ZipArchiveMode]::Create, $false)
        try {
            foreach ($name in $names) {
                $entry = $archive.CreateEntry($name, [IO.Compression.CompressionLevel]::Optimal)
                $entry.LastWriteTime = [DateTimeOffset]::new(2026, 10, 31, 0, 0, 0, [TimeSpan]::Zero)
                $bytes = [IO.File]::ReadAllBytes((Join-Path $srcDir $name))
                $s = $entry.Open()
                try { $s.Write($bytes, 0, $bytes.Length) } finally { $s.Dispose() }
            }
        } finally { $archive.Dispose() }
    } finally { $stream.Dispose() }
}

$p12Dir = New-Payload 'p12' (Join-Path $packageDir 'zzz_atomicheart-ar_carrier_koKR_p12_103_P.pak') 'zzz_atomicheart-ar_carrier_koKR_p12_P.pak' (Join-Path $RepoRoot 'docs\releases\v1.0.3\README-INSTALL-p12.txt') '69475f3548198e23733d833c7e577cf256eed0d875c1bb12f4cac3c2b57c9212'
$p12gDir = New-Payload 'p12g' (Join-Path $packageDir 'zzz_atomicheart-ar_carrier_koKR_p12g_103_P.pak') 'zzz_atomicheart-ar_carrier_koKR_p12g_P.pak' (Join-Path $RepoRoot 'docs\releases\v1.0.3\README-INSTALL-p12g.txt') '1cc7963d13a6eda77babf1f3617189d1ec2c5153455d16306f67e9e1c8b77dc9'

$p12Zip = Join-Path $dist ('AtomicHeart-AR-' + $version + '-p12.zip')
$p12gZip = Join-Path $dist ('AtomicHeart-AR-' + $version + '-p12g-experimental.zip')
New-DeterministicZip $p12Dir $p12Zip
New-DeterministicZip $p12gDir $p12gZip

$p12ZipHash = Sha256 $p12Zip
$p12gZipHash = Sha256 $p12gZip
[IO.File]::WriteAllText(($p12Zip + '.sha256'), ($p12ZipHash + '  ' + [IO.Path]::GetFileName($p12Zip) + "`n"), $utf8)
[IO.File]::WriteAllText(($p12gZip + '.sha256'), ($p12gZipHash + '  ' + [IO.Path]::GetFileName($p12gZip) + "`n"), $utf8)

[pscustomobject]@{
    p12_zip = $p12Zip
    p12_size = (Get-Item -LiteralPath $p12Zip).Length
    p12_sha256 = $p12ZipHash
    p12g_zip = $p12gZip
    p12g_size = (Get-Item -LiteralPath $p12gZip).Length
    p12g_sha256 = $p12gZipHash
} | ConvertTo-Json
