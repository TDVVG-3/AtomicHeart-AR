# p12 master - CHANGE 1 + CHANGE 2

Generated: 2026-10-27 23:28:20 +03:00

Base: `build\variants\atomic-heart-ar_p11ef.tsv`
Output: `build\variants\atomic-heart-ar_p12ef.tsv`
Fixups: `C:\AtomicHeart-AR\localization\working\tm_fixups_p12.tsv`

## Change counts

| item | count |
| --- | ---: |
| master rows | 27618 |
| keep-original rows cleared to COPY | 458 |
| keep-original rows found in master | 458 |
| keep-original rows with Arabic before | 445 |
| exact P-3 speaker-label rows | 1140 |
| P-3 rows already Arabic before | 0 |
| P-3 rows filled with the Major label | 1140 |
| P-3 rows still empty | 0 |
| P-3 rows with a different Arabic value | 0 |
| body-text rows containing P-3 | 126 |
| body-text P-3 rows changed (must be 0) | 0 |
| in-sentence item-name rows changed by cell rules | 123 |

## Before / after by scope

| scope | rows | Arabic before | Arabic after | COPY after | keep rows | P-3 labels | in-sentence rows |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Academy_Dialogues | 282 | 259 | 282 | 0 | 0 | 23 | 3 |
| Chelomey_Dialogues | 1204 | 1119 | 1201 | 0 | 0 | 82 | 2 |
| Chelomey_dlc3 | 776 | 772 | 773 | 0 | 0 | 1 | 3 |
| ChelomeyFinal_Dialogues | 214 | 186 | 214 | 0 | 0 | 28 | 3 |
| CrystalComplex_dlc4 | 1219 | 1219 | 1219 | 0 | 0 | 0 | 1 |
| CUTSCENES | 840 | 720 | 839 | 0 | 0 | 119 | 1 |
| Cutscenes_dlc1 | 421 | 417 | 418 | 0 | 0 | 1 | 6 |
| DIALOGUES FOR LQA | 746 | 746 | 746 | 0 | 0 | 0 | 0 |
| LebedevLab_dlc4 | 460 | 460 | 460 | 0 | 0 | 0 | 2 |
| Locations_dlc2 | 816 | 815 | 816 | 0 | 0 | 1 | 1 |
| Mails_01 | 454 | 454 | 454 | 0 | 0 | 0 | 4 |
| Mails_Shebetars_dlc2 | 246 | 246 | 246 | 0 | 0 | 0 | 0 |
| Mails_Shebetars_dlc4 | 756 | 756 | 756 | 0 | 0 | 0 | 1 |
| Mails_Shebetars_Tech_dlc3 | 579 | 578 | 578 | 0 | 0 | 0 | 3 |
| Marshes_dlc1 | 156 | 155 | 155 | 0 | 0 | 0 | 2 |
| Mendeleev_dlc1 | 411 | 411 | 411 | 0 | 0 | 0 | 1 |
| Misc | 21 | 19 | 20 | 0 | 0 | 1 | 0 |
| NewP5 | 5597 | 5332 | 5071 | 273 | 273 | 2 | 41 |
| NTD | 1429 | 1405 | 1405 | 0 | 0 | 0 | 0 |
| OpenWorldVDNKh_Dialogues | 443 | 432 | 443 | 0 | 0 | 11 | 3 |
| Pavlov_Dialogues | 520 | 404 | 520 | 0 | 0 | 116 | 5 |
| PearTerminals | 545 | 539 | 539 | 0 | 0 | 0 | 1 |
| Phasatron_dlc4 | 489 | 489 | 489 | 0 | 0 | 0 | 1 |
| Polygon_Dialogues | 199 | 150 | 199 | 0 | 0 | 49 | 0 |
| Sakhalin_dlc3 | 848 | 842 | 842 | 0 | 0 | 0 | 0 |
| Schebetar_Subs | 361 | 360 | 360 | 0 | 0 | 0 | 0 |
| Schebetars_dlc1 | 96 | 94 | 94 | 0 | 0 | 0 | 2 |
| Tech_dlc2 | 228 | 161 | 143 | 18 | 18 | 0 | 12 |
| Tech_dlc3 | 422 | 400 | 382 | 19 | 19 | 0 | 3 |
| Tech_dlc4 | 1273 | 1262 | 1117 | 148 | 148 | 1 | 5 |
| Theatre_Dialogues | 629 | 572 | 629 | 0 | 0 | 57 | 1 |
| Triton_dlc3 | 928 | 928 | 928 | 0 | 0 | 0 | 2 |
| Vavilov_Dialogues | 2427 | 1962 | 2427 | 0 | 0 | 465 | 9 |
| VDNKh_Dialogues | 1292 | 1067 | 1250 | 0 | 0 | 183 | 2 |
| WavePlatform_dlc4 | 291 | 291 | 291 | 0 | 0 | 0 | 3 |

The canonical master is untouched. Keep-original rows use empty Arabic + Status COPY so the carrier fill policy emits the English name. P-3 labels and in-sentence item names are applied by `tm_fixups_p12.tsv`; the shared `tm_fixups.tsv` also contains the same rules for the record, but p12 never applies the older p11f rules.
