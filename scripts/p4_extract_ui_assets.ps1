$ErrorActionPreference = 'Stop'
$pak = 'C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart\AtomicHeart\Content\Paks\pakchunk0-WindowsNoEditor.pak'
$repak = 'C:\AtomicHeart-AR\tools\bin\repak\repak.exe'
$out = 'C:\AtomicHeart-AR\build\p4\ui_src'
New-Item -ItemType Directory -Force -Path $out | Out-Null
$files = @(
    'AtomicHeart/Content/Core/Player/BP_InputTipComponent',
    'AtomicHeart/Content/Core/UI/Widgets/Hints/ShortHint/WBP_ShortHint',
    'AtomicHeart/Content/Core/UI/Widgets/Hints/WBP_FullscreenHint_Single',
    'AtomicHeart/Content/Core/UI/Widgets/Hints/WBP_FullscreenHint_Double',
    'AtomicHeart/Content/Core/UI/HUD/Widgets/WBP_ItemNotificationEntryWidget',
    'AtomicHeart/Content/Core/UI/HUD/Widgets/WBP_NewPlaceNotification',
    'AtomicHeart/Content/Core/UI/HUD/Widgets/WBP_CustomItemNotification',
    'AtomicHeart/Content/Core/UI/HUD/Widgets/WBP_RecipeNotification',
    'AtomicHeart/Content/Core/UI/HUD/Widgets/WBP_DeactivateNotification',
    'AtomicHeart/Content/Core/UI/HUD/Widgets/QuestsNotifiers/WBP_QuestNotify',
    'AtomicHeart/Content/Core/UI/HUD/WBP_ItemsNotifiersWidget'
)
foreach ($f in $files) {
    foreach ($ext in @('.uasset', '.uexp')) {
        $dest = Join-Path $out (($f -replace '/', '\') + $ext)
        New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
        $argStr = 'get "' + $pak + '" "' + $f + $ext + '"'
        $p = Start-Process -FilePath $repak -ArgumentList $argStr -RedirectStandardOutput $dest -RedirectStandardError ($dest + '.err') -NoNewWindow -Wait -PassThru
        if ($p.ExitCode -ne 0) { Write-Output ('MISS ' + $f + $ext + ' :: ' + (Get-Content ($dest + '.err') -Raw)) }
        Remove-Item ($dest + '.err') -Force -ErrorAction SilentlyContinue
    }
}
Write-Output ('files: ' + (Get-ChildItem $out -Recurse -File).Count)
