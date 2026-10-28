$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
$repo = 'C:\AtomicHeart-AR'
$repak = Join-Path $repo 'tools\bin\repak\repak.exe'
$paksDir = 'C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart\AtomicHeart\Content\Paks'
$out = Join-Path $repo 'build\c6\src'
New-Item -ItemType Directory -Force -Path $out | Out-Null

$rows = Import-Csv (Join-Path $repo 'build\c6_ru_assets.csv')
$scan = Import-Csv (Join-Path $repo 'reports\dialogue_st_counts.tsv') -Delimiter "`t"
$map = @{}
foreach ($s in $scan) { $map[$s.path] = $s }

$ok = 0; $miss = 0; $fail = 0
foreach ($r in $rows) {
    $s = $map[$r.asset]
    if (-not $s) { $miss++; Write-Output ('NOMAP ' + $r.asset); continue }
    $pak = Join-Path $paksDir ($s.pak + '.pak')
    if (-not (Test-Path $pak)) { $miss++; Write-Output ('NOPAK ' + $pak); continue }
    foreach ($ext in @('.uasset', '.uexp')) {
        $rel = [IO.Path]::ChangeExtension($r.asset, $ext)
        $dest = Join-Path (Join-Path $out $s.pak) ($rel -replace '/', '\')
        if (Test-Path $dest) { $ok++; continue }
        New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
        $argStr = 'get "' + $pak + '" "' + $rel + '"'
        $p = Start-Process -FilePath $repak -ArgumentList $argStr -RedirectStandardOutput $dest -RedirectStandardError ($dest + '.err') -NoNewWindow -Wait -PassThru
        if ($p.ExitCode -ne 0) {
            $fail++
            Write-Output ('FAIL ' + $rel + ' :: ' + ((Get-Content ($dest + '.err') -Raw) -replace "`r?`n", ' '))
            Remove-Item $dest -Force -ErrorAction SilentlyContinue
        } else { $ok++ }
        Remove-Item ($dest + '.err') -Force -ErrorAction SilentlyContinue
    }
}
Write-Output ('extracted files: ' + $ok + ' | no-pak/map: ' + $miss + ' | get failures: ' + $fail)
$files = Get-ChildItem $out -Recurse -File
Write-Output ('on disk: ' + $files.Count + ' | bytes ' + (($files | Measure-Object Length -Sum).Sum))
