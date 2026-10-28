# Subtitle caps - H2

Generated: 2026-10-27 23:27:34 +03:00
Input: `build\variants\atomic-heart-ar_p12c.tsv`
Output: `build\variants\atomic-heart-ar_p12c.tsv`

| item | count |
| --- | ---: |
| rows changed | 17 |
| H1 duplicate-start offsets | 0 |
| H1 non-monotonic tracks left unchanged | 0 |
| H2 end caps before next start | 59 |
| H3 final-page ends added | 0 |
| H3 markerless pages given *0-end* | 0 |
| H3 final ends capped at clip end | 0 |
| H3 rows skipped (no clip duration) | 0 |

## Per scope

| scope | rows | H1 | H2 | H3 ends | H3 inserts |
| --- | ---: | ---: | ---: | ---: | ---: |
| Academy_Dialogues | 282 | 0 | 0 | 0 | 0 |
| Chelomey_Dialogues | 1201 | 0 | 0 | 0 | 0 |
| Chelomey_dlc3 | 773 | 0 | 0 | 0 | 0 |
| ChelomeyFinal_Dialogues | 214 | 0 | 0 | 0 | 0 |
| CrystalComplex_dlc4 | 1219 | 0 | 0 | 0 | 0 |
| CUTSCENES | 839 | 0 | 0 | 0 | 0 |
| Cutscenes_dlc1 | 418 | 0 | 0 | 0 | 0 |
| DIALOGUES FOR LQA | 746 | 0 | 0 | 0 | 0 |
| LebedevLab_dlc4 | 460 | 0 | 0 | 0 | 0 |
| Locations_dlc2 | 816 | 0 | 0 | 0 | 0 |
| Mails_01 | 454 | 0 | 0 | 0 | 0 |
| Mails_Shebetars_dlc2 | 246 | 0 | 0 | 0 | 0 |
| Mails_Shebetars_dlc4 | 756 | 0 | 0 | 0 | 0 |
| Mails_Shebetars_Tech_dlc3 | 578 | 0 | 0 | 0 | 0 |
| Marshes_dlc1 | 155 | 0 | 0 | 0 | 0 |
| Mendeleev_dlc1 | 411 | 0 | 0 | 0 | 0 |
| Misc | 20 | 0 | 0 | 0 | 0 |
| NewP5 | 5071 | 0 | 0 | 0 | 0 |
| NTD | 1405 | 0 | 0 | 0 | 0 |
| OpenWorldVDNKh_Dialogues | 443 | 0 | 0 | 0 | 0 |
| Pavlov_Dialogues | 520 | 0 | 0 | 0 | 0 |
| PearTerminals | 539 | 0 | 0 | 0 | 0 |
| Phasatron_dlc4 | 489 | 0 | 0 | 0 | 0 |
| Polygon_Dialogues | 199 | 0 | 0 | 0 | 0 |
| Sakhalin_dlc3 | 842 | 0 | 0 | 0 | 0 |
| Schebetar_Subs | 360 | 0 | 53 | 0 | 0 |
| Schebetars_dlc1 | 94 | 0 | 6 | 0 | 0 |
| Tech_dlc2 | 143 | 0 | 0 | 0 | 0 |
| Tech_dlc3 | 382 | 0 | 0 | 0 | 0 |
| Tech_dlc4 | 1117 | 0 | 0 | 0 | 0 |
| Theatre_Dialogues | 629 | 0 | 0 | 0 | 0 |
| Triton_dlc3 | 928 | 0 | 0 | 0 | 0 |
| Vavilov_Dialogues | 2427 | 0 | 0 | 0 | 0 |
| VDNKh_Dialogues | 1250 | 0 | 0 | 0 | 0 |
| WavePlatform_dlc4 | 291 | 0 | 0 | 0 | 0 |

H1 only offsets duplicate page starts. H2 caps explicit range ends strictly before the next page start. H3 adds an end to a final singleton page; for markerless cells it inserts `*0-end*` using the Wwise clip duration and a 15 chars/s + 1.2 s reading allowance. Absolute DataTable row start offsets are not present in the cooked data, so the next *line* start cannot be used directly; the clip end is the conservative cap. This is the UNKNOWN limitation documented in the stack audit.
