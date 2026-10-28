# Subtitle caps - H1H2H3

Generated: 2026-10-27 23:25:35 +03:00
Input: `build\variants\atomic-heart-ar_p12.tsv`
Output: `build\variants\atomic-heart-ar_p12g.tsv`

| item | count |
| --- | ---: |
| rows changed | 2658 |
| H1 duplicate-start offsets | 72 |
| H1 non-monotonic tracks left unchanged | 197 |
| H2 end caps before next start | 59 |
| H3 final-page ends added | 188 |
| H3 markerless pages given *0-end* | 2422 |
| H3 final ends capped at clip end | 0 |
| H3 rows skipped (no clip duration) | 343 |

## Per scope

| scope | rows | H1 | H2 | H3 ends | H3 inserts |
| --- | ---: | ---: | ---: | ---: | ---: |
| Academy_Dialogues | 282 | 12 | 0 | 8 | 28 |
| Chelomey_Dialogues | 1201 | 7 | 0 | 24 | 378 |
| Chelomey_dlc3 | 773 | 0 | 0 | 0 | 0 |
| ChelomeyFinal_Dialogues | 214 | 0 | 0 | 0 | 42 |
| CrystalComplex_dlc4 | 1219 | 0 | 0 | 0 | 0 |
| CUTSCENES | 839 | 5 | 0 | 20 | 385 |
| Cutscenes_dlc1 | 418 | 0 | 0 | 0 | 51 |
| DIALOGUES FOR LQA | 746 | 5 | 0 | 0 | 0 |
| LebedevLab_dlc4 | 460 | 0 | 0 | 0 | 0 |
| Locations_dlc2 | 816 | 0 | 0 | 0 | 0 |
| Mails_01 | 454 | 0 | 0 | 0 | 0 |
| Mails_Shebetars_dlc2 | 246 | 0 | 0 | 0 | 0 |
| Mails_Shebetars_dlc4 | 756 | 0 | 0 | 0 | 0 |
| Mails_Shebetars_Tech_dlc3 | 578 | 0 | 0 | 0 | 0 |
| Marshes_dlc1 | 155 | 0 | 0 | 0 | 67 |
| Mendeleev_dlc1 | 411 | 0 | 0 | 0 | 118 |
| Misc | 20 | 0 | 0 | 0 | 0 |
| NewP5 | 5071 | 0 | 0 | 0 | 0 |
| NTD | 1405 | 0 | 0 | 0 | 0 |
| OpenWorldVDNKh_Dialogues | 443 | 4 | 0 | 13 | 103 |
| Pavlov_Dialogues | 520 | 14 | 0 | 27 | 174 |
| PearTerminals | 539 | 0 | 0 | 0 | 0 |
| Phasatron_dlc4 | 489 | 0 | 0 | 0 | 1 |
| Polygon_Dialogues | 199 | 3 | 0 | 16 | 60 |
| Sakhalin_dlc3 | 842 | 0 | 0 | 0 | 0 |
| Schebetar_Subs | 360 | 0 | 53 | 0 | 0 |
| Schebetars_dlc1 | 94 | 0 | 6 | 0 | 0 |
| Tech_dlc2 | 143 | 0 | 0 | 0 | 0 |
| Tech_dlc3 | 382 | 0 | 0 | 0 | 0 |
| Tech_dlc4 | 1117 | 0 | 0 | 0 | 0 |
| Theatre_Dialogues | 629 | 7 | 0 | 15 | 97 |
| Triton_dlc3 | 928 | 0 | 0 | 0 | 0 |
| Vavilov_Dialogues | 2427 | 8 | 0 | 36 | 597 |
| VDNKh_Dialogues | 1250 | 7 | 0 | 29 | 321 |
| WavePlatform_dlc4 | 291 | 0 | 0 | 0 | 0 |

H1 only offsets duplicate page starts. H2 caps explicit range ends strictly before the next page start. H3 adds an end to a final singleton page; for markerless cells it inserts `*0-end*` using the Wwise clip duration and a 15 chars/s + 1.2 s reading allowance. Absolute DataTable row start offsets are not present in the cooked data, so the next *line* start cannot be used directly; the clip end is the conservative cap. This is the UNKNOWN limitation documented in the stack audit.
