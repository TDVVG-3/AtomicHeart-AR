# PLAN — Project Phases

Source of truth: `MASTER_PROMPT.md` (section 55 "First Run Procedure").

| Phase | Name                     | State      | Notes |
|-------|--------------------------|------------|-------|
| 1     | Repository Setup         | DONE       | Structure + core docs created 2026-10-17 |
| 2     | Locate Game              | DONE       | Steam library + ACF parsed, paths recorded in `config/game.json` |
| 3     | Inventory                | DONE       | 19 PAKs hashed, headers parsed, DLC candidates mapped |
| 4     | Toolchain Setup          | DONE       | 5 tools resolved + SHA256-verified; `tools/tools.lock.json`, `docs/TOOLCHAIN.md` |
| 5     | Localization Discovery   | PARTIAL    | locres catalogued; non-locres UI text identified, not yet extracted. Needs user approval to continue. |
| 6     | Font Discovery           | NOT STARTED| Map fonts and which UI systems use them |
| 7     | Extraction Prototype     | NOT STARTED| Prove extract -> edit -> rebuild -> package -> load (10–30 strings) |
| 8     | Arabic Technical Prototype | NOT STARTED | Prove glyphs, shaping, BiDi, numbers, mixed text in game |
| 9     | Master Database          | NOT STARTED| Full master TSV generated only after prototype passes |
| 10    | Glossary                 | NOT STARTED| Terminology decisions before mass translation |
| 11    | Translation              | NOT STARTED| Batched translation with validation per batch |
| 12    | QA                       | NOT STARTED| Technical, linguistic, font, in-game visual testing |
| 13    | Release                  | NOT STARTED| Reproducible artifacts, checksums, instructions |

## Hard gates

- No mass translation before the Arabic rendering prototype (Phase 8) passes.
- No EXE/DLL/DRM modification. Data-only mod first.
- English source is never replaced or deleted.
