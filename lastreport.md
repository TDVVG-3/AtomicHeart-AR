# Cycle 014 results — Atomic Heart Arabic localization (text only)

**Date/time:** 2026-10-19, 20:55 +03:00 (Europe/Moscow) · Steam app 668580 · English-sourced, MSA
**Deliverable:** this file (UTF-8; Arabic evidence inline) + `lastreport.md` + `reports\history\report_018.md`

---

## Summary (5 lines)

1. **Coverage 21,220 of 27,618 rows (76.83%)** — up from 13,994 (50.67%) at the start of the cycle;
   **tier 3 (75%) is DONE**.
2. Batch 3 shipped **22 chunks (0017-0038)**: 6,530 ids authored, **7,226 rows filled**, 71 ids
   deliberately left copy-class (numbers, Latin-only, key names, asset ids).
3. **KI-029 closed** (bracket labels now pass the chunk gate) and the validator **glossary matcher was
   rebuilt** (DEC-040): old-corpus glossary warnings 141 -> 2; the 10 remaining are sense cases.
4. Gates are green: validator **0 errors**, glyph gate **0 glyphs introduced by Arabic**, fixup verifier
   PASS after every chunk, carrier round-trip 35/35 with 0 fail.
5. **Carrier p9 built, validated and installed** (4,276,477 B, sha256 `90d41d78…`) with font
   `p2_plex`; `~mods` holds exactly 3 files; rollback is `-Carrier p8`.

---

## 1. Coverage

| metric | value |
|---|---|
| master rows | 27,618 |
| rows with Arabic (DRAFT) | **21,220** |
| coverage | **21,220 of 27,618 (76.83%)** |
| English-fill rows (no Arabic yet) | 6,398 |
| kept-Korean rows | 0 |
| TM entries | 15,410 (was 9,132) |
| next unauthored plan id | **b11109** |

Tiers: 25% (6,905) DONE · 50% (13,809) DONE · **75% (20,714) DONE** · 100% (27,618) in progress.

## 2. Chunks applied this cycle

| phase | chunks | ids authored | rows filled | coverage after |
|---|---|---|---|---|
| KI-029 label chunk | 0016 | 1 | 5 | 13,994 (50.67%) |
| wave 1 (DLC2 subs / Mails / NTD) | 0017-0021 | 1,484 | 1,961 | 15,955 (57.77%) |
| wave 2 (Mails / DLC1 / LQA) | 0022-0026 | 1,493 | 1,589 | 17,544 (63.52%) |
| wave 3 (DLC1 / NTD / upgrades) | 0027-0031 | 1,452 | 1,543 | 19,087 (69.11%) |
| wave 4 (Limbo / NTD / Triton) | 0032-0036 | 1,500 | 1,529 | 20,616 (74.65%) |
| tail | 0038, then 0037 | 600 | 604 | **21,220 (76.83%)** |
| **total** | **23 chunk ids** | **6,530** | **7,226** | — |

Each apply reported `conflicts: 0` and `chunk strings with no master row: 0`. Chunk 0030 contributed
the largest copy-class block (47 rows: pure numbers, `x{mult}`, `BP_WayPoint*` asset ids).

## 3. Gates

| gate | command | result |
|---|---|---|
| chunk gate | `batch2_chunk.ps1 -ChunkId NNNN` | PASS for all 23 chunks (first or second attempt) |
| master validator | `validate_translation.ps1` | **PASS** — 27,618 rows, 21,220 translated, **0 errors**, 215 warnings |
| warning split | — | number 93 / length 112 / glossary 10 (all triaged, see §5) |
| glyph gate | `glyph_gate.ps1 -AllowSourceInheritedNonLatin` | **PASS** — 164 codepoints, 15 source-inherited, **0 introduced by Arabic** |
| fixups | `verify_text_fixups.ps1` | **PASS** — 83 rules, 0 stale |
| trim | `trim_trailing_ws.ps1` | 0 rows trimmed |
| carrier round-trip | `build_carrier_locres_pak.ps1 -VariantLabel p9` | 35/35 scopes, arabic 21,220, english 6,398, korean 0, **fail 0**, unpack byte-identical 35/35 |

## 4. Defects found by the gates and fixed (11 rows)

| row | chunk | defect | fix |
|---|---|---|---|
| master L19766 | 0017 | range marker `*0.01-0.28*` missing (old gate pattern only matched single markers) | marker restored; gate pattern aligned to the validator |
| master L7133 | 0018 | date transcribed from the RU asset ("5 июня") while the English row says "June 15, 1955" | follows the English master; divergence logged (KI-032) |
| master L15246 | 0019 | dropped expansion "Polymer-Electronic Autonomous Relay" (kept only the acronym) | expansion restored next to `P.E.A.R.` |
| master L15338 | 0019 | dropped "if a doctor wants" (impersonal rewrite) | restored with the glossary term |
| master L15354 | 0019 | dropped "on Soviet soil" | restored |
| master L15959/15960 | 0021 | `ROUTE TERMINAL` rendered "المسار: الاتجاه" | "محطة المسار" (RU for the key is just "ПУТЬ") |
| 3 rows | 0017/0027 | literal mistranslation of the recurring expletive ("crispy pastries") | unified to the established expletive via `tm_fixups.tsv` |
| master L20355 | 0031 | Arabic carried a leading space the locres cannot store | trimmed; build now tolerates + logs edge whitespace only |

Tooling fixes shipped with these: chunk-gate marker pattern; `-VariantLabel` now derives the carrier
output path; edge-whitespace-only round-trip tolerance; the rewritten glossary matcher (DEC-040).

## 5. Quality notes

* **Copy-class policy held**: 71 ids omitted with an empty Arabic cell (pure numbers, Latin-only words,
  key names, asset ids, marker-only lines). Nothing was left as untranslated English in the Arabic column.
* **Number warnings (93)** are Arabic word-numbers (`50` -> خمسين, `3D` -> ثلاثية الأبعاد,
  `17th` -> السابع عشر) or unseparated digits; each class was sampled and verified, no defect.
* **Length warnings (112)** are Arabic verbosity over 1.6x English (advisory; KI-026 still open).
* **Glossary warnings (10)** are sense/form cases, reviewed row by row and kept (KI-033):
  `Terminal` x6 (evolutionary branch, cargo terminal, communications terminal, route terminal - the
  glossary form محطة طرفية is the computer sense), `Major` x3 (Sergeant Major / "Major depression"),
  `Upgrade` x1 (verb in dialogue = تطوير, noun/UI = ترقية).
* **New authoring input**: `scripts\batch2_sheet.ps1` produces `sheet_<nnnn>.tsv` with the official
  Russian reference resolved per key — including readable string-table keys (`NTD_StringTable/…`),
  which the earlier generator skipped. Every chunk this cycle had 300/300 Russian references available.
* **EN/RU asset divergences** (KI-032) surfaced while authoring: "June 15" vs "5 июня";
  "Marina" vs "Леночка"; "Monday starts on Sunday" vs «суббота»; "Rachel" vs "Дина";
  "BATTLING ORIOLES" vs «скворцы». Policy used: the **English master is the factual anchor**, the
  Russian is the register/flavour reference.

## 6. Decisions and known issues

| id | text |
|---|---|
| DEC-039 | bracket-label gate exception (closes KI-029): non-bracket tokens byte-exact, `[...]` counted, Arabic allowed inside |
| DEC-040 | glossary matcher rebuild: normalisation, accepted forms (`a\|b\|c`), `cs` flag, prose-only English side |
| DEC-041 | batch-3 authoring contract (sheets with RU/TM), gate/validator marker alignment, carrier path/edge-ws fixes |

| id | state | note |
|---|---|---|
| KI-029 | **FIXED** (cycle 014) | `[Leave]` -> `[مغادرة]` shipped; 3 tamper cases still fail; 7 technical ids kept Latin on purpose |
| KI-030 | open, docs only | 2-3 `Major` warnings, benign |
| KI-031 | new, cosmetic | `<...>`-lookalike text stays Latin (1 row, e.g. `<- ALCOHOL ->`) |
| KI-032 | new, informational | en-US vs ru-RU divergences; English anchor used |
| KI-033 | new, docs only | 10 residual glossary warnings, sense/form cases, reviewed and kept |
| KI-009/013/017/018/022/026/027/028 | open | unchanged: GameTips untested, native `ar` list, RU-only assets (6,012 strings), UI fit, label candidates, choice-separator cosmetic |

## 7. Carrier p9 (installed)

`zzz_atomicheart-ar_carrier_koKR_p9_P.pak` — 4,276,477 B —
sha256 `90d41d78bdd5744ab2cae63980fa7b1376fd3a449c5987fbf9ac143e8f887de0`
font `zzz_atomicheart-ar_font_p2_plex_P.pak` — 1,461,408 B — sha256 `02b17f31…`
manifest `atomic-heart-ar-install-manifest.json` — sha256 `008cc3bc…`

* `~mods` holds exactly these 3 files; in-game language stays **Korean**.
* Rollback: `install_mod.ps1 -Carrier p8 -Font p2_plex`.
* **Honest note:** the first p9 build overwrote the (intermediate) `p3` carrier because
  `-VariantLabel` did not drive the output path. The stray file was removed, the script fixed, and p9
  rebuilt to its own name; p3 is not a documented rollback target (p7/p8 are).
* p9 is **NOT yet play-tested**.

## 8. What I should send back

1. **In-game check of p9** (it is installed): menus/HUD, one DLC2 scene, one NTD sign board and
   subtitles. Note whether subtitles clip or scroll (KI-022) and whether any UI label overflows (KI-026).
2. **"upgrade" in dialogue**: 35 dialogue rows use the verb form تطوير, 46 rows use the noun ترقية.
   Say the word if you want all dialogue unified to ترقية.
3. **EN/RU divergences** (KI-032): keep the English master as the factual anchor (current policy), or
   prefer the Russian canon for dates/names where the assets disagree?
4. **Bracket labels**: now unblocked mechanically. Should the 7 remaining technical ids (`FinalDialog`,
   `RANDOM`, `SaidFirst`, …) also be translated, or stay Latin?
5. **KI-031**: may I translate inside `<- ... ->` arrows when the content is prose, not a tag?
6. **Tone pass**: 40 of the 150-row cap used; tell me if you want the remaining 110 rows re-reviewed.

## 9. Next move

Batch 4 — chunks 0039+ from id **b11109**, 300 ids per chunk in plan order, same gates per chunk, to
reach 100% (6,398 rows). Then carrier **p10** + play-test sweep + close-out (ROADMAP milestone 8).
