# Cycle 010 report - Batch 1 delivered (25% tranche): 15 chunks, Arabic applied, gates green, carrier p5 built (not installed)

Generated: 2026-10-18 23:38 (local). Repo: C:\AtomicHeart-AR. Nothing uploaded; git remote list empty.

## What this cycle did

1. Browser-planned batch 1 exactly as `reports/translation_plan.md` orders it: scope set =
   NewP5 (5,597) + Misc (21) + PearTerminals (545) + Academy_Dialogues (282) + the first 460 rows
   of Chelomey_Dialogues = **6,905 rows** of the 27,618-row total (25% row cutoff confirmed).
   Unique English in that set: **4,562**; already translated before this cycle: 68; to author: **4,494**.
2. Split the 4,494 strings into **15 chunks** of 300 (last chunk 294) with stable ids `u0001..u4562`
   (`scripts/batch_plan.ps1` writes `localization/working/batch1/{rows.tsv,unique.tsv,chunk_NN_en.tsv}`).
   IDs exist so Arabic can never be mis-matched to an English row by retyping.
3. Authored the Arabic with 15 translator sub-sessions, one per chunk, against a written contract
   (`localization/working/batch1/BRIEF.md`) plus the authoritative glossary and the union TM.
   Each chunk produced `chunk_NN_ar.tsv` (id -> Arabic, UTF-8) and `chunk_NN_notes.md`.
4. Checked every chunk with `scripts/batch_check.ps1` before it reached the master: id set and order,
   non-empty Arabic, U+FFFD, and byte-exact preservation of `<tag>`s, `{placeholders}`, `&Speaker&`
   labels, `*0.10*` timing markers, `%` and `||` counts. 15/15 chunks PASS.
5. Applied chunk by chunk to the master with `scripts/batch_apply.ps1` (Status=DRAFT, note `batch1`),
   reusing the union TM for strings already translated elsewhere, and never touching a row outside
   the batch-1 scope set or a row that already carried Arabic.
6. Ran `scripts/validate_translation.ps1` after every application; every error was fixed before the
   next chunk. Final state: **0 errors**.
7. Quality pass: 15 rows whose Arabic ends in a trailing space were trimmed (the locres round-trip
   strips trailing whitespace, so they broke the byte-identical check); 4 rows using a transliterated
   "Neuropolymer" were aligned to the glossary form; 86 UI rows whose Arabic was more than 1.4x the
   English length were shortened by a dedicated copy pass (guard: tags, placeholders, digits,
   `%`, `||` must survive; glossary terms and proper names left alone).
8. Rebuilt the carrier as **p5** with the unchanged builder: all 35 ko-KR scopes, 0 round-trip
   failures, 35/35 unpack byte-identical. **NOT installed.**

## Numbers (measured, not estimated)

| metric | value |
|---|---|
| Master rows | 27,618 |
| Rows with Arabic (batch 1 end) | **6,564 of 27,618 (23.77%)** |
| Unique English with Arabic | **4,426 of 19,996 (22.13%)** |
| Status DRAFT / UNTRANSLATED | 6,564 / 21,054 |
| Batch-1 scope set | 6,905 rows |
| Batch-1 rows translated | 6,527 |
| Batch-1 rows intentionally left as-is (copy class) | 378 |
| Distinct English authored in batch 1 | 4,426 |
| Chunks / chunk size | 15 / 300 (last 294) |
| English characters authored | 340,101 (before translation) |

Coverage per category (rows with Arabic): UI 5,890 | Dialogue 671 | Subtitles 3.
Coverage per scope: NewP5 5,332 | PearTerminals 539 | Chelomey_Dialogues 382 | Academy_Dialogues 259 |
Misc 19 | DIALOGUES FOR LQA 7 | Vavilov_Dialogues 6 | VDNKh_Dialogues 6 | Theatre_Dialogues 4 |
Schebetar_Subs 3 | OpenWorldVDNKh_Dialogues 3 | Pavlov_Dialogues 3 | Polygon_Dialogues 1.

## Defects found and handled

| # | defect | evidence | fix |
|---|---|---|---|
| 1 | `scripts/batch_plan.ps1` crashed: `-f` inside a method-argument list is parsed as extra arguments | line 84 error, batch_plan ran 2x | build the row line with `-join` |
| 2 | `scripts/batch_apply.ps1 -All` read 0 chunk files (the switch never enumerated them) | `[map] distinct English -> Arabic: 0` | `-All` now enumerates `chunk_*_ar.tsv` |
| 3 | PowerShell `@{}` keys are case-insensitive: `CONSUMABLES` and `Consumables` collided and aborted the apply | `conflicting Arabic for the same English string: Consumables` | map is now `Dictionary[string,string]` (ordinal) |
| 4 | The same case-insensitivity in `batch_plan.ps1` set the "already translated" flag on the wrong entry, so `Off` (mixed case) was never sent to a chunk | `missing_english.tsv` contained `Off` | `On/Off` row supplied via `localization/working/batch1/extra_ar.tsv` (new override input for the applier) |
| 5 | Pure-format strings whose only Arabic character was the comma `{Class},  {Message}` were applied, then failed the validator (`Arabic contains no Arabic letter`, 17 rows) | validator lines 11021-11037 | checker and applier now use the validator's Arabic-letter class; stale values are reset to UNTRANSLATED and such rows are recorded as copy-class |
| 6 | 15 Arabic rows ended in a space; the locres round-trip strips trailing whitespace, so the p5 build failed with 15 mismatches | first p5 build: `round-trip validation failed: 15 mismatches` | `scripts/trim_trailing_ws.ps1`; second build: 0 failures |
| 7 | 4 rows used transliterated `Neuropolymer` instead of the glossary form | validator glossary warnings | data fixup appended to `localization/working/tm_fixups.tsv` (KI-021 compliant) |

## Gate results

| gate | result | evidence |
|---|---|---|
| Spec hash | PASS (CONFIRMED) | `579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35` unchanged |
| Validator `validate_translation.ps1` | **PASS, 0 errors**, 197 warnings (number 15 / length 112 / glossary 70) | `reports/translation_validation.md` |
| Chunk gate `batch_check.ps1` | PASS 15/15 chunks | console + `chunk_NN_copy.tsv` |
| Glyph gate `glyph_gate.ps1 -AllowSourceInheritedNonLatin` | **PASS**: 148 distinct codepoints, 0 introduced by the Arabic, 5 source-inherited exemptions | `reports/glyph_gate.md` |
| Round-trip (carrier builder) | **PASS**: 35/35 scopes, 0 failures, 35/35 unpack byte-identical | `reports/carrier_build.md` |
| Reference regeneration | PASS: 6,564 rows / 4,426 unique / 13 scopes | `localization/references/AR_EN_REFERENCE.md` (1,499,581 B) |
| 40-row review sample | PASS: 20 spread + 15 tagged + 5 longest rows (37 UI / 3 Dialogue) | `reports/review_sample.md`, embedded in `HANDOFF.md` |

The 5 source-inherited codepoints are U+0410, U+041A, U+0445 (Cyrillic letters that the English
source itself uses in designations like `workshop 308-А`, `КS-23`, `12х70`) and U+202F, U+2060
(invisible format characters in one obfuscated BEA-D string). They are inherited from the source,
the engine renders them through its fallback face today, and the Arabic introduced none of them
(DEC-027).

Warning classes left open on purpose: 112 UI length warnings above 1.2x (only 9 above 1.4x, and 8 of
those are proper names or glossary terms), 70 glossary warnings (mostly plural forms such as
`الخراطيش` for `Cartridge`, or `Shotgun` inside `4 shotgun shells`), 15 number warnings (numbers
that legitimately became Arabic words, e.g. `13th day` -> `اليوم الثالث عشر`).

## Copy-class rows (intentional, not translated)

170 distinct English strings (378 rows) are byte-identical in English and Arabic by design: bare
numbers and resolutions (`0.2`, `1920x1080`), symbols (`-`, `°`, `º`, `/`), lone tags (`<title>`,
`<value>`), key names (`E`, `Q`, `SHIFT`), model/tech codes (`BP_WayPoint50`, `DLAA`, `FHD (1080p)`,
`Nvidia Reflex`, `BEA-D`), language endonyms (`deutsch`, `italiano`, `español`, `français`,
`português (Brazil)`, `日本語`, `漢語`, `한국어`), gibberish (`d????dsss  ghhg`), pure-format strings
(`{Class},  {Message}`, `{Left} / {Max}`, `x{0}`) and obfuscated Russian words. The validator forbids
Arabic == English, so these rows stay UNTRANSLATED (Status UNTRANSLATED, Arabic empty) and the
carrier fills them from the en-US locres, which is exactly what the English column shows in game.
Evidence: `localization/working/batch1/copy_keep.tsv`.

## Carrier p5

| field | value |
|---|---|
| file | `build/package/zzz_atomicheart-ar_carrier_koKR_p5_P.pak` |
| size | 3,775,007 bytes |
| sha256 | `087f6b640a0f649d605148316a80cb3f51baf94994b4c317c5bd0e910f025a9f` |
| scopes / keys | 35 / 27,618 |
| Arabic / English-filled / kept Korean | 6,564 / 21,054 / 0 |
| round-trip | 26,421 exact + 1,197 newline-only (KI-015 benign class), 0 failures |
| unpack re-check | 35/35 byte-identical |

Installed set right now: carrier p4 + font v2 (unchanged this cycle).

### Exact install command for p5 (reconciling installer; removes p4 hash-verified, keeps font v2)

```
cd C:\AtomicHeart-AR
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\install_mod.ps1 -Carrier p5 -Font p2_plex
```

Then prove it (snapshot before/after): take the before snapshot first, install, then verify:

```
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\snapshot_game_folder.ps1 -Out "$env:TEMP\before_p5.json"
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\install_mod.ps1 -Carrier p5 -Font p2_plex
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\verify_install.ps1 -Before "$env:TEMP\before_p5.json"
```

### Rollback command (back to p4)

```
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\install_mod.ps1 -Carrier p4 -Font p2_plex
```

Both commands remove the superseded carrier only after its on-disk sha256 matches the install
manifest, and never touch the EXE, DLLs, Denuvo files or any stock pak.

## Review focus for you

1. The 40-row sample in `HANDOFF.md` (Arabic first, English below) - spread + tagged + longest rows.
2. `glossary/glossary_questions.md` (new batch-1 section) plus the raw per-chunk notes in
   `reports/batch1_translator_notes.md` (427 lines): weapon nicknames translated vs transliterated,
   `Chai` toast, SHOK derivatives, `Thrift`, animal-named weapon parts, `Fox`, RTX/BIOS/Nvidia kept
   Latin, and the 86 shortened UI labels.
3. Nothing is installed yet: p4 still runs in game, so the game keeps showing English for batch-1
   text until you approve p5.

## Files changed this cycle (all local)

Scripts: `scripts/batch_plan.ps1` (new), `scripts/batch_check.ps1` (new), `scripts/batch_apply.ps1`
(new), `scripts/batch_shorten.ps1` (new), `scripts/apply_shorten_keys.ps1` (new),
`scripts/trim_trailing_ws.ps1` (new), `scripts/glyph_gate.ps1` (added the documented
`-AllowSourceInheritedNonLatin` exemption).
Data: `localization/working/batch1/**` (planner outputs, 15 EN/AR chunk pairs, 15 notes files,
`copy_keep.tsv`, `missing_english.tsv`, `extra_ar.tsv`, `shorten_in/out.tsv`, `BRIEF.md`),
`localization/master/atomic-heart-ar.tsv`, `localization/working/tm.tsv` (102 -> 4,427 entries),
`localization/working/tm_fixups.tsv` (+46 rules).
Reports: `reports/translation_validation.md`, `reports/glyph_gate.md`, `reports/carrier_build.md`,
`reports/text_fixups_log.md`, `reports/review_sample.md`, `reports/batch1_translator_notes.md`,
`reports/cycle010_results.md`, `localization/references/AR_EN_REFERENCE.md`.
Build (not committed): `build/package/zzz_atomicheart-ar_carrier_koKR_p5_P.pak`.
Docs: `HANDOFF.md`, `STATUS.md`, `KNOWN_ISSUES.md`, `DECISIONS.md`, `glossary/glossary_questions.md`,
`lastreport.md`, `reports/history/report_014.md`, `reports/history/handoff_014.md`.
