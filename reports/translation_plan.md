# Translation plan - Arabic (4 cumulative batches)

Generated: 2026-10-18 20:22:59

## TOTAL (the 100%)

- TOTAL = **27618 rows** (master rows with a non-empty English source, excluding Status TECHNICAL/BLOCKED).
- U = **19996 unique English strings** (translation memory: each unique English string is translated once and reused only when the context matches).
- Excluded: Status TECHNICAL = 0 rows, Status BLOCKED = 0 rows (both zero today).
- Master rows read: 27618.  Rows that repeat an English string: 7622 (translation reuse, not new translation work).

## Priority order and cutoffs

Batches are CUMULATIVE: batch N covers the first `round(TOTAL*N/4)` rows of the order below.

| batch | % | cumulative row cutoff | cumulative unique strings | last scope touched |
|---|---|---|---|---|
| 1 | 25% | 6905 of 27618 | 4562 | Chelomey_Dialogues |
| 2 | 50% | 13809 of 27618 | 8648 | Vavilov_Dialogues |
| 3 | 75% | 20714 of 27618 | 14037 | Mails_Shebetars_Tech_dlc3 |
| 4 | 100% | 27618 of 27618 | 19996 | WavePlatform_dlc4 |

## Tiers

| tier | description | rows | share |
|---|---|---|---|
| 1 | system UI, menus, HUD, tutorials, items, weapons, skills, objectives | 6163 | 22.3% |
| 2 | dialogue, subtitles, cutscenes | 9157 | 33.2% |
| 3 | lore, DLC content, credits | 12298 | 44.5% |

## Ordered scope list (the exact work order)

| # | tier | scope | rows | cumulative rows | cumulative unique | categories |
|---|---|---|---|---|---|---|
| 1 | 1 | NewP5 | 5597 | 5597 | 3857 | UI=5597 |
| 2 | 1 | Misc | 21 | 5618 | 3871 | UI=21 |
| 3 | 1 | PearTerminals | 545 | 6163 | 4286 | UI=545 |
| 4 | 2 | Academy_Dialogues | 282 | 6445 | 4506 | Dialogue=282 |
| 5 | 2 | Chelomey_Dialogues | 1204 | 7649 | 5199 | Dialogue=1204 |
| 6 | 2 | ChelomeyFinal_Dialogues | 214 | 7863 | 5306 | Dialogue=214 |
| 7 | 2 | CUTSCENES | 840 | 8703 | 5785 | Cutscene=840 |
| 8 | 2 | DIALOGUES FOR LQA | 746 | 9449 | 6495 | Dialogue=746 |
| 9 | 2 | OpenWorldVDNKh_Dialogues | 443 | 9892 | 6675 | Dialogue=443 |
| 10 | 2 | Pavlov_Dialogues | 520 | 10412 | 6917 | Dialogue=520 |
| 11 | 2 | Polygon_Dialogues | 199 | 10611 | 7025 | Dialogue=199 |
| 12 | 2 | Schebetar_Subs | 361 | 10972 | 7383 | Subtitles=361 |
| 13 | 2 | Theatre_Dialogues | 629 | 11601 | 7707 | Dialogue=629 |
| 14 | 2 | Vavilov_Dialogues | 2427 | 14028 | 8829 | Dialogue=2427 |
| 15 | 2 | VDNKh_Dialogues | 1292 | 15320 | 9505 | Dialogue=1292 |
| 16 | 3 | NTD | 1429 | 16749 | 10837 | Lore=1429 |
| 17 | 3 | Mails_01 | 454 | 17203 | 11020 | Lore=454 |
| 18 | 3 | Cutscenes_dlc1 | 421 | 17624 | 11409 | Cutscene=421 |
| 19 | 3 | Marshes_dlc1 | 156 | 17780 | 11536 | Unknown=156 |
| 20 | 3 | Mendeleev_dlc1 | 411 | 18191 | 11936 | Unknown=411 |
| 21 | 3 | Schebetars_dlc1 | 96 | 18287 | 12011 | Unknown=96 |
| 22 | 3 | Locations_dlc2 | 816 | 19103 | 12779 | Dialogue=816 |
| 23 | 3 | Mails_Shebetars_dlc2 | 246 | 19349 | 13014 | Lore=246 |
| 24 | 3 | Tech_dlc2 | 228 | 19577 | 13168 | Unknown=228 |
| 25 | 3 | Chelomey_dlc3 | 776 | 20353 | 13900 | Unknown=776 |
| 26 | 3 | Mails_Shebetars_Tech_dlc3 | 579 | 20932 | 14222 | Lore=579 |
| 27 | 3 | Sakhalin_dlc3 | 848 | 21780 | 15019 | Unknown=848 |
| 28 | 3 | Tech_dlc3 | 422 | 22202 | 15271 | Unknown=422 |
| 29 | 3 | Triton_dlc3 | 928 | 23130 | 16178 | Unknown=928 |
| 30 | 3 | CrystalComplex_dlc4 | 1219 | 24349 | 17358 | Unknown=1219 |
| 31 | 3 | LebedevLab_dlc4 | 460 | 24809 | 17792 | Unknown=460 |
| 32 | 3 | Mails_Shebetars_dlc4 | 756 | 25565 | 18290 | Lore=756 |
| 33 | 3 | Phasatron_dlc4 | 489 | 26054 | 18771 | Unknown=489 |
| 34 | 3 | Tech_dlc4 | 1273 | 27327 | 19711 | Unknown=1273 |
| 35 | 3 | WavePlatform_dlc4 | 291 | 27618 | 19996 | Unknown=291 |

## Batch boundary notes

The cutoffs do NOT align with scope boundaries; a scope can be split across two
batches. The rule is: rows are taken in the order above until the cumulative count
reaches the cutoff. A scope is "delivered" when its last row is inside a batch.

Rules that apply to every batch (see DEC-023):
- translate each UNIQUE English string once; reuse across rows only when the context matches;
- Arabic column filled, Status set to DRAFT, never overwrite a reviewed row;
- placeholders/rich-text tags/escapes preserved exactly;
- glossary terms transliterated/translated/preserved exactly as in glossary/glossary.tsv;
- validation via scripts/validate_translation.py (placeholders, tags, UTF-8, empty Arabic, untranslated English, glossary, length).

