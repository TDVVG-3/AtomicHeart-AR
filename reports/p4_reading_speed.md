# P4.3 - subtitle clip durations and Arabic reading speed

**Generated:** 2026-10-25 23:14:55 +03:00
**Method:** English(US) Wwise bank metadata (`SoundBanksInfo...IncludedEvents[].DurationMax`) for clip length; `DT_Subtitles` `Marker` and dialogue-node `UniqueId` for key-to-event mapping; ru-RU marker ranges and EN/AR marker spacing only as fallbacks. Marker times are absolute minutes; all calculations are in seconds.

## Coverage

| item | count |
| --- | ---: |
| master rows with any marker | 539 |
| rows with Arabic markers | 537 |
| rows without Arabic markers (skipped by p11f/p11e) | 2 |
| clip duration CONFIRMED from Wwise event metadata | 506 |
| clip duration LIKELY from ru-RU explicit range end | 15 |
| clip duration UNKNOWN, estimated from marker spacing | 18 |
| subtitle pages measured | 1606 |
| pages above 17 Arabic chars/s | 390 |
| pages above 21 Arabic chars/s | 153 |

Confidence is per row, not per page. `CONFIRMED` means the exact Wwise event was found and its bank metadata gave a positive duration; `LIKELY` means the clip end came from the ru-RU explicit marker range; `UNKNOWN` means the clip end is a marker-spacing/reading-need estimate.

## Per-scope reading speed

| scope | pages | >17 | >21 |
| --- | ---: | ---: | ---: |
| Academy_Dialogues | 54 | 12 | 4 |
| Chelomey_Dialogues | 96 | 20 | 10 |
| CUTSCENES | 50 | 9 | 4 |
| DIALOGUES FOR LQA | 106 | 16 | 6 |
| Locations_dlc2 | 2 | 1 | 0 |
| OpenWorldVDNKh_Dialogues | 62 | 10 | 4 |
| Pavlov_Dialogues | 67 | 11 | 7 |
| Polygon_Dialogues | 85 | 28 | 3 |
| Schebetar_Subs | 499 | 158 | 72 |
| Schebetars_dlc1 | 182 | 51 | 19 |
| Theatre_Dialogues | 84 | 14 | 5 |
| Vavilov_Dialogues | 195 | 32 | 13 |
| VDNKh_Dialogues | 124 | 28 | 6 |

## 30 worst pages above 21 Arabic chars/s

Sorted by Arabic characters per second. `window` is the effective visible window (explicit range end when present; otherwise next page start / clip end). Duplicate-timestamp groups are subdivided and marked `estimated_duplicate_repair`.

| # | line | scope | page | chars | window s | chars/s | basis | English | Arabic |
| ---: | ---: | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 22472 | Theatre_Dialogues | 1 | 70 | 0.60 | 116.7 | duration_reinterpretation | Oh, please, spare my sides. Who is Petrov? A waste of skin that went berserk and pushed the right button? No.  | أوه، رجاءً، ارفق بجنبَيّ. من هو بيتروف؟ قطعة جلد لا نفع فيها أصابها الجنون فضغط الزر الصحيح؟ لا.  |
| 2 | 20046 | Schebetars_dlc1 | 5 | 33 | 0.60 | 55.0 | ar_markers |  &Young woman& You make it sound like geniuses are a dime a dozen!  |  &Young woman& تتحدث كأن العباقرة منتشرون هنا كالتراب!  |
| 3 | 25463 | Vavilov_Dialogues | 1 | 129 | 2.40 | 53.8 | duration_reinterpretation | The Pesticide workshop is where crucial research into crop protection is carried out. Many of the experimental crops developed in lab conditions have weakened immunity in favor of increased productivity or ease of cultivation.  | في ورشة المبيدات يُجرى بحث محوري في حماية المحاصيل. وقد اكتسبت محاصيل تجريبية كثيرة طُوّرت في ظروف مخبرية مناعة أضعف مقابل إنتاجية أعلى أو سهولة أكبر في الزراعة.  |
| 4 | 19751 | Schebetar_Subs | 6 | 30 | 0.60 | 50.0 | ru_markers |  &Elderly professor& Get out of your lab coat, Anna! Try to wriggle out! |  &Elderly professor& اخلعي معطفك يا آنا! حاولي التخلّص منها! |
| 5 | 19727 | Schebetar_Subs | 2 | 196 | 4.20 | 46.7 | ar_markers |  &Village fashionista& You know, the kind where it's one style in the morning, and then it's different in the evening, and the color changes and everything? Everybody's gonna be there for the Kollektiv update—&Village fashionista& all our bosses, and maybe even some foreigners! I don't wanna look all frumpy... oh, and grab me some Poly nail polish too, okay? |  &Village fashionista& كما تعرفين، النوع الذي يكون فيه التصفيف على حال في الصباح، ثم يختلف في المساء، ويتغير اللون وكل شيء؟ سيذهب الجميع إلى هناك من أجل تحديث كوليكتيف —&Village fashionista& كل رؤسائنا، وربما حتى بعض الأجانب! لا أريد أن أبدو مهملة... أوه، وأحضري لي أيضاً طلاء أظافر بوليمرياً، اتفقنا؟ |
| 6 | 19730 | Schebetar_Subs | 5 | 50 | 1.20 | 41.7 | ru_markers |  &Department of Corrections officer& This is the third one this year. People need to take this seriously. |  &Department of Corrections officer& هذه الحالة الثالثة هذا العام. على الناس أن يأخذوا الأمر بجدية. |
| 7 | 19751 | Schebetar_Subs | 10 | 24 | 0.60 | 40.0 | ru_markers |  &Lab assistant& Give me a tank of pesticide, I'll fuck it up! |  &Lab assistant& أعطوني أسطوانة مبيد، سأدمّرها! |
| 8 | 19714 | Schebetar_Subs | 2 | 23 | 0.60 | 38.3 | ru_markers |  &Junior engineer& You need to drop it, Andrey. Right now! |  &Junior engineer& عليك أن تتركه يا أندريه. الآن! |
| 9 | 19731 | Schebetar_Subs | 3 | 43 | 1.20 | 35.8 | ru_markers |  &Secret tour guide& Heh heh! Those capitalists sure are a weird bunch, huh? |  &Secret tour guide& هه هه! هؤلاء الرأسماليون غريبو الأطوار حقاً، أليس كذلك؟ |
| 10 | 20059 | Schebetars_dlc1 | 3 | 21 | 0.60 | 35.0 | ar_markers |  &Sanina& Spit it out, or I'm gonna lose my cool!  |  &Sanina& انطق بها، وإلا فقدت أعصابي!  |
| 11 | 19744 | Schebetar_Subs | 5 | 21 | 0.60 | 35.0 | ru_markers |  &Bykov& I'm a huge fan of your work. |  &Bykov& أنا من أشد المعجبين بعملك. |
| 12 | 291 | Chelomey_Dialogues | 1 | 124 | 3.60 | 34.4 | ru_markers | Any citizen of the USSR can obtain a THOUGHT device for free! But it gets even better: here, in our beloved Chelomey Complex, you can start using your THOUGHT device right now,  | كل مواطن في الاتحاد السوفييتي يستطيع الحصول على جهاز «الفكرة» مجاناً! لكن هناك ما هو أفضل: هنا، في مجمّع تشيلومي الحبيب، يمكنك البدء باستخدام جهاز «الفكرة» فوراً،  |
| 13 | 25348 | Vavilov_Dialogues | 1 | 61 | 1.80 | 33.9 | ar_markers | Here at the Vavilov Complex, we do a lot more than just plant fields of corn, beans, or carrots.  | هنا في مجمّع فافيلوف، نفعل أكثر بكثير من زرع حقول الذرة والفاصولياء أو الجزر.  |
| 14 | 19738 | Schebetar_Subs | 3 | 81 | 2.40 | 33.8 | ru_markers |  &Good-natured male voice& Oh, chill out! Just trying to help. You know all the mashed potatoes'll be gone and then I'll have to hear all about it. |  &Good-natured male voice& أوه، اهدأ! أنا أحاول المساعدة فحسب. أتعلم أن البطاطس المهروسة كلها ستنتهي، ثم سأضطر إلى سماع كل الشكوى. |
| 15 | 20070 | Schebetars_dlc1 | 2 | 20 | 0.60 | 33.3 | ar_markers |  &Lyova& Shura, you and I are chemists, right?  |  &Lyova& شورا، نحن كيميائيان، صحيح؟  |
| 16 | 19697 | Schebetar_Subs | 3 | 40 | 1.20 | 33.3 | ru_markers |  &Excited female voice& Here's a piece! Robots can't appreciate it the way we do. |  &Excited female voice& ها هي مقطوعة! لا يمكن للروبوتات أن تقدّرها كما نفعل. |
| 17 | 19682 | Schebetar_Subs | 5 | 80 | 2.40 | 33.3 | ru_markers |  &Lastochkin& "All in the name of man, for the good of man!" And these men need to walk out of here with smiles on their faces! |  &Lastochkin& «كل شيء باسم الإنسان، ومن أجل خير الإنسان!» وهؤلاء الرجال يجب أن يخرجوا من هنا والابتسامات على وجوههم! |
| 18 | 19725 | Schebetar_Subs | 4 | 79 | 2.40 | 32.9 | ru_markers |  &Mikhalych& I was fightin' for equality, so everybody could have the same rights and responsibilities! So everybody could be like everybody else! |  &Mikhalych& كنت أقاتل من أجل المساواة، كي يحصل الجميع على الحقوق والواجبات ذاتها! كي يصبح الجميع مثل أي شخص آخر! |
| 19 | 19736 | Schebetar_Subs | 5 | 158 | 4.80 | 32.9 | ru_markers |  &Computer voice& The pleasant gray walls help them focus on work, and the lack of sharp corners reduces the risk of injury.*0.-39.50* &Computer voice& The desks, shelves, and bookcases are constructed from an aluminum alloy, making them durable, but still light and easy to move. |  &Computer voice& الجدران الرمادية المحبّبة تساعدهم على التركيز في العمل، وغياب الزوايا الحادة يقلّل خطر الإصابة.*0.-39.50* &Computer voice& أما المكاتب والرفوف والخزائن فمصنوعة من سبيكة ألومنيوم، ما يجعلها متينة لكنها خفيفة وسهلة النقل. |
| 20 | 24844 | Vavilov_Dialogues | 1 | 57 | 1.80 | 31.7 | ar_markers | There's the control panel. And of course, it's locked! You guys just love these things, don't you?  | ها هي لوحة التحكم. وبالطبع، إنها مقفلة! أنتم تحبون هذه الأشياء، أليس كذلك؟  |
| 21 | 20062 | Schebetars_dlc1 | 3 | 19 | 0.60 | 31.7 | ar_markers |  &Skeptic& And what does this have to do with it?  |  &Skeptic& وما علاقة ذلك بالموضوع؟  |
| 22 | 26924 | VDNKh_Dialogues | 2 | 57 | 1.80 | 31.7 | duration_reinterpretation | Someone's gotta take responsibility. The buck has to stop somewhere, right?  | لا بد أن يتحمل أحدهم المسؤولية. ويجب أن تنتهي المسؤولية عند أحدهم، صحيح؟  |
| 23 | 19768 | Schebetar_Subs | 8 | 19 | 0.60 | 31.7 | ru_markers |  &Private& Yes, Comrade Colonel. |  &Private& نعم، أيها الرفيق العقيد. |
| 24 | 19714 | Schebetar_Subs | 5 | 19 | 0.60 | 31.7 | ru_markers |  &Engineer& Then we'll kill ourselves, Igor! |  &Engineer& فسنقتل أنفسنا يا إيغور! |
| 25 | 19764 | Schebetar_Subs | 4 | 19 | 0.60 | 31.7 | ru_markers |  &Lastochkin& I'll make it worth your while, of course. |  &Lastochkin& وسأردّ لك الجميل بالطبع. |
| 26 | 19737 | Schebetar_Subs | 8 | 37 | 1.20 | 30.8 | ru_markers |  &Petrov& But that's enough... we've talked about this a hundred times, and you still don't believe me.  |  &Petrov& لكن كفى... تحدّثنا في هذا مئة مرة، وما زلت لا تصدّقني.  |
| 27 | 19682 | Schebetar_Subs | 2 | 74 | 2.40 | 30.8 | ru_markers |  &Stepan& Stefan! My name is Stefan, not Stepan! And what exactly have I gone overboard from, Maris-Rudolph? The ship of decency? |  &Stepan& ستيفان! اسمي ستيفان، لا ستيبان! ومن أي سفينة بالضبط تجاوزتُ الحد يا ماريس-رودولف؟ سفينة الوقار؟ |
| 28 | 19708 | Schebetar_Subs | 3 | 36 | 1.20 | 30.0 | ru_markers |  &Fyodor Surkov& It's okay, Konstantin, we get it. Have a seat. |  &Fyodor Surkov& لا بأس يا كونستانتين، نحن نتفهّم. تفضّل بالجلوس. |
| 29 | 20061 | Schebetars_dlc1 | 13 | 18 | 0.60 | 30.0 | ar_markers |  &Backpack& I've got it on a chirper. Why?  |  &Backpack& عندي على تشيربر. لماذا؟  |
| 30 | 20061 | Schebetars_dlc1 | 6 | 18 | 0.60 | 30.0 | ar_markers |  &Bloodhound& Hold on, guys... Wait a minute...  |  &Bloodhound& انتظروا يا جماعة... لحظة...  |

## Artifacts

- `build/p4/clip_durations.tsv` - row-level clip length, last-page start, last-page remaining seconds, confidence and evidence.
- `build/p4/subtitle_pages.tsv` - every Arabic page with its window, Arabic letter count and chars/s.
- `reports/p4_reading_speed.md` - this report.

