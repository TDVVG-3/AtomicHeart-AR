# Translation validation report

Generated: 2026-10-21 12:57:29
Validator: scripts/validate_translation.ps1 (PowerShell twin of scripts/validate_translation.py)

RESULT: **PASS**

| metric | value |
|---|---|
| master rows | 27618 |
| rows with Arabic | 26022 |
| hard errors | 0 |
| warnings (number/length/glossary) | 260 |
| - number-multiset warnings | 122 |
| - UI length warnings | 112 |
| - glossary warnings | 26 |

## Status distribution (whole master)

| Status | rows |
|---|---|
| DRAFT | 26022 |
| UNTRANSLATED | 1596 |

## Translated rows per scope

| scope | rows with Arabic |
|---|---|
| NewP5 | 5332 |
| Vavilov_Dialogues | 1962 |
| NTD | 1405 |
| Tech_dlc4 | 1262 |
| CrystalComplex_dlc4 | 1219 |
| Chelomey_Dialogues | 1119 |
| VDNKh_Dialogues | 1067 |
| Triton_dlc3 | 928 |
| Sakhalin_dlc3 | 842 |
| Locations_dlc2 | 815 |
| Chelomey_dlc3 | 772 |
| Mails_Shebetars_dlc4 | 756 |
| DIALOGUES FOR LQA | 746 |
| CUTSCENES | 720 |
| Mails_Shebetars_Tech_dlc3 | 578 |
| Theatre_Dialogues | 572 |
| PearTerminals | 539 |
| Phasatron_dlc4 | 489 |
| LebedevLab_dlc4 | 460 |
| Mails_01 | 454 |
| OpenWorldVDNKh_Dialogues | 432 |
| Cutscenes_dlc1 | 417 |
| Mendeleev_dlc1 | 411 |
| Pavlov_Dialogues | 404 |
| Tech_dlc3 | 400 |
| Schebetar_Subs | 360 |
| WavePlatform_dlc4 | 291 |
| Academy_Dialogues | 259 |
| Mails_Shebetars_dlc2 | 246 |
| ChelomeyFinal_Dialogues | 186 |
| Tech_dlc2 | 161 |
| Marshes_dlc1 | 155 |
| Polygon_Dialogues | 150 |
| Schebetars_dlc1 | 94 |
| Misc | 19 |

## Translated rows per category

| category | rows with Arabic |
|---|---|
| Dialogue | 7712 |
| Unknown | 7484 |
| UI | 5890 |
| Lore | 3439 |
| Cutscene | 1137 |
| Subtitles | 360 |

## Hard errors

None.

## Warnings

- line 286: number multiset differs (en=[0|0|0|0|0|0|07|09|10|10|13|1955|2|2] ar=[0|0|0|0|0|0|07|09|10|10|1955|2|2])
- line 2547: number multiset differs (en=[000|80] ar=[80])
- line 3192: glossary term 'Major' -> 'الرائد' not found in Arabic
- line 3196: glossary term 'Terminal' -> 'محطة طرفية|طرفية' not found in Arabic
- line 3213: glossary term 'Major' -> 'الرائد' not found in Arabic
- line 3409: glossary term 'Snowball' -> 'كرة الثلج' not found in Arabic
- line 4706: glossary term 'Upgrade' -> 'ترقية' not found in Arabic
- line 5568: number multiset differs (en=[50] ar=[])
- line 5704: number multiset differs (en=[] ar=[50|50])
- line 6360: number multiset differs (en=[20] ar=[])
- line 7105: number multiset differs (en=[0|10|15|17|1955|30|5] ar=[10|15|17|1955|30|5])
- line 7690: number multiset differs (en=[100] ar=[])
- line 7795: number multiset differs (en=[112|3] ar=[112])
- line 7802: number multiset differs (en=[140|3] ar=[140])
- line 7803: number multiset differs (en=[141|3] ar=[141])
- line 7805: number multiset differs (en=[154|3] ar=[154])
- line 7812: glossary term 'Neuropolymer' -> 'البوليمر العصبي|البوليمرية العصبية|عصبية بوليمرية' not found in Arabic
- line 7815: number multiset differs (en=[1|19|1955] ar=[19|1955])
- line 7826: number multiset differs (en=[2|214] ar=[214])
- line 7829: glossary term 'Phasotron' -> 'فازاترون' not found in Arabic
- line 7830: glossary term 'Phasotron' -> 'فازاترون' not found in Arabic
- line 7831: glossary term 'Professor' -> 'البروفيسور|أستاذ' not found in Arabic
- line 7831: glossary term 'Doctor' -> 'دكتور|طبيب|طبيبة|دكتورة' not found in Arabic
- line 7835: glossary term 'Argentum' -> 'أرجنتوم' not found in Arabic
- line 7837: number multiset differs (en=[3|34] ar=[34])
- line 7840: number multiset differs (en=[1|1955|25|5|5] ar=[1955|25|5|5])
- line 7842: number multiset differs (en=[3|59] ar=[59])
- line 7843: number multiset differs (en=[3|61] ar=[61])
- line 7844: number multiset differs (en=[3|66] ar=[66])
- line 7849: number multiset differs (en=[3|71] ar=[71])
- line 7852: number multiset differs (en=[1|1955|9] ar=[1955|9])
- line 7853: number multiset differs (en=[3|90] ar=[90])
- line 7854: number multiset differs (en=[167|3] ar=[167])
- line 8323: glossary term 'Comrade' -> 'الرفيق|الرفاق' not found in Arabic
- line 8538: number multiset differs (en=[10|10|1955|2] ar=[10|1955|2])
- line 8561: glossary term 'Comrade' -> 'الرفيق|الرفاق' not found in Arabic
- line 9605: UI length 15 > 1.2 x 12
- line 9614: UI length 52 > 1.2 x 42
- line 9782: number multiset differs (en=[3] ar=[])
- line 9921: UI length 40 > 1.2 x 29
- line 9960: UI length 19 > 1.2 x 15
- line 9961: UI length 20 > 1.2 x 16
- line 9986: UI length 18 > 1.2 x 14
- line 10001: UI length 26 > 1.2 x 21
- line 10071: UI length 17 > 1.2 x 14
- line 10139: UI length 17 > 1.2 x 14
- line 10175: UI length 17 > 1.2 x 14
- line 10215: UI length 22 > 1.2 x 18
- line 10217: UI length 17 > 1.2 x 14
- line 10223: UI length 22 > 1.2 x 18
- line 10241: number multiset differs (en=[1|1] ar=[1])
- line 10278: UI length 23 > 1.2 x 18
- line 10370: UI length 18 > 1.2 x 12
- line 10404: UI length 29 > 1.2 x 21
- line 10455: UI length 23 > 1.2 x 17
- line 10664: UI length 21 > 1.2 x 16
- line 10673: UI length 25 > 1.2 x 20
- line 10695: UI length 21 > 1.2 x 17
- line 10697: UI length 20 > 1.2 x 15
- line 10735: UI length 20 > 1.2 x 16
- line 10761: UI length 29 > 1.2 x 24
- line 10766: UI length 27 > 1.2 x 21
- line 10790: UI length 31 > 1.2 x 25
- line 10833: UI length 39 > 1.2 x 30
- line 10834: UI length 39 > 1.2 x 30
- line 10835: UI length 111 > 1.2 x 88
- line 10913: UI length 17 > 1.2 x 14
- line 11208: UI length 29 > 1.2 x 14
- line 11209: UI length 51 > 1.2 x 39
- line 11210: UI length 34 > 1.2 x 21
- line 11213: UI length 15 > 1.2 x 12
- line 11217: UI length 15 > 1.2 x 12
- line 11271: UI length 15 > 1.2 x 12
- line 11387: UI length 21 > 1.2 x 16
- line 11442: UI length 21 > 1.2 x 16
- line 11538: UI length 19 > 1.2 x 15
- line 11555: UI length 40 > 1.2 x 31
- line 11677: UI length 21 > 1.2 x 15
- line 11678: UI length 21 > 1.2 x 15
- line 11769: UI length 16 > 1.2 x 13
- line 11772: UI length 15 > 1.2 x 12
- line 11773: UI length 15 > 1.2 x 12
- line 11869: UI length 22 > 1.2 x 16
- line 11963: UI length 16 > 1.2 x 13
- line 12091: UI length 16 > 1.2 x 12
- line 12092: UI length 16 > 1.2 x 12
- line 12098: UI length 27 > 1.2 x 21
- line 12103: UI length 40 > 1.2 x 29
- line 12132: UI length 37 > 1.2 x 28
- line 12170: UI length 22 > 1.2 x 18
- line 12171: UI length 19 > 1.2 x 15
- line 12247: UI length 21 > 1.2 x 17
- line 12248: UI length 21 > 1.2 x 17
- line 12251: number multiset differs (en=[3] ar=[])
- line 12251: UI length 29 > 1.2 x 16
- line 12252: number multiset differs (en=[3] ar=[])
- line 12252: UI length 29 > 1.2 x 16
- line 12253: number multiset differs (en=[3] ar=[])
- line 12253: UI length 39 > 1.2 x 30
- line 12254: number multiset differs (en=[3] ar=[])
- line 12254: UI length 39 > 1.2 x 30
- line 12414: UI length 32 > 1.2 x 26
- line 12468: UI length 26 > 1.2 x 20
- line 12539: UI length 20 > 1.2 x 16
- line 12547: UI length 22 > 1.2 x 16
- line 12557: UI length 23 > 1.2 x 18
- line 12562: UI length 21 > 1.2 x 17
- line 12632: UI length 15 > 1.2 x 12
- line 12663: UI length 20 > 1.2 x 15
- line 12727: UI length 18 > 1.2 x 14
- line 12737: UI length 15 > 1.2 x 12
- line 12738: UI length 15 > 1.2 x 12
- line 12846: UI length 27 > 1.2 x 22
- line 12847: UI length 27 > 1.2 x 22
- line 12995: UI length 15 > 1.2 x 12
- line 13031: UI length 29 > 1.2 x 22
- line 13427: UI length 19 > 1.2 x 14
- line 13433: UI length 19 > 1.2 x 14
- line 13475: UI length 45 > 1.2 x 37
- line 13624: UI length 26 > 1.2 x 19
- line 13625: UI length 26 > 1.2 x 19
- line 13626: UI length 26 > 1.2 x 19
- line 13627: UI length 26 > 1.2 x 19
- line 13644: UI length 34 > 1.2 x 28
- line 13823: UI length 18 > 1.2 x 14
- line 13861: UI length 19 > 1.2 x 15
- line 13862: UI length 19 > 1.2 x 15
- line 13890: UI length 20 > 1.2 x 16
- line 13906: number multiset differs (en=[2] ar=[])
- line 13998: UI length 24 > 1.2 x 16
- line 14008: UI length 17 > 1.2 x 13
- line 14072: UI length 21 > 1.2 x 17
- line 14266: UI length 30 > 1.2 x 22
- line 14267: UI length 35 > 1.2 x 27
- line 14275: UI length 21 > 1.2 x 17
- line 14333: UI length 23 > 1.2 x 19
- line 14404: UI length 22 > 1.2 x 18
- line 14417: UI length 49 > 1.2 x 37
- line 14430: UI length 22 > 1.2 x 17
- line 14604: UI length 16 > 1.2 x 13
- line 14833: UI length 39 > 1.2 x 22
- line 14885: UI length 66 > 1.2 x 49
- line 14971: UI length 23 > 1.2 x 19
- line 14972: UI length 23 > 1.2 x 19
- line 14980: UI length 19 > 1.2 x 15
- line 15228: number multiset differs (en=[2] ar=[])
- line 15232: number multiset differs (en=[3] ar=[])
- line 15235: number multiset differs (en=[1|60] ar=[60])
- line 15244: number multiset differs (en=[000|3|78] ar=[3000|78])
- line 15288: number multiset differs (en=[9|9] ar=[9])
- line 15432: number multiset differs (en=[000|800] ar=[800])
- line 15447: number multiset differs (en=[150] ar=[])
- line 15484: number multiset differs (en=[000|45|7] ar=[45|7000])
- line 15485: number multiset differs (en=[000|7] ar=[7000])
- line 15503: number multiset differs (en=[] ar=[8])
- line 15510: number multiset differs (en=[17] ar=[])
- line 15857: number multiset differs (en=[2] ar=[])
- line 15959: glossary term 'Terminal' -> 'محطة طرفية|طرفية' not found in Arabic
- line 15960: glossary term 'Terminal' -> 'محطة طرفية|طرفية' not found in Arabic
- line 16125: number multiset differs (en=[1|2|2|6] ar=[1|2|2|5|6])
- line 16176: number multiset differs (en=[70] ar=[5|7|70])
- line 16458: number multiset differs (en=[000|2] ar=[2000])
- line 16495: number multiset differs (en=[000|000|3|5|70] ar=[3000|5000|70])
- line 17629: UI length 15 > 1.2 x 12
- line 17718: number multiset differs (en=[12|1955|20|25|50] ar=[12|1955|25|50])
- line 17730: glossary term 'Major' -> 'الرائد' not found in Arabic
- line 17734: number multiset differs (en=[1|1|19|1954|2] ar=[19|1954])
- line 17759: number multiset differs (en=[1955|1956|28|3|3826] ar=[1955|1956|28|3826])
- line 17762: number multiset differs (en=[1|11|1955|21|260|3|47] ar=[11|1260|1955|21|3|47])
- line 17797: number multiset differs (en=[10|10|150|1955|200|200|300|8|90] ar=[10|150|1955|200|200|300|8|90])
- line 17799: number multiset differs (en=[1955|2|30|5|9] ar=[1955|2|5|9])
- line 17869: UI length 19 > 1.2 x 15
- line 17891: UI length 26 > 1.2 x 21
- line 17905: UI length 17 > 1.2 x 14
- line 17907: UI length 18 > 1.2 x 14
- line 17914: UI length 18 > 1.2 x 14
- line 17981: UI length 23 > 1.2 x 19
- line 17982: UI length 23 > 1.2 x 19
- line 18034: UI length 21 > 1.2 x 16
- line 18048: UI length 23 > 1.2 x 18
- line 18061: number multiset differs (en=[00|1955|7|9] ar=[1955|7])
- line 18284: number multiset differs (en=[19] ar=[])
- line 18799: number multiset differs (en=[0|0|0|0|000|07|08|08|12|2|42] ar=[0|0|0|0|07|08|08|12|2|42])
- line 18803: number multiset differs (en=[0|0|08|09|1|2] ar=[0|0|08|09|1])
- line 19382: number multiset differs (en=[10|25|90] ar=[10|2|25|90])
- line 19699: glossary term 'Major' -> 'الرائد' not found in Arabic
- line 19749: glossary term 'Terminal' -> 'محطة طرفية|طرفية' not found in Arabic
- line 19774: number multiset differs (en=[1] ar=[01])
- line 19775: number multiset differs (en=[2] ar=[02])
- line 19776: number multiset differs (en=[3] ar=[03])
- line 19788: number multiset differs (en=[1] ar=[01])
- line 19789: number multiset differs (en=[2] ar=[02])
- line 19790: number multiset differs (en=[3] ar=[03])
- line 19791: number multiset differs (en=[4] ar=[04])
- line 19803: number multiset differs (en=[1] ar=[01])
- line 19804: number multiset differs (en=[2] ar=[02])
- line 19805: number multiset differs (en=[3] ar=[03])
- line 19806: number multiset differs (en=[4] ar=[04])
- line 19811: number multiset differs (en=[1] ar=[01])
- line 19812: number multiset differs (en=[2] ar=[02])
- line 19813: number multiset differs (en=[3] ar=[03])
- line 19814: number multiset differs (en=[4] ar=[04])
- line 19818: number multiset differs (en=[1] ar=[01])
- line 19860: glossary term 'Major' -> 'الرائد' not found in Arabic
- line 19890: glossary term 'Terminal' -> 'محطة طرفية|طرفية' not found in Arabic
- line 19928: number multiset differs (en=[1] ar=[01])
- line 19929: number multiset differs (en=[2] ar=[02])
- line 19930: number multiset differs (en=[3] ar=[03])
- line 19931: number multiset differs (en=[4] ar=[04])
- line 19932: number multiset differs (en=[5] ar=[05])
- line 19933: number multiset differs (en=[6] ar=[06])
- line 19934: number multiset differs (en=[7] ar=[07])
- line 19935: number multiset differs (en=[7] ar=[07])
- line 19936: number multiset differs (en=[8] ar=[08])
- line 19989: number multiset differs (en=[1] ar=[01])
- line 19990: number multiset differs (en=[2] ar=[02])
- line 19991: number multiset differs (en=[3] ar=[03])
- line 19992: number multiset differs (en=[4] ar=[04])
- line 19993: number multiset differs (en=[5] ar=[05])
- line 19994: number multiset differs (en=[6] ar=[06])
- line 19995: number multiset differs (en=[7] ar=[07])
- line 19996: number multiset differs (en=[8] ar=[08])
- line 20021: number multiset differs (en=[1] ar=[01])
- line 20022: number multiset differs (en=[2] ar=[02])
- line 20023: number multiset differs (en=[3] ar=[03])
- line 20024: number multiset differs (en=[4] ar=[04])
- line 20045: number multiset differs (en=[0|0|0|0|0|0|0|0|00|10|100|11|17|18|30|31|43|90] ar=[0|0|0|0|0|0|0|0|00|10|11|17|18|30|31|43|90])
- line 20062: glossary term 'Terminal' -> 'محطة طرفية|طرفية' not found in Arabic
- line 20235: number multiset differs (en=[4] ar=[])
- line 20236: number multiset differs (en=[4] ar=[])
- line 20432: number multiset differs (en=[4] ar=[])
- line 20433: number multiset differs (en=[4] ar=[])
- line 20434: number multiset differs (en=[4] ar=[])
- line 20435: number multiset differs (en=[4] ar=[])
- line 20498: glossary term 'Major' -> 'الرائد' not found in Arabic
- line 20548: number multiset differs (en=[3] ar=[])
- line 21184: glossary term 'Archive' -> 'الأرشيف' not found in Arabic
- line 21244: number multiset differs (en=[118|1955|2] ar=[118|1955])
- line 21247: number multiset differs (en=[1|1|60|60] ar=[60|60])
- line 21299: number multiset differs (en=[20|60|7] ar=[])
- line 21380: number multiset differs (en=[2] ar=[])
- line 21396: number multiset differs (en=[000|4] ar=[4000])
- line 21485: number multiset differs (en=[1|5] ar=[5])
- line 21648: number multiset differs (en=[1|10|13|18|2|2|250|300|50|60|641|850|91] ar=[10|13|18|1850|2|2300|250|50|60|641|91])
- line 21951: number multiset differs (en=[2] ar=[])
- line 22680: number multiset differs (en=[24] ar=[])
- line 22929: number multiset differs (en=[25] ar=[])
- line 22944: number multiset differs (en=[19] ar=[])
- line 23016: glossary term 'Terminal' -> 'محطة طرفية|طرفية' not found in Arabic
- line 23017: number multiset differs (en=[30] ar=[])
- line 23082: number multiset differs (en=[30] ar=[])
- line 23083: number multiset differs (en=[50] ar=[])
- line 23084: number multiset differs (en=[30] ar=[])
- line 23608: glossary term 'Upgrade' -> 'ترقية' not found in Arabic
- line 24987: number multiset differs (en=[1] ar=[])
- line 25049: glossary term 'Upgrade' -> 'ترقية' not found in Arabic
- line 26496: number multiset differs (en=[0|0|000|04|10|3|78] ar=[0|0|04|10|3000|78])
- line 26869: number multiset differs (en=[2|500] ar=[2500])
- line 26986: number multiset differs (en=[1|1950|47] ar=[1950|47])
- line 27191: number multiset differs (en=[50] ar=[])

