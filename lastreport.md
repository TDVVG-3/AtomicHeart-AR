# Report — Cycle 002 (2026-10-18, ~22:40 local)

## 1. Completed

- **Spec verified at cycle start**: SHA256 match (579f581e...48a61c35), no restore needed.
- **`.NET 8` install started** (winget Microsoft.DotNet.DesktopRuntime.8 8.0.32, official
  Microsoft source, installer hash verified). **P1 below**: completion is pending; the
  installer appears to be waiting for UAC elevation approval on your screen.
- **Signature enforcement investigated (rule 3b)**: verdict **LIKELY not enforced** —
  zero `.sig` files beside any of the 19 paks; shipped `DefaultGame.ini`/`DefaultEngine.ini`
  contain no signing or encryption directives (only `PakFileCompressionMethod=Kraken`);
  all pak indexes are readable/encrypted=false. Definitive proof comes from the boot test
  below; if the game refuses the pak on signature grounds I will STOP per your rule.
- **PHASE 7 prototype built** (rule 2/4/5, GO):
  - `NewP5-ar.locres`: 25 Arabic strings (7 GameTips incl. the dodge popup, 9 main-menu
    strings, 9 options/settings strings; 6 proper-noun rows left as English fallback —
    within your 10-30 limit). Built with UnrealLocres import on a copy of the en-US
    locres; validated by re-export: 25/25 rows contain Arabic after round-trip. Markup
    tags (`<tag id=...>`, `<img id=...>`, `<h>...`) preserved verbatim.
  - `NewP5.locmeta` surgery: empirically decoded the LocMeta binary (16-byte constant
    signature + version byte + native culture + resource string + culture array); bumped
    culture count 14→15 and inserted `ar` alphabetically. This is what should make
    **native Arabic selectable**.
  - Pak `zzz_atomicheart-ar_locres_p1_P.pak`: repak-pack V11, mount `../../../`,
    unencrypted, 2 entries, unpack byte-compare **PASS**.
  - Font override pak `zzz_atomicheart-ar_font_p1_P.pak`: discovered `.ufont` sidecars
    are RAW sfnt data (OTTO/TTF magic at offset 0), so a payload byte-swap is valid.
    Replaced 6 UI FontFace payloads (BlenderPro-Book/Medium/Bold, BrutalType,
    Gotham-BookItalic, Gotham-Black) with the shipped OFL-licensed
    `NotoNaskhArabicUI-Regular.ttf`; payload re-scanned inside the pak: FULL Arabic
    coverage. Expectation: Arabic shaping through the same HarfBuzz/FreeType pipeline
    the game already uses for Bengali/Devanagari/Thai; BiDi is the open question.
- **Safe install performed and uninstall TESTED** (rule 3, d):
  - `scripts/install_mod.ps1` created `~mods` and installed the 2 paks + a hash-recorded
    install manifest. Recursive LastWriteTime audit of the whole game tree confirms
    NOTHING else was written.
  - `scripts/uninstall_mod.ps1` was then run: removed exactly the 2 paks by SHA-verified
    manifest match, deleted the manifest, removed the now-empty `~mods` folder. **PASS**.
  - Re-installed afterwards: final state = ready for your test (2 paks + manifest in
    `~mods`).
- **Privacy rule implemented** (rule 9): DEC-012 recorded in DECISIONS.md; "Privacy"
  note added to README.md. `git remote -v` verified empty (0 remotes, exit 0).
- Audio language: untouched. The change is text-only (locres + locmeta + font payload);
  no VO/audio assets are included in the paks (rule 4).

## 2. Problems

- **P1: .NET 8 completion pending.** wriget reports "Starting package install..." then
  stalls; most likely a UAC elevation prompt needs your approval on screen (winget
  warned: "The installer will request to run as administrator"). Phase 7 testing does
  NOT need .NET 8 (the mod paks are built); this only unlocks LocResUtility/FModel GUI
  later. Next cycle I re-verify and record the installed version in docs/TOOLCHAIN.md
  (already drafted with 8.0.32).
- **P2: native-ar acceptance is UNKNOWN until boot.** The locmeta edit is the
  mechanism-gate for a new culture appearing in the game's language menu; the binary was
  decoded and rebuilt empirically (count/strings arithmetic verified), but there is no
  offline parser to fully validate it. If Arabic does not appear or the game ignores it,
  the DEC-007 fallback (Arabic delivered inside an existing culture slot, e.g. de-DE) is
  the next iteration — I will report exactly which slot is used. Nothing in the current
  install affects English or German (the `ar` folder is additive; existing files are
  byte-identical to stock except our 2 additive entries... the locmeta is the ONE
  overriden file; English/other cultures keep stock locres files).
- **P3: Latin UI degradation during this test** is EXPECTED (rule 5): Noto Naskh has
  only ~15 Latin glyphs, so overridden-font menus will look unusual while the menu
  itself is being tested. This is a deliberate first-test trade-off; the production
  font decision (IBM Plex Sans Arabic, §18) comes later.

## 3. Evidence

- locres pipeline: build log lines in transcripts: merged csv 25 rows → import →
  "validation: 25/25 seeded rows contain Arabic in round-tripped locres".
- Pak integrity: `repak info` (V11/Fnv64BugFix, mount ../../../, encrypted false,
  2 entries), `repak list` output, unpack byte-identical check PASS.
- Font coverage inside pak: `build/staging/font_p1/verify_fontpak_coverage.txt`
  (BrutalType.ufont → FULL, 42/42 core letters).
- Install cleanliness: recursive game-tree LastWriteTime audit listed ONLY the three
  files under `~mods`.
- Uninstall-by-manifest: script output PASS (2 removed, manifest + empty folder gone),
  then reinstall PASS. Sequence: install → audit → uninstall → verify → install.
- LocMeta decode: hex dumps of NewP5/Misc/CUTSCENES locmeta; identical 16-byte prefix;
  count field = number of culture entries (verified arithmetically for 194/193/198-
  byte files).
- git remote -v: empty output, exit 0, 0 remotes.

## 4. Files Changed

- New scripts: `scripts/build_locres_pak.ps1`, `scripts/build_fontpak_p1.ps1`,
  `scripts/install_mod.ps1`, `scripts/uninstall_mod.ps1`, `scripts/get_pak_file.ps1`.
- New data: `localization/working/phase7_seed.csv` (25 Arabic strings),
  `build/package/zzz_atomicheart-ar_locres_p1_P.pak`,
  `build/package/zzz_atomicheart-ar_font_p1_P.pak` (build outputs, gitignored),
  `source/original/config/DefaultGame.ini`, `DefaultEngine.ini`,
  `source/original/locmeta/*.locmeta` (4, gitignored, analysis-only).
- Updated: README.md (Privacy), DECISIONS.md (DEC-012), STATUS.md, CHANGELOG.md,
  docs/TOOLCHAIN.md (runtime installs).
- In the GAME folder (approved writes only): `~mods/` with 2 paks + install manifest.
- Git: 2 new commits (da60704 phase7 prototype; docs commit). Local only, no remote.

## 5. Current Status

Prototype INSTALLED and ready for your manual in-game test. All tool-verified steps PASS.
The two decisive unknowns that only the boot test can resolve: (a) game accepts mod paks
(signature/ban issue === LIKELY no) and (b) native `ar` culture becomes selectable via
the modified locmeta. If (b) fails → next iteration swaps to the DEC-007 reuse-slot
variant (build is a copy-and-patch away; script changes ~10 lines).

## 6. Next Action

Wait for your in-game test report (checklist below). Based on the outcome:
- If Arabic appears and renders with correct shaping/RTL → Phase 7 PASS, proceed to
  scale-up planning (full corpus, production font, translation QA).
- If Arabic appears but shaped wrongly / LTR / boxes → font/wiring follow-up and the
  DEC-007 fallback tests.
- If nothing changes in-game → locmeta/culture discovery failed → DEC-007 fallback.
- If the game crashes or refuses to boot → remove the mod (give me the word and I also
  run uninstall_mod.ps1 evidence-side), diagnose, and if signature enforcement turns out
  real, STOP and report per your rule.

## 7. What I need you to do (non-developer checklist)

1. If a **UAC window** ("Do you want to allow... .NET") is blinking on your screen,
   click **Yes** — that finishes the .NET runtime install (unrelated to the game test).
2. Launch **Atomic Heart** as you normally would.
3. In the main menu, open **Options → Language** (language settings page) and look
   through the language list for **عربي / Arabic / العربية**.
   - What I must choose: if "**العربية**" (Arabic) is in the list, select it and wait
     for the game to reload its language. If it is NOT in the list, tell me that
     (the fallback plan starts — do NOT switch to any other language).
4. With Arabic selected (or if it's not selectable, with your current language):
   a. Screenshot the **main menu** (buttons like "لعبة جديدة / New game",
      "الخيارات / Options", "متابعة / Continue").
   b. Enter **Options → Video/Quality screens** — switch one dropdown (e.g. Quality)
      to see whether the values among them show Arabic words ("الجودة", "الأداء").
   c. Start (or continue) a short play session and **pickup a weapon / open inventory**
      — watch for the tutorial tips popups about dodging/crouching/collecting; those
      should show Arabic sentences (the dodge tip mentions the roll/dodge key).
   d. Screenshot every Arabic text you see.
5. Tell me exactly one of the following, keyed to what you saw:
   - A: Arabic option existed in the language list and the game switched (or "game
     crashed when switching" — include crash wording).
   - B: no Arabic option in the list (meaning locmeta change rejected).
   - C: text shows but is unreadable (boxes, question marks, disconnected letters,
     wrong order left-to-right).
   - D: the game fails to reach the main menu at all (possible pak rejection).
6. If anything fails or crashes: quit Steam/game normally if possible and just tell me
   what happened in one sentence; I will then run `scripts/uninstall_mod.ps1` on your
   instruction and return the game folder to stock (that script removes ONLY our 2 paks,
   hash-verified).

THEN STOP — I wait for your report before touching anything else.

Cycle report also saved as reports/history/report_002.md.
