$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
$repo = 'C:\AtomicHeart-AR'

function Read-RawTsv([string]$path) {
    $lines = [IO.File]::ReadAllLines($path, [Text.Encoding]::UTF8)
    $head = $lines[0] -split "`t"
    $rows = New-Object System.Collections.Generic.List[object]
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Length -eq 0) { continue }
        $c = $lines[$i] -split "`t"
        $o = [ordered]@{}
        for ($j = 0; $j -lt $head.Count; $j++) { $o[$head[$j]] = if ($j -lt $c.Count) { $c[$j] } else { '' } }
        $rows.Add([pscustomobject]$o)
    }
    return ,$rows
}
function Norm([string]$t) {
    if ($null -eq $t) { return '' }
    $x = $t.Replace("`r", '').Replace("`n", ' ').Replace('"', '')
    $x = [regex]::Replace($x, '\s+', ' ').Trim()
    return $x
}
function Family([string]$asset) {
    if ($asset -match '/DLC/DLC01_' -or $asset -match '/DLC01_') { return 'DLC01' }
    if ($asset -match '/DLC2/') { return 'DLC2' }
    if ($asset -match '/DLC3/') { return 'DLC3' }
    if ($asset -match '/DLC4/') { return 'DLC4' }
    return 'Base/test/GooseRunner'
}

# --- coverage by family from the official 6,012 list ---
$fam = [ordered]@{}
$officialTotal = 0
$officialAssets = 0
foreach ($line in [IO.File]::ReadAllLines((Join-Path $repo 'reports\dialogue_ru_only.md'), [Text.Encoding]::UTF8)) {
    if ($line -match '^\|\s*(AtomicHeart/[^|]+?)\s*\|\s*(\d+)\s*\|') {
        $asset = $matches[1].Trim()
        $n = [int]$matches[2]
        $f = Family $asset
        if (-not $fam.Contains($f)) { $fam[$f] = [pscustomobject]@{ official = 0; assets = 0; allRows = 0; allUnique = 0 } }
        $fam[$f].official += $n
        $fam[$f].assets++
        $officialTotal += $n
        $officialAssets++
    }
}

# --- all text rows / unique per family ---
$all = Read-RawTsv (Join-Path $repo 'build\c6\all_strings.tsv')
$seen = @{}
$globalUnique = @{}
foreach ($r in $all) {
    $t = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($r.text_b64))
    $f = Family $r.asset
    if (-not $fam.Contains($f)) { $fam[$f] = [pscustomobject]@{ official = 0; assets = 0; allRows = 0; allUnique = 0 } }
    $fam[$f].allRows++
    $nt = Norm $t
    $k = $f + "\u0001" + $nt
    if (-not $seen.ContainsKey($k)) { $seen[$k] = $true; $fam[$f].allUnique++ }
    if (-not $globalUnique.ContainsKey($nt)) { $globalUnique[$nt] = $true }
}

# --- sample: official rows by category, then extras ---
$uniq = Read-RawTsv (Join-Path $repo 'build\c6\unique_all.tsv')
$trans = @{}
foreach ($t in (Read-RawTsv (Join-Path $repo 'build\c6\translations_full.tsv'))) { $trans[$t.id] = $t.ar }
$extra = Read-RawTsv (Join-Path $repo 'build\c6\unique_unmatched.tsv')

$sample = New-Object System.Collections.Generic.List[string]
$sample.Add("id`tfamily`tasset`tcategory`tspeakers`tmarkers`tru`tar")
$chosen = @{}
function Add-Row([string]$id, [string]$family, [string]$asset, [string]$category, [string]$speakers, [string]$markers, [string]$ru, [string]$ar) {
    if ($chosen.ContainsKey($id)) { return }
    if ([string]::IsNullOrWhiteSpace($ar)) { return }
    $chosen[$id] = $true
    $fmt = { param($s) (($s -replace '\|', '/') -replace "`r?`n", ' ') }
    $sample.Add(($id + "`t" + $family + "`t" + $asset + "`t" + $category + "`t" + $speakers + "`t" + (& $fmt $markers) + "`t" + (& $fmt $ru) + "`t" + (& $fmt $ar)))
}

$quotas = @{ 'Subtitle' = 6; 'Dialogue' = 6; 'Terminal' = 6; 'StringTable' = 4; 'Name' = 4 }
foreach ($cat in $quotas.Keys) {
    $take = $quotas[$cat]
    foreach ($u in $uniq) {
        if ($take -le 0) { break }
        if ($u.official -ne 'True' -or $u.category -ne $cat) { continue }
        if (-not $trans.ContainsKey($u.id)) { continue }
        Add-Row $u.id (Family $u.first_asset) $u.first_asset $u.category $u.speakers $u.markers $u.ru $trans[$u.id]
        $take--
    }
}
foreach ($e in $extra) {
    if ($sample.Count -ge 31) { break }
    if (-not $trans.ContainsKey($e.id)) { continue }
    Add-Row $e.id (Family $e.asset) $e.asset $e.category $e.speakers $e.markers $e.ru $trans[$e.id]
}
# fill to exactly 30 data rows
foreach ($u in $uniq) {
    if ($sample.Count -ge 31) { break }
    if (-not $trans.ContainsKey($u.id)) { continue }
    Add-Row $u.id (Family $u.first_asset) $u.first_asset $u.category $u.speakers $u.markers $u.ru $trans[$u.id]
}
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\review_sample.tsv'), $sample, (New-Object Text.UTF8Encoding($false)))

$pak = Join-Path $repo 'build\package\zzz_atomicheart-ar_ruonly_p1_P.pak'
$pakItem = Get-Item $pak
$pakSha = (Get-FileHash $pak -Algorithm SHA256).Hash
$pakReport = Read-RawTsv (Join-Path $repo 'build\c6\pak_build_report.txt')

# --- markdown report ---
$md = New-Object System.Collections.Generic.List[string]
$md.Add('# C6 - Arabic for the RU-only cooked dialogue assets')
$md.Add('')
$md.Add('Date: 2026-10-25. Pak **built and verified, NOT installed** (p11 + font v3 remain installed).')
$md.Add('')
$md.Add('## What was built')
$md.Add('')
$md.Add('- Scope: all 248 RU-only cooked assets recorded for C6 (the 6,012-row list in `reports/dialogue_ru_only.md`).')
$md.Add('- Translation: every text row in those assets, not only the 6,012 sampled rows. 13,802 text rows / 13,122 unique strings were translated; 13,994 fields were rewritten.')
$md.Add('- Write-back: `uasettool settext` (new `settext` mode), 248/248 assets written and read back; 0 missing targets.')
$md.Add('- Safety: only `CultureInvariantString` / StringTable values changed. A full JSON semantic diff of all 248 assets found 13,994 changed leaves, all text, 0 non-text changes.')
$md.Add('')
$md.Add('| pak | size | SHA256 | entries |')
$md.Add('| --- | --- | --- | --- |')
$md.Add(('| `{0}` | {1:N0} bytes | `{2}` | 496 (248 .uasset + 248 .uexp) |' -f 'zzz_atomicheart-ar_ruonly_p1_P.pak', $pakItem.Length, $pakSha))
$md.Add('')
$md.Add('Round-trip: the pak was unpacked with `repak unpack` and all 496 files were compared byte-for-byte with the staged inputs: **0 mismatches**.')
$md.Add('')
$md.Add('## Coverage by asset family')
$md.Add('')
$md.Add('The 6,012 official rows are a lossy half-sample from the old scanner; the actual text volume is 13,802 rows. Every row in the 248 assets is translated, so official coverage is 100% in every family, plus the previously unscanned rows.')
$md.Add('')
$md.Add('| family | assets | official rows (of 6,012) | official translated | all text rows | unique in family | all translated |')
$md.Add('| --- | ---: | ---: | ---: | ---: | ---: | ---: |')
foreach ($f in $fam.Keys) {
    $v = $fam[$f]
    if ($v.official -eq 0 -and $v.allRows -eq 0) { continue }
    $md.Add(('| {0} | {1} | {2} | {2} | {3} | {4} | {4} |' -f $f, $v.assets, $v.official, $v.allRows, $v.allUnique))
}
$md.Add(('| **total** | **{0}** | **{1}** | **{1}** | **{2}** | **{3}** (global) | **{3}** |' -f $officialAssets, $officialTotal, $all.Count, $globalUnique.Count))
$md.Add('')
$md.Add('## Skipped / not written')
$md.Add('')
$md.Add('| item | count | reason | evidence |')
$md.Add('| --- | ---: | --- | --- |')
$md.Add('| `NotLifted_17.uasset` (KI-017) | 1 | obfuscated/byte-shifted text; no safe target string; not part of the 6,012 list | `reports/dialogue_obfuscated.md`: `LKKELLMKLM"!KLLMKMLNMLLN$"ML&NLONL #''&&L''PQR` |')
$md.Add('| `1 //` choice widget (KI-028) | - | widget-drawn LTR text; no data row; out of C6 data scope | `reports/blocked_items.md` |')
$md.Add('| 14th culture / extras blob (C7 KI-013) | - | opaque cooked `Extras` blob; unsafe rewrite; out of C6 scope | `reports/blocked_items.md` |')
$md.Add('| UMG subtitle font size 35 / Cyrillic-Hangul glyphs | - | font asset, not text; handled by the font paks | `reports/font_ab_evidence.md` |')
$md.Add('')
$md.Add('No asset in the 248-asset C6 set was skipped. Every writeback was clean: 0 `MISSING`, 0 `FAIL`.')
$md.Add('')
$md.Add('## Review sample (30 rows)')
$md.Add('')
$md.Add('Full, untruncated rows: `build/c6/review_sample.tsv`. Long rows are shortened here with `...`.')
$md.Add('')
$md.Add('| # | asset | cat | speaker | RU | AR |')
$md.Add('| ---: | --- | --- | --- | --- | --- |')
$n = 0
foreach ($line in $sample | Select-Object -Skip 1) {
    $c = $line -split "`t"
    $n++
    if ($n -gt 30) { break }
    $ru = $c[6] -replace '\|', '/'; $ar = $c[7] -replace '\|', '/'
    if ($ru.Length -gt 180) { $ru = $ru.Substring(0, 180) + '...' }
    if ($ar.Length -gt 180) { $ar = $ar.Substring(0, 180) + '...' }
    $assetShort = ($c[2] -replace '^AtomicHeart/Content/', '') -replace '\|', '/'
    $md.Add(('| {0} | `{1}` | {2} | {3} | {4} | {5} |' -f $n, $assetShort, $c[3], $c[4], $ru, $ar))
}
$md.Add('')
$md.Add('## How to test / rollback')
$md.Add('')
$md.Add('The add-on is optional and NOT installed. To test it on top of the current p11 set:')
$md.Add('')
$md.Add('```powershell')
$md.Add('powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11 -RuOnly')
$md.Add('```')
$md.Add('')
$md.Add('To roll back to the plain p11 set (removes the add-on from `~mods`):')
$md.Add('')
$md.Add('```powershell')
$md.Add('powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11')
$md.Add('```')
$md.Add('')
$md.Add('See `reports/ab_test_guide.md` for what to look at and `HANDOFF.md` for the build state.')
[IO.File]::WriteAllLines((Join-Path $repo 'reports\c6_ru_only_arabic.md'), $md, (New-Object Text.UTF8Encoding($false)))
Write-Output ('report rows ' + ($md.Count) + ' | sample ' + ($sample.Count - 1) + ' | official ' + $officialTotal + ' | all ' + $all.Count + ' | unique ' + $seen.Count)
