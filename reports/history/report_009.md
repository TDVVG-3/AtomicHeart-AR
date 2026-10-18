# Cycle 006 report (addendum) - dialogue batch 4 of 4 (100%), and scope correction

Date: 2026-10-18. Spec hash at step start: PASS
(579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35).
Local git only; `git remote -v` empty; nothing uploaded; no game-folder install.

## 1. Scope of this step

Apply the final cumulative batch (100%) of the dialogue/cutscene program, verify the
final coverage "N of TOTAL (100%)" against reports/dialogue_inventory.md, and correct
the inventory where the first attempt proved wrong.

## 2. First attempt FAILED (and why) - important

Batch 4 initially reported "covered 10505 of 10505 (100%); added 111" but the validator
FAILED with "rows with wrong field count: 111". Two separate defects were found:

1. ROW BUILDER BUG (code): in PowerShell the comma operator binds TIGHTER than '+',
   so the unparenthesised expression
       @( ..., 'NEW', 'cooked asset scan; no source keys; batch ' + $Batch, '' )
   was parsed as TWO array elements (the string, then the int $Batch), producing
   14-field rows instead of 13. Fixed by parenthesising the concatenation.
   Evidence: element 12 was Int32 and element 13 was String on all 111 rows.

2. WRONG STRINGS (scope): even with correct field counts, those 111 strings were NOT
   English. Inspection showed Cyrillic subtitle text with timecode markers, e.g.
       *0.00-0.05* &<Cyrillic>... non penis canis est! ...
   plus one encoded payload (NotLifted_17: `LKKELLMKLM"!KLLMKMLNMLLN$"ML&NLONL #'&&L'PQR`).
   The DEC-019 EN test ("contains any 3+ Latin letters") passed merely because a Russian
   line embedded a Latin phrase.

Action taken: the 111 bogus rows were deleted from the master by matching exactly
Status NEW + Notes 'cooked asset scan' (all legitimate Category retags preserved).
Master row count 27,729 -> 27,618.

## 3. Classifier corrected (DEC-021)

`Get-AssetClass` in scripts/dialogue_finalize.ps1 now classifies each chosen asset:

| class | rule |
|---|---|
| ru-only | Cyrillic >= 10 AND Cyrillic >= Latin (checked first) |
| english | Latin >= 10, Cyrillic == 0, vowel ratio >= 0.15 |
| obfuscated | Latin >= 10, Cyrillic == 0, vowel ratio < 0.15 |
| mixed | both scripts substantial, Latin dominant |
| skip | no usable text |

Corrected result:

    [collapse] EN-source sources: 0 | RU-only sources: 248 | obfuscated: 1 | mixed: 0 | skipped: 3082
    [total] EN-source asset strings: 0
    [ru-only] assets 248, strings 6012
    [obfuscated] assets 1, strings 1
    [inventory] TOTAL = 10394 (locres 10394 + assets 0)

So the exact English-source inventory is the 14 en-US locre scopes = 10,394 strings.
New reports: reports/dialogue_ru_only.md (248 assets, 6,012 strings) and
reports/dialogue_obfuscated.md (1 asset - BLOCKED, KI-017).

Effect on batch cutoffs: corrected marks are 2,599 / 5,197 / 7,796 / 10,394. Batches
1-3 were cut against the old TOTAL of 10,505 and delivered 2,626 / 5,253 / 7,879
strings - each at or above the corrected mark - so no re-delivery was required.

## 4. Batch 4 result (corrected)

    [batch 4] TOTAL 10394 strings; cumulative cutoff 10394
      (all 14 locre sources full and already present; retag 0)
    [batch 4] covered 10394 of 10394 (100%); added 0; already 10394; dup 0; retag 0
    [coverage by category]
      Cutscene  1261 of 1261 (100%)
      Dialogue  8772 of 8772 (100%)
      Subtitles 361 of 361 (100%)
    [coverage by DLC]
      base  9157 of 9157 (100%)
      DLC1  421 of 421 (100%)
      DLC2  816 of 816 (100%)
    [validation] UTF-8 round-trip: OK (no U+FFFD)
    [validation] duplicate ids total 728; pre-existing 728; new 0
    [validation] PASS (0 problems, 27618 rows)
    [write] master untouched (validation failed or nothing new)

"Master untouched" is correct here: no new rows (there is no English cooked text to add)
and no retag remained after the earlier run in this same step applied the
Cutscenes_dlc1 (421) / Locations_dlc2 (816) categories.

## 5. Final independent verification (on disk)

All 14 dialogue scopes, reading localization/master/atomic-heart-ar.tsv directly:

| scope | rows | Category | check |
|---|---|---|---|
| Academy_Dialogues | 282 | Dialogue | OK |
| Chelomey_Dialogues | 1204 | Dialogue | OK |
| ChelomeyFinal_Dialogues | 214 | Dialogue | OK |
| CUTSCENES | 840 | Cutscene | OK |
| Cutscenes_dlc1 | 421 | Cutscene | OK |
| DIALOGUES FOR LQA | 746 | Dialogue | OK |
| Locations_dlc2 | 816 | Dialogue | OK |
| OpenWorldVDNKh_Dialogues | 443 | Dialogue | OK |
| Pavlov_Dialogues | 520 | Dialogue | OK |
| Polygon_Dialogues | 199 | Dialogue | OK |
| Schebetar_Subs | 361 | Subtitles | OK |
| Theatre_Dialogues | 629 | Dialogue | OK |
| Vavilov_Dialogues | 2427 | Dialogue | OK |
| VDNKh_Dialogues | 1292 | Dialogue | OK |
| **total** | **10394** | all canonical | **10,394 of 10,394 (100%)** |

Master rows 27,618; no U+FFFD; Arabic column still empty.

## 6. Cumulative state

| Batch | Delivered | Corrected mark | Validator |
|---|---|---|---|
| 1 (25%) | 2,626 | 2,599 | PASS |
| 2 (50%) | 5,253 | 5,197 | PASS |
| 3 (75%) | 7,879 | 7,796 | PASS |
| 4 (100%) | 10,394 of 10,394 (100%) | 10,394 | PASS |

## 7. What this means for the project

- The complete English-source dialogue/cutscene text is in the master TSV and marked
  with canonical categories. Nothing was translated (Arabic empty by design).
- There is no cooked English dialogue to add: every non-locres dialogue asset is
  Russian-only (KI-018) or obfuscated (KI-017, BLOCKED).
- Translation can now start on the 10,394 dialogue rows; RU-only content would need a
  separate decision (Phase 8 uasset path) before it can be localised at all.
