# Tone pass - cycle 013 (2026-10-19)

Standing style rule: `glossary/terminology.md` section 12 (spoken-register MSA, one voice per
character, never soften). Requested by the user after the p7 in-game check.

Totals: 31 rules, 40 master rows changed, in 4 scopes.

Method: every already-translated row was matched against a marker list for stiff / polite /
literary wording ("as you know", "would you care for", "isn't it", "I would like to",
"it should be", "please", "I am pleased to hear", "I am of the age that", "I do not wish for",
"however", "from my duty to bring to your attention", formal imperatives). Candidates were
compared with the RUSSIAN source (exported from the shipped ru-RU locres,
`scripts/export_ru_reference.ps1`) so the register comes from the original, not from the
English alone. Rows whose source really is an official letter keep the official formula.
Every change lives in `localization/working/tm_fixups.tsv` (KI-021), was applied by
`scripts/apply_text_fixups.ps1` and is proven by `scripts/verify_text_fixups.ps1` (PASS).

Order below = game progression, so the prologue and Chelomey come first.

| # | scope | key | speaker | before | after | why |
|---|-------|-----|---------|--------|-------|-----|
| 1 | Chelomey_Dialogues | /50C4A47C40D3D7C6E615DA8DB827DAAB | Dialogue | يا روبوت! طلب آخر من فضلك! | يا روبوت! نريد طلباً آخر! |  RU "можно нам добавки!" -> direct request |
| 2 | Chelomey_Dialogues | /78178A064413D8446C6B2CB50CD08CB8 | Dialogue | يسعدني سماع ذلك! ولا تقلق، حتى لو صارت الروبوتات لا غنى عنها، فالبشر هم ما يهم حقاً. | هذا رائع! ولا تقلق، حتى لو صارت الروبوتات لا غنى عنها، فالبشر هم الأهم حقاً. |  "يسعدني سماع ذلك" = letter-speak -> "هذا رائع" |
| 3 | Chelomey_Dialogues | /3038A284489C584962BCF1A4459BFE31 | Dialogue | يا لي، هذا لذيذ! إنه من مجمع فافيلوف، صحيح؟ | هذا لذيذ! من مجمع فافيلوف، صحيح؟ |  "يا لي" was a calque of "My,"; removed |
| 4 | Chelomey_Dialogues | /854B4E4C43CE3D8FEDDC7F9276E36A90 | Dialogue | أيها الرفيق! أيها الرفيق، هل يمكنك مساعدتي؟ كنت في جولة وانفصلت عن مجموعتي... | أيها الرفيق! ساعدني، أرجوك؟ كنت في جولة وانفصلت عن مجموعتي... |  RU "помогите мне, пожалуйста?" -> direct plea, keeps the ellipsis |
| 5 | Chelomey_Dialogues | /7773154A4086F9163BD6CF9D2BE55E76 | Dialogue | ذلك الروبوت مثير حقاً، أليس كذلك؟ | انظر إلى ذلك الروبوت، هاه! ماذا يفعل! |  RU "Ты посмотри на этого робота, а? Что делает!" |
| 6 | Chelomey_Dialogues | /CC378EE14B69337258EE5D89A93308EB | Dialogue | حسناً، يوم الاثنين مؤكد. لكن غداً هو ما يقلقني. عليّ غسل الملابس. ينبغي أن أتحقق من توقعات الطقس. | حسناً، الاثنين مضمون. لكن غداً هو ما يقلقني. عليّ غسل الملابس، وعليّ أن أنظر في توقعات الطقس. |  "ينبغي أن" -> "عليّ أن" (RU "Надо ... посмотреть") |
| 7 | Chelomey_Dialogues | /8004730D44B4B56AC42225B571BF8C96 | Dialogue | هذا غريب... عطل آخر في العتاد، ربما؟ ينبغي أن أتحقق منه. | هذا غريب... عطل آخر في العتاد، ربما؟ عليّ أن أتفقّده. |  "ينبغي أن أتحقق منه" -> "عليّ أن أتفقّده" |
| 8 | Chelomey_Dialogues | /CBC991014757071641DA23BB8DFFFBB5 | Dialogue | ألا ترى نفسك كبيراً على مكالمات المقالب أيها الرائد؟ | مقالب مراهقين، أيها الرائد؟ أما كبرت على هذا؟ |  RU "Ну что за подростковые шутки, майор?" -> sarcastic question, not a formal one |
| 9 | Chelomey_Dialogues | /C76FE5CF4CB47AD3A4060F96F27D9F18 | Dialogue | لكنني أرغب في أن أكون جزءاً من الجماعة! | لكنني أريد أن أكون جزءاً من كوليكتيف! |  "أرغب في" -> "أريد"; RU "влиться в Коллектив" -> glossary Kollektiv = كوليكتيف |
| 10 | Chelomey_Dialogues | /DB2E68EB49C4B165C693DC848D19F707 | Dialogue | يسعدني أنك لا تملك أي أسئلة... ولأول مرة. | يسرّني أنك لا تسأل شيئاً... ولو لمرة واحدة. |  Sechenov stays pompous, but "لا تملك أي أسئلة" is bureaucratic padding |
| 11 | Chelomey_Dialogues | /596096DA403A22251AA6739F029D0F29 | Dialogue | أتدري، أود أن أقود صاروخاً إلى الشِعرى. | أتدري؟ يا ليتني أقود صاروخاً إلى الشِعرى! |  RU "Вот бы тоже повести ракету" = wish, not "I would like to" |
| 12 | Chelomey_Dialogues | /CEE5BE4B4A1C4CF73F61948A3B4199F1 | Dialogue | الروبوت صديق الإنسان الوفيّ، أليس كذلك؟ مثير للاهتمام... أنا في سنٍّ تجعلني أتذكر حين طرح سيتشينوف هذه الفكرة قبل الحرب. | الروبوت صديق الإنسان الوفيّ، هاه؟ شيء مثير... أنا كبير بما يكفي لأتذكّر حين طرح سيتشينوف هذه الفكرة قبل الحرب. |  "eh?" = هاه; dropped the literary "أنا في سنٍّ تجعلني" |
| 13 | Chelomey_Dialogues | /E88AEA6244C8D2FDC686A38E266BE551 | Dialogue | هل ترغب بمزيد من الغازية، أيها الرفيق؟ | تريد صودا يا رفيقي العزيز؟ |  RU "газировки не желаете?" -> soda = صودا (DEC-034) and spoken register (terminology 12.1) |
| 14 | Chelomey_Dialogues | /7C422ACA4BB9C22516F8AABE667C72CA | Dialogue | أعتذر بشدة أيها الرفيق، لكن جميع الطاولات محجوزة بالفعل. عد لاحقاً من فضلك. | المعذرة يا رفيق، لكن كل الطاولات محجوزة. تعال في وقت لاحق. |  robot waiter stays polite but stops sounding like a form letter |
| 15 | Chelomey_Dialogues | /861CE9D24A0C006A1981579E37E39BA2 | Dialogue | مذهل، أليس كذلك؟ | مذهل، هاه؟ |  RU "Как крутит-то, а?" -> short spoken tag |
| 16 | Chelomey_Dialogues | /397EF83A4374ACC83D5DE99F7A1DEF7F | Dialogue | عد لاحقاً من فضلك. يُتوقع انخفاض الطلب التالي بعد: خمس ساعات وأربعين دقيقة. | تعال في وقت لاحق. يُتوقع أن يقل الطلب بعد: خمس ساعات وأربعين دقيقة. |  robot waiter; "من فضلك" dropped, plain request |
| 17 | Chelomey_Dialogues | /5D4189774F3212D82A3997A6F821D8BD | Dialogue | جميل، أليس كذلك؟ كنت أحتفظ به لهذا اليوم. | أليس جميلاً؟ احتفظت به خصيصاً لهذا اليوم. |  RU "Правда красивое? Специально для праздника берегла!" |
| 18 | Chelomey_Dialogues | /436CD7AB4D55779F56DE66976B567C62 | Dialogue | عجائب العلم الحديث، أليس كذلك؟ | عجائب العلم الحديث، هاه؟ |  RU "До чего техника дошла!" -> short spoken tag |
| 19 | Chelomey_Dialogues | /D55B90F54556BD1468DB73B5C7AEB8F5 | Dialogue | هل يمكنك أن ترينا الصورة؟ | أرِنا كيف طلعت الصورة! |  RU "покажите нам, что вышло!" -> direct imperative |
| 20 | Academy_Dialogues | /F0653AB5470ED52E4F3044B98BD37D1F | Dialogue | حسناً... لقد مررنا بالكثير. لديّ مشاعر، كما تعلم... فأنا حيّ وما إلى ذلك. وهو أيضاً لديه مشاعر. | حسناً... مررنا بالكثير. ولديّ مشاعر، تدري... فأنا حيّ في النهاية. وهو أيضاً لديه مشاعر. |  "ومما إلى ذلك" padding removed, "كما تعلم" -> "تدري" |
| 21 | Academy_Dialogues | /B39B10434DD1F18D32CA729E1FEE922C | Dialogue | أنا بخير. رأسي يؤلمني بشدة في الآونة الأخيرة. وبدأت أرى أشياء. هذه وظيفة جحيمية، دعني أخبرك... | أنا بخير. رأسي يؤلمني بشدة منذ فترة. وأرى أشياء. وهذه وظيفة جحيمية، صدّقني... |  RU "Башка гудит ... Работа, сама понимаешь, нервная..." -> plain speech |
| 22 | Academy_Dialogues | /743B09324DF844DD6C04CA8BC3BBBC77 | Dialogue | كما تعلم، الإرادة الحرة لا تضمن ألّا يكون المرء حقيراً... | تدري، الإرادة الحرة لا تضمن ألّا يكون المرء حقيراً... |  RU "Знаешь" -> "تدري" |
| 23 | Academy_Dialogues | /8EA0C3CA470F9E08850C2DA025FD174E | Dialogue | *0.08*تحاول أن تجعلني أحمق، أليس كذلك؟ حسناً، مرحباً بك في النادي! لا تملك أيّ بيانات، هاه؟! *0.08*لطالما كنت تعرف كل هذا. وهناك سبب لتسميتك CHAR-LES، أليس كذلك؟ أنت خاريتون زاخاروف، يا ابن العاهرة! ألديك تفسير؟ هاه؟! | *0.08*تحاول أن تصنع مني أحمق، هاه؟ حسناً، انضم إلى النادي! لا تملك أيّ بيانات، هاه؟! *0.08*كنت تعرف كل هذا طوال الوقت. وليس عبثاً أنك تُدعى CHAR-LES، صحيح؟ أنت خاريتون زاخاروف، يا ابن العاهرة! فما تفسيرك؟ هاه؟! |  P-3 rant; RU is much cruder, the Arabic keeps the insult and the two *0.08* tags untouched |
| 24 | PearTerminals | /38229DC143F8191ED39B08A7907B39A7 | UI | تعال إلى هنا حالًا من فضلك، هناك خطب ما//////*+ | تعال إلى هنا حالاً، هناك خطب ما//////*+ |  panicked letter, "من فضلك" dropped; the //////*+ tail is untouched |
| 25 | PearTerminals | /B99B80684F87EB6CCEF7328E252E95EE | UI | مياه غازية، 200 لتر | صودا، 200 لتر |  RU "Газировка — 200 литров" in the museum order list -> صودا (DEC-034) |
| 26 | NewP5 | /2932B4ED4C2E5D96ECFD508D97013216 | UI | أغراض تافهة لا فائدة منها، ومع ذلك يمكن إعادة استخدامها في التصنيع. | خردة لا قيمة لها، لكن يمكن إعادة استخدامها في التصنيع. |  RU "Хлам, но может пригодиться" (6 rows) -> "خردة", spoken |
| 27 | NewP5 | /36EDE7BE4CE8520ED0D8CAADAD561E71 | UI | أغراض تافهة لا فائدة منها، ومع ذلك يمكن إعادة استخدامها في التصنيع. | خردة لا قيمة لها، لكن يمكن إعادة استخدامها في التصنيع. |  RU "Хлам, но может пригодиться" (6 rows) -> "خردة", spoken |
| 28 | NewP5 | /3B6CD129449B69736703D6A81A44EBA2 | UI | أغراض تافهة لا فائدة منها، ومع ذلك يمكن إعادة استخدامها في التصنيع. | خردة لا قيمة لها، لكن يمكن إعادة استخدامها في التصنيع. |  RU "Хлам, но может пригодиться" (6 rows) -> "خردة", spoken |
| 29 | NewP5 | /98FF71B34322E0E931FA4B97790621B9 | UI | أغراض تافهة لا فائدة منها، ومع ذلك يمكن إعادة استخدامها في التصنيع. | خردة لا قيمة لها، لكن يمكن إعادة استخدامها في التصنيع. |  RU "Хлам, но может пригодиться" (6 rows) -> "خردة", spoken |
| 30 | NewP5 | /CE2388B646A39AE957FA4395B366A272 | UI | أغراض تافهة لا فائدة منها، ومع ذلك يمكن إعادة استخدامها في التصنيع. | خردة لا قيمة لها، لكن يمكن إعادة استخدامها في التصنيع. |  RU "Хлам, но может пригодиться" (6 rows) -> "خردة", spoken |
| 31 | NewP5 | /F7B417EA4520F7F129FB318BECE0DF58 | UI | أغراض تافهة لا فائدة منها، ومع ذلك يمكن إعادة استخدامها في التصنيع. | خردة لا قيمة لها، لكن يمكن إعادة استخدامها في التصنيع. |  RU "Хлам, но может пригодиться" (6 rows) -> "خردة", spoken |
| 32 | NewP5 | /356122584F4A6277DFA2AD950B948CB3 | UI | الحديث مع الموتى خيار شخصي. ومع ذلك، هم عادةً مباشرون في كلامهم. ويُقال إن التجربة نفسها لا تُنسى. | الكلام مع الموتى مسألة شخصية. لكنهم عادةً لا يقولون إلا المفيد. والتجربة نفسها، كما يُقال، لا تُنسى. |  RU "мертвые не говорят лишнего" -> "لا يقولون إلا المفيد" |
| 33 | NewP5 | /9BDBC66148FEF2972EB13EBF548F6C9D | UI | الحديث مع الموتى خيار شخصي. ومع ذلك، هم عادةً مباشرون في كلامهم. ويُقال إن التجربة نفسها لا تُنسى. | الكلام مع الموتى مسألة شخصية. لكنهم عادةً لا يقولون إلا المفيد. والتجربة نفسها، كما يُقال، لا تُنسى. |  RU "мертвые не говорят лишнего" -> "لا يقولون إلا المفيد" |
| 34 | NewP5 | /EEBEA1B440E50F6850215F83E7CBB953 | UI | لا أبتغي مجتمعاً لا أستطيع فيه فعل الشرّ، بل مجتمعاً أستطيع فيه فعل كل صنوف الشرّ، لكنني لا أرغب في ذلك. | لا أريد مجتمعاً لا أستطيع فيه فعل الشرّ، بل مجتمعاً أستطيع فيه فعل كل صنوف الشرّ، لكنني لا أريد أن أفعله بنفسي. |  "أبتغي/أرغب في" are literary -> "أريد" (RU "но не хотел его делать сам") |
| 35 | NewP5 | /3CCC6DA0454F59DD0B5D10958827B69B | UI | أجل يا رائد، أنت شخص موهوب جداً! ومع ذلك، أنصحك بألّا تقفز من علوّ شاهق. وإلا فقد تجد حتى أنت أن لذّة السقوط الحرّ غير العقلانية قاتلة. | أجل يا رائد، أنت موهوب جداً! لكن لا تقفز من علوّ شاهق. وإلا فقد تجد حتى أنت أن متعة السقوط الحرّ غير العقلانية قاتلة. |  Char-les; "ومع ذلك، أنصحك" -> "لكن لا", "لذّة" -> "متعة" |
| 36 | NewP5 | /D6085F114AB5885F9E5195BF38A67A70 | UI | أجل يا رائد، أنت شخص موهوب جداً! ومع ذلك، أنصحك بألّا تقفز من علوّ شاهق. وإلا فقد تجد حتى أنت أن لذّة السقوط الحرّ غير العقلانية قاتلة. | أجل يا رائد، أنت موهوب جداً! لكن لا تقفز من علوّ شاهق. وإلا فقد تجد حتى أنت أن متعة السقوط الحرّ غير العقلانية قاتلة. |  Char-les; "ومع ذلك، أنصحك" -> "لكن لا", "لذّة" -> "متعة" |
| 37 | NewP5 | /59259C8D411F0A2FB3CF0A9E9D7336AC | UI | لا يوجد خيار لتخطّي هذه النصائح. ومع ذلك، فاتباعها — أو عدمه — متروك لك تماماً. | لا سبيل لتخطّي هذه النصائح. أما اتباعها — أو تجاهلها — فهو قرارك أنت. |  NORA; RU "Однако следовать им или нет — это ваше личное уважаемое решение"; dashes kept |
| 38 | NewP5 | /B06995924CB0C651F8693FB548EB46DD | UI | لا يوجد خيار لتخطّي هذه النصائح. ومع ذلك، فاتباعها — أو عدمه — متروك لك تماماً. | لا سبيل لتخطّي هذه النصائح. أما اتباعها — أو تجاهلها — فهو قرارك أنت. |  NORA; RU "Однако следовать им или нет — это ваше личное уважаемое решение"; dashes kept |
| 39 | NewP5 | /870FCD564A26F6ADB20F5D8497686769 | UI | ومع ذلك، لا تدع نظريات المؤامرة تتغلّب عليك. استرخِ ببساطة واستمتع بالموسيقى. | لكن لا تدع نظريات المؤامرة تتغلّب عليك. استرخِ واستمتع بالموسيقى. |  shorter, spoken |
| 40 | NewP5 | /D140A3284F84FF64E47E0480C854ADBA | UI | ومع ذلك، لا تدع نظريات المؤامرة تتغلّب عليك. استرخِ ببساطة واستمتع بالموسيقى. | لكن لا تدع نظريات المؤامرة تتغلّب عليك. استرخِ واستمتع بالموسيقى. |  shorter, spoken |

## Checked and deliberately left alone

- PearTerminals / Mails official letters: the Russian is itself bureaucratic
  (see the ru-RU export), so the Arabic official formula is the correct register, not
  stiffness. Only the panicked hand-typed letter was relaxed.
- System/UI prompts ("Please wait", "Please provide device data"): the Russian is a system
  message, so the standard Arabic UI "please" form stays.
- False positives on the word list were skipped: "sparkling wit", "SATURATION", "sodalis"
  (lorem ipsum) and Russian "gas turbines" (turbiny gazovyye) have nothing to do with the drink.
- The semantic check of every drink row is in `glossary/glossary_questions.md` section G.
