$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$root = 'C:\AtomicHeart-AR\build\p4\tips_src'
$tool = 'C:\AtomicHeart-AR\tools\bin\uasettool\uasettool.exe'
$rows = New-Object System.Collections.Generic.List[string]
$rows.Add("asset`tclass`tbHasDuration`tDurationTime`thintVisibility")
$files = Get-ChildItem $root -Recurse -Filter 'DA_*.uasset' | Sort-Object FullName
foreach ($f in $files) {
    $json = Join-Path $root ('dump_' + $f.BaseName + '.json')
    & $tool dump $f.FullName $json 2>&1 | Out-Null
    if (-not (Test-Path $json)) { $rows.Add(($f.BaseName + "`tDUMP-FAILED`t`t`t")); continue }
    try { $j = Get-Content $json -Raw | ConvertFrom-Json } catch { $rows.Add(($f.BaseName + "`tJSON-FAILED`t`t`t")); continue }
    $props = @($j.Exports[0].Data)
    $has = ($props | Where-Object { $_.Name -eq 'bHasDuration' } | Select-Object -First 1)
    $dur = ($props | Where-Object { $_.Name -eq 'DurationTime' } | Select-Object -First 1)
    $vis = ($props | Where-Object { $_.Name -eq 'HintVisibilityRules' } | Select-Object -First 1)
    $hv = ''; if ($has) { $hv = [string]$has.Value }
    $dv = ''; if ($dur) { $dv = [string]$dur.Value }
    $vv = ''; if ($vis) { $vv = [string]$vis.Value }
    $rel = $f.FullName.Substring($root.Length + 1) -replace '\\', '/'
    $rows.Add(($rel + "`tDA_InputTipInfo`t" + $hv + "`t" + $dv + "`t" + $vv))
}
$out = 'C:\AtomicHeart-AR\build\p4\tip_durations.tsv'
[IO.File]::WriteAllLines($out, $rows, (New-Object Text.UTF8Encoding($false)))
Write-Output ('assets: ' + $files.Count + ' -> ' + $out)
