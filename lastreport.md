# Cycle 011 - Chelomey canal boat scene (`D_0072_Sipuha_BringSoda`): translated, gated, carrier p6 built AND installed

Cycle: **011** | Step: **boat-scene dialogue + speaker labels** | State: **WAITING FOR YOUR IN-GAME REPORT** |
Date/time: **2026-10-19 00:52 (local)** | Repo: `C:\AtomicHeart-AR` | Commits: local only, `git remote -v` empty
Spec hash (MASTER_PROMPT.md): `579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35` - **PASS**, unchanged.

Coverage now: **7,387 of 27,618 rows (26.75%)** with Arabic - **4,431 of 19,996 unique strings (22.16%)**.
Carrier **p6** (p5 + this scene) is built **and installed** (install was approved in the task).

## 0. The task (as received)

1. Find the boat scene with `Would you care for some more soda, comrade?` / `Sure, thanks.` in the master
   and find where the bracketed speaker labels come from, with evidence.
2. Translate the whole scene (all rows of the same dialogue asset, up to ~60) plus the speaker labels it
   uses; speaker names: `Computer` -> Arabic, `P-3` stays `P-3`; one Arabic per speaker name everywhere.
3. Arabic only in UTF-8 data files; apply as DRAFT; validate; glyph gate; regenerate the AR/EN reference.
4. Build carrier p6 = p5 + this scene and **install** it (reconciling, font v2 kept) with before/after
   snapshot proof; report the SHA256 of the three `~mods` files and the rollback command.
5. In-game checklist for a non-developer.
6. Rewrite HANDOFF.md and stop. Batch 2 NOT started.

## 1. Scene identification (evidence)

| what | value | evidence |
|---|---|---|
| Scope / file | `Chelomey_Dialogues` - `AtomicHeart/Content/Localization/Chelomey_Dialogues/en-US/Chelomey_Dialogues.locres` | master row |
| Soda line | key `/E88AEA6244C8D2FDC686A38E266BE551`, EN `Would you care for some more soda, comrade?`, Category Dialogue, was UNTRANSLATED | master row |
| Reply line | key `/528883FC4A40D637D9D14D908CA990FD`, EN `Sure, thanks.`, Category Dialogue, was UNTRANSLATED | master row |
| Owning asset | `AtomicHeart/Content/Maps/Development/Dialogue_Test/Chelomey_Intro/D_0072_Sipuha_BringSoda.uasset` (pakchunk0-WindowsNoEditor) | cooked dump `localization/extracted/dialogue/pakchunk0-WindowsNoEditor__D_0072_Sipuha_BringSoda.txt` |
| Whole corpus check | a regex search for either key across **every** extracted asset dump returns **exactly one hit each** - this asset | `localization/extracted/dialogue/` + `localization/extracted/uasset_text/` |

The asset dump lists the 8 locres keys the dialogue asset uses (5 text lines + 3 label/state keys). It also
carries the Russian source of three of the lines (`Дорогой товарищ, газировки не желаете?`,
`Он исправно исполняет свою функцию.`, `С удовольствием.`) - stored cooked, i.e. the RU-only class (KI-018),
not the English source column; the other two lines exist only in the locres.

Scene size: **5 dialogue lines + 3 keys** = 8 rows, well inside the ~60-row allowance. The scene is not
split over several assets (only `D_0072` references these keys).

## 2. Where the bracketed speaker labels come from (answers the open question)

**They are ordinary locres rows, not `&Speaker&` markers and not a separate name table.**

- The dialogue asset references the speaker's display name as its own FText. Proof: the `D_0072` dump lists
  the key `6EE193DF4F471FAB99A8779B0531AEFA` next to the ASCII string `Computer`, and the master row for that
  key is **EN `Computer`** (Category Dialogue). Likewise `B5B336694BC2A0036C3B6E9EAD7F8B31` -> **EN `Char-les`**.
- The five dialogue lines themselves contain **no** speaker markup (no `&...&`), so the label cannot come from
  the text row. `&Speaker&` markers stay a DLC2-only mechanism (DEC-025, unchanged).
- The `[ ]` brackets are drawn by the subtitle widget (`WBP_TypingTextBox` -> `WBP_OneSubtitle` /
  `WBP_NPCSubtitle`); the data cell is `Computer`, never `[ Computer ]`.
- The asset's other ASCII strings (`Khraz`, `Start`, `DBk3D`) are speaker ids / state names: `Khraz` has no
  player-visible label row in the master, and `Start` (`/2119820E49AFDC57EBF87698DC1427AB`) is a normal
  string that batch 1 already translated (`ابدأ`).

**In-game answer for this scene: the labels ARE shown to the player** (user screenshot, 2026-10-19), so they
are player-visible strings and must be translated through the glossary. Recorded in STATUS.md, KNOWN_ISSUES.md
(extends KI-022) and DECISIONS.md (DEC-028).

## 3. Translations applied (5 lines)

All in `Chelomey_Dialogues`, Status `DRAFT`, note `scene:chelomey-soda`.

| # | key | English (source) | Arabic (what the player sees) |
|---|-----|------------------|-------------------------------|
| 1 | `/E88AEA6244C8D2FDC686A38E266BE551` | Would you care for some more soda, comrade? | هل ترغب بمزيد من الغازية، أيها الرفيق؟ |
| 2 | `/528883FC4A40D637D9D14D908CA990FD` | Sure, thanks. | بالتأكيد، شكراً. |
| 3 | `/5E327C8A4F443D66D60FBFB59385AE4B` | It's just performing its function, Major. | إنه يؤدّي وظيفته فحسب، أيها الرائد. |
| 4 | `/BB484B6B4E2B8844D5ED278C7EDEC145` | I'm sick to death of bots. Always up in my grill! | سئمت من الروبوتات حتى الموت. دائماً تتدخّل في شؤوني! |
| 5 | `/661F874B415EB4AEE6F32294A50FF506` | Now get the hell outta here. | والآن، اغرب عن وجهي! |

Notes on the choices (MSA, tone kept, nothing sanitised):

- `Comrade` follows the glossary (`الرفيق`) in its vocative form `أيها الرفيق`; `Major` follows the glossary
  (`الرائد`) as `أيها الرائد`, the same pattern batch 1 used for `Comrade Major` -> `الرفيق الرائد`.
- Line 4 keeps the exasperation and the casual aggression of `up in my grill`; line 5 keeps the rudeness of
  `get the hell outta here` (`اغرب عن وجهي!`), per the no-sanitising rule.
- Lengths vs English: 38/41, 19/12, 37/38, 53/51, 22/28 characters. Nothing here is a UI label.
- No tags, placeholders, `%`, `||`, markers or line breaks exist in these five rows, so byte-exactness is
  trivially satisfied (the applier refuses any English-cell mismatch anyway).

## 4. Speaker-name policy, glossary and TM

Rule used: **one Arabic per speaker name, everywhere.** The two label texts the scene uses were already
chosen in batch 1 (13 `Computer` and 52 `Char-les` rows); this cycle reuses exactly those strings and fills
every remaining row of the same English text in the whole master.

| English | Arabic (one form) | rows filled now | already identical | rows total in master | scope |
|---|---|---|---|---|---|
| `Computer` | الحاسوب | 125 | 13 | 138 | 14 scopes (Chelomey_Dialogues, ChelomeyFinal_Dialogues, VDNKh, Vavilov, Pavlov, Polygon, CUTSCENES, DLC3/DLC4, ...) |
| `Char-les` | تشارلز | 693 | 52 | 745 | same family of dialogue/cutscene scopes |
| `P-3` | stays `P-3` (Latin) | 0 | 0 | 1,140 left as English by rule | all dialogue scopes |

- `P-3` is a copy-class string: the correct display IS `P-3`, and Arabic == English hard-fails the validator,
  so those 1,140 rows deliberately stay UNTRANSLATED and the carrier fills them from the en-US locres - which
  is exactly `[ P-3 ]` on screen. This is the same policy as batch 1's copy-class rows.
- Glossary: added **`Computer` -> `الحاسوب`** (character, translated; note records that the widget draws the
  brackets and that one Arabic is used in every scope). `CHAR-les`/`CHARLES` -> `تشارلز` already existed and
  matches the batch-1 Arabic.
- TM (`localization/working/tm.tsv`): **4,427 -> 4,432** entries (5 appended for the scene lines, 2 label
  entries already identical, 0 conflicts).
- Tooling: `scripts/apply_scene_labels.ps1` (ASCII-only) reads two UTF-8 data files -
  `localization/working/scene_chelomey_soda_rows.tsv` (scope/key/english/arabic) and
  `localization/working/speaker_labels.tsv` (english/arabic/note). It hard-fails on a missing scene row, an
  English-cell mismatch, an empty Arabic, or a label row whose existing Arabic differs (consistency guard);
  it then refreshes the union TM. A dry run showed 0 mismatches and 0 conflicts before anything was written.

## 5. Gates (all PASS)

```
Step               Item                          Result
Identification     scene + label source          PASS  D_0072_Sipuha_BringSoda; 8 keys; 1-hit corpus search
Authoring          scene Arabic                  PASS  5 rows - localization/working/scene_chelomey_soda_rows.tsv
Authoring          speaker labels                PASS  2 labels - localization/working/speaker_labels.tsv
Apply              apply_scene_labels.ps1        PASS  5 scene rows + 818 label rows (65 already identical);
                                                     0 mismatch, 0 conflict -> master + TM written
Validator          validate_translation.ps1      PASS  rows=27618 translated=7387 errors=0 warnings=197
                                                     (number 15 / length 112 / glossary 70) - unchanged
Glyph gate         glyph_gate.ps1                PASS  7,387 rows with Arabic; 148 distinct codepoints;
                                                     0 codepoints introduced by the Arabic (5 source-inherited, KI-025)
Reference          AR_EN_REFERENCE.md            PASS  7,387 rows / 4,431 unique / 19 scopes
Review sample      review_sample.ps1             PASS  40 rows regenerated (embedded in HANDOFF.md)
Carrier build      p6                            PASS  3,775,256 B, sha256 b7dbb14e...1dc4c321; 35/35 scopes;
                                                     27,618 keys; 7,387 Arabic; 20,231 English; 0 kept Korean;
                                                     26,421 exact + 1,197 newline-only (KI-015 benign); 0 failures;
                                                     35/35 unpack byte-identical
Install            install_mod.ps1 (APPROVED)    PASS  reconciling: p4 removed hash-verified; font v2 kept;
                                                     manifest rewritten
Verify             verify_install.ps1            PASS  outside ~mods: 0 added / 0 removed / 0 changed;
                                                     stock paks 19/19; AtomicHeart.exe unchanged
```

No format repair was needed this cycle: the build had **0 round-trip failures**, so no trailing-whitespace
(KI-024) or newline repair pass was triggered by the new strings.

## 6. Carrier p6 - build and install

Build (unchanged builder, `scripts/build_carrier_locres_pak.ps1 -PakOut ... -VariantLabel p6`):

- `build\package\zzz_atomicheart-ar_carrier_koKR_p6_P.pak`, **3,775,256 bytes**,
  sha256 `b7dbb14e80a926c06d0255919a454747488778de98a1778645d117ef1dc4c321` (= p5 + this scene).
- Report: `reports/carrier_build.md`.

Install (approved) - `scripts\install_mod.ps1 -Carrier p6 -Font p2_plex`, run 2026-10-19 00:49.
`~mods` now contains exactly these three files:

| file | size | sha256 |
|---|---|---|
| `atomic-heart-ar-install-manifest.json` | 1,824 | `ad7164ebe3836bac9e54ea603b96a6517c21309d14327f451e1ebdd4fe9597be` |
| `zzz_atomicheart-ar_carrier_koKR_p6_P.pak` | 3,775,256 | `b7dbb14e80a926c06d0255919a454747488778de98a1778645d117ef1dc4c321` |
| `zzz_atomicheart-ar_font_p2_plex_P.pak` | 1,461,408 | `02b17f31e61a46ddba20bea8c4da5be44164173df608d52697f68d27d8269747` |

- Removed as superseded (only after its hash matched the manifest): `zzz_atomicheart-ar_carrier_koKR_p4_P.pak`.
- Font v2 was **not** touched (hash unchanged since the pilot).
- Nothing in the game folder was modified outside `~mods` (before/after snapshot diff): game root 0/0/0,
  Paks 0/0/0 (19 stock paks before and after), `AtomicHeart.exe` unchanged. Report:
  `reports/install_verification.md`.
- Game language must stay **Korean** during tests (the Arabic rides in the Korean locres slot).

Rollback commands (both pak variants are still in `build\package\`):

```
# back to the build that was installed before this cycle
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\install_mod.ps1 -Carrier p4 -Font p2_plex

# alternative: the batch-1 build (p5), if you want the 25% tranche without this scene
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\install_mod.ps1 -Carrier p5 -Font p2_plex
```

## 7. In-game checklist

See `reports/scene_soda_ingame_check.md` (short, non-developer). Summary: load the save you took the
screenshot from, replay the boat ride in Chelomey City, and check **(a)** Arabic shape and right-to-left
order, **(b)** the bracketed labels `[ الحاسوب ]` and `[ P-3 ]`, **(c)** wrapping on the soda line, and
**(d)** that all five lines are Arabic, not English.

## 8. Coverage

- Rows: **7,387 of 27,618 (26.75%)** carry Arabic (was 6,564 / 23.77%).
- Unique strings: **4,431 of 19,996 (22.16%)** (was 4,426 / 22.13%).
- This cycle added: 5 scene lines + 818 speaker-label rows (both label texts now complete game-wide;
  1,140 `P-3` rows stay Latin by the copy-class rule).
- Everything new is Status `DRAFT`; nothing is marked final.
- Batch 1 (25% tranche) is untouched and still DRAFT.

## 9. Problems found this cycle

1. `KNOWN_ISSUES.md` had a **duplicated header block** (its first 5 lines appeared twice, breaking the table).
   Cosmetic, pre-existing; removed in this cycle.
2. My first corpus search used `Select-String -SimpleMatch` with a `|` in the pattern, so it matched the two
   hex keys literally and reported "no hits" while the keys were in fact present. Re-run without
   `-SimpleMatch` (plain hex regex) it returned exactly one hit per key. Recorded here because a silent
   "no hits" would have wrongly ruled out the asset.
3. No defect in the translation or build pipeline: validator 0 errors, glyph gate 0 introduced, build 0
   round-trip failures, install verified, nothing changed outside `~mods`.

## 10. What I need back from you

- The in-game result of the boat scene (a screenshot of the soda line with its label is enough).
- Anything that looks wrong: a label still in Latin, boxes/tofu instead of letters, wrong order, clipped text.
- Then, on your word, batch 2 (base dialogue; cumulative 13,809 rows / 8,648 unique at the 50% cutoff).
