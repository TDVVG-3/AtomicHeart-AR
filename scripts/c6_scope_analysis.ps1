$ErrorActionPreference = 'Stop'
$repo = 'C:\AtomicHeart-AR'
$dumpRoot = Join-Path $repo 'localization\extracted\dialogue'
$rows = Import-Csv (Join-Path $repo 'build\c6\collected.tsv') -Delimiter "`t"

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

$scan = Import-Csv (Join-Path $repo 'reports\dialogue_st_counts.tsv') -Delimiter "`t"
$dumpByAsset = @{}
foreach ($s in $scan) { $dumpByAsset[$s.path] = $s.dump }

$selByAsset = @{}
$selTotal = 0
$assetSet = @{}
foreach ($r in $rows) { $assetSet[$r.asset] = $true }
foreach ($a in $assetSet.Keys) {
    $d = $dumpByAsset[$a]
    if (-not $d) { continue }
    $p = Join-Path $dumpRoot $d
    if (-not (Test-Path $p)) { continue }
    $txt = [IO.File]::ReadAllText($p, [Text.Encoding]::UTF8)
    $sel = @(Get-DialogueStrings $txt)
    $selByAsset[$a] = $sel
    $selTotal += $sel.Count
}
Write-Output ('selected total: ' + $selTotal)

$out = New-Object System.Collections.Generic.List[string]
$out.Add("asset`tkey`tcategory`tspeaker`ttriggered`ttext")
$tr = 0; $un = 0; $trChars = 0; $unChars = 0
$trTexts = @{}; $unTexts = @{}
foreach ($r in $rows) {
    $sel = $selByAsset[$r.asset]
    $hit = $false
    if ($sel) {
        foreach ($s in $sel) {
            if ($r.text.Contains($s)) { $hit = $true; break }
        }
    }
    if ($hit) { $tr++; $trChars += $r.text.Length; $trTexts[$r.text] = 1 }
    else { $un++; $unChars += $r.text.Length; $unTexts[$r.text] = 1 }
    $out.Add(($r.asset + "`t" + $r.key + "`t" + $r.category + "`t" + $r.speaker + "`t" + $hit + "`t" + $r.text))
}
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\scope_analysis.tsv'), $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('triggered rows ' + $tr + ' | unique ' + $trTexts.Count + ' | chars ' + $trChars + ' (unique ' + (($trTexts.Keys | ForEach-Object { $_.Length } | Measure-Object -Sum).Sum) + ')')
Write-Output ('untriggered rows ' + $un + ' | unique ' + $unTexts.Count + ' | chars ' + $unChars + ' (unique ' + (($unTexts.Keys | ForEach-Object { $_.Length } | Measure-Object -Sum).Sum) + ')')
