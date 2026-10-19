# Cycle 012 results - speaker-label fix + batch-2 opening chunk + carrier p7

- Date/time: 2026-10-19 11:45 local
- Repo: C:\AtomicHeart-AR (local git only; nothing uploaded)
- Verdict: PARTIAL - label fix PASS, batch-2 groundwork PASS, chunk 1 PASS, p7 built + INSTALLED; the 50% row target was NOT reached this turn.

Five-line summary
1. Every speaker-label row across all 35 scopes was inventoried (3,611 distinct name-like values / 9,168 rows) and a curated dictionary gave ONE Arabic per speaker name, applied to 1,264 rows (292 names), 0 conflicts.
2. Batch 2 was re-planned to GAME-PROGRESSION order (DEC-029), derived from the game's own subtitle-table row order, not from the tier grid; the screenshot narration row is plan seq 3.
3. Chunk 1 (306 unique strings of the prologue: boat narration, arrival, aerobics, photo session, Shelley poem, phone pranks) is authored and applied as DRAFT; KI-023 (case-insensitive dictionaries) is fixed.
4. Gates: validator PASS 0 errors / 197 warnings (unchanged baseline), glyph gate PASS (introduced-by-Arabic 0), carrier round-trip 35/35 unpack byte-identical.
5. Carrier p7 built and INSTALLED (font v2 kept); coverage 8,981 of 27,618 (32.52%) rows, 4,947 of 19,996 (24.74%) unique - batch 2 continues at id b0309.

## 1. What was delivered

| Deliverable | Result | Evidence |
|---|---|---|
| Speaker-label inventory (all 35 scopes) | 9,168 rows / 3,611 distinct name-like values | `localization/working/labels/label_candidates.tsv` |
| Curated speaker-name dictionary | 324 translatable entries + 4 documented copy-class keeps | `localization/working/labels/speaker_names.tsv` |
| Label pass applied | 1,264 rows filled, 292 names, 0 conflicts, 510 already-identical | `localization/working/labels/label_apply_report.tsv` |
| Batch-2 order rule (game progression) | documented + scripted | `DECISIONS.md` DEC-029, `scripts/batch2_plan.ps1`, `localization/working/batch2/plan.tsv` |
| Batch-2 chunk toolchain (fixed-id contract) | planner, chunk gate, applier, resumable state | `scripts/batch2_plan.ps1`, `scripts/batch2_chunk.ps1`, `scripts/batch2_apply.ps1`, `localization/working/batch2/state.tsv` |
| Chunk 1 (prologue) | 306 unique strings -> 330 rows, markers byte-exact, 0 conflicts | `localization/working/batch2/ar_0001.tsv`, `chunk_0001.tsv` |
| KI-023 fix | ordinal `Dictionary[string,int]` in `batch_plan.ps1`; ordinal maps in all batch-2 tools | `KNOWN_ISSUES.md` KI-023 |
| Carrier p7 | 3,790,472 bytes, 35/35 scopes, 8,981 Arabic, 0 kept Korean, 0 round-trip failures | `reports/carrier_build.md` |
| Install | p7 installed, p6 removed after hash match, font v2 untouched, `~mods` = exactly 3 files | installer output below |
| Reference + review sample regenerated | 8,981 rows / 4,947 unique / 28 scopes; 40-row sample | `localization/references/AR_EN_REFERENCE.md`, `reports/review_sample.md` |

## 2. Coverage (exact)

- Rows: **8,981 of 27,618 (32.52%)** carrying Arabic, all DRAFT.
- Unique English strings: **4,947 of 19,996 (24.74%)**.
- Batch-2 target for this turn was 13,809 rows (50%). DELIVERED 8,981 (32.52%). The gap is reported honestly: this turn's budget went to the label fix (1,264 rows) plus the batch-2 plan, tooling and gate work, and only chunk 1 of ~21 was authored.
- Untranslated rows remaining in work order: 17,698; unique strings remaining: 15,518.
- Resume point: `localization/working/batch2/plan_unique.tsv` id **b0309** (plan seq 310). No re-planning is needed.

## 3. Speaker labels (KI-027)

Structure confirmed earlier (cycle 011): bracketed speaker names such as `[ Char-les ]` are ordinary locres rows
referenced by the dialogue asset (`WBP_TypingTextBox` -> `WBP_OneSubtitle`/`WBP_NPCSubtitle`), drawn inside
`[ ]` by the widget. Policy (DEC-028): ONE Arabic per speaker name in EVERY scope.

- Dictionary applied with `scripts/apply_speaker_names.ps1`: exact, case-sensitive English match (ordinal), only EMPTY Arabic cells filled, never overwrites, copy-class keeps skipped.
- `P-3` stays Latin (1,140 rows, empty Arabic by the copy-class rule).
- `Char-les` -> CHARLES wording, `Computer` -> the agreed word: 745 + 138 rows were already applied in cycle 011; the 2 remaining DLC4 `CHAR-les` rows are now covered too (they are a different source string, so they needed their own entry).
- Glossary wording wins: `Doctor`, `Ballerina`, `Korolyov`, `Polymorph` (+18 family names), `Nechaev`, `Nechaeva`, `Sergey Nechaev`, `Katya Nechaeva`, `VOV-A6` (kept Latin) were aligned to `glossary/glossary.tsv`; 116 entries that already had batch-1 Arabic adopted that wording instead of churning a shipped row.
- Top names by rows filled: Sechenov 104, NORA 102, Petrov 101, Woman 69, Granny Zina 58, Stockhausen 54, Filatova 49, Ballerina 35, Talking dead man 28, Tereshkova 24, Molotov 23, Scientist 19, Chatty corpse 19, Vavilov 17, Zakharov 15, Talking corpse 13, Vaccinated mutant 12, Teardrop 12, Dead body 11, Lebedev 11, Claire 10, Man 10, Announcer 10, War veteran 9, Chelomey 8 (full list in `label_apply_report.tsv`, 324 rows).
- Left untranslated on purpose and listed for review: technical service ids (`Start`, `NoText`, `SaidSecond`, `FinalDialog`, `RadioReroute`, `Order`), the single `Chariton` row in `Mails_01`, and 2,588 single-occurrence name-like values not yet curated. See `glossary/glossary_questions.md` section 9.

## 4. Batch-2 plan (game progression, DEC-029)

Playback order is DATA-DRIVEN: each base-game dialogue scope has a subtitle DataTable dump
(`localization/extracted/dialogue/pakchunk0-WindowsNoEditor__DT_Subtitles_*.txt` + pakchunk13/14/15/16), and the
FText keys appear in that dump in the table's own row order, i.e. the order the game plays them.

Playback keys extracted: Chelomey 1,101 | CUTSCENES 793 | VDNKh 892 | Vavilov 2,135 | Pavlov 474 | Polygon 199 |
Theatre 336 | OpenWorld 216 | ChelomeyFinal 214 | Academy 104 | Schebetar_Subs 95 | Cutscenes_dlc1 99.
DLC3/DLC4 dumps use readable keys instead of hex, so those scopes fall back to master key order (documented
limitation).

The plan opens exactly with the user's screenshot scene and the screenshot row is a very early entry:

| seq | scope | playback | English |
|---|---|---|---|
| 1 | Chelomey_Dialogues | 0 | P-3 (copy-class, stays Latin) |
| 2 | Chelomey_Dialogues | 1 | I really love this place. Good vibes. |
| **3** | **Chelomey_Dialogues** | **3** | **The Chelomey Complex was built from the ground up to be the ideal comfortable workplace.** |
| 5 | Chelomey_Dialogues | 5 | Can it, glove. I've been here before. |
| 6 | Chelomey_Dialogues | 7 | Will we make it for the speech? |

## 5. Chunk 1 (prologue)

- File `ar_0001.tsv` is keyed by the stable plan id (`b####`), so the English column is copied from the plan by id and can never drift from the master.
- Chunk gate `batch2_chunk.ps1`: 306 entries, hard checks all PASS (unknown/duplicate id, empty Arabic, Arabic cell without Arabic letters, placeholder/timing-marker/tag multiset mismatch). The only two ids skipped in range are the two copy-class rows (`b0001` P-3, `b0034` VOV-A6).
- Timed rows preserved byte-exact: `*0.05*`, `*0.07*`, `*0.08*`, `*0.11*`, `*0.13*` (e.g. `b0266`, `b0298`, `b0300`, `b0301`).
- Applied by `batch2_apply.ps1`: 330 rows filled, 1 already identical, 0 conflicts, 306/306 strings matched a master row.
- Content: the boat narration and P-3/Char-les exchange, the fitness-broadcast drills, the lost-group conversation, the Vova-robot repair job, the speech announcements, the photo-session party, the Shelley "Ozymandias" recitation, the Infokiosk 55 adverts, the phone pranks, the Brown Plague memorial narration.
- Consistency: Char-les speaks as a pompous know-it-all, P-3 as a sarcastic soldier, `Comrade Major` uses the glossary wording, insults kept (e.g. `<dickhead>` rendered as a strong Arabic insult, never sanitised).

## 6. Gates

| Gate | Result | Detail |
|---|---|---|
| Validator | **PASS** | rows=27618 translated=8981 errors=0 warnings=197 (number 15 / length 112 / glossary 70) - EXACTLY the p6 baseline, i.e. zero new warnings |
| Glyph gate | **PASS** | `-AllowSourceInheritedNonLatin`: source-inherited 5, introduced-by-Arabic 0 |
| Round-trip | **PASS** | 35/35 scopes unpack byte-identical; 26,427 values exact + 1,191 newline-only; 0 kept Korean |
| Copy-class | **PASS** | 0 rows with a Latin-only non-empty Arabic; `P-3`, `VOV-A6` remain empty/UNTRANSLATED |
| Reference | regenerated | `localization/references/AR_EN_REFERENCE.md` (1,826,756 bytes, 8,981 rows / 4,947 unique / 28 scopes) |
| Review sample | regenerated | `reports/review_sample.md` (40 rows) |

## 7. Carrier p7 and install

- Built by `scripts/build_carrier_locres_pak.ps1 -PakOut ...carrier_koKR_p7_P.pak -VariantLabel p7`.
- File: `build\package\zzz_atomicheart-ar_carrier_koKR_p7_P.pak`, 3,790,472 bytes, sha256 `d7cddff41ac346d7a28c79646e702bb34c1672d1c3e32f8187fa77983b177d9c`.
- Composition: p6 + 1,264 label rows + 330 chunk rows; 8,981 Arabic + 18,637 English-filled + 0 kept Korean; 35/35 scopes.

Installed `~mods` content (verified after install, exactly 3 files):

| File | Bytes | SHA256 |
|---|---|---|
| `zzz_atomicheart-ar_carrier_koKR_p7_P.pak` | 3,790,472 | `d7cddff41ac346d7a28c79646e702bb34c1672d1c3e32f8187fa77983b177d9c` |
| `zzz_atomicheart-ar_font_p2_plex_P.pak` (font v2, unchanged) | 1,461,408 | `02b17f31e61a46ddba20bea8c4da5be44164173df608d52697f68d27d8269747` |
| `atomic-heart-ar-install-manifest.json` | 1,824 | `8685264a2c6ac4cd55bad7a19d5c6bc49df9fa4e7dd250e686297c202bcf5597` |

- Installer behaviour: `zzz_atomicheart-ar_carrier_koKR_p6_P.pak` was removed only AFTER its hash matched the manifest; the game folder outside `~mods` was not touched; no EXE/DLL/Denuvo file was modified.
- Rollback (one command): `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\install_mod.ps1 -Carrier p6 -Font p2_plex`
- Older rollback targets kept in `build\package\`: p1 (489,923 B), p2 (503,841 B), p3 (3,612,753 B), p4 (3,614,845 B), p5 (3,775,007 B), p6 (3,775,256 B), plus font p1 and locres p1.

## 8. Decisions and issues

| Item | Change |
|---|---|
| DEC-029 | NEW - batch-2 order follows game progression (data-driven playback order); UI scopes last |
| DEC-030 | NEW - speaker names are one curated dictionary; glossary + existing batch-1 wording win |
| DEC-028 | unchanged - one Arabic per speaker name in every scope (now actually satisfied for the curated set) |
| DEC-027 | unchanged - ~300-string chunks, per-chunk gate, DRAFT master, resumable state; fresh batch-2 id space |
| KI-023 | FIXED - ordinal dictionaries in `batch_plan.ps1` and all new batch-2 tools |
| KI-027 | coverage gap CLOSED for the curated set (292 names / 1,264 rows); in-game proof pending |
| KI-025 | unchanged - glyph gate exemption for source-inherited codepoints (introduced-by-Arabic 0) |
| KI-026 | still NOT TESTED - p7 installed, so UI fit is testable now |
| KI-022 | still PARTIAL - subtitle clip-vs-scroll NOT TESTED |
| KI-009 | unchanged - GameTips popups NOT TESTED |
| KI-018 / KI-013 / KI-017 | unchanged - blocked on Phase 8 uasset / DA_Audio / obfuscated asset |

## 9. What I should send back

Please run the short checklist in `reports/scene_cycle012_ingame_check.md`. The three answers I need most:

1. Does `[ Char-les ]` (and a second label such as `[ Computer ]` or `[ Ситчинов ]`/Sechenov) now show in Arabic in the subtitle brackets?
2. Is the opening narration line ("The Chelomey Complex was built from the ground up...") now in Arabic, and does the boat/arrival dialogue read naturally?
3. Anything that is still English, clipped, broken, or a wrong label name - a screenshot and the scene name are enough.

Also useful: whether any `~mods` label overflows its button (KI-026), and whether long subtitles lose their tail (KI-022).

## 10. Honest deviations from the requested turn

- The requested cumulative target was 13,809 rows (50%). Delivered 8,981 (32.52%). Batch 2 was planned, tooled and started (chunk 1), but the remaining ~21 chunks of the prologue-and-onward order were NOT authored in this turn. The turn ends here so the work is delivered and verified rather than left half-applied.
- No work is left running: every script exited, the master, TM, reference, sample, carrier and install are all in a consistent state and the resume point is exact (id `b0309`).
