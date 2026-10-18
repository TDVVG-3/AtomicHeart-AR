# Cycle 006 report - dialogue/cutscene text program, batch 1 of 4 (25%)

Date: 2026-10-18. Spec hash at cycle start: PASS
(579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35).
Local git only; `git remote -v` empty; nothing uploaded; no game-folder install.

## 1. What was asked

Extract ALL dialogue and cutscene text (subtitles, dialogue lines, radio, NORA/Char-les,
cutscene captions, text-stored voice transcripts) in FOUR cumulative batches
(25/50/75/100%) into `localization/master/atomic-heart-ar.tsv`, English source column
only (no translation yet), with a full inventory manifest and an exact 100% total.

## 2. Work completed this cycle

| Step | Result | Evidence |
|---|---|---|
| Spec hash check | PASS | SHA256 matches the guarded hash |
| Count pass over 4,325 candidate cooked assets | PASS | 4 workers, 23 min, 4,325 rows, 0 FETCH-FAIL, 0 stderr bytes (reports/dialogue_st_counts.tsv) |
| Decoder verification (Cyrillic) | PASS | ST_DLC01_Goose_Sentences dump decoded "Все получат по ебалу! И Сережа тоже!" and "Все на перевыборы советов" - no mojibake, no '?' substitution |
| String selection rule | PASS | DEC-019 prose filter shared by inventory + batch tool (scripts/dialogue_strings_lib.ps1) |
| Inventory + 100% TOTAL | PASS | reports/dialogue_inventory.md: TOTAL = 10,505 |
| RU-only separation | PASS | reports/dialogue_ru_only.md: 246 assets / 5,903 strings, excluded from TOTAL |
| Batch 1 apply (25%) | PASS | covered 2,626 of 10,505 (25%); added 0; already present 2,626; dup 0; retag 3,286 |
| Validator | PASS | 0 problems, 27,618 rows, UTF-8 round-trip OK, no NEW duplicate ids |

## 3. Exact inventory (the 100% definition)

TOTAL = 10,505 dialogue/cutscene strings that HAVE an English source:

- en-US locres, 14 scopes = 10,394 strings (already in the master TSV before this cycle):
  Academy_Dialogues 282, Chelomey_Dialogues 1,204, ChelomeyFinal_Dialogues 214,
  CUTSCENES 840, DIALOGUES FOR LQA 746, OpenWorldVDNKh_Dialogues 443, Pavlov_Dialogues 520,
  Polygon_Dialogues 199, Schebetar_Subs 361, Theatre_Dialogues 629, Vavilov_Dialogues 2,427,
  VDNKh_Dialogues 1,292, Cutscenes_dlc1 421 (DLC1), Locations_dlc2 816 (DLC2).
- cooked assets with English prose = 111 strings in 4 assets:
  DT_Subtitles_Schebetars 41, DT_Subtitles_DLC02_Schebetars 49 (DLC2),
  D_DLC04_10 20 (DLC4), NotLifted_17 1 (base cutscene).

RU-only (no English anywhere, KI-010 class): 246 assets / 5,903 prose strings
(reports/dialogue_ru_only.md). Excluded from TOTAL and from all batches.

Batch cutoffs (cumulative): batch 1 = 2,626; batch 2 = 5,253; batch 3 = 7,879;
batch 4 = 10,505.

## 4. Batch 1 result

    [batch 1] TOTAL 10505 strings; cumulative cutoff 2626
      locres Academy_Dialogues              present 282/282 full retag 282
      locres Chelomey_Dialogues             present 1204/1204 full retag 1486
      locres ChelomeyFinal_Dialogues        present 214/214 full retag 1700
      locres CUTSCENES                      present 840/840 full retag 2540
      locres DIALOGUES FOR LQA              present 86/746 partial retag 3286
    [batch 1] covered 2626 of 10505 (25%); added 0; already 2626; dup 0; retag 3286
    [validation] duplicate ids total 728; pre-existing 728; new 0
    [validation] PASS (0 problems, 27618 rows)
    [write] master rows 27618 -> 27618

Coverage by category (cumulative):

| Category | Covered |
|---|---|
| Cutscene | 840 of 1,262 (66.6%) |
| Dialogue | 1,786 of 8,792 (20.3%) |
| Subtitles | 0 of 451 (0%) |

Coverage by DLC (cumulative):

| DLC | Covered |
|---|---|
| base | 2,626 of 9,199 (28.5%) |
| DLC1 | 0 of 421 (0%) |
| DLC2 | 0 of 865 (0%) |
| DLC4 | 0 of 20 (0%) |

Note on "added 0": the batch order (DEC-017) puts the 14 locre sources first and the
4 cooked English-prose assets last. Batch 1 therefore lies entirely inside the locre
scope, where every row already existed in the master - so there are 0 new rows and the
batch's real effect is (a) canonical Category retagging and (b) coverage marking.
New rows from cooked assets appear in batch 4 (they are the last 111 strings of TOTAL).

## 5. Problems found and fixed this cycle

1. Over-extraction: raw UTF-16 runs gave 5,005,978 "strings" (asset/engine names and
   binary fragments). Fixed by the DEC-019 prose filter applied identically in the
   inventory and the batch tool. TOTAL went from a meaningless 5,016,372 to 10,505.
2. Locres source matching: the batch tool matched `/en-US/<scope>/` but files end
   `<scope>.locres`, so 0 rows matched on the first run. Fixed to `/en-US/<scope>\.locres$`.
3. Validator false FAIL: the master already had 728 duplicate IDs (KI-016). The
   validator now baselines that count and fails only on NEW duplicates.
4. Retag-only batches were not being persisted (write gate only triggered on row-count
   change). Fixed: the master is written when rows changed OR any retag occurred.
5. Stale count-pass generations / alignment-bugged decoder output (DEC-018): all stale
   dumps and part TSVs were purged and the pass rerun from a clean slate with the
   verified decoder.

## 6. Artifacts written

- `reports/dialogue_inventory.md` - exact TOTAL, per-source tables, split rule, cutoffs.
- `reports/dialogue_ru_only.md` - RU-only assets and samples (KI-010 class).
- `reports/dialogue_st_counts.tsv` - per-asset scan registry (4,325 rows).
- `reports/dialogue_inventory_raw/sources_lockres.tsv` (14 ordered locre sources),
  `sources_st.tsv` (4 ordered cooked sources), `chunk_1..4.txt`, `worker_1..4.log/.err`,
  `counts_part_1..4.tsv`.
- Scripts: `dialogue_st_counts.ps1`, `dialogue_count_worker.ps1`, `dialogue_strings_lib.ps1`,
  `dialogue_finalize.ps1`, `dialogue_batch_apply.ps1`.
- `localization/references/AR_EN_REFERENCE.md` (0 rows with Arabic, by design).
- Docs: DECISIONS.md (DEC-019, DEC-020), KNOWN_ISSUES.md (KI-016), STATUS.md, HANDOFF.md.

## 7. State and next action

- Text only: no audio/video/media touched; no raw game asset committed (the 4,319
  string dumps live under `localization/extracted/dialogue/`, which is gitignored).
- Game folder read-only; nothing installed or removed this cycle; Test-3 paks in `~mods`
  were not disturbed.
- Arabic column remains empty (translation deliberately not started).
- Next action: wait for the user's "next", then run batch 2 (50%, cutoff 5,253), which
  completes DIALOGUES FOR LQA, OpenWorldVDNKh_Dialogues and Pavlov_Dialogues.
