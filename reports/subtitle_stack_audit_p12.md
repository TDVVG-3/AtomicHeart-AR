# Subtitle stack audit - H1 / H2 / H3 / H4

Generated: 2026-10-28 14:09:05 +03:00
Master: `build\variants\atomic-heart-ar_p12.tsv`
Stock tables: 31 | rows: 8853 | unmatched keys: 4790

Mapping note: 4790 of 8853 stock rows could not be joined to a master locres key. H1m, H1k and H4 are stock DataTable checks independent of Arabic. H1t, H2 and H3 are assessed only where a master Arabic cell was found; unmatched rows keep their table name as the scope label.

| hypothesis | rows | meaning |
| --- | ---: | --- |
| H1 marker duplicate in table | 36 | same Wwise marker used by more than one row in the same DataTable |
| H1 key duplicate in table | 15 | same locres sentence key used by more than one row in the same DataTable |
| H1 duplicate marker start in cell | 72 | same page start timestamp repeated inside one Arabic cell |
| H2 end overlaps next start | 17 | explicit range end >= the next page start in the same cell |
| H3 final singleton + following scene row | 2953 | final page has no end and another line follows in the same scene |
| H4 stock cross-table marker/key reuse | 3 | marker or key reused in another stock DataTable |

## Per scope

| scope | rows | H1m | H1k | H1t | H2 | H3 | H4 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Academy_Dialogues | 58 | 0 | 0 | 13 | 0 | 38 | 0 |
| Chelomey | 1 | 0 | 0 | 0 | 0 | 0 | 1 |
| Chelomey_Dialogues | 559 | 0 | 0 | 14 | 0 | 457 | 0 |
| ChelomeyFinal_Dialogues | 107 | 0 | 0 | 0 | 0 | 56 | 0 |
| CUTSCENES | 441 | 0 | 0 | 5 | 0 | 410 | 0 |
| Cutscenes_dlc1 | 99 | 0 | 0 | 0 | 0 | 84 | 0 |
| DLC01_Goose | 119 | 12 | 15 | 0 | 0 | 0 | 0 |
| DLC02_Climber | 95 | 0 | 0 | 0 | 0 | 0 | 0 |
| DLC02_GooseRunner | 421 | 0 | 0 | 0 | 0 | 0 | 0 |
| DLC02_Schebetars | 188 | 0 | 0 | 0 | 0 | 0 | 0 |
| DLC02_Slider | 252 | 6 | 0 | 0 | 0 | 0 | 0 |
| DLC03_Chelomey | 393 | 0 | 0 | 0 | 0 | 0 | 0 |
| DLC03_Intro | 24 | 0 | 0 | 0 | 0 | 0 | 0 |
| DLC03_Sakhalin | 173 | 0 | 0 | 0 | 0 | 0 | 0 |
| DLC03_Schebetars | 187 | 0 | 0 | 0 | 0 | 0 | 0 |
| DLC03_Triton | 922 | 10 | 0 | 0 | 0 | 0 | 0 |
| DLC04_Schebetars | 298 | 0 | 0 | 0 | 0 | 0 | 0 |
| DLC4_Beach | 103 | 0 | 0 | 0 | 0 | 0 | 0 |
| DLC4_CrystalComplex | 839 | 0 | 0 | 0 | 0 | 0 | 0 |
| DLC4_LebedevLab | 88 | 0 | 0 | 0 | 0 | 0 | 1 |
| DLC4_Phasatron | 466 | 0 | 0 | 0 | 0 | 0 | 0 |
| DLC4_WavePlatform | 220 | 0 | 0 | 0 | 0 | 0 | 0 |
| Mails_Shebetars_dlc4 | 10 | 0 | 0 | 0 | 0 | 9 | 0 |
| Marshes_dlc1 | 140 | 4 | 0 | 0 | 0 | 100 | 0 |
| Mendeleev_dlc1 | 273 | 0 | 0 | 0 | 0 | 134 | 0 |
| OpenWorldVDNKh_Dialogues | 140 | 0 | 0 | 2 | 0 | 120 | 0 |
| Pavlov | 1 | 0 | 0 | 0 | 0 | 0 | 1 |
| Pavlov_Dialogues | 237 | 0 | 0 | 14 | 0 | 206 | 0 |
| Phasatron_dlc4 | 1 | 0 | 0 | 0 | 0 | 1 | 0 |
| Polygon_Dialogues | 109 | 0 | 0 | 15 | 0 | 80 | 0 |
| Schebetar_Subs | 95 | 0 | 0 | 0 | 53 | 0 | 0 |
| Schebetars_dlc1 | 39 | 0 | 0 | 0 | 6 | 0 | 0 |
| Theatre_Dialogues | 171 | 0 | 0 | 3 | 0 | 141 | 0 |
| Vavilov_Dialogues | 1069 | 4 | 0 | 16 | 0 | 741 | 0 |
| VDNKh_Dialogues | 515 | 0 | 0 | 5 | 0 | 376 | 0 |

## 30 worst scenes

Score = H1m + H1k + H1t + H2 + H3 + H4. Scene is the marker prefix with the trailing character and line number removed.

| # | scene | table | rows | H1m | H1k | H1t | H2 | H3 | H4 | score |
|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | VO_D_0133 | DT_Subtitles_Cutscenes.tsv | 45 | 0 | 0 | 2 | 0 | 44 | 0 | 46 |
| 2 | VO_SP_Vavilov | DT_Subtitles_Vavilov.tsv | 42 | 0 | 0 | 0 | 0 | 41 | 0 | 41 |
| 3 | VO_SP_Theatre | DT_Subtitles_Theatre.tsv | 37 | 0 | 0 | 1 | 0 | 36 | 0 | 37 |
| 4 | VO_SP_Begin_Raf | DT_Subtitles_Chelomey.tsv | 37 | 0 | 0 | 0 | 0 | 36 | 0 | 36 |
| 5 | VO_CS_01_29 | DT_Subtitles_Cutscenes.tsv | 33 | 0 | 0 | 0 | 0 | 32 | 0 | 32 |
| 6 | VO_CS_01_09 | DT_Subtitles_Cutscenes.tsv | 30 | 0 | 0 | 0 | 0 | 29 | 0 | 29 |
| 7 | VO_CS_01_35 | DT_Subtitles_Cutscenes.tsv | 30 | 0 | 0 | 0 | 0 | 29 | 0 | 29 |
| 8 | VO_SP_Begin | DT_Subtitles_Chelomey.tsv | 29 | 0 | 0 | 0 | 0 | 28 | 0 | 28 |
| 9 | VO_CS_01_50 | DT_Subtitles_Cutscenes.tsv | 28 | 0 | 0 | 1 | 0 | 27 | 0 | 28 |
| 10 | VO_SP_Begin_ChelomeyCrowd | DT_Subtitles_Chelomey.tsv | 28 | 0 | 0 | 0 | 0 | 27 | 0 | 27 |
| 11 | VO_DLC1_Goose | DT_Subtitles_DLC01_Goose.tsv | 91 | 12 | 15 | 0 | 0 | 0 | 0 | 27 |
| 12 | VO_VA_Begin_FlightFirstPart | DT_Subtitles_Chelomey.tsv | 27 | 0 | 0 | 0 | 0 | 26 | 0 | 26 |
| 13 | VO_CS_01_23 | DT_Subtitles_Cutscenes.tsv | 26 | 0 | 0 | 1 | 0 | 25 | 0 | 26 |
| 14 | VO_CS_01_02 | DT_Subtitles_Cutscenes.tsv | 25 | 0 | 0 | 0 | 0 | 24 | 0 | 24 |
| 15 | VO_CS_01_15 | DT_Subtitles_Cutscenes.tsv | 25 | 0 | 0 | 0 | 0 | 24 | 0 | 24 |
| 16 | VO_CS_01_34 | DT_Subtitles_Cutscenes.tsv | 24 | 0 | 0 | 0 | 0 | 23 | 0 | 23 |
| 17 | VO_SP_VDNH | DT_Subtitles_VDNH.tsv | 23 | 0 | 0 | 0 | 0 | 22 | 0 | 22 |
| 18 | VO_SP_Marshes_SolvingLabDeactivation | DT_Subtitles_DLC01_Marshes.tsv | 23 | 0 | 0 | 0 | 0 | 22 | 0 | 22 |
| 19 | VO_SP_Begin_PhotoTereshkova_PhotoMan | DT_Subtitles_Chelomey.tsv | 22 | 0 | 0 | 0 | 0 | 21 | 0 | 21 |
| 20 | VO_CS_01_45 | DT_Subtitles_Cutscenes.tsv | 22 | 0 | 0 | 0 | 0 | 21 | 0 | 21 |
| 21 | VO_VA_Vavilov_GreetingsEleanore | DT_Subtitles_Vavilov.tsv | 22 | 0 | 0 | 0 | 0 | 21 | 0 | 21 |
| 22 | VO_VA_Hospital_KhrazInsistsRings | DT_Subtitles_Pavlov.tsv | 20 | 0 | 0 | 1 | 0 | 19 | 0 | 20 |
| 23 | VO_VA_Theatre_FinalDialogue | DT_Subtitles_Theatre.tsv | 20 | 0 | 0 | 1 | 0 | 19 | 0 | 20 |
| 24 | VO_CS_01_28 | DT_Subtitles_Cutscenes.tsv | 21 | 0 | 0 | 0 | 0 | 20 | 0 | 20 |
| 25 | VO_VA_Vavilov_BorschevikRoomGotTankScene | DT_Subtitles_Cutscenes.tsv | 21 | 0 | 0 | 0 | 0 | 20 | 0 | 20 |
| 26 | VO_VA_Marshes_SolvingLabDeactivation | DT_Subtitles_DLC01_Marshes.tsv | 20 | 0 | 0 | 0 | 0 | 19 | 0 | 19 |
| 27 | VO_VA_Pavlov_MainDialogue_04 | DT_Subtitles_Pavlov.tsv | 15 | 0 | 0 | 3 | 0 | 14 | 0 | 17 |
| 28 | VO_SP_Academy | DT_Subtitles_Schebetars.tsv | 3 | 0 | 0 | 0 | 17 | 0 | 0 | 17 |
| 29 | VO_SP_LIMBO2 | DT_Subtitles_Pavlov.tsv | 16 | 0 | 0 | 2 | 0 | 15 | 0 | 17 |
| 30 | VO_VA_VDNH_MainDialogue_05 | DT_Subtitles_VDNH.tsv | 17 | 0 | 0 | 0 | 0 | 16 | 0 | 16 |

## Screenshot scene: VO_CS_01_15

| order | line | key | marker | speaker | markers | clip s | final singleton | following in scene | cps | English | Arabic |
|---:|---:|---|---|---|---|---:|---|---|---:|---|---|
| 1 | 4228 | `/CF1A66AD482DFA9D03DF86BA88FBF13E` | VO_CS_01_15_Larisa_01 | Filatova | 0 | 3.764 | True | yes | 6.9 | Are you okay? Is everything ready? Did you pull it off? | هل أنتِ بخير؟ هل كل شيء جاهز؟ هل نجحتِ؟ |
| 2 | 4291 | `/CA8AF8514C76D3525CB05782384B45DF` | VO_CS_01_15_Victor_02 | Petrov | 0 | 5.207 | True | yes | 9.0 | Don't worry, honey, I'm right as rain. The operation was totally painless. | لا تقلق يا عزيزي، أنا في أحسن حال. كانت العملية بلا ألم تماماً. |
| 3 | 4474 | `/3998BD2D45C3CC56576575AB48DC4BD0` | VO_CS_01_15_Larisa_03 | Filatova | 0 | 7.781 | True | yes | 8.9 | Good. You need to leave right now. There's a man coming for you, he's armed and wearing an experimental Polymer glove. | جيد. عليكِ أن ترحلي الآن فوراً. هناك رجل قادم من أجلك، وهو مسلّح ويرتدي قفاز بوليمر تجريبياً. |
| 4 | 4186 | `/60F798D848972F1DC5ECF3AE1AF3E419` | VO_CS_01_15_Victor_04 | Petrov | 0 | 4.721 | True | yes | 7.4 | Must be Sechenov's guy. Larisa, did you talk to him? | لا بد أنه رجل سيتشينوف. لاريسا، هل تحدثتِ إليه؟ |
| 5 | 4279 | `/E8636ED640BCA8E848438C9951866CB4` | VO_CS_01_15_Larisa_05 | Filatova | 0 | 8.749 | True | yes | 7.3 | He was attacked by a Burav. We took him to the infirmary, and then... I didn't know... I couldn't just let him bleed ... | هاجمه بوراف. أخذناه إلى المستوصف، ثم... لم أكن أعلم... لم أستطع أن أتركه ينزف حتى الموت. |
| 6 | 4068 | `/A2918A4D4461784F58BE8894BCC99CC9` | VO_CS_01_15_Victor_06 | Petrov | 0 | 6.093 | True | yes | 5.1 | Well, you should have—it would've saved us a whole lot of trouble! | كان عليكِ ذلك—كان سيوفر علينا متاعب جمة! |
| 7 | 4266 | `/920C0298464B98C0C4A81B9F01F1498B` | VO_CS_01_15_Larisa_07 | Filatova | 0 | 3.202 | True | yes | 5.3 | It scares me when you talk like that. | يخيفني أن تتحدث هكذا. |
| 8 | 4197 | `/93A698D6458088CE93329C99495E6EBA` | VO_CS_01_15_Victor_08 | Petrov | 0 | 2.487 | True | yes | 6.8 | I'll meet you at the exit. | سألتقي بك عند المخرج. |
| 9 | 4528 | `/0955E4F54AA5DCAAB88EEFB7E1485F88` | VO_CS_01_15_Victor_09 | Petrov | 0 | 2.821 | True | yes | 7.1 | I'm right behind you, honey. | أنا خلفك مباشرة يا عزيزي. |
| 10 | 4283 | `/9C0A56C34B5A35918C71DCB8E6E9C65B` | VO_CS_01_15_Victor_10 | Petrov | 0 | 2.934 | True | yes | 8.9 | I just hope we're not too late. | آمل فقط ألا نكون قد تأخرنا كثيراً. |
| 11 | 4282 | `/F902E7E74D73D75689CDEE807BAB1094` | VO_CS_01_15_P3_11 | P-3 | 0 | 3.641 | True | yes | 7.4 | Hope can be dangerous. Hands up! | الأمل قد يكون خطراً. ارفعا أيديكما! |
| 12 | 4483 | `/19DDB5C8497CD7DA09EF98AA9985659E` | VO_CS_01_15_Victor_12 | Petrov | 0 | 1.982 | True | yes | 5.0 | What's going on? | ما الذي يجري؟ |
| 13 | 4122 | `/E28A8A014B01FCC36108F5AC721173DF` | VO_CS_01_15_Larisa_13 | Filatova | 0 | 1.987 | True | yes | 3.0 | Viktor? | فيكتور؟ |
| 14 | 4456 | `/B3422E0D457CBB8CD13333870F1F073D` | VO_CS_01_15_P3_14 | P-3 | 0 | 3.537 | True | yes | 7.1 | You deaf? Hands behind your head! | أصمّان؟ ضعا أيديكما خلف رأسيكما! |
| 15 | 4118 | `/215591EB44AEC138027888B023AE41BC` | VO_CS_01_15_Larisa_15 | Filatova | 0 | 1.975 | True | yes | 3.0 | Viktor! | فيكتور! |
| 16 | 4064 | `/52B0F9494FCF9DD2FF0D7FB2A2DE61D0` | VO_CS_01_15_Victor_16 | Petrov | 0 | 2.206 | True | yes | 6.3 | Who the hell are you? | من أنت بحق الجحيم؟ |
| 17 | 4119 | `/59D38058415A2E856B102B8CC7C89753` | VO_CS_01_15_Larisa_17 | Filatova | 0 | 1.985 | True | yes | 3.0 | Viktor! | فيكتور! |
| 18 | 4343 | `/BA8D96FD4AFE22522C9EF68AB196F8AF` | VO_CS_01_15_P3_18 | P-3 | 0 | 4.611 | True | yes | 10.2 | Major Nechaev, special operations. And that's the last question you get. | الرائد نيتشاييف، العمليات الخاصة. وهذا آخر سؤال تحصل عليه. |
| 19 | 4429 | `/04ED04FC490E4AE131CBE9839642F2E8` | VO_CS_01_15_P3_19 | P-3 | 0 | 2.522 | True | yes | 8.3 | You're going to Chelomey. | أنتما ذاهبان إلى تشيلومي. |
| 20 | 4114 | `/CBF6B9D64CE92FB14159899C29FC7B7E` | VO_CS_01_15_Larisa_20 | Filatova | 0 | 2.796 | True | yes | 5.0 | VIKTOR! Save yourself! | فيكتور! أنقذ نفسك! |
| 21 | 4057 | `/A9E5E32246044C6099B55E9BA361DA8B` | VO_CS_01_15_Victor_21 | Petrov | 0 | 6.647 | True | yes | 5.3 | Chelomey... of course, Comrade Major. Intrusion. | تشيلومي... بالطبع أيها الرفيق الرائد. اختراق. |
| 22 | 4493 | `/00FC26A44B12CBD732B5BE9407E15A64` | VO_CS_01_15_P3_22 | P-3 | 0 | 1.868 | True | yes | 1.6 | Huh? | هاه؟ |
| 23 | 4287 | `/996A27774B7F5F5F510EFBB643C2306F` | VO_CS_01_15_Victor_23 | Petrov | 0 | 2.333 | True | yes | 2.6 | Intrusion! | اختراق! |
| 24 | 4124 | `/17D667C94E198D8CEF39C780F0C11E39` | VO_CS_01_15_Computer_24 | Computer | 0 | 6.167 | True | yes | 4.4 | Warning! Warning! Red alert! Lockdown in progress! | تحذير! تحذير! إنذار أحمر! إغلاق جارٍ! |
| 25 | 4058 | `/4A2ABC89444D5389596E509CD89CABEC` | VO_CS_01_15_P3_25 | P-3 | 0 | 3.044 | True | no | 4.9 | HEY, FREEZE! DAMMIT! | هي، قف مكانك! اللعنة! |

Scene counts: H1m 0 | H1k 0 | H1t 0 | H2 0 | H3 24 | H4 0.

### Screenshot lines

| marker | line | tokens | final singleton | following in scene | H3 | clip s | cps |
|---|---:|---:|---|---|---|---:|---:|
| VO_CS_01_15_Larisa_15 | 4118 | 0 | True | yes | 1 | 1.975 | 3.0 |
| VO_CS_01_15_Victor_16 | 4064 | 0 | True | yes | 1 | 2.206 | 6.3 |
| VO_CS_01_15_Larisa_17 | 4119 | 0 | True | yes | 1 | 1.985 | 3.0 |
| VO_CS_01_15_P3_18 | 4343 | 0 | True | yes | 1 | 4.611 | 10.2 |

Of the four screenshot lines, 4 of 4 have H3 (final singleton plus a following scene line). The long P-3 line is still markerless and reads at 10.2 Arabic chars/s over 4.611 s.

### Verdict

- H1: **not supported** in this scene - the scene markers/keys are unique and no cell repeats a page start.
- H2: **not supported** in this scene - no explicit range end reaches the next page start.
- H3: **LIKELY for the stack** - 24 line(s) in the scene have a final singleton page and a following line in the same scene; 4 of the four screenshot lines are in that set. With markerless cells their lifetime is the whole Wwise clip, so overlapping voice events can leave several lines on screen at once.
- H4: **not supported** in this scene - no marker or key is reused in another stock DataTable.
- The visible truncation of the long P-3 line is **not explained by H1-H4**. It is consistent with the bottom subtitle bar running out of vertical space when three wrapped lines are shown; the widget evidence is in `reports/p4_subtitle_hide_blueprint.md` and the play-test guide. H3 explains why the three lines are concurrent; it does not by itself truncate text.
