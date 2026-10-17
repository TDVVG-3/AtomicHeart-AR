# Report — Cycle 001 (2026-10-18, 18:45 local)

## 1. Completed

- **Spec integrity guard deployed** (user decision 1): MASTER_PROMPT.md verified at
  34,293 bytes, SHA256 579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35;
  byte-identical read-only backup at docs/spec/MASTER_PROMPT.backup.md; hash recorded in
  docs/spec/MASTER_PROMPT.sha256 and procedure in docs/spec/SPEC_INTEGRITY.md.
  Cycle-start re-verification: PASS (no restore needed).
- **Git installed and repository initialized** (user decision 2): Git.Git 2.55.0.5 via
  winget with verified installer hash; repo-local identity (AtomicHeart-AR,
  atomicheart-ar@localhost); 11 conventional commits; 887 tracked files. No global git
  config changes.
- **Redistribution policy written** (user decision 4): THIRD_PARTY_LICENSES.md +
  tools/README.md: LocResUtility and UnrealLocres have no license file, used locally only,
  never redistributed, never copied into dist/.
- **DEC-006 scope expansion recorded** (user decision 3): non-locres text treated as
  first-class; no raw game assets committed (binaries under gitignored source/original/,
  .gitignore updated; only extracted text + manifests committed).
- **PHASE 5 full locres extraction: PASS.** All 565/565 locres+locmeta extracted from all
  19 paks (scripts/extract_localization.ps1); SHA256 manifest at
  source/manifests/localization_manifest.json.
- **PHASE 5 locres-to-text pipeline: PASS.** UnrealLocres 1.1.0 export proven on LocRes v3.
  Master DB skeleton generated: localization/master/atomic-heart-ar.tsv with 27,618 en-US
  strings, 13 spec columns, Status=UNTRANSLATED, Arabic column empty (no translation work).
- **PHASE 5 non-locres extraction: PASS.** 841 candidates found; 828 asset text dumps
  extracted (29.7 MB, localization/extracted/uasset_text/) + catalog
  (reports/uasset_strings_catalog.txt) + locres cross-check
  (reports/stringtable_coverage.csv).
- **CONFIRMED text-delivery mechanism** (major discovery): StringTable uassets carry
  RUSSIAN-native fallback text only; the ENGLISH text for the "missing" UI targets is in
  the locres corpus (NewP5 holds ST_GameTips_Texts and more; ST_PickableBoy in Tech_dlc4;
  NTD tables in NTD). Arabic can therefore ride the standard locres path (Phase 7 test).
- **Translation-gap set identified**: some tables have no locres entries in ANY culture
  (e.g. ST_GooseRunner_Hints, 16 keys, zero en-US matches; English players see Russian).
  Adds KI-010; needs the uasset path as a Phase 8 fallback.
- **PHASE 6 font discovery: PASS.** 49 font binaries cmap-scanned with a new pure
  PowerShell TTF parser (scripts/font_glyph_scan.ps1), reports/font_glyph_coverage.txt/csv.
  CONFIRMED: no game UI font (Gotham/BlenderPro/BrutalType/RobotoMono) renders Arabic.
  Engine Slate NotoNaskhArabicUI-Regular.ttf ships in pakchunk0 with FULL Arabic coverage
  (42/42 core letters, 1,092 Arabic codepoints), OFL-licensed by Google: legal reuse
  candidate and first Phase 7 test vector.
- Docs updated: STATUS, DECISIONS (DEC-008..011), CHANGELOG, KNOWN_ISSUES (KI-002
  mitigated; KI-008, KI-009, KI-010 added), LOCALIZATION_FORMAT, FONT_RESEARCH,
  reports/non_locres_text.md Phase 5 results.

## 2. Problems

- **P1: LocResUtility CLI cannot run** - requires the .NET 8 runtime, which is not
  installed. Installing it system-wide needs your approval (KI-008). Workaround active:
  UnrealLocres runs on the built-in .NET Framework and is fully functional. FModel GUI
  will need .NET 8 as well, when we get to structured StringTable inspection.
- **P2: master TSV regeneration quirks** - two PowerShell import bugs (CSV header row as
  data; locres namespace parsing) were caught and fixed; final file verified clean
  (27,618 rows, no junk rows). No impact on any committed English source.
- **P3: false positives in the text-candidate sweep** - many ETA_^ST_ -prefixed files are
  StaticTextures/Meshes and BP subsystems, not StringTables. Coverage tables qualify this;
  real StringTable-class assets are 33 of 828. No release-level effect; classification by
  asset class remains Phase 7 work (DEC-010).

## 3. Evidence

- File/size verification commands and outputs in cycle log:
  spec hash verify: PASS (both cycle start and end).
- locres extraction: reports/extract_localization_run.log (565/565 extracted,
  manifest SHA256-hashed).
- LocRes v3 + pipeline: localization/generated/test/Misc_en.csv ("Exported 21 strings");
  reports/build_master_tsv_run.log (per-target string counts; NewP5 = 5,598).
- Text mechanism: grep of en-US locres CSV shows ST_GameTips_Texts_/ keys with English
  text (e.g. "To dodge attacks... press <tag id=\"InputAction.Gameplay.Dodge\"/>");
  ST_GooseRunner_Hints keys (Main_Hint etc.) -> zero matches in all locres.
- Fonts: reports/font_glyph_coverage.txt (49 fonts; single FULL = NotoNaskhArabicUI).
- Git: git log shows 11 commits; git ls-files count = 887.

## 4. Files Changed

Committed (11 commits, 73bb81f..a16fb26):
- New: THIRD_PARTY_LICENSES.md, tools/README.md, docs/spec/* (3 files),
  scripts/extract_localization.ps1, scripts/build_master_tsv.ps1,
  scripts/extract_uasset_text.ps1, scripts/extract_fonts.ps1,
  scripts/font_glyph_scan.ps1, scripts/analyze_stringtable_coverage.ps1.
- Data: source/manifests/localization_manifest.json, source/manifests/font_manifest.json,
  localization/master/atomic-heart-ar.tsv (27,618 rows), 828 files under
  localization/extracted/uasset_text/, reports/font_glyph_coverage.{txt,csv},
  reports/stringtable_coverage.csv, reports/uasset_strings_catalog.txt, various run logs.
- Updated: README/STATUS/DECISIONS/CHANGELOG/KNOWN_ISSUES/.gitignore,
  docs/LOCALIZATION_FORMAT.md, docs/FONT_RESEARCH.md, reports/non_locres_text.md.

## 5. Current Status

Phases 1-6 COMPLETE. Repo is versioned. Master DB ready for Arabic with zero Arabic rows
(no translation ordered yet). Arabic-capable font evidence secured. Non-locres landscape
mapped with a confirmed mechanism. Phase 7 NOT STARTED (blocked on your approval).

## 6. Next Action

PHASE 7 (extraction prototype, 10-30 strings), upon your approval:
1. Pick a small, visible StringTable (candidate: ST_GameTips_Texts) plus one locres
   target sample.
2. Create ar-NewP5.locres (Arabic text injected as native `ar` culture) via
   UnrealLocres import + repak repack into ~mods (folder creation needs your OK at that
   point).
3. Verify in game: Arabic string appears; fonts render (first tests can reuse the
   shipped Noto Naskh Arabic UI via a font-override prototype).
4. If native ar fails to load, fall back to the reuse-slot strategy (DEC-007) and
   report which language slot it replaces.

## 7. What I need you to do

1. Approve or defer installing the .NET 8 runtime (needed for LocResUtility and FModel
   GUI later; not needed for Phase 7 tests).
2. Say "go" to start Phase 7 (extraction prototype with ~10-30 strings), or name a
   different first text to test.
3. Optional: confirm the Arabic-first visible text to prototype with (default: the
   GameTips dodge/tutorial popup).
