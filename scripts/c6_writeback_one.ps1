param(
    [Parameter(Mandatory=$true)][string]$Asset,
    [Parameter(Mandatory=$true)][string]$Map,
    [Parameter(Mandatory=$true)][string]$Src,
    [Parameter(Mandatory=$true)][string]$OutRoot,
    [Parameter(Mandatory=$true)][string]$JsonRoot,
    [string]$MapDir = 'build\c6\maps_all'
)
$ErrorActionPreference = 'Stop'
$repo = 'C:\AtomicHeart-AR'
$tool = Join-Path $repo 'tools\src\uasettool\bin\Release\net8.0\uasettool.exe'
$srcU = Join-Path $repo $Src
if (-not (Test-Path $srcU)) { throw 'missing src ' + $srcU }
$rel = $Asset -replace '/', '\'
$outU = Join-Path $OutRoot $rel
New-Item -ItemType Directory -Force -Path (Split-Path $outU -Parent) | Out-Null
Copy-Item $srcU $outU -Force
$srcX = [IO.Path]::ChangeExtension($srcU, '.uexp')
if (Test-Path $srcX) { Copy-Item $srcX ([IO.Path]::ChangeExtension($outU, '.uexp')) -Force }

$mapPath = Join-Path $repo (Join-Path $MapDir $Map)
& $tool settext $outU $mapPath $outU --strict
if ($LASTEXITCODE -ne 0) { throw ('settext failed ' + $LASTEXITCODE) }

$jsonOut = Join-Path $JsonRoot (($rel -replace '\\', '__') + '.json')
New-Item -ItemType Directory -Force -Path (Split-Path $jsonOut -Parent) | Out-Null
& $tool dump $outU $jsonOut | Out-Null
Write-Output ('wrote ' + $outU + ' | json ' + $jsonOut)
