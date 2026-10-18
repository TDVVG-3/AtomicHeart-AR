# HANDOFF - Atomic Heart Arabic localization

DATE-TIME: 2026-10-18 19:28 (local)
CYCLE: 006
CURRENT STEP: dialogue batch 3 of 4 (75%) - DONE
STATE: WAITING FOR USER

## Summary (5 lines)

1. Dialogue/cutscene inventory is locked: exact 100% TOTAL = 10,505 English-source strings.
2. Batches 1-3 are applied: batch 3 covered 7,879 of 10,505 (75%).
3. Master TSV still 27,618 rows; only Category values were canonicalized (Arabic still empty).
4. Batch 4 (100%) is the only step that adds NEW rows: the 4 cooked English-prose assets (111 strings).
5. Validator PASS for all three batches, each with an idempotent re-run confirming no double-apply.

## Completed

- Batch 3 applied: Theatre_Dialogues completed (629/629), Vavilov_Dialogues fully
  retagged (2,427), VDNKh_Dialogues retagged (1,292; 14 strings count toward coverage).
- On-disk verification: Vavilov_Dialogues 2,427 = Dialogue; VDNKh_Dialogues 1,292 =
  Dialogue; Theatre_Dialogues 629 = Dialogue; 27,618 rows; no U+FFFD.
- Idempotency verified: second run gave retag 0 and "master untouched", PASS.
- STATUS.md updated with batch-3 step lines; report_008 written.
- Spec hash re-checked at step start: PASS.

## Problems

- None this step. Composition matched the plan exactly (5,253 + 185 + 2,427 + 14 = 7,879).
- Standing: master had 728 duplicate IDs before this program (KI-016); validator
  baselines it and reports 0 new duplicates every batch.

## Evidence

- Batch 3 console output in reports/history/report_008.md section 2.
- reports/dialogue_inventory.md (exact TOTAL and cutoffs 2,626 / 5,253 / 7,879 / 10,505).
- On-disk Category check quoted in report_008 section 3.
- Idempotent re-run line: "[batch 3] covered 7879 of 10505 (75%); added 0; already 7879;
  dup 0; retag 0" and "[write] master untouched".

## Files Changed

- localization/master/atomic-heart-ar.tsv (Category canonicalization for 3,719 rows).
- STATUS.md, HANDOFF.md.
- New: reports/history/report_008.md, reports/history/handoff_008.md,
  lastreport.md (refreshed).

## Current Status

- Batch 1 of 4: DONE (2,626 of 10,505 = 25%).
- Batch 2 of 4: DONE (5,253 of 10,505 = 50%).
- Batch 3 of 4: DONE (7,879 of 10,505 = 75%).
- Batch 4 of 4: NOT STARTED (100%).
- Arabic translation: NOT STARTED (column empty, by design).
- Test 3: main menu Arabic CONFIRMED earlier; settings pages/GameTips still open.
- Nothing installed or removed; game folder read-only; nothing uploaded.

## Next Action

On the user's "next": run batch 4 (cumulative 100%, cutoff 10,505) = remaining 1,278
strings of VDNKh_Dialogues + Cutscenes_dlc1 421 (DLC1) + Locations_dlc2 816 (DLC2) +
the 4 cooked assets (111 strings, the only NEW rows); then run the validator, rewrite
HANDOFF.md and the report, and commit locally. After batch 4, DLC1/DLC2/DLC4 coverage
should move from 0% to 100%.

## What I need you to do

- Reply "next" to run batch 4 (100%) - the final batch of the dialogue inventory.
- Optional, unrelated: finish Test 3 (settings captions + GameTips popups) when convenient.

## Decisions made (relevant)

| ID | Decision |
|---|---|
| DEC-017 | Dialogue program rules: scope, TOTAL = English-only, cumulative batches, order rule, no duplicate rows |
| DEC-018 | Count-pass dump generations: purged stale dumps/TSVs, rerun with verified decoder |
| DEC-019 | Prose filter: what counts as dialogue text in cooked assets (shared by inventory and batch tool) |
| DEC-020 | TOTAL = 10,505; RU-only excluded; cutoffs 2,626/5,253/7,879/10,505; retag-per-source boundary rule; duplicate baseline |

## Known issues (relevant)

| ID | State | Note |
|---|---|---|
| KI-010 | OPEN | RU-only text with no English; reported for 246 assets / 5,903 strings |
| KI-013 | OPEN | Native "ar" needs DA_Audio schema tooling (Phase 8); carrier ko-KR is the interim route |
| KI-014 | CONFIRMED | Replacement font faces have zero Hangul; mitigated by English-fill carrier p2 |
| KI-015 | NOTED | UnrealLocres normalizes LF to CRLF inside multiline values (5 values / 56 keys) |
| KI-016 | NOTED | 728 duplicate IDs already existed in the master before this program; baseline, not ours |

## What I should send back

- One word: "next" - to run batch 4 (100%), the final dialogue batch.
- Nothing else is needed; no permissions are pending.
