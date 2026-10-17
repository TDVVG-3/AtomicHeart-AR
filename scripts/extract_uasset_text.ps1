<#
.SYNOPSIS
  Phase 5 (non-locres): extracts StringTable / DataTable / DataAsset text candidates
  from the paks and dumps their inline strings (UTF-16LE + ASCII) into text catalogs.

.DESCRIPTION
  Per user decision 3: raw game assets are NEVER committed. Binary .uasset/.uexp
  extraction goes to source/original/uasset/ (gitignored). Only the text dumps
  (user-facing strings) go to localization/extracted/uasset_text/ (committable).

  Steps:
   1. repak list each pak once; select text candidates by filename/class pattern.
   2. repak get each selected .uasset/.uexp pair into source/original/uasset/<pak>/.
   3. For each .uexp, extract UTF-16LE strings >= 3 chars and ASCII strings >= 3 chars;
      detect scripts present (Cyrillic/CJK/Arabic/Greek) to test the inline
      multi-culture hypothesis.
   4. Write per-asset dumps + a consolidated catalog report.
#>
[CmdletBinding()]
param(
    [string]$GamePath = 'C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart',
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
$repak = Join-Path $RepoRoot 'tools\bin\repak\repak.exe'
$paksPath = Join-Path $GamePath 'AtomicHeart\Content\Paks'
$rawRoot = Join-Path $RepoRoot 'source\original\uasset'
$textRoot = Join-Path $RepoRoot 'localization\extracted\uasset_text'
$catalogPath = Join-Path $RepoRoot 'reports\uasset_strings_catalog.txt'
if (-not (Test-Path $rawRoot)) { New-Item -ItemType Directory -Force -Path $rawRoot | Out-Null }
if (-not (Test-Path $textRoot)) { New-Item -ItemType Directory -Force -Path $textRoot | Out-Null }

# candidate patterns: filename ends like ST_*, *StringTable, *Text*, *Tips, *Tip, DA_QuestData etc.
$patterns = @(
    '(^|/)ST_[A-Za-z0-9_]+\.uasset$',
    '(^|/)[A-Za-z0-9_]*StringTable[A-Za-z0-9_]*\.uasset$',
    '(^|/)([A-Za-z0-9_]*(Tips|Texts|Text|Subs|Sentences|Nomals|Descriptions)[A-Za-z0-9_]*)\.uasset$'
)

$candidates = @()
foreach ($pak in (Get-ChildItem $paksPath -Filter '*.pak' | Sort-Object Name)) {
    Write-Host ("[SCAN] {0}" -f $pak.Name)
    $list = & $repak list $pak.FullName 2>&1 | Where-Object { $_ -match '\S' }
    foreach ($p in $patterns) {
        $hits = $list | Select-String -Pattern $p
        foreach ($h in $hits) {
            $candidates += [pscustomobject]@{ pak = $pak.Name; path = $h.ToString().Trim() }
        }
    }
}
$candidates = $candidates | Sort-Object path, pak -Unique
Write-Host ("[OK] {0} candidate text assets" -f $candidates.Count)

# companion .uexp paths (game convention: Foo.uasset <-> Foo.uexp)
$fetch = @()
foreach ($c in $candidates) {
    $fetch += $c.path
    $fetch += ($c.path -replace '\.uasset$', '.uexp')
}
$fetch = $fetch | Sort-Object -Unique

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# Non-locres asset text catalog (UTF-16LE + ASCII string dumps)')
$lines.Add('# Generated (UTC): ' + (Get-Date).ToUniversalTime().ToString('o'))
$lines.Add('# Asset selection heuristics: ST_*, *StringTable*, *Tips/Texts/Subs/Sentences*')
$lines.Add('')

$pakCache = @{}
foreach ($entry in $fetch) {
    $pakName = $null
    foreach ($c in $candidates) {
        if ($c.path -eq $entry -or (($c.path -replace '\.uasset$','.uexp') -eq $entry)) { $pakName = $c.pak; break }
    }
    if (-not $pakName) { continue }
    if (-not $pakCache.ContainsKey($pakName)) { $pakCache[$pakName] = Join-Path $paksPath $pakName }
    $pak = $pakCache[$pakName]

    $rel = ($entry -replace '^(\.\./)+', '')
    $dest = Join-Path $rawRoot (Join-Path $pakName ($rel -replace '/', '\'))
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
    $tmp = "$dest.tmp"
    cmd /c "`"$repak`" get `"$pak`" `"$entry`" > `"$tmp`"" 2>$null
    if ((Test-Path $tmp) -and ((Get-Item $tmp).Length -gt 0)) { Move-Item $tmp $dest -Force } else { if (Test-Path $tmp) { Remove-Item $tmp -Force } ; continue }

    if ($dest -notmatch '\.uexp$') { continue }

    $assetName = [System.IO.Path]::GetFileNameWithoutExtension($rel)
    $pakLeaf = $pakName -replace '\.pak$', ''
    $dumpPath = Join-Path $textRoot ("{0}__{1}.txt" -f $pakLeaf, $assetName)

    # resume support: skip assets already extracted and dumped
    if ((Test-Path $dumpPath) -and (Test-Path $dest)) { continue }

    # --- string extraction from the .uexp binary (single-pass .NET regex) ---
    $bytes = [System.IO.File]::ReadAllBytes($dest)

    # UTF-16LE view: printable runs >= 3 chars (latin/cyrillic/greek/arabic/CJK/kana/hangul)
    $text16 = [System.Text.Encoding]::Unicode.GetString($bytes)
    $utf16 = [System.Collections.Generic.List[string]]::new()
    foreach ($m in [regex]::Matches($text16, '[\u0020-\u2FFF\u3000-\uD7FF\uF900-\uFFFD]{3,}')) {
        $s = $m.Value.Trim()
        if ($s.Length -ge 3) { $utf16.Add($s) }
    }

    # ASCII view (class/property names, keys)
    $textA = [System.Text.Encoding]::GetEncoding('latin1').GetString($bytes)
    $ascii = [System.Collections.Generic.List[string]]::new()
    foreach ($m in [regex]::Matches($textA, '[\x20-\x7E]{3,}')) { $ascii.Add($m.Value) }

    $scripts = @()
    $txt = $utf16 -join ' '
    if ($txt -match '[\u0400-\u04FF]') { $scripts += 'Cyrillic' }
    if ($txt -match '[\u3040-\u30FF\u4E00-\u9FFF]') { $scripts += 'CJK' }
    if ($txt -match '[\u0600-\u06FF]') { $scripts += 'Arabic' }
    if ($txt -match '[\u0370-\u03FF]') { $scripts += 'Greek' }

    # (dump path computed above, shared with resume skip)
    $dump = New-Object System.Collections.Generic.List[string]
    $dump.Add("# $entry  (from $pakName)")
    $dump.Add("# utf16_strings=$($utf16.Count) ascii_strings=$($ascii.Count) scripts=$($scripts -join ',')")
    if ($scripts.Count -gt 0) { $dump.Add('# SCRIPTS DETECTED: ' + ($scripts -join ',')) }
    $dump.Add('')
    $dump.Add('## UTF-16 strings')
    foreach ($s in $utf16) { $dump.Add($s) }
    $dump.Add('')
    $dump.Add('## ASCII strings (may include class/property names)')
    foreach ($s in ($ascii | Select-Object -Unique)) { $dump.Add($s) }
    Set-Content -Path $dumpPath -Value $dump -Encoding UTF8

    $lines.Add(('{0} :: {1}' -f $pakName.PadRight(40), $entry))
    $lines.Add(('    utf16={0} ascii={1} scripts={2} dump={3}' -f $utf16.Count, $ascii.Count, ($scripts -join ','), (Split-Path $dumpPath -Leaf)))
}
Set-Content -Path $catalogPath -Value $lines -Encoding UTF8
Write-Host ''
Write-Host ("[DONE] catalog: $catalogPath")
Write-Host ("[DONE] text dumps: $textRoot")
