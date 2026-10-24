$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$TAB = [char]9
$lines = [IO.File]::ReadAllLines('C:\AtomicHeart-AR\localization\master\atomic-heart-ar.tsv', [Text.Encoding]::UTF8)
$rx = [regex]'\*([0-9]+(?:\.[0-9]+)?)(?:-([0-9]+(?:\.[0-9]+)?))?\*'
$rows = 0; $enRows = 0; $arRows = 0; $enRg = 0; $enSg = 0; $arRg = 0; $arSg = 0; $same = 0
$minSpan = 999.0; $maxSpan = 0.0
$examples = New-Object System.Collections.Generic.List[string]
for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split $TAB
    if ($f.Count -ne 13) { continue }
    $en = $f[5]; $ar = $f[6]
    $em = $rx.Matches($en); $am = $rx.Matches($ar)
    if ($em.Count -eq 0 -and $am.Count -eq 0) { continue }
    $rows++
    if ($em.Count -gt 0) { $enRows++ }
    if ($am.Count -gt 0) { $arRows++ }
    foreach ($m in $em) {
        if ($m.Groups[2].Success) { $enRg++; $sp = [double]::Parse($m.Groups[2].Value, [Globalization.CultureInfo]::InvariantCulture) - [double]::Parse($m.Groups[1].Value, [Globalization.CultureInfo]::InvariantCulture); if ($sp -lt $minSpan) { $minSpan = $sp }; if ($sp -gt $maxSpan) { $maxSpan = $sp } }
        else { $enSg++ }
    }
    foreach ($m in $am) { if ($m.Groups[2].Success) { $arRg++ } else { $arSg++ } }
    $es = ($em | ForEach-Object { $_.Value }) -join '|'
    $as = ($am | ForEach-Object { $_.Value }) -join '|'
    if ($es -ceq $as) { $same++ }
    if ($examples.Count -lt 4 -and $em.Count -ge 2 -and $en.Length -lt 400) {
        $examples.Add('L' + ($i+1) + ' EN: ' + $en)
        $examples.Add('L' + ($i+1) + ' AR: ' + $ar)
    }
}
Write-Output ("rows=$rows | EN rows=$enRows markers ranges=$enRg singles=$enSg | AR rows=$arRows ranges=$arRg singles=$arSg | identical seq=$same")
Write-Output ("explicit span min=$minSpan max=$maxSpan")
$examples | ForEach-Object { $_ }
