param(
    [Parameter(Mandatory=$true)][string]$InTsV,
    [Parameter(Mandatory=$true)][string]$OutTsV,
    [ValidateSet('H2','H1H2H3')][string]$Mode = 'H2',
    [string]$AuditRows = 'C:\AtomicHeart-AR\reports\subtitle_stack_rows.tsv',
    [string]$ReportPath = ''
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$TAB = [char]9
$inv = [Globalization.CultureInfo]::InvariantCulture
$utf8 = New-Object Text.UTF8Encoding($false)
if (-not $ReportPath) { $ReportPath = [IO.Path]::ChangeExtension($OutTsV, '.caps.md') }
$rx = [regex]'\*([0-9]+(?:\.[0-9]+)?)(?:-([0-9]+(?:\.[0-9]+)?))?\*'
$arLetter = [regex]'[\u0621-\u064A\u0660-\u0669\u066E-\u06D3\u06D5\u06E5-\u06E6\u06EE-\u06EF\u06FA-\u06FC\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]'

function F3([double]$v) { return $v.ToString('0.######', $inv) }
function Same([double]$a, [double]$b) { return [Math]::Abs($a - $b) -lt 0.0000001 }

# Normalize clip seconds to marker minutes once, before all comparisons.
if (-not (Test-Path $AuditRows)) { throw ('audit rows not found: ' + $AuditRows) }
$clipByLine = @{}; $h3ByLine = @{}
$al = [IO.File]::ReadAllLines($AuditRows, [Text.Encoding]::UTF8)
$head = $al[0] -split $TAB
$idxLine = [Array]::IndexOf($head, 'line')
$idxClip = [Array]::IndexOf($head, 'clip_seconds')
$idxH3 = [Array]::IndexOf($head, 'h3_final_following')
if ($idxLine -lt 0 -or $idxClip -lt 0 -or $idxH3 -lt 0) { throw 'audit rows header is missing line/clip_seconds/h3_final_following' }
for ($i = 1; $i -lt $al.Count; $i++) {
    if (-not $al[$i].Trim()) { continue }
    $f = $al[$i] -split $TAB
    if ($f.Count -le [Math]::Max($idxLine, [Math]::Max($idxClip, $idxH3))) { continue }
    $ln = 0; if (-not [int]::TryParse($f[$idxLine], [ref]$ln)) { continue }
    if ($ln -le 0) { continue }
    $c = 0.0; [double]::TryParse($f[$idxClip], [Globalization.NumberStyles]::Float, $inv, [ref]$c) | Out-Null
    $clipMinutes = $c / 60.0
    if ($clipMinutes -gt 0 -and (-not $clipByLine.ContainsKey($ln) -or $clipMinutes -gt $clipByLine[$ln])) { $clipByLine[$ln] = $clipMinutes }
    if ($f[$idxH3] -eq '1') { $h3ByLine[$ln] = 1 }
}

$lines = [IO.File]::ReadAllLines($InTsV, [Text.Encoding]::UTF8)
$out = New-Object System.Collections.Generic.List[string]
$out.Add($lines[0])
$rowsChanged = 0; $h1Offsets = 0; $h1Ambiguous = 0; $h2Caps = 0; $h3Ends = 0; $h3Inserts = 0; $h3Caps = 0; $skippedNoClip = 0; $skippedInvalidTrack = 0
$byScope = @{}
$manualReview = New-Object System.Collections.Generic.List[string]
function Scope-Of([string]$file) {
    $s = 'other'; if ($file -match '/Localization/(.+?)/en-US/') { $s = $Matches[1] }
    return $s
}
function Scoped([string]$scope) {
    if (-not $script:byScope.ContainsKey($scope)) { $script:byScope[$scope] = @{ rows = 0; h1 = 0; h2 = 0; h3 = 0; h3i = 0 } }
    return $script:byScope[$scope]
}

for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { $out.Add($lines[$i]); continue }
    $f = $lines[$i] -split $TAB
    if ($f.Count -ne 13) { $out.Add($lines[$i]); continue }
    $ar = $f[6]
    if (-not $ar.Trim()) { $out.Add($lines[$i]); continue }
    $ln = $i + 1
    $scope = Scope-Of $f[2]
    $d = Scoped $scope
    $d.rows++
    $clip = if ($clipByLine.ContainsKey($ln)) { $clipByLine[$ln] } else { 0.0 }
    $newAr = $ar
    $rowChanged = $false
    $ms = $rx.Matches($ar)
    if ([regex]::Matches($ar, '\*[0-9][0-9.\-]*\*').Count -ne $ms.Count) {
        $skippedInvalidTrack++
        $manualReview.Add(('| {0} | {1} | malformed numeric marker; needs source/audio review |' -f $ln, $f[4]))
        $out.Add($lines[$i]); continue
    }
    $tokens = New-Object System.Collections.Generic.List[object]
    for ($j = 0; $j -lt $ms.Count; $j++) {
        $s = [double]::Parse($ms[$j].Groups[1].Value, $inv)
        $e = $null
        if ($ms[$j].Groups[2].Success) { $e = [double]::Parse($ms[$j].Groups[2].Value, $inv) }
        $tokens.Add([pscustomobject]@{
            Index = $ms[$j].Index; Length = $ms[$j].Length; Text = $ms[$j].Value
            StartText = $ms[$j].Groups[1].Value; EndText = $(if ($ms[$j].Groups[2].Success) { $ms[$j].Groups[2].Value } else { '' })
            Start = $s; End = $e; HasEnd = $ms[$j].Groups[2].Success
            NewStart = $s; NewEnd = $e; Changed = $false
        })
    }

    if ($tokens.Count -eq 0) {
        # Markerless page: H3 fix inserts a start=0 range when a following scene row exists.
        if ($Mode -eq 'H1H2H3' -and $h3ByLine.ContainsKey($ln) -and $clip -gt 0) {
            $visible = [regex]::Replace($ar, '&[^&]{1,40}&', ' ')
            $visible = [regex]::Replace($visible, '<[^<>]*>', ' ')
            $chars = $arLetter.Matches($visible).Count
            $end = ($chars / 15.0 + 1.2) / 60.0
            $cap = [Math]::Floor(($clip - 0.000001) * 1000000) / 1000000
            if ($end -gt $cap) { $end = $cap }
            if ($end -le 0) { $skippedInvalidTrack++; $manualReview.Add(('| {0} | {1} | invalid/unrepresentable clip window |' -f $ln, $f[4])); $out.Add($lines[$i]); continue }
            $newAr = '*0-' + (F3 $end) + '*' + $ar
            $rowChanged = $true
            $h3Inserts++
            $d.h3i++
        } elseif ($Mode -eq 'H1H2H3' -and $h3ByLine.ContainsKey($ln) -and $clip -le 0) {
            $skippedNoClip++
        }
        if ($rowChanged) {
            $f[6] = $newAr
            $out.Add(($f -join $TAB))
            $rowsChanged++
        } else {
            $out.Add($lines[$i])
        }
        continue
    }

    # A start at/after the clip end has no valid window: retain the row for manual review.
    if ($Mode -eq 'H1H2H3' -and $clip -gt 0 -and @($tokens | Where-Object { $_.Start -ge $clip - 0.000001 }).Count -gt 0) {
        $skippedInvalidTrack++; $manualReview.Add(('| {0} | {1} | invalid/unrepresentable clip window |' -f $ln, $f[4])); $out.Add($lines[$i]); continue
    }

    # H1: spread a whole duplicate group before the next distinct start (never just one pair).
    if ($Mode -eq 'H1H2H3') {
        $mono = $true
        for ($j = 1; $j -lt $tokens.Count; $j++) {
            if ($tokens[$j].Start -lt $tokens[$j - 1].Start) { $mono = $false; break }
        }
        if (-not $mono) {
            $h1Ambiguous++
            $manualReview.Add(('| {0} | {1} | descending source timing; needs audio review |' -f $ln, $f[4]))
            $out.Add($lines[$i]); continue
        }
        for ($j = 0; $j -lt $tokens.Count; $j++) {
            $endGroup = $j + 1
            while ($endGroup -lt $tokens.Count -and (Same $tokens[$endGroup].Start $tokens[$j].Start)) { $endGroup++ }
            $count = $endGroup - $j
            if ($count -le 1) { continue }
            $limit = if ($endGroup -lt $tokens.Count) { $tokens[$endGroup].Start } elseif ($clip -gt 0) { $clip } else { $tokens[$j].Start + $count * 0.001 }
            $step = [Math]::Min(0.001, ($limit - $tokens[$j].Start) / $count)
            for ($k = 1; $k -lt $count; $k++) {
                $t = $tokens[$j + $k]
                $t.NewStart = [Math]::Round($tokens[$j].Start + $k * $step, 6)
                if ($t.HasEnd) { $t.NewEnd = $t.End + $t.NewStart - $t.Start }
                $t.Changed = $true
                $h1Offsets++; $d.h1++
            }
            $j = $endGroup - 1
        }
        $valid = $true
        for ($j = 1; $j -lt $tokens.Count; $j++) {
            if ($tokens[$j].NewStart -le $tokens[$j - 1].NewStart) { $valid = $false }
        }
        if ($clip -gt 0 -and $tokens[$tokens.Count - 1].NewStart -ge $clip - 0.000001) { $valid = $false }
        if (-not $valid) { $skippedInvalidTrack++; $manualReview.Add(('| {0} | {1} | invalid/unrepresentable clip window |' -f $ln, $f[4])); $out.Add($lines[$i]); continue }
    }

    # H2: explicit range end strictly before the next page start.
    for ($j = 0; $j -lt $tokens.Count; $j++) {
        $t = $tokens[$j]
        if (-not $t.HasEnd -or $j + 1 -ge $tokens.Count) { continue }
        $nextStart = $tokens[$j + 1].NewStart
        if ($null -ne $t.NewEnd -and $t.NewEnd -ge $nextStart - 0.0001) {
            $cap = $nextStart - 0.001
            if ($cap -le $t.NewStart) { $cap = [Math]::Round(($t.NewStart + $nextStart) / 2.0, 6) }
            if ($cap -gt $t.NewStart -and $cap -lt $nextStart) {
                $t.NewEnd = $cap
                $t.Changed = $true
                $h2Caps++
                $d.h2++
            }
        }
    }

    # H3: final page gets/keeps an end, capped at the clip end when known.
    if ($Mode -eq 'H1H2H3') {
        $last = $tokens[$tokens.Count - 1]
        if (-not $last.HasEnd -and $h3ByLine.ContainsKey($ln)) {
            if ($clip -gt 0) {
                $visible = $ar.Substring($last.Index + $last.Length)
                $visible = [regex]::Replace($visible, '&[^&]{1,40}&', ' ')
                $visible = [regex]::Replace($visible, '<[^<>]*>', ' ')
                $chars = $arLetter.Matches($visible).Count
                $end = $last.NewStart + ($chars / 15.0 + 1.2) / 60.0
                $cap = [Math]::Floor(($clip - 0.000001) * 1000000) / 1000000
                if ($end -gt $cap) { $end = $cap }
                if ($end -le $last.NewStart) { $skippedInvalidTrack++; $manualReview.Add(('| {0} | {1} | invalid/unrepresentable clip window |' -f $ln, $f[4])); $out.Add($lines[$i]); continue }
                $last.NewEnd = $end
                $last.Changed = $true
                $h3Ends++
                $d.h3++
            } else {
                $skippedNoClip++
            }
        } elseif ($last.HasEnd -and $clip -gt 0 -and $last.NewEnd -ge $clip - 0.000001) {
            $cap = [Math]::Floor(($clip - 0.000001) * 1000000) / 1000000
            if ($cap -gt $last.NewStart -and -not (Same $last.NewEnd $cap)) {
                $last.NewEnd = $cap
                $last.Changed = $true
                $h3Caps++
                $d.h3++
            }
        }
    }

    if (-not ($tokens | Where-Object { $_.Changed })) {
        $out.Add($lines[$i])
        continue
    }
    # Rebuild from the end so earlier indices stay valid.
    for ($j = $tokens.Count - 1; $j -ge 0; $j--) {
        $t = $tokens[$j]
        if (-not $t.Changed) { continue }
        $startText = if (Same $t.NewStart $t.Start) { $t.StartText } else { F3 $t.NewStart }
        $hasEnd = $t.HasEnd -or ($null -ne $t.NewEnd)
        $endText = ''
        if ($hasEnd) {
            if ($t.HasEnd -and (Same $t.NewEnd $t.End)) { $endText = $t.EndText } else { $endText = F3 $t.NewEnd }
        }
        $tok = '*' + $startText + $(if ($hasEnd) { '-' + $endText } else { '' }) + '*'
        $newAr = $newAr.Substring(0, $t.Index) + $tok + $newAr.Substring($t.Index + $t.Length)
    }
    $f[6] = $newAr
    $out.Add(($f -join $TAB))
    $rowsChanged++
}

[IO.File]::WriteAllLines($OutTsV, $out, $utf8)

$r = New-Object System.Collections.Generic.List[string]
$r.Add('# Subtitle caps - ' + $Mode)
$r.Add('')
$r.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')))
$r.Add(('Input: `{0}`' -f $InTsV))
$r.Add(('Output: `{0}`' -f $OutTsV))
$r.Add('')
$r.Add('All marker calculations use minutes; clip_seconds is converted on input. Six decimal places retain sub-millisecond boundaries.')
$r.Add('Unresolvable or descending tracks are left unchanged for manual review; this is not a runtime HUD verification.')
$r.Add('| item | count |')
$r.Add('| --- | ---: |')
$r.Add(('| rows changed | {0} |' -f $rowsChanged))
$r.Add(('| H1 duplicate-start offsets | {0} |' -f $h1Offsets))
$r.Add(('| H1 non-monotonic tracks left unchanged | {0} |' -f $h1Ambiguous))
$r.Add(('| H2 end caps before next start | {0} |' -f $h2Caps))
$r.Add(('| H3 final-page ends added | {0} |' -f $h3Ends))
$r.Add(('| H3 markerless pages given *0-end* | {0} |' -f $h3Inserts))
$r.Add(('| H3 final ends capped at clip end | {0} |' -f $h3Caps))
$r.Add(('| H3 rows skipped (no clip duration) | {0} |' -f $skippedNoClip))
$r.Add(('| rows retained for manual review (invalid or unrepresentable window) | {0} |' -f $skippedInvalidTrack))
$r.Add('')
$r.Add('## Per scope')
$r.Add('')
$r.Add('| scope | rows | H1 | H2 | H3 ends | H3 inserts |')
$r.Add('| --- | ---: | ---: | ---: | ---: | ---: |')
foreach ($s in ($byScope.Keys | Sort-Object)) {
    $d = $byScope[$s]
    $r.Add(('| {0} | {1} | {2} | {3} | {4} | {5} |' -f $s, $d.rows, $d.h1, $d.h2, $d.h3, $d.h3i))
}
$r.Add('')
$r.Add('H1 only offsets duplicate page starts. H2 caps explicit range ends strictly before the next page start. H3 adds an end to a final singleton page; for markerless cells it inserts `*0-end*` using the Wwise clip duration and a 15 chars/s + 1.2 s reading allowance. Absolute DataTable row start offsets are not present in the cooked data, so the next *line* start cannot be used directly; the clip end is the conservative cap. This is the UNKNOWN limitation documented in the stack audit.')
$r.Add('')
$r.Add('## Rows retained for manual review')
$r.Add('| line | key | reason |')
$r.Add('| ---: | --- | --- |')
foreach ($entry in $manualReview) { $r.Add($entry) }
[IO.File]::WriteAllLines($ReportPath, $r, $utf8)

Write-Output ('[caps {0}] rows changed {1} | H1 {2} (ambiguous {3}) | H2 {4} | H3 ends {5} | inserts {6} | clip caps {7} | no-clip {8}' -f $Mode, $rowsChanged, $h1Offsets, $h1Ambiguous, $h2Caps, $h3Ends, $h3Inserts, $h3Caps, $skippedNoClip)
Write-Output ('[caps] output: ' + $OutTsV)
Write-Output ('[caps] report: ' + $ReportPath)
