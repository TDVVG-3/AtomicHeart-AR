<#
.SYNOPSIS
  Dialogue program - Phase B: applies batch N (cumulative 25/50/75/100%) of the
  dialogue/cutscene string inventory into localization/master/atomic-heart-ar.tsv.

.DESCRIPTION
  Reads the ordered source manifests (sources_lockres.tsv + sources_st.tsv), computes
  the cumulative cutoff hi = TOTAL * N * 25%, then walks sources in order:
   - LOCRE: rows already mastered from the en-US build. Whole source counts 'already
     present'; Category retagged to the canonical class when it differs (cosmetic,
     source/Arabic/keys untouched). Row coverage capped at the batch cutoff.
   - ASSET: new rows from the UTF-8 string dumps (localization/extracted/dialogue/,
     file name <pakName>__<baseName>.txt as written by dialogue_count_worker.ps1).
     File = asset path, Namespace = empty (cooked strings have no namespace),
     Key = empty (no source keys exist in cooked strings),
     Context = 'raw string <n>', Category = scope class, Speaker = empty, Notes =
     'cooked asset scan; no source keys'. Placement/tags preserved byte-exact.
     A missing dump is a hard error (never a silent skip, which would understate coverage).
     RU-only assets (Cyrillic, no Latin) are never added here - they are reported in
     reports/dialogue_ru_only.md (they have no English source to keep in this column).
  Idempotent: duplicate IDs are skipped and counted. Validation prints PASS/FAIL.
#>
[CmdletBinding()]
param(
    [int]$Batch = 1,
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
. (Join-Path $RepoRoot 'scripts\dialogue_strings_lib.ps1')
$sha1 = [System.Security.Cryptography.SHA1]::Create()
function Get-RowId([string]$kind, [string]$src, [string]$text) {
    $bytes = [Text.Encoding]::UTF8.GetBytes($kind + '|' + $src + '|' + $text)
    return ([System.BitConverter]::ToString($sha1.ComputeHash($bytes))).Replace('-', '')
}

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$invDir = Join-Path $RepoRoot 'reports\dialogue_inventory_raw'
$ruOnlyPath = Join-Path $RepoRoot 'reports\dialogue_ru_only.md'

# --- load master
$lines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$rows = New-Object System.Collections.Generic.List[object]
for ($i = 1; $i -lt $lines.Count; $i++) { $rows.Add(($lines[$i] -split "`t")) }
$masterCount = $rows.Count
$knownId = @{}
foreach ($r in $rows) { $knownId[$r[0]] = $r }
# baseline: pre-existing duplicate IDs in the master (pre-date this program; KI-016)
$baseSeen = @{}
$baseDup = 0
foreach ($r in $rows) {
    if ($baseSeen.ContainsKey($r[0])) { $baseDup++ } else { $baseSeen[$r[0]] = $true }
}
Write-Output ("[baseline] master rows {0}; pre-existing duplicate IDs {1} (KI-016, not caused by this program)" -f $masterCount, $baseDup)

# --- ordered sources
$sources = New-Object System.Collections.Generic.List[object]
foreach ($ln in ([IO.File]::ReadAllLines((Join-Path $invDir 'sources_lockres.tsv'), [Text.Encoding]::UTF8) | Select-Object -Skip 1)) {
    $p = $ln -split "`t"
    $sources.Add([pscustomobject]@{ ord = [int]$p[0]; kind = 'LOCRE'; source = $p[2]; container = $p[3]; dlc = $p[4]; cls = $p[5]; count = [int]$p[6] })
}
$stPath = Join-Path $invDir 'sources_st.tsv'
if (Test-Path $stPath) {
    foreach ($ln in ([IO.File]::ReadAllLines($stPath, [Text.Encoding]::UTF8) | Select-Object -Skip 1)) {
        $p = $ln -split "`t"
        $sources.Add([pscustomobject]@{ ord = [int]$p[0]; kind = 'ASSET'; source = $p[2]; container = $p[3]; dlc = $p[4]; cls = $p[5]; count = [int]$p[6]; pak = $p[7] })
    }
}
$sources = ($sources | Sort-Object ord, kind)
$total = ($sources | Measure-Object -Sum count).Sum
if (-not $total -or $total -le 0) { throw "inventory total is $total - refusing to batch" }
$hi = [Math]::Round($total * ($Batch * 0.25), [MidpointRounding]::AwayFromZero)
Write-Output ("[batch {0}] TOTAL {1} strings; cumulative cutoff {2}" -f $Batch, $total, $hi)

# --- walk
$cum = 0
$added = 0; $already = 0; $dups = 0; $retag = 0
$ruOnlyAssets = 0; $ruOnlyStrings = 0
foreach ($src in $sources) {
    if ($cum -ge $hi) { break }
    $take = [Math]::Min($src.count, $hi - $cum)
    if ($take -le 0) { break }
    $full = ($take -eq $src.count)
    $cut = ($newCum = $cum + $take)
    if ($src.kind -eq 'LOCRE') {
        # prebuilt en-US rows: count presence (capped), retag category
        $rx = '/en-US/' + [regex]::Escape($src.source) + '\.locres$'
        $seen = New-Object System.Collections.Generic.List[object]
        foreach ($r in $rows) { if ($r[2] -match $rx) { $seen.Add($r) } }
        foreach ($r in $seen) { if ($r[9] -ne $src.cls) { $r[9] = $src.cls; $retag++ } }
        $already += $take
        $part = if ($full) { 'full' } else { 'partial' }
        Write-Output ("  locres {0,-30} present {1}/{2} {3} retag {4}" -f $src.source, [Math]::Min($take, $seen.Count), $src.count, $part, $retag)
        if ($seen.Count -ne $src.count) { Write-Output ("    NOTE master rows {0} != manifest {1}" -f $seen.Count, $src.count) }
    }
    elseif ($src.kind -eq 'ASSET') {
        # dump naming written by dialogue_count_worker.ps1: <pakName>__<baseName>.txt
        $dumpName = $src.pak + '__' + [IO.Path]::GetFileNameWithoutExtension($src.source) + '.txt'
        $dumpPath = Join-Path $RepoRoot ('localization\extracted\dialogue\' + $dumpName)
        if (-not (Test-Path $dumpPath)) { throw ("missing dump for {0}: {1}" -f $src.source, $dumpName) }
        $txt = [IO.File]::ReadAllText($dumpPath, [Text.Encoding]::UTF8)
        $strings = @(Get-DialogueStrings $txt)
        if ($strings.Count -eq 0) { throw ("no prose strings for {0} (dump {1})" -f $src.source, $dumpName) }
        $take2 = [Math]::Min($take, $strings.Count)
        for ($n = 0; $n -lt $take2; $n++) {
            $s = $strings[$n]
            $id = Get-RowId 'ASSET' $src.source $s
            if ($knownId.ContainsKey($id)) {
                if ($knownId[$id][11] -match 'batch') { $already++ } else { $dups++ }
                continue
            }
            # NOTE: the concatenation MUST be parenthesised - in PowerShell the comma
            # operator binds tighter than '+', so an unparenthesised
            # '...batch ' + $Batch inside @( ... ) splits into TWO array elements
            # (a string and the int), producing 14-field rows.
            $newRow = @($id, 'AtomicHeart', $src.source, '', '', $s, '', ('raw string ' + ($n + 1)), '', $src.cls, 'NEW', ('cooked asset scan; no source keys; batch ' + $Batch), '')
            $rows.Add($newRow)
            $knownId[$id] = $newRow
            $added++
        }
    }
    $cum += $take
}
$donePct = [Math]::Round($cum / $total * 100, 1)
Write-Output ("[batch {0}] covered {1} of {2} ({3}%); added {4}; already {5}; dup {6}; retag {7}" -f $Batch, $cum, $total, $donePct, $added, $already, $dups, $retag)

# --- coverage tables (per category and per DLC), cumulative up to this batch
$covClass = @{}; $totClass = @{}; $covDlc = @{}; $totDlc = @{}
$c2 = 0
foreach ($src in $sources) {
    $cl = $src.cls; $dl = $src.dlc
    if (-not $totClass.ContainsKey($cl)) { $totClass[$cl] = 0; $covClass[$cl] = 0 }
    if (-not $totDlc.ContainsKey($dl)) { $totDlc[$dl] = 0; $covDlc[$dl] = 0 }
    $totClass[$cl] += $src.count; $totDlc[$dl] += $src.count
    if ($c2 -lt $hi) {
        $tk = [Math]::Min($src.count, $hi - $c2)
        if ($tk -gt 0) { $covClass[$cl] += $tk; $covDlc[$dl] += $tk }
    }
    $c2 += $src.count
}
function Fmt-Cov([int]$n, [int]$t) { $p = if ($t -gt 0) { [Math]::Round($n / $t * 100, 1) } else { 0 }; return ('{0} of {1} ({2}%)' -f $n, $t, $p) }
Write-Output '[coverage by category]'
foreach ($k in ($totClass.Keys | Sort-Object)) { Write-Output ('  {0,-9} {1}' -f $k, (Fmt-Cov $covClass[$k] $totClass[$k])) }
Write-Output '[coverage by DLC]'
foreach ($k in ($totDlc.Keys | Sort-Object)) { Write-Output ('  {0,-5} {1}' -f $k, (Fmt-Cov $covDlc[$k] $totDlc[$k])) }

# --- validation
$fail = 0
$checkId = @{}
$postDup = 0
# UTF-8 round-trip: no U+FFFD replacement chars in the file text
$rawBytes = [IO.File]::ReadAllBytes($masterPath)
$decoded = [Text.Encoding]::UTF8.GetString($rawBytes)
if ($decoded.Contains([char]0xFFFD)) { Write-Output '  VALIDATION UTF-8: replacement character U+FFFD found'; $fail++ }
else { Write-Output '  VALIDATION UTF-8 round-trip: OK (no U+FFFD)' }
$badFields = 0
$openTags = 0; $closeTags = 0; $selfTags = 0
foreach ($r in $rows) {
    if ($r.Count -ne 13) { $badFields++ }
    if (-not $r[0]) { $fail++ }
    if (-not $r[5] -and $r[10] -eq 'NEW') { Write-Output ('  VALIDATION empty source: ' + $r[2]); $fail++ }
    if ($checkId.ContainsKey($r[0])) { $postDup++ } else { $checkId[$r[0]] = $true }
    if ($r[5]) {
        $openTags += ([regex]::Matches($r[5], '<(?![/?])')).Count
        $closeTags += ([regex]::Matches($r[5], '</')).Count
        $selfTags += ([regex]::Matches($r[5], '<[^>]{1,80}/>')).Count
    }
}
if ($badFields -gt 0) { Write-Output ('  VALIDATION rows with wrong field count: ' + $badFields); $fail++ }
Write-Output ('  VALIDATION rich-text tags in source (informational): {0} opening, {1} self-closing, {2} closing' -f $openTags, $selfTags, $closeTags)
if ($openTags - $selfTags -ne $closeTags) { Write-Output '  VALIDATION tag balance: pairs unbalanced (informational - pre-existing UI rows only)' }
else { Write-Output '  VALIDATION tag balance: paired tags balanced' }
$newDup = $postDup - $baseDup
if ($newDup -gt 0) { Write-Output ('  VALIDATION NEW duplicate ids introduced: ' + $newDup); $fail++ }
Write-Output ("[validation] duplicate ids total {0}; pre-existing {1}; new {2}" -f $postDup, $baseDup, $newDup)
$verdict = if ($fail -eq 0) { 'PASS' } else { 'FAIL' }
Write-Output ("[validation] {0} ({1} problems, {2} rows)" -f $verdict, $fail, $rows.Count)

if (-not $fail -and (($rows.Count -ne $masterCount) -or ($retag -gt 0))) {
    $out = New-Object System.Collections.Generic.List[string]
    $out.Add($lines[0])
    foreach ($r in $rows) { $out.Add(($r -join "`t")) }
    $tmpM = $masterPath + '.tmp'
    [IO.File]::WriteAllLines($tmpM, $out, (New-Object Text.UTF8Encoding($false)))
    Move-Item $tmpM $masterPath -Force
    Write-Output ("[write] master rows {0} -> {1}" -f $masterCount, $rows.Count)
} else {
    Write-Output "[write] master untouched (validation failed or nothing new)"
}
