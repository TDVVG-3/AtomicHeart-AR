# Subtitle caps - H1H2H3

Generated: 2026-10-31 10:40:51 +03:00
Input: `C:\AtomicHeart-AR\build\variants\atomic-heart-ar_p12.tsv`
Output: `C:\AtomicHeart-AR\build\variants\atomic-heart-ar_p12g.tsv`

All marker calculations use minutes; clip_seconds is converted on input. Six decimal places retain sub-millisecond boundaries.
Unresolvable or descending tracks are left unchanged for manual review; this is not a runtime HUD verification.
| item | count |
| --- | ---: |
| rows changed | 2561 |
| H1 duplicate-start offsets | 72 |
| H1 non-monotonic tracks left unchanged | 197 |
| H2 end caps before next start | 59 |
| H3 final-page ends added | 91 |
| H3 markerless pages given *0-end* | 2422 |
| H3 final ends capped at clip end | 0 |
| H3 rows skipped (no clip duration) | 336 |
| rows retained for manual review (invalid or unrepresentable window) | 1 |

## Per scope

| scope | rows | H1 | H2 | H3 ends | H3 inserts |
| --- | ---: | ---: | ---: | ---: | ---: |
| Academy_Dialogues | 282 | 12 | 0 | 3 | 28 |
| Chelomey_Dialogues | 1201 | 7 | 0 | 9 | 378 |
| Chelomey_dlc3 | 773 | 0 | 0 | 0 | 0 |
| ChelomeyFinal_Dialogues | 214 | 0 | 0 | 0 | 42 |
| CrystalComplex_dlc4 | 1219 | 0 | 0 | 0 | 0 |
| CUTSCENES | 839 | 5 | 0 | 7 | 385 |
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
| OpenWorldVDNKh_Dialogues | 443 | 4 | 0 | 9 | 103 |
| Pavlov_Dialogues | 520 | 14 | 0 | 16 | 174 |
| PearTerminals | 539 | 0 | 0 | 0 | 0 |
| Phasatron_dlc4 | 489 | 0 | 0 | 0 | 1 |
| Polygon_Dialogues | 199 | 3 | 0 | 4 | 60 |
| Sakhalin_dlc3 | 842 | 0 | 0 | 0 | 0 |
| Schebetar_Subs | 360 | 0 | 53 | 0 | 0 |
| Schebetars_dlc1 | 94 | 0 | 6 | 0 | 0 |
| Tech_dlc2 | 143 | 0 | 0 | 0 | 0 |
| Tech_dlc3 | 382 | 0 | 0 | 0 | 0 |
| Tech_dlc4 | 1117 | 0 | 0 | 0 | 0 |
| Theatre_Dialogues | 629 | 7 | 0 | 6 | 97 |
| Triton_dlc3 | 928 | 0 | 0 | 0 | 0 |
| Vavilov_Dialogues | 2427 | 8 | 0 | 20 | 597 |
| VDNKh_Dialogues | 1250 | 7 | 0 | 17 | 321 |
| WavePlatform_dlc4 | 291 | 0 | 0 | 0 | 0 |

H1 only offsets duplicate page starts. H2 caps explicit range ends strictly before the next page start. H3 adds an end to a final singleton page; for markerless cells it inserts `*0-end*` using the Wwise clip duration and a 15 chars/s + 1.2 s reading allowance. Absolute DataTable row start offsets are not present in the cooked data, so the next *line* start cannot be used directly; the clip end is the conservative cap. This is the UNKNOWN limitation documented in the stack audit.

## Rows retained for manual review
| line | key | reason |
| ---: | --- | --- |
| 112 | /D4B49AAE43DC66A20B282D991E9E7296 | descending source timing; needs audio review |
| 134 | /CB61834D4C99C83FAC1E85B2F4A8F239 | descending source timing; needs audio review |
| 140 | /3F1A7DB043A4A7D981BBBC83DAF16280 | descending source timing; needs audio review |
| 177 | /C5D56F7B45237349D19F47A2D6D2D4AC | descending source timing; needs audio review |
| 203 | /AF2C15D94611068149C62D82D6D9DF57 | descending source timing; needs audio review |
| 205 | /DB0145CF41A69AAC778BB1AD2C7BF1B7 | descending source timing; needs audio review |
| 215 | /B33738E143D0A5C97841219EAC4C6EF6 | descending source timing; needs audio review |
| 227 | /AE2B11F04AD8786FBB10278DF51529FE | descending source timing; needs audio review |
| 244 | /2B0D97AB4E0228DF3A06F9BAE8A73680 | descending source timing; needs audio review |
| 268 | /3E4F984F418ED596A17830BCEF2BC180 | descending source timing; needs audio review |
| 276 | /88E234114855C6B720A8DDA855B48A58 | descending source timing; needs audio review |
| 282 | /A3957E434F3B42A84FC8BE84BA3F2901 | descending source timing; needs audio review |
| 285 | /4C81F68D466B7E53EDEB3BADA39F3810 | descending source timing; needs audio review |
| 286 | /10E57B554D1CB6E33B614B829975AE99 | descending source timing; needs audio review |
| 287 | /714401B1409AD14630429692B0DFAFF5 | descending source timing; needs audio review |
| 288 | /C6CA53CF4667BE6A271CFB8BFCF56BFB | descending source timing; needs audio review |
| 289 | /DC11CB9A4BFFB0AA5E099DAA4057EEE9 | descending source timing; needs audio review |
| 290 | /1002A45848240DE4F7234C932386D3BF | descending source timing; needs audio review |
| 292 | /993C32CD4606AD8982BE078429495AB0 | descending source timing; needs audio review |
| 293 | /33EA844F4B8F028BC8002BB818499148 | descending source timing; needs audio review |
| 295 | /07DA2375411F20CAD0FE25B87105AE07 | descending source timing; needs audio review |
| 862 | /3D791308400FF895030B88A3CF4EAF8C | descending source timing; needs audio review |
| 916 | /D9A720EE41EE752967C4BB8EB96A3274 | descending source timing; needs audio review |
| 965 | /EC31AC50418107818E4C6FA61F378323 | descending source timing; needs audio review |
| 1005 | /51BF3D534287B59CD5F18E89C45ED727 | descending source timing; needs audio review |
| 1051 | /752EEA3D4435874E1EE4E5B3E30C0B89 | descending source timing; needs audio review |
| 1091 | /098633B44FF66086C44355983A244586 | descending source timing; needs audio review |
| 1174 | /7876447F4075E553549CE4B31786FF75 | descending source timing; needs audio review |
| 1199 | /27C557584728D2575B9314B04EC6857F | descending source timing; needs audio review |
| 1311 | /A528C48D43C6406F64DCBFBC51394373 | descending source timing; needs audio review |
| 1328 | /6D7D86EE4E4BB6CFF3EC52A14D63B59E | descending source timing; needs audio review |
| 1347 | /C7F391554B093D2809CEAA9A1ED1105B | descending source timing; needs audio review |
| 1389 | /EAD9F7A440A31581B98F419A852BFC2D | descending source timing; needs audio review |
| 1409 | /BE05491E49783E6C4C417AB3DF0ADF39 | descending source timing; needs audio review |
| 1422 | /90C54D8B42B15570B15B04B948F6E2D3 | descending source timing; needs audio review |
| 3698 | /7C5737584851A4BDC43D5A8C6803CC60 | descending source timing; needs audio review |
| 4071 | /F5DD847D4B70776219FE2391B35965BD | descending source timing; needs audio review |
| 4076 | /5DE460654A08ECFFA570ED8D07F70FD1 | descending source timing; needs audio review |
| 4098 | /7DA3736B43938592B1219A9EBE862476 | descending source timing; needs audio review |
| 4109 | /15754064453573AF974BAE9391DAC428 | descending source timing; needs audio review |
| 4136 | /A7A994A84ECAF69410414281BDC94BF2 | descending source timing; needs audio review |
| 4180 | /BEC051A845F205FCE8132D9140BD22DC | descending source timing; needs audio review |
| 4236 | /917F1882435BC66EA0E2748B96601F92 | descending source timing; needs audio review |
| 4297 | /A9C90EE34044771013AA028063592DB5 | descending source timing; needs audio review |
| 4309 | /7075CC9C41083091A219189592F17F16 | descending source timing; needs audio review |
| 4466 | /90856E1C4DB793D30AA3ED9F34C19C0B | descending source timing; needs audio review |
| 4475 | /0BC9D15E4DDC75C4A5665F9A8E9FF4B0 | descending source timing; needs audio review |
| 4512 | /C006727F4F54C2E9EBE86ABDF34C3A88 | descending source timing; needs audio review |
| 5071 | /1552928C4C63FD48E1107B8F84ABA0F6 | descending source timing; needs audio review |
| 5096 | /74C7EBA3403E9A0DFA9DEF916B04D2E5 | descending source timing; needs audio review |
| 5126 | /395484B146174B5DF2C234A41EFE1F29 | descending source timing; needs audio review |
| 5127 | /962A2FA3462F1CE524EB09B650D0C297 | descending source timing; needs audio review |
| 5136 | /B56010C94E3ACF20E0F087B81E9CC41C | descending source timing; needs audio review |
| 5177 | /52EC7FF847D25DC9CFEE22B6BDEC31CD | descending source timing; needs audio review |
| 5215 | /FEC9C75B49C2959364D583A1F49A10BE | descending source timing; needs audio review |
| 5315 | /C3B8ACB44A5FB005BF553DA654EEE3AB | descending source timing; needs audio review |
| 5327 | /F28E47C842A26251B4F0A8909D5FA117 | descending source timing; needs audio review |
| 5340 | /233810684F2CD5EF8D5E22A0504F5AAA | descending source timing; needs audio review |
| 5347 | /1FD0BC7A4EEF0745A690B79C2E9B3B90 | descending source timing; needs audio review |
| 5376 | /CD81CACE4DCFD2A7E3E24CB16B0B9D52 | descending source timing; needs audio review |
| 5390 | /7A03FEF3482BD3F4F30FB68D54B92FB2 | descending source timing; needs audio review |
| 5419 | /65C3F60C4192F305A2DC788D9A86B0F2 | descending source timing; needs audio review |
| 5475 | /E83412284C0B98CA6CBDC69C417597B3 | descending source timing; needs audio review |
| 5485 | /6E630F6349E722F8705B569192F136C1 | descending source timing; needs audio review |
| 5493 | /FF239AA64E24D987025E47BC2132A47E | descending source timing; needs audio review |
| 5527 | /7BA6299C4FB26AB33D4A178596C0EF9B | descending source timing; needs audio review |
| 5599 | /EB7E63AD49B708CDA05A4A8CACEB181F | descending source timing; needs audio review |
| 5617 | /602D4E3F4FEAFA8A66CE04903BD1D603 | descending source timing; needs audio review |
| 5622 | /4A69B4964D5337B626AF37AC22D489DE | descending source timing; needs audio review |
| 5646 | /9291C3554B730FCA269319A8FBF00293 | descending source timing; needs audio review |
| 5672 | /391A255F45ADDC96C1D7B587B450B80F | descending source timing; needs audio review |
| 5673 | /D23C28994B19AC858F9332A7CCAC9A0B | descending source timing; needs audio review |
| 16757 | /31C8DF414134F8E1C7FC6198F011D4A7 | descending source timing; needs audio review |
| 16767 | /14041A2D45BCEE6DB052579A48B9C8A4 | descending source timing; needs audio review |
| 16860 | /C3B8ACB44A5FB005BF553DA654EEE3AB | descending source timing; needs audio review |
| 16864 | /7777EA2E4562F6D9810E828F2D79AABB | descending source timing; needs audio review |
| 16940 | /E83412284C0B98CA6CBDC69C417597B3 | descending source timing; needs audio review |
| 16983 | /6A8EF4AE46CA40EC942BEBAE9428751B | descending source timing; needs audio review |
| 16997 | /90CC238544B1AB2634BC2E804069EB96 | descending source timing; needs audio review |
| 16999 | /5DA9CC1946F99BC5D7748B83DE0FC4F0 | descending source timing; needs audio review |
| 17022 | /EB7E63AD49B708CDA05A4A8CACEB181F | descending source timing; needs audio review |
| 17037 | /4A69B4964D5337B626AF37AC22D489DE | descending source timing; needs audio review |
| 17070 | /494BB64141ABCA8CDFD6BAAD3F7C7338 | descending source timing; needs audio review |
| 17334 | /2CD24C234A730A2F6D7B91A483CF26B2 | descending source timing; needs audio review |
| 17339 | /0136DBEB4EF88FFA06F2159616DE3977 | descending source timing; needs audio review |
| 17354 | /685E452A437BA9A0CFB933A89DCEBC8D | descending source timing; needs audio review |
| 17375 | /B56010C94E3ACF20E0F087B81E9CC41C | descending source timing; needs audio review |
| 17385 | /B787AB334203CF84C995EE8620D9E640 | descending source timing; needs audio review |
| 17401 | /DC03AB5C4D428158DA0BE68B0658DAB6 | descending source timing; needs audio review |
| 17419 | /983F11444094A90BBC4EB78DC9C2039B | descending source timing; needs audio review |
| 17423 | /58F092EE4B29B32435F716A2687B1FD8 | descending source timing; needs audio review |
| 17434 | /CCDB69D14C36823ED35A5EB37B77B321 | descending source timing; needs audio review |
| 17487 | /2B0BB3994B9ED8D3216C5BBB984C1905 | descending source timing; needs audio review |
| 17496 | /8EF926014FE2DA1DE173E7B95423AAC8 | descending source timing; needs audio review |
| 17524 | /4A788B394D57EC0E18A895B7CD8DCF96 | descending source timing; needs audio review |
| 17534 | /4200A71D4CA852C1C999F6BBE4C05715 | descending source timing; needs audio review |
| 17543 | /537E28C748048911AC9FCFB022AA7D7A | descending source timing; needs audio review |
| 18723 | /0E5728A94036E2446BD25894C75E68E0 | descending source timing; needs audio review |
| 18738 | /549D45CB48FC88B6A46E8CB10A8042B1 | descending source timing; needs audio review |
| 18746 | /05FC372C491B3BA1D255AE98B54E453C | descending source timing; needs audio review |
| 18750 | /AC2F37D6452B6C67A19A3A9A6BECFF7D | descending source timing; needs audio review |
| 18756 | /2B3959D341F279E85D681E940B5B5F44 | descending source timing; needs audio review |
| 18758 | /FE911F1C469E4428506EB19BCEB56215 | descending source timing; needs audio review |
| 18759 | /BBD8306B48FC603647DA4B8C0D652406 | descending source timing; needs audio review |
| 18762 | /47FE300D468C54080355879FAB38D8BB | descending source timing; needs audio review |
| 18764 | /E21899DD4B7005A60F6526A1A33DC920 | descending source timing; needs audio review |
| 18779 | /D5FEAF1940C86F86E90D63BD3ECC381E | descending source timing; needs audio review |
| 18782 | /9933F06440EA8DF58D75C2B1A64EE493 | descending source timing; needs audio review |
| 18783 | /14AF388F4C36225F5253C9BDD2F4B453 | descending source timing; needs audio review |
| 18789 | /03DCD7D943C931DAC2FE70A7EF52F5DF | descending source timing; needs audio review |
| 18793 | /853A1C92476355C0E3E4509D428B5C3C | descending source timing; needs audio review |
| 18794 | /96D21C034190E5812079C19E035B4158 | descending source timing; needs audio review |
| 18798 | /9D53BF43469EB97E8C3F0D80CC774ED0 | descending source timing; needs audio review |
| 18799 | /8B7023EF41A2EF2B4C2927B9A7758A28 | descending source timing; needs audio review |
| 18800 | /D751A8F44414948FBDAE9E8F2090BF03 | descending source timing; needs audio review |
| 19736 | /5B8B06AA4583001BAF44468576710125 | malformed numeric marker; needs source/audio review |
| 22258 | /B0AA077B488F0C5AB4ADE4811136E1F2 | descending source timing; needs audio review |
| 22306 | /6AF8373344472499AC80FB823A1F70DC | descending source timing; needs audio review |
| 22334 | /01FC1A7E4A5FDAF673DE3997AD877186 | descending source timing; needs audio review |
| 22337 | /962A2FA3462F1CE524EB09B650D0C297 | descending source timing; needs audio review |
| 22388 | /FEC9C75B49C2959364D583A1F49A10BE | descending source timing; needs audio review |
| 22391 | /AB844C0A41871DA61F4D20B3C96D4BF8 | descending source timing; needs audio review |
| 22393 | /62E1487840CB13313FE7EEB35E78A715 | descending source timing; needs audio review |
| 22406 | /F16C66114273B1D41E0803B1041D874A | descending source timing; needs audio review |
| 22432 | /4276DCCD4AB542CBF65EDF956377E483 | descending source timing; needs audio review |
| 22435 | /233810684F2CD5EF8D5E22A0504F5AAA | descending source timing; needs audio review |
| 22484 | /65C3F60C4192F305A2DC788D9A86B0F2 | descending source timing; needs audio review |
| 22501 | /2D7128DC45D77F798E34A5BF58066162 | descending source timing; needs audio review |
| 22521 | /935BBBA44F6B3AAD9F64D0BA2B9C5519 | descending source timing; needs audio review |
| 22537 | /D0D4D25C4BD4B265983A37AEB2403903 | descending source timing; needs audio review |
| 22550 | /525BCB884EE6EBD64E6D77830BD598D2 | descending source timing; needs audio review |
| 22552 | /79BA9E8D4581526F941708BE642B14FC | descending source timing; needs audio review |
| 22591 | /7BA6299C4FB26AB33D4A178596C0EF9B | descending source timing; needs audio review |
| 22614 | /BA882AA04D1C9EF8B5F5218590B968FD | descending source timing; needs audio review |
| 22627 | /82AA1A4C47114E2D6B7B0D89004A3040 | descending source timing; needs audio review |
| 22659 | /A3E52A8041B1F924FEE33FA8B85EB15D | descending source timing; needs audio review |
| 24735 | /2B00FDAD471A6E46F7EB5AA4422F4E9F | descending source timing; needs audio review |
| 24769 | /1552928C4C63FD48E1107B8F84ABA0F6 | descending source timing; needs audio review |
| 24779 | /6CAFE7EF4FFE79B368DEB38436D6F83F | descending source timing; needs audio review |
| 24785 | /F8B8A9B74B4432CE69DF918CEACE67F2 | descending source timing; needs audio review |
| 24788 | /AA007240457ABB454E84D4BE310917CE | descending source timing; needs audio review |
| 24859 | /74C7EBA3403E9A0DFA9DEF916B04D2E5 | descending source timing; needs audio review |
| 24904 | /AF62A84447DB07E6B3D13B9AE080246C | descending source timing; needs audio review |
| 24906 | /301B846648364C6E5A8DFDA3BBFA32B4 | descending source timing; needs audio review |
| 24914 | /496FE530498AB864C3587F98A988C7CF | descending source timing; needs audio review |
| 24917 | /395484B146174B5DF2C234A41EFE1F29 | descending source timing; needs audio review |
| 24941 | /5521906145368DAF45478BBE9015647D | descending source timing; needs audio review |
| 25002 | /52EC7FF847D25DC9CFEE22B6BDEC31CD | descending source timing; needs audio review |
| 25060 | /B9E760B14B7EF60F314EFAA89364F1DD | descending source timing; needs audio review |
| 25065 | /A4B3C1D64BD0362D5CEB9AA9B8720C1D | descending source timing; needs audio review |
| 25071 | /A0E6A4754FDB4376421C93B66B7E6AF0 | descending source timing; needs audio review |
| 25077 | /D4DE681E4EBC6AFFC672C7B3FA7B275D | descending source timing; needs audio review |
| 25086 | /825B79C14E94CB04E3DA72A44835B425 | descending source timing; needs audio review |
| 25107 | /CBCA8B2F40E357EA78C6D9B66528A93F | descending source timing; needs audio review |
| 25253 | /E1CDBCDD4CEF45665DD7CC9AD9D795C9 | descending source timing; needs audio review |
| 25286 | /7F72BCF948C8A98F8682249923564701 | descending source timing; needs audio review |
| 25307 | /F28E47C842A26251B4F0A8909D5FA117 | descending source timing; needs audio review |
| 25310 | /436E03F542BAFF22FF4292BB709E4B4A | descending source timing; needs audio review |
| 25368 | /CD81CACE4DCFD2A7E3E24CB16B0B9D52 | descending source timing; needs audio review |
| 25549 | /FF41313D45B21D301A8A55AEC32BA1A3 | descending source timing; needs audio review |
| 25550 | /36BEFB524FECED0019A354AE8C9C4DFD | descending source timing; needs audio review |
| 25552 | /A36EA8F14FBDEDE48D80BFA3B7B59DB3 | descending source timing; needs audio review |
| 25601 | /4E48926D4B31FE3B350565B9DB3100FF | descending source timing; needs audio review |
| 25615 | /6E630F6349E722F8705B569192F136C1 | descending source timing; needs audio review |
| 25643 | /FF239AA64E24D987025E47BC2132A47E | descending source timing; needs audio review |
| 25710 | /0A19524D4587137A68A41FA219ABBED5 | descending source timing; needs audio review |
| 25711 | /F871E23B452D1D7C8608308C0826AF63 | descending source timing; needs audio review |
| 25797 | /1BBAE8BB46E8887FA4C41883950D4A0C | descending source timing; needs audio review |
| 25841 | /E11958A54B143091B6ED7BA43E8E234C | descending source timing; needs audio review |
| 25868 | /CF296EA64333261E85BFB69029AB4A8E | descending source timing; needs audio review |
| 25878 | /11EDAE414278DDC1464F10A12526CF2B | descending source timing; needs audio review |
| 25933 | /40FA9FA44578DBDFD123CB9891ABBB4D | descending source timing; needs audio review |
| 25993 | /391A255F45ADDC96C1D7B587B450B80F | descending source timing; needs audio review |
| 25995 | /5A9B53474A86A6C00BCE8EBD587EE8E6 | descending source timing; needs audio review |
| 25997 | /D23C28994B19AC858F9332A7CCAC9A0B | descending source timing; needs audio review |
| 26011 | /59692E1E477551FBDCDD329947B91A32 | descending source timing; needs audio review |
| 26030 | /74419A4F4550C3858E291E8D8C6D53FE | descending source timing; needs audio review |
| 26511 | /07F2AA6D480E946977732DB63BF31D9E | descending source timing; needs audio review |
| 26545 | /41E07038411EB2E04DFA48A0B6E1D712 | descending source timing; needs audio review |
| 26568 | /EF5DF0494A421DF4441533BBF73919D2 | descending source timing; needs audio review |
| 26604 | /D6BF60B94049921DE1FD89AC0C4513A6 | descending source timing; needs audio review |
| 26605 | /C9AAF0464D0869CC8BA1A8913CD5A470 | descending source timing; needs audio review |
| 26680 | /DCC7D38C42BB527E3EA20B8020DF69C2 | descending source timing; needs audio review |
| 26746 | /527ACB2943A821F2B151CFA70A231872 | descending source timing; needs audio review |
| 26849 | /0679D6934903CE240F66ECB83C8B7E78 | descending source timing; needs audio review |
| 26852 | /659DC3694A09FAB1DB700DB8FC53557D | descending source timing; needs audio review |
| 26891 | /1FD0BC7A4EEF0745A690B79C2E9B3B90 | descending source timing; needs audio review |
| 26892 | /993D702345F1D3B47BD7A0BB938C5C08 | descending source timing; needs audio review |
| 26924 | /4AC48D7B4E04705F25EBE69C627D38D7 | descending source timing; needs audio review |
| 26939 | /7A03FEF3482BD3F4F30FB68D54B92FB2 | descending source timing; needs audio review |
| 27069 | /11E38722411DA9A4CF6716BB47C4E71B | descending source timing; needs audio review |
| 27086 | /886315AD442671E36561DF862E7CFCEF | descending source timing; needs audio review |
| 27088 | /1F50781D4E98FBC6FF1408A0E341232F | descending source timing; needs audio review |
| 27101 | /E38ECB21408D585285970BBE27D55FFE | descending source timing; needs audio review |
| 27184 | /91A3DF244D47F336BD620CABC3FC4651 | descending source timing; needs audio review |
| 27233 | /84824889419A7CCEC08B5AA1DE840421 | descending source timing; needs audio review |
| 27256 | /602D4E3F4FEAFA8A66CE04903BD1D603 | descending source timing; needs audio review |
| 27286 | /9291C3554B730FCA269319A8FBF00293 | descending source timing; needs audio review |
