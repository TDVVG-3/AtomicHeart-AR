$ErrorActionPreference = 'Stop'
$repo = 'C:\AtomicHeart-AR'
$tool = Join-Path $repo 'tools\src\uasettool\bin\Release\net8.0\uasettool.exe'
$testDir = Join-Path $repo 'build\c6\test'
New-Item -ItemType Directory -Force -Path $testDir | Out-Null
Remove-Item (Join-Path $testDir '*') -Force -ErrorAction SilentlyContinue

$src = Join-Path $repo 'build\c6\src\pakchunk0-WindowsNoEditor\AtomicHeart\Content\Maps\Development\Dialogue_Test\Dialog_Academy\DT_Subtitles_Academy.uasset'
if (-not (Test-Path $src)) { throw 'src missing: ' + $src }
$base = [IO.Path]::GetFileNameWithoutExtension($src)
$dst = Join-Path $testDir ($base + '.uasset')
Copy-Item $src $dst -Force
Copy-Item ([IO.Path]::ChangeExtension($src, '.uexp')) (Join-Path $testDir ($base + '.uexp')) -Force

$rows = Import-Csv (Join-Path $repo 'build\c6\collected.tsv') -Delimiter "`t"
$r = $rows | Where-Object { $_.asset -like '*DT_Subtitles_Academy*' } | Select-Object -First 1
if (-not $r) { throw 'no collected row for Academy' }
$old = $r.text
$new = [IO.File]::ReadAllText((Join-Path $repo 'build\c6\test_new_ar.txt'), [Text.Encoding]::UTF8).TrimEnd("`r", "`n")
$oldB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($old))
$newB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($new))
$map = Join-Path $testDir 'map.tsv'
[IO.File]::WriteAllText($map, ('DataTable' + "`t" + 'Sentences' + "`t" + $oldB64 + "`t" + $newB64 + "`n"), (New-Object Text.UTF8Encoding($false)))

& $tool settext $dst $map $dst --strict
if ($LASTEXITCODE -ne 0) { throw ('settext failed: ' + $LASTEXITCODE) }

$readback = Join-Path $testDir 'readback.json'
& $tool dump $dst $readback | Out-Null
$j = [IO.File]::ReadAllText($readback, [Text.Encoding]::UTF8) | ConvertFrom-Json
$row = $j.Exports[0].Table.Data | Where-Object { $_.Name -eq $r.key } | Select-Object -First 1
$got = ($row.Value | Where-Object { $_.Name -eq 'Sentences' } | Select-Object -First 1).CultureInvariantString
$out = New-Object System.Collections.Generic.List[string]
$out.Add('oldLen=' + $old.Length + ' newLen=' + $new.Length)
$out.Add('gotLen=' + ([string]$got).Length)
$out.Add('match=' + ([string]$got -eq $new))
$out.Add('got=' + $got)
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\test_settext_result.txt'), $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('match=' + ([string]$got -eq $new) + ' got=' + $got)
