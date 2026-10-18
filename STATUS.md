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

- LocResUtility CLI: needs .NET 8 runtime. .NET 8 installation was APPROVED and started
  (winget, 8.0.32); completion verification pending in this cycle (installer may be
  waiting on a UAC elevation prompt on the user's screen).
- Non-locres StringTable parsing is heuristic string-dump only; structured key->text
  mapping needs the Phase 7 prototype (UAssetGUI or FModel-assisted).
- KI-010 (ST_GooseRunner_Hints gap) deferred by user decision until after the prototype.

## Phase 7 prototype (2026-10-18, Cycle 002)

- Native-`ar` locres pak built and verified: NewP5-ar.locres (25 Arabic strings from
  phase7_seed.csv) + modified NewP5.locmeta (culture count 14->15, "ar" inserted).
  Pak: build/package/zzz_atomicheart-ar_locres_p1_P.pak (V11, round-trip byte-identical).
- Font override pak built and verified: NotoNaskhArabicUI payload swapped into 6 UI
  FontFace sidecars (.ufont are raw sfnt data - proven). Pak:
  build/package/zzz_atomicheart-ar_font_p1_P.pak; payload re-scanned FULL Arabic.
- Paks INSTALLED into ~mods via install_mod.ps1 (manifest-based). Uninstall script
  tested THEN reinstalled: both PASS. Game folder untouched otherwise (verified by
  recursive LastWriteTime audit).
- Signature enforcement: no .sig files anywhere; no signing/encryption directives in
  shipped INIs. Verdict LIKELY not enforced (definitive only via the boot test).
- In-game test: NOT RUN (user will test manually; checklist delivered).

## Next

STOP. Awaiting the user's in-game test report for the Phase 7 prototype (language menu,
mmenu strings, options strings, GameTips popups, font shaping/RTL). Then fix or advance.
