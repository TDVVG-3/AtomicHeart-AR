$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
$TAB = [char]9
$RepoRoot = 'C:\AtomicHeart-AR'
$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$lines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$utf8 = New-Object Text.UTF8Encoding($false)

function Reason-Of([string]$en) {
    if ($en -eq '') { return 'empty source' }
    if ($en -notmatch '\p{L}') { return 'no letters (numbers/symbols)' }
    if ($en -match '^\[(do not localize|DO NOT LOCALIZE)\]$') { return 'localization marker' }
    $toks = @($en -split '\s+' | Where-Object { $_ -ne '' })
    if ($toks.Count -le 1) { return 'single token / identifier' }
    return 'technical label / proper name'
}

$total = 0; $translated = 0; $copyClass = 0; $unexpected = 0
$reasons = @{}
$scopes = @{}
$cats = @{}
$englishFilled = New-Object System.Collections.Generic.List[string]
$englishFilled.Add("line`tscope`tkey`tenglish`treason")
$uiLong = New-Object System.Collections.Generic.List[object]
$unexpectedRows = New-Object System.Collections.Generic.List[string]

for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split $TAB
    if ($f.Count -ne 13) { continue }
    $total++
    $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $cat = $f[9]; if (-not $cat) { $cat = '(none)' }
    if (-not $scopes.ContainsKey($scope)) { $scopes[$scope] = @{ total = 0; ar = 0; copy = 0 } }
    if (-not $cats.ContainsKey($cat)) { $cats[$cat] = @{ total = 0; ar = 0; copy = 0 } }
    $scopes[$scope].total++; $cats[$cat].total++
    if ($f[6].Trim()) {
        $translated++
        $scopes[$scope].ar++; $cats[$cat].ar++
        if ($cat -eq 'UI') {
            $uiLong.Add([pscustomobject]@{ L = ($i + 1); len = $f[6].Length; en = $f[5]; ar = $f[6]; key = $f[4] })
        }
    } else {
        $reason = Reason-Of $f[5]
        $isCopy = $true
        if ($reason -eq 'technical label / proper name') {
            $en = $f[5]
            $isCopy = $false
            if ($en -match '^\{[^}]+\}') { $isCopy = $true }
            if ($en -match '^<[^>]+>$') { $isCopy = $true }
            if ($en -match '^[0-9]+[xX][0-9]+$') { $isCopy = $true }
            if ($en -match '\((1080p|720p|1440p|2160p)\)') { $isCopy = $true }
            if ($en -cmatch '^(Nvidia|AMD|Intel)') { $isCopy = $true }
            if ($en -match '^[A-Z0-9][A-Z0-9 \-\._/]*$') { $isCopy = $true }
            if ($en -match '^DUMMY') { $isCopy = $true }
            if ($en -match '^[A-Za-z][A-Za-z0-9]*\s*:$') { $isCopy = $true }
            if ($en -match '^\*[0-9][0-9.\-]*\*\s*&.+&$') { $isCopy = $true }
            if ($en -match '^(portugu|deutsch|espa|fran|italiano|polski|english)') { $isCopy = $true }
            if ($en -match '[a-z][\u0400-\u04FF]|[\u0400-\u04FF][a-z]') { $isCopy = $true }
            if (-not $isCopy) {
                $unexpected++
                if ($unexpectedRows.Count -lt 40) { $unexpectedRows.Add(('line ' + ($i + 1) + ' | ' + $scope + ' | ' + $en)) }
                continue
            }
        }
        $copyClass++
        $scopes[$scope].copy++; $cats[$cat].copy++
        if (-not $reasons.ContainsKey($reason)) { $reasons[$reason] = 0 }
        $reasons[$reason]++
        $englishFilled.Add(($i + 1).ToString() + $TAB + $scope + $TAB + $f[4] + $TAB + $f[5] + $TAB + $reason)
    }
}

$translatable = $total - $copyClass
$pctTr = 0.0; if ($translatable -gt 0) { $pctTr = [Math]::Round(100.0 * $translated / $translatable, 2) }
$pctAll = [Math]::Round(100.0 * $translated / $total, 2)

$out = New-Object System.Collections.Generic.List[string]
$out.Add('# Coverage - cycle 016 (text passes + carrier p11)')
$out.Add('')
$out.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$out.Add('')
$out.Add('Same classification as cycle 015: a row is copy-class when its Arabic cell is empty and')
$out.Add('the English needs no translation (placeholders, tags, resolutions, brands, debug ids,')
$out.Add('Cyrillic-in-Latin tokens). Everything else is translatable and must carry Arabic.')
$out.Add('')
$out.Add('## Totals')
$out.Add('')
$out.Add('| metric | value |')
$out.Add('| --- | --- |')
$out.Add(('| master rows | {0} |' -f $total))
$out.Add(('| rows with Arabic | {0} |' -f $translated))
$out.Add(('| copy-class rows left English-filled | {0} |' -f $copyClass))
$out.Add(('| translatable rows | {0} |' -f $translatable))
$out.Add(('| coverage of translatable rows | {0} of {1} ({2}%) |' -f $translated, $translatable, $pctTr))
$out.Add(('| coverage of all rows | {0} of {1} ({2}%) |' -f $translated, $total, $pctAll))
$out.Add(('| rows needing review (not copy-class, still empty) | {0} |' -f $unexpected))
$out.Add('')
$out.Add('## Copy-class reasons')
$out.Add('')
$out.Add('| reason | rows |')
$out.Add('| --- | --- |')
foreach ($k in ($reasons.Keys | Sort-Object { -$reasons[$_] })) { $out.Add(('| {0} | {1} |' -f $k, $reasons[$k])) }
$out.Add('')
$out.Add('## Per scope')
$out.Add('')
$out.Add('| scope | rows | Arabic | copy-class | coverage of translatable |')
$out.Add('| --- | --- | --- | --- | --- |')
foreach ($s in ($scopes.Keys | Sort-Object)) {
    $d = $scopes[$s]; $tr = $d.total - $d.copy
    $p = 0.0; if ($tr -gt 0) { $p = [Math]::Round(100.0 * $d.ar / $tr, 2) }
    $out.Add(('| {0} | {1} | {2} | {3} | {4} of {5} ({6}%) |' -f $s, $d.total, $d.ar, $d.copy, $d.ar, $tr, $p))
}
$out.Add('')
$out.Add('## Per category')
$out.Add('')
$out.Add('| category | rows | Arabic | copy-class | coverage of translatable |')
$out.Add('| --- | --- | --- | --- | --- |')
foreach ($c in ($cats.Keys | Sort-Object)) {
    $d = $cats[$c]; $tr = $d.total - $d.copy
    $p = 0.0; if ($tr -gt 0) { $p = [Math]::Round(100.0 * $d.ar / $tr, 2) }
    $out.Add(('| {0} | {1} | {2} | {3} | {4} of {5} ({6}%) |' -f $c, $d.total, $d.ar, $d.copy, $d.ar, $tr, $p))
}
$out.Add('')
if ($unexpectedRows.Count -gt 0) {
    $out.Add('## Rows needing review (not copy-class, still empty) - first 40')
    $out.Add('')
    foreach ($r in $unexpectedRows) { $out.Add('- ' + $r) }
    $out.Add('')
}
[IO.File]::WriteAllLines((Join-Path $RepoRoot 'reports\coverage_cycle016.md'), $out, $utf8)
[IO.File]::WriteAllLines((Join-Path $RepoRoot 'reports\english_filled_rows.tsv'), $englishFilled, $utf8)

$top = $uiLong | Sort-Object len -Descending | Select-Object -First 30
$ul = New-Object System.Collections.Generic.List[string]
$ul.Add('# 30 longest UI labels (Arabic length)')
$ul.Add('')
$ul.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$ul.Add('')
$ul.Add('These are the UI rows most likely to clip or wrap badly at the shipped widget size.')
$ul.Add('Check them in the upgrade menu, the terminal and the PDA during the in-game pass.')
$ul.Add('')
$ul.Add('| # | chars | line | key | English | Arabic |')
$ul.Add('| --- | --- | --- | --- | --- | --- |')
$n = 0
foreach ($r in $top) {
    $n++
    $en = $r.en -replace '\|', '/'
    $ar = $r.ar -replace '\|', '/'
    $ul.Add(('| {0} | {1} | {2} | {3} | {4} | {5} |' -f $n, $r.len, $r.L, $r.key, $en, $ar))
}
[IO.File]::WriteAllLines((Join-Path $RepoRoot 'reports\ui_longest_labels.md'), $ul, $utf8)

Write-Output ('[cycle016] rows {0} | arabic {1} | copy-class {2} | translatable {3} | coverage {4}% | review-needed {5}' -f $total, $translated, $copyClass, $translatable, $pctTr, $unexpected)
Write-Output ('[cycle016] coverage: reports\coverage_cycle016.md')
Write-Output ('[cycle016] english-filled rows: {0} -> reports\english_filled_rows.tsv' -f ($englishFilled.Count - 1))
Write-Output ('[cycle016] UI labels ranked: {0} -> reports\ui_longest_labels.md' -f $top.Count)
