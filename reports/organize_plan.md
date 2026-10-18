# Organize Plan - DRY RUN (nothing moved yet) - 2026-10-18

Rules honored: no deletions; game folder, MASTER_PROMPT.md, docs/spec/*, tools/bin/*,
.git untouched; no file referenced by any script is moved (verified: grep of scripts\
for "run.log" returned no references - the logs are write-only outputs of past runs).

## Survey findings
- Root files already match the allowed list exactly (README, STATUS, PLAN, DECISIONS,
  KNOWN_ISSUES, CHANGELOG, ROADMAP, CONTRIBUTING, LICENSE, THIRD_PARTY_LICENSES,
  lastreport.md; MASTER_PROMPT.md excluded from handling by rule). No root changes.
- Structure folders already correct: build/, config/, docs/, fonts/, glossary/,
  localization/, qa/, reports/, scripts/, source/, tools/.
- Empty placeholder dirs (dist/, glossary/ with subdirs empty, qa/ subdirs empty):
  LEFT IN PLACE (removing them would be a deletion, which is forbidden; they serve
  as planned structure per repo layout).
- Stray files found: 7 historical run logs sit directly in reports/ root.

## Moves (execute list - contains NO deletions)
| # | From (C:\AtomicHeart-AR\reports\)      | To                                   | Why                                   |
|---|----------------------------------------|--------------------------------------|---------------------------------------|
| 1 | build_master_tsv_run.log               | reports\logs\build_master_tsv_run.log| logs belong in reports/logs (rule e)  |
| 2 | extract_fonts_run.log                  | reports\logs\extract_fonts_run.log   | same                                  |
| 3 | extract_localization_run.log           | reports\logs\extract_localization_run.log | same                             |
| 4 | extract_uasset_text_run.log            | reports\logs\extract_uasset_text_run.log | same                              |
| 5 | font_glyph_scan_run.log                | reports\logs\font_glyph_scan_run.log | same                                  |
| 6 | scan_game_run.log                      | reports\logs\scan_game_run.log       | same                                  |
| 7 | scan_localization_run.log              | (NOT PRESENT on disk - plan over-inferred this entry; file is created only when scan_localization.ps1 next runs; no action) | - |

Amendment 2026-10-18: entries 1-6 executed (6 moves). Entry 7: no such file existed.

## New files (additions, not moves)
- INDEX.md at root: one line per folder; pointers to latest report, installed paks,
  install/uninstall scripts.
- HANDOFF.md at root: created at end of every cycle hereafter (standing instruction).

## Explicit non-actions
- scripts/*.ps1: stay (references intact; no script reads the moved logs).
- build/, source/, localization/, old paks: stay in place (already organized or
  script-referenced).
- MASTER_PROMPT.md, docs/spec/*, tools/bin/*, .git: UNTOUCHED by rule.

## Post-execution verification (to be reported PASS/FAIL)
1. Spec hash check: SHA256(MASTER_PROMPT.md) == guard hash.
2. Dry check: all scripts parse (PSParser), and every repo path referenced by any
   script still exists after the reorg (nothing referenced was moved anyway).
3. git commit (local only; no remotes).
