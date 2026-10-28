param(
    [string]$MapDir = 'build\c6\maps_all',
    [string]$Manifest = 'build\c6\maps_all_manifest.tsv',
    [string]$StatusPath = 'build\c6\writeback_status.tsv',
    [int]$MaxAssets = 0
)
$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
$repo = 'C:\AtomicHeart-AR'
$tool = Join-Path $repo 'tools\src\uasettool\bin\Release\net8.0\uasettool.exe'
$manifestPath = Join-Path $repo $Manifest
$manifestRows = New-Object System.Collections.Generic.List[object]
$mlines = [IO.File]::ReadAllLines($manifestPath, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $mlines.Count; $i++) {
    if ($mlines[$i].Length -eq 0) { continue }
    $c = $mlines[$i] -split "`t"
    if ($c.Count -lt 3) { continue }
    $manifestRows.Add([pscustomobject]@{ idx = $c[0]; asset = $c[1]; map = $c[2]; rows = $c[3]; distinct_targets = $c[4] })
}
$scanPath = Join-Path $repo 'reports\dialogue_st_counts.tsv'
$slines = [IO.File]::ReadAllLines($scanPath, [Text.Encoding]::UTF8)
$shead = $slines[0] -split "`t"
$pathIdx = [Array]::IndexOf($shead, 'path')
$pakIdx = [Array]::IndexOf($shead, 'pak')
$pakByAsset = @{}
for ($i = 1; $i -lt $slines.Count; $i++) {
    if ($slines[$i].Length -eq 0) { continue }
    $c = $slines[$i] -split "`t"
    if ($c.Count -le [Math]::Max($pathIdx, $pakIdx)) { continue }
    $pakByAsset[$c[$pathIdx]] = $c[$pakIdx]
}

$outRoot = Join-Path $repo 'build\c6\out'
$jsonRoot = Join-Path $repo 'build\c6\json_out'
New-Item -ItemType Directory -Force -Path $outRoot | Out-Null
New-Item -ItemType Directory -Force -Path $jsonRoot | Out-Null
$statusPath = Join-Path $repo $StatusPath
$status = New-Object System.Collections.Generic.List[string]
if (Test-Path $statusPath) { $status.AddRange([IO.File]::ReadAllLines($statusPath, [Text.Encoding]::UTF8)) }
else { $status.Add("idx`tasset`tstatus`tchanged`tmapRows`tmissing`tdetail") }
$done = @{}
foreach ($line in $status | Select-Object -Skip 1) {
    $c = $line -split "`t"
    if ($c.Count -ge 3 -and -not [string]::IsNullOrEmpty($c[1]) -and $c[2] -eq 'OK') { $done[$c[1]] = $true }
}

$ok = 0; $skip = 0; $fail = 0; $seenCount = 0
foreach ($m in $manifestRows) {
    $seenCount++
    if ($MaxAssets -gt 0 -and $seenCount -gt $MaxAssets) { break }
    if ($null -eq $m.asset) { Write-Output ('NULL asset at row ' + $m.idx); $fail++; continue }
    if ($done.ContainsKey($m.asset)) { $skip++; continue }
    $pak = $pakByAsset[$m.asset]
    if (-not $pak) { $status.Add(($m.idx + "`t" + $m.asset + "`tSKIP`t0`t0`t0`tno pak mapping")); $fail++; continue }
    $srcU = Join-Path $repo ('build\c6\src\' + $pak + '\' + ($m.asset -replace '/', '\'))
    if (-not (Test-Path $srcU)) { $status.Add(($m.idx + "`t" + $m.asset + "`tSKIP`t0`t0`t0`tsource missing")); $fail++; continue }
    $outU = Join-Path $outRoot ($pak + '\' + ($m.asset -replace '/', '\'))
    New-Item -ItemType Directory -Force -Path (Split-Path $outU -Parent) | Out-Null
    Copy-Item $srcU $outU -Force
    $srcX = [IO.Path]::ChangeExtension($srcU, '.uexp')
    if (Test-Path $srcX) { Copy-Item $srcX ([IO.Path]::ChangeExtension($outU, '.uexp')) -Force }
    $mapPath = Join-Path $repo (Join-Path $MapDir $m.map)

    $lines = & $tool settext $outU $mapPath $outU 2>&1
    $rc = $LASTEXITCODE
    $changed = 0; $mapRows = 0; $missing = 0
    foreach ($l in $lines) {
        if ($l -match '^changed=(\d+) mapRows=(\d+) missing=(\d+)') { $changed = [int]$matches[1]; $mapRows = [int]$matches[2]; $missing = [int]$matches[3] }
        elseif ($l -match '^MISSING') { }
    }
    if ($rc -ne 0) {
        $status.Add(($m.idx + "`t" + $m.asset + "`tFAIL`t0`t0`t0`t" + (($lines -join ' | ') -replace "`t", ' ')))
        $fail++
        continue
    }
    if ($missing -gt 0) {
        $status.Add(($m.idx + "`t" + $m.asset + "`tMISSING`t$changed`t$mapRows`t$missing`tpartial; not accepted"))
        $fail++
        continue
    }
    $jsonOut = Join-Path $jsonRoot ($pak + '\' + ($m.asset -replace '/', '\') + '.json')
    New-Item -ItemType Directory -Force -Path (Split-Path $jsonOut -Parent) | Out-Null
    & $tool dump $outU $jsonOut | Out-Null
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $jsonOut)) {
        $status.Add(($m.idx + "`t" + $m.asset + "`tDUMPFAIL`t$changed`t$mapRows`t0`t" ))
        $fail++
        continue
    }
    $status.Add(($m.idx + "`t" + $m.asset + "`tOK`t$changed`t$mapRows`t$missing`t"))
    $ok++
    if (($ok % 25) -eq 0) { Write-Output ('progress ok=' + $ok + ' fail=' + $fail + ' skip=' + $skip) }
}
[IO.File]::WriteAllLines($statusPath, $status, (New-Object Text.UTF8Encoding($false)))
Write-Output ('writeback OK=' + $ok + ' FAIL=' + $fail + ' SKIP=' + $skip)
