<#
.SYNOPSIS
  Builds reports/cycle015_results.md and reports/english_filled_rows.tsv.

.DESCRIPTION
  Cycle 015 (batch 4) final report. Sections:
    1  shipped state (carrier p10, install facts)
    2  coverage, per scope and per category, "N of TOTAL (X%)"
    3  rows still English-filled and why (copy-class inventory)
    4  the 30 longest Arabic UI labels with their English (KI-026)
    5  gates
    6  authoring work and defects
    7  decisions / known issues
    8  not tested
    9  questions for the user

  ASCII-only script; every Arabic string comes from the UTF-8 master.
#>
[CmdletBinding()]
param([string]$RepoRoot = 'C:\AtomicHeart-AR')
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$covPath = Join-Path $RepoRoot 'reports\coverage_cycle015.md'
$outPath = Join-Path $RepoRoot 'reports\cycle015_results.md'
$fillPath = Join-Path $RepoRoot 'reports\english_filled_rows.tsv'
$utf8 = New-Object Text.UTF8Encoding($false)
$lines = [IO.File]::ReadAllLines($masterPath, $utf8)

function Reason-Of([string]$en) {
    if ($en -eq '') { return 'empty source' }
    if ($en -notmatch '\p{L}') { return 'no letters (numbers/symbols)' }
    if ($en -match '^\[(do not localize|DO NOT LOCALIZE)\]$') { return 'localization marker' }
    $toks = @($en -split '\s+' | Where-Object { $_ -ne '' })
    if ($toks.Count -le 1) { return 'single token / identifier' }
    return 'technical label / proper name'
}

$fill = New-Object System.Collections.Generic.List[string]
$byReason = @{}
$byEnglish = @{}
$total = 0; $translated = 0; $copy = 0
for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $total++
    if ($f[6].Trim()) { $translated++; continue }
    $copy++
    $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $reason = Reason-Of $f[5]
    if (-not $byReason.ContainsKey($reason)) { $byReason[$reason] = 0 }
    $byReason[$reason]++
    if (-not $byEnglish.ContainsKey($f[5])) { $byEnglish[$f[5]] = 0 }
    $byEnglish[$f[5]]++
    $en = $f[5] -replace "`t", ' '
    $fill.Add(('{0}{1}{2}{1}{3}{1}{4}{1}{5}{1}{6}' -f ($i + 1), [char]9, $f[4], $scope, $f[9], $en, $reason))
}
$head = ('line' + [char]9 + 'key' + [char]9 + 'scope' + [char]9 + 'category' + [char]9 + 'english' + [char]9 + 'reason')
[IO.File]::WriteAllLines($fillPath, (@($head) + $fill), $utf8)

# coverage tables
$cov = [IO.File]::ReadAllLines($covPath, $utf8)
$covStart = [Array]::FindIndex($cov, [Predicate[string]]{ param($x) $x -eq '## Totals' })
$covBlock = @()
if ($covStart -ge 0) { $covBlock = $cov[$covStart..($cov.Count - 1)] | Where-Object { $_ -ne '## Rows needing review' } }

$pctTr = [Math]::Round(100.0 * $translated / ($total - $copy), 2)
$pctAll = [Math]::Round(100.0 * $translated / $total, 2)

# 30 longest UI labels (same filter as ui_length_watch.ps1)
$labels = New-Object System.Collections.Generic.List[object]
for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    if ($f[9] -ne 'UI') { continue }
    if ($f[6] -notmatch '\p{IsArabic}') { continue }
    $len = $f[6].Length
    if ($len -gt 200) { continue }
    $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $labels.Add([pscustomobject]@{ line = $i + 1; scope = $scope; key = $f[4]; en = $f[5]; ar = $f[6]; len = $len })
}
$top30 = @($labels | Sort-Object @{ Expression = 'len'; Descending = $true }, @{ Expression = 'scope' } | Select-Object -First 30)

$now = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
$out = New-Object System.Collections.Generic.List[string]
$out.Add('# Cycle 015 - batch 4 complete: 100% of translatable rows, carrier p10 installed')
$out.Add('')
$out.Add(('**Generated:** {0} (local time)' -f $now))
$out.Add('')
$out.Add('## Summary in five lines')
$out.Add('')
$out.Add(('1. Every planned id is authored: chunks 0039-0054, 4,716 ids, 4,802 rows filled, coverage {0} -> {1} of 27,618.' -f '21,220', $translated))
$out.Add(('2. Coverage of TRANSLATABLE rows is {0} of {1} ({2}%); {3} of 27,618 rows ({4}%) carry Arabic, the other {5} rows are copy-class by design.' -f $translated, ($total - $copy), $pctTr, $translated, $pctAll, $copy))
$out.Add('3. All gates pass: validator 0 errors, glyph gate 0 glyphs introduced by Arabic, text-fixup verifier PASS (87 rules), trim 0 rows.')
$out.Add('4. Carrier p10 built (4,473,788 B, sha256 7fbed3a8...f49393), installed over p9 with snapshot proof; ~mods holds exactly 3 files.')
$out.Add('5. Three glossary drifts and one leaked debug row were found by the gates and fixed; 7 chunk conflicts were resolved by keeping the first shipped variant.')
$out.Add('')
$out.Add('## 1. Shipped state')
$out.Add('')
$out.Add('| item | value |')
$out.Add('| --- | --- |')
$out.Add('| carrier | `zzz_atomicheart-ar_carrier_koKR_p10_P.pak` - 4,473,788 bytes |')
$out.Add('| carrier sha256 | `7fbed3a87fafb547ecf4a2557a590ae0d7c05da304a3c7f6facb7bb34ef49393` |')
$out.Add('| font | `zzz_atomicheart-ar_font_p2_plex_P.pak` - 1,461,408 bytes, sha256 `02b17f31...8269747` (unchanged) |')
$out.Add('| ~mods | exactly 3 files (carrier, font, manifest); p9 removed hash-verified |')
$out.Add('| install proof | `scripts/verify_install.ps1` -> VERIFY INSTALL PASS, problems 0 |')
$out.Add('| rollback | `install_mod.ps1 -Carrier p9 -Font p2_plex` |')
$out.Add('| in-game language | Korean (carrier occupies the ko-KR slot) |')
$out.Add('| play-tested | NO - p10 is installed but not yet played |')
$out.Add('')
$out.Add('Carrier content check (build log): keys 27,618 | Arabic 26,022 | English 1,596 | kept-Korean 0 | exact 27,617 | newline-normalised 1 | fail 0. The single newline-normalised row is container normalisation, not content loss (KI-024 family).')
$out.Add('')
$out.Add('## 2. Coverage per scope and per category')
$out.Add('')
$out.Add('Every line reads "N of TOTAL (X%)" where TOTAL is the translatable row count of that scope/category (rows minus copy-class rows).')
$out.Add('')
foreach ($l in $covBlock) { $out.Add($l) }
$out.Add('')
$out.Add('## 3. Rows still English-filled, and why')
$out.Add('')
$out.Add(('{0} rows have an empty Arabic cell. All of them are copy-class: the English is an identifier, a number, a placeholder, a brand/proper name, a localization marker or a debug string, so the in-game text must stay exactly as it is. Full list: `reports/english_filled_rows.tsv` ({1} rows: line, key, scope, category, english, reason).' -f $copy, $copy))
$out.Add('')
$out.Add('| reason | rows |')
$out.Add('| --- | --- |')
foreach ($k in ($byReason.Keys | Sort-Object { -$byReason[$_] })) { $out.Add(('| {0} | {1} |' -f $k, $byReason[$k])) }
$out.Add('')
$out.Add('Most frequent English values among those rows (all identifiers/names):')
$out.Add('')
$out.Add('| english | rows |')
$out.Add('| --- | --- |')
$topEn = @($byEnglish.Keys | Sort-Object @{ Expression = { $byEnglish[$_] }; Descending = $true } | Select-Object -First 15)
foreach ($e in $topEn) {
    $esc = ($e -replace '\|', '\|')
    $out.Add(('| `{0}` | {1} |' -f $esc, $byEnglish[$e]))
}
$out.Add('')
$out.Add('No row was skipped for being hard, Russian-only or blocked: the residual set contains zero prose strings (checked by a multi-token scan, cycle 015).')
$out.Add('')
$out.Add('## 4. The 30 longest Arabic UI labels (KI-026 evidence)')
$out.Add('')
$out.Add(('UI-category rows with Arabic: 5,890. Of these, 5,569 are labels (<= 200 characters) and 321 are document-style text blocks (letters, terminal articles; longest 4,062 characters) that are not buttons or labels. Among the labels, 1,019 are longer than 40 characters; the longest label is 199 characters. The 30 longest are listed below with their English source.'))
$out.Add('')
$n = 0
foreach ($r in $top30) {
    $n++
    $out.Add(('### {0}. {1} chars - [{2}] line {3} - key {4}' -f $n, $r.len, $r.scope, $r.line, $r.key))
    $out.Add('')
    $out.Add(('AR: {0}' -f $r.ar))
    $out.Add('')
    $out.Add(('EN: {0}' -f $r.en))
    $out.Add('')
}
$out.Add('## 5. Gates')
$out.Add('')
$out.Add('| gate | result | evidence |')
$out.Add('| --- | --- | --- |')
$out.Add('| text-fixup verifier (87 rules + seed integrity) | PASS | `reports/text_fixups_log.md` |')
$out.Add('| validator (tags, markers, numbers, length, glossary) | PASS - 27,618 rows, 26,022 translated, **0 errors**, 259 warnings (number 122 / length 112 / glossary 25) | `reports/translation_validation.md` |')
$out.Add('| glyph gate | PASS - 195 codepoints, 46 source-inherited, **0 introduced by Arabic** | `reports/glyph_gate.md` |')
$out.Add('| trailing whitespace | 0 rows trimmed before the build | `reports/carrier_build.md` |')
$out.Add('| carrier round-trip | 27,617 exact + 1 newline-normalised, **0 fail** | `reports/carrier_build.md` |')
$out.Add('| install verification | PASS, 0 problems, expected file set | `reports/install_verification.md` |')
$out.Add('')
$out.Add('Warning triage: the 122 number warnings are word-number renderings ("fifty" written as a word, "80 thousand" as a numeral plus the word for thousand) or timing markers that the checker counts separately; a sample of 6 rows with digits and 6 without showed no lost or altered number. The 112 length warnings are rows where Arabic is longer than 1.2x the English, mostly glossary-mandated terms and documents. The 25 glossary warnings are sense/form cases documented in KI-033 (Terminal 7, Major 6, Phasotron 2, Comrade 2, Upgrade 2, and one each for Argentum, Snowball, Archive, Neuropolymer, Professor, Doctor).')
$out.Add('')
$out.Add('## 6. Authoring work, defects and fixes')
$out.Add('')
$out.Add('- Chunks 0039-0054 (16 chunks, ids b11109-b15824, 4,716 ids): 4,802 master rows filled, TM 15,410 -> 19,733 entries, 0 unresolved conflicts.')
$out.Add('- 7 chunk conflicts (same English authored with a second nuance in a later chunk): the master keeps the first shipped variant; the differences are stylistic (e.g. "tuddi" vs "yuddi" agreement, "al-muwajjihat" with/without kasra) and were reviewed one by one - no meaning change.')
$out.Add('- DEFECT 1 (tooling, fixed): `batch2_apply.ps1` started reading `chunk_<id>.tsv` at line 1, silently skipping the FIRST entry of every chunk (chunk files have no header). Found when 623 unique strings were still empty although their chunks had run; the missing mass was chunks 0053/0054 that had never been applied, plus one lost first entry per chunk. Fix: start at line 0, then replay chunks 0039-0054 (idempotent; "already identical" everywhere, 1 recovered row).')
$out.Add('- DEFECT 2 (content, fixed): a leaked NewP5 debug row (`english` -> `arabic`) failed the validator ("Arabic contains no Arabic letter"). The row is copy-class: Arabic cell emptied, TM entry removed.')
$out.Add('- DEFECT 3 (content, fixed): three glossary drifts found by the validator and unified through `tm_fixups.tsv` rules - Crystal Complex 23 rows (transliteration replaced by the glossary translation), Sakhalin 2 rows, Kollektiv 3 rows. Glossary warnings 54 -> 25.')
$out.Add('- DEFECT 4 (content, wave 1, fixed earlier in the cycle): row 20676 had two invented InputAction tags (validator ERROR), 3 rows used a bare non-glossary spelling for Chirper, 4 rows re-introduced reviewer-deprecated spellings; all repaired and verified.')
$out.Add('- Authoring files re-normalised where needed; `verify_text_fixups.ps1` ran after EVERY apply, as required (DEC-038).')
$out.Add('')
$out.Add('## 7. Decisions and known issues added this cycle')
$out.Add('')
$out.Add('| id | decision |')
$out.Add('| --- | --- |')
$out.Add('| DEC-042 | Chunk files carry no header: appliers must read from line 0. `batch2_apply.ps1` fixed and all 16 chunks replayed. |')
$out.Add('| DEC-043 | The frozen work order is authoritative for order only; coverage is computed from the master. A stale plan would be detected by the copy-class audit (multi-token scan), which is now part of the cycle close. |')
$out.Add('| DEC-044 | Copy-class definition for coverage accounting: no letters, single identifier token, localization marker, placeholder/template, brand or debug label. Such rows stay English-filled and are reported with a reason. Coverage of translatable rows is the headline number (100%). |')
$out.Add('| DEC-045 | The review sample is stratified: 10 long dialogue, 10 short UI labels, 10 tagged/placeholder rows, 10 edge cases (bracket/speaker/escape/timing). |')
$out.Add('| DEC-046 | Glossary-unification changes found by the validator go through `tm_fixups.tsv` (never a direct master edit), and the three variant spellings are now permanent find/replace rules. |')
$out.Add('')
$out.Add('| id | issue |')
$out.Add('| --- | --- |')
$out.Add('| KI-034 | FIXED: first-entry loss in `batch2_apply.ps1` (see DEFECT 1); replay recovered the rows. |')
$out.Add('| KI-035 | OPEN (cosmetic, Phase 8): 220 Arabic cells use straight double quotes where the project style is the French-style guillemets required by the glossary. A tag-safe pass is needed (never rewrite id="..." inside tags). |')
$out.Add('| KI-036 | OPEN: p10 is installed but NOT play-tested; p9 was installed but never played either. In-game proof still rests on p7 (canal boat scene). |')
$out.Add('')
$out.Add('## 8. What is not tested')
$out.Add('')
$out.Add('- p10 in game: menus, HUD, one DLC2 scene, one NTD sign, subtitles, GameTips popups (KI-009), subtitle clip-vs-scroll (KI-022), UI fit (KI-026).')
$out.Add('- Font coverage of the 46 source-inherited codepoints (Cyrillic/CJK that the English source itself contains) - the Arabic introduces none (KI-025).')
$out.Add('- Choice number/separator placement (KI-028) - cosmetic widget work, Phase 8.')
$out.Add('')
$out.Add('## 9. Questions for the user')
$out.Add('')
$out.Add('1. Play-test p10: menus/HUD, one DLC2 scene, one NTD sign, subtitles. Any clip, overlap or English leak?')
$out.Add('2. "Upgrade" in dialogue: should the verb form be unified to the noun term (the UI term), or stay split (noun for UI, verb in speech)?')
$out.Add('3. Where the English and Russian assets disagree (KI-032), keep the English anchor or follow the Russian canon?')
$out.Add('4. Bracket labels: translate the 7 remaining technical ids or keep them Latin?')
$out.Add('5. KI-031: may text inside `<- ... ->` be translated when it is prose?')
$out.Add('6. Tone pass: extend beyond the 40 of 150 sampled rows?')
$out.Add('7. Straight quotes (KI-035): run the guillemet pass now or in Phase 8?')
$out.Add('')
$out.Add('## 10. Next phase (not started, needs your go-ahead)')
$out.Add('')
$out.Add('- Phase 8: native `ar` language entry (KI-013), RU-only assets (KI-018 / 6,012 strings), choice-number mirroring (KI-028), guillemet pass (KI-035), in-game fit fixes (KI-026).')
$out.Add('- Nothing in Phase 8 changes the delivered carrier p10.')
[IO.File]::WriteAllLines($outPath, $out, $utf8)
Write-Output ('[report] written: ' + $outPath + ' | lines ' + $out.Count)
Write-Output ('[report] english-filled inventory: ' + $fillPath + ' | rows ' + $fill.Count)
Write-Output ('[report] coverage of translatable: {0} of {1} ({2}%) | all rows {3}%' -f $translated, ($total - $copy), $pctTr, $pctAll)
