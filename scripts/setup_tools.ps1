<#
.SYNOPSIS
  Downloads and verifies the third-party toolchain into tools/bin (portable, gitignored).

.DESCRIPTION
  Reads tools/tools.lock.json and, for each tool with a download_url:
    - downloads the asset from the official GitHub release URL,
    - computes SHA256,
    - compares it against the lock entry when an upstream digest exists,
    - extracts .zip archives (FModel, repak) with Expand-Archive,
    - extracts .7z archives (LocResUtility) with 7-Zip if present,
    - leaves single-executable assets (UnrealLocres.exe, UAssetGUI.exe) as-is,
    - writes the computed hash back into tools/bin/toolhashes.json.

  Nothing is installed system-wide. Everything lands under tools/bin.
  The game folder is never touched.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)

$ErrorActionPreference = 'Stop'
$lockPath = Join-Path $RepoRoot 'tools\tools.lock.json'
$binRoot = Join-Path $RepoRoot 'tools\bin'
New-Item -ItemType Directory -Force -Path $binRoot | Out-Null

$lock = Get-Content $lockPath -Raw | ConvertFrom-Json
$computedHashes = @()
$failures = @()

foreach ($t in $lock.tools) {
    if (-not $t.download_url) {
        Write-Host ("[SKIP] {0} - no download URL (manual/proprietary acquisition)" -f $t.tool)
        continue
    }

    $dest = Join-Path $binRoot $t.asset
    Write-Host ("[GET ] {0} {1} from {2}" -f $t.tool, $t.version, $t.download_url)

    if (-not (Test-Path $dest)) {
        try {
            Invoke-WebRequest -Uri $t.download_url -OutFile $dest -UseBasicParsing -MaximumRedirection 5
        }
        catch {
            Write-Host ("       DOWNLOAD FAILED: {0}" -f $_.Exception.Message)
            $failures += "$($t.tool): download failed"
            continue
        }
    }
    else {
        Write-Host '       already downloaded, reusing local copy'
    }

    $hash = (Get-FileHash -Path $dest -Algorithm SHA256).Hash.ToLower()
    $computedHashes += [pscustomobject]@{ tool = $t.tool; asset = $t.asset; sha256 = $hash }

    $expected = if ($t.sha256_source -like 'upstream*') { $t.sha256.ToLower() } else { $null }
    if ($expected) {
        if ($hash -eq $expected) {
            Write-Host ("       SHA256 OK (matches upstream): {0}" -f $hash)
        }
        else {
            Write-Host ("       SHA256 MISMATCH! expected={0} actual={1}" -f $expected, $hash)
            $failures += "$($t.tool): SHA256 mismatch"
            continue
        }
    }
    else {
        Write-Host ("       SHA256 computed (no upstream digest): {0}" -f $hash)
    }

    # Extract archives; keep executables as-is
    $targetDir = Join-Path $binRoot ($t.tool.ToLower() -replace '[^a-z0-9]', '')
    switch -Wildcard ($t.asset) {
        '*.zip' {
            if (-not (Test-Path $targetDir)) {
                Expand-Archive -Path $dest -DestinationPath $targetDir
                Write-Host ("       extracted to {0}" -f $targetDir)
            }
        }
        '*.7z' {
            $sevenZip = @(
                "$env:ProgramFiles\7-Zip\7z.exe",
                "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
            ) | Where-Object { Test-Path $_ } | Select-Object -First 1
            if ($sevenZip) {
                if (-not (Test-Path $targetDir)) {
                    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
                    & $sevenZip x -y -o"$targetDir" $dest | Out-Null
                    Write-Host ("       extracted with 7-Zip to {0}" -f $targetDir)
                }
            }
            else {
                Write-Host '       7-Zip NOT FOUND - .7z left unextracted (install 7-Zip or extract manually)'
                $failures += "$($t.tool): 7z extraction skipped (no 7-Zip)"
            }
        }
        default {
            New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
            Copy-Item $dest (Join-Path $targetDir $t.asset) -Force
            Write-Host ("       copied to {0}" -f $targetDir)
        }
    }
}

$hashOut = Join-Path $binRoot 'toolhashes.json'
$computedHashes | ConvertTo-Json -Depth 3 | Set-Content $hashOut -Encoding UTF8
Write-Host ''
Write-Host ("[DONE] Tool hashes written to {0}" -f $hashOut)
if ($failures.Count -gt 0) {
    Write-Host '[WARN] Problems:'
    $failures | ForEach-Object { Write-Host ("       - {0}" -f $_) }
    exit 1
}
exit 0
