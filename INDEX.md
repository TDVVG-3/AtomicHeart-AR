# INDEX.md - repository map (one line per folder)

- `build/` - build artifacts: staging work dirs, packaged `.pak` files in `build\package\` (carrier, font, rejected Naskh v1, test-1 locres), build records.
- `config/` - JSON configuration: game paths/build id (`game.json`), build settings, translation settings, `paths.example.json`.
- `dist/` - reserved for distribution packaging (currently empty placeholder).
- `docs/` - investigation dossiers and reference docs (ARCHIVE_LAYOUT, FONT_RESEARCH, LANGUAGE_SELECTION, LOCALIZATION_FORMAT, TOOLCHAIN, ...); `docs/spec/` holds the immutable spec copies - do not edit.
- `fonts/` - font sources in `fonts\source\`, licenses in `fonts\licenses\`, generated weights in `fonts\generated\`.
- `glossary/` - terminology glossary (currently empty placeholder).
- `localization/` - the text pipeline: `extracted\` from game paks, `master\` master DB (en-US), `generated\` TSV/CSV outputs, `references\`, `working\` (incl. `phase7_seed.csv`, the 25 Arabic seed rows).
- `qa/` - QA materials: `qa\issues\`, `qa\reports\`, `qa\screenshots\` (test screenshots from the user).
- `reports/` - all evidence and reports: `reports\logs\` run logs, `reports\paklists\`, `reports\history\` (cycle reports + handoff copies), top-level evidence scan/dump files, `organize_plan.md`.
- `scripts/` - all PowerShell tooling (the operational entry points).
- `source/` - extracted game assets (originals + decoded uasset text) for Phase 8 work.
- `tools/bin/` - third-party native tools (repak, UnrealLocres, ...). Do not redistribute.

## Where to find things
- Latest report: `lastreport.md` (mutable copy) / `reports/history/report_NNN.md` (per-cycle originals).
- Latest handoff: `HANDOFF.md` / `reports/history/handoff_NNN.md`.
- Packaged paks to install: `build\package\zzz_atomicheart-ar_*.pak` (the active set is chosen inside `scripts\install_mod.ps1`).
- Install script: `scripts\install_mod.ps1` - Uninstall script: `scripts\uninstall_mod.ps1` (manifest-based; writes only into the game's `Paks\~mods`).
- Spec: `MASTER_PROMPT.md` (guarded; read-only backup + hash per DEC-008).
- Project status: `STATUS.md`; decisions: `DECISIONS.md`; open issues: `KNOWN_ISSUES.md`; history: `CHANGELOG.md`.
