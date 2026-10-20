# Cycle 015 - batch 4 complete: 100% of translatable rows, carrier p10 installed

**Generated:** 2026-10-20 23:32:43 +03:00 (local time)

## Summary in five lines

1. Every planned id is authored: chunks 0039-0054, 4,716 ids, 4,802 rows filled, coverage 21,220 -> 26,022 of 27,618.
2. Coverage of TRANSLATABLE rows is 26,022 of 26,022 (100%); 26,022 of 27,618 rows (94.22%) carry Arabic, the other 1,596 rows are copy-class by design.
3. All gates pass: validator 0 errors, glyph gate 0 glyphs introduced by Arabic, text-fixup verifier PASS (87 rules), trim 0 rows.
4. Carrier p10 built (4,473,788 B, sha256 7fbed3a8...f49393), installed over p9 with snapshot proof; ~mods holds exactly 3 files.
5. Three glossary drifts and one leaked debug row were found by the gates and fixed; 7 chunk conflicts were resolved by keeping the first shipped variant.

## 1. Shipped state

| item | value |
| --- | --- |
| carrier | `zzz_atomicheart-ar_carrier_koKR_p10_P.pak` - 4,473,788 bytes |
| carrier sha256 | `7fbed3a87fafb547ecf4a2557a590ae0d7c05da304a3c7f6facb7bb34ef49393` |
| font | `zzz_atomicheart-ar_font_p2_plex_P.pak` - 1,461,408 bytes, sha256 `02b17f31...8269747` (unchanged) |
| ~mods | exactly 3 files (carrier, font, manifest); p9 removed hash-verified |
| install proof | `scripts/verify_install.ps1` -> VERIFY INSTALL PASS, problems 0 |
| rollback | `install_mod.ps1 -Carrier p9 -Font p2_plex` |
| in-game language | Korean (carrier occupies the ko-KR slot) |
| play-tested | NO - p10 is installed but not yet played |

Carrier content check (build log): keys 27,618 | Arabic 26,022 | English 1,596 | kept-Korean 0 | exact 27,617 | newline-normalised 1 | fail 0. The single newline-normalised row is container normalisation, not content loss (KI-024 family).

## 2. Coverage per scope and per category

Every line reads "N of TOTAL (X%)" where TOTAL is the translatable row count of that scope/category (rows minus copy-class rows).

## Totals

| metric | value |
| --- | --- |
| master rows | 27618 |
| rows with Arabic (DRAFT) | 26022 |
| copy-class rows left English-filled | 1596 |
| translatable rows | 26022 |
| coverage of translatable rows | 26022 of 26022 (100%) |
| coverage of all rows | 26022 of 27618 (94.22%) |
| rows needing review (not copy-class, still empty) | 0 |

## Copy-class reasons

| reason | rows |
| --- | --- |
| single token / identifier | 1385 |
| no letters (numbers/symbols) | 157 |
| technical label / proper name | 50 |
| localization marker | 4 |

## Per scope

| scope | rows | Arabic | copy-class | coverage of translatable |
| --- | --- | --- | --- | --- |
| Academy_Dialogues | 282 | 259 | 23 | 259 of 259 (100%) |
| Chelomey_Dialogues | 1204 | 1119 | 85 | 1119 of 1119 (100%) |
| Chelomey_dlc3 | 776 | 772 | 4 | 772 of 772 (100%) |
| ChelomeyFinal_Dialogues | 214 | 186 | 28 | 186 of 186 (100%) |
| CrystalComplex_dlc4 | 1219 | 1219 | 0 | 1219 of 1219 (100%) |
| CUTSCENES | 840 | 720 | 120 | 720 of 720 (100%) |
| Cutscenes_dlc1 | 421 | 417 | 4 | 417 of 417 (100%) |
| DIALOGUES FOR LQA | 746 | 746 | 0 | 746 of 746 (100%) |
| LebedevLab_dlc4 | 460 | 460 | 0 | 460 of 460 (100%) |
| Locations_dlc2 | 816 | 815 | 1 | 815 of 815 (100%) |
| Mails_01 | 454 | 454 | 0 | 454 of 454 (100%) |
| Mails_Shebetars_dlc2 | 246 | 246 | 0 | 246 of 246 (100%) |
| Mails_Shebetars_dlc4 | 756 | 756 | 0 | 756 of 756 (100%) |
| Mails_Shebetars_Tech_dlc3 | 579 | 578 | 1 | 578 of 578 (100%) |
| Marshes_dlc1 | 156 | 155 | 1 | 155 of 155 (100%) |
| Mendeleev_dlc1 | 411 | 411 | 0 | 411 of 411 (100%) |
| Misc | 21 | 19 | 2 | 19 of 19 (100%) |
| NewP5 | 5597 | 5332 | 265 | 5332 of 5332 (100%) |
| NTD | 1429 | 1405 | 24 | 1405 of 1405 (100%) |
| OpenWorldVDNKh_Dialogues | 443 | 432 | 11 | 432 of 432 (100%) |
| Pavlov_Dialogues | 520 | 404 | 116 | 404 of 404 (100%) |
| PearTerminals | 545 | 539 | 6 | 539 of 539 (100%) |
| Phasatron_dlc4 | 489 | 489 | 0 | 489 of 489 (100%) |
| Polygon_Dialogues | 199 | 150 | 49 | 150 of 150 (100%) |
| Sakhalin_dlc3 | 848 | 842 | 6 | 842 of 842 (100%) |
| Schebetar_Subs | 361 | 360 | 1 | 360 of 360 (100%) |
| Schebetars_dlc1 | 96 | 94 | 2 | 94 of 94 (100%) |
| Tech_dlc2 | 228 | 161 | 67 | 161 of 161 (100%) |
| Tech_dlc3 | 422 | 400 | 22 | 400 of 400 (100%) |
| Tech_dlc4 | 1273 | 1262 | 11 | 1262 of 1262 (100%) |
| Theatre_Dialogues | 629 | 572 | 57 | 572 of 572 (100%) |
| Triton_dlc3 | 928 | 928 | 0 | 928 of 928 (100%) |
| Vavilov_Dialogues | 2427 | 1962 | 465 | 1962 of 1962 (100%) |
| VDNKh_Dialogues | 1292 | 1067 | 225 | 1067 of 1067 (100%) |
| WavePlatform_dlc4 | 291 | 291 | 0 | 291 of 291 (100%) |

## Per category

| category | rows | Arabic | copy-class | coverage of translatable |
| --- | --- | --- | --- | --- |
| Cutscene | 1261 | 1137 | 124 | 1137 of 1137 (100%) |
| Dialogue | 8772 | 7712 | 1060 | 7712 of 7712 (100%) |
| Lore | 3464 | 3439 | 25 | 3439 of 3439 (100%) |
| Subtitles | 361 | 360 | 1 | 360 of 360 (100%) |
| UI | 6163 | 5890 | 273 | 5890 of 5890 (100%) |
| Unknown | 7597 | 7484 | 113 | 7484 of 7484 (100%) |

## 3. Rows still English-filled, and why

1596 rows have an empty Arabic cell. All of them are copy-class: the English is an identifier, a number, a placeholder, a brand/proper name, a localization marker or a debug string, so the in-game text must stay exactly as it is. Full list: `reports/english_filled_rows.tsv` (1596 rows: line, key, scope, category, english, reason).

| reason | rows |
| --- | --- |
| single token / identifier | 1385 |
| no letters (numbers/symbols) | 157 |
| technical label / proper name | 50 |
| localization marker | 4 |

Most frequent English values among those rows (all identifiers/names):

| english | rows |
| --- | --- |
| `P-3` | 1140 |
| `FinalDialog` | 18 |
| `{Class},  {Message}` | 17 |
| `LimboUpgrade` | 14 |
| `RadioReroute` | 11 |
| `999` | 10 |
| `2` | 9 |
| `NoText` | 9 |
| `SaidSecond` | 9 |
| `0` | 8 |
| `10` | 6 |
| `1` | 5 |
| `/` | 5 |
| `PM` | 5 |
| `º` | 4 |

No row was skipped for being hard, Russian-only or blocked: the residual set contains zero prose strings (checked by a multi-token scan, cycle 015).

## 4. The 30 longest Arabic UI labels (KI-026 evidence)

UI-category rows with Arabic: 5,890. Of these, 5,569 are labels (<= 200 characters) and 321 are document-style text blocks (letters, terminal articles; longest 4,062 characters) that are not buttons or labels. Among the labels, 1,019 are longer than 40 characters; the longest label is 199 characters. The 30 longest are listed below with their English source.

### 1. 199 chars - [NewP5] line 12493 - key /03344CB54C556E16E35B45A9B5C670FE

AR: كبسولات نيوروميد الطبية ومواد تجديد الطاقة، بل وحتى علبة من الحليب المكثّف، كلها مستهلكات ستنقذ حياتك أكثر من مرة. ويمكنك إدارة هذه الموارد البسيطة عبر القائمة الدائرية بتخصيصها لأزرار الوصول السريع.

EN: Medicinal capsules of Neuromed and energy replenishment or even a can of condensed milk are consumables that will save your life more than once. You can manage these simple resources via the radial menu by assigning them to quick access buttons.

### 2. 197 chars - [NewP5] line 12796 - key /49E65FA2417DC0693D5BC5B256838D68

AR: عُيّن سميرنوف من لينينغراد وكلّفه الحزب بمراقبة عدد من موظفي المجمّع. وعلى الرغم من أن دوره "المُبلّغ" معروف جيداً، فإن زملاءه يحترمونه، أولاً وقبل كل شيء، لتنظيمه أنشطة الترفيه والنوادي التعليمية.

EN: An appointee from Leningrad, Smirnov was tasked by the Party with monitoring individual Complex employees. Despite the fact that his role as a "snitch" is well known, he is respected by his coworkers, first and foremost as a host of leisure activities and educational clubs.

### 3. 190 chars - [NewP5] line 15181 - key ST_GameTips_Texts_/esli_protivnik_stoit_spinoy

AR: إذا فاجأت عدوًا، يمكنك التسلل إليه وطرحه أرضًا دون إطلاق إنذار. <h>لتنفيذ تصفية خفية، اقترب من الخلف واضغط</> <tag id="InputAction.Gameplay.StealthKill"/>. أسرع، وإلا فقد تفقد عنصر المفاجأة.

EN: If you catch an enemy unawares, you can sneak up and knock them out without raising the alarm. <h>To perform a stealth kill, approach from behind and press</> <tag id="InputAction.Gameplay.StealthKill"/>. Be quick, or you might lose the element of surprise.

### 4. 189 chars - [NewP5] line 15022 - key /89066259475C9103459B128C817EC91A

AR: طوّر مصمّم سوفييتي بندقية الهجوم هذه بعد الحرب العالمية الثانية رداً على بندقية الهجوم الألمانية والكرابين الأمريكي نصف الآلي. وتعوّض موثوقيتها العالية وسهولة صيانتها عن دقة الرمي المنخفضة.

EN: This assault rifle was developed by a Soviet designer after the World War II as a response to the German assault rifle and American semi-automatic carbine. High reliability and ease of maintenance make up for its low firing accuracy.

### 5. 189 chars - [NewP5] line 15021 - key /43D304884391BBACB7877194FE0AC209

AR: طوّر مصمّم سوفييتي بندقية الهجوم هذه بعد الحرب العالمية الثانية رداً على بندقية الهجوم الألمانية والكرابين الأمريكي نصف الآلي. وتعوّض موثوقيتها العالية وسهولة صيانتها عن دقة الرمي المنخفضة.

EN: This assault rifle was developed by a Soviet designer after the World War II as a response to the German assault rifle and American semi-automatic carbine. High reliability and ease of maintenance make up for its low firing accuracy.

### 6. 188 chars - [NewP5] line 14384 - key /870FCD564A26F6ADB20F5D8497686769

AR: تقنية "راديو المستقبل" سرّية للغاية. وهذا يعني أن الحكومة لا تستمع إلى أغاني المستقبل فحسب، بل قادرة فعلاً على التنبّؤ به. لكن لا تدع نظريات المؤامرة تتغلّب عليك. استرخِ واستمتع بالموسيقى.

EN: The Radio of the Future technology is top secret. This suggests the government not only listens to songs from the future, but can actually predict it. Still, don't let the conspiracy theories get to you. Simply relax and enjoy the music.

### 7. 188 chars - [NewP5] line 14385 - key /D140A3284F84FF64E47E0480C854ADBA

AR: تقنية "راديو المستقبل" سرّية للغاية. وهذا يعني أن الحكومة لا تستمع إلى أغاني المستقبل فحسب، بل قادرة فعلاً على التنبّؤ به. لكن لا تدع نظريات المؤامرة تتغلّب عليك. استرخِ واستمتع بالموسيقى.

EN: The Radio of the Future technology is top secret. This suggests the government not only listens to songs from the future, but can actually predict it. Still, don't let the conspiracy theories get to you. Simply relax and enjoy the music.

### 8. 182 chars - [NewP5] line 11552 - key /AB7805264B1F9BAF3246F1A18347D0FD

AR: يمكنك <h>إعادة ضبط المهارات وتوزيع البوليمر العصبي المُستعاد</> لاستخدام مهارات أخرى إن سئمت القديمة أو أردت تغيير أسلوب لعبك. <h>لن تُعاقَب بغرامات أو جزاءات، فجرّب ما شئت بحرية!</>

EN: You can <h>reset skills and redistribute the returned Neuropolymer</> to use other skills if you get tired of the old ones or want to change your play style. <h>You won't be punished with fines or penalties, so feel free to experiment!</>

### 9. 180 chars - [NewP5] line 13538 - key /44F3C4164BE81D0CCDA8DD9278CDDEE4

AR: يتيح معالجة الانعكاسات والتظليل المحيطي باستخدام تتبّع الأشعة. ويتطلّب بطاقة رسومات تدعم DXR بذاكرة لا تقل عن 12 غيغابايت ليعمل بشكل صحيح. وستحتاج إلى إعادة تشغيل اللعبة بعد الضبط.

EN: Allows reflections and ambient occlusion to be processed using ray tracing. Requires a graphics card supporting DXR with at least 12 GB of memory for proper operation. You will need to restart the game after configuring.

### 10. 179 chars - [NewP5] line 11914 - key /7CD0F8844D604EC2E964D5AFFA306A9A

AR: من المؤسف أن ترسانتك لا تضمّ أسلحة كاتمة، أيها الرفيق الرائد. كان يمكنك الاختفاء في الظلال وإسقاط الأعداء دون إطلاق الإنذار... لكن الوقت ترفٌ لا نملكه. ثم إن هذا ليس أسلوبك بوضوح.

EN: It's a shame your arsenal does not include silenced weapons, Comrade Major. You could hide in the shadows and take down enemies without triggering an alarm... But time is a luxury we don't have. Besides, that is clearly not your style.

### 11. 179 chars - [NewP5] line 11915 - key /A846368F415F037061A328BE93E34A2D

AR: من المؤسف أن ترسانتك لا تضمّ أسلحة كاتمة، أيها الرفيق الرائد. كان يمكنك الاختفاء في الظلال وإسقاط الأعداء دون إطلاق الإنذار... لكن الوقت ترفٌ لا نملكه. ثم إن هذا ليس أسلوبك بوضوح.

EN: It's a shame your arsenal does not include silenced weapons, Comrade Major. You could hide in the shadows and take down enemies without triggering an alarm... But time is a luxury we don't have. Besides, that is clearly not your style.

### 12. 177 chars - [NewP5] line 14712 - key /B1AF1FCE4596BCD706EE659C22F63998

AR: مكوّن عصبي بوليمري تجريبي فريد. يعيد تدوير خلايا الدم الحمراء المفقودة بسبب النزيف إلى ATP ويوجّهها إلى عضلات الذراع العلوية، ما يزيد الضرر المُحدث في الحالة الحرجة زيادة كبيرة.

EN: A unique experimental neuropolymeric component. Recycles the red blood cells lost to bleeding into ATP and directs it into the upper arm muscles, significantly increasing the damage dealt in the critical state.

### 13. 177 chars - [NewP5] line 14711 - key /11A5539247393273A4DFB7A08B533270

AR: مكوّن عصبي بوليمري تجريبي فريد. يعيد تدوير خلايا الدم الحمراء المفقودة بسبب النزيف إلى ATP ويوجّهها إلى عضلات الذراع العلوية، ما يزيد الضرر المُحدث في الحالة الحرجة زيادة كبيرة.

EN: A unique experimental neuropolymeric component. Recycles the red blood cells lost to bleeding into ATP and directs it into the upper arm muscles, significantly increasing the damage dealt in the critical state.

### 14. 175 chars - [NewP5] line 11960 - key /40BF62894F2571ECB520D29604A0CE74

AR: لرؤية الأسلاك داخل الجدران، استمرّ بالضغط على <tag id="InputAction.Gameplay.ScannnerDoublePress"/> + <tag id="InputAction.Gameplay.ScannnerDoublePress"/> أثناء استخدام الماسح.

EN: To see the wiring inside the walls, hold <tag id="InputAction.Gameplay.ScannnerDoublePress"/> + <tag id="InputAction.Gameplay.ScannnerDoublePress"/> while using the scanner.

### 15. 174 chars - [NewP5] line 12989 - key /0246D6E244B69BA9FE32DAA79D39E84A

AR: يستطيع قفّازك رشّ الأهداف والأسطح بنفّاثة من البوليمر القتالي. وبعد تطبيقه، يمكن إشعال البوليمر القتالي أو كهربته أو تجميده، فيلحق بالأعداء المتأثّرين ضرراً من النوع المقابل.

EN: Your glove can spray targets and surfaces with a jet of combat polymer. Once applied, combat polymer can be set on fire, electrified, or frozen, dealing damage of the corresponding type to affected enemies.

### 16. 174 chars - [NewP5] line 12991 - key /14EC28F144CB76A115DC9E9BA158DDB3

AR: يستطيع قفّازك إصابة الأهداف والأسطح بنفّاثة من الكرايو-بوليمر. ويتجمّد الأعداء المتأثّرون فلا يستطيعون الحركة. والأعداء العضويون أكثر حساسية بوجه خاص لدرجات الحرارة المنخفضة.

EN: Your glove can hit targets and surfaces with a jet of cryopolymer. Affected enemies are frozen and cannot move. Organic enemies are especially vulnerable to low temperatures.

### 17. 174 chars - [NewP5] line 9829 - key /4B48400241F4BFFE35BCA9B33F5FE735

AR: طاقة بطارية البوليمر في قفّازك لازمة لاستخدام مهارات مثل شوك والصقيع وغيرها. تتجدّد هذه الطاقة ببطء خارج المعارك، لكن تسديد ضربات القتال القريب يعيد تعبئتها بسرعة أكبر بكثير.

EN: The energy from your glove's Polymer battery is required to use skills like SHOK, Frostbite, etc. This energy slowly regenerates when you're not in combat, but landing melee attacks refills it much more quickly.

### 18. 173 chars - [NewP5] line 11797 - key /8A5EA25448F7E475D47304829BFD7DEC

AR: لاستخدام مهارة، استمرّ بالضغط على <tag id="InputAction.Gameplay.ActivateSpecialAbility"/> ولتبديل المهارات، اضغط <tag id="InputAction.Gameplay.SwapSpecialAbilitiesIndexes"/>

EN: To use a skill, hold <tag id="InputAction.Gameplay.ActivateSpecialAbility"/> To change skills, press <tag id="InputAction.Gameplay.SwapSpecialAbilitiesIndexes"/>

### 19. 173 chars - [NewP5] line 11796 - key /5B89FBEE4ADC29A00ECB58BAB82C87EE

AR: لاستخدام مهارة، استمرّ بالضغط على <tag id="InputAction.Gameplay.ActivateSpecialAbility"/> ولتبديل المهارات، اضغط <tag id="InputAction.Gameplay.SwapSpecialAbilitiesIndexes"/>

EN: To use a skill, hold <tag id="InputAction.Gameplay.ActivateSpecialAbility"/> To change skills, press <tag id="InputAction.Gameplay.SwapSpecialAbilitiesIndexes"/>

### 20. 173 chars - [PearTerminals] line 17592 - key /C4DCA847441AEF2FD77D9BAC8C904FF8

AR: التاريخ: 12 أغسطس 1953 من: المدير العام للمنشأة 3826 د. سيتشينوف إلى: مساعد مدير مجمّع فافيلوف ف. زولوتوخين  مرحباً! ليس لديّ وقت للكتابة، لذا سأسجّل هذا على تشيربر، اتفقنا؟

EN: Date: August 12, 1953 From: Facility 3826 General Director D. Sechenov To: Vavilov Complex Assistant Manager V. Zolotukhin  Hello! I don't have time to type, so I'm just going to record this on a Chirper, okay?

### 21. 172 chars - [NewP5] line 10860 - key /EEABC4D44EE2FC0E9630C2942850E227

AR: لإضافة خيارات جديدة، استخدم مرجع هذا المحدِّد واستدعِ الدالتين "add option" أو "add options". ولاختيار القيمة الافتراضية، استدعِ "set default option by name" أو "by index".

EN: To add new options, use this selector reference and call the functions "add option" or "add options". To choose the default value, call "set default option by name" or "by index".

### 22. 172 chars - [NewP5] line 9902 - key /CD1357334008F6AC897AEA88FA6E5943

AR: منظّم مرور آلي PM6 لإدارة النقل الحضري. ويستبدل نظام كاميرات المراقبة DANDELION العاملين في نقاط التفتيش عند مداخل المصانع، ويكفل السلامة العامة ويحافظ على النظام والقانون.

EN: Automated traffic controller PM6 for urban transport management.   The Dandelion CCTV system replaces staff at factory entrance checkpoints, ensures public safety, and maintains law and order.

### 23. 171 chars - [NewP5] line 9824 - key /24EA152A472A6001C2A10AB3AFF74757

AR: استخدم الخراطيش لكثافة نيرانية أعلى. استخدم الأسلحة الكهربائية ضد الروبوتات، والضرر الناري ضد الأهداف العضوية. استخدم <h> Ctrl + عجلة الفأرة </> لاختيار الخرطوشة المطلوبة.

EN: Use cartridges for superior fire density. Use electric weapons against robots, and fire damage against organic targets. Use <h> Ctrl + mouse wheel </> to select the required cartridge.

### 24. 171 chars - [NewP5] line 14627 - key /864072C34A6BB438DB7E93AB5C5C5871

AR: اضغط <tag id="InputAction.Gameplay.ActivateSpecialAbility"/> لاستخدام المهارات المحدّدة. اضغط <tag id="InputAction.Gameplay.SwapSpecialAbilitiesIndexes"/> لتبديل المهارات.

EN: Press <tag id="InputAction.Gameplay.ActivateSpecialAbility"/> to use the selected skills. Press <tag id="InputAction.Gameplay.SwapSpecialAbilitiesIndexes"/> to switch abilities.

### 25. 170 chars - [NewP5] line 13733 - key /E4ABA2634455CD006AE292A6FA460602

AR: تتزامن معظم بيانات VOLAN تلقائياً مع خريطة P-3 عند التفاعل. لكن رؤية نقاط واجهات البنية التحتية تتطلب وصلة VOLAN نشطة <h>للاتصال بكاميرات المراقبة DANDELION الإقليمية</>.

EN: Most of Volan's data is automatically synced to P-3's map upon interaction. However, an active Volan connection is required to <h>connect to regional DANDELION CAMERAS</> and see infrastructure interface points.

### 26. 168 chars - [NewP5] line 14828 - key /6F59D6DE40D6E63DDF51C7BD8CD3EA69

AR: حتى لو كانت عيناك محميّتين بعدسات بوليمرية، ما زلت أنصحك بأن تريحهما من وقت لآخر. لا تُطل التحديق في شاشة المحطة الطرفية — إن كنت تفهم ما أرمي إليه، أيها الرفيق الرائد.

EN: Even though your eyes are protected with Polymer lenses, I still suggest you give them a break every now and then. Don't spend too much time staring at a terminal screen — if you're catching my drift, Comrade Major.

### 27. 168 chars - [NewP5] line 14829 - key /E0FD9E0B4FD88015645FEA818EFAD04E

AR: حتى لو كانت عيناك محميّتين بعدسات بوليمرية، ما زلت أنصحك بأن تريحهما من وقت لآخر. لا تُطل التحديق في شاشة المحطة الطرفية — إن كنت تفهم ما أرمي إليه، أيها الرفيق الرائد.

EN: Even though your eyes are protected with Polymer lenses, I still suggest you give them a break every now and then. Don't spend too much time staring at a terminal screen — if you're catching my drift, Comrade Major.

### 28. 165 chars - [NewP5] line 10859 - key /07992B914B5685FFB582A4B9F8099A7D

AR: استخدم الخراطيش لكثافة نيرانية أعلى. استخدم الأسلحة الكهربائية ضد الروبوتات وضرر الحرق ضد الأهداف العضوية. اضغط Ctrl + mouse wheel لاختيار الخرطوشة التي تريد تجهيزها

EN: Use cartridges for superior fire density. Use electric weapons against robots and fire damage against organic targets. Press Ctrl + mouse wheel to choose the cartridge you want to equip

### 29. 165 chars - [NewP5] line 11085 - key /69C14D2D4883E333B5BD788DEB887689

AR: يتلقّى العميل P-3 مهمة وقفّاز أرجنتوم جديداً مزوّداً بنظام المحادثة المكتبي التعليمي الاصطناعي المدمج من الدكتور سيتشينوف، ويتوجّه إلى المنشأة 3826 في مجمّع فافيلوف.

EN: Agent P-3 receives a mission and a new Argentum glove with a built-in Chatting Artificial Librarian-Educational System from Dr. Sechenov and heads to Facility 3826 in the Vavilov complex.

### 30. 163 chars - [NewP5] line 14347 - key /511DFD084977AA48E7352595E36596EC

AR: إن استخدام تليكينيسيس على سطح مرشوش بالبوليمر القتالي يجمّعه في كتلة من البوليمر القتالي تبقى معلّقة في الهواء وتلحق بالأعداء القريبين ضرراً يتناسب طردياً مع حجمها

EN: Applying Telekinesis to a surface sprayed with Combat Polymer agglomerates it into a CP blob that hangs in the air and deals damage, directly proportional to its size, to nearby enemies

## 5. Gates

| gate | result | evidence |
| --- | --- | --- |
| text-fixup verifier (87 rules + seed integrity) | PASS | `reports/text_fixups_log.md` |
| validator (tags, markers, numbers, length, glossary) | PASS - 27,618 rows, 26,022 translated, **0 errors**, 259 warnings (number 122 / length 112 / glossary 25) | `reports/translation_validation.md` |
| glyph gate | PASS - 195 codepoints, 46 source-inherited, **0 introduced by Arabic** | `reports/glyph_gate.md` |
| trailing whitespace | 0 rows trimmed before the build | `reports/carrier_build.md` |
| carrier round-trip | 27,617 exact + 1 newline-normalised, **0 fail** | `reports/carrier_build.md` |
| install verification | PASS, 0 problems, expected file set | `reports/install_verification.md` |

Warning triage: the 122 number warnings are word-number renderings ("fifty" written as a word, "80 thousand" as a numeral plus the word for thousand) or timing markers that the checker counts separately; a sample of 6 rows with digits and 6 without showed no lost or altered number. The 112 length warnings are rows where Arabic is longer than 1.2x the English, mostly glossary-mandated terms and documents. The 25 glossary warnings are sense/form cases documented in KI-033 (Terminal 7, Major 6, Phasotron 2, Comrade 2, Upgrade 2, and one each for Argentum, Snowball, Archive, Neuropolymer, Professor, Doctor).

## 6. Authoring work, defects and fixes

- Chunks 0039-0054 (16 chunks, ids b11109-b15824, 4,716 ids): 4,802 master rows filled, TM 15,410 -> 19,733 entries, 0 unresolved conflicts.
- 7 chunk conflicts (same English authored with a second nuance in a later chunk): the master keeps the first shipped variant; the differences are stylistic (e.g. "tuddi" vs "yuddi" agreement, "al-muwajjihat" with/without kasra) and were reviewed one by one - no meaning change.
- DEFECT 1 (tooling, fixed): `batch2_apply.ps1` started reading `chunk_<id>.tsv` at line 1, silently skipping the FIRST entry of every chunk (chunk files have no header). Found when 623 unique strings were still empty although their chunks had run; the missing mass was chunks 0053/0054 that had never been applied, plus one lost first entry per chunk. Fix: start at line 0, then replay chunks 0039-0054 (idempotent; "already identical" everywhere, 1 recovered row).
- DEFECT 2 (content, fixed): a leaked NewP5 debug row (`english` -> `arabic`) failed the validator ("Arabic contains no Arabic letter"). The row is copy-class: Arabic cell emptied, TM entry removed.
- DEFECT 3 (content, fixed): three glossary drifts found by the validator and unified through `tm_fixups.tsv` rules - Crystal Complex 23 rows (transliteration replaced by the glossary translation), Sakhalin 2 rows, Kollektiv 3 rows. Glossary warnings 54 -> 25.
- DEFECT 4 (content, wave 1, fixed earlier in the cycle): row 20676 had two invented InputAction tags (validator ERROR), 3 rows used a bare non-glossary spelling for Chirper, 4 rows re-introduced reviewer-deprecated spellings; all repaired and verified.
- Authoring files re-normalised where needed; `verify_text_fixups.ps1` ran after EVERY apply, as required (DEC-038).

## 7. Decisions and known issues added this cycle

| id | decision |
| --- | --- |
| DEC-042 | Chunk files carry no header: appliers must read from line 0. `batch2_apply.ps1` fixed and all 16 chunks replayed. |
| DEC-043 | The frozen work order is authoritative for order only; coverage is computed from the master. A stale plan would be detected by the copy-class audit (multi-token scan), which is now part of the cycle close. |
| DEC-044 | Copy-class definition for coverage accounting: no letters, single identifier token, localization marker, placeholder/template, brand or debug label. Such rows stay English-filled and are reported with a reason. Coverage of translatable rows is the headline number (100%). |
| DEC-045 | The review sample is stratified: 10 long dialogue, 10 short UI labels, 10 tagged/placeholder rows, 10 edge cases (bracket/speaker/escape/timing). |
| DEC-046 | Glossary-unification changes found by the validator go through `tm_fixups.tsv` (never a direct master edit), and the three variant spellings are now permanent find/replace rules. |

| id | issue |
| --- | --- |
| KI-034 | FIXED: first-entry loss in `batch2_apply.ps1` (see DEFECT 1); replay recovered the rows. |
| KI-035 | OPEN (cosmetic, Phase 8): 220 Arabic cells use straight double quotes where the project style is the French-style guillemets required by the glossary. A tag-safe pass is needed (never rewrite id="..." inside tags). |
| KI-036 | OPEN: p10 is installed but NOT play-tested; p9 was installed but never played either. In-game proof still rests on p7 (canal boat scene). |

## 8. What is not tested

- p10 in game: menus, HUD, one DLC2 scene, one NTD sign, subtitles, GameTips popups (KI-009), subtitle clip-vs-scroll (KI-022), UI fit (KI-026).
- Font coverage of the 46 source-inherited codepoints (Cyrillic/CJK that the English source itself contains) - the Arabic introduces none (KI-025).
- Choice number/separator placement (KI-028) - cosmetic widget work, Phase 8.

## 9. Questions for the user

1. Play-test p10: menus/HUD, one DLC2 scene, one NTD sign, subtitles. Any clip, overlap or English leak?
2. "Upgrade" in dialogue: should the verb form be unified to the noun term (the UI term), or stay split (noun for UI, verb in speech)?
3. Where the English and Russian assets disagree (KI-032), keep the English anchor or follow the Russian canon?
4. Bracket labels: translate the 7 remaining technical ids or keep them Latin?
5. KI-031: may text inside `<- ... ->` be translated when it is prose?
6. Tone pass: extend beyond the 40 of 150 sampled rows?
7. Straight quotes (KI-035): run the guillemet pass now or in Phase 8?

## 10. Next phase (not started, needs your go-ahead)

- Phase 8: native `ar` language entry (KI-013), RU-only assets (KI-018 / 6,012 strings), choice-number mirroring (KI-028), guillemet pass (KI-035), in-game fit fixes (KI-026).
- Nothing in Phase 8 changes the delivered carrier p10.
