<#
.SYNOPSIS
  Reconciles the AtomicHeart-AR mod inside the game's Paks\~mods folder to an exact set,
  and (re)writes the install manifest.

.DESCRIPTION
  User rules honoured here:
   - writes ONLY our mod paks + the install manifest into ~mods;
   - removes a superseded file ONLY if it was installed by us (its on-disk sha256 matches
     the previous manifest) - a mismatch is reported and aborts the install;
   - never touches AtomicHeart.exe, DLLs, Steam/Denuvo files, any stock pak, or anything
     else anywhere in the game folder;
   - leaves the folder in exactly the requested set, then verifies it and prints hashes.

  Default set = carrier ko-KR p3 + font v2 (DEC-024 pilot set). The superseded carrier p2
  is removed automatically on first run.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$Carrier = 'p3',              # carrier variant -> zzz_atomicheart-ar_carrier_koKR_<Carrier>_P.pak
    [string]$Font = 'p2_plex',            # font variant    -> zzz_atomicheart-ar_font_<Font>_P.pak
    [string]$CarrierFile = '',            # optional explicit carrier file name
    [string]$FontFile = '',               # optional explicit font file name
    [switch]$Force
)
$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

$game = Get-Content (Join-Path $RepoRoot 'config\game.json') -Raw | ConvertFrom-Json
$modsPath = $game.mods_path
$paksDir = $game.paks_path
if (-not $paksDir -or -not (Test-Path $paksDir)) { throw "game paks directory not found: $paksDir" }

$carrierName = if ($CarrierFile) { $CarrierFile } else { "zzz_atomicheart-ar_carrier_koKR_${Carrier}_P.pak" }
$fontName    = if ($FontFile)    { $FontFile }    else { "zzz_atomicheart-ar_font_${Font}_P.pak" }
$installSet = @($carrierName, $fontName)

$buildDir = Join-Path $RepoRoot 'build\package'
$resolved = @{}
foreach ($name in $installSet) {
    $p = Join-Path $buildDir $name
    if (-not (Test-Path $p)) { throw "build output missing: $p (build it first)" }
    $resolved[$name] = Get-Item $p
}

$manifestPath = Join-Path $modsPath 'atomic-heart-ar-install-manifest.json'
$removed = New-Object System.Collections.Generic.List[string]
$removedHashes = New-Object System.Collections.Generic.List[object]

if (Test-Path $modsPath) {
    $existing = @(Get-ChildItem $modsPath -File)
    if (Test-Path $manifestPath) {
        $old = Get-Content $manifestPath -Raw | ConvertFrom-Json
        foreach ($f in $old.files) {
            if ($installSet -contains $f.file) { continue }        # will be overwritten / kept
            $p = Join-Path $modsPath $f.file
            if (-not (Test-Path $p)) { Write-Host ("[SKIP] superseded file already absent: {0}" -f $f.file); continue }
            $onDisk = (Get-FileHash $p -Algorithm SHA256).Hash.ToLower()
            if ($onDisk -ne $f.sha256) {
                $msg = "hash mismatch for superseded file {0}: on-disk {1} != manifest {2}; NOT deleted" -f $f.file, $onDisk, $f.sha256
                if (-not $Force) { throw ($msg + ' (refusing to delete a file we did not install)') }
                Write-Host ('[REFUSE] ' + $msg)
                continue
            }
            Remove-Item $p -Force
            $removed.Add($f.file)
            $removedHashes.Add([pscustomobject]@{ file = $f.file; sha256 = $onDisk; size = $f.size })
            Write-Host ("[OK] removed superseded (hash-verified): {0}" -f $f.file)
        }
    } elseif ($existing.Count -gt 0 -and -not $Force) {
        throw ("~mods contains files but no install manifest; refusing: " + (($existing | ForEach-Object { $_.Name }) -join ', '))
    }
} else {
    New-Item -ItemType Directory -Path $modsPath | Out-Null
    Write-Host ("[OK] created ~mods: {0}" -f $modsPath)
}

$installed = New-Object System.Collections.Generic.List[object]
foreach ($name in $installSet) {
    $src = $resolved[$name]
    $destPath = Join-Path $modsPath $name
    Copy-Item $src.FullName $destPath -Force
    $hash = (Get-FileHash $destPath -Algorithm SHA256).Hash.ToLower()
    $installed.Add([pscustomobject]@{
        file              = $name
        source_build_path = 'build\package\' + $name
        size              = $src.Length
        sha256            = $hash
        installed_utc     = (Get-Date).ToUniversalTime().ToString('o')
    })
    Write-Host ("[OK] installed: {0} ({1} bytes)" -f $name, $src.Length)
}

$manifest = [pscustomobject]@{
    project       = 'AtomicHeart-AR'
    phase         = 'phase7 prototype -> translation program pilot'
    installed_utc = (Get-Date).ToUniversalTime().ToString('o')
    game_build_id = $game.steam_build_id
    variant       = ('carrier=' + $carrierName + ' ; font=' + $fontName)
    files         = $installed
    superseded    = $removedHashes
    notes         = 'Remove with scripts/uninstall_mod.ps1 only. These paks are the ONLY files this project installs into the game folder. Pilot set (DEC-024): carrier ko-KR p3 (all 35 ko-KR scopes, 85 Arabic rows, English fill) + font v2 (IBM Plex Sans Arabic dual-script).'
}
$manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $manifestPath -Encoding UTF8
Write-Host ("[DONE] manifest: {0}" -f $manifestPath)

# --- immediate verification: ~mods must hold EXACTLY the install set + manifest
$present = @(Get-ChildItem $modsPath -File | Sort-Object Name)
$expected = @($installSet + 'atomic-heart-ar-install-manifest.json') | Sort-Object
$names = @($present | ForEach-Object { $_.Name })
$ok = ($names.Count -eq $expected.Count)
foreach ($e in $expected) { if ($names -notcontains $e) { $ok = $false } }
Write-Host ''
Write-Host ('[VERIFY] ~mods contains exactly {0} files: {1}' -f $present.Count, ($names -join ', '))
foreach ($f in $present) {
    Write-Host ('   {0}  {1} bytes  sha256={2}' -f $f.Name.PadRight(46), $f.Length, (Get-FileHash $f.FullName -Algorithm SHA256).Hash.ToLower())
}
Write-Host ('[VERIFY] exact expected set present: ' + $ok)
if (-not $ok) { throw 'install verification failed: ~mods contents do not match the requested set' }
Write-Host ('[DONE] installed and verified; removed superseded files: {0}' -f $(if ($removed.Count) { $removed -join ', ' } else { 'none' }))
