param(
    [Parameter(Mandatory=$true)][string]$Chunk,
    [Parameter(Mandatory=$true)][string]$Ar,
    [Parameter(Mandatory=$true)][string]$Out
)
$ErrorActionPreference = 'Stop'
$chunkRows = Import-Csv $Chunk -Delimiter "`t"
$arRows = Import-Csv $Ar -Delimiter "`t"
$arMap = @{}
$dup = 0
foreach ($r in $arRows) {
    if ($arMap.ContainsKey($r.id)) { $dup++ }
    $arMap[$r.id] = $r.ar
}
$fail = New-Object System.Collections.Generic.List[string]
$fail.Add("id`tcheck`tdetail")
$warn = 0
$checked = 0
$markerRe = [regex]'\*[0-9][0-9.\-]*\*'
$tagRe = [regex]'<[^>]+>'
$phRe = [regex]'\{[0-9]+\}|%[sd]'
$latRe = [regex]'[A-Za-z][A-Za-z0-9_\-]*'
$arabicRe = [regex]'[\u0600-\u06FF]'
$cyrRe = [regex]'[\u0400-\u04FF]'
$arabicDigitRe = [regex]'[\u0660-\u0669\u06F0-\u06F9]'
$allowLatin = @('P-3','VOV-A6','BEA-D','HOG-7','PEAR','SHZ-5','BUS','BUS-A','K-47','AK-47','VOV-A6/CH','BEA-Ds')

function Get-Seq([regex]$re, [string]$s) {
    $m = $re.Matches($s)
    return (($m | ForEach-Object { $_.Value }) -join '|')
}
function Bad([string]$id, [string]$check, [string]$detail) {
    $fail.Add(($id + "`t" + $check + "`t" + ($detail -replace "`t", ' ') -replace "`r?`n", ' '))
}

foreach ($r in $chunkRows) {
    $checked++
    if (-not $arMap.ContainsKey($r.id)) { Bad $r.id 'missing-id' ''; continue }
    $ar = [string]$arMap[$r.id]
    $ru = [string]$r.ru
    if ($ar.Trim().Length -eq 0) { Bad $r.id 'empty' ''; continue }
    if (-not $arabicRe.IsMatch($ar)) { Bad $r.id 'no-arabic' $ar; continue }
    if ($cyrRe.IsMatch($ar)) { Bad $r.id 'cyrillic' $ar }
    if ($arabicDigitRe.IsMatch($ar)) { Bad $r.id 'arabic-digits' $ar }
    $rm = Get-Seq $markerRe $ru; $am = Get-Seq $markerRe $ar
    if ($rm -ne $am) { Bad $r.id 'markers' ('ru=' + $rm + ' ar=' + $am) }
    $rt = Get-Seq $tagRe $ru; $at = Get-Seq $tagRe $ar
    if ($rt -ne $at) { Bad $r.id 'tags' ('ru=' + $rt + ' ar=' + $at) }
    $rp = Get-Seq $phRe $ru; $ap = Get-Seq $phRe $ar
    if ($rp -ne $ap) { Bad $r.id 'placeholders' ('ru=' + $rp + ' ar=' + $ap) }
    if (([regex]::Matches($ru, "`n")).Count -ne ([regex]::Matches($ar, "`n")).Count) { Bad $r.id 'newlines' '' }
    if ($ru -match ',\s|\?|;' -and $ar -match '(?<![A-Za-z0-9]),|(?<![A-Za-z0-9])\?|(?<![A-Za-z0-9]);') { $warn++; Bad $r.id 'ascii-punct' $ar }
    if ($ru.Length -gt 20) {
        $ratio = $ar.Length / [double]$ru.Length
        if ($ratio -lt 0.35 -or $ratio -gt 2.6) { Bad $r.id 'length' ([string]::Format('{0:N2}x {1}/{2}', $ratio, $ar.Length, $ru.Length)) }
    }
    $srcLatin = @($latRe.Matches($ru) | ForEach-Object { $_.Value })
    foreach ($m in $latRe.Matches($ar)) {
        $t = $m.Value
        if ($allowLatin -contains $t) { continue }
        if ($srcLatin -contains $t) { continue }
        if ($t -match '^[A-Z]{1,3}[0-9]{1,4}(-[A-Z0-9]+)?$') { continue }
        if ($t -match '^P-[0-9]+$') { continue }
        if ($t -match '^[A-Z]{2,5}-[0-9]{1,4}(-[A-Z0-9]+)?$') { continue }
        Bad $r.id 'latin' $t
    }
    if ($ar -match '[\u0600-\u06FF][,;?]|[,;?][\u0600-\u06FF]') { $warn++ }
}
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('chunk: ' + $Chunk)
$lines.Add('rows: ' + $checked + ' | ar rows: ' + $arRows.Count + ' | duplicate ids: ' + $dup + ' | failures: ' + ($fail.Count - 1) + ' | warnings: ' + $warn)
$lines.AddRange($fail)
[IO.File]::WriteAllLines($Out, $lines, (New-Object Text.UTF8Encoding($false)))
Write-Output ('rows ' + $checked + ' failures ' + ($fail.Count - 1) + ' warnings ' + $warn + ' -> ' + $Out)
if ($fail.Count -gt 1 -or $dup -gt 0) { exit 1 }
