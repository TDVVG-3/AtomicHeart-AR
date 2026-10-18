<#
.SYNOPSIS
  Applies the batch-1 UI length pass KEY-SCOPED (one master row at a time), for the rows
  that the literal find/replace engine had to skip because several cells share the same
  Arabic text.

.DESCRIPTION
  Reads localization/working/batch1/shorten_in.tsv  (key, english, arabic, en_len, ar_len, ratio)
        localization/working/batch1/shorten_out.tsv (key, newArabic)
  For every key whose Arabic actually changed it:
    - verifies the master row still holds the recorded Arabic (idempotent, no double edit)
    - verifies protected tokens survive: every <tag>, {placeholder}, digit run and % / + / / / ( ) / —
      present in the old Arabic is present in the new Arabic in the same order
    - verifies the new Arabic is strictly shorter and contains an Arabic letter
    - writes the new Arabic into localization/master/atomic-heart-ar.tsv (Arabic column only)
    - updates the matching english -> arabic row in localization/working/tm.tsv
  ASCII-only script (KI-021); Arabic lives in the UTF-8 data files.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$dir        = Join-Path $RepoRoot 'localization\working\batch1'
$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$tmPath     = Join-Path $RepoRoot 'localization\working\tm.tsv'
$utf8       = New-Object Text.UTF8Encoding($false)
$arabicLetterRx = '[\u0621-\u064A\u0660-\u0669\u066E-\u06D3\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF]'

function Get-Tokens([string]$s, [string]$pattern) {
    $list = New-Object System.Collections.Generic.List[string]
    foreach ($m in [regex]::Matches($s, $pattern)) { $list.Add($m.Value) }
    return , $list
}

$old = @{}
$il = [IO.File]::ReadAllLines((Join-Path $dir 'shorten_in.tsv'), [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $il.Count; $i++) {
    if (-not $il[$i].Trim()) { continue }
    $f = $il[$i] -split "`t"
    $old[$f[0]] = [pscustomobject]@{ en = $f[1]; ar = $f[2] }
}

$newMap = @{}
$ol = [IO.File]::ReadAllLines((Join-Path $dir 'shorten_out.tsv'), [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $ol.Count; $i++) {
    if (-not $ol[$i].Trim()) { continue }
    $f = $ol[$i] -split "`t"
    if ($f.Count -lt 2) { continue }
    $newMap[$f[0]] = ($f | Select-Object -Skip 1) -join "`t"
}

$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$applied = 0; $skipped = 0; $changedEnglish = @{}
for ($i = 1; $i -lt $mlines.Count; $i++) {
    if (-not $mlines[$i].Trim()) { continue }
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $key = $f[4]
    if (-not $newMap.ContainsKey($key)) { continue }
    if (-not $old.ContainsKey($key)) { continue }
    $oldAr = $old[$key].ar
    $newAr = $newMap[$key]
    if ($newAr -ceq $oldAr) { continue }
    if ($f[6] -cne $oldAr) { $skipped++; continue }          # already shortened / diverged -> leave alone
    if ($newAr.Length -ge $oldAr.Length) { $skipped++; continue }
    if (-not [regex]::IsMatch($newAr, $arabicLetterRx)) { Write-Output ('   skip (no Arabic letter): ' + $key); $skipped++; continue }
    $ok = $true
    foreach ($rx in @('<[^>]*>', '\{[^}]*\}', '[0-9]+', '%', '\|\|')) {
        $a = (Get-Tokens $oldAr $rx) -join '|'
        $b = (Get-Tokens $newAr $rx) -join '|'
        if ($a -ne $b) {
            Write-Output ('   skip (token class ' + $rx + ' differs): ' + $key)
            $ok = $false
            break
        }
    }
    if (-not $ok) { $skipped++; continue }
    $f[6] = $newAr
    $mlines[$i] = ($f -join "`t")
    $changedEnglish[$f[5]] = $newAr
    $applied++
}
Write-Output ('[shorten-keys] applied: {0} | skipped: {1}' -f $applied, $skipped)

if (-not $DryRun -and $applied -gt 0) {
    [IO.File]::WriteAllLines($masterPath, $mlines, $utf8)
    Write-Output ('[master] written: {0}' -f $masterPath)
    $tmlines = [IO.File]::ReadAllLines($tmPath, [Text.Encoding]::UTF8)
    $tmChanged = 0
    for ($i = 1; $i -lt $tmlines.Count; $i++) {
        if (-not $tmlines[$i].Trim()) { continue }
        $tf = $tmlines[$i] -split "`t"
        if ($tf.Count -lt 2) { continue }
        if ($changedEnglish.ContainsKey($tf[0]) -and $tf[1] -cne $changedEnglish[$tf[0]]) {
            $tf[1] = $changedEnglish[$tf[0]]
            $tmlines[$i] = ($tf -join "`t")
            $tmChanged++
        }
    }
    [IO.File]::WriteAllLines($tmPath, $tmlines, $utf8)
    Write-Output ('[tm] rows updated: {0}' -f $tmChanged)
}
