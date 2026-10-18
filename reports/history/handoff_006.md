# HANDOFF - Atomic Heart Arabic localization

DATE-TIME: 2026-10-18 18:26 (local)
CYCLE: 006
CURRENT STEP: dialogue batch 1 of 4 (25%) - DONE
STATE: WAITING FOR USER

## Summary (5 lines)

1. Dialogue/cutscene inventory is locked: exact 100% TOTAL = 10,505 English-source strings.
2. That is 10,394 en-US locres strings (14 scopes) + 111 cooked-asset strings (4 assets).
3. Russian-only dialogue (246 assets / 5,903 strings) is separated in reports/dialogue_ru_only.md.
4. Batch 1 (25%) applied and validated: covered 2,626 of 10,505 (25%); validator PASS.
5. Master TSV still 27,618 rows; only Category values were canonicalized. Arabic still empty.

## Completed

- Spec hash check PASS (579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35).
- Count pass: 4,325 candidate cooked assets scanned by 4 workers in 23 min; 0 fetch
  failures, 0 stderr bytes.
- Decoder verified: a Cyrillic dump decoded "Все на перевыборы советов" and
  "Все получат по ебалу! И Сережа тоже!" with no mojibake.
- Prose filter defined (DEC-019), shared by inventory and batch tool.
- Exact inventory and TOTAL written (DEC-020): reports/dialogue_inventory.md.
- RU-only report written: reports/dialogue_ru_only.md.
- Batch 1 (25%) applied to the master TSV; validator PASS.
- Docs updated: DECISIONS.md (DEC-019, DEC-020), KNOWN_ISSUES.md (KI-016), STATUS.md.
- AR_EN_REFERENCE.md regenerated (0 rows with Arabic, by design).

## Problems

1. Raw UTF-16 extraction over-counted (5,005,978 "strings" = engine/asset names and
   binary fragments). Fixed with the DEC-019 prose filter - counts are now real text.
2. Batch tool matched locres files with a wrong regex (expected a trailing slash, files
   end ".locres"), so 0 rows matched on the first run. Fixed and re-run.
3. The master already contained 728 duplicate IDs (KI-016). The validator now baselines
   that and fails only on NEW duplicates.
4. A Category-only (retag) batch was not persisted at first because the write gate only
   watched the row count. Fixed: writes when rows changed OR any retag happened.
5. Earlier stale count generations used an alignment-bugged decoder (DEC-018); all stale
   dumps and part files were purged and the pass rerun from a clean slate.

## Evidence

- reports/dialogue_inventory.md - TOTAL 10,505 + per-source tables + cutoffs.
- reports/dialogue_ru_only.md - 246 RU-only assets / 5,903 strings with samples.
- reports/dialogue_st_counts.tsv - 4,325-row scan registry (FETCH-FAIL = 0).
- reports/dialogue_inventory_raw/ - ordered sources, chunks, worker logs, part TSVs.
- Batch 1 console output (in report_006.md section 4) - coverage 2,626 of 10,505 (25%).
- Validator output: PASS, 0 problems, 27,618 rows, UTF-8 round-trip OK, new duplicates 0.
  Rich-text tags: dialogue rows carry none; the only 11 rows with unpaired tags are
  pre-existing UI rows (NewP5/NTD/PearTerminals) outside the dialogue scope.

## Files Changed

- localization/master/atomic-heart-ar.tsv (Category canonicalization; 27,618 rows).
- DECISIONS.md, KNOWN_ISSUES.md, STATUS.md, HANDOFF.md.
- New: scripts/dialogue_st_counts.ps1, dialogue_count_worker.ps1,
  dialogue_strings_lib.ps1, dialogue_finalize.ps1, dialogue_batch_apply.ps1.
- New: reports/dialogue_inventory.md, reports/dialogue_ru_only.md,
  reports/dialogue_st_counts.tsv, reports/dialogue_inventory_raw/*,
  localization/references/AR_EN_REFERENCE.md, reports/history/report_006.md.

## Current Status

- Batch 1 of 4: DONE (2,626 of 10,505 = 25%).
- Batches 2, 3, 4: NOT STARTED (50% / 75% / 100%).
- Arabic translation: NOT STARTED (column empty, by design).
- Test 3: main menu Arabic CONFIRMED earlier; settings pages/GameTips still open.
- Nothing installed or removed; game folder read-only; nothing uploaded.

## Next Action

On the user's "next": run batch 2 (cumulative 50%, cutoff 5,253), which finishes
DIALOGUES FOR LQA and covers OpenWorldVDNKh_Dialogues and Pavlov_Dialogues; then run the
validator, rewrite HANDOFF.md, update the report, and commit locally.

## What I need you to do

- Reply "next" to start batch 2 (50%).
- Optional, unrelated to this batch: finish Test 3 (settings captions + GameTips popups)
  when convenient - uninstall first, then install the Test-3 set.

## Decisions made (relevant)

| ID | Decision |
|---|---|
| DEC-017 | Dialogue program rules: scope, TOTAL = English-only, cumulative batches, order rule, no duplicate rows |
| DEC-018 | Count-pass dump generations: purged stale dumps/TSVs, rerun with verified decoder, 4 workers resumable |
| DEC-019 | Prose filter: what counts as dialogue text in cooked assets (shared by inventory and batch tool) |
| DEC-020 | TOTAL = 10,505; RU-only excluded; batch cutoffs 2,626/5,253/7,879/10,505; retag-per-source boundary rule; duplicate baseline |

## Known issues (relevant)

| ID | State | Note |
|---|---|---|
| KI-010 | OPEN | RU-only text with no English, e.g. GooseRunner hints - now reported for 246 assets / 5,903 strings |
| KI-013 | OPEN | Native "ar" needs DA_Audio schema tooling (Phase 8); carrier ko-KR is the interim route |
| KI-014 | CONFIRMED | Replacement font faces have zero Hangul; mitigated by English-fill carrier p2 |
| KI-015 | NOTED | UnrealLocres normalizes LF to CRLF inside multiline values (5 values / 56 keys) |
| KI-016 | NOTED | 728 duplicate IDs already existed in the master before this program; baseline, not ours |

## What I should send back

- One word: "next" - to run batch 2 (50%).
- If you want Test 3 finished first, say so and I will list the exact steps.
- Nothing else is needed; no permissions are pending.
