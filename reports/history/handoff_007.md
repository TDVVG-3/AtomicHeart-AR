# HANDOFF - Atomic Heart Arabic localization

DATE-TIME: 2026-10-18 19:24 (local)
CYCLE: 006
CURRENT STEP: dialogue batch 2 of 4 (50%) - DONE
STATE: WAITING FOR USER

## Summary (5 lines)

1. Dialogue/cutscene inventory is locked: exact 100% TOTAL = 10,505 English-source strings.
2. Batch 1 (25%) and batch 2 (50%) are applied; batch 2 covered 5,253 of 10,505 (50%).
3. Master TSV still 27,618 rows; only Category values were canonicalized (Arabic still empty).
4. Russian-only dialogue (246 assets / 5,903 strings) stays separated in reports/dialogue_ru_only.md.
5. Validator PASS for both batches, including an idempotent re-run of batch 2.

## Completed

- Batch 2 (12 locre sources + part of a 13th) applied to the master TSV; validator PASS.
- DIALOGUES FOR LQA now fully counted (746/746 in batch 2, only 86 in batch 1).
- Category canonicalized on disk: Schebetar_Subs 361 = Subtitles (was "Unknown"),
  Theatre_Dialogues 629 = Dialogue, Pavlov_Dialogues 520 = Dialogue,
  Polygon_Dialogues 199 = Dialogue, OpenWorldVDNKh_Dialogues 443 = Dialogue.
- Idempotency verified: re-running batch 2 gives retag 0 and "master untouched", PASS.
- STATUS.md updated with the batch-2 step lines; report_007 written.
- Spec hash re-checked at step start: PASS.

## Problems

- None this step. The two correctness issues found during batch 1 (locres File-regex,
  retag-only write gate) were already fixed and are confirmed working in batch 2.
- Standing known issue: master had 728 duplicate IDs before this program (KI-016);
  validator baselines it and reports 0 new duplicates.

## Evidence

- Batch 2 console output in reports/history/report_007.md section 2.
- On-disk Category verification: localization/master/atomic-heart-ar.tsv
  (Schebetar_Subs 361 = Subtitles; Theatre_Dialogues 629 = Dialogue; Pavlov 520;
  Polygon 199; rows 27,618; no U+FFFD).
- Idempotent re-run: "[batch 2] covered 5253 of 10505 (50%); added 0; already 5253;
  dup 0; retag 0" and "[write] master untouched".
- reports/dialogue_inventory.md still holds the exact TOTAL and the four cutoffs
  (2,626 / 5,253 / 7,879 / 10,505).

## Files Changed

- localization/master/atomic-heart-ar.tsv (Category canonicalization for 2,152 rows).
- STATUS.md, HANDOFF.md.
- New: reports/history/report_007.md, reports/history/handoff_007.md,
  lastreport.md (refreshed).

## Current Status

- Batch 1 of 4: DONE (2,626 of 10,505 = 25%).
- Batch 2 of 4: DONE (5,253 of 10,505 = 50%).
- Batches 3, 4: NOT STARTED (75% / 100%).
- Arabic translation: NOT STARTED (column empty, by design).
- Test 3: main menu Arabic CONFIRMED earlier; settings pages/GameTips still open.
- Nothing installed or removed; game folder read-only; nothing uploaded.

## Next Action

On the user's "next": run batch 3 (cumulative 75%, cutoff 7,879) = remaining 185 strings
of Theatre_Dialogues + Vavilov_Dialogues in full (2,427) + first 14 strings of
VDNKh_Dialogues; then run the validator, rewrite HANDOFF.md and the report, and commit
locally.

## What I need you to do

- Reply "next" to start batch 3 (75%).
- Optional, unrelated to this batch: finish Test 3 (settings captions + GameTips popups)
  when convenient - uninstall first, then install the Test-3 set.

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

- One word: "next" - to run batch 3 (75%).
- If you want Test 3 finished first, say so and I will list the exact steps.
- Nothing else is needed; no permissions are pending.
