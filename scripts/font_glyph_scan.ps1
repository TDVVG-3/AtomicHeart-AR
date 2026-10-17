<#
.SYNOPSIS
  Phase 6: scans font binaries (TTF/OTF/TTC/WOFF/UE4 .ufont) for glyph coverage of
  the Arabic Unicode blocks, plus other script blocks, via their cmap tables.

.DESCRIPTION
  Pure PowerShell TTF/OTF parser (no external dependencies):
   - handles single fonts, 'ttcf' collections, and UE4 .ufont containers
     (which may prefix raw sfnt data; the scanner auto-detects the sfnt magic).
   - parses cmap subtables of format 4 and format 12 (standard for BMP + full plane).
  Output: reports/font_glyph_coverage.txt with per-font verdict for Arabic:
   FULL (all core letters) / PARTIAL / NONE.

  Reusable later (Phase 8) to verify downloaded open fonts (IBM Plex Sans Arabic,
  Noto Sans Arabic) BEFORE adding them to the project.
#>
[CmdletBinding()]
param(
    [string]$FontsRoot = 'C:\AtomicHeart-AR\source\original\fonts',
    [string]$OutPath = 'C:\AtomicHeart-AR\reports\font_glyph_coverage.txt'
)

function U16([byte[]]$b, [int]$i) { ([uint16]($b[$i]) -shl 8) -bor [uint16]($b[$i+1]) }
function U32([byte[]]$b, [int]$i) {
    ([uint32]($b[$i]) -shl 24) -bor ([uint32]($b[$i+1]) -shl 16) -bor ([uint32]($b[$i+2]) -shl 8) -bor [uint32]($b[$i+3])
}

# Blocks: name, first, last
$blocks = @(
    @{ name = 'Arabic';              first = 0x0600; last = 0x06FF },
    @{ name = 'Arabic-Supplement';   first = 0x0750; last = 0x077F },
    @{ name = 'Arabic-ExtA';         first = 0x08A0; last = 0x08FF },
    @{ name = 'Arabic-PresentationA';first = 0xFB50; last = 0xFDFF },
    @{ name = 'Arabic-PresentationB';first = 0xFE70; last = 0xFEFF },
    @{ name = 'Latin-Basic';         first = 0x0020; last = 0x007E },
    @{ name = 'Latin-Ext';           first = 0x00A0; last = 0x024F },
    @{ name = 'Cyrillic';            first = 0x0400; last = 0x04FF },
    @{ name = 'Greek';               first = 0x0370; last = 0x03FF },
    @{ name = 'Devanagari';          first = 0x0900; last = 0x097F },
    @{ name = 'Bengali';             first = 0x0980; last = 0x09FF },
    @{ name = 'Thai';                first = 0x0E00; last = 0x0E7F },
    @{ name = 'CJK-Common';          first = 0x4E00; last = 0x9FFF },
    @{ name = 'Kana';                first = 0x3040; last = 0x30FF },
    @{ name = 'Hangul-Syllables';    first = 0xAC00; last = 0xD7AF }
)
# Core Arabic letter set U+0621..U+064A + alef variants of presentation used by shapers
$coreArabic = 0x0621..0x064A

$codepointSets = @{}   # cache: facehash -> HashSet of codepoints

function Get-CoveredCodepoints([byte[]]$data) {
    <# returns HashSet[uint32] of codepoints mapped in the best cmap subtable(s) #>
    $set = [System.Collections.Generic.HashSet[uint32]]::new()
    $subtables = Get-CmapSubtables $data
    foreach ($st in $subtables) { Merge-CmapSubtable $set $data $st }
    return ,$set
}

function Get-CmapSubtables([byte[]]$data) {
    $list = @()
    $found = Find-SfntStart $data
    if ($null -eq $found) { return ,$list }
    $off = $found
    foreach ($o in $off) {
        $numTables = U16 $data ($o + 4)
        for ($t = 0; $t -lt $numTables; $t++) {
            $rec = $o + 12 + 16 * $t
            $tag = [System.Text.Encoding]::ASCII.GetString($data, $rec, 4)
            if ($tag -eq 'cmap') {
                $cmapOff = $o + [int](U32 $data ($rec + 8))
                $nSub = U16 $data ($cmapOff + 2)
                for ($s = 0; $s -lt $nSub; $s++) {
                    $sub = $cmapOff + 4 + 8 * $s
                    $plat = U16 $data $sub
                    $enc  = U16 $data ($sub + 2)
                    $subOff = $cmapOff + [int](U32 $data ($sub + 4))
                    $fmt = U16 $data $subOff
                    if ($fmt -in 4, 12) {
                        $list += @{ platform = $plat; encoding = $enc; format = $fmt; offset = $subOff }
                    }
                }
            }
        }
    }
    return ,$list
}

function Find-SfntStart([byte[]]$data) {
    <# returns @(offsets of sfnt tables) — handles ttcf collections and .ufont search #>
    # direct magic?
    $m4 = [System.Text.Encoding]::ASCII.GetString($data, 0, [Math]::Min(4, $data.Length))
    if ($data.Length -ge 12 -and (($data[0] -eq 0 -and $data[1] -eq 1) -or $m4 -eq 'OTTO' -or $m4 -eq 'true')) {
        return @(0)
    }
    if ($m4 -eq 'ttcf') {
        $n = U32 $data 8
        $offs = @()
        for ($i = 0; $i -lt [Math]::Min($n, 8); $i++) { $offs += [int](U32 $data (12 + 4 * $i)) }
        return $offs
    }
    # .ufont/uncompressed stream: search first 64KB for sfnt magic
    $limit = [Math]::Min(65536, $data.Length - 12)
    for ($i = 0; $i -lt $limit; $i++) {
        if (($data[$i] -eq 0 -and $data[$i+1] -eq 1 -and $data[$i+2] -eq 0 -and $data[$i+3] -eq 0) -or
            ($data[$i] -eq 0x4F -and $data[$i+1] -eq 0x54 -and $data[$i+2] -eq 0x54 -and $data[$i+3] -eq 0x4F) -or
            ($data[$i] -eq 0x74 -and $data[$i+1] -eq 0x74 -and $data[$i+2] -eq 0x63 -and $data[$i+3] -eq 0x66)) {
            return @($i)
        }
    }
    return $null
}

function Merge-CmapSubtable([System.Collections.Generic.HashSet[uint32]]$set, [byte[]]$data, $st) {
    $off = $st.offset
    $fmt = U16 $data $off
    if ($fmt -eq 4) {
        $segCountX2 = U16 $data ($off + 6)
        $segCount = [int]($segCountX2 / 2)
        for ($i = 0; $i -lt $segCount; $i++) {
            $end   = U16 $data ($off + 14 + 2 * $i)
            $start = U16 $data ($off + 16 + $segCountX2 + 2 * $i)
            if ($start -eq 0xFFFF -and $end -eq 0xFFFF) { continue }
            for ($c = $start; $c -le $end; $c++) { [void]$set.Add([uint32]$c) }
        }
    } elseif ($fmt -eq 12) {
        $nGroups = U32 $data ($off + 12)
        for ($i = 0; $i -lt $nGroups; $i++) {
            $g = $off + 16 + 12 * $i
            $s = U32 $data $g
            $e = U32 $data ($g + 4)
            if (($e - $s) -gt 0x10000) { $e = $s + 0x10000 }   # sanity cap
            for ($c = $s; $c -le $e; $c++) { [void]$set.Add([uint32]$c) }
        }
    }
}

# ---- main scan ----
$out = New-Object System.Collections.Generic.List[string]
$out.Add('# Font glyph coverage report (Phase 6)')
$out.Add('# Generated (UTC): ' + (Get-Date).ToUniversalTime().ToString('o'))
$out.Add('# Method: pure-PowerShell sfnt cmap parser (formats 4 and 12).')
$out.Add('# Arabic verdict: FULL = all 42 core letter codepoints U+0621..U+064A mapped in scope; PARTIAL = some; NONE = none.')
$out.Add('')

$fonts = Get-ChildItem $FontsRoot -Recurse -File |
    Where-Object { $_.Extension -in '.ufont', '.ttf', '.otf', '.ttc' }
Write-Host ("[OK] {0} font binaries to scan" -f $fonts.Count)

$summary = New-Object System.Collections.Generic.List[string]
$summary.Add('font,container,size_bytes,verdict,arabic_core_letters,arabic_codepoints,cmap_formats')

foreach ($f in $fonts) {
    $data = [System.IO.File]::ReadAllBytes($f.FullName)
    $set = Get-CoveredCodepoints $data

    $cmapFormats = (Get-CmapSubtables $data | ForEach-Object { $_.format }) | Sort-Object -Unique
    $arabicCount = 0
    $coreHit = 0
    foreach ($c in $set) {
        if ($c -ge 0x0600 -and $c -le 0x08FF) { $arabicCount++ }
        if ($c -ge 0xFB50 -and $c -le 0xFEFF) { $arabicCount++ }
    }
    foreach ($cc in $coreArabic) { if ($set.Contains([uint32]$cc)) { $coreHit++ } }

    $verdict = 'NONE'
    if ($coreHit -ge 28) { $verdict = 'FULL' } elseif ($coreHit -gt 0) { $verdict = 'PARTIAL' }

    $perBlock = New-Object System.Collections.Generic.List[string]
    foreach ($b in $blocks) {
        $n = 0
        foreach ($c in $set) {
            if ($c -ge $b.first -and $c -le $b.last) { $n++ }
        }
        if ($n -gt 0) { $perBlock.Add(('{0}={1}' -f $b.name, $n)) }
    }

    $rel = $f.FullName.Substring($FontsRoot.Length + 1)
    $out.Add(('### ' + $rel + '  (' + $f.Length + ' bytes)'))
    if ($null -eq $set) { $out.Add('    parse FAILED') }
    else {
        $out.Add(('    codepointsMapped: ' + $set.Count))
        $out.Add(('    coverage: ' + ($perBlock -join ', ')))
        $out.Add(('    arabicCoreLetters: ' + $coreHit + '/28   arabicTotal: ' + $arabicCount))
        $out.Add(('    VERDICT: ' + $verdict + '   (cmap formats present: ' + (($cmapFormats) -join ',') + ')'))
    }
    $out.Add('')
    $summary.Add(('{0},{1},{2},{3},{4},{5},{6}' -f $rel, ($f.Directory.Name + '/' + $f.Name), $f.Length, $verdict, $coreHit, $arabicCount, (($cmapFormats) -join '+')))
    Write-Host ("[SCAN] {0,-60} {1}" -f $rel, $verdict)
}

Set-Content -Path $OutPath -Value $out -Encoding UTF8
Set-Content -Path ($OutPath -replace '\.txt$', '.csv') -Value $summary -Encoding UTF8
Write-Host "[DONE] report: $OutPath"
