param(
    [string]$BaseTsV = 'C:\AtomicHeart-AR\localization\master\atomic-heart-ar.tsv',
    [string]$OutTsV = 'C:\AtomicHeart-AR\build\variants\atomic-heart-ar_p12.tsv',
    [string]$KeepPath = 'C:\AtomicHeart-AR\localization\working\keep_original.tsv',
    [string]$FixupsPath = 'C:\AtomicHeart-AR\localization\working\tm_fixups_p12.tsv',
    [string]$ReportPath = 'C:\AtomicHeart-AR\reports\p12_master.md',
    [string]$FixupLogPath = 'C:\AtomicHeart-AR\reports\p12_text_fixups_log.md'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$TAB = [char]9
$repo = 'C:\AtomicHeart-AR'
$utf8 = New-Object Text.UTF8Encoding($false)
$applyScript = Join-Path $repo 'scripts\apply_text_fixups.ps1'

# label text is data, never a PowerShell literal
$label = ''
$lb = [IO.File]::ReadAllLines((Join-Path $repo 'localization\working\p3_label.tsv'), [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $lb.Count; $i++) {
    $f = $lb[$i] -split $TAB
    if ($f.Count -ge 2 -and $f[0].Trim() -ceq 'P-3') { $label = $f[1]; break }
}
if (-not $label) { throw 'p3_label.tsv has no P-3 row' }

$keep = @{}
$kl = [IO.File]::ReadAllLines($KeepPath, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $kl.Count; $i++) {
    if (-not $kl[$i].Trim()) { continue }
    $f = $kl[$i] -split $TAB
    if ($f.Count -lt 3) { continue }
    $keep[$f[1] + '|' + $f[2]] = 1
}

$base = [IO.File]::ReadAllLines($BaseTsV, [Text.Encoding]::UTF8)
$out = New-Object System.Collections.Generic.List[string]
$out.Add($base[0])
$keepRows = 0; $keepFound = 0; $keepBeforeArabic = 0
$p3Rows = 0; $p3BeforeArabic = 0; $p3Filled = 0; $p3Conflict = 0
$bodyP3Rows = 0; $bodyP3Changed = 0
$cellChanged = 0
$byScope = @{}
function Scope-Of([string]$file) {
    $s = 'other'; if ($file -match '/Localization/(.+?)/en-US/') { $s = $Matches[1] }
    return $s
}
function Scoped([string]$scope) {
    if (-not $script:byScope.ContainsKey($scope)) {
        $script:byScope[$scope] = [pscustomobject]@{ keep = 0; keepBefore = 0; p3 = 0; p3Before = 0; cell = 0; arBefore = 0; arAfter = 0; copyAfter = 0; total = 0 }
    }
    return $script:byScope[$scope]
}

for ($i = 1; $i -lt $base.Count; $i++) {
    if (-not $base[$i].Trim()) { $out.Add($base[$i]); continue }
    $f = $base[$i] -split $TAB
    if ($f.Count -ne 13) { $out.Add($base[$i]); continue }
    $scope = Scope-Of $f[2]
    $sig = $scope + '|' + $f[4]
    $d = Scoped $scope
    $d.total++
    if ($f[6].Trim()) { $d.arBefore++ }
    $isKeep = $keep.ContainsKey($sig)
    if ($isKeep) {
        $keepRows++
        if ($f[6].Trim()) { $keepBeforeArabic++; $d.keepBefore++ }
        $f[6] = ''
        $f[10] = 'COPY'
        if ($f[11] -notmatch 'keep original name') {
            $f[11] = if ($f[11].Trim()) { $f[11] + '; keep original name' } else { 'keep original name' }
        }
        $keepFound++
        $d.keep++
        $out.Add(($f -join $TAB))
        continue
    }
    $en = $f[5].Trim()
    if ($en -ceq 'P-3') {
        $p3Rows++
        if ($f[6].Trim()) { $p3BeforeArabic++ }
        # The label rule in tm_fixups_p12.tsv performs the fill (and sets Status DRAFT).
        $out.Add($base[$i])
        continue
    }
    if ($f[5] -match 'P-3') { $bodyP3Rows++ }
    $out.Add($base[$i])
}

[IO.File]::WriteAllLines($OutTsV, $out, $utf8)

# Apply the p12-only fixups (P-3 fill + 127 cell-scoped item names).
& $applyScript -RepoRoot $repo -MasterTsV $OutTsV -Fixups $FixupsPath -LogPath $FixupLogPath -MasterOnly
if (-not $?) { throw 'apply_text_fixups failed' }

# Verify and collect after counts.
$final = [IO.File]::ReadAllLines($OutTsV, [Text.Encoding]::UTF8)
if ($final.Count -ne $base.Count) { throw ('row count changed: ' + $base.Count + ' -> ' + $final.Count) }
$p3StillEmpty = 0; $p3Wrong = 0; $bodyP3Changed = 0; $cellChanged = 0
for ($i = 1; $i -lt $final.Count; $i++) {
    if (-not $final[$i].Trim()) { continue }
    $a = $base[$i] -split $TAB
    $b = $final[$i] -split $TAB
    if ($a.Count -ne 13 -or $b.Count -ne 13) { throw ('line ' + ($i + 1) + ' column count changed') }
    $scope = Scope-Of $b[2]
    $d = Scoped $scope
    if ($b[6].Trim()) { $d.arAfter++ }
    if ($b[10] -eq 'COPY') { $d.copyAfter++ }
    $en = $b[5].Trim()
    if ($en -ceq 'P-3') {
        if (-not $b[6].Trim()) { $p3StillEmpty++ }
        elseif ($b[6] -cne $label) { $p3Wrong++ }
        if (-not $a[6].Trim() -and $b[6] -ceq $label) { $p3Filled++; $d.p3++ }
    } elseif ($b[5] -match 'P-3' -and $a[6] -cne $b[6]) {
        $bodyP3Changed++
    }
    if ($a[6] -cne $b[6] -and $en -cne 'P-3' -and -not $keep.ContainsKey((Scope-Of $b[2]) + '|' + $b[4])) {
        $cellChanged++
        $d.cell++
    }
    # non-Arabic columns: only Status (10) and Notes (11) may differ, and only for keep rows
    for ($c = 0; $c -lt 13; $c++) {
        if ($c -in @(6,10,11)) { continue }
        if ($a[$c] -cne $b[$c]) { throw ('line ' + ($i + 1) + ' column ' + $c + ' changed unexpectedly') }
    }
}

$r = New-Object System.Collections.Generic.List[string]
$r.Add('# p12 master - CHANGE 1 + CHANGE 2')
$r.Add('')
$r.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')))
$r.Add('')
$r.Add(('Base: `{0}`' -f $BaseTsV))
$r.Add(('Output: `{0}`' -f $OutTsV))
$r.Add(('Fixups: `{0}`' -f $FixupsPath))
$r.Add('')
$r.Add('## Change counts')
$r.Add('')
$r.Add('| item | count |')
$r.Add('| --- | ---: |')
$r.Add(('| master rows | {0} |' -f ($base.Count - 1)))
$r.Add(('| keep-original rows cleared to COPY | {0} |' -f $keepRows))
$r.Add(('| keep-original rows found in master | {0} |' -f $keepFound))
$r.Add(('| keep-original rows with Arabic before | {0} |' -f $keepBeforeArabic))
$r.Add(('| exact P-3 speaker-label rows | {0} |' -f $p3Rows))
$r.Add(('| P-3 rows already Arabic before | {0} |' -f $p3BeforeArabic))
$r.Add(('| P-3 rows filled with the Major label | {0} |' -f $p3Filled))
$r.Add(('| P-3 rows still empty | {0} |' -f $p3StillEmpty))
$r.Add(('| P-3 rows with a different Arabic value | {0} |' -f ($p3Conflict + $p3Wrong)))
$r.Add(('| body-text rows containing P-3 | {0} |' -f $bodyP3Rows))
$r.Add(('| body-text P-3 rows changed (must be 0) | {0} |' -f $bodyP3Changed))
$r.Add(('| in-sentence item-name rows changed by cell rules | {0} |' -f $cellChanged))
$r.Add('')
$r.Add('## Before / after by scope')
$r.Add('')
$r.Add('| scope | rows | Arabic before | Arabic after | COPY after | keep rows | P-3 labels | in-sentence rows |')
$r.Add('| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |')
foreach ($s in ($byScope.Keys | Sort-Object)) {
    $d = $byScope[$s]
    $r.Add(('| {0} | {1} | {2} | {3} | {4} | {5} | {6} | {7} |' -f $s, $d.total, $d.arBefore, $d.arAfter, $d.copyAfter, $d.keep, $d.p3, $d.cell))
}
$r.Add('')
$r.Add('The canonical master is untouched. Keep-original rows use empty Arabic + Status COPY so the carrier fill policy emits the English name. P-3 labels and in-sentence item names are applied by `tm_fixups_p12.tsv`; the shared `tm_fixups.tsv` also contains the same rules for the record, but p12 never applies the older p11f rules.')
[IO.File]::WriteAllLines($ReportPath, $r, $utf8)

Write-Output ('[p12 master] rows {0} | keep {1} | P-3 filled {2} (empty {3}, conflict {4}) | cell rows {5} | body-P3 changed {6}' -f ($base.Count - 1), $keepRows, $p3Filled, $p3StillEmpty, ($p3Conflict + $p3Wrong), $cellChanged, $bodyP3Changed)
Write-Output ('[p12 master] variant: ' + $OutTsV)
Write-Output ('[p12 master] report: ' + $ReportPath)
if ($p3StillEmpty -gt 0 -or ($p3Conflict + $p3Wrong) -gt 0 -or $bodyP3Changed -gt 0) { exit 2 }
