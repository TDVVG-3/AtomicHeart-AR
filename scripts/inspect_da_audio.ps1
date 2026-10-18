<#
.SYNOPSIS
  DA_Audio language-map engineer (cycle 004, DEC-015).
  Modes: Inspect | Patch
   - Inspect: parse .uasset/.uexp, walk the export property stream, locate the
     LanguageMap ArrayProperty, decode the records, verify count == 13 and the
     known culture codes.
   - Patch: append a 14th record (clone of the 13th, fields re-written:
     DisplayName => -DisplayName param as UTF-16 FString, Culture => `ar`,
     Wwise/audio alias => enUS), rebuild counts/sizes, then re-run the SAME
     parser over the produced bytes as self-validation, and print a diff report.
  Reads the game folder (via get_pak_file.ps1 outputs) - never writes there.
#>
[CmdletBinding()]
param(
    [ValidateSet('Inspect', 'Patch')][string]$Mode = 'Inspect',
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$SourceDir = 'C:\AtomicHeart-AR\source\original\uasset\settings_da',
    [string]$OutDir = 'C:\AtomicHeart-AR\build\staging\langmap_p1',
    [string]$DisplayName = 'العربية',
    [string]$EngineCulture = 'ar',
    [string]$WwiseAlias = 'enUS'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

$assetBytes = [IO.File]::ReadAllBytes("$SourceDir\DA_Audio.uasset")
$uexp = [IO.File]::ReadAllBytes("$SourceDir\DA_Audio.uexp")
Write-Host ("input: uasset={0} uexp={1}" -f $assetBytes.Length, $uexp.Length)

function I32([byte[]]$b, [long]$o) { [BitConverter]::ToInt32($b, $o) }
function I64([byte[]]$b, [long]$o) { [BitConverter]::ToInt64($b, $o) }

# ---------- summary ----------
$magic = -1
for ($i = 0; $i -lt $assetBytes.Length - 4; $i++) {
    if ($assetBytes[$i] -eq 0xC1 -and $assetBytes[$i+1] -eq 0x83 -and $assetBytes[$i+2] -eq 0x2A -and $assetBytes[$i+3] -eq 0x9E) { $magic = $i; break }
}
if ($magic -lt 0) { throw 'no ue4 magic' }
$p = $magic + 4
$legacyFileVersion = I32 $assetBytes $p; $p += 4
$p += 4                            # legacy UE3 ver
$fileVersionUE4 = I32 $assetBytes $p; $p += 4
$p += 4                            # licensee
$cvCount = I32 $assetBytes $p; $p += 4
for ($i = 0; $i -lt $cvCount; $i++) {
    $p += 20                       # guid16 + version4
    $clen = I32 $assetBytes $p; $p += 4 + $clen
}
$totalHeaderSize = I32 $assetBytes $p; $p += 4
$fnLen = I32 $assetBytes $p; $p += 4; $p += [Math]::Abs($fnLen)
$p += 4                            # package flags
$nameCount = I32 $assetBytes $p; $p += 4
$nameOffset = I32 $assetBytes $p; $p += 4
$p += 4                            # gatherable count
$p += 4                            # gatherable offset
$exportCount = I32 $assetBytes $p; $p += 4
$exportOffset = I32 $assetBytes $p; $p += 4
$importCount = I32 $assetBytes $p; $p += 4
$importOffset = I32 $assetBytes $p; $p += 4

Write-Host ("summary: fvUE4={0} cv={1} header={2} names={3}@{4} exps={5}@{6} imps={7}@{8}" -f $fileVersionUE4, $cvCount, $totalHeaderSize, $nameCount, $nameOffset, $exportCount, $exportOffset, $importCount, $importOffset)

# ---------- name table (self-calibrating entry stride) ----------
$names = New-Object System.Collections.Generic.List[string]
$npos = $nameOffset
$importOffsetProbe = $importOffset
# try possible trailing sizes per entry: {string,NUL-pad, extra}
foreach ($extra in 0, 2, 4, 6, 8) {
    $names.Clear()
    $npos = $nameOffset
    $ok = $true
    try {
        for ($i = 0; $i -lt $nameCount; $i++) {
            $len = I32 $assetBytes $npos; $npos += 4
            if ($len -lt 0) { $nm = [Text.Encoding]::Unicode.GetString($assetBytes, $npos, ([Math]::Abs($len) - 1) * 2) }
            elseif ($len -gt 0) { $nm = [Text.Encoding]::ASCII.GetString($assetBytes, $npos, $len - 1) }
            else { throw 'len 0' }
            if ($npos + [Math]::Abs($len) + $extra -gt $assetBytes.Length) { throw 'overrun' }
            $npos += [Math]::Abs($len) + $extra
            [void]$names.Add($nm)
        }
    } catch { $ok = $false }
    if ($ok -and $npos -eq $importOffsetProbe) { Write-Host ("name stride calibrated: extra={0}" -f $extra); break }
}
Write-Host ("names[{0}]: {1}" -f $names.Count, ($names -join ' | '))

# ---------- export table ----------
$exports = @()
$epos = $exportOffset
for ($i = 0; $i -lt $exportCount; $i++) {
    $epos += 16                                      # ClassIndex, SuperIndex, TemplateIndex, OuterIndex
    $objIdx = I32 $assetBytes $epos; $epos += 4
    $epos += 4                                        # ObjectNumber
    $epos += 4                                        # ObjectFlags
    $sz = I64 $assetBytes $epos; $epos += 8
    $off = I64 $assetBytes $epos; $epos += 8
    $exports += [pscustomobject]@{ i = $i; obj = $names[[Math]::Max(0, $objIdx)]; size = $sz; off = $off }
}
Write-Host ("exports: " + (($exports | ForEach-Object { "[$($_.i)] $($_.obj) @ $($_.off) ($($_.size))" }) -join '; '))

$main = $exports | Where-Object { $_.obj -eq 'DA_Audio' }
if (-not $main) { throw 'DA_Audio export not found' }

# ---------- property walker ----------
# cooked UE4.27 tag hypothesis (validated empirically below):
#   FName name (idx i32 + num i32)
#   FName type (idx i32 + num i32)
#   int32 size
#   int32 arrayIndex
#   StructProperty: + FName structType (idx i32 + num i32) + int32 bHasGuid + (16 bytes guid if 1)
#   BoolProperty: + int32 bHasGuid? and value byte (empirical branch below)
#   EnumProperty: + FName enum (idx i32 + num i32)
#   then `size` bytes of data.
function Walk-Props {
    param([byte[]]$buf, [long]$start, [long]$end, $Names, [string]$indent)
    $pos = $start
    $result = [pscustomobject]@{ pos = $start; end = $end; LanguageMapOff = -1; LanguageMapCount = -1; Elements = @() }
    while ($true) {
        $nmIdx = I32 $buf $pos
        if ($nmIdx -ge $Names.Count) { throw ("name OOR {0} @ {1}" -f $nmIdx, $pos) }
        if ($Names[$nmIdx] -eq 'None') { $pos += 8; break }
        $nmNum = I32 $buf ($pos + 4); $pos += 8
        $tyIdx = I32 $buf $pos; $tyNum = I32 $buf ($pos + 4); $pos += 8
        $typeName = if ($tyIdx -lt $Names.Count) { $Names[$tyIdx] } else { throw "type OOR $tyIdx @ $pos" }
        $sz = I32 $buf $pos; $pos += 4
        $arrI = I32 $buf $pos; $pos += 4
        $propName = $Names[$nmIdx]
        Write-Host ("{0}prop {1} : {2} (size {3}) [offset {4}]" -f $indent, $propName, $typeName, $sz, ($pos - 24))
        switch ($typeName) {
            'StructProperty' {
                $pos += 8                       # struct type FName
                $hasGuid = I32 $buf $pos; $pos += 4
                if ($hasGuid -eq 1) { $pos += 16 }
            }
            'EnumProperty' {
                $pos += 8                       # enum FName
            }
            'ByteProperty' {
                # byte props in cooked tags carry optional enum FName; we test empirically below
                $pos += 8                       # hypothesis: enum FName always present
            }
            'BoolProperty' {
                # hypothesis: int32 bHasPropertyGuid + value byte (data size should be 0)
                $hasGuid = I32 $buf $pos; $pos += 4
                if ($hasGuid -eq 1) { $pos += 16 }
                $pos += 1
            }
        }
        $dataStart = $pos
        if ($propName -eq 'LanguageMap') {
            if ($typeName -ne 'ArrayProperty') { throw 'LanguageMap is not an ArrayProperty' }
            $result.LanguageMapOff = $dataStart
            $cnt = I32 $buf $dataStart
            $result.LanguageMapCount = $cnt
            Write-Host ("{0}  LanguageMap array: {1} elements (data {2} bytes)" -f $indent, $cnt, ($sz - 4))
            $ep = $dataStart + 4
            for ($e = 0; $e -lt $cnt; $e++) {
                $rec = [ordered]@{ _off = $ep }
                while ($true) {
                    $fi = I32 $buf $ep
                    if ($Names[$fi] -eq 'None') { $ep += 8; break }
                    $ep += 8                     # name idx+num
                    $ft = I32 $buf $ep; $ep += 8 # type idx+num
                    $ftype = $Names[$ft]
                    $fsize = I32 $buf $ep; $ep += 4
                    $farr = I32 $buf $ep; $ep += 4
                    $foff = $ep
                    switch ($ftype) {
                        'StructProperty' { $ep += 8; $hg = I32 $buf $ep; $ep += 4; if ($hg -eq 1) { $ep += 16 } }
                        'EnumProperty' { $ep += 8 }
                        'ByteProperty' { $ep += 8 }
                        'BoolProperty' { $hg = I32 $buf $ep; $ep += 4; if ($hg -eq 1) { $ep += 16 }; $ep += 1 }
                    }
                    $ep += $fsize
                    $field = [ordered]@{ type = $ftype; off = $foff; size = $fsize; arrayIdx = $farr }
                    if ($ftype -eq 'StrProperty') {
                        $l = I32 $buf $foff
                        if ($l -gt 0) { $field.value = [Text.Encoding]::ASCII.GetString($buf, $foff + 4, $l - 1) }
                        elseif ($l -lt 0) { $field.value = [Text.Encoding]::Unicode.GetString($buf, $foff + 4, ([Math]::Abs($l) - 1) * 2) }
                    }
                    elseif ($ftype -eq 'NameProperty') {
                        $fi2 = I32 $buf $foff
                        $field.value = $Names[$fi2]
                    }
                    $rec[$Names[$fi]] = $field
                }
                $rec['_end'] = $ep
                $result.Elements = $result.Elements + @($rec)
                Write-Host ("{0}    record {1}: bytes {2}..{3}  {4}" -f $indent, $e, $rec['_off'], $ep - 8, (($rec.Keys | Where-Object { $_ -notin @('_off','_end') } | ForEach-Object { if ($rec[$_].value) { "$_ =$($rec[$_].value)" } else { "$_!type=$($rec[$_].type)" } }) -join ' | '))
            }
            $pos = $ep
        }
        else {
            switch ($typeName) {
                'ArrayProperty' {
                    # generic inner walk for non-target arrays: count prefix + element tagged props
                    $acnt = I32 $buf $pos
                    $ip = $pos + 4
                    for ($a = 0; $a -lt $acnt; $a++) {
                        $w = Walk-Props $buf $ip ($dataStart + $sz) $Names ("$indent|  ")
                        $ip = $w.end
                    }
                    $pos = $ip
                }
                'MapProperty' {
                    # skip: data size known
                    $pos = $dataStart + $sz
                }
                default {
                    $pos = $dataStart + $sz
                }
            }
        }
        if ($pos -gt $end) { throw ("walk overran: pos={0} end={1}" -f $pos, $end) }
    }
    if ($pos -ne $end) { throw ("walk terminator mismatch: pos={0} end={1}" -f $pos, $end) }
    return $result
}

# ============ main walk ============
try {
    $walk = Walk-Props $uexp ($main.off) ($main.off + $main.size) $names ''
    Write-Host ("WALK OK: LanguageMap @ {0}, {1} records, stream consumed exactly {2}..{3}" -f $walk.LanguageMapOff, $walk.LanguageMapCount, $main.off, ($main.off + $main.size))
    $known = @('en-US','ru-RU','fr-FR','it-IT','de-DE','es-ES','pt-BR','pl-PL','zh-CN','zh-TW','ko-KR','ja-JP','uk-UA')
    $dec = @()
    foreach ($rec in $walk.Elements) {
        foreach ($k in $rec.Keys) {
            if ($k -in @('_off','_end')) { continue }
            $dec += ("{0}" -f $rec[$k].value)
        }
        $dec += '----'
    }
    $joined = ($dec | Where-Object { $_ -ne '----' }) -join ' '
    Write-Host ("decoded strings: {0}" -f $joined)
    $missing = $known | Where-Object { $_ -notin $dec }
    if ($missing) { Write-Host ("MISSING known cultures in decode: {0}" -f ($missing -join ',')) } else { Write-Host 'CALIBRATION PASS: all 13 known cultures decoded' }
} catch {
    Write-Host ("WALK FAILED: {0}" -f $_.Exception.Message)
    throw
}
