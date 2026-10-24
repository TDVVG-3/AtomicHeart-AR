$ErrorActionPreference = 'Stop'
$pak = 'C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart\AtomicHeart\Content\Paks\pakchunk0-WindowsNoEditor.pak'
$repak = 'C:\AtomicHeart-AR\tools\bin\repak\repak.exe'
$ulr = 'C:\AtomicHeart-AR\tools\bin\UnrealLocres\UnrealLocres.exe'
$out = 'C:\AtomicHeart-AR\build\p4\locres_src'
New-Item -ItemType Directory -Force -Path $out | Out-Null
$targets = @(
    @{ scope = 'Academy_Dialogues'; culture = 'en-US' },
    @{ scope = 'Academy_Dialogues'; culture = 'ru-RU' },
    @{ scope = 'Chelomey_Dialogues'; culture = 'en-US' },
    @{ scope = 'Chelomey_Dialogues'; culture = 'ru-RU' }
)
foreach ($t in $targets) {
    $rel = 'AtomicHeart/Content/Localization/' + $t.scope + '/' + $t.culture + '/' + $t.scope + '.locres'
    $dest = Join-Path $out ($t.scope + '-' + $t.culture + '.locres')
    $argStr = 'get "' + $pak + '" "' + $rel + '"'
    $p = Start-Process -FilePath $repak -ArgumentList $argStr -RedirectStandardOutput $dest -RedirectStandardError ($dest + '.err') -NoNewWindow -Wait -PassThru
    if ($p.ExitCode -ne 0) { Write-Output ('MISS ' + $rel); continue }
    Remove-Item ($dest + '.err') -Force -ErrorAction SilentlyContinue
    $csv = Join-Path $out ($t.scope + '-' + $t.culture + '.csv')
    & $ulr export $dest -o $csv 2>&1 | Out-Null
    if (Test-Path $csv) { Write-Output ($rel + ' -> ' + (Get-Item $csv).Length + ' bytes') } else { Write-Output ($rel + ' -> export failed') }
}
