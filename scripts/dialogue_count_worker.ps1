<#
  Worker for the parallel dialogue count pass.
  Reads one chunk file (lines: pak|path), skips assets whose TSV row exists AND whose
  dump file is valid on disk, fetches each remaining .uexp via repak (max 1 per worker;
  4 workers = 4 repak max), decodes UTF-16LE losslessly, writes per-asset dumps and
  appends rows to its own part TSV. Safe single-parameter run.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$GamePath = 'C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart',
    [string]$ChunkFile = '',
    [string]$WorkerId = '1'
)
$ErrorActionPreference = 'Continue'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$repak = Join-Path $RepoRoot 'tools\bin\repak\repak.exe'
$paksPath = Join-Path $GamePath 'AtomicHeart\Content\Paks'
$dumps = Join-Path $RepoRoot 'localization\extracted\dialogue'
$outTsv = Join-Path $RepoRoot ('reports\dialogue_inventory_raw\counts_part_' + $WorkerId + '.tsv')
if (-not (Test-Path $dumps)) { New-Item -ItemType Directory -Force -Path $dumps | Out-Null }

function Get-CleanStrings([byte[]]$b) {
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
        if ($ok) { [void]$sb.Append([char]$u); $i += 2 }
        else {
            if ($sb.Length -ge 3) { $out.Add($sb.ToString()) }
            [void]$sb.Clear()
            $i += 2
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

# done-set: any asset whose dump file exists and is non-empty counts as counted
$done = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
foreach ($f in (Get-ChildItem $dumps -Filter '*.txt' -ErrorAction SilentlyContinue)) {
    if ($f.Length -gt 0) { $done.Add($f.Name) | Out-Null }  # key = '<pakstub>__<name>.txt'
}
Write-Output ("[worker {0}] known dumps: {1}" -f $WorkerId, $done.Count)

$entries = New-Object System.Collections.Generic.List[object]
foreach ($ln in (Get-Content $ChunkFile)) {
    if (-not $ln) { continue }
    $p = $ln -split '\|', 2
    if ($p.Count -lt 2) { continue }
    $name = [IO.Path]::GetFileNameWithoutExtension($p[1])
    $dumpName = '{0}__{1}.txt' -f ($p[0] -replace '-WindowsNoEditor\.pak$', ''), $name
    if ($done.Contains($dumpName)) { continue }
    $entries.Add([pscustomobject]@{ pak = $p[0]; path = $p[1]; dump = $dumpName })
}
Write-Output ("[worker {0}] to do: {1}" -f $WorkerId, $entries.Count)

$sw = [Diagnostics.Stopwatch]::StartNew()
Set-Content -Path $outTsv -Value "pak`tpath`tscopeClass`tutf16Count`tasciiCount`thasLatin`thasCyrillic`tdump" -Encoding UTF8
$ok = 0
foreach ($e in $entries) {
    $pak = Join-Path $paksPath ($e.pak + '.pak')
    $entryX = $e.path -replace '\.uasset$', '.uexp'
    $tmpu = Join-Path $env:TEMP ('rk_' + [guid]::NewGuid().ToString('N') + '.tmp')
    $tmpu_err = $tmpu + '.err'
    Start-Process -FilePath $repak -ArgumentList @('get', ('"' + $pak + '"'), ('"' + $entryX + '"')) -RedirectStandardOutput $tmpu -RedirectStandardError $tmpu_err -NoNewWindow -Wait | Out-Null
    Remove-Item $tmpu_err -Force -ErrorAction SilentlyContinue
    if (-not ((Test-Path $tmpu) -and ((Get-Item $tmpu -ErrorAction SilentlyContinue).Length -gt 0))) {
        Remove-Item $tmpu -Force -ErrorAction SilentlyContinue
        Add-Content -Path $outTsv -Value ("{0}`t{1}`tFETCH-FAIL`t0`t0`t0`t0`t-" -f $e.pak, $e.path) -Encoding UTF8
        continue
    }
    $ue = [IO.File]::ReadAllBytes($tmpu)
    Remove-Item $tmpu -Force
    $utf16 = Get-CleanStrings $ue
    $ascii = Get-AsciiStrings $ue
    $txt = ($utf16 -join "`n")
    $hasLatin = [regex]::IsMatch($txt, '[A-Za-z]{3,}')
    $hasCyr = $txt -cmatch '[\u0410-\u044F]{2,}'
    $dumpPath = Join-Path $dumps $e.dump
    $header = "# $($e.path) (from $($e.pak))`n# scope_class=$(Get-ScopeClass $entryX) utf16=$($utf16.Count) ascii=$($ascii.Count) hasLatin=$hasLatin hasCyrillic=$hasCyr`n"
    Set-Content -Path $dumpPath -Value ($header + "## UTF-16 strings`n" + ($utf16 -join "`n") + "`n`n## ASCII strings`n" + ($ascii -join "`n")) -Encoding UTF8
    Add-Content -Path $outTsv -Value ("{0}`t{1}`t{2}`t{3}`t{4}`t{5}`t{6}`t{7}" -f $e.pak, $e.path, (Get-ScopeClass $entryX), $utf16.Count, $ascii.Count, [int][bool]$hasLatin, [int][bool]$hasCyr, $e.dump) -Encoding UTF8
    $ok++
    if ($ok % 200 -eq 0) { Write-Output ("[worker {0}] {1} done, {2} min" -f $WorkerId, $ok, [int]($sw.Elapsed.TotalMinutes)) }
}
Write-Output ("[worker {0} DONE] {1} rows in {2} min" -f $WorkerId, $ok, [int]($sw.Elapsed.TotalMinutes))
