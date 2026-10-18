# Batch 1 translator notes (raw, per chunk)

Generated: 2026-10-18 23:34:57

Each bullet is one uncertain or notable choice made while authoring the Arabic for that chunk.
These are the DRAFT-quality items a reviewer should confirm (see glossary/glossary_questions.md).

## chunk_01_notes.md

# chunk_01 — notes (uncertain choices)

- NEUROPOLYMER -> نيوروبوليمر — the brief's example table gives exactly this rendering for this UI item name; `glossary.tsv` has the lore term `Neuropolymer -> البوليمر العصبي` (used for the concept elsewhere). Kept the brief's UI form here.
- `+50 EN` -> `+50 طاقة` — "EN" is the glove-energy abbreviation; translated as a unit word per rule 4.
- `3D Audio` -> `صوت مجسّم` — short UI label (en_len 8); terse Arabic chosen over the longer "صوت ثلاثي الأبعاد".
- `Auto QTE` -> `QTE تلقائي` — QTE kept in Latin as an established genre acronym.
- `Bumblebee` -> الطنّانة — the MTU-7 robot nickname; the Russian source is an insect name, so it is translated rather than transliterated (unlike glossary robot nicknames such as Hedgie/Belyash).
- `Tumbleweed mode` -> وضع التدحرّج — descriptive rendering of the rolling mode; literal "عشب متدححرج" would be unclear in UI.
- `Bobbin` -> بكرة — literal object meaning; could conceivably be a device/robot nickname (no glossary entry).
- `CATALISATOR` -> المحفّز — misspelled "catalyst"; treated as a module name (no glossary entry).
- `Buckshot` -> خرطوش الرشّ — to stay distinct from `Shotgun` (بندقية رش) and `shotgun shells` (خراطيش رش).
- `Attraction integrity` -> سلامة الجذب — ambiguous stat name; read as the integrity/"health" of the magnetic attraction field.
- `// RESISTANT TO` / `// VULNERABLE TO` -> `// مقاوم ضد` / `// ضعيف ضد` — bestiary headers, kept terse.
- `THE WORLD OF ATOMIC` -> عالم أتوميك — gallery/section title; brand kept transliterated rather than "الذرّي".
- `AlertLevel`, `AutoClosing`, `AutoOpening`, `AutomaticShooting`, `Autosorting`, `BlockRedAttacks`, `BlocksRedAttacks`, `Autofocus`, `Aggro` -> translated, not copied, so that no Arabic cell equals its English cell.
- Copied byte-exact as technical/preserved (no meaningful translation): `/ `, `/`, `- `, `--`, `.`, `. . .`, `..`, `...`, `?`, `:`, `1X`, `2X`, `BC`, `C`, `ORB`, `BP_WayPoint50`–`53`, `2CutthroughTargets`, `+1CutThroughTarget+MaxSegmentsCount`, `<checkbox title>`, `<slider title>`, `<title>`, `<value>`.
- `30 АK47 rounds` -> `30 طلقة АK47` — the "А" in the source is Cyrillic U+0410 and is preserved as such.
- `50 km/h` -> `50 كم/س`; `540 rpm` -> `540 دورة/دقيقة`; `°C` -> `°م`.
- Long robot dossiers (u0010, u0163–u0166, u0214, u0215) have internal double spaces in the English; normalized to single spaces in Arabic.
- `SHOK` / `Frostbite` -> شوك / الصقيع per glossary (note: a sibling chunk used the Latin "SHOK").

## chunk_02_notes.md

# chunk_02 notes — uncertain choices

- `Lorem ipsum` rows (u0565–u0571) -> Arabic paraphrase of the Latin sense ("no one loves pain for its own sake…") — because the source is pseudo-Latin placeholder text; leaving it in Latin verbatim would fail the "no untranslated English" gate, so it was rendered as natural Arabic prose of comparable length.
- `MOB` (u0580) -> حشد — the entry sits in an alphabetical debug-menu list; read as "mob" (crowd / spawn group), not as an acronym.
- `Ergonomics` (u0400) -> الراحة — not in the glossary; chose the player-readable weapon-stat wording over the transliteration "إرغونوميا".
- `Deuteranopia` (u0368) -> عمى الأخضر — descriptive colour-vision term instead of the scientific transliteration, so the option is understandable in a settings list.
- `HDD` (u0472), `DLAA` (u0338), `FHD (1080p)` (u0409), `HD (720p)` (u0471), `Fidelity FX` (u0416), keys `E` (u0378) / `K` (u0537) / `L` (u0544) kept in Latin — display-mode names, technology acronyms and key names.
- `IN USE` (u0385) -> مستخدم — terse status chip; "قيد الاستخدام" would exceed the short label width.
- `Crosshair` (u0319) -> التصويب — length constraint (en 9); "مؤشّر التصويب" is clearer but too long for the label.
- `Gendin` (u0458) -> غيندين, `Drofa` (u0375) -> دروفا, `Krepysh` (u0542) -> كريبيش, `Suslik` (u0444) -> سوسليك — names absent from the glossary; transliterated provisionally (candidates for glossary_questions).
- `ForesterSuslik1Camera1` (u0444) -> كاميرا الحارس سوسليك 1 — internal debug-camera asset name; "Forester" translated (الحارس), "Suslik" transliterated, digits kept.
- `Terminal` (u0333, u0470) -> المحطة الطرفية — glossary form محطة طرفية with the natural definite article (allowed by terminology 4.1).
- `HOLD (tag) TO SKIP` (u0476) — the literal Latin placeholder "(tag)" is kept byte-exact; it is not a rich-text tag.
- `E—response || Q—none` (u0379) — the two em dashes (U+2014) and the `||` separator are kept in the same structural position as the source.
- Trailing spaces preserved on u0567 and u0570 (source rows end with a space); the five-space run between the repeated halves of u0570 is preserved as well.
- camelCase internal identifiers (`DebugGun`, `DecreaseRMBCost`, `GivesArmorOnEnemyKilled`, `Attack hints`, `KilledEnemyCreatesLightnings`, `DoubleBossHealthbar`, …) -> readable Arabic debug-menu labels, since these strings are displayed in the debug/console UI.

## chunk_03_notes.md

# chunk_03 notes — uncertain choices

- Outline -> الحدود — ambiguous UI string (a photo-mode filter or a contrast-mode style); chose the terse "outline/borders" reading.
- Pchela -> بتشيلا — no glossary entry; transliteration of the Russian robot nickname chosen (used in u0666, u0849).
- Perling -> بيرلينغ — unknown robot/proper name, no glossary entry; transliterated.
- RESHETO -> ريشيتو — no glossary entry; transliterated as a name.
- Rotorobot -> روتوروبوت — model-style name; transliterated rather than described.
- Sprout -> برعم / البراعم — creature/plant name absent from the glossary; translated literally and used consistently in u0681, u0815, u0848, u0854.
- Laborer (MFU-68) -> العامل — descriptive robot nickname translated (also referenced in the MED-6 text u0859 as "هيكل العامل MFU-68").
- Drofa (MUC-1) -> دروفا — bird nickname transliterated (u0851, u0860).
- Bumblebee (MTU-7) -> الطنّانة — nickname translated (u0847).
- Owl (LUC-1) -> البومة (plural بومات) — nickname translated (u0802, u0860).
- Engineer (RAF-9) -> المهندس, Medic (MED-6) -> الطبيب, Lab Tech (VOV-A6) -> الفنّي المخبري — role nicknames translated consistently (u0850, u0853, u0859).
- Plych (TM) -> بليتش (TM) — joke brand of Plyusch; transliterated, the (TM) marker kept Latin (u0680).
- PETROV OF OPERA -> بيتروف الأوبرالي — ambiguous label (poster/performer); read as "Petrov the opera singer" (u0669).
- NoStock -> بلا أخمص — "stock" read as the weapon stock (u0630).
- No Localization -> بلا توطين — read as "no localization / no localized subtitles" (u0626).
- SnakeMinigameInputDown/EndGame/Left/Right/Up -> إدخال لعبة الأفعى: ... — internal snake-minigame input names; meaning translated, direction words kept in Arabic (u0807-u0811).
- Test placeholders u0845/u0846 -> repeated اختبار (mirrors "Test ... Value" / repeated "Test Test Test Testst") to avoid leaving untranslated English; the trailing space of u0846 and of u0678 is preserved.
- NoRecoilOnFullEnergy -> بلا ارتداد عند الطاقة الكاملة — camel-case perk identifier rendered as a readable perk label (u0629).
- RangeWeaponStatus / QuestNotify / SaveAsset / UpgradedHead / TwoHorizontalLines -> meaning translated as short UI labels (u0731, u0704, u0782, u0893, u0876).
- Consumable -> المستهلك — used consistently for the Next/Previous/Use Consumable family (u0620, u0692, u0895).
- Reskin (Activate Swede Reskin) -> المظهر البديل — game-jargon "reskin" rendered as "alternative look" (u0800).
- TUTORIAL -> تعليمي — kept terse (6 chars vs 8) as a section label rather than the longer "الدرس التعليمي" (u0837).
- NEXT TIP / Next tab / Previous tab -> التلميح التالي, التبويب التالي, التبويب السابق — kept the natural paired wording (menu-item length allowance) instead of an artificially truncated form (u0610, u0621, u0693).
- Latin-only strings kept byte-exact: Nvidia Reflex, QHD (1440p), UHD (2160p), SSD, TDDSDASd, Q, R, SHIFT, Space (u0637, u0701, u0877, u0769, u0833, u0700, u0706, u0764, u0812).

## chunk_04_notes.md

# chunk_04 — uncertain choices (DRAFT)

- SEE ON MAP -> على الخريطة — because en_len is only 10; dropped the verb to keep a terse UI label.
- Vatrushka -> فاتروشكا — Russian pastry name; transliterated rather than translated.
- YES ENERGY -> نعم، طاقة — source looks like a debug/leftover label; kept a literal reading.
- [ Flatlined ] -> [ مسطّح ] — brackets and inner spaces preserved; "flatline" rendered literally (death/HUD state).
- Laborer / MFU-68 LABORER -> عامل / عامل MFU-68 — robot/worker name; "Laborer" translated, model number kept in Latin.
- Free-bolt automation -> أتمتة المزلاج الحرّ — "free-bolt" is a firearm action term; chose a literal technical reading.
- Agent P3 found a flamer... -> rhyme lost; kept the mockery of the complex's denizens.
- Musclehead -> رأس العضلات — nickname/insult; literal rendering kept.
- Texture anisotropy -> تباين النسيج — graphics setting; used the common short Arabic form rather than a transliteration.
- BINGUN -> بينغن — no glossary entry; transliterated. Consider confirming against the in-game weapon list.
- Ballistic Agent -> عامل باليستي — possibly a module name; literal reading chosen.
- Lake Lazur Shore -> شاطئ بحيرة لازور — "Lazur" transliterated; could be "الّلازورد".
- Block B -> الجناح B — "Block" as a facility wing; could also be "الكتلة B".
- Most of the people who managed to escape from themselves were caught by the orderlies. -> الممرّضون — "orderlies" in an asylum context; psychiatric-attendant sense assumed.
- The Delivery Man and the Mistress -> عامل التوصيل والعشيقة — title of an in-game play/poster; literal reading.
- Surface Approach -> المدخل السطحي — could be a location ("approach to the surface") rather than a method.
- Greased Lightning -> سريع كالصاعقة — idiom localized to keep the "very fast" function, image changed.
- Forester Village -> قرية الغابة — location name not in the glossary; provisional rendering.
- Commonwealth / ManKind Project -> مشروع البشرية — "ManKind" treated as a program name and translated.
- AoC (Academy of Consequences) -> أكاديمية العواقب — abbreviation expanded because the Arabic has no equivalent initialism.
- CENTAUR / MANTIS / COLOSSUS BEA-D, BEA-D Magneton -> القنطور BEA-D / فرس النبي BEA-D / العملاق BEA-D / ماغنيتون BEA-D — BEA-D kept Latin per glossary; the variant word moved after the designation.
- FPS kept as Latin "FPS" in u1197 (common in-game abbreviation).
- SHOK -> شوك — glossary form used instead of the Latin display spelling (validator glossary check).
- Endonyms (deutsch, english, español, français, italiano, polski, português (Brazil)) and the gibberish/symbol strings (x2, x, ], _, {0}, {a}.png, °, º, AK) copied byte-exact per brief rules 4.7/4.8.

## chunk_05_notes.md

# chunk_05 notes — uncertain choices

- HAWK 01 … HAWK 08, SM-1 -> kept byte-identical (unit/model codes). The TM already keeps `HAWK` Latin in `UNIDENTIFIED HAWK -> HAWK غير معرّف`, so identical output for these rows is intentional, not a missing translation.
- HAWK—FORESTER -> `HAWK—الحرّاج` — because `Forester` is a callsign/role here, not a person's name; `الحرّاج` (forest warden) reads naturally beside the preserved `HAWK`; alternative transliteration `فورستر` rejected as it would hide the meaning.
- CONTROLLER DISCONNECTED -> `ذراع التحكّم غير متصل` — because in caps as a system message this is the gamepad-disconnect banner; the game's "Controller" enemy would have been `المتحكّم`.
- Controller Camera 1/2 -> `كاميرا المتحكّم 1/2` — because these are surveillance cameras tied to the `Controller` (not the gamepad); kept consistent with the enemy reading rather than the peripheral reading.
- Art subtitles -> `ترجمات فنية` — because the setting category is ambiguous (art/artistic subtitle track); chose a neutral adjective form.
- High-discrete oscillating circuit -> `دارة تذبذبية عالية التفرّد` — because "high-discrete" has no established Arabic term; `التفرّد` (discreteness) keeps the technical register and matches the component naming style.
- Hold time -> `زمن الإمساك` — because the string sits with the maintenance settings and has no context; `الإمساك` covers both "hold input" and "grip/hold" readings.
- Pchela -> `بشيلا` (transliterated, left for glossary) — because it is a Russian robot name (пчела "bee") not yet in the glossary; kept as a transliteration so the swarm unit keeps an identity.
- profile damage -> `ضرر المقطع` — because "profile" here is a weapon stat (cross-profile damage), not a character profile; `المقطع` keeps it short for UI.
- Дельфин с панамкой -> `دلفين بقبّعة بنما` — because the source string is Russian, not English; translated into Arabic and the trailing space preserved. Recorded here in case the reviewer prefers the raw Russian asset name kept verbatim.
- Vsync -> `تزامن عمودي` — because the full form `المزامنة العمودية` would exceed the 5-char English label; short two-word form used for UI fit.
- Repeater (Vibrating repeater) -> `المكرّر المهتزّ` — because "repeater" as a weapon part is best kept terse; a full `بندقية تكرار` would be too long.
- Meddlesome Lady -> `السيدة المتطفّلة` — because `الفضولية` understates the pejorative sense of "meddlesome".
- Bawler -> `الصيّاح` — because the robot nickname is mocking; `الصيّاح` keeps the insult register.
- "battements and cabriolet" transliterated as `الباتمون والكابريول` — because the French ballet terms have no settled Arabic forms; transliteration avoided a false friend (`باتمان` = Batman).
- ryzhova -> `ريجوفا` — provisional transliteration (Russian ж rendered as ج, matching Nechaev/Zakharov in the glossary); submitted for glossary addition.
- Filimonenko -> `فيليمونينكو`, Petelka -> `بيتيلكا`, Lyogkaya -> `ليوهكايا`, Debaltovskaya -> `ديبالتسيفسكايا` — provisional transliterations, not yet in the glossary.
- Khrushchev -> `خروتشوف`, Michurin -> `ميتشورين`, Koktebel -> `كوكتيبل` — provisional transliterations, not yet in the glossary.
- Hive -> `الخليّة` — because the source capitalises "The Hive" as a unit name; `الخليّة` (hive) keeps both the meaning and the unit-name feel.

## chunk_06_notes.md

# chunk_06 — notes (uncertain / judgement calls)

- Destabilizer -> مزعزع الاستقرار — no glossary entry; chose a descriptive weapon/module name over a terse opaque label.
- Discrete (neuropolymeric destructor / microdoser) -> منفصل — "Discrete" read as "separate/stand-alone module", not "discreet".
- microdoser -> موزّع جرعات دقيق — no glossary entry; provisional descriptive rendering.
- Suffix "-er" agent nouns (Modulator, Detonator, Corrector, Amplifier, Supercharger) rendered with Arabic active-participle patterns (مُضمِّن، مفجّر، مصحّح، مضخّم، شاحن فائق).
- stun / stunning -> تدويخ / مدوّخ (u1534, u1745) — chosen over شلّ (paralysis) to keep "temporary" sense; used consistently.
- Juggernaut -> الجبّار — robot/character nickname, not in glossary; could also be "العملاق".
- Juggler -> لاعب الخفة — stage-performer sense kept instead of "البهلوان".
- Reaper -> الحاصد — death/reaper sense; could also be "المحصّاد".
- Greedy Guts -> الطمّاع — nickname/insult; the pun ("guts"/belly) does not survive, the taunting function does.
- Sucker Punch -> لكمة غادرة — "sucker punch" = treacherous surprise blow; kept as a terse ability name.
- u1588 "Oh, crispy critters!" -> أوه، أيتها الكائنات المقرمشة! — exclamation localized by function, not literally.
- Bottom of Lazur -> قاع لازور — "Lazur" transliterated as a place name (no glossary entry).
- Race of Conscience -> سباق الضمير — read as an event/challenge name; levels rendered سهل/متوسط/صعب/بلا نهاية.
- VOLAN (u1763) and HAWK (u1683, u1768) kept in Latin — follows tm.tsv, where VOLAN/HAWK are preserved untranslated in approved Arabic.
- Sealed with Seven Seals -> مختوم بالأختام السبعة — film-title style; literal seal imagery kept.
- u1740: engine markers `#.KEY:`, `//Msg. start//`, `//Msg. end//`, `#REG.ENTRY:`, `#June111955` and the two double spaces copied byte-exactly around the translated dossier text and the insult line.
- Dr. Lizova -> الدكتورة ليزوفا — feminine form used (English "Dr." is gender-neutral); "Dr. Domov" -> الدكتور دوموف.
- Makhnyov / Ludwig (u1727), Khozin / Aniva (u1775), Yablochkovo (u1513) transliterated (no glossary entries).
- u1573, u1727, u1740: source whitespace preserved (one trailing space on u1573; internal double spaces kept).
- u1603, u1606: source uses U+02BC (ʼ) in "puppetʼs"/"youʼre"; as possessives/contractions they have no Arabic equivalent, so the meaning was translated without the character.
- Muzzle cryorails -> قضبان الفوهة المتجمّدة — "cryo" rendered as تجميد to match the glossary style of Cryo Jet (النفّاثة المتجمّدة) rather than a bare "كرايو".
- Polymeric alloy bolt frame / Revolver-type bolt frame -> إطار مزلاج — "bolt frame" read as the firearm bolt carrier assembly.

## chunk_07_notes.md

# chunk_07 notes — uncertain choices

- FOX -> `الثعلب`, CRICKET -> `الجدجد` (weapons). The project translates English-language weapon nicknames (glossary: Swede -> السويدي, Snowball -> كرة الثلج, Needle -> الإبرة, Whip -> السوط) while Russian ones are transliterated (Kalash -> كلاش, Pashtet -> باشتيت), so the meaning was kept instead of a transliteration. Note: chunk_05 u1240 left `Fox` in Latin inside the sentence "PM and Fox unlocked" -> `PM وFox مفتوحان`; reviewer may want to align these two rows.
- Килька (Russian source) -> `الأنشوفة` — because chunk_06 has the same weapon under its English name `ANCHOVY` (u1796), and both rows must end up with the same Arabic.
- KS-23 (u1830) copied byte-exact: it is a model code, and `КS-23` (u1832, u1835) keeps its Cyrillic `К` (U+041A), not a Latin `K`.
- DUMMY Х / DUMMY Y (u2042, u2043) copied byte-exact — dev/test placeholder labels; u2042 keeps the Cyrillic `Х` (U+0425), u2043 keeps Latin `Y`.
- Tanks/canisters u1812 `TRIANGLE MOON CANISTER` -> `حاوية القمر المثلّثة` — because the sibling rows (chunk_06 u1808-u1811 SQUARE/RING/X/CIRCLE MOON CANISTER) all follow the "canister + moon + engraved shape" pattern; u1895-u1899 use the same shape words (مربّع، دائرة، مثلّث، حلقة).
- LUC-1 Laser/Rocket Owl -> `LUC-1 البومة الليزرية/الصاروخية`, LUC-1 OWL -> `LUC-1 البومة`; MFU-68/CP Duck -> `MFU-68/CP البطّة` — because chunk_03 u0802 translated `Owl` as `البومة` and its description keeps `LUC-1` in Latin, so the model code stays Latin and the nickname is translated.
- Dandelion Security CCTV Camera -> `كاميرا مراقبة الأمن DANDELION` — because the approved TM row (chunk_01 series) keeps the product name `DANDELION` in Latin inside its description.
- KS-23—DAMPER-POLYMERIC STOCK -> `KS-23—أخمص مخمّد بوليمري` — the hyphen inside `DAMPER-POLYMERIC` is realised as Arabic word order, exactly as the already accepted row chunk_05 u1510 `Damper-polymeric stock` -> `أخمص مخمّد بوليمري`; the em dash itself is preserved.
- KS-23—EXPANSIVE CONVERTER -> `KS-23—محوّل تمدّدي` — "expansive" has no fixed Arabic term here; `تمدّدي` keeps the technical register and matches `محوّل` (converter -> محوّل, chunk_05 u1254).
- Vector controller -> `متحكّم المتجه` — deliberately different from chunk_05 u1254 `Vector transducer` -> `محوّل المتجه`, since the English nouns differ.
- Cafeteria -> `المقصف` (locations `مجمّع مندليف: المقصف`, `ممرّات المقصف`) — "cafeteria" is rendered with the MSA word rather than the transliteration `الكافيتيريا`, following the project's preference for translated common nouns; the row `Cafeteria Manager` lives in chunk_06 and should be aligned.
- Cable Car -> `التلفريك` (u1942, u1943) — no established project form yet; the common Arabic loanword was chosen for UI fit.
- Hangar -> `الحظيرة` (u1911, u1915) — short label kept for UI length instead of `مستودع الطائرات`.
- Flights of Stairs -> `أدراج السلالم` (u1930), In-Patient Facility Stairs -> `سلالم قسم المرضى المقيمين` (u1952) — "in-patient facility" has no glossary form; the descriptive rendering was preferred to a vague `الدرج`.
- Interchange (Vavilov tunnels) -> `التبادل` (u1941) — could also be `الوصلة`/`المحطة التبادلية`; kept terse.
- ULTRA (u1864) -> `فائق` — a graphics preset, kept in line with the seed TM (Balanced -> متوازن, Quality -> الجودة); alternative was copying `ULTRA` Latin.
- LORE MENU -> `قائمة المعلومات` — "lore" has no clean Arabic UI word; `المعلومات` avoids both the literal `الحكايات` and a clash with the glossary `Archive` -> الأرشيف.
- Shop -> `متجر`, Store -> `دكّان` (u2055, u2056) — the two adjacent labels are near-synonyms in English; two different Arabic words were used in case both appear on the same screen. `Store` here is not the inventory (that is `المخزن`, used for MAGAZINE and EXPANDED STORAGE).
- Full House (u2022) -> `البيت الكامل` — a dossier/letter title with no context; the poker idiom was translated rather than transliterated.
- Looter (u2081) -> `النهّاب` — a role/nickname; the pejorative register was kept.
- BLOOD COURIER (u1828) -> `ساعي الدم` — no context (robot or unit name); the literal translation was chosen over a transliteration.
- Cryo Sleep -> `سبات متجمّد` (u1979), Icy Destruction -> `الدمار الجليدي` (u2014), Drastic Measure -> `إجراء جذري` (u1973), It's Complicated -> `الأمر معقّد` (u1909) — nightmare/letter titles with no glossary form.
- Rooster sledgehammer -> `مطرقة الديك` (u1988), A box of deadly items -> `صندوق من العناصر الفتّاكة` (u1967) — museum/loot labels with no context.
- MED-6 Doc -> `دكتور MED-6` (u2045) — model code kept Latin, `Doc` rendered with the glossary `Doctor` form `دكتور`.
- PR-3 in RECONFIGURED PR-3 RESISTORS -> `مقاومات PR-3 المعاد ضبطها` (u2037) — `PR-3` kept Latin; it is read as a part code, not the character `P-3`.
- SPOKE BOOST -> `تعزيز الأضلاع` (u2034) — "spoke" (of the saw wheel) has no settled Arabic term; `الأضلاع` was used for UI length and readability.
- Klimovs -> `آل كليموف` (u1890) — familial plural has no Arabic single-word equivalent.
- Altupolis (u1848) -> `ألتوبوليس` — provisional transliteration, not yet in the glossary.
- Karamelkin, Kuzmich, Krayeva, Meglina, Makhnyov, Lebedyansky, Lebedin, Malakhova, Lorievich, Klavdia, Konstantinovna, Lizova, Larisa, Kristina, Marina, Maria, Lev, Karamela-related names — provisional transliterations (كاراميلكين، كوزميتش، كراييفا، ميغلينا، ماخنيوف، ليبيديانسكي، ليبيدين، مالاخوفا، لوريفيتش، كلافديا، كونستانتينوفنا) pending glossary additions.
- Carl Jung -> `كارل يونغ`, Leo Tolstoy -> `ليو تولستوي`, Lewis Carroll -> `لويس كارول`, Mark Twain -> `مارك توين`, Marty McFly -> `مارتي مكفلاي`, Mahatma Gandhi -> `المهاتما غاندي`, Konstantin Tsiolkovsky -> `كونستانتين تسيولكوفسكي` — well-known names rendered with their standard Arabic forms.
- Language-selection/punctuation rows: Arabic commas `،` and the Arabic question mark `؟` used inside Arabic sentences (u2020, u2067); ASCII colon kept inside location labels, matching chunk_05 (`المتحف: البهو`, `مجمّع مندليف: فندق ليوهكايا`).

## chunk_08_notes.md

# chunk_08 — uncertainties and choices

- Neyelova -> نييلوفا — transliteration of Неелова/«Neyelova»; not in glossary, kept close to the Russian spelling.
- Michael / Michael Stockhausen -> ميخائيل — treated as the Russian form Михаил (same character as the Vavilov biography first names); a German «ميخائيل» reading was preferred over «مايكل» for consistency across u2127/u2196.
- «Trap mine» -> لغم فخّي — «trap mine / mina-lovushka»; «لغم شركي» was the alternative, «فخّي» reads better as an equipment name.
- «Finial» -> زخرفة قمّية — short item name for an ornamental top piece; «قمة زخرفية» was the alternative.
- «NAJTITE BALLON» (u2182, source is Russian «НАЙДИТЕ БАЛЛОН») -> اعثر على الأسطوانة — the row is Russian, not English; translated by meaning so it matches the neighbouring «FIND ACTIVATION CARD» objective.
- «Trap mine»/«Pressure builder» -> مولّد الضغط — «بانِي الضغط» was rejected as unidiomatic.
- «Neurokinetic centrifuge» -> نابذة عصبية حركية — «جهاز طرد مركزي عصبي حركي» is clearer but too long for a 23-char UI label.
- «Neuropolymeric» -> عصبي بوليمري — adjective order follows the approved TM row «Neuropolymeric supercharger = شاحن عصبي بوليمري فائق».
- SHOK -> شوك — glossary form used everywhere, including inside <h> tags (u2298) and the SHOK charging upgrade (u2356), matching TM row for SHOK/Frostbite.
- «Frostbite» rendered الصقيع in u2383 per glossary; «regular frostbite» -> الصقيع العادي.
- u2157 «Rooster hammer» -> مطرقة الديك القوية — «Rooster» is a nickname; kept literal because no glossary entry exists.
- u2156 «Med Reflector» -> عاكس طبي قوي — «Med» read as «medical»; «Med» transliterated was the alternative.
- u2205 «Finial», u2226 infomercial style — register kept as advertising patter.
- u2224 «snitch» -> المُبلّغ — kept blunt (not softened to «المخبر») to preserve the original tone.
- u2396/u2397 «No lockpick» / «No stock» -> لا كسّارة أقفال / لا أخمص — «stock» read as the weapon's stock (same sense as u2409 «stock»); the alternative «لا مخزون» (out of stock) was rejected because these rows look like equipment-slot strings.
- u2388 «AoC» -> أكاديمية العواقب — expansion «Academy of Consequences»; not in glossary.
- u2386/u2406 em dashes (—) preserved with the same occurrence count as the English (4 and 1 respectively).
- u2399 «Lower Yablochkovo» -> يابلوتشكوفو السفلى — toponym, not in glossary.
- u2337 «Deimos OS» kept Latin; «Chelomey Design Bureau» -> مكتب تشيلومي للتصميم.
- u2346/u2347 nearly identical English: wording differentiated slightly («والأعداء العضويون أكثر حساسية…») consistent with the source difference.
- u2199/u2200 and u2262/u2264/u2265 near-duplicates: wording varied only where the English differs (strike/attack, into/to, lab/labs).
- u2303 «Senior Archivist» -> أمين الأرشيف الأقدم — «كبير الأمناء» was the alternative.
- u2308 «Polymerized Subjects» -> الأشخاص المبلمرين — «الخاضعين للبلمرة» longer; chosen form matches «مبلمَر» used in TM.

## chunk_09_notes.md

# chunk_09 notes — uncertain choices

- Bingun -> بينغون — because there is no glossary entry; the proper name is transliterated.
- Echidna -> إكيدنا — because there is no glossary entry; the mythological name is transliterated.
- Singer -> المغنّي — because the English is ambiguous (possibly a robot/attack name); rendered as a common noun.
- Jelly Man -> رجل الهلام — because there is no glossary entry; the descriptive boss name is translated rather than transliterated.
- Cricket -> كريكيت — because there is no glossary entry; the weapon/nickname is transliterated.
- A GLASS, DARKLY -> كأس، بغموض — because it is a punning drink/mission title; kept the wordplay flavour instead of a literal rendering.
- ROCK BOTTOM -> القاع — because the English idiom is noun-like; rendered as the short literal noun for UI fit.
- Nyukhov -> نيوخوف — proper name absent from the glossary; transliterated.
- Oystein -> أويستين — proper name absent from the glossary; transliterated.
- Meglina -> ميغلينا / Yefremov -> يفريموف / Krayeva -> كراييفا / Gromyko -> غروميكو — dossier names absent from the glossary; transliterated.
- reductor -> مخفّض — no glossary entry; chosen for consistency across weapon-module descriptions.
- relay -> مرحّل — no glossary entry; chosen for consistency across the relay-maintenance strings.
- Pchela -> بتشيلا — reused the rendering already present in chunk_03 (WSP-9 drone).
- u2516 source is Russian (not English): "От: Вавилов Николай Иванович / 57 лет / Социальный рейтинг: 7.9". Translated to Arabic while keeping the <Bold> tags, the "/" separators and the digits byte-exact.
- 12х70 / 9х18 — the "х" is Cyrillic U+0445 in the source and was preserved exactly (not replaced with Latin "x").

## chunk_10_notes.md

# chunk_10 notes - uncertain choices

- Volan -> `VOLAN` (kept in Latin) — because the approved TM row `The <h>VOLAN</> is an auxiliary interface...` (u0150) keeps `VOLAN` in Latin and there is no glossary entry; DANDELION and HAWK are treated the same way, so `SDC-2 Volan` -> `SDC-2 VOLAN`, `Volan's data` -> `بيانات VOLAN`.
- Windbender / Windcatcher -> `ويندبندر` / `ويندكاتشر` — because these are made-up power-generator device names with no glossary entry; transliteration keeps a stable identity instead of inventing a descriptive name.
- Pchela -> `بشيلا` — because the glossary has no entry and chunk_05 (approved) regularised the same Russian robot name as `بشيلا`.
- Polymeric Overload -> `فرط الحمل البوليمري` — because a literal `التحميل البوليمري الزائد` (25 chars) trips the length warning on an 18-char label; `فرط الحمل` is the established short Arabic form for "overload".
- finial -> `الطرف الزخرفي` — because chunk_04 (approved) renders `Finial` / `Basic Finial` with this form and it must stay consistent between weapon parts.
- Stock -> `الأخمص` — because chunk_04 (approved) uses `الأخمص` for the weapon stock (`A basic wooden stock.`).
- Grip / Handle -> `المقبض` / `القبضة` — because chunk_04/05 use `المقبض` for "Grip" (`Grip Center`, `Grip Head`); "Handle" is a separate part in the same list, so a distinct short term was needed.
- magazine (swap magazines, SECATEUR—MAGAZINE) -> `المخزن` — because the glossary only fixes `Cartridge` = `خرطوشة`; the ammo magazine is a different part and `المخزن` is the neutral Arabic firearm term.
- Receiver -> `المستقبِل` — because the English is ambiguous between a firearm receiver and a signal receiver, and the string sits in an uncontextualised parts list.
- Robogirl -> `الفتاة الروبوت` — because the robot nickname has no glossary entry; a descriptive Arabic compound reads better than a transliteration and fits the 8-char label limit.
- Reufe -> `روفه` — provisional transliteration only (short surname, no glossary entry).
- Koschevna / Koschey -> `كوشتشيفنا` / `كوشتشي` — provisional transliterations of the folklore nickname and its source character.
- Khodyukova -> `خوديوكوفا` — provisional transliteration (no glossary entry); `Nonna Khodyukova` -> `نونا خوديوكوفا`.
- Gireyev -> `غيرييف`, Nyukhov -> `نيوخوف`, Dyagterev -> `دياغتيريف`, Raguzin -> `راغوزين`, Privalov -> `بريفالوف`, Robertovich -> `روبرتوفيتش`, Larisa -> `لاريسا` — provisional transliterations, matching the glossary conventions for Russian names (г = غ, ж = ج).
- Radeonovich -> `راديونوفيتش` — follows the glossary entry `Chariton Radeonovich` -> `خاريتون راديونوفيتش`.
- Ryzhova -> `ريجوفا` — matches the approved chunk_05/04 rendering of the same ballerina.
- Pesticide Workshop / Cold Workshop -> `ورشة المبيدات` / `الورشة الباردة` — because only `Algae Workshop` and `Hot Workshop` are in the glossary; the other two workshops (chunk_06) get the same `ورشة/الورشة + modifier` pattern.
- Seed Bank -> `بنك البذور`, lighthouse -> `المنارة` — no glossary entries; descriptive renderings used consistently.
- Torrent modulation -> `تعديل التدفق` — because "torrent" has no established Arabic technical sense here; kept neutral and short for a menu label.
- Chain Lighting -> `البرق المتسلسل` — the English has a typo ("Lighting"); translated as "Chain Lightning" per the weapon-upgrade meaning.
- Splitting blow -> `الضربة الشاطبة`; Full Contact -> `التماس الكامل`; Tar and Feather -> `القار والريش`; Peaceful Atom -> `الذرة السلمية`; Worker and Kolkhoz Woman -> `العامل والمرأة الكولخوزية` — no glossary entries; rendered as established Arabic names/idioms rather than transliterations.
- Relay -> `المرحّل` and Power Cell -> `خلية طاقة` — used consistently across the chunk to keep the HAWK/security-relay and recirculation-chamber parts readable.
- BEA-D, P-3, HAWK, PEC-4, RAF-9, ESRB, WTG, ATP, DANDELION kept in Latin — model codes, characters and systems that the glossary or the TM marks as preserved.
- MADE IN THE USSR -> `صُنع في الاتحاد السوفييتي` — the idiomatic full phrase is 2 characters over the length-warning threshold for a 16-char label; accepted in favour of the natural stamp text (`صناعة سوفييتية` is the shorter alternative).
- u2822 (USSR humanitarian-aid resolution) — the trailing space of the English fragment is preserved in the Arabic cell.
- Objective strings (`Get...`, `Bring...`, `Survive...`, `Proceed...`) -> Arabic verbal nouns (`الحصول على...`, `إحضار...`, `النجاة من...`, `التوجّه إلى...`) — because the approved TM uses that pattern (`Detain Petrov in the Theater` -> `احتجاز بيتروف في المسرح`).

## chunk_11_notes.md

# chunk_11 notes - uncertain choices

- Тест -> `اختبار` — because the English is the Russian word for "test", not gibberish/symbol-only, so it was translated rather than copied; if the string is a raw dev label the copy-class rule may apply instead (only row in this chunk where "copy English as-is" was considered).
- Sergeeviches -> `آل سيرغييفيتش` — because the plural of the patronymic nickname has no glossary entry; an Arabic collective (`آل` = "the ... family") was chosen over a bare repeated singular so it stays distinct from `Sergeevich` -> `سيرغييفيتش`.
- Barrel / Barrels / Barrel case -> `الماسورة` / `الماسورات` / `علبة الماسورة` — because the approved TM renders firearm "barrel" as `الماسورة` (`Barrel module` -> `وحدة الماسورة`); the same three strings could also be oil drums (`برميل`), which is the alternative if the UI shows world objects rather than weapon parts.
- STORAGE -> `التخزين` (and STORAGE/DISASSEMBLY -> `التخزين/التفكيك`) — deliberately different from `Warehouse` -> `المخزن` so the two adjacent labels do not collapse into the same Arabic word.
- CAPTURE -> `احتجاز` — because the TM uses `احتجاز` for the same enforcement verb (`Detain Petrov in the Theater` -> `احتجاز بيتروف في المسرح`); `استيلاء` would be the reading if the string is about seizing a location.
- FORTITUDE -> `الصمود` (Fortitude 2/3 -> `الصمود 2`/`الصمود 3`) — because `الجَلَد` (the literal "fortitude") would be misread as "leather" next to an all-caps HUD label.
- Armageddon -> `هرمجدون` — difficulty-tier name with no glossary entry; the established Arabic transliteration of Armageddon was used.
- Triode energy absorber -> `ماصّ الطاقة الثلاثي` — because `Triode` has no glossary entry; `الصمّام الثلاثي` is the longer electronics reading if the part is the vacuum tube and not the "triple" module.
- Hive -> `الخلية` (in `Additional Hive settings terminal`) — because the glossary/TM preserve only HAWK/VOLAN/DANDELION/PEAR in Latin; keeping `HIVE` in Latin is the alternative if the in-game check shows it is an untranslated system code name.
- Academy of Consequences -> `أكاديمية العواقب` — because the TM row for Petrov keeps the abbreviation `AoC` in Latin; the full Arabic name was used here because the dossier reads as prose.
- profile polymer -> `البوليمر الخاص` — because the approved TM renders the consumable resource as `البوليمر الخاص` (`special polymer`); a distinct reading (`بوليمر الملف`) is possible if "profile" is a separate resource name.
- collimator scope -> `منظار تصويب قياسي` — because `كوليماتور` is rarely understood in Arabic UI; the descriptive rendering was preferred for a 62-character tooltip.
- The Turbine -> `التوربين` (in `Get in the Turbine`) — the vehicle/hall name has no glossary entry; `Turbine` also appears as a standalone string in chunk_13, so this may need to be aligned with that chunk later.
- 2 fire modes (u3073) -> `2 من أوضاع الرمي` — the digit `2` was kept explicitly (instead of the natural Arabic dual `وضعا رمي`) so the number survives byte-exact.
- Provisional transliterations with no glossary/TM entry: Smirnov -> `سميرنوف`, Alexander Kuznetsov -> `ألكسندر كوزنيتسوف`, Sergey Dovlatov -> `سيرغي دوفلاتوف`, Semyonovna -> `سيميونوفنا`, Timofeyevich -> `تيموفيفيتش`, Tove Jansson -> `توفي يانسون`, Terry Pratchett -> `تيري براتشيت`, Steve Jobs -> `ستيف جوبز`, Stepan -> `ستيبان`, Tamara -> `تمارا`, Claire -> `كلير`, Komar -> `كومار`, Lukomorye -> `لوكوموري`, Titan -> `تيتان`.
- Roboboy -> `فتى روبوت` — follows the TM/notes rendering of Robogirl -> `الفتاة الروبوت` inside the u3188 dossier.
- Battering blow -> `الضربة الطاحنة` while Crushing blow -> `الضربة الساحقة` — two separate upgrade names needed distinct short forms, so the near-synonyms were split between `طاحنة` and `ساحقة`.
- Weak/Strong hit -> `إصابة ضعيفة`/`إصابة قوية` (and Power attack -> `الضربة القوية` per the TM `Power attack hints`) — to keep "power attack" and "strong hit" from becoming the same Arabic label.
- Jet Module -> `وحدة النفّاثة` — follows the glossary `Polymeric Jet` -> `النفّاثة البوليمرية`; `وحدة الدفع النفّاثي` if the module is a thruster rather than an ability upgrade.
- Textures -> `الأنسجة`; Subtitles -> `الترجمة` — standard Arabic UI terms for graphics/subtitle settings.
- u3156 and u3289 keep their trailing spaces in the Arabic cell (fragments consumed by the UI).

## chunk_12_notes.md

# chunk_12 notes (EN -> AR)

- Spooling speed -> سرعة التدوير — because "spooling" refers to spinning up the accelerator; kept terse as a stat label.
- Impact -> ارتطام / وحدات الصدم — "Increased Impact" and "Impact units" rendered with the impact/"صدم" root; no glossary entry exists.
- rifle pitch -> خطوة البندقية — kept parallel with "barrel bore pitch" = خطوة تجويف الماسورة; "pitch" here means twist/step of the barrel.
- weak point damage -> ضرر نقاط الضعف — matches existing TM "ضرر لنقاط الضعف" wording.
- weakened points -> النقاط المُنهَكة — distinct from "weak points" (نقاط الضعف); "weakened" treated as already-worn points.
- grazed enemy -> عدو تصيبه إصابة سطحية — "graze" read as a glancing/skim hit.
- Mph! Gr! -> همف! غر! — an untranslatable grunt/onomatopoeia; rendered as an Arabic phonetic equivalent in the same interjection register.
- spigots -> موصلات — "spigots" transmit energy, so rendered as connectors rather than the literal "صنابير".
- muzzle brake compensator -> معوّض كابح الفوهة المحسّن — uses existing TM "كابح الفوهة".
- marching engine -> محرّك سير — "marching engine" read as a locomotion/drive engine in the exoskeleton upgrade context.
- GREASER -> المشحّم — robot type; translated like SECATEUR (المقصّ) rather than transliterated.
- SURGEON -> الجرّاح — robot type; translated like SECATEUR.
- Auger (SNOWBALL—AUGER) -> المثقب — attachment name; kept the em dash in place.
- Photon Sink -> مصرف الفوتونات — "sink" as a drain/absorber device.
- Extended Topology -> طوبولوجيا موسّعة — kept the technical term "طوبولوجيا".
- roundhouse attack -> ضربة الدوران — a spinning/roundhouse strike.
- Reflex (accelerator / frame generation) -> الرفلكس — transliterated as an in-game feature name rather than kept Latin.
- Brave New World -> عالم جديد شجاع — standard Arabic rendering of the Huxley title.
- Pelican (loader) -> بيليكان — in-world machine name transliterated like other robots (Burlak -> بورلاك).
- Perlin/Pelican/Vortex context: "Maglev high-speed Vortex trains" -> قطارات فورتكس فائقة السرعة المعلّقة مغناطيسياً — "Maglev" expressed descriptively as magnetically levitated.

## chunk_13_notes.md

# chunk_13 notes — uncertain choices

- u3630 `Chai! And chaps!` -> `شاي! ويا رفاق!` — a short exclamatory toast with no glossary entry; the cheer/party function and both exclamation marks were kept, "chaps" rendered as a vocative rather than literally.
- u3627 `Turbine` -> `توربين` — no glossary entry; the established Arabic loan form was used for the location label (`Chelomey` does not need it).
- u3760 `Thrift` -> `التوفير` — single ambiguous word in an uncontextualised list; read as the abstract quality ("frugality") rather than a shop name.
- u3725 `SHOKer` -> `شوكر` / u3727 `SHOK therapy` -> `علاج شوك` — SHOK is fixed by the glossary (`شوك`); the two derived module names are not in the glossary, so a transliterated nickname and a descriptive compound were used instead of inventing a root.
- u3650 `Lumberjack` -> `الحطّاب`, u3651 `Carousel` -> `الدوّار`, u3652 `Greaser` -> `المشحّم` — melee-weapon nicknames with no glossary entries; translated (like `Star` -> `النجمة`, `Fox` -> `الثعلب`, `Snowball` -> `كرة الثلج`) rather than transliterated, for a readable weapon list.
- u3651 `Carousel` -> `الدوّار` — follows the approved TM row `WeaponsCarousel` -> `دوّار الأسلحة`.
- u3671 `Fox` -> `الثعلب` — although TM u2003 keeps `Fox` in Latin in one list row, the approved TM row `FOX—ERGONOMIC HANDLE` -> `الثعلب—مقبض مهيّأ تشريحياً` translates it, so the translated form is used.
- u3753 `RHINO ENERGY STORAGE` -> `مخزن طاقة الكركدن` / u3754 `CRICKET ENERGY STORAGE` -> `مخزن طاقة الجدجد` — weapon-specific energy-storage names without glossary entries; the animal nicknames were translated (short form) instead of transliterated.
- u3716 `SDC-2 VOLAN` kept in Latin (`ورقة غشّ SDC-2 VOLAN`) — matches the approved TM row `SDC-2 Volan` -> `SDC-2 VOLAN`.
- u3711 `BB`, u3742 `Snap-A`, u3825 `m`, u3859 `BP_WayPoint` — copied byte-exactly (ammo/model/unit code; `Snap-A` is already kept in Latin in TM u2494).
- u3829 `русский`, u3831 `уйцуйцуйцу`, u3833 `—`, u3835 `日本語`, u3836 `汉语`, u3837 `漢語`, u3838 `한국어`, u3840 `DX11`, u3841 `DX12` — copied byte-exactly (language endonyms, gibberish, symbol-only, graphics-API codes).
- u3876 `!!!`, u3881 `:(`, u3882 `?!`, u3883 `X(` — copied byte-exactly (symbol-only strings; the `?` in `?!` is a copy, not an Arabic sentence).
- u3845 `PBR BaseColor Range` -> `نطاق اللون الأساسي PBR` / u3846 `PBR Specular Range` -> `نطاق اللمعان PBR` — engine buffer-visualisation labels; translated but `PBR` kept in Latin as a technical acronym.
- u3858 `BIKE WITH SIPUHAr` -> `دراجة مع SIPUHAr` — developer asset name with a garbled tail; the readable part is translated and `SIPUHAr` kept Latin so the actor name still matches.
- u3862 `ICE CREAM RAFIK` -> `آيس كريم رافيك` — `RAFIK` read as a personal name (رفيق/رافيك), so it is transliterated rather than translated as the word "comrade".
- u3864 `MUSICAN` -> `موسيقي` — the English has a typo; translated as "musician" like the neighbouring Misc sound-emitter labels.
- u3674 `binoculars` -> `منظار`, u3685 `Condensed Milk` -> `حليب مكثّف`, u3688 `Bottle of Vodka` -> `قنينة فودكا` — follow the approved TM rows `BINOCULARS` -> `منظار`, `CONDENSED MILK` -> `حليب مكثّف`, `VODKA` -> `فودكا`.
- u3732/u3733 `Conventional barrel case` -> `غطاء ماسورة تقليدي` — no glossary entry; a neutral weapon-part rendering was used (`Conventional barrel` -> `ماسورة تقليدية`).
- u3751 `EMP inductor` -> `ملف حثّ EMP` — "inductor" is the electrical component; `EMP` kept in Latin as in the approved TM (`وحدة EMP`).
- u3760-adjacent list items u3730 `Staff Head` -> `رأس العصا` and u3755 `ERGONOMIC STAFF` -> `العصا المريحة` — "staff" read as the melee-weapon shaft, consistent with `Finial`/`Staff` being weapon parts.
- u3762 `Expansive converter` -> `المحوّل التمدّدي` — follows the approved TM rows `PM—EXPANSIVE CONVERTER` / `KS-23—EXPANSIVE CONVERTER`.
- u3717 `JAB` -> `لكمة` — a melee move label; the short boxing term was preferred over a literal verb phrase.
- u3692 `not worth their salt` -> `لا قيمة له` — the idiom was localised to its function (a spy without a lockpick is worthless); the salt image does not survive in Arabic.
- u3691 `It could drive you Limbonkers!` -> `هذا كفيل بأن يجنّنك حتى في ليمبو!` — the Limbo/`bonkers` pun cannot survive; the joke function and the place name `ليمبو` (glossary) were kept.
- u3819 `Trouble in paradise?` -> `مشكلة في الجنّة؟` — idiomatic rendering; no glossary variant exists.
- u3638 `Chelomey: High-Rise 1st Floor` -> `تشيلومي: الطابق 1 من البرج` — the ordinal was written with a Western digit to satisfy the digits rule, while `Final Floor` stays as words.
- u3932 `Mastiffs, Unicorns` -> `الماستيف واليونيكورن` — WWII-era military robot nicknames with no glossary entry; transliterated so the veteran's named machines stay recognisable.
- u3923 `Zmei Gorynich` -> `زمي غورينيتش`, `bravvies` -> `برافيز`, `Trebelov` -> `تريبلوف` — quoted codename/nickname/inventor name; transliterated rather than translated so the in-world citations stay consistent.
- u3790 `Erich Maria Remarque`, u3804 `Yusup` -> `يوسوب`, u3803 `Korolyov`/`Yuri Gagarin` -> `كوروليف`/`يوري غاغارين` — established Arabic forms of real persons, matching the glossary transliteration conventions.
- u3924 `chicken coop` -> `خمّ دجاجه` and `rutting roosters` -> `الديوك الهائجة` — kept the crude/ridiculous register of the complaint, not sanitised.
- u3921 `Gimme a break...` -> `أرحمنا...` — exasperated filler localised to an Arabic equivalent; the rude `fucking apple trees` stays crude as `أشجار تفاح لعينة`.
- u3941 `before we get our asses handed to us on a platter` -> `قبل أن تُوضع رؤوسنا على طبق` — the vulgar image was localised to a comparable Arabic idiom rather than softened.
- u3934/u3935/u3941 `E. Puodjunas` -> `بووديوناس` and `E. Puojunas` -> `بوويوناس` — the English spells the same watchman two ways; each row follows its own spelling.
- Other provisional transliterations: `Styzhev` -> `ستيجيف`, `Liteikina` -> `ليتيكينا`, `Kalinina` -> `كالينينا`, `Vybegallo` -> `فيبيغالو`, `Kislevsky` -> `كيسليفسكي`, `Muravyova` -> `مورافيوفا`, `Martashev` -> `مارتاشيف`, `Savelyeva` -> `سافيليفا`, `Kopylova` -> `كوبيلوفا`, `Osenev` -> `أوسينيف`, `Nikitin` -> `نيكيتين`, `Rukh` -> `روخ`, `Yegor` -> `ييغور` — no glossary entries; standard Russian-name transliteration used throughout.
- Whitespace structure was preserved: the trailing space of u3697, the double space of u3724, the triple space of u3937, the double-space paragraph separators of u3872-u3942, the non-breaking space before the em dash in u3809, and the narrow no-break space plus word joiner inside `BEA‑Ds` in u3701.
- Em dashes in compound part names were kept in place: `السويدي—…` (u3708-u3710), `إلكترو—…` (u3745-u3748) and the parenthetical em dashes of u3923/u3926/u3929.

## chunk_14_notes.md

# chunk_14 notes — uncertain choices

- "Atomic Heart" (project name) -> `مشروع القلب الذري` — no glossary/TM entry; the literal title rendering was chosen and is used consistently in u4206.
- "Energy for All" -> `الطاقة للجميع` — propaganda programme name; descriptive Arabic rendering.
- `Илья` (u4087) -> `إيليا` and `Поспелов` (u4165) -> `بوسبيلوف` — the source is Cyrillic (terminal user names); the glossary transliterates Russian personal names, so these were transliterated rather than copied.
- `Workshop 308-А` (u4096) -> `ورشة 308-А` — the trailing letter is Cyrillic А (U+0410); copied byte-exact.
- `Dandelion` the flower/seeds -> `الهندباء` (u3970), but `Dandelion cameras` / `dandelions and hives` -> `DANDELION` kept in Latin (u3993) — follows the approved TM rows `Dandelion` = الهندباء and `Dandelion CCTV cameras` = كاميرات المراقبة DANDELION.
- `Lithops` (u3970 seed list) -> `نبات Lithops` — botanical genus name kept in Latin.
- `Dionaea muscipula` (u3994) -> kept in Latin — scientific name quoted inside a confession, no Arabic equivalent in use.
- `Pioneer` / `Young Pioneers` -> `الرائد` / `الرواد الشباب` — Soviet-era organisational names; the cartoon character "the Pioneer" uses the same word.
- `crispy critters` (u4053) -> `الكائنات المشويّة` — slang for people burned beyond recognition; the insulting/crude register is kept in Arabic.
- `the fence` (u4037) -> `تاجر المسروقات` — English slang for a receiver of stolen goods; no established Arabic slang here, so a neutral readable term was used.
- `Ole!` (u4069) -> `أوليه!` — a subject-line interjection; transliterated rather than translated.
- `tank` (u4231, "drop off this tank") -> `الخزّان` — the English is ambiguous between a vehicle and a container, so the neutral "container/tank" reading was chosen.
- Robot/device names with no glossary entry: `Rafik` -> `رافيك`, `Anfisa` -> `أنفيسا`, `Pelican` -> `بيليكان`, `Raven-1` -> `رافن-1`, `Manka` -> `مانكا`, `Working Woman` -> `المرأة العاملة` (sculpture title translated), `Cherevikov`-style surnames transliterated.
- `Poly hairstyles` / `Poly nail polish` (u4233) -> `تسريحات البوليمر` / `طلاء أظافر بوليمري` — "Poly" is short for Polymer; the glossary form بوليمر/بوليمري was used.
- `Billie Eilish` (u4038) -> `بيلي آيليش` — modern pop reference kept as a transliterated name.
- `Moskviches` (u4246) -> `سيارات موسكفيتش` — Soviet car brand transliterated.
- `20th Century Fox` and `Popular Mechanics` (u3953) -> kept in Latin — both are named inside instructions about how the name should/shouldn't be handled.
- `homo sovieticus` / `homo futurum` (u3982) -> kept in Latin — the passage discusses the foreign Latin term itself.
- `Wehrmacht` -> `الفيرماخت`, `Reich` -> `الرايخ`, `Third Reich` -> `الرايخ الثالث`, `Übermensch` -> `الإنسان الأعلى`, `V-2`, `NKVD`, `ENIAC`, `MORP`, `5P`, `PA-400`, `A-2`, prisoner codes (`S-230385`, `F-451`, `N-554`...) kept as-is.
- `Hemlock` (project + plant) -> `الشوكران` — one rendering used for both; no glossary entry.
- `wheatgrass, saltbush, sow-thistle` (u4011) -> `نجيل القمح والرغل والشوك الجبلي` and `ragweed, sump weed, wormwood` (u4025) -> `الرجيد وعشب المستنقعات والشيح` — botany terms with no glossary entry; standard Arabic plant names chosen.
- `litmus test` (u3998) -> `اختبار عبّاد الشمس` — established Arabic idiom.
- `hut on chicken legs` (u3948) -> `كوخ على أرجل دجاج` — folklore allusion kept literally.
- `their servos are malfunctioning` (u4062) -> `محرّكاتهنّ المؤازرة تتعطّل` — "servo" translated instead of left in Latin.
- `somethingswrong//////*+` (u3945) -> `هناك خطب ما//////*+` — the readable panic phrase is translated; the punctuation run is preserved byte-exact.
- `nervous tic` -> `حركة عصبية عرضية`; `flight risk` -> `خطر فرار` — standard institutional Arabic in HR/security records.
- Sign-offs and channels: `XOXO` -> `قبلات وأحضان`, `#villagers`/`#techstaff`/`#review_book` etc. kept as `#` + translated Arabic channel names (e.g. `#القرويون`, `#الطاقم_التقني`, `#سجل_المراجعات`).
- `HAP` / `SAD` (u3981) -> kept in Latin — the letter proposes them as telegraph-style Latin abbreviations.
- Provisional transliterations of surnames with no glossary entry (single bullet): Malakhova `مالاخوفا`, Yshtelbyev `إشتيلبييف`, Orlikova `أورليكوفا`, Debaltovskaya `ديبالتوفسكايا`, Abdurakhimov `عبد الرحيموف`, Baray-Ogla `باراي-أوغلا`, Henes `هينيس`, Svobodin `سفوبودين`, Semushev `سيموشيف`, Ilyushin `إيليوشين`, Sagdyev `ساغدييف`, Yevstigneyeva `يفستيغنييفا`, Azarova `أزاروفا`, Raguzin `راغوزين`, Vishnevskaya `فيشنيفسكايا`, Zakharchenko `زاخارتشينكو`, Kozhevin `كوجيفين`, Tormachev `تورماتشيف`, Naushkin `ناوشكين`, Zakirina `زاكيرينا`, Iosipova `يوسيبوفا`, Neyelova/Neyelov `نييلوفا`/`نييلوف`, Zommer `زومر`, Yudina `يودينا`, Yshtelbyeva `إشتيلبييفا`, Rastoropkin `راستوروبكين`, Styzhev `ستيزهيف`, Kurzin `كوزين`, Veritayev `فيريتاييف`, Sherman `شيرمان`, Grabov `غرابوف`, Lobazov `لوبازوف`, Papkin `بابكين`, Surkov `سوركوف`, Rykspert `ريكسبيرت`, Mitin `ميتين`, Savelyeva `سافيلييفا`, Chubakova `تشوباكوفا`, Notov `نوتوف`, Muravyova `مورافيوفا`, Krestovozdvizhensky `كريستوفوزدفيجينسكي`, Cherevikov `تشيريفيكوف`, Sysoyev `سيسويف`, Vorobyova `فوروبيوفا`, Gorshenev `غورشينيف`, Vladimirov `فلاديميروف`, Savin `سافين`, Kheimov `خيموف`, Kurtz `كورتز`, Ismailov `إسماعيلوف`, Haus `هاوس`, Lyubin `ليوبين`, Lepeshinova `ليبشينوفا`, Pavlovskaya `بافلوفسكايا`, Balko `بالكو`, Romashkov `روماشكوف`, Vyshegorodsky `فيشيغورودسكي`, Somin `سومين`, Lavrov `لافروف`, Kopylova `كوبيلوفا`, Budulak `بودولاك`, Gulshat `غولشات`, Koktebel `كوكتيبل`, Gagra `غاغرا`, Aldebaran `الدبران`, Yamala `يامالا`, Lake Lazur `بحيرة لازور`.
- Glossary/TM forms reused for consistency: `Sechenov` سيتشينوف, `Stockhausen` شتوكهاوزن, `Lastochkin` لاستوتشكين, `Vavilov` فافيلوف, `Pavlov` بافلوف, `Zolotukhin` زولوتوخين, `Nyukhov` نيوخوف, `Privalov` بريفالوف, `Smirnov` سميرنوف, `Yelizarova` يليزاروفا, `Mukhtarev` موختاريف, `Furman` فورمان, `Lizova` ليزوفا, `Lebedin` ليبيدين, `Klimov/Klimovs` كليموف/آل كليموف, `Chirper` تشيربر, `Academy of Consequences` أكاديمية العواقب, `Radio of the Future` راديو المستقبل, `Lighthouse` المنارة, `Natasha` ناتاشا, `Hedgie` هيدجي, `Belyash` بيلياش, `THOUGHT` and `PEAR` kept in Latin, `VOV-A6` kept in Latin.

## chunk_15_notes.md

# chunk_15 notes — uncertain choices

- Crispy critters -> `الكائنات المقرمشة` — P-3's catchphrase ("хрустящие твари"), used as an expletive; the same compound is reused in u4333 (`Crispy...` -> `المقرمش...`), u4372, u4438 and u4466 so the running joke stays recognisable.
- Chatting Artificial Librarian -> `أمين مكتبة آلي ثرثار` — the English is a backronym that spells CHARLES; Arabic cannot keep the acronym, so the meaning is translated and the Latin form `CHAR-LES` / `CHARLES` is kept verbatim where the pun itself is the point (u4332, u4345).
- Chariton Zakharov, Zakharov, Chariton Radeonovich -> `خاريتون زاخاروف`, `زاخاروف`, `خاريتون راديونوفيتش` — glossary forms.
- Spark Polymer extension -> `امتداد البوليمر «سبارك»` — no glossary entry; the name is transliterated like the sibling extension `Voskhod` -> `فوسخود` (glossary).
- THOUGHT (device) -> `THOUGHT` — kept in Latin, matching the approved pilot TM rows.
- Loops (coat check) / password "loop" -> `العروة` — the password (u4262) ties into the girls who "sew loops"; kept Arabic rather than a bare Latin word.
- Password "Fluffy" (u4475) -> `«زغبي»` — cutesy password word with no glossary entry; rendered as an Arabic adjective for consistency with `loop` above.
- Drofas -> `الدروفات` (sg. `دروفا`) — provisional transliteration of the robot type; no glossary entry.
- Hemlock -> `الشوكران` — the mutated plant of the Neyelov experiment; used consistently in u4253/u4276.
- Bullrushes -> `البردي` — the cultivation subject Lastochkin half-remembers in u4253.
- Blitzar -> `بليتزار` — provisional transliteration of the neutron-star term (u4252).
- Teardrop (u4297) -> `الدمعة` — shape/object label, matching u4399 `بشكل قطرة دمع`.
- Neptune -> `نبتون` — site name, matching the approved TM `منشأة نبتون`.
- A. Neyelova's first name "Anna" (u4284) -> `آنا`; Neyelova -> `نييلوفا` (approved TM).
- Lyubun (u4279, a typo of Lyubin) -> `ليوبين` — same person as u4266's `A. Lyubin`, so one Arabic spelling is kept.
- Kuznetsov -> `كوزنتسوف` (Commander); Schnipperson / Shniperson -> `شنيبرسون` (one spelling for the same physicist); Necheyev -> `نيتشاييف` per glossary `Nechaev`.
- DATA DELETED -> `بيانات محذوفة`; bare `DELETED` (u4285) -> `محذوف` — readable English, so translated.
- `#down_with#Sechenov`, `#robo-theater`, `#maglev #station_master`, `#3826 #Vavilov #A. Neyelova` — channel/handle tokens copied byte-exact in Latin.
- `*attachment:` (u4266), the ASCII fish `><(((~'>` (u4277), the emoticon `;)` (u4256) and the appended `*N.NN*` pacing markers are preserved byte-exact in place.
- "dickbag" (u4416) -> `وغد` — kept as a crude insult without sanitising; Arabic has no single-word equivalent that is both short and natural.
- u4465 English is broken ("What are you justifying atrocities?"); rendered as the intended question `ماذا؟ أنت تبرّر الفظائع؟`.
- Session/speaker labels in Chelomey_Dialogues translated as plain role nouns; character names (`Lida`, `Rafik`, `Romeo`, `Semyon`) transliterated.

