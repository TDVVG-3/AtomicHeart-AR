$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
$repo = 'C:\AtomicHeart-AR'
$tool = Join-Path $repo 'tools\bin\uasettool\uasettool.exe'
$src = Join-Path $repo 'build\c6\src'
$out = Join-Path $repo 'build\c6\json'
New-Item -ItemType Directory -Force -Path $out | Out-Null

$assets = Get-ChildItem $src -Recurse -Filter '*.uasset'
$ok = 0; $fail = 0
$fails = New-Object System.Collections.Generic.List[string]
foreach ($a in $assets) {
    $rel = $a.FullName.Substring($src.Length + 1)
    $dest = Join-Path $out ($rel + '.json')
    New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
    & $tool dump $a.FullName $dest 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0 -and (Test-Path $dest)) { $ok++ }
    else {
        $fail++
        $fails.Add($rel)
        Write-Output ('FAIL ' + $rel)
    }
}
Write-Output ('dumped: ' + $ok + ' | failed: ' + $fail)
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\dump_failures.txt'), $fails, (New-Object Text.UTF8Encoding($false)))
