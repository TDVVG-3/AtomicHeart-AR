<#
.SYNOPSIS
  Cycle 005 evidence: explicit codepoint-count probe for chosen Unicode blocks on
  font files (default: the installed IBM Plex Sans Arabic payloads + the game's
  original faces). Uses the same pure-PowerShell cmap parser as font_glyph_scan.ps1.
  Output: reports/font_block_probe.txt + console.
#>
[CmdletBinding()]
param(
    [string[]]$Fonts,
    [string]$OutPath = 'C:\AtomicHeart-AR\reports\font_block_probe.txt'
)
$ErrorActionPreference = 'Stop'
if (-not $Fonts) {
    $Fonts = @(
        'C:\AtomicHeart-AR\source\original\fonts\downloaded\IBMPlexSansArabic-Regular.ttf',
        'C:\AtomicHeart-AR\source\original\fonts\downloaded\IBMPlexSansArabic-Medium.ttf',
        'C:\AtomicHeart-AR\source\original\fonts\downloaded\IBMPlexSansArabic-Bold.ttf'
    )
}

function U16([byte[]]$b, [int]$i) { ([uint16]($b[$i]) -shl 8) -bor [uint16]($b[$i+1]) }
function U32([byte[]]$b, [int]$i) {
    ([uint32]($b[$i]) -shl 24) -bor ([uint32]($b[$i+1]) -shl 16) -bor ([uint32]($b[$i+2]) -shl 8) -bor [uint32]($b[$i+3])
}
function Find-SfntStart([byte[]]$data) {
    $m4 = [System.Text.Encoding]::ASCII.GetString($data, 0, [Math]::Min(4, $data.Length))
    if ($data.Length -ge 12 -and (($data[0] -eq 0 -and $data[1] -eq 1) -or $m4 -eq 'OTTO' -or $m4 -eq 'true')) { return @(0) }
    if ($m4 -eq 'ttcf') {
        $n = U32 $data 8
        $offs = @()
        for ($i = 0; $i -lt [Math]::Min($n, 8); $i++) { $offs += [int](U32 $data (12 + 4 * $i)) }
        return $offs
    }
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
function Get-CoveredCodepoints([byte[]]$data) {
    $set = [System.Collections.Generic.HashSet[uint32]]::new()
    $offs = Find-SfntStart $data
    foreach ($o in $offs) {
        $numTables = U16 $data ($o + 4)
        for ($t = 0; $t -lt $numTables; $t++) {
            $rec = $o + 12 + 16 * $t
            $tag = [System.Text.Encoding]::ASCII.GetString($data, $rec, 4)
            if ($tag -eq 'cmap') {
                $cmapOff = $o + [int](U32 $data ($rec + 8))
                $nSub = U16 $data ($cmapOff + 2)
                for ($s = 0; $s -lt $nSub; $s++) {
                    $sub = $cmapOff + 4 + 8 * $s
                    $subOff = $cmapOff + [int](U32 $data ($sub + 4))
                    $fmt = U16 $data $subOff
                    if ($fmt -eq 4) {
                        $segCountX2 = U16 $data ($subOff + 6)
                        $segCount = [int]($segCountX2 / 2)
                        for ($i = 0; $i -lt $segCount; $i++) {
                            $end   = U16 $data ($subOff + 14 + 2 * $i)
                            $start = U16 $data ($subOff + 16 + $segCountX2 + 2 * $i)
                            if ($start -eq 0xFFFF -and $end -eq 0xFFFF) { continue }
                            for ($c = $start; $c -le $end; $c++) { [void]$set.Add([uint32]$c) }
                        }
                    } elseif ($fmt -eq 12) {
                        $nGroups = U32 $data ($subOff + 12)
                        for ($i = 0; $i -lt $nGroups; $i++) {
                            $g = $subOff + 16 + 12 * $i
                            $s0 = U32 $data $g
                            $e0 = U32 $data ($g + 4)
                            if (($e0 - $s0) -gt 0x10000) { $e0 = $s0 + 0x10000 }
                            for ($c = $s0; $c -le $e0; $c++) { [void]$set.Add([uint32]$c) }
                        }
                    }
                }
            }
        }
    }
    return ,$set
}

$blocks = @(
    @{ name = 'Latin-Basic';      first = 0x0020; last = 0x007E },
    @{ name = 'Cyrillic';         first = 0x0400; last = 0x04FF },
    @{ name = 'Hangul-Syllables'; first = 0xAC00; last = 0xD7AF },
    @{ name = 'Hangul-Jamo';      first = 0x1100; last = 0x11FF },
    @{ name = 'Arabic-core';      first = 0x0621; last = 0x064A }
)
$our = New-Object System.Collections.Generic.List[string]
$our.Add('# Font block probe (cycle 005)')
$our.Add('# Generated (UTC): ' + (Get-Date).ToUniversalTime().ToString('o'))
foreach ($f in $Fonts) {
    if (-not (Test-Path $f)) { throw "font missing: $f" }
    $data = [IO.File]::ReadAllBytes($f)
    $set = Get-CoveredCodepoints $data
    $our.Add(('### ' + (Split-Path $f -Leaf) + '  (' + (Get-Item $f).Length + ' bytes)'))
    foreach ($b in $blocks) {
        $n = 0
        foreach ($c in $set) { if ($c -ge $b.first -and $c -le $b.last) { $n++ } }
        $verdict = 'ABSENT'
        if ($n -gt 0) {
            if ($b.name -eq 'Arabic-core') { $verdict = if ($n -ge 42) { 'FULL' } else { 'PARTIAL' } }
            elseif ($b.name -eq 'Latin-Basic') { $verdict = if ($n -ge 95) { 'FULL' } else { 'PARTIAL' } }
            else { $verdict = 'COVERED' }
        }
        $our.Add(('    {0}: {1}   [{2}]' -f $b.name, $n, $verdict))
    }
    $our.Add('')
}
Set-Content -Path $OutPath -Value $our -Encoding UTF8
Get-Content $OutPath | ForEach-Object { Write-Host $_ }
Write-Host "[DONE] $OutPath"
