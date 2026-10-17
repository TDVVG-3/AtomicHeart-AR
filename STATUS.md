# Current State

Status snapshot after Cycle 001 (2026-10-18). Rule: PASS/FAIL/PARTIAL/BLOCKED/NOT TESTED
labels only; never claim success without evidence.

```
Phase 1  Repo structure + governing docs:   PASS (committed)
Phase 2  Steam + game detection:            PASS (App 668580, buildid 24534183)
Phase 3  Archive inventory (19 PAKs):       PASS (SHA256-hashed, headers parsed)
Phase 4  Toolchain (5 tools, SHA256):       PASS (portable under tools/bin; UnrealPak NOT OBTAINED)
Git repository:                             PASS (Git 2.55.0.5 installed via winget, user-approved; 9+ commits)
Phase 5  Locres extraction:                 PASS (565/565 locres+locmeta extracted, SHA256 manifest)
Phase 5  Locres -> text pipeline:           PASS (UnrealLocres export proven; 27,618 en-US strings + all-culture locres kept)
Phase 5  Master translation DB skeleton:    PASS (TSV, 13 columns per spec, 27,618 rows UNTRANSLATED)
Phase 5  Non-locres text extraction:        PASS (857 StringTable/DataTable candidates -> text dumps + catalog)
Phase 6  Font discovery:                    PASS (49 font binaries cmap-scanned; Arabic verdicts recorded)
Phase 7  Extraction prototype:              NOT STARTED (awaiting approval)
Arabic translation:                          0 strings (correct: no translation work ordered yet)
RTL rendering test:                          NOT TESTED
Build (mod pak):                             NOT STARTED
```

## Key findings this cycle (Cycle 001)

1. Locres pipeline proven end-to-end: repak get -> UnrealLocres export csv (LocRes v3).
   BREAKER: LocResUtility CLI needs .NET 8 runtime (not installed; blocked on approval, see
   Problems). UnrealLocres runs on built-in .NET Framework and is fully functional.
2. `NewP5` target identified as the weapons/items upgrade text (5,598 strings).
   Dialogue-bearing targets: DIALOGUES FOR LQA, *_Dialogues, CUTSCENES, Mails*, NTD.
3. **No game UI font renders Arabic** (Gotham/BlenderPro/BrutalType/RobotoMono: NONE).
4. **Engine/Content/Slate/Fonts/NotoNaskhArabicUI-Regular.ttf = FULL Arabic coverage**
   (42/42 core letters, 1,092 Arabic codepoints). It ships in pakchunk0 as stock UE4 content
   and is OFL-licensed - a legal, zero-download fallback candidate and Phase 7 test vector.
5. Non-locres asset strings: script detection per asset (Cyrillic/CJK/etc.) proves whether
   all cultures are stored inline in uassets; details in reports/uasset_strings_catalog.txt.

## Problems / open items

- LocResUtility CLI: needs .NET 8 runtime (user approval required to install, or keep
  UnrealLocres as the working exporter - a DECISION pending for the user).
- Non-locres StringTable parsing is heuristic string-dump only; structured key->text
  mapping needs the Phase 7 prototype (UAssetGUI or FModel-assisted).

## Next

STOP. Awaiting user review of Phase 5 + Phase 6 report before PHASE 7 (extraction
prototype, 10-30 strings; native `ar` culture injection tested first, reuse-slot fallback).
