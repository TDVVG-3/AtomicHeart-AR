<#
.SYNOPSIS
  Exercise every switch_variant.ps1 combination without touching the game's real ~mods:
    - dry-run for each variant (read-only, resolves the exact set)
    - real install into a temp folder via install_mod.ps1 -ModsPath
    - full switch_variant rollback test in a temp repo with a forced post-install failure

.DESCRIPTION
  Writes only under <repo>\build\test_mods and <repo>\build\test_switch.
  The real game's Paks\~mods is only read (as the baseline copy).
#>
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

$game = Get-Content (Join-Path $RepoRoot 'config\game.json') -Raw | ConvertFrom-Json
$baseline = $game.mods_path
if (-not (Test-Path $baseline)) { throw "real ~mods not found: $baseline" }

$variants = @(
    [pscustomobject]@{ Name='p11';            Carrier='p11';        Font='p3_unhinted';    Tips='';     RuOnly=$false },
    [pscustomobject]@{ Name='p11b';           Carrier='p11b_retime'; Font='p3_unhinted';   Tips='';     RuOnly=$false },
    [pscustomobject]@{ Name='p11c';           Carrier='p11c';       Font='p3_unhinted';    Tips='';     RuOnly=$false },
    [pscustomobject]@{ Name='p11c_tips_x125'; Carrier='p11c';       Font='p3_unhinted';    Tips='x125'; RuOnly=$false },
    [pscustomobject]@{ Name='p11c_tips_x150'; Carrier='p11c';       Font='p3_unhinted';    Tips='x150'; RuOnly=$false },
    [pscustomobject]@{ Name='p11_3b';         Carrier='p11';        Font='p3b_linemetrics'; Tips='';    RuOnly=$false },
    [pscustomobject]@{ Name='p11b3b';         Carrier='p11b_retime'; Font='p3b_linemetrics'; Tips='';   RuOnly=$false },
    [pscustomobject]@{ Name='p10';            Carrier='p10';        Font='p2_plex';        Tips='';     RuOnly=$false },
    [pscustomobject]@{ Name='p11+ruonly';     Carrier='p11';        Font='p3_unhinted';    Tips='';     RuOnly=$true },
    [pscustomobject]@{ Name='p11c_tips_x150+ruonly'; Carrier='p11c'; Font='p3_unhinted';  Tips='x150'; RuOnly=$true },
    [pscustomobject]@{ Name='p11e';           Carrier='p11e';       Font='p3_unhinted';    Tips='';     RuOnly=$false },
    [pscustomobject]@{ Name='p11f';           Carrier='p11f';       Font='p3_unhinted';    Tips='';     RuOnly=$false },
    [pscustomobject]@{ Name='p11ef';          Carrier='p11ef';      Font='p3_unhinted';    Tips='';     RuOnly=$false },
    [pscustomobject]@{ Name='p11e_tips_x150'; Carrier='p11e';       Font='p3_unhinted';    Tips='x150'; RuOnly=$false },
    [pscustomobject]@{ Name='p11f_tips_x150'; Carrier='p11f';       Font='p3_unhinted';    Tips='x150'; RuOnly=$false },
    [pscustomobject]@{ Name='p11ef_tips_x150'; Carrier='p11ef';     Font='p3_unhinted';    Tips='x150'; RuOnly=$false },
    [pscustomobject]@{ Name='p11e+ruonly';    Carrier='p11e';       Font='p3_unhinted';    Tips='';     RuOnly=$true },
    [pscustomobject]@{ Name='p11f+ruonly';    Carrier='p11f';       Font='p3_unhinted';    Tips='';     RuOnly=$true },
    [pscustomobject]@{ Name='p11ef+ruonly';   Carrier='p11ef';      Font='p3_unhinted';    Tips='';     RuOnly=$true },
    [pscustomobject]@{ Name='p11e_tips_x150+ruonly'; Carrier='p11e'; Font='p3_unhinted'; Tips='x150'; RuOnly=$true },
    [pscustomobject]@{ Name='p11f_tips_x150+ruonly'; Carrier='p11f'; Font='p3_unhinted'; Tips='x150'; RuOnly=$true },
    [pscustomobject]@{ Name='p11ef_tips_x150+ruonly'; Carrier='p11ef'; Font='p3_unhinted'; Tips='x150'; RuOnly=$true },
    [pscustomobject]@{ Name='tips_x150';       Carrier='p11';        Font='p3_unhinted';    Tips='x150'; RuOnly=$false },
    [pscustomobject]@{ Name='tips_x150+ruonly'; Carrier='p11';       Font='p3_unhinted';    Tips='x150'; RuOnly=$true }
)
foreach ($c in @('p12','p12g','p12c','p12e','p12f','p12ef')) {
    $variants += [pscustomobject]@{ Name=$c;                    Carrier=$c; Font='p3_unhinted'; Tips='';     RuOnly=$false }
    $variants += [pscustomobject]@{ Name=($c + '+ruonly');      Carrier=$c; Font='p3_unhinted'; Tips='';     RuOnly=$true }
    $variants += [pscustomobject]@{ Name=($c + '_tips_x150');   Carrier=$c; Font='p3_unhinted'; Tips='x150'; RuOnly=$false }
    $variants += [pscustomobject]@{ Name=($c + '_tips_x150+ruonly'); Carrier=$c; Font='p3_unhinted'; Tips='x150'; RuOnly=$true }
}

function Get-InstallSet($v) {
    $set = @(
        "zzz_atomicheart-ar_carrier_koKR_$($v.Carrier)_P.pak",
        "zzz_atomicheart-ar_font_$($v.Font)_P.pak"
    )
    if ($v.Tips) { $set += "zzz_atomicheart-ar_tips_$($v.Tips)_P.pak" }
    if ($v.RuOnly) { $set += 'zzz_atomicheart-ar_ruonly_p1_P.pak' }
    return $set
}

function Test-ExpectedSet([string]$dir, [string[]]$set) {
    $problems = New-Object System.Collections.Generic.List[string]
    $expected = @($set + 'atomic-heart-ar-install-manifest.json') | Sort-Object
    $present = @(Get-ChildItem $dir -File | Sort-Object Name)
    $names = @($present | ForEach-Object { $_.Name })
    if ($names.Count -ne $expected.Count) {
        $problems.Add("file count $($names.Count) != $($expected.Count)")
    }
    foreach ($e in $expected) { if ($names -notcontains $e) { $problems.Add("missing $e") } }
    foreach ($n in $names) { if ($expected -notcontains $n) { $problems.Add("extra $n") } }
    foreach ($n in $set) {
        $src = Join-Path $RepoRoot ('build\package\' + $n)
        $dst = Join-Path $dir $n
        if ((Test-Path $src) -and (Test-Path $dst)) {
            $sh = (Get-FileHash $src -Algorithm SHA256).Hash.ToLower()
            $dh = (Get-FileHash $dst -Algorithm SHA256).Hash.ToLower()
            if ($sh -ne $dh) { $problems.Add("hash mismatch $n") }
        }
    }
    $mp = Join-Path $dir 'atomic-heart-ar-install-manifest.json'
    if (Test-Path $mp) {
        try {
            $m = Get-Content $mp -Raw | ConvertFrom-Json
            $mf = @($m.files)
            if ($mf.Count -ne $set.Count) { $problems.Add("manifest file count $($mf.Count) != $($set.Count)") }
            foreach ($n in $set) {
                $rec = $mf | Where-Object { $_.file -eq $n }
                if (-not $rec) { $problems.Add("manifest missing $n"); continue }
                $dst = Join-Path $dir $n
                $h = (Get-FileHash $dst -Algorithm SHA256).Hash.ToLower()
                if ($rec.sha256 -ne $h) { $problems.Add("manifest hash mismatch $n") }
                if ([long]$rec.size -ne (Get-Item $dst).Length) { $problems.Add("manifest size mismatch $n") }
            }
        } catch {
            $problems.Add('manifest unreadable: ' + $_.Exception.Message)
        }
    }
    return $problems
}

$rows = New-Object System.Collections.Generic.List[object]
$testRoot = Join-Path $RepoRoot 'build\test_mods'
if (Test-Path $testRoot) { Remove-Item $testRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $testRoot | Out-Null

Write-Output '=== dry-run + temp real-install matrix ==='
foreach ($v in $variants) {
    $set = Get-InstallSet $v
    $safe = $v.Name -replace '[^A-Za-z0-9_]+', '_'
    $temp = Join-Path $testRoot $safe
    New-Item -ItemType Directory -Force -Path $temp | Out-Null
    Get-ChildItem $baseline -File | Copy-Item -Destination $temp

    # 1. dry-run through the real switch_variant.ps1
    $dryArgs = @('-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $RepoRoot 'scripts\switch_variant.ps1'),'-Variant',$v.Name.Replace('+ruonly',''))
    if ($v.RuOnly) { $dryArgs += '-RuOnly' }
    $dryArgs += '-DryRun'
    $dryOut = @(& powershell @dryArgs 2>&1 | ForEach-Object { [string]$_ })
    $dryRc = $LASTEXITCODE
    $dryText = $dryOut -join "`n"
    $dryOk = ($dryRc -eq 0)
    foreach ($n in $set) { if ($dryText -notmatch [regex]::Escape($n)) { $dryOk = $false } }
    if ($dryText -notmatch 'DRY RUN') { $dryOk = $false }
    $dryNote = if ($dryOk) { 'PASS' } else { "FAIL (rc=$dryRc)" }

    # 2. real install into the temp copy via install_mod.ps1 -ModsPath
    $instArgs = @(
        '-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $RepoRoot 'scripts\install_mod.ps1'),
        '-RepoRoot',$RepoRoot,'-Carrier',$v.Carrier,'-Font',$v.Font,'-ModsPath',$temp
    )
    if ($v.Tips) { $instArgs += @('-Tips',$v.Tips) }
    if ($v.RuOnly) { $instArgs += '-RuOnly' }
    $instOut = @(& powershell @instArgs 2>&1 | ForEach-Object { [string]$_ })
    $instRc = $LASTEXITCODE
    $problems = @(Test-ExpectedSet $temp $set)
    $instOk = (($instRc -eq 0) -and ($problems.Count -eq 0))
    $instNote = if ($instOk) { 'PASS' } else { "FAIL (rc=$instRc; $($problems -join '; '))" }
    if (-not $instOk) {
        $instNote += ' | output tail: ' + (($instOut | Select-Object -Last 8) -join ' / ')
    }

    $rows.Add([pscustomobject]@{
        Variant = $v.Name
        Files = ($set -join ' + ')
        DryRun = $dryNote
        TempInstall = $instNote
        TempDir = $temp
    })
    Write-Output ("{0,-22} dry={1,-8} temp={2}" -f $v.Name, $dryNote, $instNote)
    if (-not $instOk) {
        Write-Output ('  files: ' + ($set -join ', '))
        foreach ($line in ($instOut | Select-Object -Last 12)) { Write-Output ('  | ' + $line) }
    }
}

# 3. full switch_variant rollback test in a temp repo (forced failure after real install)
Write-Output ''
Write-Output '=== switch_variant rollback test (temp repo, forced post-install failure) ==='
$testRepo = Join-Path $RepoRoot 'build\test_switch'
if (Test-Path $testRepo) { Remove-Item $testRepo -Recurse -Force }
New-Item -ItemType Directory -Force -Path (Join-Path $testRepo 'config') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $testRepo 'scripts') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $testRepo 'build\package') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $testRepo 'build\snapshots') | Out-Null
Copy-Item (Join-Path $RepoRoot 'scripts\*.ps1') (Join-Path $testRepo 'scripts') -Force
Copy-Item (Join-Path $RepoRoot 'build\package\*.pak') (Join-Path $testRepo 'build\package') -Force
$testMods = Join-Path $testRepo 'test_mods'
New-Item -ItemType Directory -Force -Path $testMods | Out-Null
Get-ChildItem $baseline -File | Copy-Item -Destination $testMods

$cfg = Get-Content (Join-Path $RepoRoot 'config\game.json') -Raw | ConvertFrom-Json
$cfg.mods_path = $testMods
$cfg | ConvertTo-Json -Depth 8 | Set-Content -Path (Join-Path $testRepo 'config\game.json') -Encoding UTF8

# Wrapper: run the real installer against the temp mods, then deliberately fail.
$wrapper = @'
try {
    & 'C:\AtomicHeart-AR\scripts\install_mod.ps1' @args
} catch {
    Write-Output ('FORCED TEST: real install threw: ' + $_.Exception.Message)
    exit 1
}
Write-Output 'FORCED TEST FAILURE AFTER INSTALL (rollback test)'
exit 1
'@
Set-Content -Path (Join-Path $testRepo 'scripts\install_mod.ps1') -Value $wrapper -Encoding ASCII

function Get-ModsState([string]$dir) {
    return @(Get-ChildItem $dir -File | ForEach-Object {
        [pscustomobject]@{ Name=$_.Name; Length=$_.Length; SHA256=(Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLower() }
    } | Sort-Object Name)
}
function Test-SameState($before, $after) {
    if ($before.Count -ne $after.Count) { return $false }
    for ($i=0; $i -lt $before.Count; $i++) {
        if ($after[$i].Name -ne $before[$i].Name -or $after[$i].Length -ne $before[$i].Length -or $after[$i].SHA256 -ne $before[$i].SHA256) { return $false }
    }
    return $true
}

$testBefore = Get-ModsState $testMods
$rollbackRows = New-Object System.Collections.Generic.List[object]
$newRollbackVariants = @(
    'p11e', 'p11f', 'p11ef',
    'p11e_tips_x150', 'p11f_tips_x150', 'p11ef_tips_x150',
    'p11e+ruonly', 'p11f+ruonly', 'p11ef+ruonly',
    'p11e_tips_x150+ruonly', 'p11f_tips_x150+ruonly', 'p11ef_tips_x150+ruonly',
    'tips_x150', 'tips_x150+ruonly'
)
foreach ($c in @('p12','p12g','p12c','p12e','p12f','p12ef')) {
    $newRollbackVariants += $c
    $newRollbackVariants += ($c + '+ruonly')
    $newRollbackVariants += ($c + '_tips_x150')
    $newRollbackVariants += ($c + '_tips_x150+ruonly')
}
foreach ($rv in $newRollbackVariants) {
    # Restore the exact baseline before every forced-failure run.
    Get-ChildItem $testMods -File -ErrorAction SilentlyContinue | Remove-Item -Force
    Get-ChildItem $baseline -File | Copy-Item -Destination $testMods
    Start-Sleep -Milliseconds 1100

    $rbVariant = $rv -replace '\+ruonly$', ''
    $swArgs = @('-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $testRepo 'scripts\switch_variant.ps1'),'-RepoRoot',$testRepo,'-Variant',$rbVariant)
    if ($rv -match '\+ruonly$') { $swArgs += '-RuOnly' }
    $rbOut = @(& powershell @swArgs 2>&1 | ForEach-Object { [string]$_ })
    $rbRc = $LASTEXITCODE
    $rbText = $rbOut -join "`n"
    $after = Get-ModsState $testMods
    $same = Test-SameState $testBefore $after
    $marker = ($rbText -match 'ROLLED BACK TO')
    $ok = (($rbRc -eq 1) -and $marker -and $same)
    $rollbackRows.Add([pscustomobject]@{
        Variant = $rv
        Rc = $rbRc
        BaselineRestored = $same
        Marker = $marker
        Result = $(if ($ok) { 'PASS' } else { 'FAIL' })
    })
    Write-Output ("{0,-28} rollback={1} rc={2} restored={3} marker={4}" -f $rv, $(if ($ok) { 'PASS' } else { 'FAIL' }), $rbRc, $same, $marker)
    if (-not $ok) {
        Write-Output 'ROLLBACK TEST FAILED'
        Write-Output ('  before: ' + (($testBefore | ForEach-Object { $_.Name + '=' + $_.SHA256 }) -join '; '))
        Write-Output ('  after : ' + (($after | ForEach-Object { $_.Name + '=' + $_.SHA256 }) -join '; '))
        foreach ($line in ($rbOut | Select-Object -Last 20)) { Write-Output ('  | ' + $line) }
    }
}
$rollbackOk = (@($rollbackRows | Where-Object { $_.Result -ne 'PASS' }).Count -eq 0)

# 4. report
$reportDir = Join-Path $RepoRoot 'reports'
New-Item -ItemType Directory -Force -Path $reportDir | Out-Null
$reportPath = Join-Path $reportDir 'variant_test_matrix.md'
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# Variant test matrix')
$lines.Add('')
$lines.Add('Generated: ' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz'))
$lines.Add('')
$lines.Add('Baseline installed set copied for each test: ' + (($baselineFiles = @(Get-ChildItem $baseline -File | Sort-Object Name) | ForEach-Object { $_.Name }) -join ', '))
$lines.Add('')
$lines.Add('| Variant | Resolved file set | Dry-run | Temp real install |')
$lines.Add('|---|---|---|---|')
foreach ($r in $rows) {
    $files = ($r.Files -split ' \+ ' | ForEach-Object { '`' + $_ + '`' }) -join '<br>'
    $lines.Add('| ' + $r.Variant + ' | ' + $files + ' | ' + $r.DryRun + ' | ' + $r.TempInstall + ' |')
}
$lines.Add('')
$lines.Add('## Rollback test')
$lines.Add('')
$lines.Add('Forced failure: real install into temp mods, then the wrapper exits 1 before verification.')
$lines.Add('Each row starts from the exact baseline `~mods` copy and must restore it byte-for-byte.')
$lines.Add('')
$lines.Add('| Variant | Result | Exit code | Baseline restored | `ROLLED BACK TO` printed |')
$lines.Add('|---|---|---:|---|---|')
foreach ($rr in $rollbackRows) {
    $lines.Add('| ' + $rr.Variant + ' | ' + $rr.Result + ' | ' + $rr.Rc + ' | ' + $rr.BaselineRestored + ' | ' + $rr.Marker + ' |')
}
$lines.Add('')
$lines.Add('- Temp repo: `' + $testRepo + '`')
$lines.Add('- Result: ' + $(if ($rollbackOk) { 'PASS - all forced-failure runs restored the exact baseline.' } else { 'FAIL - see rows above.' }))
$lines.Add('')
$lines.Add('## Notes')
$lines.Add('')
$lines.Add('Temp installs call `install_mod.ps1 -ModsPath <temp>`; the real game `~mods` is only read for the baseline copy in these tests.')
$lines.Add('')
$lines | Set-Content -Path $reportPath -Encoding UTF8
Write-Output ''
Write-Output ('report: ' + $reportPath)
if (-not $rollbackOk) { exit 1 }
$failed = @($rows | Where-Object { $_.DryRun -ne 'PASS' -or $_.TempInstall -ne 'PASS' })
if ($failed.Count) { Write-Output ('FAILED ROWS: ' + (($failed | ForEach-Object { $_.Variant }) -join ', ')); exit 1 }
Write-Output 'ALL VARIANT TESTS PASSED'
