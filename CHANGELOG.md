# Changelog

All notable changes to this project are documented here.
Format loosely follows Keep a Changelog.

## [Unreleased]

### Added (Cycle 004 - 2026-10-18)
- Test 1 result: outcome B - game boots with the locres-only pak, language list has NO
  Arabic option (not a pak failure; locmeta staging alone provably can never add a menu
  entry). User confirmed NORMAL FPS during the test.
- ROOT CAUSE found: Options > Language list is hardcoded (13 records) in the cooked
  DataAsset Core/Data/Settings/DA_Audio.uasset+.uexp (docs/LANGUAGE_SELECTION.md);
  consumer chain via cooked Config/DefaultGame.ini +ConfigurableSettings ->
  native AHGameSettingsSubsystem -> WBP_Options.
- Compiler verdict on the asset: cooked UNVERSIONED (tagless; FileVersionUE4=0) ->
  direct record-append requires schema reconstruction -> Phase 8 tooling item;
  partial decode recorded in scripts/inspect_da_audio.ps1.
- DEC-015 (amended): primary route deferred to Phase 8 tooling; user-approved carrier
  built now.
- DEC-007 carrier (user-approved slot ko-KR): scripts/build_carrier_locres_pak.ps1 +
  pak BUILT: build/package/zzz_atomicheart-ar_carrier_koKR_p1_P.pak (489,923 B,
  sha256 146f9c5f50744eed0b3ed614cf9e84f177efb35049c46d59c8948ea4857596ab) -
  25/25 Arabic round-trip, controls unchanged Korean, unpack byte-identical.
  NOT INSTALLED (waiting for user go).
- Voice-culture evidence from DA_Audio_VoiceBanks: retail VO only en-US + ru-RU; all
  other slots fall back to en-US - both routes keep the English voice untouched.
- KI-012 closed as negative: `-log` produced no log file even when active.
- Locres pak kept available (not installed); font pak v2 untouched, not installed.

### Added / Fixed (Cycle 003 — 2026-10-18)
- IN-GAME TEST RESULT (attempt 1): FAIL. Game booted and loaded mod paks (font swap
  visibly active = mount pipeline CONFIRMED), but all Latin UI text disappeared
  (only digits and '!' rendered = Naskh Latin-Basic 15), heavy FPS collapse, hang.
  Root cause: single-script Arabic-only font payload replacing UI FontFaces (DEC-014).
- Mods uninstalled on user order: uninstall_mod.ps1 run — both paks + manifest removed
  exactly (hash-verified); ~mods back to stock (19 stock paks only).
- Font strategy DEC-014: v1 rejected; v2 = dual-script IBM Plex Sans Arabic payloads;
  production target = composite-font fallback (Phase 8, needs headless Font-asset tooling).
- IBM Plex Sans Arabic downloaded from official IBM/plex release 1.1.0 (OFL 1.1,
  SHA256 f03915581aea37d82792c188b08064023a73494d679b8e19f85f5971db714013), verified
  locally: Latin-Basic 95/95, Arabic 42/42, presentation forms complete.
- scripts/build_fontpak_p2_plex.ps1 + font pak v2 built
  (build/package/zzz_atomicheart-ar_font_p2_plex_P.pak) — NOT installed.
- Isolated-variant test plan documented (locres-only first, font v2 second).
- KI-012 recorded: shipping build writes no engine log; `-log` optional next round.
- fonts/licenses/IBM-Plex-Sans-Arabic-OFL-1.1.txt recorded (redistributable).
- reports/font_glyph_coverage_plex.txt / .csv (Plex verification evidence).

### Added (Cycle 002 — 2026-10-18)
- .NET 8 runtime install started (user-approved winget package, 8.0.32).
- PHASE 7 prototype: native-`ar` NewP5 locres pak built (25 seed strings, locmeta
  surgery decode + script) and font-override pak built (Noto Naskh sidecar swap).
- scripts/build_locres_pak.ps1, scripts/build_fontpak_p1.ps1, scripts/install_mod.ps1,
  scripts/uninstall_mod.ps1, scripts/get_pak_file.ps1.
- MOD INSTALLED into ~mods with hash-verified install manifest; uninstall tested then
  reinstalled. Signature enforcement assessed LIKELY-absent (no .sig files, no signed
  config directives).
- DEC-012: permanent no-upload rule recorded; README Privacy note added; git remote -v
  verified empty.

### Added (Cycle 001 — 2026-10-18)
- Git repository initialized (Git for Windows 2.55.0.5 via winget, user-approved).
- Spec integrity guard: read-only backup + SHA256 records under docs/spec/ (DEC-008).
- PHASE 5: all 565 locres/locmeta extracted with SHA256 manifest
  (scripts/extract_localization.ps1).
- PHASE 5: locres -> CSV pipeline proven with UnrealLocres; master translation DB
  skeleton generated (27,618 en-US strings, 13 spec columns) —
  scripts/build_master_tsv.ps1.
- PHASE 5: 857 non-locres text candidates extracted to string dumps + catalog +
  locres-coverage cross-check (extract_uasset_text.ps1, analyze_stringtable_coverage.ps1).
- CONFIRMED text-delivery mechanism: StringTables keyed into locres corpus (NewP5 etc.);
  Russian-inline assets only fallback. Translation-gap set identified (e.g.
  ST_GooseRunner_Hints, no English locres keys).
- PHASE 6: 49 font binaries cmap-scanned (font_glyph_scan.ps1). CONFIRMED: no game UI
  font renders Arabic; shipped Engine Slate NotoNaskhArabicUI-Regular.ttf = FULL Arabic
  coverage (1,092 codepoints) — OFL-licensed reuse candidate.
- THIRD_PARTY_LICENSES.md + tools/README.md redistribution policy (unlicensed tools
  never redistributed / never in dist/).

### Added
- Repository structure per MASTER_PROMPT.md §8.
- Core documents: README, PLAN, STATUS, DECISIONS, KNOWN_ISSUES.
- Steam game detection and Paks inventory (Phases 2–3).
- Toolchain research and tools lock file (Phase 4).
