# Changelog

All notable changes to this project are documented here.
Format loosely follows Keep a Changelog.

## [Unreleased]

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
