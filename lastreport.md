# lastreport — Atomic Heart Arabic localization

**Date/time:** 2026-10-20 23:36 +03:00
**Cycle:** 015 closed (batch 4 complete, carrier p10 installed)
**Verdict:** PASS — 100% of translatable rows translated, all gates green, build installed and verified.

---

## Five-line summary

1. Batch 4 is finished: chunks 0039–0054, 4,716 ids, **4,802 rows** filled; coverage 21,220 → **26,022 of 27,618 (94.22%)**.
2. **26,022 of 26,022 translatable rows (100%)** now carry Arabic; the remaining 1,596 rows are copy-class (identifiers, numbers, placeholders, proper names) and stay English-filled by design, each with a recorded reason.
3. Validator **PASS (0 errors)**, glyph gate **PASS (0 glyphs introduced by Arabic)**, text-fixup verifier **PASS (87 rules, integrity 0 mismatches)**, trim 0 rows.
4. Carrier **p10** built (4,473,788 B, sha256 `7fbed3a8…f49393`) and installed over p9 with a snapshot proof; `~mods` holds exactly 3 files; rollback is one command.
5. The gates caught real defects (a silent first-entry loss in the applier, a leaked debug row, three glossary drifts); all are fixed and documented, and nothing is play-tested yet on p10.

---

## 1. What shipped

| item | value |
|---|---|
| carrier | `zzz_atomicheart-ar_carrier_koKR_p10_P.pak` — 4,473,788 bytes |
| carrier sha256 | `7fbed3a87fafb547ecf4a2557a590ae0d7c05da304a3c7f6facb7bb34ef49393` |
| font | `zzz_atomicheart-ar_font_p2_plex_P.pak` — 1,461,408 bytes, sha256 `02b17f31…8269747` (unchanged) |
| manifest | `atomic-heart-ar-install-manifest.json`, sha256 `c34ac3a1…38d474` |
| ~mods | exactly 3 files (carrier, font, manifest); p9 removed hash-verified |
| install proof | `verify_install.ps1 -Before ah_before_p10b.json` → **VERIFY INSTALL PASS, problems 0** |
| rollback | `scripts\install_mod.ps1 -Carrier p9 -Font p2_plex` |
| language slot | Korean (carrier occupies ko-KR) |
| play-tested | **NO** — p10 installed, not played |

## 2. Coverage

| metric | value |
|---|---|
| master rows | 27,618 |
| rows with Arabic (DRAFT) | **26,022** |
| copy-class rows left English-filled | 1,596 |
| translatable rows | 26,022 |
| **coverage of translatable rows** | **26,022 of 26,022 (100%)** |
| coverage of all rows | 26,022 of 27,618 (94.22%) |
| rows needing review (translatable but empty) | **0** |

Per category (all at 100% of translatable):

| category | rows | Arabic | copy-class | coverage |
|---|---|---|---|---|
| Cutscene | 1,261 | 1,137 | 124 | 1,137 of 1,137 (100%) |
| Dialogue | 8,772 | 7,712 | 1,060 | 7,712 of 7,712 (100%) |
| Lore | 3,464 | 3,439 | 25 | 3,439 of 3,439 (100%) |
| Subtitles | 361 | 360 | 1 | 360 of 360 (100%) |
| UI | 6,163 | 5,890 | 273 | 5,890 of 5,890 (100%) |
| Unknown | 7,597 | 7,484 | 113 | 7,484 of 7,484 (100%) |

Per scope: 35 of 35 scopes at 100% of translatable — full table in `reports\coverage_cycle015.md` (section 2 of `reports\cycle015_results.md`).

## 3. Gates (evidence)

| gate | result |
|---|---|
| `verify_text_fixups.ps1` | **PASS** — 87 rules, integrity 85 rows, 0 mismatches, 0 English missing from TM |
| `validate_translation.ps1` | **PASS** — rows 27,618, translated 26,022, **errors 0**, warnings 259 (number 122 / length 112 / glossary 25) |
| `glyph_gate.ps1 -AllowSourceInheritedNonLatin` | **PASS** — 195 codepoints, 46 source-inherited, **0 introduced by Arabic** |
| `trim_trailing_ws.ps1` | 0 rows trimmed |
| carrier round-trip | 27,617 exact + 1 newline-normalised, **0 fail** |
| `verify_install.ps1` | **PASS**, 0 problems, expected file set |

Warning triage: number warnings are word-number renderings and timing markers (sampled, no lost numbers); length warnings are glossary-mandated long terms and documents; the 25 glossary warnings are the accepted sense/form cases of KI-033 (Terminal 7, Major 6, Phasotron 2, Comrade 2, Upgrade 2, plus one each for Argentum, Snowball, Archive, Neuropolymer, Professor, Doctor).

## 4. Defects found and fixed this cycle

1. **Silent first-entry loss (tooling).** `batch2_apply.ps1` began reading `chunk_<id>.tsv` at line 1, so the first entry of *every* chunk was skipped (chunk files have no header). Detected when the residual audit found 623 unique strings still empty although their chunks had run; the bulk was chunks 0053/0054 that had never been applied. Fix: read from line 0, then replay chunks 0039–0054 (idempotent, 1 recovered row). → DEC-042, KI-034 (fixed).
2. **Leaked debug row (content).** NewP5 `english` → `arabic` failed the validator ("Arabic contains no Arabic letter"). Row treated as copy-class: Arabic cell emptied, TM entry removed. → validator back to 0 errors.
3. **Glossary drift (content).** Crystal Complex rendered as a transliteration in 23 DLC4 rows, Sakhalin 2, Kollektiv 3. Unified through `tm_fixups.tsv` rules (Crystal Complex → المجمّع البلوري, ساخالين, كوليكتيف). Glossary warnings 54 → 25. → DEC-046.
4. **Wave-1 authoring defects** (already fixed earlier in the cycle): row 20676 had two invented `<tag id="InputAction…"/>` tags; 3 rows used the non-glossary bare spelling for Chirper; 4 rows re-introduced reviewer-deprecated spellings. All repaired, all re-verified.
5. **7 chunk conflicts** (same English, second nuance in a later chunk): master keeps the first shipped variant; each pair reviewed, differences are stylistic only (e.g. agreement, a kasra), no meaning change.

## 5. Decisions added

| id | decision |
|---|---|
| DEC-042 | Chunk files carry no header — appliers must read from line 0. `batch2_apply.ps1` fixed; all 16 chunks replayed. |
| DEC-043 | The frozen work order is authoritative for order only; coverage comes from the master, and the end-of-cycle copy-class audit (multi-token scan) proves nothing translatable is left empty. |
| DEC-044 | Copy-class definition for coverage accounting (no letters / single identifier / marker / placeholder / brand / debug label); such rows stay English-filled with a recorded reason; the headline number is coverage of translatable rows. |
| DEC-045 | The review sample is stratified 10 long dialogue / 10 short UI / 10 tagged / 10 edge cases, deterministic by hash. |
| DEC-046 | Glossary-unification changes go through `tm_fixups.tsv` (never a direct master edit); the three variant spellings are now permanent rules. |

## 6. Known issues touched

| id | status |
|---|---|
| KI-034 | **FIXED** — first-entry loss in `batch2_apply.ps1`; replay recovered the rows. |
| KI-035 | OPEN (cosmetic, Phase 8) — 220 Arabic cells use straight quotes where the style is guillemets «»; needs a tag-safe pass. |
| KI-036 | OPEN — p10 installed but not play-tested (p9 was never played either). |
| KI-026 | Evidence produced: `reports\ui_length_watch.md` — 5,890 UI rows with Arabic, 5,569 labels, 1,019 labels > 40 chars, longest label 199 chars; 321 document-style cells excluded. In-game fit still NOT TESTED. |
| KI-033 | Residual glossary warnings now 25 (was 10 documented, 54 after batch 4, 25 after unification); all reviewed as sense/form cases. |
| KI-009, KI-022, KI-028 | unchanged — GameTips, subtitle clip-vs-scroll, choice-number placement still NOT TESTED / cosmetic Phase 8. |
| KI-013, KI-018, KI-017 | unchanged — native `ar` entry, 248 RU-only assets (6,012 strings), obfuscated asset: Phase 8 / blocked. |

## 7. Evidence files

- `reports\cycle015_results.md` — full cycle report (coverage tables, English-filled inventory, 30 longest UI labels, gates, defects, questions).
- `reports\coverage_cycle015.md` — per-scope and per-category coverage, copy-class reasons.
- `reports\english_filled_rows.tsv` — all 1,596 English-filled rows with a reason.
- `reports\ui_length_watch.md` — 30 longest Arabic UI labels with English (KI-026).
- `reports\review_sample.md` — 40-row stratified AR/EN review sample.
- `reports\carrier_build.md`, `reports\install_verification.md`, `reports\translation_validation.md`, `reports\glyph_gate.md`, `reports\text_fixups_log.md`.
- `localization\references\AR_EN_REFERENCE.md` — regenerated (6,988,783 B, 26,022 rows, 19,732 unique English, 35 scopes).

## 8. What is NOT tested

- p10 in game: menus/HUD, one DLC2 scene, one NTD sign, subtitles, GameTips popups (KI-009), subtitle clip-vs-scroll (KI-022), UI fit (KI-026).
- Font behaviour for the 46 source-inherited codepoints (Cyrillic/CJK present in the English source); the Arabic introduces none (KI-025).
- Choice number/separator placement (KI-028), Phase 8 widget work.

## 9. What I should send back

1. **Play-test p10** — menus/HUD, one DLC2 scene, one NTD sign, subtitles. Report any clip, overlap, box glyph or English leak (with a screenshot and the scene name).
2. **"Upgrade" in dialogue** — unify the verb to the noun term (ترقية), or keep the split (noun for UI, verb in speech, تطوير)?
3. **EN/RU divergences (KI-032)** — keep the English master as the anchor (current policy) or follow the Russian canon?
4. **Bracket labels** — translate the 7 remaining technical ids or keep them Latin?
5. **KI-031** — may prose inside `<- … ->` be translated?
6. **Tone pass** — extend beyond the 40 of 150 rows reviewed so far?
7. **KI-035** — run the guillemet pass now or in Phase 8?

## 10. Next move

Phase 8 is **not started** and needs your go-ahead: native `ar` language entry (KI-013), RU-only assets (KI-018 / 6,012 strings), choice-number mirroring (KI-028), guillemet pass (KI-035), in-game fit fixes (KI-026). Nothing in Phase 8 changes the delivered carrier p10.
