# C6 - Arabic for the RU-only cooked dialogue assets

Date: 2026-10-25. Pak **built and verified, NOT installed** (p11 + font v3 remain installed).

## What was built

- Scope: all 248 RU-only cooked assets recorded for C6 (the 6,012-row list in `reports/dialogue_ru_only.md`).
- Translation: every text row in those assets, not only the 6,012 sampled rows. 13,802 text rows / 13,122 unique strings were translated; 13,994 fields were rewritten.
- Write-back: `uasettool settext` (new `settext` mode), 248/248 assets written and read back; 0 missing targets.
- Safety: only `CultureInvariantString` / StringTable values changed. A full JSON semantic diff of all 248 assets found 13,994 changed leaves, all text, 0 non-text changes.

| pak | size | SHA256 | entries |
| --- | --- | --- | --- |
| `zzz_atomicheart-ar_ruonly_p1_P.pak` | 7,998,115 bytes | `BECEB894BCAAEAC546DA8D847AF815B42493A971ED45DC8D8B2693332EAA1CC3` | 496 (248 .uasset + 248 .uexp) |

Round-trip: the pak was unpacked with `repak unpack` and all 496 files were compared byte-for-byte with the staged inputs: **0 mismatches**.

## Coverage by asset family

The 6,012 official rows are a lossy half-sample from the old scanner; the actual text volume is 13,802 rows. Every row in the 248 assets is translated, so official coverage is 100% in every family, plus the previously unscanned rows.

| family | assets | official rows (of 6,012) | official translated | all text rows | unique in family | all translated |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| DLC01 | 7 | 186 | 186 | 402 | 397 | 397 |
| DLC2 | 15 | 452 | 452 | 1011 | 1010 | 1010 |
| DLC3 | 49 | 1157 | 1157 | 3015 | 2981 | 2981 |
| DLC4 | 72 | 1904 | 1904 | 4186 | 4143 | 4143 |
| Base/test/GooseRunner | 105 | 2313 | 2313 | 5188 | 4892 | 4892 |
| **total** | **248** | **6012** | **6012** | **13802** | **13122** (global) | **13122** |

## Skipped / not written

| item | count | reason | evidence |
| --- | ---: | --- | --- |
| `NotLifted_17.uasset` (KI-017) | 1 | obfuscated/byte-shifted text; no safe target string; not part of the 6,012 list | `reports/dialogue_obfuscated.md`: `LKKELLMKLM"!KLLMKMLNMLLN$"ML&NLONL #'&&L'PQR` |
| `1 //` choice widget (KI-028) | - | widget-drawn LTR text; no data row; out of C6 data scope | `reports/blocked_items.md` |
| 14th culture / extras blob (C7 KI-013) | - | opaque cooked `Extras` blob; unsafe rewrite; out of C6 scope | `reports/blocked_items.md` |
| UMG subtitle font size 35 / Cyrillic-Hangul glyphs | - | font asset, not text; handled by the font paks | `reports/font_ab_evidence.md` |

No asset in the 248-asset C6 set was skipped. Every writeback was clean: 0 `MISSING`, 0 `FAIL`.

## Review sample (30 rows)

Full, untruncated rows: `build/c6/review_sample.tsv`. Long rows are shortened here with `...`.

| # | asset | cat | speaker | RU | AR |
| ---: | --- | --- | --- | --- | --- |
| 1 | `DLC2/Narrative/Terminals/DA_Terminal_DLC2_Climbing_01.uasset` | Terminal |  | Правильнее говорить - ХРАЗ | الأصحّ أن نقول: خراز |
| 2 | `DLC2/Narrative/Terminals/DA_Terminal_DLC2_Climbing_01.uasset` | Terminal |  | Они стояли до конца | لقد صمدوا حتى النهاية |
| 3 | `DLC2/Narrative/Terminals/DA_Terminal_DLC2_Climbing_01.uasset` | Terminal |  | Другая физика | فيزياء أخرى |
| 4 | `DLC2/Narrative/Terminals/DA_Terminal_DLC2_Climbing_02.uasset` | Terminal |  | Так ли важен мозг? | هل الدماغ بهذه الأهمية؟ |
| 5 | `DLC2/Narrative/Terminals/DA_Terminal_DLC2_Climbing_02.uasset` | Terminal |  | Что к чему? | ما علاقة هذا بذاك؟ |
| 6 | `DLC2/Narrative/Terminals/DA_Terminal_DLC2_Climbing_03.uasset` | Terminal |  | Маска или лицо? | قناع أم وجه؟ |
| 7 | `DLC/DLC01_Narrative/DLC01_Cutscenes/D_DLC01_Lebedev01.uasset` | Subtitle | Lebedev01_Lebedev | О, нет-нет, она далеко не сошла с ума. Она полковник контрразведки СССР и начальник узла секретной правительственной связи комплекса. | أوه، لا لا، هي أبعد ما تكون عن الجنون. إنها عقيد في مكافحة التجسس السوفييتية، ورئيسة عقدة الاتصالات الحكومية السرية في المجمّع. |
| 8 | `DLC/DLC01_Narrative/DLC01_Cutscenes/D_DLC01_Lebedev01.uasset` | Subtitle | Lebedev01_Lebedev | Авиаузел полковника Муравьёвой, Сергей... Кхм, её избушка — это передовая технология войсковой разведки. | العقدة الجوية للعقيد مورافيوفا، سيرغي... أهلاً، كوخها هذا تقنية متقدمة في استطلاع القوات البرية. |
| 9 | `DLC/DLC01_Narrative/DLC01_Cutscenes/D_DLC01_Lebedev01.uasset` | Subtitle | Lebedev01_Lebedev | Я узнал о сбое Элеаноры и сразу же направился сюда. Она... Она моё изобретение, — мне за неё и отвечать. | علمتُ بخلل إلينورا وتوجهت إلى هنا فوراً. إنها... إنها من اختراعي، وأنا من يجب أن يُحاسَب عليها. |
| 10 | `DLC/DLC01_Narrative/DLC01_Cutscenes/D_DLC01_Lebedev01.uasset` | Subtitle | Lebedev01_Lebedev | Спецсерии ШЗ-5, «Шиза». Охранно-обслуживающий персонал комплекса «Менделеев». | من السلسلة الخاصة SHZ-5، «شيزا». طاقم الحراسة والخدمة في مجمّع مندليف. |
| 11 | `DLC/DLC01_Narrative/DLC01_Cutscenes/D_DLC01_Lebedev01.uasset` | Subtitle | Lebedev01_Lebedev | С поисков роботов типа БУС-А, содержащих эталонные алгоритмы Элеаноры. | بالبحث عن روبوتات من طراز BUS-A تحتوي على خوارزميات إلينورا المرجعية. |
| 12 | `DLC/DLC01_Narrative/DLC01_Cutscenes/D_DLC01_Lebedev01.uasset` | Subtitle | Lebedev01_P3 | Плетёные нейроконтакты? Что-то напоминает... не могу вспомнить. | وصلات عصبية مضفّرة؟ شيء ما يذكّرني... لا أستطيع التذكّر. |
| 13 | `DLC3/Narrative/Sakhalin/D_DLC03_01.uasset` | Dialogue | 01_P3 | Интересно, и что она собиралась сделать? | ترى، ماذا كانت تنوي أن تفعل؟ |
| 14 | `DLC3/Narrative/Sakhalin/D_DLC03_01.uasset` | Dialogue | 01_P3 | Ясно, у этой стальной пароварки секрет на секрете. Идем уже. | واضح أن لحمّام البخار الفولاذي هذا أسرارًا فوق أسرار. لنمضِ. |
| 15 | `DLC3/Narrative/Sakhalin/D_DLC03_01.uasset` | Dialogue | 01_P3 | Ты вообще в курсе, что на Предприятии происходит? | هل لديك أي فكرة عما يجري في المنشأة؟ |
| 16 | `DLC3/Narrative/Sakhalin/D_DLC03_01.uasset` | Dialogue | 01_Terenty | О судьбе прошлого руководителя товарища Сеченова необходимо уточнить у агента Муравьевой. Я не могу сообщить эту информацию. | بشأن مصير المدير السابق الرفيق سيتشينوف، يجب الاستفسار من العميلة مورافيوفا. لا أستطيع الإفصاح عن هذه المعلومة. |
| 17 | `DLC3/Narrative/Sakhalin/D_DLC03_01.uasset` | Dialogue | 01_Blesna | Судя по сканированию его полимерной памяти он принадлежит профессору Лебедеву, Алексею Владимировичу. | بحسب مسح ذاكرته البوليمرية، فهو يعود إلى البروفيسور ليبيديف، أليكسي فلاديميروفيتش. |
| 18 | `DLC3/Narrative/Sakhalin/D_DLC03_01.uasset` | Dialogue | 01_P3 | Неплохая вещь. Я раньше такой не видел… или видел? Хм. | شيء لا بأس به. لم أرَ مثله من قبل... أم رأيت؟ هم. |
| 19 | `DLC/DLC01_Narrative/DLC01_Goose/ST_DLC01_Goose_Sentences.uasset` | StringTable |  | повезло, повезло | يا لحظك، يا لحظك |
| 20 | `DLC/DLC01_Narrative/DLC01_Goose/ST_DLC01_Goose_Sentences.uasset` | StringTable |  | эхехех и что бы ты без меня делал? | ههههه، وماذا كنت ستفعل من دوني؟ |
| 21 | `DLC/DLC01_Narrative/DLC01_Goose/ST_DLC01_Goose_Sentences.uasset` | StringTable |  | Ты недооцениваешь мою мощь! | أنت تستهين بقوتي! |
| 22 | `DLC/DLC01_Narrative/DLC01_Goose/ST_DLC01_Goose_Sentences.uasset` | StringTable |  | Га га Кря, как ебануло! | ها ها كرا، يا لها من ضربة قاضية! |
| 23 | `DLC2/Narrative/Terminals/DA_Terminal_DLC2_Climbing_02.uasset` | Terminal |  | Автопилот | الطيار الآلي |
| 24 | `GooseRunner/GooseRunner/Blueprints/UI/Hints/ST_GooseRunner_Hints.uasset` | StringTable |  | Добро пожаловать в игровой режим GooseRunner! Ваша задача -  <h>Укусить П-3.</>  Используйте <h>A/D</>  или <h>ПКМ</> для перемещения между полосами.  Используйте <h>Q/E</> или <h>... | مرحباً بك في نمط اللعب GooseRunner! مهمتك هي <h>عضّ P-3.</> استخدم <h>A/D</> أو <h>زر الفأرة الأيمن</> للتنقل بين المسارات. استخدم <h>Q/E</> أو <h>حركة الفأرة</> للإزاحة داخل المسا... |
| 25 | `GooseRunner/GooseRunner/Blueprints/UI/Hints/ST_GooseRunner_Hints.uasset` | StringTable |  | Добро пожаловать в <h>SlideMode</> игрового режима GooseRunner    Используйте <h>Q/E</> или <h>Движение Мышью</> для перемещения по единому треку.  Используйте  <h>Пробел</> для пр... | مرحباً بك في <h>SlideMode</> ضمن نمط اللعب GooseRunner استخدم <h>Q/E</> أو <h>حركة الفأرة</> للتنقل على مسار واحد. استخدم <h>مسافة</> للقفز. |
| 26 | `GooseRunner/GooseRunner/Blueprints/UI/Hints/ST_GooseRunner_Hints.uasset` | StringTable |  | Используйте <h>A/D</> для перемещения между полосами. | استخدم <h>A/D</> للتنقل بين المسارات. |
| 27 | `GooseRunner/GooseRunner/Blueprints/UI/Hints/ST_GooseRunner_Hints.uasset` | StringTable |  | Используйте <h>W или Space</> для прыжка и <h>S</> для скольжения. | استخدم <h>W أو Space</> للقفز و<h>S</> للانزلاق. |
| 28 | `GooseRunner/GooseRunner/Blueprints/UI/Hints/ST_GooseRunner_Hints.uasset` | StringTable |  | Освобождайте <h>гусей</> из клеток, они помогут вам в трудную минуту! | حرّر <h>الإوزّ</> من الأقفاص، فسيساعدك في اللحظة الحرجة! |
| 29 | `GooseRunner/GooseRunner/Blueprints/UI/Hints/ST_GooseRunner_Hints.uasset` | StringTable |  | Используйте <h>Q / E</> или <h>движение мышью</> для смещения внутри текущей полосы. | استخدم <h>Q / E</> أو <h>حركة الفأرة</> للإزاحة داخل المسار الحالي. |
| 30 | `GooseRunner/GooseRunner/Blueprints/UI/Hints/ST_GooseRunner_Hints.uasset` | StringTable |  | <h>Магнит</> позволит вам собирать вишенки даже с тех полос, где нет вашего гуся! | <h>المغناطيس</> يتيح لك جمع الكرز حتى من المسارات التي لا يوجد فيها إوزّتك! |

## How to test / rollback

The add-on is optional and NOT installed. To test it on top of the current p11 set:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11 -RuOnly
```

To roll back to the plain p11 set (removes the add-on from `~mods`):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11
```

See `reports/ab_test_guide.md` for what to look at and `HANDOFF.md` for the build state.
