<#
.SYNOPSIS
  Applies the curated speaker-name dictionary (cycle 012, KI-027) to every master
  row whose English cell is byte-identical to a dictionary entry.

.DESCRIPTION
  Input: localization/working/labels/speaker_names.tsv
      header: english<TAB>arabic<TAB>note
      An entry with EMPTY Arabic is a documented copy-class keep (e.g. P-3); it is
      skipped and counted, never applied.

  Rules:
    - Exact, case-sensitive match on the English cell (ordinal Dictionary, KI-023).
    - Only rows with an EMPTY Arabic cell are filled. An existing non-empty Arabic
      that differs from the dictionary is reported as a CONFLICT and left untouched
      (consistency rule: one Arabic per speaker name).
    - Duplicate English with two different Arabics inside the dictionary is a HARD
      ERROR (aborts before anything is written).
    - Applied rows: Arabic = dictionary value, Status = DRAFT, Notes = label:<n>.
    - The union TM gets english -> arabic for every applied pair.

  ASCII-only script (KI-021): all Arabic lives in the UTF-8 data file.
  Idempotent: a second run reports everything as already identical.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$Names = 'localization\working\labels\speaker_names.tsv',
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$tmPath     = Join-Path $RepoRoot 'localization\working\tm.tsv'
$namesPath  = Join-Path $RepoRoot $Names
$repPath    = Join-Path $RepoRoot 'localization\working\labels\label_apply_report.tsv'
$utf8       = New-Object Text.UTF8Encoding($false)

# ---------- 1) dictionary ----------
$ar    = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::Ordinal)
$note  = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::Ordinal)
$keep  = New-Object System.Collections.Generic.List[string]
$nl = [IO.File]::ReadAllLines($namesPath, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $nl.Count; $i++) {
    if (-not $nl[$i].Trim()) { continue }
    $f = $nl[$i] -split "`t"
    if ($f.Count -lt 2) { throw ("names line $($i+1): fewer than 2 fields") }
    $en = $f[0]
    $val = ''
    if ($f.Count -ge 2) { $val = $f[1] }
    $nt = ''
    if ($f.Count -ge 3) { $nt = $f[2] }
    if (-not $val.Trim()) { $keep.Add($en); continue }
    if ($ar.ContainsKey($en)) {
        if ($ar[$en] -cne $val) { throw ("names: conflicting Arabics for [" + $en + "]") }
        continue
    }
    $ar[$en] = $val
    $note[$en] = $nt
}
Write-Output ('[names] translatable entries: {0} | copy-class keep (empty Arabic): {1}' -f $ar.Count, $keep.Count)
if ($keep.Count -gt 0) { Write-Output ('[names] keep: ' + ($keep -join ', ')) }

# ---------- 2) master walk ----------
$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$out = New-Object System.Collections.Generic.List[string]
$out.Add($mlines[0])
$filled  = New-Object 'System.Collections.Generic.Dictionary[string,int]' ([StringComparer]::Ordinal)
$same    = New-Object 'System.Collections.Generic.Dictionary[string,int]' ([StringComparer]::Ordinal)
$scopesSeen = New-Object 'System.Collections.Generic.Dictionary[string,object]' ([StringComparer]::Ordinal)
$conflict = New-Object System.Collections.Generic.List[string]
$tmPairs  = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::Ordinal)

for ($i = 1; $i -lt $mlines.Count; $i++) {
    if (-not $mlines[$i].Trim()) { $out.Add($mlines[$i]); continue }
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { $out.Add($mlines[$i]); continue }
    $en = $f[5]
    if (-not $ar.ContainsKey($en)) { $out.Add($mlines[$i]); continue }
    $scope = 'other'
    if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $cur = $f[6]
    $want = $ar[$en]
    if ($cur.Trim()) {
        if ($cur -ceq $want) {
            if (-not $same.ContainsKey($en)) { $same[$en] = 0 }
            $same[$en]++
        } else {
            $conflict.Add(('EN=[{0}] scope={1} master=[{2}] dict=[{3}]' -f $en, $scope, $cur, $want))
        }
        $out.Add($mlines[$i])
        continue
    }
    $f[6] = $want
    $f[10] = 'DRAFT'
    $f[11] = 'label:' + $note[$en]
    $out.Add(($f -join "`t"))
    if (-not $filled.ContainsKey($en)) { $filled[$en] = 0 }
    $filled[$en]++
    if ($scopesSeen.ContainsKey($en)) { $scopesSeen[$en] = $scopesSeen[$en] + ',' + $scope } else { $scopesSeen[$en] = $scope }
    $tmPairs[$en] = $want
}

$totFilled = 0; foreach ($k in $filled.Keys) { $totFilled += $filled[$k] }
Write-Output ('[apply] rows filled: {0} | names used: {1} | already-identical rows: {2}' -f $totFilled, $filled.Count, (($same.Values | Measure-Object -Sum).Sum))
if ($conflict.Count -gt 0) {
    Write-Output ('CONFLICTS ({0}) - left untouched:' -f $conflict.Count)
    foreach ($x in $conflict) { Write-Output ('   ' + $x) }
}
$neverSeen = New-Object System.Collections.Generic.List[string]
foreach ($k in $ar.Keys) { if (-not $filled.ContainsKey($k) -and -not $same.ContainsKey($k)) { $neverSeen.Add($k) } }
if ($neverSeen.Count -gt 0) { Write-Output ('[apply] dictionary entries with no matching master row ({0}): {1}' -f $neverSeen.Count, ($neverSeen -join ', ')) }

# ---------- 3) report file ----------
$rl = New-Object System.Collections.Generic.List[string]
$rl.Add("english`trowsFilled`talreadySame`tscopes`tarabic")
foreach ($k in ($filled.Keys | Sort-Object)) {
    $s = ''
    if ($scopesSeen.ContainsKey($k)) { $s = $scopesSeen[$k] }
    $rl.Add(($k + "`t" + $filled[$k] + "`t" + '0' + "`t" + $s + "`t" + $ar[$k]))
}
foreach ($k in ($same.Keys | Sort-Object)) {
    if ($filled.ContainsKey($k)) { continue }
    $rl.Add(($k + "`t0`t" + $same[$k] + "`t" + '' + "`t" + $ar[$k]))
}
[IO.File]::WriteAllLines($repPath, $rl, $utf8)
Write-Output ('[report] written: ' + $repPath)

if ($DryRun) { Write-Output '[dryrun] master/TM not written'; exit 0 }

[IO.File]::WriteAllLines($masterPath, $out, $utf8)
Write-Output ('[master] written: {0}' -f $masterPath)

# ---------- 4) union TM ----------
$tmlines = [IO.File]::ReadAllLines($tmPath, [Text.Encoding]::UTF8)
$tmOut = New-Object System.Collections.Generic.List[string]
$tmOut.Add($tmlines[0])
$have = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::Ordinal)
for ($i = 1; $i -lt $tmlines.Count; $i++) {
    if (-not $tmlines[$i].Trim()) { continue }
    $tf = $tmlines[$i] -split "`t"
    if ($tf.Count -ge 2) { $have[$tf[0]] = $tf[1] }
    $tmOut.Add($tmlines[$i])
}
$tmAdded = 0; $tmSame = 0; $tmConf = 0
foreach ($e in $tmPairs.Keys) {
    if ($have.ContainsKey($e)) {
        if ($have[$e] -ceq $tmPairs[$e]) { $tmSame++ } else { $tmConf++; Write-Output ('   TM CONFLICT: ' + $e) }
    } else {
        $tmOut.Add($e + "`t" + $tmPairs[$e] + "`t" + 'label-012')
        [void]$have.Add($e, $tmPairs[$e])
        $tmAdded++
    }
}
[IO.File]::WriteAllLines($tmPath, $tmOut, $utf8)
Write-Output ('[tm] entries {0} -> {1} | appended {2} | already identical {3} | conflicts {4}' -f ($tmlines.Count - 1), ($tmOut.Count - 1), $tmAdded, $tmSame, $tmConf)

# ---------- 5) totals ----------
$written = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$total = 0; $withAr = 0
for ($i = 1; $i -lt $written.Count; $i++) {
    $f = $written[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $total++
    if ($f[6].Trim()) { $withAr++ }
}
Write-Output ('[coverage] rows with Arabic: {0} of {1} ({2}%)' -f $withAr, $total, [Math]::Round(100.0 * $withAr / $total, 2))
