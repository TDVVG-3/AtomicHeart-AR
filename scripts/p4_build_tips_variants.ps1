$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

# P4.1 - build data-only tip/notification duration override paks.
# Edits only: DA_InputTipInfo.DurationTime (assets with bHasDuration=True) and
# WBP_ItemNotificationEntryWidget.WaitTime. Originals in build\p4 are never modified.
# Output paks go to build\package and are NOT installed.

$repo     = 'C:\AtomicHeart-AR'
$tool     = Join-Path $repo 'tools\bin\uasettool\uasettool.exe'
$repak    = Join-Path $repo 'tools\bin\repak\repak.exe'
$tipsSrc  = Join-Path $repo 'build\p4\tips_src'
$uiSrc    = Join-Path $repo 'build\p4\ui_src'
$pkgDir   = Join-Path $repo 'build\package'
$table    = Join-Path $repo 'build\p4\tip_durations.tsv'
$widgetRel = 'AtomicHeart/Content/Core/UI/HUD/Widgets/WBP_ItemNotificationEntryWidget'
$inv      = [Globalization.CultureInfo]::InvariantCulture

function Add-Props($o, $list) {
    if ($null -eq $o) { return }
    if ($o -is [System.Collections.IEnumerable] -and -not ($o -is [string])) { foreach ($i in $o) { Add-Props $i $list }; return }
    if ($o -is [PSCustomObject]) {
        $n = $null; try { $n = $o.Name } catch {}
        if ($n -and $null -ne $o.Value) {
            $v = $o.Value
            if ($v -is [string] -or $v -is [bool] -or $v -is [double] -or $v -is [single] -or $v -is [decimal] -or $v -is [int] -or $v -is [long]) {
                $list.Add([string]$n + '=' + [string]::Format($inv, '{0}', $v))
            }
        }
        foreach ($p in $o.PSObject.Properties) { Add-Props $p.Value $list }
    }
}
function Get-PropList([string]$jsonPath) {
    $l = New-Object System.Collections.Generic.List[string]
    Add-Props (Get-Content $jsonPath -Raw | ConvertFrom-Json) $l
    return ,$l
}
function Get-Float([string]$jsonPath, [string]$name) {
    $l = Get-PropList $jsonPath
    $hit = $l | Where-Object { $_ -like ($name + '=*') } | Select-Object -First 1
    if (-not $hit) { return $null }
    return [double]::Parse($hit.Substring($name.Length + 1), $inv)
}
function Compare-Props([string]$a, [string]$b, [string]$skip) {
    $la = @(Get-PropList $a) | Sort-Object
    $lb = @(Get-PropList $b) | Sort-Object
    $d = @(Compare-Object $la $lb)
    $bad = @($d | Where-Object { $_.InputObject -notlike ($skip + '=*') })
    if ($bad.Count -eq 0) { return 'same' }
    return ('DIFF:' + (($bad | ForEach-Object { $_.SideIndicator + $_.InputObject }) -join ';'))
}

# --- timed tips (bHasDuration=True only)
$rows = [IO.File]::ReadAllLines($table, [Text.Encoding]::UTF8) | Select-Object -Skip 1 |
    ForEach-Object { $f = $_ -split "`t"; if ($f.Count -ge 5) { [pscustomobject]@{ asset=$f[0]; has=$f[2]; dur=$f[3] } } }
$timed = @($rows | Where-Object { $_.has -eq 'True' -and $_.dur -ne '' })
Write-Output ('timed tips: ' + $timed.Count)
if ($timed.Count -lt 1) { throw 'no timed tips found' }

$summary = New-Object System.Collections.Generic.List[string]
$summary.Add("variant`tasset`tproperty`tbefore`tafter`treadback`tother_props`tpak_bytes`tpak_sha256")

foreach ($variant in @(@{ label='x125'; factor=1.25 }, @{ label='x150'; factor=1.5 })) {
    $label = $variant.label
    $factor = $variant.factor
    $stage = Join-Path $repo ('build\staging\tips_' + $label)
    if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $stage | Out-Null
    $rbDir = Join-Path $repo ('build\p4\readback_tips_' + $label)
    if (Test-Path $rbDir) { Remove-Item $rbDir -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $rbDir | Out-Null

    foreach ($t in $timed) {
        $rel = $t.asset -replace '/', '\'
        $srcU = Join-Path $tipsSrc $rel
        $srcE = [IO.Path]::ChangeExtension($srcU, '.uexp')
        $dstU = Join-Path $stage $rel
        $dstE = [IO.Path]::ChangeExtension($dstU, '.uexp')
        New-Item -ItemType Directory -Force -Path (Split-Path $dstU -Parent) | Out-Null
        Copy-Item $srcU $dstU -Force
        Copy-Item $srcE $dstE -Force

        $before = [double]::Parse($t.dur, $inv)
        $after = [math]::Round($before * $factor, 3)
        $afterStr = [string]::Format($inv, '{0}', $after)
        $base = [IO.Path]::GetFileNameWithoutExtension($dstU)
        Write-Output ('  edit ' + $base + ' dur ' + $before + ' -> ' + $afterStr)
        & $tool setfloat $dstU DurationTime $afterStr | Out-Null
        if ($LASTEXITCODE -ne 0) { throw ('setfloat failed: ' + $rel) }

        $rb = Join-Path $rbDir ($base + '.json')
        & $tool dump $dstU $rb | Out-Null
        if (-not (Test-Path $rb)) { throw ('read-back dump failed: ' + $rel) }
        $got = Get-Float $rb 'DurationTime'
        if ($null -eq $got -or [math]::Abs($got - $after) -gt 0.0005) { throw ('read-back mismatch ' + $rel + ': ' + $got + ' != ' + $after) }
        $origJson = Join-Path $tipsSrc ('dump_' + $base + '.json')
        if (-not (Test-Path $origJson)) { throw ('missing original dump: ' + $origJson) }
        $cmp = Compare-Props $origJson $rb 'DurationTime'
        if ($cmp -ne 'same') { throw ('unexpected property change ' + $rel + ': ' + $cmp) }
        $summary.Add(('tips_' + $label + "`t" + $rel + "`tDurationTime`t" + $before + "`t" + $afterStr + "`t" + $got + "`t" + $cmp + "`t`t"))
    }

    # notification widget
    $dstU = Join-Path $stage ($widgetRel -replace '/', '\')
    $dstU = $dstU + '.uasset'
    $dstE = [IO.Path]::ChangeExtension($dstU, '.uexp')
    New-Item -ItemType Directory -Force -Path (Split-Path $dstU -Parent) | Out-Null
    $wSrcBase = Join-Path $uiSrc ($widgetRel -replace '/', '\')
    Copy-Item ($wSrcBase + '.uasset') $dstU -Force
    Copy-Item ($wSrcBase + '.uexp') $dstE -Force
    $wBefore = 3.5
    $wAfter = [math]::Round($wBefore * $factor, 4)
    $wAfterStr = [string]::Format($inv, '{0}', $wAfter)
    & $tool setfloat $dstU WaitTime $wAfterStr | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'setfloat failed: notification widget' }
    $rb = Join-Path $rbDir 'WBP_ItemNotificationEntryWidget.json'
    & $tool dump $dstU $rb | Out-Null
    $got = Get-Float $rb 'WaitTime'
    if ($null -eq $got -or [math]::Abs($got - $wAfter) -gt 0.00005) { throw ('widget read-back mismatch: ' + $got) }
    $origJson = $wSrcBase + '.uasset.json'
    $cmp = Compare-Props $origJson $rb 'WaitTime'
    if ($cmp -ne 'same') { throw ('unexpected widget property change: ' + $cmp) }
    $summary.Add(('tips_' + $label + "`t" + $widgetRel + "`tWaitTime`t" + $wBefore + "`t" + $wAfterStr + "`t" + $got + "`t" + $cmp + "`t`t"))

    # --- pack
    $pakName = 'zzz_atomicheart-ar_tips_' + $label + '_P.pak'
    $pakOut = Join-Path $pkgDir $pakName
    & $repak pack --version V11 --mount-point '../../../' $stage $pakOut 2>&1 | Select-Object -Last 1 | Out-Null
    if (-not (Test-Path $pakOut)) { throw ('pack failed: ' + $pakOut) }
    $entries = @(& $repak list $pakOut)
    Write-Output ('packed ' + $pakName + ' entries=' + $entries.Count)

    # --- unpack + byte-identical check
    $verify = Join-Path $repo ('build\p4\verify_tips_' + $label)
    if (Test-Path $verify) { Remove-Item $verify -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $verify | Out-Null
    & $repak unpack -o $verify -f $pakOut 2>&1 | Select-Object -Last 1 | Out-Null
    $bad = 0
    foreach ($e in $entries) {
        $s = Join-Path $stage ($e -replace '/', '\')
        $d = Join-Path $verify ($e -replace '/', '\')
        if (-not (Test-Path $d)) { $bad++; Write-Output ('  MISSING ' + $e); continue }
        if ((Get-FileHash $s -Algorithm SHA256).Hash -ne (Get-FileHash $d -Algorithm SHA256).Hash) { $bad++; Write-Output ('  DIFF ' + $e) }
    }
    if ($bad -ne 0) { throw ($pakName + ': ' + $bad + ' unpack mismatches') }
    Write-Output ('  byte-identical unpack: ' + $entries.Count + '/' + $entries.Count)

    $sha = (Get-FileHash $pakOut -Algorithm SHA256).Hash.ToLower()
    $sz = (Get-Item $pakOut).Length
    for ($i = 0; $i -lt $summary.Count; $i++) {
        if ($summary[$i].StartsWith('tips_' + $label + "`t") -and $summary[$i].EndsWith("`t`t")) {
            $summary[$i] = $summary[$i] + $sz + "`t" + $sha
        }
    }
    Write-Output ('  ' + $pakName + ' | ' + $sz + ' bytes | ' + $sha)
}

$outTsv = Join-Path $repo 'build\p4\tips_variants_build.tsv'
[IO.File]::WriteAllLines($outTsv, $summary, (New-Object Text.UTF8Encoding($false)))
Write-Output ('wrote ' + $outTsv)
