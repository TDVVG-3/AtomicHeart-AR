# Subtitle stack audit - H1 / H2 / H3 / H4

Generated: 2026-10-28 14:09:15 +03:00
Master: `build\variants\atomic-heart-ar_p12g.tsv`
Stock tables: 31 | rows: 8853 | unmatched keys: 4790

Mapping note: 4790 of 8853 stock rows could not be joined to a master locres key. H1m, H1k and H4 are stock DataTable checks independent of Arabic. H1t, H2 and H3 are assessed only where a master Arabic cell was found; unmatched rows keep their table name as the scope label.

| hypothesis | rows | meaning |
| --- | ---: | --- |
| H1 marker duplicate in table | 36 | same Wwise marker used by more than one row in the same DataTable |
| H1 key duplicate in table | 15 | same locres sentence key used by more than one row in the same DataTable |
| H1 duplicate marker start in cell | 27 | same page start timestamp repeated inside one Arabic cell |
| H2 end overlaps next start | 0 | explicit range end >= the next page start in the same cell |
| H3 final singleton + following scene row | 343 | final page has no end and another line follows in the same scene |
| H4 stock cross-table marker/key reuse | 3 | marker or key reused in another stock DataTable |

## Per scope

| scope | rows | H1m | H1k | H1t | H2 | H3 | H4 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Academy_Dialogues | 58 | 0 | 0 | 6 | 0 | 2 | 0 |
| Chelomey | 1 | 0 | 0 | 0 | 0 | 0 | 1 |
| Chelomey_Dialogues | 559 | 0 | 0 | 8 | 0 | 55 | 0 |
| ChelomeyFinal_Dialogues | 107 | 0 | 0 | 0 | 0 | 14 | 0 |
| CUTSCENES | 441 | 0 | 0 | 0 | 0 | 5 | 0 |
| Cutscenes_dlc1 | 99 | 0 | 0 | 0 | 0 | 33 | 0 |
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
| Marshes_dlc1 | 140 | 4 | 0 | 0 | 0 | 33 | 0 |
| Mendeleev_dlc1 | 273 | 0 | 0 | 0 | 0 | 16 | 0 |
| OpenWorldVDNKh_Dialogues | 140 | 0 | 0 | 0 | 0 | 4 | 0 |
| Pavlov | 1 | 0 | 0 | 0 | 0 | 0 | 1 |
| Pavlov_Dialogues | 237 | 0 | 0 | 1 | 0 | 5 | 0 |
| Phasatron_dlc4 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |
| Polygon_Dialogues | 109 | 0 | 0 | 12 | 0 | 4 | 0 |
| Schebetar_Subs | 95 | 0 | 0 | 0 | 0 | 0 | 0 |
| Schebetars_dlc1 | 39 | 0 | 0 | 0 | 0 | 0 | 0 |
| Theatre_Dialogues | 171 | 0 | 0 | 1 | 0 | 29 | 0 |
| Vavilov_Dialogues | 1069 | 4 | 0 | 9 | 0 | 108 | 0 |
| VDNKh_Dialogues | 515 | 0 | 0 | 0 | 0 | 26 | 0 |

## 30 worst scenes

Score = H1m + H1k + H1t + H2 + H3 + H4. Scene is the marker prefix with the trailing character and line number removed.

| # | scene | table | rows | H1m | H1k | H1t | H2 | H3 | H4 | score |
|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | VO_SP_Vavilov | DT_Subtitles_Vavilov.tsv | 42 | 0 | 0 | 0 | 0 | 41 | 0 | 41 |
| 2 | VO_SP_Begin_Raf | DT_Subtitles_Chelomey.tsv | 37 | 0 | 0 | 0 | 0 | 36 | 0 | 36 |
| 3 | VO_DLC1_Goose | DT_Subtitles_DLC01_Goose.tsv | 91 | 12 | 15 | 0 | 0 | 0 | 0 | 27 |
| 4 | VO_SP_Theatre | DT_Subtitles_Theatre.tsv | 37 | 0 | 0 | 0 | 0 | 14 | 0 | 14 |
| 5 | VO_SP_Mendeleev_TVNews03 | DT_Subtitles_DLC01_Cutscenes.tsv | 13 | 0 | 0 | 0 | 0 | 12 | 0 | 12 |
| 6 | VO_SP_Marshes_SolvingLabDeactivation | DT_Subtitles_DLC01_Marshes.tsv | 23 | 0 | 0 | 0 | 0 | 12 | 0 | 12 |
| 7 | VO_SP_Theatre_VictorSpeaker | DT_Subtitles_Theatre.tsv | 12 | 0 | 0 | 0 | 0 | 11 | 0 | 11 |
| 8 | VO_SP_VDNH | DT_Subtitles_VDNH.tsv | 23 | 0 | 0 | 0 | 0 | 11 | 0 | 11 |
| 9 | VO_SP_Begin | DT_Subtitles_Chelomey.tsv | 29 | 0 | 0 | 0 | 0 | 11 | 0 | 11 |
| 10 | VO_VA | DT_Subtitles_Vavilov.tsv | 12 | 0 | 0 | 0 | 0 | 11 | 0 | 11 |
| 11 | VO_VA_Marshes_SolvingLabDeactivation | DT_Subtitles_DLC01_Marshes.tsv | 20 | 0 | 0 | 0 | 0 | 10 | 0 | 10 |
| 12 | VO_SP_Mendeleev_TVNews04 | DT_Subtitles_DLC01_Cutscenes.tsv | 10 | 0 | 0 | 0 | 0 | 9 | 0 | 9 |
| 13 | VO_SP_DLC01_Corpses | DT_Subtitles_DLC01_Mendeleev.tsv | 10 | 0 | 0 | 0 | 0 | 9 | 0 | 9 |
| 14 | VO_SP_Final_AtomicHeartProgram | DT_Subtitles_ChelomeyFinal.tsv | 10 | 0 | 0 | 0 | 0 | 9 | 0 | 9 |
| 15 | VO_SP_Marshes_RafikWeaponIdle | DT_Subtitles_DLC01_Marshes.tsv | 11 | 0 | 0 | 0 | 0 | 9 | 0 | 9 |
| 16 | VO_SCH_Crystal_11_Tereshkova | DT_Subtitles_DLC04_Schebetars.tsv | 15 | 0 | 0 | 0 | 0 | 9 | 0 | 9 |
| 17 | VO_SP_CraftCase_IdleRandom | DT_Subtitles_Vavilov.tsv | 9 | 0 | 0 | 0 | 0 | 8 | 0 | 8 |
| 18 | VO_VA_DLC03_Triton_PoolEmotionTalk | DT_Subtitles_DLC03_Triton.tsv | 11 | 6 | 0 | 0 | 0 | 0 | 0 | 6 |
| 19 | VO_SP_Mendeleev_TVNews02 | DT_Subtitles_DLC01_Cutscenes.tsv | 7 | 0 | 0 | 0 | 0 | 6 | 0 | 6 |
| 20 | VO_VA_DLC_02_Slider_GotApple | DT_Subtitles_DLC02_Slider.tsv | 6 | 6 | 0 | 0 | 0 | 0 | 0 | 6 |
| 21 | VO_VA_VDNH_MagnetTalk_02 | DT_Subtitles_VDNH.tsv | 11 | 0 | 0 | 0 | 0 | 6 | 0 | 6 |
| 22 | VO_VA_DialogCase_BattleEnteruption | DT_Subtitles_Vavilov.tsv | 6 | 0 | 0 | 0 | 0 | 5 | 0 | 5 |
| 23 | VO_SP_CutScene00 | DT_Subtitles_Chelomey.tsv | 6 | 0 | 0 | 5 | 0 | 0 | 0 | 5 |
| 24 | VO_SP_Pavlov_PolymerizedDeadman | DT_Subtitles_Pavlov.tsv | 6 | 0 | 0 | 0 | 0 | 5 | 0 | 5 |
| 25 | VO_SP_Vavilov_Ucheniy_on | DT_Subtitles_Vavilov.tsv | 1 | 0 | 0 | 5 | 0 | 0 | 0 | 5 |
| 26 | VO_VA_DialogCase_SelfDamageEnteruption | DT_Subtitles_Vavilov.tsv | 6 | 0 | 0 | 0 | 0 | 5 | 0 | 5 |
| 27 | VO_VA_Final_FirstTwinBattle | DT_Subtitles_ChelomeyFinal.tsv | 6 | 0 | 0 | 0 | 0 | 5 | 0 | 5 |
| 28 | VO_VA_Polygon10_BrokenContainer | DT_Subtitles_Polygons.tsv | 5 | 0 | 0 | 0 | 0 | 4 | 0 | 4 |
| 29 | VO_SP_Mendeleev_TVNews01 | DT_Subtitles_DLC01_Cutscenes.tsv | 5 | 0 | 0 | 0 | 0 | 4 | 0 | 4 |
| 30 | VO_VA_OWVDNH_PetrovCall_01 | DT_Subtitles_OpenWorld.tsv | 13 | 0 | 0 | 0 | 0 | 4 | 0 | 4 |

## Screenshot scene: VO_CS_01_15

| order | line | key | marker | speaker | markers | clip s | final singleton | following in scene | cps | English | Arabic |
|---:|---:|---|---|---|---|---:|---|---|---:|---|---|
| 1 | 4228 | `/CF1A66AD482DFA9D03DF86BA88FBF13E` | VO_CS_01_15_Larisa_01 | Filatova | 1 | 3.764 | False | yes | 6.9 | Are you okay? Is everything ready? Did you pull it off? | *0-0.049*هل أنتِ بخير؟ هل كل شيء جاهز؟ هل نجحتِ؟ |
| 2 | 4291 | `/CA8AF8514C76D3525CB05782384B45DF` | VO_CS_01_15_Victor_02 | Petrov | 1 | 5.207 | False | yes | 9.0 | Don't worry, honey, I'm right as rain. The operation was totally painless. | *0-0.072*لا تقلق يا عزيزي، أنا في أحسن حال. كانت العملية بلا ألم تماماً. |
| 3 | 4474 | `/3998BD2D45C3CC56576575AB48DC4BD0` | VO_CS_01_15_Larisa_03 | Filatova | 1 | 7.781 | False | yes | 8.9 | Good. You need to leave right now. There's a man coming for you, he's armed and wearing an experimental Polymer glove. | *0-0.097*جيد. عليكِ أن ترحلي الآن فوراً. هناك رجل قادم من أجلك، وهو مسلّح ويرتدي قفاز بوليمر تجريبياً. |
| 4 | 4186 | `/60F798D848972F1DC5ECF3AE1AF3E419` | VO_CS_01_15_Victor_04 | Petrov | 1 | 4.721 | False | yes | 7.4 | Must be Sechenov's guy. Larisa, did you talk to him? | *0-0.059*لا بد أنه رجل سيتشينوف. لاريسا، هل تحدثتِ إليه؟ |
| 5 | 4279 | `/E8636ED640BCA8E848438C9951866CB4` | VO_CS_01_15_Larisa_05 | Filatova | 1 | 8.749 | False | yes | 7.3 | He was attacked by a Burav. We took him to the infirmary, and then... I didn't know... I couldn't just let him bleed ... | *0-0.091*هاجمه بوراف. أخذناه إلى المستوصف، ثم... لم أكن أعلم... لم أستطع أن أتركه ينزف حتى الموت. |
| 6 | 4068 | `/A2918A4D4461784F58BE8894BCC99CC9` | VO_CS_01_15_Victor_06 | Petrov | 1 | 6.093 | False | yes | 5.1 | Well, you should have—it would've saved us a whole lot of trouble! | *0-0.054*كان عليكِ ذلك—كان سيوفر علينا متاعب جمة! |
| 7 | 4266 | `/920C0298464B98C0C4A81B9F01F1498B` | VO_CS_01_15_Larisa_07 | Filatova | 1 | 3.202 | False | yes | 5.3 | It scares me when you talk like that. | *0-0.039*يخيفني أن تتحدث هكذا. |
| 8 | 4197 | `/93A698D6458088CE93329C99495E6EBA` | VO_CS_01_15_Victor_08 | Petrov | 1 | 2.487 | False | yes | 6.8 | I'll meet you at the exit. | *0-0.039*سألتقي بك عند المخرج. |
| 9 | 4528 | `/0955E4F54AA5DCAAB88EEFB7E1485F88` | VO_CS_01_15_Victor_09 | Petrov | 1 | 2.821 | False | yes | 7.1 | I'm right behind you, honey. | *0-0.042*أنا خلفك مباشرة يا عزيزي. |
| 10 | 4283 | `/9C0A56C34B5A35918C71DCB8E6E9C65B` | VO_CS_01_15_Victor_10 | Petrov | 1 | 2.934 | False | yes | 8.9 | I just hope we're not too late. | *0-0.049*آمل فقط ألا نكون قد تأخرنا كثيراً. |
| 11 | 4282 | `/F902E7E74D73D75689CDEE807BAB1094` | VO_CS_01_15_P3_11 | P-3 | 1 | 3.641 | False | yes | 7.4 | Hope can be dangerous. Hands up! | *0-0.05*الأمل قد يكون خطراً. ارفعا أيديكما! |
| 12 | 4483 | `/19DDB5C8497CD7DA09EF98AA9985659E` | VO_CS_01_15_Victor_12 | Petrov | 1 | 1.982 | False | yes | 5.0 | What's going on? | *0-0.031*ما الذي يجري؟ |
| 13 | 4122 | `/E28A8A014B01FCC36108F5AC721173DF` | VO_CS_01_15_Larisa_13 | Filatova | 1 | 1.987 | False | yes | 3.0 | Viktor? | *0-0.027*فيكتور؟ |
| 14 | 4456 | `/B3422E0D457CBB8CD13333870F1F073D` | VO_CS_01_15_P3_14 | P-3 | 1 | 3.537 | False | yes | 7.1 | You deaf? Hands behind your head! | *0-0.048*أصمّان؟ ضعا أيديكما خلف رأسيكما! |
| 15 | 4118 | `/215591EB44AEC138027888B023AE41BC` | VO_CS_01_15_Larisa_15 | Filatova | 1 | 1.975 | False | yes | 3.0 | Viktor! | *0-0.027*فيكتور! |
| 16 | 4064 | `/52B0F9494FCF9DD2FF0D7FB2A2DE61D0` | VO_CS_01_15_Victor_16 | Petrov | 1 | 2.206 | False | yes | 6.3 | Who the hell are you? | *0-0.036*من أنت بحق الجحيم؟ |
| 17 | 4119 | `/59D38058415A2E856B102B8CC7C89753` | VO_CS_01_15_Larisa_17 | Filatova | 1 | 1.985 | False | yes | 3.0 | Viktor! | *0-0.027*فيكتور! |
| 18 | 4343 | `/BA8D96FD4AFE22522C9EF68AB196F8AF` | VO_CS_01_15_P3_18 | P-3 | 1 | 4.611 | False | yes | 10.2 | Major Nechaev, special operations. And that's the last question you get. | *0-0.072*الرائد نيتشاييف، العمليات الخاصة. وهذا آخر سؤال تحصل عليه. |
| 19 | 4429 | `/04ED04FC490E4AE131CBE9839642F2E8` | VO_CS_01_15_P3_19 | P-3 | 1 | 2.522 | False | yes | 8.3 | You're going to Chelomey. | *0-0.043*أنتما ذاهبان إلى تشيلومي. |
| 20 | 4114 | `/CBF6B9D64CE92FB14159899C29FC7B7E` | VO_CS_01_15_Larisa_20 | Filatova | 1 | 2.796 | False | yes | 5.0 | VIKTOR! Save yourself! | *0-0.036*فيكتور! أنقذ نفسك! |
| 21 | 4057 | `/A9E5E32246044C6099B55E9BA361DA8B` | VO_CS_01_15_Victor_21 | Petrov | 1 | 6.647 | False | yes | 5.3 | Chelomey... of course, Comrade Major. Intrusion. | *0-0.059*تشيلومي... بالطبع أيها الرفيق الرائد. اختراق. |
| 22 | 4493 | `/00FC26A44B12CBD732B5BE9407E15A64` | VO_CS_01_15_P3_22 | P-3 | 1 | 1.868 | False | yes | 1.6 | Huh? | *0-0.023*هاه؟ |
| 23 | 4287 | `/996A27774B7F5F5F510EFBB643C2306F` | VO_CS_01_15_Victor_23 | Petrov | 1 | 2.333 | False | yes | 2.6 | Intrusion! | *0-0.027*اختراق! |
| 24 | 4124 | `/17D667C94E198D8CEF39C780F0C11E39` | VO_CS_01_15_Computer_24 | Computer | 1 | 6.167 | False | yes | 4.4 | Warning! Warning! Red alert! Lockdown in progress! | *0-0.05*تحذير! تحذير! إنذار أحمر! إغلاق جارٍ! |
| 25 | 4058 | `/4A2ABC89444D5389596E509CD89CABEC` | VO_CS_01_15_P3_25 | P-3 | 0 | 3.044 | True | no | 4.9 | HEY, FREEZE! DAMMIT! | هي، قف مكانك! اللعنة! |

Scene counts: H1m 0 | H1k 0 | H1t 0 | H2 0 | H3 0 | H4 0.

### Screenshot lines

| marker | line | tokens | final singleton | following in scene | H3 | clip s | cps |
|---|---:|---:|---|---|---|---:|---:|
| VO_CS_01_15_Larisa_15 | 4118 | 1 | False | yes | 0 | 1.975 | 3.0 |
| VO_CS_01_15_Victor_16 | 4064 | 1 | False | yes | 0 | 2.206 | 6.3 |
| VO_CS_01_15_Larisa_17 | 4119 | 1 | False | yes | 0 | 1.985 | 3.0 |
| VO_CS_01_15_P3_18 | 4343 | 1 | False | yes | 0 | 4.611 | 10.2 |

Of the four screenshot lines, 0 of 4 have H3 (final singleton plus a following scene line). The long P-3 line now has an explicit 0-end range and reads at 10.2 Arabic chars/s over 4.611 s.

### Verdict

- H1: **not supported** in this scene - the scene markers/keys are unique and no cell repeats a page start.
- H2: **not supported** in this scene - no explicit range end reaches the next page start.
- H3: **not present in this variant** - no scene line remains a final singleton with a following line. All four screenshot lines now carry an explicit 0-end range; compare with the p12 baseline audit for the before state.
- H4: **not supported** in this scene - no marker or key is reused in another stock DataTable.
- The visible truncation of the long P-3 line is **not explained by H1-H4**. H3 has been addressed with explicit 0-end ranges, so the remaining truncation is consistent with the bottom subtitle bar running out of vertical space when three wrapped lines are shown; see `reports/p4_subtitle_hide_blueprint.md` and the play-test guide.
