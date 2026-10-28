$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
$repo = 'C:\AtomicHeart-AR'
$repak = Join-Path $repo 'tools\bin\repak\repak.exe'
$outRoot = Join-Path $repo 'build\c6\out'
$stage = Join-Path $repo 'build\c6\pakstage'
$pak = Join-Path $repo 'build\package\zzz_atomicheart-ar_ruonly_p1_P.pak'
$unpack = Join-Path $repo 'build\c6\pak_unpack'

if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force -Path $stage | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path $pak -Parent) | Out-Null
if (Test-Path $pak) { Remove-Item $pak -Force }
if (Test-Path $unpack) { Remove-Item $unpack -Recurse -Force }

$copied = 0
foreach ($pakDir in (Get-ChildItem $outRoot -Directory)) {
    $content = Join-Path $pakDir.FullName 'AtomicHeart'
    if (-not (Test-Path $content)) { throw ('missing AtomicHeart under ' + $pakDir.FullName) }
    Copy-Item $content $stage -Recurse -Force
    $copied++
}
Write-Output ('staged from ' + $copied + ' pak folders')

$assets = @(Get-ChildItem $stage -Recurse -Filter '*.uasset')
$uexps = @(Get-ChildItem $stage -Recurse -Filter '*.uexp')
Write-Output ('stage uasset ' + $assets.Count + ' uexp ' + $uexps.Count)
if ($assets.Count -ne 248 -or $uexps.Count -ne 248) { throw 'unexpected staged file count' }

$packOut = & $repak pack --version V11 --mount-point '../../../' $stage $pak 2>&1
Write-Output (($packOut | Select-Object -Last 3) -join ' ')
if (-not (Test-Path $pak)) { throw 'repak pack failed: no pak' }

$list = @(& $repak list $pak)
Write-Output ('pak entries ' + $list.Count)
$badPrefix = @($list | Where-Object { $_ -notmatch '^AtomicHeart/Content/' })
if ($badPrefix.Count -gt 0) { throw ('bad internal paths: ' + ($badPrefix | Select-Object -First 3 -join '; ')) }
if ($list.Count -ne 496) { throw ('unexpected pak entry count ' + $list.Count) }

& $repak unpack $pak --output $unpack 2>&1 | Out-Null
if (-not (Test-Path $unpack)) { throw 'repak unpack failed' }

$mismatch = 0
$checkCount = 0
$manifest = New-Object System.Collections.Generic.List[string]
$manifest.Add("asset`tuasset_bytes`tuasset_sha256`tuexp_bytes`tuexp_sha256")
function Compare-Bytes([string]$a, [string]$b) {
    $ba = [IO.File]::ReadAllBytes($a)
    $bb = [IO.File]::ReadAllBytes($b)
    if ($ba.Length -ne $bb.Length) { return $false }
    for ($i = 0; $i -lt $ba.Length; $i++) { if ($ba[$i] -ne $bb[$i]) { return $false } }
    return $true
}
foreach ($a in $assets) {
    $rel = $a.FullName.Substring($stage.Length + 1)
    $u = Join-Path $unpack $rel
    $xRel = [IO.Path]::ChangeExtension($rel, '.uexp')
    $x = Join-Path $unpack $xRel
    if (-not (Test-Path $u)) { throw ('unpacked uasset missing: ' + $rel) }
    if (-not (Test-Path $x)) { throw ('unpacked uexp missing: ' + $xRel) }
    if (-not (Compare-Bytes $a.FullName $u)) { $mismatch++ }
    if (-not (Compare-Bytes ([IO.Path]::ChangeExtension($a.FullName, '.uexp')) $x)) { $mismatch++ }
    $checkCount += 2
    $shaU = (Get-FileHash $a.FullName -Algorithm SHA256).Hash
    $shaX = (Get-FileHash ([IO.Path]::ChangeExtension($a.FullName, '.uexp')) -Algorithm SHA256).Hash
    $relFwd = $rel -replace '\\', '/'
    $manifest.Add($relFwd + "`t" + $a.Length + "`t" + $shaU + "`t" + (Get-Item ([IO.Path]::ChangeExtension($a.FullName, '.uexp'))).Length + "`t" + $shaX)
}
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\pak_manifest.tsv'), $manifest, (New-Object Text.UTF8Encoding($false)))
$pakItem = Get-Item $pak
$sha = (Get-FileHash $pak -Algorithm SHA256).Hash
$report = New-Object System.Collections.Generic.List[string]
$report.Add('pak=' + $pak)
$report.Add('bytes=' + $pakItem.Length)
$report.Add('sha256=' + $sha)
$report.Add('entries=' + $list.Count)
$report.Add('assets=248')
$report.Add('compare_files=' + $checkCount)
$report.Add('byte_mismatches=' + $mismatch)
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\pak_build_report.txt'), $report, (New-Object Text.UTF8Encoding($false)))
Write-Output ('PAK ' + $pak)
Write-Output ('SIZE ' + $pakItem.Length)
Write-Output ('SHA256 ' + $sha)
Write-Output ('COMPARE ' + $checkCount + ' mismatches ' + $mismatch)
if ($mismatch -ne 0) { throw 'pak round-trip mismatch' }
