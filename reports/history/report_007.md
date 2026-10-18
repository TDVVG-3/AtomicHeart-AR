# Cycle 006 report (addendum) - dialogue batch 2 of 4 (50%)

Date: 2026-10-18. Spec hash at step start: PASS
(579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35).
Local git only; `git remote -v` empty; nothing uploaded; no game-folder install.

## 1. Scope of this step

Apply cumulative batch 2 (50%) of the dialogue/cutscene program on top of batch 1.
TOTAL is unchanged at 10,505 (batch 1 defined it); the cumulative cutoff is 5,253.

## 2. Batch 2 result

    [batch 2] TOTAL 10505 strings; cumulative cutoff 5253
      locres Academy_Dialogues              present 282/282 full retag 0
      locres Chelomey_Dialogues             present 1204/1204 full retag 0
      locres ChelomeyFinal_Dialogues        present 214/214 full retag 0
      locres CUTSCENES                      present 840/840 full retag 0
      locres DIALOGUES FOR LQA              present 746/746 full retag 0
      locres OpenWorldVDNKh_Dialogues       present 443/443 full retag 443
      locres Pavlov_Dialogues               present 520/520 full retag 963
      locres Polygon_Dialogues              present 199/199 full retag 1162
      locres Schebetar_Subs                 present 361/361 full retag 1523
      locres Theatre_Dialogues              present 444/629 partial retag 2152
    [batch 2] covered 5253 of 10505 (50%); added 0; already 5253; dup 0; retag 2152
    [coverage by category]
      Cutscene  840 of 1262 (66.6%)
      Dialogue  4052 of 8792 (46.1%)
      Subtitles 361 of 451 (80%)
    [coverage by DLC]
      base  5253 of 9199 (57.1%)
      DLC1  0 of 421 (0%)
      DLC2  0 of 865 (0%)
      DLC4  0 of 20 (0%)
    [validation] UTF-8 round-trip: OK (no U+FFFD)
    [validation] rich-text tags in source (informational): 209 opening, 118 self-closing, 80 closing
      -> 11 rows with unpaired tags, all pre-existing and outside the dialogue scope.
    [validation] duplicate ids total 728; pre-existing 728; new 0
    [validation] PASS (0 problems, 27618 rows)
    [write] master rows 27618 -> 27618

## 3. What changed in the master

- DIALOGUES FOR LQA is now fully inside the batch (746/746) - batch 1 counted only 86.
- New Category retags this step: OpenWorldVDNKh_Dialogues 443, Pavlov_Dialogues 520,
  Polygon_Dialogues 199, Schebetar_Subs 361 (was "Unknown" -> now Subtitles),
  Theatre_Dialogues 629 (the source straddles the 50% boundary; per DEC-020 the whole
  source is retagged by the batch that first touches it, while only 444 of its strings
  count toward coverage).
- Verified on disk: Schebetar_Subs 361 rows = Subtitles; Theatre_Dialogues 629 = Dialogue;
  Pavlov_Dialogues 520 = Dialogue; Polygon_Dialogues 199 = Dialogue.
- Row count unchanged: 27,618. Master content columns and Arabic column untouched.

## 4. Idempotency check

A second run of batch 2 reported `retag 0` and `[write] master untouched` with validator
PASS - the batch tool is idempotent, as required.

## 5. Cumulative state after batch 2

| Metric | Batch 1 | Batch 2 |
|---|---|---|
| Covered | 2,626 of 10,505 (25%) | 5,253 of 10,505 (50%) |
| Added new rows | 0 | 0 |
| Retagged categories | 3,286 | 2,152 (this step) |
| Validator | PASS | PASS |

Batch 2 still lies entirely inside the 14 locre sources, so 0 new rows are expected;
the 4 cooked English-prose assets (111 strings) are the last sources and belong to
batch 4. This is documented in DEC-020.

## 6. Next action

Batch 3 (cumulative 75%, cutoff 7,879), verified composition against the ordered sources:
the remaining 185 strings of Theatre_Dialogues, then Vavilov_Dialogues in full (2,427),
then the first 14 strings of VDNKh_Dialogues (5,253 + 185 + 2,427 + 14 = 7,879).
Batch 4 (100%) then covers: the remaining 1,278 of VDNKh_Dialogues, Cutscenes_dlc1 421
(DLC1), Locations_dlc2 816 (DLC2), and the 4 cooked English-prose assets
(NotLifted_17 1, DT_Subtitles_Schebetars 41, DT_Subtitles_DLC02_Schebetars 49,
D_DLC04_10 20) - the only step that adds NEW rows.
Note: DLC1/DLC2/DLC4 coverage stays 0% until batch 4.
