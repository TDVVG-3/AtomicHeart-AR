$ErrorActionPreference = 'Stop'
$repo = 'C:\AtomicHeart-AR'
$rows = Import-Csv (Join-Path $repo 'build\c6\collected.tsv') -Delimiter "`t"
$byAsset = @{}
foreach ($r in $rows) {
    if (-not $byAsset.ContainsKey($r.asset)) { $byAsset[$r.asset] = New-Object System.Collections.Generic.List[object] }
    $byAsset[$r.asset].Add($r)
}
$selRows = Import-Csv (Join-Path $repo 'build\c6\scope_analysis.tsv') -Delimiter "`t"
# scope_analysis has no selected strings; rebuild selection per asset from dumps (same filter)
$dumpRoot = Join-Path $repo 'localization\extracted\dialogue'
$scan = Import-Csv (Join-Path $repo 'reports\dialogue_st_counts.tsv') -Delimiter "`t"
$dumpByAsset = @{}
foreach ($s in $scan) { $dumpByAsset[$s.path] = $s.dump }
$words = [regex]'[A-Za-z\u0400-\u04FF\u0600-\u06FF\u0590-\u05FF]{3,}'
function Get-DialogueStrings([string]$dumpText) {
    $m = [regex]::Match($dumpText, '(?s)## UTF-16 strings\r?\n(.*?)(\r?\n\s*## ASCII strings|$)')
    if (-not $m.Success) { return @() }
    $raw = $m.Groups[1].Value -split "`r?`n"
    $seen = @{}; $out = New-Object System.Collections.Generic.List[string]
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
        $seen[$t] = $true; $out.Add($t)
    }
    return $out
}

$out = New-Object System.Collections.Generic.List[string]
$out.Add("asset`tselected`torphans`tselectedText")
$orphanTotal = 0
$selectedTotal = 0
foreach ($asset in ($byAsset.Keys | Sort-Object)) {
    $d = $dumpByAsset[$asset]
    if (-not $d) { continue }
    $p = Join-Path $dumpRoot $d
    if (-not (Test-Path $p)) { continue }
    $sel = @(Get-DialogueStrings ([IO.File]::ReadAllText($p, [Text.Encoding]::UTF8)))
    $assetRows = $byAsset[$asset]
    $orph = New-Object System.Collections.Generic.List[string]
    foreach ($s in $sel) {
        $selectedTotal++
        $hit = $false
        foreach ($r in $assetRows) { if ($r.text.Contains($s)) { $hit = $true; break } }
        if (-not $hit) { $orph.Add($s); $orphanTotal++ }
    }
    $out.Add(($asset + "`t" + $sel.Count + "`t" + $orph.Count + "`t" + (($orph | ForEach-Object { $_.Replace("`t",' ') }) -join ' | ')))
}
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\selected_orphans.tsv'), $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('selected ' + $selectedTotal + ' | orphans ' + $orphanTotal)
