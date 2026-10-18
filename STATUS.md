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
```

Facts:
- English-source dialogue universe = the en-US locres (10,394 strings, 14 scopes) +
  4 cooked assets (111 strings). Cooked dialogue assets are otherwise Russian-only.
- Master TSV: 27,618 rows before and after batch 1 (only Category values changed).
- Pre-existing master duplicate IDs = 728 (KI-016), unchanged by this program.
- No install/uninstall action this cycle; `~mods` still holds the Test-3 paks (untouched).
- Nothing uploaded; `git remote -v` empty.

