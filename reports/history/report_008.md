# Cycle 006 report (addendum) - dialogue batch 3 of 4 (75%)

Date: 2026-10-18. Spec hash at step start: PASS
(579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35).
Local git only; `git remote -v` empty; nothing uploaded; no game-folder install.

## 1. Scope of this step

Apply cumulative batch 3 (75%) of the dialogue/cutscene program on top of batches 1-2.
TOTAL is unchanged at 10,505; the cumulative cutoff is 7,879.

## 2. Batch 3 result

    [batch 3] TOTAL 10505 strings; cumulative cutoff 7879
      locres Academy_Dialogues              present 282/282 full retag 0
      locres Chelomey_Dialogues             present 1204/1204 full retag 0
      locres ChelomeyFinal_Dialogues        present 214/214 full retag 0
      locres CUTSCENES                      present 840/840 full retag 0
      locres DIALOGUES FOR LQA              present 746/746 full retag 0
      locres OpenWorldVDNKh_Dialogues       present 443/443 full retag 0
      locres Pavlov_Dialogues               present 520/520 full retag 0
      locres Polygon_Dialogues              present 199/199 full retag 0
      locres Schebetar_Subs                 present 361/361 full retag 0
      locres Theatre_Dialogues              present 629/629 full retag 0
      locres Vavilov_Dialogues              present 2427/2427 full retag 2427
      locres VDNKh_Dialogues                present 14/1292 partial retag 3719
    [batch 3] covered 7879 of 10505 (75%); added 0; already 7879; dup 0; retag 3719
    [coverage by category]
      Cutscene  840 of 1262 (66.6%)
      Dialogue  6678 of 8792 (76%)
      Subtitles 361 of 451 (80%)
    [coverage by DLC]
      base  7879 of 9199 (85.7%)
      DLC1  0 of 421 (0%)
      DLC2  0 of 865 (0%)
      DLC4  0 of 20 (0%)
    [validation] UTF-8 round-trip: OK (no U+FFFD)
    [validation] rich-text tags in source (informational): 209 opening, 118 self-closing, 80 closing
    [validation] duplicate ids total 728; pre-existing 728; new 0
    [validation] PASS (0 problems, 27618 rows)
    [write] master rows 27618 -> 27618

The composition matches the prediction in report_007 exactly:
5,253 + 185 (rest of Theatre_Dialogues) + 2,427 (Vavilov_Dialogues) + 14 (start of
VDNKh_Dialogues) = 7,879.

## 3. What changed in the master

- Theatre_Dialogues is now complete inside the batch (629/629).
- Vavilov_Dialogues fully retagged: 2,427 rows -> Category Dialogue.
- VDNKh_Dialogues: source straddles the boundary; all 1,292 rows retagged to Dialogue
  (per DEC-020), only 14 of its strings count toward the 75% coverage.
- Verified on disk: Vavilov_Dialogues 2,427 = Dialogue; VDNKh_Dialogues 1,292 = Dialogue;
  Theatre_Dialogues 629 = Dialogue. Master rows 27,618; no U+FFFD; source and Arabic
  columns untouched (Arabic empty by design).

## 4. Idempotency check

A second run of batch 3 reported `retag 0` and `[write] master untouched`, validator PASS.

## 5. Cumulative state after batch 3

| Metric | Batch 1 | Batch 2 | Batch 3 |
|---|---|---|---|
| Covered | 2,626 of 10,505 (25%) | 5,253 of 10,505 (50%) | 7,879 of 10,505 (75%) |
| Added new rows | 0 | 0 | 0 |
| Validator | PASS | PASS | PASS |

All three batches still lie inside the 14 locre sources, so 0 new rows so far. Batch 4
is the only step that adds rows (the 4 cooked English-prose assets, 111 strings).

## 6. Next action

Batch 4 (cumulative 100%, cutoff 10,505): remaining 1,278 strings of VDNKh_Dialogues,
Cutscenes_dlc1 421 (DLC1), Locations_dlc2 816 (DLC2), then the 4 cooked assets
(NotLifted_17 1, DT_Subtitles_Schebetars 41, DT_Subtitles_DLC02_Schebetars 49,
D_DLC04_10 20) - these 111 strings are the only NEW master rows of the whole program.
Expect DLC1/DLC2/DLC4 coverage to move from 0% to 100% in that step.
