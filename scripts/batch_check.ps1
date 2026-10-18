<#
.SYNOPSIS
  Validates batch-1 chunk Arabic files against their English chunk files.

.DESCRIPTION
  For every chunk (or one chunk) checks:
    - header, row count, id set and order
    - non-empty Arabic, no U+FFFD, no stray tabs
    - protected tokens preserved byte-exact and in order:
        rich-text tags <...>, placeholders {...}, &Speaker& labels
    - structural symbols count: % || 
    - Arabic script present where the English is real prose
    - length warnings for short UI labels
  Exit code 0 = PASS, 1 = FAIL. Warnings never fail the gate.

  ASCII-only script (KI-021). Reads UTF-8 data files explicitly.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$Chunk = '',
    [switch]$ShowWarnings
)
$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$dir = Join-Path $RepoRoot 'localization\working\batch1'
$utf8 = New-Object Text.UTF8Encoding($false)

function Get-Tokens([string]$s, [string]$pattern) {
    $list = New-Object System.Collections.Generic.List[string]
    foreach ($m in [regex]::Matches($s, $pattern)) { $list.Add($m.Value) }
    return , $list
}
function Count-Ch([string]$s, [string]$ch) { return ([regex]::Matches($s, [regex]::Escape($ch))).Count }

# classes of English strings that are legitimately copied unchanged
function Test-CopyAllowed([string]$en) {
    if ($en -match '^[\s\p{P}\p{S}0-9]*$') { return $true }          # symbols/numbers only
    if ($en -match '^<[^>]*>$') { return $true }                       # a lone tag
    if ($en -match '^(\s*<[^>]*>\s*)+$') { return $true }              # tags only
    if ($en -match '^\s*[\u0600-\u06FF]') { return $true }             # already Arabic
    $endonyms = @('español', 'français', 'português', '日本語', '漢語', '한국어', 'd????dsss')
    foreach ($e in $endonyms) { if ($en -eq $e) { return $true } }
    if ($en -match '^[A-Z0-9][A-Z0-9\-\u2014 ]+$' -and $en.Length -le 20 -and $en -notmatch '[AEIOU]{2,}') { return $true } # model codes
    return $false
}

$chunks = @()
if ($Chunk) { $chunks = @($Chunk) }
else {
    foreach ($f in (Get-ChildItem (Join-Path $dir 'chunk_*_en.tsv') | Sort-Object Name)) {
        if ($f.Name -match '^chunk_(\d+)_en\.tsv$') { $chunks += $Matches[1] }
    }
}

$failTotal = 0
$summary = New-Object System.Collections.Generic.List[string]
foreach ($c in $chunks) {
    $enPath = Join-Path $dir ('chunk_{0}_en.tsv' -f $c)
    $arPath = Join-Path $dir ('chunk_{0}_ar.tsv' -f $c)
    if (-not (Test-Path $arPath)) {
        Write-Output ('chunk {0}: MISSING {1}' -f $c, $arPath)
        $failTotal++
        continue
    }
    $en = [IO.File]::ReadAllLines($enPath, [Text.Encoding]::UTF8)
    $ar = [IO.File]::ReadAllLines($arPath, [Text.Encoding]::UTF8)
    $enRows = @(); for ($i = 1; $i -lt $en.Count; $i++) { if ($en[$i].Trim()) { $enRows += , ($en[$i] -split "`t") } }
    $arRows = @(); for ($i = 1; $i -lt $ar.Count; $i++) { if ($ar[$i].Trim()) { $arRows += , ($ar[$i] -split "`t") } }

    $problems = New-Object System.Collections.Generic.List[string]
    $warnings = New-Object System.Collections.Generic.List[string]
    $noArLines = New-Object System.Collections.Generic.List[string]

    # header
    if ($ar.Count -eq 0 -or $ar[0].Trim() -notmatch '^id\s+arabic$') { $problems.Add('header is not "id<TAB>arabic"') }

    # id set / order
    if ($arRows.Count -ne $enRows.Count) { $problems.Add(('row count {0} != expected {1}' -f $arRows.Count, $enRows.Count)) }
    $max = [Math]::Min($arRows.Count, $enRows.Count)
    $orderBad = 0
    for ($i = 0; $i -lt $max; $i++) {
        if ($arRows[$i][0] -ne $enRows[$i][0]) { $orderBad++; if ($orderBad -le 5) { $problems.Add(('id mismatch at row {0}: ar={1} expected={2}' -f ($i + 1), $arRows[$i][0], $enRows[$i][0])) } }
        if ($arRows[$i].Count -lt 2) { $problems.Add(('row {0} ({1}) has no Arabic cell' -f ($i + 1), $arRows[$i][0])) }
    }

    $badTag = 0; $badPh = 0; $badSpeaker = 0; $badSym = 0; $badTiming = 0; $empty = 0; $fffd = 0; $copied = 0; $lenWarn = 0; $noArabic = 0
    for ($i = 0; $i -lt $max; $i++) {
        $id = $enRows[$i][0]; $eng = $enRows[$i][1]
        $arb = ''
        if ($arRows[$i].Count -ge 2) { $arb = ($arRows[$i] | Select-Object -Skip 1) -join "`t" }
        if (-not $arb.Trim()) { $empty++; if ($problems.Count -lt 40) { $problems.Add(($id + ' empty Arabic')) }; continue }
        if ($arb.IndexOf([char]0xFFFD) -ge 0) { $fffd++; if ($problems.Count -lt 40) { $problems.Add(($id + ' contains U+FFFD')) } }

        $tEn = Get-Tokens $eng '<[^>]*>'; $tAr = Get-Tokens $arb '<[^>]*>'
        if (($tEn -join '|') -ne ($tAr -join '|')) { $badTag++; if ($problems.Count -lt 40) { $problems.Add(($id + ' tags differ: EN[' + ($tEn -join ',') + '] AR[' + ($tAr -join ',') + ']')) } }
        $pEn = Get-Tokens $eng '\{[^}]*\}'; $pAr = Get-Tokens $arb '\{[^}]*\}'
        if (($pEn -join '|') -ne ($pAr -join '|')) { $badPh++; if ($problems.Count -lt 40) { $problems.Add(($id + ' placeholders differ: EN[' + ($pEn -join ',') + '] AR[' + ($pAr -join ',') + ']')) } }
        $sEn = Get-Tokens $eng '&[^&\s]+&'; $sAr = Get-Tokens $arb '&[^&\s]+&'
        if (($sEn -join '|') -ne ($sAr -join '|')) { $badSpeaker++; if ($problems.Count -lt 40) { $problems.Add(($id + ' speaker labels differ')) } }
        $mEn = Get-Tokens $eng '\*[0-9]+\.[0-9]+\*'; $mAr = Get-Tokens $arb '\*[0-9]+\.[0-9]+\*'
        if (($mEn -join '|') -ne ($mAr -join '|')) { $badTiming++; if ($problems.Count -lt 40) { $problems.Add(($id + ' timing markers differ: EN[' + ($mEn -join ',') + '] AR[' + ($mAr -join ',') + ']')) } }
        if ((Count-Ch $eng '%') -ne (Count-Ch $arb '%')) { $badSym++; if ($problems.Count -lt 40) { $problems.Add(($id + ' percent count differs')) } }
        if ((Count-Ch $eng '||') -ne (Count-Ch $arb '||')) { $badSym++; if ($problems.Count -lt 40) { $problems.Add(($id + ' || count differs')) } }

        $enLen = $eng.Length; $arLen = $arb.Length
        $hasAr = [regex]::IsMatch($arb, '[\u0621-\u064A\u0660-\u0669\u066E-\u06D3\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF]')
        if (-not $hasAr) {
            $copied++
            $noArLines.Add($id + "`t" + $eng + "`t" + $arb + "`t" + $(if (Test-CopyAllowed $eng) { 'copy-class' } else { 'REVIEW' }))
        }
        if ($hasAr -and $enLen -le 40 -and $arLen -gt [Math]::Ceiling($enLen * 1.15) + 3) { $lenWarn++; $warnings.Add(('{0} long: EN {1} -> AR {2} :: {3}' -f $id, $enLen, $arLen, $eng)) }
    }

    $fails = $problems.Count
    if ($fails -gt 0) { $failTotal++ }
    if ($noArLines.Count -gt 0) { [IO.File]::WriteAllLines((Join-Path $dir ('chunk_{0}_copy.tsv' -f $c)), $noArLines, $utf8) }
    $verdict = if ($fails -eq 0) { 'PASS' } else { 'FAIL' }
    Write-Output ('=== chunk {0}: {1} ===' -f $c, $verdict)
    Write-Output ('  rows: {0} | empty: {1} | U+FFFD: {2} | bad tags: {3} | bad placeholders: {4} | bad speakers: {5} | bad timing: {6}' -f $max, $empty, $fffd, $badTag, $badPh, $badSpeaker, $badTiming)
    Write-Output ('  symbol mismatches: {0} | no-Arabic copy rows: {1} | length warnings: {2}' -f $badSym, $noArLines.Count, $lenWarn)
    foreach ($p in $problems) { Write-Output ('  PROBLEM ' + $p) }
    if ($ShowWarnings) { foreach ($w in $warnings) { Write-Output ('  warn ' + $w) } }
    $summary.Add(('{0}: {1} rows, {2} problems, {3} warnings' -f $c, $max, $fails, $lenWarn))
}

Write-Output ''
Write-Output ('GATE: ' + $(if ($failTotal -eq 0) { 'PASS' } else { ('FAIL (' + $failTotal + ' chunk(s))') }))
exit $failTotal
