<#
.SYNOPSIS
  Dialogue program - Phase A (v2, uexp-only): string-count pass over the in-scope
  cooked dialogue/cutscene candidate assets (reports/dialogue_inventory_raw/st_scope.txt).

.DESCRIPTION
  For every candidate: fetch ONLY the .uexp from its pak (READ-ONLY game access into
  source/original/uasset/dlg/, gitignored), then:
   - scope class from the path pattern (StringTable / LevelSequence-ish / other),
   - string extraction from the .uexp with a CORRECT byte-level UTF-16LE decoder
     (previous dumps destroyed Cyrillic; this writer is UTF-8 and lossless),
   - per-asset counts (utf16/ascii strings, hasLatin, hasCyrillic).
  Output: reports/dialogue_st_counts.tsv + per-asset dumps localization/extracted/dialogue/
  NO translation, NO media, NO game writes, NO commits of raw assets. Class hints were
  dropped versus v1: DEC-017 classifies sources by path/name evidence; the dumps carry
  the content for later pairing checks.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$GamePath = 'C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart'
)
$ErrorActionPreference = 'Continue'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$repak = Join-Path $RepoRoot 'tools\bin\repak\repak.exe'
$paksPath = Join-Path $GamePath 'AtomicHeart\Content\Paks'
$rawRoot = Join-Path $RepoRoot 'source\original\uasset\dlg'
$dumps = Join-Path $RepoRoot 'localization\extracted\dialogue'
$outTsv = Join-Path $RepoRoot 'reports\dialogue_st_counts.tsv'
foreach ($d in $rawRoot, $dumps) { if (-not (Test-Path $d)) { New-Item -ItemType Directory -Force -Path $d | Out-Null } }

$sources = Get-Content (Join-Path $RepoRoot 'reports\dialogue_inventory_raw\st_scope.txt')
$byPak = $sources | Group-Object { ($_ -split '\|')[0] }
Write-Output ("[start] assets: {0} in {1} containers" -f $sources.Count, $byPak.Count)

function Get-CleanStrings([byte[]]$b) {
    # decode runs of UTF-16LE units; allowed: printable latin, punctuation, cyrillic,
    # greek, general punctuation, CJK, arabic, tab/newline. 2-byte aligned.
    $out = New-Object System.Collections.Generic.List[string]
    $i = 0; $n = $b.Length
    $sb = New-Object System.Text.StringBuilder
    while ($i + 1 -lt $n) {
        $u = [int]$b[$i] -bor ([int]$b[$i+1] -shl 8)
        $ok = ($u -ge 0x20 -and $u -le 0x7E) -or ($u -ge 0xA0 -and $u -le 0x17F) -or `
              ($u -ge 0x0386 -and $u -le 0x03CE) -or ($u -ge 0x0400 -and $u -le 0x04FF) -or `
              ($u -ge 0x2010 -and $u -le 0x2027) -or ($u -eq 0x00AB) -or ($u -eq 0x00BB) -or `
              ($u -eq 0x2026) -or ($u -ge 0x4E00 -and $u -le 0x9FFF) -or `
              ($u -ge 0x0600 -and $u -le 0x06FF) -or ($u -eq 10) -or ($u -eq 9)
        if ($ok) {
            [void]$sb.Append([char]$u)
            $i += 2
        } else {
            if ($sb.Length -ge 3) { $out.Add($sb.ToString()) }
            [void]$sb.Clear()
            $i += 2   # keep 2-byte alignment of the UTF-16LE stream
        }
    }
    if ($sb.Length -ge 3) { $out.Add($sb.ToString()) }
    return $out
}
function Get-AsciiStrings([byte[]]$b) {
    $out = New-Object System.Collections.Generic.List[string]
    $sb = New-Object System.Text.StringBuilder
    $prevOk = $false
    for ($i = 0; $i -lt $b.Length; $i++) {
        $c = $b[$i]
        $ok = ($c -ge 0x30 -and $c -le 0x7A -and $c -ne 0x40) -or ($c -ge 0x41 -and $c -le 0x5A) -or ($c -eq 0x5F) -or ($c -eq 0x20 -and $prevOk)
        if ($ok) { [void]$sb.Append([char]$c); $prevOk = $true }
        else { if ($sb.Length -ge 4) { $out.Add($sb.ToString().Trim()) }; [void]$sb.Clear(); $prevOk = $false }
    }
    if ($sb.Length -ge 4) { $out.Add($sb.ToString().Trim()) }
    return $out
}
function Get-ScopeClass([string]$path) {
    if ($path -match 'Localisation_LS|Narrative_LS|OpenWorldCorpses|Dialog_VDNH|LevelSequence|/LS_|(^|/)LS_[0-9]') { return 'LS' }
    if ($path -match 'ST_[A-Za-z0-9_]+\.|StringTable') { return 'ST' }
    return 'OTHER'
}

$sw = [Diagnostics.Stopwatch]::StartNew()
if (Test-Path $outTsv) { Remove-Item $outTsv -Force }
Set-Content -Path $outTsv -Value "pak`tpath`tscopeClass`tutf16Count`tasciiCount`thasLatin`thasCyrillic`tdump" -Encoding UTF8
$done = 0
foreach ($grp in ($byPak | Sort-Object Name)) {
    $pakName = $grp.Name
    $pak = Join-Path $paksPath ($pakName + '.pak')
    if (-not (Test-Path $pak)) { Write-Output ("[MISS] {0}" -f $pak); continue }
    foreach ($line in $grp.Group) {
        $parts = $line -split '\|', 2
        $entry = $parts[1]
        $name = [IO.Path]::GetFileNameWithoutExtension($entry)
        $tmpu = Join-Path $env:TEMP ('rk_' + [guid]::NewGuid().ToString('N') + '.tmp')
        $tmpu_err = $tmpu + '.err'
        Start-Process -FilePath $repak -ArgumentList @('get', ('"' + $pak + '"'), ('"' + $entry + '"')) -RedirectStandardOutput $tmpu -RedirectStandardError $tmpu_err -NoNewWindow -Wait | Out-Null
        Remove-Item $tmpu_err -Force -ErrorAction SilentlyContinue
        if (-not ((Test-Path $tmpu) -and ((Get-Item $tmpu -ErrorAction SilentlyContinue).Length -gt 0))) {
            Remove-Item $tmpu -Force -ErrorAction SilentlyContinue
            Add-Content -Path $outTsv -Value ("{0}`t{1}`tFETCH-FAIL`t0`t0`t0`t0`t-" -f $pakName, $entry) -Encoding UTF8
            continue
        }
        $ue = [IO.File]::ReadAllBytes($tmpu)
        Remove-Item $tmpu -Force
        $utf16 = Get-CleanStrings $ue
        $ascii = Get-AsciiStrings $ue
        $txt = ($utf16 -join "`n")
        $hasLatin = [regex]::IsMatch($txt, '[A-Za-z]{3,}')
        $hasCyr = $txt -cmatch '[\u0410-\u044F]{2,}'
        $dumpName = '{0}__{1}.txt' -f ($pakName -replace '-WindowsNoEditor\.pak$', ''), $name
        $dumpPath = Join-Path $dumps $dumpName
        $header = "# $entry (from $pakName)`n# scope_class=$(Get-ScopeClass $entry) utf16=$($utf16.Count) ascii=$($ascii.Count) hasLatin=$hasLatin hasCyrillic=$hasCyr`n"
        Set-Content -Path $dumpPath -Value ($header + "## UTF-16 strings`n" + ($utf16 -join "`n") + "`n`n## ASCII strings`n" + ($ascii -join "`n")) -Encoding UTF8
        Add-Content -Path $outTsv -Value ("{0}`t{1}`t{2}`t{3}`t{4}`t{5}`t{6}`t{7}" -f $pakName, $entry, (Get-ScopeClass $entry), $utf16.Count, $ascii.Count, [int][bool]$hasLatin, [int][bool]$hasCyr, $dumpName) -Encoding UTF8
        $done++
        if ($done % 250 -eq 0) { Write-Output ("{0} assets done, {1} min" -f $done, [int]($sw.Elapsed.TotalMinutes)) }
    }
    Write-Output ("[pak done] {0} ({1})" -f $pakName, $grp.Count)
}
Write-Output ("[DONE] {} assets in {} min" -f $done, [int]($sw.Elapsed.TotalMinutes))
