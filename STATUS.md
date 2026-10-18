# Current State

Status snapshot after Cycle 004 (2026-10-18). Rule: PASS/FAIL/PARTIAL/BLOCKED/NOT TESTED
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
                                            (no font pak; install reverted for now)
Language-list mechanism:                    CONFIRMED (hardcoded 13 records in DA_Audio;
                                            locmeta staging alone can NEVER add a menu entry)
Native-ar route (DEC-015 primary):          PLAN LOCKED (DA_Audio override; build pending)
Carrier fallback (DEC-007, plan b):         PREPARED (ko-KR recommended; needs approval)
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

STOP. Awaiting user's approval/decision on: (1) proceed to BUILD (not install) the
DA_Audio override with a 14th Arabic record; (2) which carrier slot they want as
prepared fallback (ko-KR recommended); (3) the three remaining Test-1 data points
(FPS? exact list contents? voice language in use?). No pak installed meanwhile; game
folder stock except the reverted test-1 state (nothing installed).
