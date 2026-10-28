$ErrorActionPreference = 'Stop'
$repo = 'C:\AtomicHeart-AR'
$dump = Join-Path $repo 'localization\extracted\dialogue\pakchunk0-WindowsNoEditor__DT_Subtitles_Academy.txt'
$json = Get-ChildItem (Join-Path $repo 'build\c6\json') -Recurse -Filter '*DT_Subtitles_Academy*.json' | Select-Object -First 1

$words = [regex]'[A-Za-z\u0400-\u04FF\u0600-\u06FF\u0590-\u05FF]{3,}'
function Get-DialogueStrings([string]$dumpText) {
    $m = [regex]::Match($dumpText, '(?s)## UTF-16 strings\r?\n(.*?)(\r?\n\s*## ASCII strings|$)')
    if (-not $m.Success) { return @() }
    $raw = $m.Groups[1].Value -split "`r?`n"
    $seen = @{}
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($s in $raw) {
        $t = $s.Trim()
        if ($t.Length -lt 8 -or $t.Length -gt 1000) { continue }
        if (-not $t.Contains(' ')) { continue }
        if ($t.Contains('/') -or $t.Contains('\') -or $t.Contains('::')) { continue }
        if ($t -match '\.(uasset|uexp|locres|png|wav|ogg|umap)$') { continue }
        if ($t -match '^(DC_|BP_|ST_|LS_|SK_|M_|T_|SM_)') { continue }
        if ($t -match 'Property|Function|Blueprint|Struct|Enum|Class|Asset|Package|Level|Component|Actor') { continue }
        if ($t.Contains(':')) { continue }
        if ($words.Matches($t).Count -lt 2) { continue }
        if ($seen.ContainsKey($t)) { continue }
        $seen[$t] = $true
        $out.Add($t)
    }
    return $out
}

$txt = [IO.File]::ReadAllText($dump, [Text.Encoding]::UTF8)
$sel = Get-DialogueStrings $txt
$j = [IO.File]::ReadAllText($json.FullName, [Text.Encoding]::UTF8) | ConvertFrom-Json
$rows = $j.Exports[0].Table.Data
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('selected: ' + $sel.Count + ' | rows: ' + $rows.Count)
$i = 0
foreach ($s in $sel) { $i++; $lines.Add('SEL ' + $i + ' | ' + $s) }
$lines.Add('')
$k = 0
foreach ($r in $rows) {
    $t = ($r.Value | Where-Object { $_.Name -eq 'Sentences' } | Select-Object -First 1).CultureInvariantString
    $mk = ($r.Value | Where-Object { $_.Name -eq 'Marker' } | Select-Object -First 1).Value
    $sp = ($r.Value | Where-Object { $_.Name -eq 'Speaker' } | Select-Object -First 1).CultureInvariantString
    $k++
    $hit = $sel -contains $t
    $lines.Add('ROW ' + $k + ' ' + $r.Name + ' [' + $sp + '] ' + $mk + ' | insight=' + $hit + ' | len=' + ([string]$t).Length + ' | ' + $t)
}
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\academy_compare.txt'), $lines, (New-Object Text.UTF8Encoding($false)))
Write-Output ('selected ' + $sel.Count)
