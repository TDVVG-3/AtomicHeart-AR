# Current State

Status snapshot after Cycle 006 (2026-10-18). Rule: PASS/FAIL/PARTIAL/BLOCKED/NOT TESTED
labels only; never claim success without evidence.

```
Phase 1  Repo structure + governing docs:   PASS (committed)
Phase 2  Steam + game detection:            PASS (App 668580, buildid 24534183)
Phase 3  Archive inventory (19 PAKs):       PASS (SHA256-hashed)
Phase 4  Toolchain:                         PASS (repak, UnrealLocres, LocResUtility + .NET 8)
Phase 5  Extraction + master DB:            PASS (565 locres/locmeta; 27,618-row TSV)
Phase 6  Font discovery:                    PASS (49 fonts scanned)
Phase 7  Prototype attempt 1 (v1):          FAIL (Naskh font swap blanks Latin UI; uninstalled)
Phase 7  Test 1: locres-only pak:           RESULT B: game boots normally, NO Arabic option
                                            (not a pak failure - list is hardcoded; NORMAL FPS
                                            confirmed by user in cycle 004 answers)
Language-list mechanism:                    CONFIRMED (hardcoded 13 records in DA_Audio;
                                            locmeta staging alone can NEVER add a menu entry)
Native-ar route (DEC-015 primary):          BLOCKED this cycle: DA_Audio is UNVERSIONED/tagless
                                            -> needs schema tooling (Phase 8 work item)
Carrier pak (DEC-007 ko-KR slot):           BUILT + validation PASS, NOT installed
                                            (25/25 Arabic round-trip; controls unchanged Korean)
Voice-culture evidence:                     CONFIRMED (retail VO only en-US + ru-RU; other
                                            slots fall back to en-US)
Font v2 (IBM Plex Sans Arabic):             BUILT, verified, NOT installed
Mod loading pipeline:                       PASS (boots + applies overrides)
RTL rendering test:                         NOT TESTED
```

## Key findings this cycle (Cycle 004)

1. **Why Test 1 showed no Arabic (root cause CONFIRMED, mechanism-level)**: the Options >
   Language menu is a hardcoded 13-record list inside the cooked DataAsset
   `Core/Data/Settings/DA_Audio.uasset/.uexp` (docs/LANGUAGE_SELECTION.md). LocMeta
   staging can never populate this menu, therefore a modified locmeta alone could not
   have produced an Arabic entry in any test configuration. NOT a failure of our pak.
2. Both DA_Audio and its consumer list (`+ConfigurableSettings` in the cooked
   `Config/DefaultGame.ini`) are ordinary pak files - overridable from `~mods` with no
   EXE change. DEC-015: native `ar` via DA_Audio override = PRIMARY; DEC-007 carrier
   = prepared fallback (candidates: ko-KR recommended, zh-TW, uk-UA; approval needed).
3. Voice evidence (DA_Audio_VoiceBanks): retail VO exists only for en-US and ru-RU.
   Every other slot's audio mapping falls back to en-US -> carrier slots and the new
   `ar` record both keep the English voice intact by design.
4. `-log` produced NO engine log even when active (KI-012 closed as negative result).
5. zh cultures carry distinct Wwise aliases (zh-hans / zh-hant) inside the same records -
   the list's records are per-language OptionSelect entries with display name +
   culture + audio alias, all inline strings.

## Next

Cycle 005 complete except Test 3. Test 2 (carrier koKR p1 + font v2) gave outcome D
(partial): user hypothesis CONFIRMED - untranslated ko-KR strings are Korean and the
replacement Plex faces have zero Hangul -> blank labels; Russian labels survive via
faces we never swapped (Cyrillic-capable: BlenderPro 94, Gotham 170, BrutalType 94,
RobotoMono/Roboto 255; evidence reports/font_glyph_coverage.txt + font_block_probe.txt).

Built this cycle (NOT installed): carrier p2
(zzz_atomicheart-ar_carrier_koKR_p2_P.pak, 503,841 bytes, SHA256 3d4b0ea6...) with the
English-fill policy (DEC-016): 25 Arabic seed keys + 5,572 en-US-filled keys + 0 kept
Korean of 5,597 total; round-trip 0 failures (5,541 byte-exact, 56 newline-normalized
only - KI-015). Glyph gate upgraded with Cyrillic/Hangul enforcement (DEC-016).

## Test 3 result (in progress - user reports arrive in parts)

**Main menu: outcome A (2026-10-18, user screenshot). CONFIRMED:** the five menu buttons
(Continue / New game / Load game / Options / Exit) render as correct Arabic - letters
connected, right-to-left order correct, Latin text readable. This is the first positive
proof of Arabic rendering in-game (font v2 + carrier p2 stack working). Settings pages
and GameTips popups are NOT yet checked; Test 3 stays open until the user reports them.

Test 3 = carrier p2 + font v2, select ko-KR, verify Arabic in GameTips popups and
settings captions (Balanced/On/Off/Fullscreen), untranslated text now English instead
of blank. Awaiting user's go: `scripts/uninstall_mod.ps1` then install Test-3 set.

## Cycle 006 - dialogue/cutscene text program (batch 1 of 4)

```
Step A  Spec hash check:                    PASS (579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35)
Step B  Cooked-asset count pass (4,325):    PASS (4 workers, 23 min, 4,325 rows, 0 fetch failures, 0 stderr)
Step C  Decoder verification (Cyrillic):     PASS ("Все на перевыборы советов" decoded, no mojibake)
Step D  Prose filter (DEC-019):              PASS (over-extraction 5,005,978 -> 111 EN / 5,903 RU prose strings)
Step E  Inventory + TOTAL (DEC-020):        PASS (TOTAL = 10,505; reports/dialogue_inventory.md)
Step F  RU-only separation (KI-010 class):  PASS (246 assets / 5,903 strings -> reports/dialogue_ru_only.md, excluded from TOTAL)
Step G  Batch 1 apply (25%):                PASS (covered 2,626 of 10,505 (25%); added 0 new rows since batch 1 lies entirely in locre scope; already present 2,626; retag 3,286 Category values)
Step H  Validator (batch 1):                PASS (0 problems; UTF-8 no U+FFFD; no NEW duplicate ids; 27,618 rows)
Step I  Batch 2 apply (50%):                PASS (covered 5,253 of 10,505 (50%); added 0; already present 5,253; retag 2,152; DIALOGUES FOR LQA now complete; Schebetar_Subs 361 retagged from "Unknown" to Subtitles)
Step J  Validator (batch 2, idempotent re-run): PASS (0 problems; retag 0; master untouched; 27,618 rows)
Step K  Batch 3 apply (75%):                PASS (covered 7,879 of 10,505 (75%); added 0; already present 7,879; retag 3,719 = Vavilov 2,427 + VDNKh 1,292; Theatre_Dialogues complete)
Step L  Validator (batch 3, idempotent re-run): PASS (0 problems; retag 0; master untouched; 27,618 rows)
Step M  Batch 4 apply (100%), first attempt: FAIL (added 111 rows; validator caught 111 rows with 14 fields - PowerShell comma-binds-tighter-than-'+' bug in the row builder; also those 111 strings were Cyrillic, not English)
Step N  EN-source classifier corrected (DEC-021): PASS (EN cooked assets 0; RU-only 248 assets / 6,012 strings; obfuscated 1; TOTAL corrected to 10,394)
Step O  Bogus rows removed from master: PASS (exactly 111 rows with Status NEW + 'cooked asset scan' deleted; rows 27,729 -> 27,618)
Step P  Batch 4 re-run on corrected TOTAL: PASS (covered 10,394 of 10,394 (100%); added 0; already 10,394; retag 0)
Step Q  Final coverage + validator: PASS (all 14 scopes canonical on disk; Cutscene 1,261/1,261, Dialogue 8,772/8,772, Subtitles 361/361; base 9,157 + DLC1 421 + DLC2 816 = 100%; 0 problems, 27,618 rows)
```

Facts:
- Dialogue/cutscene coverage is COMPLETE: 10,394 of 10,394 (100%) of the English-source
  inventory (14 en-US locre scopes). All are already-present master rows (Category
  canonicalized); no translation performed.
- Corrected scope picture (DEC-021): the en-US locres are the ONLY English dialogue
  source. Non-locres cooked dialogue assets are Russian-only (248 assets / 6,012 strings,
  KI-018) or obfuscated (1 asset, KI-017, BLOCKED) - none is English.
- Master TSV: 27,618 rows; all 14 dialogue scopes verified canonical on disk.
- Pre-existing master duplicate IDs = 728 (KI-016), unchanged by this program.
- No install/uninstall action this cycle; `~mods` still holds the Test-3 paks (untouched).
- Nothing uploaded; `git remote -v` empty.

## Cycle 006 - Test 3 user results (2026-10-18, user screenshots)

```
Step R  Test 3 Settings page:   PASS  A  ("Window mode" = correct Arabic "ملء الشاشة",
                                          connected letters, RTL correct, Latin readable)
Step S  Test 3 Dialogue:        PASS  A (rendering)  Subtitles visible and readable,
                                          showing KOREAN (dialogue not translated yet).
                                          Quest title + objective show English fill,
                                          no blanks anywhere on screen.
Step T  Test 3 GameTips popup:  NOT TESTED (user could not reach one in this pass)
Step U  Subtitle font check:    PARTIAL/UNKNOWN - see KI-009 and DEC-022
```

Facts from the user's Test 3:
- Settings Arabic = outcome A; no blank labels; Latin readable (English-fill carrier works).
- HUD/quest text = English fill, no blanks (carrier p2 works outside the seeded labels).
- Dialogue subtitles render and are legible, but in Korean (expected: dialogue is not
  translated yet). The user observed Hangul rendering, which means the subtitle glyphs
  did NOT come from an Arabic-only (Latin+Arabic) face.
- User conclusion recorded verbatim as an observation: the subtitle font is NOT one of
  the 6 faces the v2 font pak replaces; Arabic support for the subtitle font = UNKNOWN.
- Project finding (evidence, DEC-022): the subtitle text widget resolves its FontObject
  to `/Game/Development/UI/Fonts/BlenderPro-Medium_Font` (WBP_TypingTextBox, the parent of
  WBP_OneSubtitle / WBP_NPCSubtitle; DT_Game_Text_Style also points at
  BlenderPro-Medium_Font). BlenderPro-Medium.ufont IS in the v2 replace map, so the
  subtitle face already carries Plex Arabic (42/42). The Hangul the user saw is the
  engine GLYPH FALLBACK (DroidSansFallback / NotoSansKR cover Hangul), not the subtitle
  face itself. Net: Arabic subtitles are expected to render; the pilot is the test.
- GameTips: still NOT TESTED; stays open.


## Cycle 007 - Arabic translation program: Phase 0 + pilot build (2026-10-18)

```
Phase 0 step 1  TOTAL definition:            PASS  TOTAL = 27,618 rows / 19,996 unique
                                                   English strings (TECHNICAL 0, BLOCKED 0)
Phase 0 step 2  work order + cutoffs:        PASS  scripts/translation_plan.ps1 -> reports/
                                                   translation_plan.md (deterministic)
Phase 0 step 3  glossary (before translating): PASS 136 entries, all DRAFT, all verified
                                                   present in the corpus; 26 open questions
                                                   for the user (glossary_questions.md)
Phase 0 step 4  style guide:                 PASS  glossary/terminology.md (MSA, tone map,
                                                   digits, punctuation, tags, length, TM,
                                                   Status workflow, validation gates)
Pilot step 5    pilot translation (60 rows): PASS  20 UI + 20 short + 20 long (57 unique
                                                   strings) + 25 phase-7 seeds = 85 rows
                                                   with Arabic, all Status DRAFT
Pilot step 5b   validator:                   PASS  0 errors; 1 accepted length warning
                                                   (proper name H. P. Lovecraft)
Pilot step 6    subtitle font + glyph gate:  PASS  reports/glyph_gate.md - all 113 distinct
                                                   codepoints of the pilot Arabic present in
                                                   BlenderPro-Medium (subtitle face); no font
                                                   pak extension required
Pilot step 7    carrier builder extended:    PASS  scripts/build_carrier_locres_pak.ps1 now
                                                   builds ALL 35 ko-KR scopes (was NewP5 only)
Pilot step 7b   pilot pak p3 built:          PASS  35 scopes / 27,618 keys / 85 Arabic /
                                                   27,533 English-filled / 0 kept Korean;
                                                   round-trip 0 failures; unpack verify
                                                   35/35 byte-identical. NOT INSTALLED.
Pilot step 8    pilot checklist + handoff:   PASS  reports/pilot_in_game_checklist.md,
                                                   HANDOFF.md rewritten, committed locally
Pilot gate      user in-game report:         NOT TESTED  waiting for the user
```

Facts:
- Master rows with Arabic: 85 (60 pilot + 25 seeds). Coverage: 85 of 27,618 (0.3%).
- Translation memory: 82 unique English strings (57 pilot + 25 seed), localization/working/tm.tsv.
- DEFECT FOUND AND FIXED before shipping: the installed carrier p2 carried malformed
  rich-text tags in the 7 seeded game tips (KI-019). p3 carries the corrected tags.
- Translation unit = unique English string (DEC-023); 27,618 rows reduce to 19,996 units,
  so reuse across identical strings is accounted for from the start.
## Cycle 008 - Pilot install (p3) + reviewer fixes + speaker-marker check (2026-10-18)

```
Cycle open      spec hash guard:             PASS  579f581e5bb8caae2aff6ef60326f1f461688f1b
                                                  1392391a56a97a6148a61c35 (unchanged)
User task 1a    uninstall old carrier p2:    PASS  removed hash-verified against the old
                                                  manifest (sha256 3d4b0ea65c5dc789...5fa9e1)
User task 1b    install carrier p3:          PASS  installed; sha256 b58029662e5acf77...f7b41df
User task 1c    keep font pak v2:            PASS  untouched; sha256 02b17f31e61a46dd...8269747
User task 1d    verify manifest + ~mods:     PASS  ~mods holds exactly carrier p3 + font v2 +
                                                  manifest (sha256 346abd7f291f36d7...5298bd)
User task 1e    nothing else changed:        PASS  reports/install_verification.md - 0 files
                                                  added/removed/changed outside ~mods; EXE
                                                  unchanged; 19/19 stock paks unchanged
User task 2     Python validator:            CLOSED by user decision - PowerShell validator is
                                                  primary; KI-020 closed (Python not needed)
User task 3     glossary questions:          PASS  all 26 recommended defaults ACCEPTED;
                                                  sensitive terms to be reviewed after batch 1
User task 4a    fix (grammar tanfukh):       PASS  2 rows (Theatre_Dialogues + its identical
                                                  DIALOGUES FOR LQA sibling, same key)
User task 4b    fix (stealth-kill tip):      PASS  1 row (NewP5 tip); <tag .../> byte-unchanged
User task 4c    fix (Swab -> cotton swab):   PASS  1 row (Schebetar_Subs)
User task 4d    revalidate (no pak rebuild): PASS  validator 0 errors / 1 warning; fixup verify
                                                  PASS (old text gone, master==memory 85/85);
                                                  AR_EN_REFERENCE.md regenerated (85 rows)
User task 5     speaker-marker evidence:     PASS  reports/speaker_markers.md + speaker_marker_
                                                  check.md - 130 rows / 145 tokens, DLC2 only;
                                                  conditional rule added (terminology.md s.10)
User task 6     HANDOFF rewrite + stop:      PASS  Handoff_012 written; waiting for the user
```

Facts:
- Installed set right now in Paks\~mods: carrier p3 + font v2 + manifest. Nothing else.
- Coverage unchanged: 85 of 27,618 (0.3%). Fixes touch existing rows only; no new rows translated.
- The three reviewer fixes are in the master/TM/seed but NOT in the installed p3 (by order:
  "install p3 as built; these fixes go into p4 together with the pilot results").
- Speaker markers exist ONLY in DLC2 "Schebetars" scopes (base game has none).

Next: the user runs the pilot check (reports/pilot_in_game_checklist.md + the speaker-marker
question in reports/speaker_marker_check.md), reports back, and batch 1 starts on "next".

## Cycle 009 - Pilot result recorded + opening-scene Arabic proof build (p4) (2026-10-18)

```
Cycle open      spec hash guard:             PASS  579f581e5bb8caae2aff6ef60326f1f461688f1b
                                                  1392391a56a97a6148a61c35 (unchanged)
User task 0     pilot result recorded:       CONFIRMED  bridge subtitle showed the carrier's
                                                  English where Korean was before -> the ko-KR
                                                  dialogue scopes are read from ~mods at runtime
                                                  (KI-009 updated)
User task 1     scene located:               PASS  scope Chelomey_Dialogues; on-screen row =
                                                  key /DC11CB9A4BFFB0AA5E099DAA4057EEE9
                                                  (master line 289); scene taken as master
                                                  lines 284-324 of the same asset
User task 2     scene translated:            PASS  40 new rows DRAFT + 1 pre-existing pilot row =
                                                  41-row scene; markers byte-exact (validator
                                                  multiset check)
User task 3a    Arabic kept in UTF-8 data:   PASS  localization/working/scene_opening_ar.tsv +
                                                  scene_opening_rows.tsv; scene_apply.ps1 is ASCII
                                                  (KI-021)
User task 3b    master + TM updated:         PASS  master 125 rows with Arabic; TM 82 -> 102
                                                  entries; scene_apply idempotent (2nd run: 40/40
                                                  already identical, 0 appended)
User task 3c    validator:                   PASS  125 of 27,618 rows translated; 0 hard errors;
                                                  2 warnings (1 new number-as-word, 1 pre-existing
                                                  UI length)
User task 3d    glyph gate:                  PASS  113 distinct codepoints; 0 missing in the
                                                  subtitle face and in the union of the 6 faces
User task 3e    AR/EN reference:             PASS  regenerated: 125 rows / 102 unique / 12 scopes
User task 4a    carrier p4 built:            PASS  35/35 scopes; 27,618 keys; 125 Arabic;
                                                  27,493 English-filled; 0 kept Korean; 0
                                                  round-trip failures; 35/35 unpack byte-identical
                                                  sha256 aa894b4468888ac22a3fd3e58619d4cdb70ae24
                                                  a895c35f286b002b2f4132f22
User task 4b    p4 installed (APPROVED):     PASS  reconciling install: p3 removed hash-verified,
                                                  font v2 untouched, manifest rewritten; before/
                                                  after snapshot PASS (nothing else changed)
User task 5     in-game checklist:           PASS  reports/scene_bridge_ingame_check.md
User task 6     HANDOFF rewrite + stop:      PASS  reports/history/handoff_013.md
```

Facts:
- Coverage now: **125 of 27,618 (0.45%)** - 85 pilot rows + 40 new opening-scene rows.
- p4 = p3 + the three cycle-008 reviewer fixes + the 40 new scene rows (all three fixes are now
  in the installed build, so the stealth-kill tip and the surgery line show the corrected wording).
- Subtitle display question: data side CONFIRMED complete; display is marker-driven (the visible
  text began exactly at the 2nd marker boundary); clipping-vs-scroll stays NOT TESTED and is
  checklist item 4. Evidence: reports/subtitle_display_finding.md (KI-022).
- Batches 1-4 still not started; they start on the user's "next".

## Cycle 010 - Batch 1 delivered (15 chunks): Arabic applied, gates green, carrier p5 built (not installed) (2026-10-18)

Batch 1 of 4 is done and everything is committed locally. Nothing is installed: the game still runs
carrier p4 + font v2, so batch-1 text shows English in game until p5 is approved.

```
Step              Item                          Result
Planning          batch row set + unique set    PASS  6,905 rows / 4,562 unique / 4,494 to author,
                                                     15 chunks of 300 (last 294)
Authoring         15 chunk Arabic files         PASS  4,426 distinct strings authored, 15 notes files
Per-chunk gate    scripts/batch_check.ps1       PASS  15/15 chunks, 0 protected-token violations
Master apply      scripts/batch_apply.ps1       PASS  6,564 rows with Arabic (DRAFT), TM 102 -> 4,427
Validator         scripts/validate_translation  PASS  0 errors / 197 warnings
Quality pass      glossary + UI shortening      PASS  4 glossary rows aligned, 86 labels shortened
Repair            trailing-whitespace trim      PASS  15 rows trimmed -> round-trip clean
Glyph gate        scripts/glyph_gate.ps1        PASS  0 codepoints introduced by the Arabic (KI-025)
Reference         AR_EN_REFERENCE.md            PASS  6,564 rows / 4,426 unique / 13 scopes
Review sample     reports/review_sample.md      PASS  40 rows (20 spread, 15 tagged, 5 longest)
Carrier build     p5 (not installed)            PASS  3,775,007 B, sha256 087f6b64...f025a9f,
                                                     35/35 scopes, 0 round-trip failures, 35/35 identical
```

Facts:
- Coverage now: **6,564 of 27,618 (23.77%)** rows; **4,426 of 19,996 (22.13%)** unique strings.
- Batch-1 row set accounting: 6,905 rows = 6,527 translated + 378 copy-class left as-is (numbers,
  symbols, lone tags, key letters, model/tech codes, language endonyms, gibberish, pure-format
  strings). Evidence: localization/working/batch1/copy_keep.tsv.
- Every batch-1 row is Status=DRAFT and awaits the reviewer sample.
- p5 = p4 + batch 1. p4 remains installed; the exact p5 install and p4 rollback commands are in
  reports/cycle010_results.md.
- Batch 2 (base dialogue, ~13,809 cumulative rows / 8,648 unique at the 50% cutoff) starts on the
  user's "next"; `scripts/batch_plan.ps1` must switch its occurrence index to a case-sensitive
  dictionary first (KI-023).
- Open after this cycle: user's in-game p4 bridge report, the speaker-marker question, KI-026 (UI
  length, NOT TESTED in game).

## Cycle 011 - Chelomey canal boat scene (D_0072_Sipuha_BringSoda): translated, gated, carrier p6 built AND installed (2026-10-19)

The scene in the user's screenshot is the dialogue asset `D_0072_Sipuha_BringSoda` (Chelomey intro set):
5 text rows plus the speaker labels the asset uses. Installing was explicitly approved this cycle, so
unlike p5 the new carrier is live in the game.

```
Step              Item                          Result
Identification    scene + label source          PASS  D_0072_Sipuha_BringSoda; 8 keys; exactly 1 corpus hit per key
Authoring         scene + labels (data files)   PASS  5 lines + 2 labels, Arabic in UTF-8 data files only
Apply             apply_scene_labels.ps1        PASS  5 scene rows + 818 label rows; 0 mismatch, 0 conflict
Validator         validate_translation.ps1      PASS  0 errors / 197 warnings (unchanged)
Glyph gate        glyph_gate.ps1                PASS  0 codepoints introduced by the Arabic
Reference         AR_EN_REFERENCE.md            PASS  7,387 rows / 4,431 unique / 19 scopes
Review sample     review_sample.ps1             PASS  40 rows
Carrier build     p6                            PASS  3,775,256 B, sha256 b7dbb14e...c321, 35/35, 0 failures
Install           install_mod.ps1 (APPROVED)    PASS  p4 removed hash-verified; font v2 kept; manifest rewritten
Verify            verify_install.ps1            PASS  0 changes outside ~mods; exe unchanged; stock paks 19/19
```

Facts:
- Coverage now: **8,981 of 27,618 (32.52%)** rows; **4,947 of 19,996 (24.74%)** unique strings.
- Speaker labels: CONFIRMED displayed to the player in this scene (in brackets) and they are ordinary locres
  rows referenced by the dialogue asset - not `&Speaker&` markers (which stay DLC2-only, DEC-025). `Computer`
  -> `الحاسوب` (138 rows) and `Char-les` -> `تشارلز` (745 rows) now carry ONE Arabic each in every scope;
  `P-3` (1,140 rows) stays Latin by the copy-class rule. Glossary + TM updated (TM now 4,432).
- Installed: carrier p7 (`d7cddff4...`), font v2 (`02b17f31...`), manifest (`8685264a...`). Rollback:
  `install_mod.ps1 -Carrier p6 -Font p2_plex` (or `-Carrier p5` for the batch-1 build).
- In-game checklist: `reports/scene_cycle012_ingame_check.md`.
- Batch 2 STARTED (cycle 012): order rule DEC-029 (game progression, data-driven from the subtitle-table
  dumps), plan in `localization\working\batch2\plan_unique.tsv`, chunk 1 (306 strings / 330 rows) applied as
  DRAFT. Resume at id `b0309`. Batch 1 + 2 stay DRAFT.
- Open: in-game report for p7 (does `[ Char-les ]` show Arabic; do other labels), KI-022 clip-vs-scroll,
  KI-026 UI fit, KI-027 residual label sweep, KI-018/KI-013/KI-017 Phase 8 blockers.

## Cycle 013 - reviewer style/term fixes + batch 2 to the 50% milestone: carrier p8 built AND installed (2026-10-19)

- **Shipped:** carrier p8 (4,012,829 B, sha256 `dd0391ed...`) + font v2 (`02b17f31...`); `~mods` holds
  exactly 3 files; superseded p7 removed after hash match. Rollback:
  `scripts\install_mod.ps1 -Carrier p7 -Font p2_plex`.
- **Coverage: 13,989 of 27,618 rows (50.65%)** - the 13,809-row (50%) milestone is reached and passed
  (8,981 / 32.52% at the start of the cycle). Unique English 9,130 of 19,996 (45.66%).
- **Reviewer feedback applied:** the soda term was fixed from the Russian source (`газировка` -> `صودا`,
  DEC-034 - vending sign `مياه غازية`, flavours `كريم صودا`/`طارخون`/`ديوشيس`, previous `الغازية`
  retired); 40 already-shipped rows were rewritten for tone with before/after evidence
  (`reports/tone_pass.md`); the spoken-register rule is now standing policy
  (`glossary/terminology.md` section 12, DEC-033); the device name was unified as `«الفكرة»`
  (17 rows, DEC-035).
- **Batch 2 finished:** chunks 0002-0015 (ids `b0309`-`b4508`, 4,189 strings, 5,008 rows) authored on
  the frozen progression plan (DEC-029) under `localization\working\batch2\AUTHORING_BRIEF.md`
  (contract DEC-037); every chunk passed its gate, was applied atomically, 0 conflicts. 11 ids are
  documented copy-class keeps.
- **Gates:** validator 0 errors (277 warnings = number 24 / length 112 / glossary 141, all triaged as
  morphological false positives, DEC-036); glyph gate introduced-by-Arabic 0; carrier 35/35 scopes with
  0 FAIL and 35/35 byte-identical round-trip; trailing whitespace 0; fixups PASS after catching a
  regression (2 rows re-shortened, carrier rebuilt, DEC-038).
- **Docs:** DEC-031..038, KI-028 (cosmetic choice layout) and KI-029 (`[...]` bracket rows cannot pass
  the chunk gate), `reports/cycle013_results.md` = `lastreport.md` = `reports/history/report_017.md` =
  `handoff_017.md`; `AR_EN_REFERENCE.md` (3,269,014 B) and the 40-row `reports/review_sample.md`
  regenerated.
- **Next:** plan id `b4509`; 13,629 rows remaining (11,316 ids) - the DLC scopes, the NTD VDNH sign
  strings and the remaining UI. A p9 build/install happens only with explicit approval.
