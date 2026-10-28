$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
$repo = 'C:\AtomicHeart-AR'

function Read-TsvRaw([string]$path) {
    $lines = [IO.File]::ReadAllLines($path, [Text.Encoding]::UTF8)
    $head = $lines[0] -split "`t"
    $rows = New-Object System.Collections.Generic.List[object]
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Length -eq 0) { continue }
        $c = $lines[$i] -split "`t"
        $o = [ordered]@{}
        for ($j = 0; $j -lt $head.Count; $j++) { $o[$head[$j]] = if ($j -lt $c.Count) { $c[$j] } else { '' } }
        $rows.Add([pscustomobject]$o)
    }
    return $rows
}
function Norm([string]$t) {
    if ($null -eq $t) { return '' }
    $x = $t.Replace("`r", '').Replace("`n", ' ').Replace('"', '')
    $x = [regex]::Replace($x, '\s+', ' ').Trim()
    return $x
}
function Get-Category([string]$asset, [string]$field) {
    $n = [IO.Path]::GetFileNameWithoutExtension($asset)
    if ($asset -match 'Terminal' -or $n -like 'DA_*Terminal*') { return 'Terminal' }
    if ($n -like 'ST_*') { return 'StringTable' }
    if ($n -like 'DT_*' -or $asset -match '/Cut_Scenes/|/Cutscenes/|DLC01_Cutscenes') { return 'Subtitle' }
    if ($field -in @('Surname','NPCName','Patronymic','Name','NPC2Name','NPC3Name')) { return 'Name' }
    if ($field -in @('Position','PlaceOfWork','PersonDossier','Subject','MailBody')) { return 'Terminal' }
    if ($n -like 'D_*') { return 'Dialogue' }
    return 'Other'
}
function Get-Speaker([string]$asset, [string]$field) {
    $n = [IO.Path]::GetFileNameWithoutExtension($asset)
    if ($n -match '(Chelomey|Chelomei)') { return 'Chelomey' }
    if ($n -match 'Sechenov') { return 'Sechenov' }
    if ($n -match 'Lebedev') { return 'Lebedev' }
    if ($n -match 'Zina|Baba') { return 'Zinaida' }
    if ($n -match 'Eleanor') { return 'Eleanor' }
    if ($n -match 'Petrov') { return 'Petrov' }
    if ($n -match 'Filatova') { return 'Filatova' }
    if ($n -match 'Muravyova') { return 'Muravyova' }
    if ($n -match 'Charles|Char_les') { return 'Char-les' }
    if ($n -match 'P3|Nechaev') { return 'P-3' }
    return ''
}

$trans = Read-TsvRaw (Join-Path $repo 'build\c6\translations_all.tsv')
$known = @{}
foreach ($t in $trans) { $known[(Norm $t.ru)] = $true }

$all = Read-TsvRaw (Join-Path $repo 'build\c6\all_strings.tsv')
$uniq = [ordered]@{}
$totalRows = 0
foreach ($r in $all) {
    $t = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($r.text_b64))
    $n = Norm $t
    if ($known.ContainsKey($n)) { continue }
    $totalRows++
    if ($uniq.Contains($n)) { $uniq[$n].count++; continue }
    $clean = $t.Replace("`r", ' ').Replace("`n", ' ').Replace("`t", ' ')
    $markers = (([regex]::Matches($t, '\*[0-9][0-9.\-]*\*')) | ForEach-Object { $_.Value }) -join ' '
    $cat = Get-Category $r.asset $r.field
    $spk = Get-Speaker $r.asset $r.field
    $uniq[$n] = [pscustomobject]@{ id = ''; ru = $clean; category = $cat; speakers = $spk; asset = $r.asset; kind = $r.kind; field = $r.field; markers = $markers; count = 1 }
}
$i = 0
$rows = New-Object System.Collections.Generic.List[object]
foreach ($k in $uniq.Keys) {
    $i++
    $o = $uniq[$k]
    $o.id = ('C6X' + $i.ToString('00000'))
    $rows.Add($o)
}
$out = New-Object System.Collections.Generic.List[string]
$out.Add("id`tru`tcategory`tspeakers`tasset`tmarkers`tkind`tfield`tcount")
foreach ($o in $rows) {
    $out.Add(($o.id + "`t" + $o.ru + "`t" + $o.category + "`t" + $o.speakers + "`t" + $o.asset + "`t" + $o.markers + "`t" + $o.kind + "`t" + $o.field + "`t" + $o.count))
}
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\unique_unmatched.tsv'), $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('rows ' + $totalRows + ' unique ' + $rows.Count)
