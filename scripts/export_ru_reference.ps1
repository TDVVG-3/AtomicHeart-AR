<#
.SYNOPSIS
  Exports the extracted ru-RU locres files to CSV so the Russian source text is
  available for tone checks (KI-028 / terminology decisions).

.DESCRIPTION
  - Input: localization/extracted/AtomicHeart/Content/Localization/<Scope>/ru-RU/<Scope>.locres
  - Output: localization/extracted/ru_csv/<Scope>.csv  (gitignored workspace reference,
    regenerate any time; never committed as raw game data).
  - The CSV layout is the UnrealLocres export layout: "<key>,<text>,".
  - Console prints non-Latin text as "?", so verify results by reading the CSV files.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\export_ru_reference.ps1
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)

$ErrorActionPreference = 'Stop'
$locresExe = Join-Path $RepoRoot 'tools\bin\unreallocres\UnrealLocres.exe'
$srcRoot   = Join-Path $RepoRoot 'localization\extracted\AtomicHeart\Content\Localization'
$outRoot   = Join-Path $RepoRoot 'localization\extracted\ru_csv'

if (-not (Test-Path $locresExe)) { throw "UnrealLocres not found at $locresExe" }
if (-not (Test-Path $outRoot)) { New-Item -ItemType Directory -Force -Path $outRoot | Out-Null }

$inFiles = Get-ChildItem $srcRoot -Recurse -File -Filter '*.locres' |
    Where-Object { $_.FullName -match '\\ru-RU\\' } | Sort-Object FullName
Write-Host ("[OK] ru-RU locres found: {0}" -f $inFiles.Count)

$done = 0
foreach ($f in $inFiles) {
    $scope = $f.BaseName
    $out   = Join-Path $outRoot ("$scope.csv")
    cmd /c "`"$locresExe`" export -o `"$out`" `"$($f.FullName)`"" | Out-Null
    if (Test-Path $out) {
        $done++
        Write-Host ("  [OK] {0} -> {1} bytes" -f $scope, (Get-Item $out).Length)
    } else {
        Write-Host ("  [WARN] export failed: {0}" -f $scope)
    }
}

Write-Host ("[DONE] exported {0} of {1} ru-RU scopes to {2}" -f $done, $inFiles.Count, $outRoot)
