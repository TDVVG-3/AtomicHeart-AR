<#
.SYNOPSIS
  Generic single-file extractor from a game pak into the project's gitignored area.
  Used by build/analysis scripts; never writes to the game folder.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Pak,
    [Parameter(Mandatory = $true)][string]$Entry,          # full path as shown by repak list
    [Parameter(Mandatory = $true)][string]$OutFile,
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
$repak = Join-Path $RepoRoot 'tools\bin\repak\repak.exe'
if (-not (Test-Path $repak)) { throw "repak not found: $repak" }
$destDir = Split-Path $OutFile -Parent
if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
$tmp = "$OutFile.tmp"
cmd /c "`"$repak`" get `"$Pak`" `"$Entry`" > `"$tmp`"" 2>$null
if ((Test-Path $tmp) -and ((Get-Item $tmp).Length -gt 0)) {
    Move-Item $tmp $OutFile -Force
    Write-Output ("[OK] {0} -> {1} ({2} bytes)" -f $Entry, $OutFile, (Get-Item $OutFile).Length)
} else {
    if (Test-Path $tmp) { Remove-Item $tmp -Force }
    throw "repak get failed for: $Entry"
}
