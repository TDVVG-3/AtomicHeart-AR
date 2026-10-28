$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$TAB = [char]9
$repo = 'C:\AtomicHeart-AR'
$occPath = Join-Path $repo 'build\p4\item_name_occurrences.tsv'
$labelPath = Join-Path $repo 'localization\working\p3_label.tsv'
$outPath = Join-Path $repo 'localization\working\tm_fixups_p12.tsv'
$allPath = Join-Path $repo 'localization\working\tm_fixups.tsv'
$repPath = Join-Path $repo 'reports\p12_fixups.md'
$utf8 = New-Object Text.UTF8Encoding($false)

# --- label rule (P-3 speaker label -> الرائد), read from a UTF-8 data file
$labelReplace = ''
$lb = [IO.File]::ReadAllLines($labelPath, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $lb.Count; $i++) {
    $f = $lb[$i] -split $TAB
    if ($f.Count -ge 2 -and $f[0].Trim() -ceq 'P-3') { $labelReplace = $f[1]; break }
}
if (-not $labelReplace) { throw 'p3_label.tsv has no P-3 row' }

$occ = [IO.File]::ReadAllLines($occPath, [Text.Encoding]::UTF8)
$seen = @{}
$cellRules = New-Object System.Collections.Generic.List[object]
$conflicts = New-Object System.Collections.Generic.List[string]
$dupes = 0
for ($i = 1; $i -lt $occ.Count; $i++) {
    if (-not $occ[$i].Trim()) { continue }
    $f = $occ[$i] -split $TAB
    if ($f.Count -lt 10) { continue }
    $scope = $f[1]; $key = $f[2]; $find = $f[7]; $replace = $f[6]
    if (-not $find -or -not $replace) { continue }
    $value = $scope + '|' + $key
    $sig = $find + '|' + $value
    if ($seen.ContainsKey($sig)) {
        $old = $seen[$sig]
        if ($old -cne $replace) {
            $conflicts.Add(('L{0} | {1} | {2} | {3} -> {4} conflicts with {5}' -f $f[0], $scope, $key, $find, $replace, $old))
        } else { $dupes++ }
        continue
    }
    $seen[$sig] = $replace
    $cellRules.Add([pscustomobject]@{ find = $find; replace = $replace; scope = $scope; key = $key; value = $value })
}

# Longest names first inside a cell, so a shorter substring cannot pre-empt a longer name.
$sorted = @($cellRules | Sort-Object value, @{ Expression = { $_.find.Length }; Descending = $true }, find)

$out = New-Object System.Collections.Generic.List[string]
$out.Add(('find' + $TAB + 'replace' + $TAB + 'note' + $TAB + 'selector' + $TAB + 'value'))
$out.Add(('P-3' + $TAB + $labelReplace + $TAB + 'speaker label P-3 -> Major [label]' + $TAB + 'label' + $TAB + 'P-3'))
foreach ($r in $sorted) {
    $out.Add(($r.find + $TAB + $r.replace + $TAB + 'in-sentence item name [cell]' + $TAB + 'cell' + $TAB + $r.value))
}
[IO.File]::WriteAllLines($outPath, $out, $utf8)

# --- append to the shared fixups file, without duplicating rules already present
$all = [IO.File]::ReadAllLines($allPath, [Text.Encoding]::UTF8)
$existing = @{}
for ($i = 1; $i -lt $all.Count; $i++) {
    if (-not $all[$i].Trim()) { continue }
    $f = $all[$i] -split $TAB
    if ($f.Count -ge 5) { $existing[$f[0] + '|' + $f[3] + '|' + $f[4]] = 1 }
    elseif ($f.Count -ge 3) { $existing[$f[0] + '||'] = 1 }
}
$append = New-Object System.Collections.Generic.List[string]
$added = 0
for ($i = 1; $i -lt $out.Count; $i++) {
    $f = $out[$i] -split $TAB
    $sig = $f[0] + '|' + $f[3] + '|' + $f[4]
    if ($existing.ContainsKey($sig)) { continue }
    $existing[$sig] = 1
    $append.Add($out[$i])
    $added++
}
if ($all[0] -ne ('find' + $TAB + 'replace' + $TAB + 'note' + $TAB + 'selector' + $TAB + 'value')) {
    $all[0] = ('find' + $TAB + 'replace' + $TAB + 'note' + $TAB + 'selector' + $TAB + 'value')
}
$allOut = New-Object System.Collections.Generic.List[string]
foreach ($l in $all) { $allOut.Add($l) }
foreach ($l in $append) { $allOut.Add($l) }
[IO.File]::WriteAllLines($allPath, $allOut, $utf8)

$r = New-Object System.Collections.Generic.List[string]
$r.Add('# p12 text fixups')
$r.Add('')
$r.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')))
$r.Add('')
$r.Add('| item | count |')
$r.Add('| --- | ---: |')
$r.Add(('| occurrence rows read | {0} |' -f [Math]::Max(0, $occ.Count - 1)))
$r.Add(('| unique cell rules | {0} |' -f $sorted.Count))
$r.Add(('| duplicate identical candidates folded | {0} |' -f $dupes))
$r.Add(('| conflicting candidates skipped | {0} |' -f $conflicts.Count))
$r.Add(('| label rules | 1 |'))
$r.Add(('| appended to tm_fixups.tsv | {0} |' -f $added))
$r.Add('')
$r.Add('Cell rules replace a weapon/item name inside one master cell only. The English name is used as the replacement; all Arabic prose around it stays. The P-3 label rule fills an empty Arabic cell whose English source is exactly `P-3`.')
$r.Add('')
if ($conflicts.Count -gt 0) {
    $r.Add('## Conflicts')
    $r.Add('')
    foreach ($c in $conflicts) { $r.Add('- ' + $c) }
    $r.Add('')
}
$r.Add('## First 40 rules')
$r.Add('')
$r.Add('| # | find | replace | scope | key |')
$r.Add('|---:|---|---|---|---|')
$idx = 0
foreach ($x in $sorted) {
    $idx++
    if ($idx -gt 40) { break }
    $r.Add(('| {0} | {1} | {2} | {3} | `{4}` |' -f $idx, $x.find.Replace('|','/'), $x.replace.Replace('|','/'), $x.scope, $x.key))
}
[IO.File]::WriteAllLines($repPath, $r, $utf8)

Write-Output ('[p12 fixups] cell rules {0} | conflicts {1} | appended to shared file {2}' -f $sorted.Count, $conflicts.Count, $added)
Write-Output ('[p12 fixups] variant file: ' + $outPath)
Write-Output ('[p12 fixups] report: ' + $repPath)
if ($conflicts.Count -gt 0) { exit 2 }
