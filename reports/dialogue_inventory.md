# Dialogue and cutscene text inventory (exact)

Generated: 2026-10-18 19:39; count pass: reports/dialogue_st_counts.tsv (4325 candidate assets scanned, DEC-018 parallel pass).

## 100% TOTAL

**TOTAL = 10394 dialogue/cutscene strings with an English source.**

- locres sources (en-US locres, already in the master TSV): 10394
- non-locres cooked sources (unique EN-source assets after collapse, DEC-019 prose filter): 0
- RU-only strings (reported separately in reports/dialogue_ru_only.md, NOT in TOTAL): 6012
- obfuscated/non-text assets (reported separately in reports/dialogue_obfuscated.md, BLOCKED, NOT in TOTAL): 1 assets

Classification rule (DEC-021): an asset counts as an English source only if its prose
is Latin-dominant with ZERO Cyrillic letters and a vowel ratio >= 0.15; Cyrillic-dominant
assets are RU-only; Latin text with no vowels is treated as obfuscated/binary.

Every percentage in the batch reports is quoted as "N of TOTAL (X%)".

## Locres sources (14 scopes, exact; calibrated: Academy_Dialogues fresh export = 282 rows = master rows)

| # | scope | group | class | strings |
|---|---|---|---|---|
| 1 | Academy_Dialogues | base | Dialogue | 282 |
| 2 | Chelomey_Dialogues | base | Dialogue | 1204 |
| 3 | ChelomeyFinal_Dialogues | base | Dialogue | 214 |
| 4 | CUTSCENES | base | Cutscene | 840 |
| 5 | DIALOGUES FOR LQA | base | Dialogue | 746 |
| 6 | OpenWorldVDNKh_Dialogues | base | Dialogue | 443 |
| 7 | Pavlov_Dialogues | base | Dialogue | 520 |
| 8 | Polygon_Dialogues | base | Dialogue | 199 |
| 9 | Schebetar_Subs | base | Subtitles | 361 |
| 10 | Theatre_Dialogues | base | Dialogue | 629 |
| 11 | Vavilov_Dialogues | base | Dialogue | 2427 |
| 12 | VDNKh_Dialogues | base | Dialogue | 1292 |
| 13 | Cutscenes_dlc1 | DLC1 | Cutscene | 421 |
| 14 | Locations_dlc2 | DLC2 | Dialogue | 816 |

## Non-locres cooked sources (per kind and DLC)

| kind | base | DLC1 | DLC2 | DLC3 | DLC4 | strings |
|---|---|---|---|---|---|---|

Non-locres EN-source assets: 0; RU-only assets: 248 (reports/dialogue_ru_only.md).
String rule: DEC-019 prose filter (scripts/dialogue_strings_lib.ps1), identical in the inventory and the batch tool.

## Batch split rule (DEC-017)

Cumulative batches 25/50/75/100% of TOTAL. Order: locres scopes (base alphabetical,
then DLC1, DLC2), then cooked ASSET sources (DLC then kind then path). Batches cut at
cumulative string counts; batch N includes everything before it.

Batch cutoffs: batch 1 = 2599; batch 2 = 5197; batch 3 = 7796; batch 4 = 10394.
