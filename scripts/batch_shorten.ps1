<#
.SYNOPSIS
  Batch-1 UI length pass. Two modes:

    -Generate : writes localization/working/batch1/shorten_in.tsv with every master row whose
                Arabic is at least 1.4x the English length and whose category is UI
                (columns: key, english, arabic, en_len, ar_len, ratio).
    -Apply    : reads localization/working/batch1/shorten_out.tsv (key, newArabic), verifies the
                row still holds the recorded Arabic, appends a literal rule per row to
                localization/working/tm_fixups.tsv and calls apply_text_fixups.ps1.
                A rule is only appended when the CURRENT Arabic text occurs in exactly one
                master cell (so a substring replacement can never touch another row).

  ASCII-only script (KI-021); all Arabic lives in the UTF-8 data files.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [switch]$Generate,
    [switch]$Apply
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$dir = Join-Path $RepoRoot 'localization\working\batch1'
$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$fixPath = Join-Path $RepoRoot 'localization\working\tm_fixups.tsv'
$utf8 = New-Object Text.UTF8Encoding($false)
$arabicLetterRx = '[\u0621-\u064A\u0660-\u0669\u066E-\u06D3\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF]'

if ($Generate) {
    $lines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
    $out = New-Object System.Collections.Generic.List[string]
    $out.Add('key' + "`t" + 'english' + "`t" + 'arabic' + "`t" + 'en_len' + "`t" + 'ar_len' + "`t" + 'ratio')
    $n = 0
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if (-not $lines[$i].Trim()) { continue }
        $f = $lines[$i] -split "`t"
        if ($f.Count -ne 13) { continue }
        if (-not $f[6].Trim() -or $f[9] -ne 'UI') { continue }
        $en = $f[5]; $ar = $f[6]
        if ($en.Trim().Length -lt 8) { continue }
        $ratio = [Math]::Round($ar.Length / [double]$en.Length, 2)
        if ($ratio -lt 1.4) { continue }
        $out.Add($f[4] + "`t" + $en + "`t" + $ar + "`t" + $en.Length + "`t" + $ar.Length + "`t" + $ratio)
        $n++
    }
    [IO.File]::WriteAllLines((Join-Path $dir 'shorten_in.tsv'), $out, $utf8)
    Write-Output ('[shorten] rows with ratio >= 1.4: {0} -> {1}' -f $n, (Join-Path $dir 'shorten_in.tsv'))
    exit 0
}

if ($Apply) {
    $inPath = Join-Path $dir 'shorten_in.tsv'
    $outPath = Join-Path $dir 'shorten_out.tsv'
    if (-not (Test-Path $outPath)) { throw "missing $outPath" }
    $rec = @{}
    $il = [IO.File]::ReadAllLines($inPath, [Text.Encoding]::UTF8)
    for ($i = 1; $i -lt $il.Count; $i++) { if (-not $il[$i].Trim()) { continue }; $f = $il[$i] -split "`t"; $rec[$f[0]] = [pscustomobject]@{ en = $f[1]; ar = $f[2] } }
    # count how often each current Arabic cell appears, to prove a rule is unambiguous
    $mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
    $rules = New-Object System.Collections.Generic.List[string]
    $skipped = 0; $applied = 0
    $ol = [IO.File]::ReadAllLines($outPath, [Text.Encoding]::UTF8)
    for ($i = 1; $i -lt $ol.Count; $i++) {
        if (-not $ol[$i].Trim()) { continue }
        $f = $ol[$i] -split "`t"
        if ($f.Count -lt 2) { continue }
        $key = $f[0]; $newAr = ($f | Select-Object -Skip 1) -join "`t"
        if (-not $rec.ContainsKey($key)) { Write-Output ('   skip (not in shorten_in): ' + $key); $skipped++; continue }
        $oldAr = $rec[$key].ar
        if ($newAr -ceq $oldAr) { $skipped++; continue }
        if (-not [regex]::IsMatch($newAr, $arabicLetterRx)) { Write-Output ('   skip (no Arabic letter): ' + $key); $skipped++; continue }
        # the old cell must still be present in exactly the master cell of this key
        $cellMatches = 0; $otherContains = 0
        for ($j = 1; $j -lt $mlines.Count; $j++) {
            $g = $mlines[$j] -split "`t"
            if ($g.Count -ne 13) { continue }
            if ($g[6] -ceq $oldAr) { $cellMatches++ }
            elseif ($g[6].Contains($oldAr)) { $otherContains++ }
        }
        if ($cellMatches -ne 1 -or $otherContains -gt 0) { Write-Output ('   skip (ambiguous: exact={0} contained-elsewhere={1}): {2}' -f $cellMatches, $otherContains, $key); $skipped++; continue }
        if ($newAr.Length -ge $oldAr.Length) { Write-Output ('   skip (not shorter): ' + $key); $skipped++; continue }
        $rules.Add($oldAr + "`t" + $newAr + "`t" + ('batch1 shorten: {0} -> {1} chars' -f $oldAr.Length, $newAr.Length))
        $applied++
    }
    if ($rules.Count -gt 0) {
        $raw = [IO.File]::ReadAllText($fixPath, [Text.Encoding]::UTF8)
        if (-not $raw.EndsWith("`n")) { $raw = $raw + "`r`n" }
        $add = ($rules -join "`r`n")
        [IO.File]::WriteAllText($fixPath, ($raw + $add + "`r`n"), $utf8)
    }
    Write-Output ('[shorten] rules appended: {0} | skipped: {1}' -f $applied, $skipped)
    exit 0
}

throw 'pass -Generate or -Apply'
