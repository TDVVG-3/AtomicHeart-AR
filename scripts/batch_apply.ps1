<#
.SYNOPSIS
  Batch-1 apply: fills the master Arabic column for batch-1 rows from the chunk Arabic
  files (localization/working/batch1/chunk_NN_ar.tsv), sets Status=DRAFT and a
  'batch1:chunkNN' note, and refreshes the union translation memory.

.DESCRIPTION
  Row identity is (scope, key) restricted to the batch-1 row set written by
  scripts/batch_plan.ps1 (localization/working/batch1/rows.tsv), so rows outside batch 1
  can never be touched. Rows that already carry Arabic (pilot / scene) are left alone.
  Every Arabic string lives in UTF-8 data files; this script is pure ASCII (KI-021).
  Idempotent: running twice produces the same master and the same TM.

  Reads : localization/working/batch1/unique.tsv      (id -> english)
          localization/working/batch1/rows.tsv        (scope, key, ...) batch row set
          localization/working/batch1/chunk_NN_ar.tsv (id -> arabic)
  Writes: localization/master/atomic-heart-ar.tsv (Arabic, Status, Notes)
          localization/working/tm.tsv (union TM, appended english -> arabic)
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string[]]$Chunks = @(),
    [switch]$All,
    [switch]$Apply,
    [switch]$Quiet
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$dir        = Join-Path $RepoRoot 'localization\working\batch1'
$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$tmPath     = Join-Path $RepoRoot 'localization\working\tm.tsv'
$utf8       = New-Object Text.UTF8Encoding($false)
# letters that make an Arabic cell "translated" (same class the validator uses)
$arabicLetterRx = '[\u0621-\u064A\u0660-\u0669\u066E-\u06D3\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF]'

if (-not $All -and $Chunks.Count -eq 0) { throw 'pass -Chunks 01,02 or -All' }
if ($Chunks.Count -eq 1 -and $Chunks[0] -match ',') { $Chunks = $Chunks[0] -split ',' }
$Chunks = @($Chunks | ForEach-Object { $_.Trim() } | Where-Object { $_ })
if ($All) {
    $Chunks = @()
    foreach ($f in (Get-ChildItem (Join-Path $dir 'chunk_*_ar.tsv') | Sort-Object Name)) {
        if ($f.Name -match '^chunk_(\d+)_ar\.tsv$') { $Chunks += $Matches[1] }
    }
    if ($Chunks.Count -eq 0) { throw 'no chunk_*_ar.tsv files found' }
}

# --- 1) unique.tsv: id -> english  (case-sensitive: CONSUMABLES and Consumables are different keys)
$uniqById = New-Object 'System.Collections.Generic.Dictionary[string,string]'
$uniqEnglish = New-Object System.Collections.Generic.HashSet[string]
$ulines = [IO.File]::ReadAllLines((Join-Path $dir 'unique.tsv'), [Text.Encoding]::UTF8)
$nDoneUnique = 0
for ($i = 1; $i -lt $ulines.Count; $i++) {
    if (-not $ulines[$i].Trim()) { continue }
    $f = $ulines[$i] -split "`t"
    if ($f.Count -lt 8) { throw ("unique.tsv row $($i+1): $($f.Count) fields") }
    $uniqById[$f[0]] = $f[1]
    [void]$uniqEnglish.Add($f[1])
    if ($f[7] -eq 'yes') { $nDoneUnique++ }
}

# --- 2) rows.tsv: batch row set (scope TAB key)
$rowSet = New-Object 'System.Collections.Generic.HashSet[string]'
$rl = [IO.File]::ReadAllLines((Join-Path $dir 'rows.tsv'), [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $rl.Count; $i++) {
    if (-not $rl[$i].Trim()) { continue }
    $f = $rl[$i] -split "`t"
    if ($f.Count -lt 2) { continue }
    [void]$rowSet.Add($f[1] + "`u{0000}" + $f[2])
}
if (-not $Quiet) { Write-Output ('[set] batch rows: {0} | unique ids: {1} (already translated unique: {2})' -f $rowSet.Count, $uniqById.Count, $nDoneUnique) }

# --- 3) chunk Arabic files -> id -> arabic, english -> (arabic, chunk)
$englishToArabic = New-Object 'System.Collections.Generic.Dictionary[string,string]'
$copyKeep = New-Object System.Collections.Generic.List[string]
$copyEnglish = New-Object 'System.Collections.Generic.HashSet[string]'
$perChunk = [ordered]@{}
foreach ($c in $Chunks) {
    $p = Join-Path $dir ('chunk_{0}_ar.tsv' -f $c)
    if (-not (Test-Path $p)) { throw ("missing chunk Arabic file: $p") }
    $al = [IO.File]::ReadAllLines($p, [Text.Encoding]::UTF8)
    $n = 0
    for ($i = 1; $i -lt $al.Count; $i++) {
        if (-not $al[$i].Trim()) { continue }
        $f = $al[$i] -split "`t"
        if ($f.Count -lt 2) { throw ("chunk_${c}_ar.tsv row $($i+1): $($f.Count) fields") }
        $id = $f[0].Trim()
        $arb = ($f | Select-Object -Skip 1) -join "`t"
        if (-not $uniqById.ContainsKey($id)) { throw ("chunk_${c}_ar.tsv: unknown id $id") }
        if (-not $arb.Trim()) { throw ("chunk_${c}_ar.tsv: empty Arabic for $id") }
        $eng = $uniqById[$id]
        # copy-class row: Arabic carries no Arabic letter (key letters, model codes,
        # endonyms, gibberish). The validator forbids Arabic == English, so such rows
        # stay UNTRANSLATED in the master; they are recorded as evidence instead.
        if (-not [regex]::IsMatch($arb, $arabicLetterRx)) {
            $copyKeep.Add($id + "`t" + $eng + "`t" + $arb + "`t" + $c)
            [void]$copyEnglish.Add($eng)
            $n++
            continue
        }
        if ($englishToArabic.ContainsKey($eng)) {
            if ($englishToArabic[$eng] -cne $arb) { throw ("conflicting Arabic for the same English string: " + $eng.Substring(0, [Math]::Min(50, $eng.Length))) }
        } else {
            $englishToArabic[$eng] = $arb
        }
        $n++
    }
    $perChunk[$c] = $n
    if (-not $Quiet) { Write-Output ('[chunk {0}] rows read: {1}' -f $c, $n) }
}
if (-not $Quiet) { Write-Output ('[map] distinct English -> Arabic: {0} | copy-keep rows: {1}' -f $englishToArabic.Count, $copyKeep.Count) }

# --- 3a2) manual overrides (localization/working/batch1/extra_ar.tsv), highest priority
$extraPath = Join-Path $dir 'extra_ar.tsv'
$extraCount = 0
if (Test-Path $extraPath) {
    $xl = [IO.File]::ReadAllLines($extraPath, [Text.Encoding]::UTF8)
    for ($i = 1; $i -lt $xl.Count; $i++) {
        if (-not $xl[$i].Trim()) { continue }
        $xf = $xl[$i] -split "`t"
        if ($xf.Count -lt 2) { continue }
        $xid = $xf[0].Trim(); $xar = ($xf | Select-Object -Skip 1) -join "`t"
        if (-not $uniqById.ContainsKey($xid)) { throw ("extra_ar.tsv: unknown id $xid") }
        if (-not [regex]::IsMatch($xar, $arabicLetterRx)) { throw ("extra_ar.tsv: no Arabic letter for $xid") }
        $xeng = $uniqById[$xid]
        $englishToArabic[$xeng] = $xar
        [void]$copyEnglish.Remove($xeng)
        $extraCount++
    }
    if (-not $Quiet) { Write-Output ('[extra] manual overrides: {0}' -f $extraCount) }
}

# --- 3b) TM fallback: strings already translated elsewhere (pilot / scene / earlier chunks)
#          are reused for other rows with the same English inside the batch set.
$tmFallback = 0
$tmLines0 = [IO.File]::ReadAllLines($tmPath, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $tmLines0.Count; $i++) {
    if (-not $tmLines0[$i].Trim()) { continue }
    $tf = $tmLines0[$i] -split "`t"
    if ($tf.Count -lt 2) { continue }
    if ($englishToArabic.ContainsKey($tf[0])) { continue }
    if ($copyEnglish.Contains($tf[0])) { continue }
    if (-not [regex]::IsMatch($tf[1], $arabicLetterRx)) { continue }
    $englishToArabic[$tf[0]] = $tf[1]
    $tmFallback++
}
if (-not $Quiet) { Write-Output ('[tm] fallback reuse (already translated elsewhere): {0} -> map now {1}' -f $tmFallback, $englishToArabic.Count) }

# --- 4) master walk
$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$out = New-Object System.Collections.Generic.List[string]
$out.Add($mlines[0])
$applied = 0; $alreadyAr = 0; $noTranslation = 0; $copyRows = 0; $notInSet = 0; $resetStale = 0
$perScope = @{}
$missingSet = New-Object 'System.Collections.Generic.HashSet[string]'
$appliedEnglish = New-Object 'System.Collections.Generic.HashSet[string]'
for ($i = 1; $i -lt $mlines.Count; $i++) {
    if (-not $mlines[$i].Trim()) { $out.Add($mlines[$i]); continue }
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { $out.Add($mlines[$i]); continue }
    $scope = 'other'
    if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $sid = $scope + "`u{0000}" + $f[4]
    if (-not $rowSet.Contains($sid)) { $notInSet++; $out.Add($mlines[$i]); continue }
    # repair: a value applied by an earlier run of this batch that carries no real
    # Arabic letter (for example a pure-format string where only the comma changed)
    if ($f[11] -eq 'batch1' -and -not [regex]::IsMatch($f[6], $arabicLetterRx)) {
        $f[6] = ''; $f[10] = 'UNTRANSLATED'; $f[11] = 'batch1:copy-keep'
        $resetStale++
        $out.Add(($f -join "`t"))
        continue
    }
    if ($f[6].Trim()) { $alreadyAr++; $out.Add($mlines[$i]); continue }
    $eng = $f[5]
    if ($copyEnglish.Contains($eng)) { $copyRows++; $out.Add($mlines[$i]); continue }
    if (-not $englishToArabic.ContainsKey($eng)) { $noTranslation++; [void]$missingSet.Add($eng); $out.Add($mlines[$i]); continue }
    $f[6] = $englishToArabic[$eng]
    $f[10] = 'DRAFT'
    $f[11] = 'batch1'
    $applied++
    [void]$appliedEnglish.Add($eng)
    if (-not $perScope.ContainsKey($scope)) { $perScope[$scope] = 0 }
    $perScope[$scope]++
    $out.Add(($f -join "`t"))
}
if (-not $Quiet) {
    Write-Output ('[walk] applied: {0} | already had Arabic: {1} | copy-keep (left UNTRANSLATED): {2} | reset stale non-Arabic values: {3} | no translation available: {4} | outside batch-1 set: {5}' -f $applied, $alreadyAr, $copyRows, $resetStale, $noTranslation, $notInSet)
    foreach ($k in ($perScope.Keys | Sort-Object)) { Write-Output ('   {0,-22} {1}' -f $k, $perScope[$k]) }
}
if ($copyKeep.Count -gt 0) {
    [IO.File]::WriteAllLines((Join-Path $dir 'copy_keep.tsv'), $copyKeep, $utf8)
    if (-not $Quiet) { Write-Output ('[copy] recorded {0} copy-keep rows: {1}' -f $copyKeep.Count, (Join-Path $dir 'copy_keep.tsv')) }
}
if ($missingSet.Count -gt 0) {
    $missOut = New-Object System.Collections.Generic.List[string]
    $q = 0
    foreach ($e in ($missingSet | Sort-Object)) {
        $inUnique = $uniqEnglish.Contains($e)
        $missOut.Add($e + "`t" + $(if ($inUnique) { 'in-unique-not-supplied' } else { 'NOT-IN-UNIQUE-SET' }))
        $q++
        if ($q -le 20) { Write-Output ('   MISSING ' + $(if ($inUnique) { '(unique, no chunk output) ' } else { '(not in unique set) ' }) + $e.Substring(0, [Math]::Min(70, $e.Length))) }
    }
    [IO.File]::WriteAllLines((Join-Path $dir 'missing_english.tsv'), $missOut, $utf8)
    Write-Output ('[missing] {0} distinct English strings in the batch set have no Arabic yet: {1}' -f $missingSet.Count, (Join-Path $dir 'missing_english.tsv'))
}
if ($Apply) {
    [IO.File]::WriteAllLines($masterPath, $out, $utf8)
    Write-Output ('[master] written: {0}' -f $masterPath)
} else {
    Write-Output '[dry-run] master not written (pass -Apply)'
}

# --- 5) union TM
$tmlines = [IO.File]::ReadAllLines($tmPath, [Text.Encoding]::UTF8)
$tmOut = New-Object System.Collections.Generic.List[string]
$tmOut.Add($tmlines[0])
$existing = New-Object 'System.Collections.Generic.HashSet[string]'
for ($i = 1; $i -lt $tmlines.Count; $i++) {
    if (-not $tmlines[$i].Trim()) { continue }
    $tf = $tmlines[$i] -split "`t"
    if ($tf.Count -ge 1) { [void]$existing.Add($tf[0]) }
    $tmOut.Add($tmlines[$i])
}
$tmAdded = 0
foreach ($eng in ($appliedEnglish | Sort-Object)) {
    if ($existing.Contains($eng)) { continue }
    $tmOut.Add($eng + "`t" + $englishToArabic[$eng] + "`t" + 'batch1')
    [void]$existing.Add($eng)
    $tmAdded++
}
if ($Apply) {
    [IO.File]::WriteAllLines($tmPath, $tmOut, $utf8)
    Write-Output ('[tm] entries before: {0} | appended: {1} | entries now: {2}' -f ($tmlines.Count - 1), $tmAdded, ($tmOut.Count - 1))
} else {
    Write-Output ('[dry-run] tm would append: {0}' -f $tmAdded)
}

# --- 6) totals
$written = if ($Apply) { [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8) } else { $mlines }
$total = 0; $withAr = 0; $draft = 0
for ($i = 1; $i -lt $written.Count; $i++) {
    $f = $written[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $total++
    if ($f[6].Trim()) { $withAr++; if ($f[10] -eq 'DRAFT') { $draft++ } }
}
$pct = ('{0:N2}' -f (100.0 * $withAr / $total))
Write-Output ''
Write-Output ('[total] coverage: {0} of {1} ({2}%) | DRAFT: {3}' -f $withAr, $total, $pct, $draft)
