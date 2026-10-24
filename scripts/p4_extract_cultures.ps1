$ErrorActionPreference = 'Stop'
$pak = 'C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart\AtomicHeart\Content\Paks\pakchunk0-WindowsNoEditor.pak'
$repak = 'C:\AtomicHeart-AR\tools\bin\repak\repak.exe'
$ulr = 'C:\AtomicHeart-AR\tools\bin\UnrealLocres\UnrealLocres.exe'
$out = 'C:\AtomicHeart-AR\build\p4\locres_src'
foreach ($culture in @('de-DE', 'ja-JP', 'ko-KR', 'zh-Hans')) {
    $rel = 'AtomicHeart/Content/Localization/Academy_Dialogues/' + $culture + '/Academy_Dialogues.locres'
    $dest = Join-Path $out ('Academy_Dialogues-' + $culture + '.locres')
    $argStr = 'get "' + $pak + '" "' + $rel + '"'
    $p = Start-Process -FilePath $repak -ArgumentList $argStr -RedirectStandardOutput $dest -RedirectStandardError ($dest + '.err') -NoNewWindow -Wait -PassThru
    if ($p.ExitCode -ne 0) { Write-Output ('MISS ' + $culture); Remove-Item ($dest + '.err') -Force -ErrorAction SilentlyContinue; continue }
    Remove-Item ($dest + '.err') -Force -ErrorAction SilentlyContinue
    $csv = Join-Path $out ('Academy_Dialogues-' + $culture + '.csv')
    & $ulr export $dest -o $csv 2>&1 | Out-Null
    Write-Output ($culture + ' -> ' + (Get-Item $csv).Length + ' bytes')
}
