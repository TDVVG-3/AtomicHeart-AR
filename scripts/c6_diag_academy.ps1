$ErrorActionPreference = 'Stop'
$repo = 'C:\AtomicHeart-AR'
$dump = Get-Content (Join-Path $repo 'localization\extracted\dialogue\pakchunk0-WindowsNoEditor__DT_Subtitles_Academy.txt') -Raw -Encoding UTF8
$json = Get-ChildItem (Join-Path $repo 'build\c6\json') -Recurse -Filter '*DT_Subtitles_Academy*.json' | Select-Object -First 1
$j = [IO.File]::ReadAllText($json.FullName, [Text.Encoding]::UTF8) | ConvertFrom-Json
$rows = $j.Exports[0].Table.Data
$out = New-Object System.Collections.Generic.List[string]
$hit = 0; $miss = 0
foreach ($r in $rows) {
    $t = ($r.Value | Where-Object { $_.Name -eq 'Sentences' } | Select-Object -First 1).CultureInvariantString
    $in = $dump.Contains($t)
    if ($in) { $hit++ } else { $miss++ }
    $out.Add(($r.Name + "`t" + $in + "`t" + $t))
}
$out.Add(('HIT ' + $hit + ' MISS ' + $miss))
$m = [regex]::Match($dump, '(?s)## UTF-16 strings\r?\n(.*?)(\r?\n\s*## ASCII strings|$)')
$lines = $m.Groups[1].Value -split "`r?`n"
$out.Add('DUMP LINES ' + $lines.Count)
$i = 0
foreach ($l in $lines) { $i++; $out.Add('DUMP ' + $i + ' | ' + $l) }
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\academy_diag.txt'), $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('hit ' + $hit + ' miss ' + $miss + ' lines ' + $lines.Count)
