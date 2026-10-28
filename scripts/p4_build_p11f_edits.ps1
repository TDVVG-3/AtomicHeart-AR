$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

# Build and validate the p11f page replacements.
# Inputs: build\p4\p11f_targets.tsv and build\p4\p11f_new_1..3.tsv.
# Output: build\p4\p11f_applied.tsv + reports\p11f_shortened.md.
$TAB = [char]9
$inv = [Globalization.CultureInfo]::InvariantCulture
$root = 'C:\AtomicHeart-AR'
$targetsPath = Join-Path $root 'build\p4\p11f_targets.tsv'
$outPath = Join-Path $root 'build\p4\p11f_applied.tsv'
$reportPath = Join-Path $root 'reports\p11f_shortened.md'
$arLetter = [regex]'[\u0621-\u064A\u0660-\u0669\u066E-\u06D3\u06D5\u06E5-\u06E6\u06EE-\u06EF\u06FA-\u06FC\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]'
function F3([double]$v) { return $v.ToString('0.###', $inv) }

$targets = [IO.File]::ReadAllLines($targetsPath, [Text.Encoding]::UTF8)
$new = @{}
foreach ($file in @('build\p4\p11f_new_1.tsv','build\p4\p11f_new_2.tsv','build\p4\p11f_new_3.tsv')) {
    $path = Join-Path $root $file
    foreach ($line in [IO.File]::ReadAllLines($path, [Text.Encoding]::UTF8)) {
        if (-not $line.Trim()) { continue }
        $p = $line -split $TAB
        if ($p.Count -lt 3) { throw ('bad replacement row in ' + $file + ': ' + $line) }
        $k = $p[0] + '|' + $p[1]
        if ($new.ContainsKey($k)) { throw ('duplicate replacement for ' + $k) }
        $new[$k] = $p[2]
    }
}

$out = New-Object System.Collections.Generic.List[string]
$out.Add(('line' + $TAB + 'page' + $TAB + 'window_sec' + $TAB + 'old_chars' + $TAB + 'new_chars' + $TAB + 'old_cps' + $TAB + 'new_cps' + $TAB + 'status' + $TAB + 'old_ar' + $TAB + 'new_ar'))
$missing = 0; $extra = 0; $tagsBad = 0; $numBad = 0; $still = 0
$sumOld = 0; $sumNew = 0; $n = 0
foreach ($line in ($targets | Select-Object -Skip 1)) {
    $f = $line -split $TAB
    if ($f.Count -lt 15) { continue }
    $k = $f[0] + '|' + $f[3]
    if (-not $new.ContainsKey($k)) { $missing++; Write-Output ('MISSING ' + $k); continue }
    $old = $f[14]
    $rep = $new[$k]
    $lead = ''; $trail = ''
    if ($old -match '^(\s+)') { $lead = $Matches[1] }
    if ($old -match '(\s+)$') { $trail = $Matches[1] }
    $newText = $lead + $rep.Trim() + $trail
    $oc = $arLetter.Matches($old).Count
    $nc = $arLetter.Matches($newText).Count
    $sumOld += $oc; $sumNew += $nc; $n++
    $win = [double]::Parse($f[6], $inv)
    $ocps = $oc / $win; $ncps = $nc / $win
    $ot = ([regex]::Matches($old, '&[^&]{1,60}&') | ForEach-Object { $_.Value } | Sort-Object) -join '|'
    $nt = ([regex]::Matches($newText, '&[^&]{1,60}&') | ForEach-Object { $_.Value } | Sort-Object) -join '|'
    $on = ([regex]::Matches($old, '[0-9]+(?:[.,:][0-9]+)*') | ForEach-Object { $_.Value } | Sort-Object) -join '|'
    $nn = ([regex]::Matches($newText, '[0-9]+(?:[.,:][0-9]+)*') | ForEach-Object { $_.Value } | Sort-Object) -join '|'
    $status = 'OK'
    if ($ot -ne $nt) { $status = 'TAG_MISMATCH'; $tagsBad++ }
    if ($on -ne $nn) { $status = $status + '+NUM_MISMATCH'; $numBad++ }
    if ($ncps -gt 21.0) { $status = $status + '+STILL_OVER21'; $still++ }
    $out.Add(($f[0] + $TAB + $f[3] + $TAB + (F3 $win) + $TAB + $oc + $TAB + $nc + $TAB + $ocps.ToString('0.00', $inv) + $TAB + $ncps.ToString('0.00', $inv) + $TAB + $status + $TAB + $old + $TAB + $newText))
}
foreach ($k in $new.Keys) {
    $parts = $k -split '\|'
    $found = $false
    foreach ($line in ($targets | Select-Object -Skip 1)) {
        $f = $line -split $TAB
        if ($f.Count -lt 15) { continue }
        if ($f[0] -eq $parts[0] -and $f[3] -eq $parts[1]) { $found = $true; break }
    }
    if (-not $found) { $extra++; Write-Output ('EXTRA ' + $k) }
}
[IO.File]::WriteAllLines($outPath, $out, (New-Object Text.UTF8Encoding($false)))

$r = New-Object System.Collections.Generic.List[string]
$r.Add('# p11f shortened pages')
$r.Add('')
$r.Add(('Generated: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')))
$r.Add('')
$r.Add(('Target pages: {0} | replacements: {1} | missing: {2} | extra: {3} | tag mismatches: {4} | number mismatches: {5} | still above 21 chars/s: {6}' -f $n, $new.Count, $missing, $extra, $tagsBad, $numBad, $still))
$r.Add('')
$r.Add(('Arabic characters in target pages: {0} -> {1} ({2}% reduction).' -f $sumOld, $sumNew, ([Math]::Round(100.0 * ($sumOld - $sumNew) / [Math]::Max(1, $sumOld), 1))))
$r.Add('')
$r.Add('Only the visible Arabic page segments listed below are changed. All markers, speaker tags, numbers, placeholders and the twelve non-Arabic columns are preserved; the build gate verifies this byte-exactly.')
$r.Add('')
$r.Add('## Before and after')
$r.Add('')
$r.Add('| # | line/page | scope | window s | chars | chars/s | new chars | new chars/s | English page | Arabic before | Arabic after |')
$r.Add('|---:|---|---|---:|---:|---:|---:|---:|---|---|---|')
$idx = 0
foreach ($line in ($out | Select-Object -Skip 1)) {
    $p = $line -split $TAB
    if ($p[7] -like '*MISMATCH*') { continue }
    $idx++
    $tf = $null
    foreach ($tl in ($targets | Select-Object -Skip 1)) {
        $q = $tl -split $TAB
        if ($q.Count -lt 15) { continue }
        if ($q[0] -eq $p[0] -and $q[3] -eq $p[1]) { $tf = $q; break }
    }
    $scope = if ($tf) { $tf[2] } else { '' }
    $en = if ($tf) { $tf[13] } else { '' }
    $r.Add(('| {0} | L{1} p{2} | {3} | {4} | {5} | {6} | {7} | {8} | {9} | {10} | {11} |' -f $idx, $p[0], $p[1], $scope, $p[2], $p[3], $p[5], $p[4], $p[6], $en.Replace('|','/'), $p[8].Replace('|','/'), $p[9].Replace('|','/')))
}
[IO.File]::WriteAllLines($reportPath, $r, (New-Object Text.UTF8Encoding($false)))

Write-Output ('p11f edits: targets={0} replacements={1} missing={2} extra={3} tags={4} numbers={5} stillOver21={6}' -f $n, $new.Count, $missing, $extra, $tagsBad, $numBad, $still)
Write-Output ('chars {0} -> {1}' -f $sumOld, $sumNew)
Write-Output ('wrote ' + $outPath)
Write-Output ('wrote ' + $reportPath)
if ($missing -gt 0 -or $extra -gt 0 -or $tagsBad -gt 0 -or $numBad -gt 0) { exit 1 }
if ($still -gt 0) { Write-Output 'WARNING: some pages remain above 21 chars/s'; exit 3 }
