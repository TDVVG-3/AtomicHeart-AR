<#
.SYNOPSIS
  Glyph gate (DEC-023 step 6): proves that every character used by the translated
  master rows (Arabic + the Latin inside tags/keys) is present in the font faces that
  the font pak v2 installs, with special attention to the SUBTITLE face.

.DESCRIPTION
  Faces replaced by zzz_atomicheart-ar_font_p2_plex_P.pak (build\staging\font_p2\modpakfont):
      UI\Fonts\BlenderPro-Medium.ufont    <- subtitle/dialogue typing widget face
      UI\Fonts\BlenderPro-Book.ufont
      UI\Fonts\BlenderPro-Bold.ufont
      UI\Fonts\BrutalType.ufont
      NTD\Fonts\Gotham-Black.ufont
      NTD\Fonts\Gotham-BookItalic.ufont
  The parser is a pure-PowerShell sfnt cmap reader (formats 4 and 12).

  Checks:
    1. every distinct codepoint in the master Arabic column is inside the SUBTITLE face
    2. ... and inside each of the six installed faces (a union is not HUD coverage)
    3. Latin-Basic (U+0020..U+007E) is complete in the subtitle face (tags/keys/numbers)
    4. report Cyrillic / Hangul presence per face (informational: those scripts are served
       by the engine fallback face, not by these payloads)

  Output: reports/glyph_gate.md + console summary. Exit 2 on FAIL.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$MasterTsV = '',
    [string]$PayloadRoot = '',
    [string]$ReportPath = '',
    # Exempt codepoints that the translation INHERITED from the English source of the same
    # row (for example the Cyrillic A in "Workshop 308-A" or the Cyrillic x in "12x70
    # rounds"): the engine serves those from its fallback face today, so they are not a
    # new requirement introduced by the Arabic. Codepoints absent from the font AND absent
    # from the source still fail. DEC-027.
    [switch]$AllowSourceInheritedNonLatin
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

if (-not $MasterTsV) { $MasterTsV = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv' }
if (-not $PayloadRoot) { $PayloadRoot = Join-Path $RepoRoot 'build\staging\font_p2\modpakfont' }
$payloadRoot = $PayloadRoot
if (-not $ReportPath) { $ReportPath = Join-Path $RepoRoot 'reports\glyph_gate.md' }
$reportPath = $ReportPath

$faces = @(
    @{ name = 'BlenderPro-Medium (subtitle/dialogue)'; rel = 'AtomicHeart\Content\Development\UI\Fonts\BlenderPro-Medium.ufont'; subtitle = $true },
    @{ name = 'BlenderPro-Book'; rel = 'AtomicHeart\Content\Development\UI\Fonts\BlenderPro-Book.ufont'; subtitle = $false },
    @{ name = 'BlenderPro-Bold'; rel = 'AtomicHeart\Content\Development\UI\Fonts\BlenderPro-Bold.ufont'; subtitle = $false },
    @{ name = 'BrutalType'; rel = 'AtomicHeart\Content\Development\UI\Fonts\BrutalType.ufont'; subtitle = $false },
    @{ name = 'Gotham-Black'; rel = 'AtomicHeart\Content\Development\NTD\Fonts\Gotham-Black.ufont'; subtitle = $false },
    @{ name = 'Gotham-BookItalic'; rel = 'AtomicHeart\Content\Development\NTD\Fonts\Gotham-BookItalic.ufont'; subtitle = $false }
)

function U16([byte[]]$b, [int]$i) { ([uint16]($b[$i]) -shl 8) -bor [uint16]($b[$i+1]) }
function U32([byte[]]$b, [int]$i) {
    ([uint32]($b[$i]) -shl 24) -bor ([uint32]($b[$i+1]) -shl 16) -bor ([uint32]($b[$i+2]) -shl 8) -bor [uint32]($b[$i+3])
}
function Get-CmapSet([string]$path) {
    $bytes = [IO.File]::ReadAllBytes($path)
    $set = New-Object 'System.Collections.Generic.HashSet[int]'
    $numTables = U16 $bytes 4
    $cmapOff = -1
    for ($t = 0; $t -lt $numTables; $t++) {
        $rec = 12 + 16 * $t
        $tag = [Text.Encoding]::ASCII.GetString($bytes, $rec, 4)
        if ($tag -eq 'cmap') { $cmapOff = U32 $bytes ($rec + 8) }
    }
    if ($cmapOff -lt 0) { throw "no cmap table in $path" }
    $nSub = U16 $bytes ($cmapOff + 2)
    $best = -1; $bestScore = -1
    for ($s = 0; $s -lt $nSub; $s++) {
        $o = $cmapOff + 4 + 8 * $s
        $platID = U16 $bytes $o
        $encID = U16 $bytes ($o + 2)
        $sub = $cmapOff + (U32 $bytes ($o + 4))
        $fmt = U16 $bytes $sub
        $score = -1
        if ($platID -eq 3 -and $encID -eq 10 -and $fmt -eq 12) { $score = 100 }
        elseif ($platID -eq 3 -and $encID -eq 1 -and $fmt -eq 4) { $score = 90 }
        elseif ($platID -eq 0 -and $fmt -eq 12) { $score = 80 }
        elseif ($platID -eq 0 -and $fmt -eq 4) { $score = 70 }
        if ($score -gt $bestScore) { $bestScore = $score; $best = $sub }
    }
    if ($best -lt 0) { throw "no usable cmap subtable in $path" }
    $fmt = U16 $bytes $best
    if ($fmt -eq 4) {
        $segX2 = U16 $bytes ($best + 6)
        $segCount = $segX2 / 2
        $endBase = $best + 14
        $startBase = $endBase + $segX2 + 2
        $deltaBase = $startBase + $segX2
        $rangeBase = $deltaBase + $segX2
        for ($seg = 0; $seg -lt $segCount; $seg++) {
            $end = U16 $bytes ($endBase + 2 * $seg)
            $start = U16 $bytes ($startBase + 2 * $seg)
            if ($start -eq 0xFFFF) { continue }
            $idDelta = U16 $bytes ($deltaBase + 2 * $seg)
            $idRangeOffset = U16 $bytes ($rangeBase + 2 * $seg)
            for ($c = $start; $c -le $end; $c++) {
                $gid = 0
                if ($idRangeOffset -eq 0) {
                    $gid = ($c + $idDelta) -band 0xFFFF
                } else {
                    $addr = $rangeBase + 2 * $seg + $idRangeOffset + 2 * ($c - $start)
                    if ($addr + 1 -lt $bytes.Length) {
                        $g = U16 $bytes $addr
                        if ($g -ne 0) { $gid = ($g + $idDelta) -band 0xFFFF }
                    }
                }
                if ($gid -ne 0) { [void]$set.Add([int]$c) }
            }
        }
    } elseif ($fmt -eq 12) {
        $nGroups = U32 $bytes ($best + 12)
        for ($g = 0; $g -lt $nGroups; $g++) {
            $o = $best + 16 + 12 * $g
            $s0 = U32 $bytes $o
            $e0 = U32 $bytes ($o + 4)
            $gid0 = U32 $bytes ($o + 8)
            for ($c = $s0; $c -le $e0; $c++) {
                if (($c - $s0 + $gid0) -ne 0) { [void]$set.Add([int]$c) }
            }
        }
    } else { throw "unsupported cmap format $fmt in $path" }
    return $set
}

function Get-Codepoints([string]$text) {
    for ($index = 0; $index -lt $text.Length; $index++) {
        $cp = [char]::ConvertToUtf32($text, $index)
        $cp
        if ($cp -gt 0xFFFF) { $index++ }
    }
}

# --- codepoints used by the translated master rows
$lines = [IO.File]::ReadAllLines($MasterTsV, [Text.Encoding]::UTF8)
$usedAr = New-Object 'System.Collections.Generic.HashSet[int]'
$introduced = New-Object 'System.Collections.Generic.HashSet[int]'
$introducedAt = @{}
$rowsWithArabic = 0
$distinctCodepoints = @{}
for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    if (-not $f[6].Trim()) { continue }
    $rowsWithArabic++
    $rowSource = New-Object 'System.Collections.Generic.HashSet[int]'
    foreach ($cp in (Get-Codepoints $f[5])) { [void]$rowSource.Add($cp) }
    foreach ($cp in (Get-Codepoints $f[6])) {
        [void]$usedAr.Add($cp)
        if (-not $distinctCodepoints.ContainsKey($cp)) {
            $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
            $distinctCodepoints[$cp] = [pscustomobject]@{ scope = $scope; key = $f[4]; sample = $f[6] }
        }
    }
    foreach ($cp in (Get-Codepoints $f[6])) {
        if (-not $rowSource.Contains($cp)) {
            [void]$introduced.Add($cp)
            if (-not $introducedAt.ContainsKey($cp)) { $introducedAt[$cp] = [pscustomobject]@{ scope = $f[2]; key = $f[4] } }
        }
    }
}

$results = New-Object System.Collections.Generic.List[object]
$union = New-Object 'System.Collections.Generic.HashSet[int]'
$subtitleMissing = $null
foreach ($face in $faces) {
    $p = Join-Path $payloadRoot $face.rel
    if (-not (Test-Path $p)) { throw "payload face missing: $p" }
    $set = Get-CmapSet $p
    foreach ($cp in $set) { [void]$union.Add($cp) }
    $missing = New-Object System.Collections.Generic.List[int]
    foreach ($cp in $usedAr) { if (-not $set.Contains($cp)) { $missing.Add($cp) } }
    $latinMissing = 0
    for ($cp = 0x20; $cp -le 0x7E; $cp++) { if (-not $set.Contains($cp)) { $latinMissing++ } }
    $cyr = 0; for ($cp = 0x0410; $cp -le 0x044F; $cp++) { if ($set.Contains($cp)) { $cyr++ } }
    $han = 0; for ($cp = 0xAC00; $cp -le 0xAC00 + 500; $cp++) { if ($set.Contains($cp)) { $han++ } }
    $results.Add([pscustomobject]@{
        face = $face.name; subtitle = $face.subtitle; file = $face.rel
        mapped = $set.Count; missing = $missing.Count; latinMissing = $latinMissing
        cyrillic = $cyr; hangulSample = $han; missingList = $missing
    })
    if ($face.subtitle) { $subtitleMissing = $missing }
}
$unionMissing = New-Object System.Collections.Generic.List[int]
foreach ($cp in $usedAr) { if (-not $union.Contains($cp)) { $unionMissing.Add($cp) } }

# Split the missing codepoints: those that the English source of the same row already needs
# (the engine fallback serves them today) vs codepoints the Arabic introduced on its own.
$allMissing = New-Object 'System.Collections.Generic.HashSet[int]'
foreach ($cp in $unionMissing) { [void]$allMissing.Add($cp) }
foreach ($faceResult in $results) {
    foreach ($cp in $faceResult.missingList) { [void]$allMissing.Add($cp) }
}
$sourceInherited = New-Object System.Collections.Generic.List[int]
$realMissing = New-Object System.Collections.Generic.List[int]
foreach ($cp in $allMissing) {
    if ($cp -gt 0x7F -and -not $introduced.Contains($cp)) { $sourceInherited.Add($cp) }
    else { $realMissing.Add($cp) }
}
$sourceInherited.Sort(); $realMissing.Sort()

$verdict = 'PASS'
if ($realMissing.Count -gt 0 -or @($results | Where-Object { $_.latinMissing -gt 0 }).Count -gt 0) { $verdict = 'FAIL' }
elseif ($sourceInherited.Count -gt 0 -and -not $AllowSourceInheritedNonLatin) { $verdict = 'FAIL' }

$r = New-Object System.Collections.Generic.List[string]
$r.Add('# Glyph gate report (pilot)' )
$r.Add('')
$r.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$r.Add(('Font payload under test: `{0}`' -f $payloadRoot))
$r.Add(('Master: {0} ({1} rows with Arabic)' -f $MasterTsV, $rowsWithArabic))
$r.Add('')
$r.Add(('VERDICT: **{0}**' -f $verdict))
$r.Add('')
$r.Add(('Distinct codepoints used by the translated rows: {0}' -f $usedAr.Count))
$r.Add(('Codepoints missing from the subtitle face: {0}' -f $subtitleMissing.Count))
$r.Add(('Codepoints missing from the union of all six installed faces: {0}' -f $unionMissing.Count))
$r.Add(('Codepoints missing from any replacement face: {0}' -f $allMissing.Count))
$r.Add(('Of those, non-Latin source-inherited in EVERY translated occurrence: {0}' -f $sourceInherited.Count))
$r.Add(('Codepoints newly required by the Arabic and missing from the font: {0}' -f $realMissing.Count))
$r.Add(('Source-inherited exemption switch: {0}' -f $(if ($AllowSourceInheritedNonLatin) { 'ON (-AllowSourceInheritedNonLatin)' } else { 'off' })))
$r.Add('')
$r.Add('| face | mapped codepoints | missing (pilot chars) | Latin-Basic missing | Cyrillic | Hangul sample |')
$r.Add('|---|---|---|---|---|---|')
foreach ($x in $results) {
    $r.Add(('| {0}{1} | {2} | {3} | {4} | {5} | {6} |' -f $x.face, $(if ($x.subtitle) { ' **(subtitle)**' } else { '' }), $x.mapped, $x.missing, $x.latinMissing, $x.cyrillic, $x.hangulSample))
}
$r.Add('')
if ($allMissing.Count -gt 0) {
    $r.Add('## Missing codepoints')
    $r.Add('')
    foreach ($cp in ($allMissing | Sort-Object)) {
        $d = if ($introducedAt.ContainsKey($cp)) { $introducedAt[$cp] } else { $distinctCodepoints[$cp] }
        $kind = if ($sourceInherited.Contains($cp)) { 'source-inherited in every occurrence' } else { 'REQUIRED / NOT EXEMPT' }
        $r.Add(('- U+{0:X4} ({1}) first seen in {2} key {3}' -f $cp, $kind, $d.scope, $d.key))
    }
    $r.Add('')
}
$r.Add('## Notes')
$r.Add('')
$r.Add('- Source-inherited exemptions require runtime fallback. The recorded Korean test does')
$r.Add('  not prove fallback for every Cyrillic/Japanese character, widget or game version.')
$r.Add('- Every replacement face must cover Latin-Basic. A missing character in any face is checked;')
$r.Add('  the union of faces does not prove that the HUD can draw it. Source exemptions are per row.')
$r.Add('- PASS with exemptions does not verify engine fallback, shaping, bidi ordering, or layout at runtime.')
$r.Add('')
[IO.File]::WriteAllLines($reportPath, $r, (New-Object Text.UTF8Encoding($false)))

Write-Output ('GLYPH GATE {0}: rows with Arabic {1} | distinct codepoints {2} | subtitle-face missing {3} | union missing {4} | source-inherited {5} | introduced-by-Arabic {6}' -f $verdict, $rowsWithArabic, $usedAr.Count, $subtitleMissing.Count, $unionMissing.Count, $sourceInherited.Count, $realMissing.Count)
foreach ($x in $results) {
    Write-Output ('  {0,-40} mapped={1,-6} missing={2,-3} latinMissing={3,-3} cyrillic={4,-4} hangulSample={5}' -f $x.face, $x.mapped, $x.missing, $x.latinMissing, $x.cyrillic, $x.hangulSample)
}
foreach ($cp in $unionMissing) { Write-Output ('  MISSING U+{0:X4}' -f $cp) }
Write-Output ('report: ' + $reportPath)
if ($verdict -eq 'FAIL') { exit 2 }
