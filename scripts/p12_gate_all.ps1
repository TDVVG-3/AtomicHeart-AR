$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$repo = 'C:\AtomicHeart-AR'
$variants = @('p12','p12g','p12c','p12e','p12f','p12ef')
$fail = 0
$summary = New-Object System.Collections.Generic.List[string]
$summary.Add('| variant | validator | coverage | glyph | stack audit |')
$summary.Add('|---|---|---|---|---|')
foreach ($v in $variants) {
    $master = Join-Path $repo ('build\variants\atomic-heart-ar_' + $v + '.tsv')
    if (-not (Test-Path $master)) { $summary.Add(('| {0} | MISSING | - | - | - |' -f $v)); $fail++; continue }
    $valRep = Join-Path $repo ('reports\' + $v + '_translation_validation.md')
    $covRep = Join-Path $repo ('reports\coverage_' + $v + '.md')
    $glyRep = Join-Path $repo ('reports\glyph_gate_' + $v + '.md')
    $stkRep = Join-Path $repo ('reports\subtitle_stack_audit_' + $v + '.md')
    $stkRows = Join-Path $repo ('reports\subtitle_stack_rows_' + $v + '.tsv')

    $valArgs = @('-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $repo 'scripts\validate_translation.ps1'),'-MasterTsV',$master,'-ReportPath',$valRep)
    if ($v -ne 'p12') { $valArgs += '-AllowTimingRepair' }
    & powershell @valArgs 2>&1 | Out-Null
    $valOk = ($LASTEXITCODE -eq 0)

    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo 'scripts\coverage_report.ps1') -MasterTsV $master -ReportPath $covRep -Title ('Coverage - ' + $v) 2>&1 | Out-Null
    $covOk = ($LASTEXITCODE -eq 0)

    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo 'scripts\glyph_gate.ps1') -MasterTsV $master -PayloadRoot (Join-Path $repo 'build\staging\font_v3\modpakfont') -ReportPath $glyRep -AllowSourceInheritedNonLatin 2>&1 | Out-Null
    $glyOk = ($LASTEXITCODE -eq 0)

    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo 'scripts\subtitle_stack_audit.ps1') -MasterTsV $master -ReportPath $stkRep -RowsPath $stkRows 2>&1 | Out-Null
    $stkOk = ($LASTEXITCODE -eq 0)

    if (-not $valOk -or -not $covOk -or -not $glyOk -or -not $stkOk) { $fail++ }
    $summary.Add(('| {0} | {1} | {2} | {3} | {4} |' -f $v, $(if ($valOk) {'PASS'} else {'FAIL'}), $(if ($covOk) {'PASS'} else {'FAIL'}), $(if ($glyOk) {'PASS'} else {'FAIL'}), $(if ($stkOk) {'PASS'} else {'FAIL'})))
    Write-Output ('[{0}] validator={1} coverage={2} glyph={3} audit={4}' -f $v, $valOk, $covOk, $glyOk, $stkOk)
}
$out = Join-Path $repo 'reports\p12_gate_all.md'
$hdr = New-Object System.Collections.Generic.List[string]
$hdr.Add('# p12 family gate summary')
$hdr.Add('')
$hdr.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')))
$hdr.Add('')
foreach ($l in $summary) { $hdr.Add($l) }
[IO.File]::WriteAllLines($out, $hdr, (New-Object Text.UTF8Encoding($false)))
Write-Output ('summary: ' + $out)
if ($fail -gt 0) { exit 2 }
