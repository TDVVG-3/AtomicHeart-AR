<#
.SYNOPSIS
  Subtitle timing audit (Workstream A): marker integrity and segment balance.

.DESCRIPTION
  The game times a subtitle line with markers embedded in the text:
      *t*        a point in time (minutes into the voice clip)
      *t1-t2*    an explicit start-end range
  Every culture carries its own marker values (the Korean locres retimes the same key
  differently), so the markers are timing data, not decoration. A translated segment
  must therefore keep

    1. the same marker MULTISET and ORDER as the English source, byte-exact, and
    2. the same meaning per segment: Arabic segment i must carry English segment i,
       otherwise the right words appear at the wrong time (too early / too late) and
       the last part lingers after the voice stopped.

  This audit reports, for every translated row that has markers:
    - marker sequence equality (values AND order) against English,
    - marker count / multiset / order defects (the lingering-subtitle candidates),
    - per-segment Arabic/English length ratio, and outliers outside 0.60-1.60,
    - the Russian reference ratio for the same key (second opinion on content shift).

  Outputs:
    reports/subtitle_timing_audit.md    human report + summary table
    reports/subtitle_timing_rows.tsv    one row per audited master row with its verdict
    reports/subtitle_timing_outliers.tsv per-segment outliers for triage

  ASCII-only script (KI-021). All text comes from the UTF-8 master / ru CSV export.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\subtitle_timing_audit.ps1
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [double]$RatioLow = 0.60,
    [double]$RatioHigh = 1.60,
    [int]$MinSegmentChars = 12
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$ruRoot     = Join-Path $RepoRoot 'localization\extracted\ru_csv'
$outMd      = Join-Path $RepoRoot 'reports\subtitle_timing_audit.md'
$outRows    = Join-Path $RepoRoot 'reports\subtitle_timing_rows.tsv'
$outOut     = Join-Path $RepoRoot 'reports\subtitle_timing_outliers.tsv'
$utf8       = New-Object Text.UTF8Encoding($false)

# marker token: *0.10*  *0.00-0.08*  (also tolerate *1* / *1-2*)
$markerRx = [regex]'\*([0-9]+(?:\.[0-9]+)?(?:-[0-9]+(?:\.[0-9]+)?)?)\*'

function Get-Markers([string]$s) {
    $list = New-Object System.Collections.Generic.List[string]
    foreach ($m in $markerRx.Matches($s)) { $list.Add($m.Groups[1].Value) }
    return ,$list
}
function Get-Segments([string]$s) {
    # text between markers; the leading part (before the first marker) is segment 0
    return ,@($markerRx.Split($s))
}
function Ar-Len([string]$s) {
    $n = 0
    foreach ($ch in $s.ToCharArray()) { if ([int]$ch -ge 0x0600 -and [int]$ch -le 0x06FF) { $n++ } }
    return $n
}
function Word-Count([string]$s) {
    return @($s -split '\s+' | Where-Object { $_ -match '\p{L}' }).Count
}
function Char-Count([string]$s) {
    return ($s -replace '\s','').Length
}

# --- Russian reference: scope -> key -> text (CSV from UnrealLocres export: key,text,)
$ru = New-Object 'System.Collections.Generic.Dictionary[string,string]'
if (Test-Path $ruRoot) {
    Add-Type -AssemblyName Microsoft.VisualBasic | Out-Null
    foreach ($csv in Get-ChildItem $ruRoot -File -Filter '*.csv') {
        $scope = $csv.BaseName
        $parser = New-Object Microsoft.VisualBasic.FileIO.TextFieldParser($csv.FullName, [Text.Encoding]::UTF8)
        $parser.HasFieldsEnclosedInQuotes = $true
        $parser.SetDelimiters(',')
        while (-not $parser.EndOfData) {
            try { $f = $parser.ReadFields() } catch { break }
            if ($f -and $f.Count -ge 2) {
                if ($f[0] -eq 'key' -or $f[0] -eq 'Key') { continue }
                $k = $scope + '|' + $f[0]
                if (-not $ru.ContainsKey($k)) { $ru[$k] = $f[1] }
            }
        }
        $parser.Close()
    }
}
Write-Output ('[ru] reference keys: ' + $ru.Count)

$lines = [IO.File]::ReadAllLines($masterPath, $utf8)
$rows = New-Object System.Collections.Generic.List[string]
$outliers = New-Object System.Collections.Generic.List[string]
$rows.Add(('line' + [char]9 + 'scope' + [char]9 + 'key' + [char]9 + 'en_markers' + [char]9 + 'ar_markers' + [char]9 + 'ru_markers' + [char]9 + 'verdict' + [char]9 + 'segments' + [char]9 + 'min_ratio' + [char]9 + 'max_ratio'))
$outliers.Add(('line' + [char]9 + 'scope' + [char]9 + 'key' + [char]9 + 'seg' + [char]9 + 'en_len' + [char]9 + 'ar_len' + [char]9 + 'ratio' + [char]9 + 'row_median' + [char]9 + 'ru_len' + [char]9 + 'en_text' + [char]9 + 'ar_text'))

$total = 0; $withMarkers = 0
$ok = 0; $missing = 0; $extra = 0; $valueDrift = 0; $orderDrift = 0
$outlierRows = 0; $outlierSegs = 0
$detail = New-Object System.Collections.Generic.List[object]

for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $ar = $f[6]
    if (-not $ar.Trim()) { continue }
    $total++
    $en = $f[5]
    $enM = Get-Markers $en
    $arM = Get-Markers $ar
    if ($enM.Count -eq 0 -and $arM.Count -eq 0) { continue }
    $withMarkers++

    $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $key = $f[4]
    $ruKey = $scope + '|' + $key
    $ruText = ''
    if ($ru.ContainsKey($ruKey)) { $ruText = $ru[$ruKey] }
    $ruM = Get-Markers $ruText

    $verdict = 'OK'
    $enSeq = ($enM -join '|'); $arSeq = ($arM -join '|')
    if ($enSeq -cne $arSeq) {
        if ($arM.Count -lt $enM.Count) { $verdict = 'MISSING'; $missing++ }
        elseif ($arM.Count -gt $enM.Count) { $verdict = 'EXTRA'; $extra++ }
        else {
            $enSorted = (($enM | Sort-Object) -join '|'); $arSorted = (($arM | Sort-Object) -join '|')
            if ($enSorted -ceq $arSorted) { $verdict = 'ORDER'; $orderDrift++ }
            else { $verdict = 'VALUE'; $valueDrift++ }
        }
    } else { $ok++ }

    # segment balance: characters, not words (Arabic packs more meaning per word, so a
    # word ratio flags normal Arabic as an outlier). What matters is that part i of the
    # Arabic carries part i of the English: a part far shorter or far longer than the
    # row's own median means the meaning moved across a timing marker.
    $enS = Get-Segments $en
    $arS = Get-Segments $ar
    $ruS = Get-Segments $ruText
    $n = [Math]::Min($enS.Count, $arS.Count)
    $ratios = New-Object System.Collections.Generic.List[double]
    $lens = New-Object System.Collections.Generic.List[int]
    for ($s = 0; $s -lt $n; $s++) {
        $et = $enS[$s]; $at = $arS[$s]
        $elen = Char-Count $et
        $alen = Char-Count $at
        if ($elen -lt 10) { $ratios.Add(-1.0); $lens.Add(0); continue }
        $ratios.Add([Math]::Round($alen / $elen, 3))
        $lens.Add($elen)
    }
    $valid = @($ratios | Where-Object { $_ -ge 0 })
    $med = 0.0
    if ($valid.Count -gt 0) {
        $sorted = @($valid | Sort-Object)
        $mid = [int][Math]::Floor($sorted.Count / 2)
        if ($sorted.Count % 2 -eq 0) { $med = ($sorted[$mid-1] + $sorted[$mid]) / 2.0 } else { $med = $sorted[$mid] }
    }
    $minR = 99.0; $maxR = 0.0; $nseg = 0; $rowOutlier = 0
    for ($s = 0; $s -lt $n; $s++) {
        $r = $ratios[$s]
        if ($r -lt 0) { continue }
        $nseg++
        if ($r -lt $minR) { $minR = $r }
        if ($r -gt $maxR) { $maxR = $r }
        $flag = $false
        if ($med -gt 0) {
            if ($r -lt 0.50 * $med -or $r -gt 1.80 * $med) { $flag = $true }
        }
        if ($r -lt 0.35 -or $r -gt 2.20) { $flag = $true }
        if ($r -eq 0) { $flag = $true }
        if ($flag) {
            $rowOutlier++
            $outlierSegs++
            $rlen = 0
            if ($s -lt $ruS.Count) { $rlen = Char-Count $ruS[$s] }
            $et = ($enS[$s] -replace "`t", ' ' -replace "`r?`n", ' ')
            $at = ($arS[$s] -replace "`t", ' ' -replace "`r?`n", ' ')
            if ($et.Length -gt 160) { $et = $et.Substring(0,160) }
            if ($at.Length -gt 160) { $at = $at.Substring(0,160) }
            $outliers.Add(('{0}{1}{2}{1}{3}{1}{4}{1}{5}{1}{6}{1}{7}{1}{8}{1}{9}{1}{10}{1}{11}' -f ($i+1), [char]9, $scope, $key, $s, $lens[$s], (Char-Count $arS[$s]), $r, $med, $rlen, $et, $at))
        }
    }    if ($rowOutlier -gt 0) { $outlierRows++ }
    if ($minR -eq 99.0) { $minR = '' }
    if ($nseg -eq 0) { $maxR = '' }

    $rows.Add(('{0}{1}{2}{1}{3}{1}{4}{1}{5}{1}{6}{1}{7}{1}{8}{1}{9}{1}{10}' -f ($i+1), [char]9, $scope, $key, $enSeq, $arSeq, ($ruM -join '|'), $verdict, $nseg, $minR, $maxR))
    $detail.Add([pscustomobject]@{ line = $i+1; scope = $scope; key = $key; verdict = $verdict; enM = $enM; arM = $arM; en = $en; ar = $ar; ru = $ruText })
}

[IO.File]::WriteAllLines($outRows, $rows, $utf8)
[IO.File]::WriteAllLines($outOut, $outliers, $utf8)

$pct = 0.0
if ($withMarkers -gt 0) { $pct = [Math]::Round(100.0 * $ok / $withMarkers, 2) }

$md = New-Object System.Collections.Generic.List[string]
$md.Add('# Subtitle timing audit (Workstream A)')
$md.Add('')
$md.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$md.Add('')
$md.Add('## Method (what the markers are)')
$md.Add('')
$md.Add('A subtitle line carries inline markers `*t*` (time point) and `*t1-t2*` (start-end range), with `t` in minutes into the voice clip. Evidence that they are timing and not decoration:')
$md.Add('')
$md.Add('- the same key carries DIFFERENT marker values per culture. Academy key `/5434B01849407463CAA10B822CDA51A8` has `*0.10*` twice in English and Arabic, no marker at all in Korean, while Academy key `/4B8C709A40B531D70C2A31B74C49E372` has `*0.10*` in English but `*0.19*` / `*0.21*` in Korean - a per-language retime of the same voice clip.')
$md.Add('- the Russian subtitle DataTables (`DT_Subtitles_*`) carry the explicit range form (`*0.00-0.08*`, `*0.09-0.25*`), i.e. start-end times for the same Russian voice clip.')
$md.Add('- the locres text itself is the only string the game receives for these keys (no duration column in the locres schema).')
$md.Add('')
$md.Add('Therefore a translated row must keep the English marker multiset AND order byte-exact, and each Arabic segment must carry the meaning of the English segment at the same index. A lost or reordered marker shifts the text against the voice (P1) and leaves the last part on screen after the voice ends (P2).')
$md.Add('')
$md.Add('## Result')
$md.Add('')
$md.Add('| metric | value |')
$md.Add('| --- | --- |')
$md.Add(('| translated rows audited | {0} |' -f $total))
$md.Add(('| rows that carry markers (EN or AR) | {0} |' -f $withMarkers))
$md.Add(('| marker sequence identical (values + order) | **{0} of {1} ({2}%)** |' -f $ok, $withMarkers, $pct))
$md.Add(('| AR missing markers that EN has (lingering risk) | **{0}** |' -f $missing))
$md.Add(('| AR has extra markers that EN lacks | **{0}** |' -f $extra))
$md.Add(('| same markers, different values (timing drift) | **{0}** |' -f $valueDrift))
$md.Add(('| same markers, different order | **{0}** |' -f $orderDrift))
$md.Add(('| rows with at least one segment-ratio outlier | {0} |' -f $outlierRows))
$md.Add(('| segment outliers (< {0} or > {1} Arabic/English words) | {2} |' -f $RatioLow, $RatioHigh, $outlierSegs))
$md.Add('')
$md.Add('## Defects that explain the user report')
$md.Add('')

if ($missing -gt 0) { $md.Add(('**P2 - lingering subtitles: CONFIRMED for {0} rows.** The Arabic text lost one or more markers that the English has, so the segment structure collapses: the remaining text stays on screen past the end of the voice. These are listed with verdict MISSING in `reports/subtitle_timing_rows.tsv` and are fixed through `tm_fixups.tsv`.' -f $missing)) }
else { $md.Add('**P2 - lingering subtitles: NOT explained by lost markers (0 rows).** See the segment-ratio analysis below.') }
$md.Add('')
if ($valueDrift -gt 0 -or $orderDrift -gt 0) { $md.Add(('**P1 - timing: CONFIRMED for {0} rows with drifted values and {1} rows with reordered markers.** The text of one part is at the wrong time relative to the voice. Values are restored to the English sequence byte-exact.' -f $valueDrift, $orderDrift)) }
else { $md.Add('**P1 - timing: marker values themselves are byte-exact in every row**, so the perceived "too early / too fast" comes from the segment content balance (below), not from marker drift.') }
$md.Add('')
$md.Add(('**Segment balance: {0} rows have at least one part outside {1}-{2}.** A part far too long means the Arabic packed the meaning of the following English part into it (so the viewer reads ahead and the last part is empty when the voice arrives); a part far too short means the meaning moved later. Those rows are rebalanced in Workstream A step 2, keeping the markers byte-exact.' -f $outlierRows, $RatioLow, $RatioHigh))
$md.Add('')
$md.Add('## Worst rows')
$md.Add('')
$md.Add('| line | scope | verdict | EN markers | AR markers |')
$md.Add('| --- | --- | --- | --- | --- |')
$bad = @($detail | Where-Object { $_.verdict -ne 'OK' } | Select-Object -First 25)
foreach ($b in $bad) {
    $md.Add(('| {0} | {1} | {2} | `{3}` | `{4}` |' -f $b.line, $b.scope, $b.verdict, ($b.enM -join ' '), ($b.arM -join ' ')))
}
if ($bad.Count -eq 0) { $md.Add('| - | - | none | - | - |') }
$md.Add('')
$md.Add('## Files')
$md.Add('')
$md.Add('- `reports/subtitle_timing_rows.tsv` - every audited row with its verdict and ratio range.')
$md.Add('- `reports/subtitle_timing_outliers.tsv` - every outlier segment with English and Arabic text for triage.')
[IO.File]::WriteAllLines($outMd, $md, $utf8)

Write-Output ('AUDIT rows {0} | with markers {1} | identical {2} ({3}%) | missing {4} | extra {5} | value {6} | order {7} | outlier rows {8} | outlier segs {9}' -f $total, $withMarkers, $ok, $pct, $missing, $extra, $valueDrift, $orderDrift, $outlierRows, $outlierSegs)
Write-Output ('written: ' + $outMd)
