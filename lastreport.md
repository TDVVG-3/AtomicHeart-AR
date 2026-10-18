# Report 003 - Cycle 003 (2026-10-18)

Scope: user's in-game test feedback processing for the Phase 7 prototype v1, per ordered
steps 1-7. Evidence labels used: PASS/FAIL/PARTIAL/BLOCKED/NOT TESTED/CONFIRMED/LIKELY/
UNKNOWN only. All work committed locally (no remote exists).

## Step 1 - Uninstall on user order: DONE, PASS

`scripts/uninstall_mod.ps1` executed. Exact, hash-verified removal of our files only:

- removed: `zzz_atomicheart-ar_font_p1_P.pak`
- removed: `zzz_atomicheart-ar_locres_p1_P.pak`
- removed: `atomic-heart-ar-install-manifest.json`
- `~mods` folder removed (it was empty afterwards)
- Paks directory final state: **19 files = 19 stock paks only**. Game folder is stock.
- Nothing else was written to the game folder this cycle.

## Step 2 - Diagnosis with evidence

### Log availability: FAIL (no engine log exists) -> new KI-012

- `Saved\Logs` exists only under `%LOCALAPPDATA%\AtomicHeart\` and contains ONLY the
  NGX log (`NGX_2026.10.18-13.55.53_...`, timestamp matches your test session at 13:55).
- No `AtomicHeart.log`, no crash dumps, no font/locmeta/pak error lines anywhere - the
  shipping build does not write an engine log in this configuration.
- No `Saved` folder at all inside the game tree (write-protected install dir).
- Consequence: log-based confirmation of the hang mechanism is NOT AVAILABLE in this
  build. Mitigation documented: next test round can optionally add `-log` to the Steam
  launch options to capture a full engine log.

### Per-cause verdicts (setup under test: BOTH paks installed together)

a. **The font swap (Arabic-only Naskh payloads replacing all 6 UI FontFaces):**
   - Cause of the blank Latin UI text: **CONFIRMED**.
     - Render-output evidence: only "2", "!" visible, empty buttons. Decimal digits
       0-9, space, and a small punctuation set are exactly what Noto Naskh Arabic UI
       maps (Latin-Basic = 15 codepoints, zero Latin letters). What you saw on screen
       matches the missing-coverage set 1:1, while localization was left untouched
       (English culture) - no locres/locmeta involvement needed to explain it.
   - Cause of the FPS collapse / hang: **LIKELY**.
     - Mechanism: for every Latin glyph request the engine runs the missing-glyph
       fallback chain (composite fallback / default engine faces); thousands of
       failing glyph lookups per frame typically degenerate into a glyph-cache
       storm/deadlock - a known engine-wide behavior class. However this build writes
       no log, so the mechanism itself is UNCONFIRMED on this title (KI-012).

b. **The modified `NewP5.locmeta` (ar culture added):** **UNKNOWN** for its actual
   goal (the language list was never reached), but with a bound from this test: boot
   progressed past package loading to the main menu WITH the locres/locmeta pak
   mounted -> the modified content is not a boot-blocker. No hang attribution is
   possible from this test either way.

c. **The locres pak (NewP5-ar + Arabic content):** **UNKNOWN** (Arabic never selected).
   Same boot bound as (b): the pak mount itself did not prevent reaching the menu.

### Additional verdict from this test (major positive)

- **Mod loading pipeline (paks in `~mods`): PASS, CONFIRMED.** The game booted past
  Steam/Denuvo, loaded our override payloads, and visibly USED them (the glyph
  starvation is itself proof the engine consumed our font bytes, not stock).
- **Signature enforcement: not observed in practice.** Upgraded from "LIKELY not
  enforced" toward observed-absent on this machine/build; not labeled fully
  CONFIRMED (one boot on one machine is not a proof).

## Step 3 - Isolated variants: BUILT (NOT installed)

Both variants exist independently; the locres-only side needed no rebuild.

| Variant | Pak | Contents |
|---|---|---|
| **Locres-only** | `build/package/zzz_atomicheart-ar_locres_p1_P.pak` | NewP5-ar.locres (25 Arabic strings) + modified NewP5.locmeta (adds `ar` culture). No fonts. |
| **Font-only v2** | `build/package/zzz_atomicheart-ar_font_p2_plex_P.pak` | The 6 `.ufont` sidecars replaced with IBM Plex Sans Arabic payloads (dual-script; see Step 4). No locres/locmeta. |
| (reference) v1 font pak | `build/package/zzz_atomicheart-ar_font_p1_P.pak` | REJECTED; never to be installed again. |

### Recommended test order and expectations

1. **Test 1 - locres-only pak installed.**
   Expect: normal boot, normal FPS, main menu text 100% normal English (original
   fonts intact - no font pak). This isolates the locmeta+locres path cleanly.
   If it passes: open settings/language and screenshot whether an Arabic option
   exists. If instead the game hangs: (b)+(c) are implicated -> STOP and rethink.
2. **Test 2 - locres pak + font v2 pak installed together.**
   Expect: boot, normal FPS, main-menu text READABLE but with a different (Plex)
   typeface - temporary, prototype-only. Then select Arabic and check menu text,
   shaping/RTL, then in-game GameTips popups.
3. If the game still hangs in Test 2: uninstall and we proceed locres-first only;
   no permanent failure at this point.

## Step 4 - Font fix: DONE (v2), verification PASS

Per your order (never replace the original Latin fonts in the final product;
options a then b):

- Option (a) - add Arabic as a composite-font fallback on the ORIGINAL Font objects:
  assessed, NOT ATTEMPTED this cycle. It requires editing cooked Font uassets
  (CompositeFont fallback tables); headless tooling for that does not exist in our
  current toolchain (UAssetGUI is GUI-only; a custom UAssetAPI patcher is a Phase 8
  build item). Recorded in DEC-014 as the PRODUCTION path (Phase 8).
- Option (b) (replacement unavoidable for the prototype): implemented with
  **IBM Plex Sans Arabic**, which contains BOTH scripts in one family, so Latin stays
  fully readable during testing:
  - Downloaded from the official release page
    `https://github.com/IBM/plex/releases/tag/%40ibm/plex-sans-arabic%401.1.0`
    (asset ibm-plex-sans-arabic.zip, 3,898,251 bytes).
  - SHA256: `f03915581aea37d82792c188b08064023a73494d679b8e19f85f5971db714013`
    (no upstream digest published for this asset; recorded locally per DEC-012 rules).
  - License: **SIL OFL 1.1**, shipped with the font; copied to
    `fonts/licenses/IBM-Plex-Sans-Arabic-OFL-1.1.txt`; redistribution permitted.
  - **Glyph verification BEFORE building (your rule 4): PASS.**
    Scanner: `reports/font_glyph_coverage_plex.txt` - Latin-Basic **95/95** (every
    printable ASCII incl. digits and `!`), Latin-Ext 113, Arabic core letters
    **42/42**, Arabic total 676 including **presentation forms A+B** (shaping data);
    VERDICT FULL for Regular, Medium and Bold weights.
  - Weight mapping (face -> payload): BlenderPro-Book -> Regular, BlenderPro-Medium
    -> Medium, BlenderPro-Bold -> Bold, BrutalType -> Bold, Gotham-BookItalic ->
    Regular (no italic in family; test-grade), Gotham-Black -> Bold.
  - Builder: `scripts/build_fontpak_p2_plex.ps1` (hard coverage gate: refuses to
    pack any payload without a FULL scanner verdict).
  - Output: `build/package/zzz_atomicheart-ar_font_p2_plex_P.pak` (1,461,408 bytes).
  - **What v2 still changes:** the Latin typeface LOOK during the prototype
    (Plex instead of BlenderPro/Gotham/BrutalType). Accepted as test-grade only;
    the factory faces stay untouched in the game folder, and production requires
    the option-(a) composite fallback.

## Steps 5-6 - Standing constraints re-affirmed

- No EXE/DLL/Steam/Denuvo files touched; nothing written outside `~mods` (the game
  folder was only read this cycle).
- No uploads anywhere: `git remote -v` re-verified this cycle -> **zero remotes**;
  commit `047a063` is local-only. The sole download (IBM Plex zip) is from the
  official upstream release page with SHA256 recorded - DEC-012-compliant.

## Step 7 - Documentation updated, all committed

- `DECISIONS.md`: **DEC-014** (v1 rejected with evidence; v2 interim dual-script;
  composite-fallback as the production/Phase 8 requirement).
- `KNOWN_ISSUES.md`: **KI-009** updated (CONFIRMED mono-script failure + mitigation),
  **KI-012** added (shipping build writes no engine log; optional `-log` mitigation).
- `STATUS.md`: cycle 003 snapshot (Phase 7 attempt 1 = FAIL; mount pipeline = PASS;
  v2 = BUILT and verification-PASS; language path = NOT TESTED).
- `CHANGELOG.md` + `THIRD_PARTY_LICENSES.md` (IBM Plex entry + license path).
- Commit: `047a063` (9 files, local only). This file + same content in
  `lastreport.md` (standing rule).

## Next - your action (manual); I stop here

I stay stopped until you decide. Two clean tests are ready:

**Test 1 (recommended first) - locres-only pak:**
1. Say "install test 1"; I run the installer with only the locres pak.
2. Launch normally. Expected: normal FPS, menu text normal English.
3. Open the language list in game settings; screenshot it (looking for Arabic /
   العربية).
4. Optional diagnostic: Steam -> game Properties -> Launch Options -> add `-log`;
   after playing copy `%LOCALAPPDATA%\AtomicHeart\Saved\Logs\*.log` to your desktop
   for me. Untested whether Denuvo accepts it - mark it "did not help" if empty.
5. Report outcome as one of: A = Arabic option listed; B = not listed; C = rendering
   problem; D = hang/no boot (then run `scripts/uninstall_mod.ps1` immediately).

**Test 2 - both paks (locres + font v2):** readable Plex Latin in menus; then select
Arabic and screenshot menu text, shaping/RTL quality, and a GameTips popup in game.

(For non-technical reference: Test 1 proves the language switch itself is safe;
Test 2 proves Arabic is readable on screen. If Test 1 fails, we never needed the
font, and the diagnosis gets much easier.)
