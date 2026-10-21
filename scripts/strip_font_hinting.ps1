<#
.SYNOPSIS
  Workstream B (P3 shimmer): rebuild an IBM Plex Sans Arabic TTF with the TrueType
  hinting program removed, and optionally with the vertical metrics of the original
  Atomic Heart faces.

.DESCRIPTION
  Evidence (reports/font_ab_evidence.md, build/fonts/original):
    the six faces the font pak replaces (BlenderPro-Book/Medium/Bold, BrutalType,
    Gotham-BookItalic, Gotham-Black) are CFF/OTF fonts: their table directory has
    CFF + no fpgm / prep / cvt at all.
    IBM Plex Sans Arabic is a TrueType font with fpgm 371 B, prep 578 B, cvt 82 B
    and head.flags 0x0009 (force integer ppem).
  A TrueType face with an instruction program is rasterised differently from a CFF
  face, and "force integer ppem" makes glyphs snap to whole pixel heights while the
  subtitle widget is drawn at a fractional scale (SubtitleSizeScale = 0.75). That is
  the mechanism behind H4 (unstable rasterisation while the camera moves).

  This script removes the hinting tables (fpgm, prep, cvt, cvar), clears the
  force-ppem flag, rebuilds the sfnt table directory, recomputes every table
  checksum and head.checkSumAdjustment, and verifies the result by re-parsing it.
  Glyph outlines, cmap, GPOS, GSUB, hmtx and name are copied byte-for-byte, so
  coverage cannot change.

  -NormalizeLineMetrics additionally copies the original faces' vertical metrics
  (hhea 800 / -200 / 200, OS/2 typo 800 / -200 / 200, win 800 / 200). The originals
  have a 1.20 em line box; Plex has 1.50 em (1085 / -415 / 0). This is the H5
  variant: the subtitle style (Size 35, OutlineSize 3) was authored for the
  original metrics.

  ASCII-only (KI-021).

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\strip_font_hinting.ps1 `
    -In source\original\fonts\downloaded\...\IBMPlexSansArabic-Regular.ttf `
    -Out build\fonts\v3\IBMPlexSansArabic-Regular.unhinted.ttf
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$In,
    [Parameter(Mandatory = $true)][string]$Out,
    [switch]$NormalizeLineMetrics
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

function U16([byte[]]$b, [int]$i) { return ([uint16]$b[$i] -shl 8) -bor [uint16]$b[$i+1] }
function U32([byte[]]$b, [int]$i) {
    [uint64]$v = ([uint64]$b[$i] -shl 24) -bor ([uint64]$b[$i+1] -shl 16) -bor ([uint64]$b[$i+2] -shl 8) -bor [uint64]$b[$i+3]
    return [uint32]($v -band ([uint64]4294967295))
}
function W16([byte[]]$b, [int]$i, [int]$v) { $b[$i] = [byte](($v -shr 8) -band 0xFF); $b[$i+1] = [byte]($v -band 0xFF) }
function W32([byte[]]$b, [int]$i, [uint32]$v) {
    $b[$i] = [byte](($v -shr 24) -band 0xFF); $b[$i+1] = [byte](($v -shr 16) -band 0xFF)
    $b[$i+2] = [byte](($v -shr 8) -band 0xFF); $b[$i+3] = [byte]($v -band 0xFF)
}
function Table-Checksum([byte[]]$data, [int]$offset, [int]$length) {
    [uint64]$sum = 0
    $end = $offset + $length
    $i = $offset
    while ($i -lt $end) {
        [uint64]$v = 0
        for ($k = 0; $k -lt 4; $k++) {
            $v = ($v -shl 8)
            if ($i + $k -lt $end) { $v = $v -bor [uint64]$data[$i + $k] }
        }
        $sum = ($sum + $v) -band ([uint64]4294967295)
        $i += 4
    }
    return [uint32]$sum
}

if (-not (Test-Path $In)) { throw "input font not found: $In" }
$src = [IO.File]::ReadAllBytes($In)
if ($src.Length -lt 12) { throw 'input is not a font' }
$sfnt = U32 $src 0
if ($sfnt -ne 0x00010000 -and $sfnt -ne 0x4F54544F -and $sfnt -ne 0x74727565) { throw ('unsupported sfnt version 0x' + $sfnt.ToString('x8')) }
$num = [int](U16 $src 4)

$records = New-Object System.Collections.Generic.List[object]
for ($i = 0; $i -lt $num; $i++) {
    $o = 12 + $i * 16
    $tag = [Text.Encoding]::ASCII.GetString($src, $o, 4)
    $records.Add([pscustomobject]@{
        Tag = $tag
        Checksum = (U32 $src ($o + 4))
        Offset = [int](U32 $src ($o + 8))
        Length = [int](U32 $src ($o + 12))
    })
}
$tags = @($records | ForEach-Object { $_.Tag.Trim() })
$drop = @('fpgm', 'prep', 'cvt ', 'cvar')
$removed = @($tags | Where-Object { $drop -contains $_ })
$kept = @($records | Where-Object { $drop -notcontains $_.Tag.Trim() })

# copy the kept tables into owned byte arrays so we can patch head / hhea / OS/2
$tables = @{}
foreach ($r in $kept) {
    $buf = New-Object byte[] ($r.Length)
    [Array]::Copy($src, $r.Offset, $buf, 0, $r.Length)
    $tables[$r.Tag] = $buf
}

if (-not $tables.ContainsKey('head')) { throw 'head table missing' }
$head = $tables['head']
# head.flags: clear bit 3 (force ppem to integer values) and bit 4, set bit 1 like the CFF originals (0x0003)
W16 $head 16 0x0003
# checkSumAdjustment is recomputed at the end
W32 $head 8 0

if ($NormalizeLineMetrics) {
    if ($tables.ContainsKey('hhea')) {
        $hhea = $tables['hhea']
        W16 $hhea 4 800      # ascender
        W16 $hhea 6 (-200)   # descender
        W16 $hhea 8 200      # lineGap
    }
    if ($tables.ContainsKey('OS/2')) {
        $os2 = $tables['OS/2']
        $ver = U16 $os2 0
        if ($ver -ge 1 -and $os2.Length -ge 78) {
            W16 $os2 68 800      # sTypoAscender
            W16 $os2 70 (-200)   # sTypoDescender
            W16 $os2 72 200      # sTypoLineGap
            W16 $os2 74 800      # usWinAscent
            W16 $os2 76 200      # usWinDescent
        }
    }
}

$n = $kept.Count
$searchRange = 16
$entrySelector = 0
while (($searchRange * 2) -le ($n * 16)) { $searchRange *= 2; $entrySelector++ }
$rangeShift = $n * 16 - $searchRange

$headerLen = 12 + 16 * $n
$cursor = $headerLen
$layout = New-Object System.Collections.Generic.List[object]
foreach ($r in $kept) {
    $len = $tables[$r.Tag].Length
    $layout.Add([pscustomobject]@{ Tag = $r.Tag; Offset = $cursor; Length = $len })
    $cursor += [int]([Math]::Ceiling($len / 4.0) * 4)
}
$outBytes = New-Object byte[] $cursor
W32 $outBytes 0 $sfnt
W16 $outBytes 4 $n
W16 $outBytes 6 $searchRange
W16 $outBytes 8 $entrySelector
W16 $outBytes 10 $rangeShift

$recIndex = 0
foreach ($l in $layout) {
    $o = 12 + $recIndex * 16
    $tagBytes = [Text.Encoding]::ASCII.GetBytes($l.Tag)
    [Array]::Copy($tagBytes, 0, $outBytes, $o, 4)
    $data = $tables[$l.Tag]
    [Array]::Copy($data, 0, $outBytes, $l.Offset, $l.Length)
    $sum = Table-Checksum $outBytes $l.Offset $l.Length
    W32 $outBytes ($o + 4) $sum
    W32 $outBytes ($o + 8) ([uint32]$l.Offset)
    W32 $outBytes ($o + 12) ([uint32]$l.Length)
    $recIndex++
}

# head.checkSumAdjustment = 0xB1B0AFBA - checksum(entire font)
$headLayout = $layout | Where-Object { $_.Tag -eq 'head' } | Select-Object -First 1
if (-not $headLayout) { throw 'head layout missing' }
$fileSum = Table-Checksum $outBytes 0 $outBytes.Length
$adjust = [uint32]((([uint64]2982240698 - $fileSum)) -band ([uint64]4294967295))
W32 $outBytes ([int]$headLayout.Offset + 8) $adjust

$outDir = Split-Path -Parent $Out
if ($outDir -and -not (Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }
[IO.File]::WriteAllBytes($Out, $outBytes)

# ---------------- verification: re-parse the output ----------------
$v = [IO.File]::ReadAllBytes($Out)
$vnum = [int](U16 $v 4)
$vtags = @()
$bad = 0
for ($i = 0; $i -lt $vnum; $i++) {
    $o = 12 + $i * 16
    $tag = [Text.Encoding]::ASCII.GetString($v, $o, 4)
    $sum = U32 $v ($o + 4)
    $off = [int](U32 $v ($o + 8))
    $len = [int](U32 $v ($o + 12))
    $vtags += $tag.Trim()
    if ($tag.Trim() -ne 'head') {
        $calc = Table-Checksum $v $off $len
        if ($calc -ne $sum) { $bad++ }
    }
}
$vhead = (0..($vnum - 1) | Where-Object { [Text.Encoding]::ASCII.GetString($v, 12 + $_ * 16, 4) -eq 'head' } | Select-Object -First 1)
$hOff = [int](U32 $v (12 + $vhead * 16 + 8))
$hLen = [int](U32 $v (12 + $vhead * 16 + 12))
$saved = U32 $v ($hOff + 8)
W32 $v ($hOff + 8) 0
$total = Table-Checksum $v 0 $v.Length
W32 $v ($hOff + 8) $saved
$adjOk = (($total + $saved) -band ([uint64]4294967295)) -eq 2982240698
$hintLeft = @($vtags | Where-Object { $drop -contains $_ })

Write-Output ('[strip] ' + [IO.Path]::GetFileName($In) + ' -> ' + [IO.Path]::GetFileName($Out))
Write-Output ('  tables: {0} -> {1} | removed: {2}' -f $num, $vnum, ($(if ($removed.Count) { $removed -join ',' } else { 'none' })))
Write-Output ('  size: {0} -> {1} bytes' -f $src.Length, $v.Length)
Write-Output ('  checksums: {0} bad table(s), head.checkSumAdjustment {1}' -f $bad, $(if ($adjOk) { 'valid' } else { 'INVALID' }))
Write-Output ('  hint tables left: ' + $(if ($hintLeft.Count) { $hintLeft -join ',' } else { 'none' }))
Write-Output ('  head.flags: 0x' + (U16 $v ($hOff + 16)).ToString('x4'))
if ($NormalizeLineMetrics) {
    $hheaIdx = (0..($vnum - 1) | Where-Object { [Text.Encoding]::ASCII.GetString($v, 12 + $_ * 16, 4) -eq 'hhea' } | Select-Object -First 1)
    $hheaOff = [int](U32 $v (12 + $hheaIdx * 16 + 8))
    $os2Idx = (0..($vnum - 1) | Where-Object { [Text.Encoding]::ASCII.GetString($v, 12 + $_ * 16, 4) -eq 'OS/2' } | Select-Object -First 1)
    $os2Off = [int](U32 $v (12 + $os2Idx * 16 + 8))
    Write-Output ('  line metrics: hhea {0}/{1}/{2} | typo {3}/{4}/{5} win {6}/{7}' -f `
        (U16 $v ($hheaOff + 4)), (U16 $v ($hheaOff + 6)), (U16 $v ($hheaOff + 8)), `
        (U16 $v ($os2Off + 68)), (U16 $v ($os2Off + 70)), (U16 $v ($os2Off + 72)), `
        (U16 $v ($os2Off + 74)), (U16 $v ($os2Off + 76)))
}
if ($bad -ne 0 -or -not $adjOk -or $hintLeft.Count -ne 0) { throw 'font rebuild verification FAILED' }
Write-Output '  VERIFY: PASS'
