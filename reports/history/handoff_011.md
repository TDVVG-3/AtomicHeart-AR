# HANDOFF

**Date/time:** 2026-10-18 20:49 (+03:00)  |  **Cycle:** 007  |  **Step:** pilot step 8 (checklist + handoff)  |  **State:** PILOT BUILT, NOT INSTALLED - STOPPED AT THE PILOT GATE

---

## Summary (5 lines)

1. Phase 0 is done: TOTAL = 27,618 rows / 19,996 unique English strings, an explicit work order
   with 25/50/75/100 cutoffs, a 136-entry glossary built BEFORE translating, and a style guide.
2. The pilot translated 60 rows (20 UI + 20 short dialogue + 20 long subtitles with markers and
   tags) covering 57 unique strings, plus the 25 phase-7 seed rows = 85 rows with Arabic, all DRAFT.
3. The validator passes with 0 errors, and the glyph gate proves every pilot character exists in
   the subtitle font the v2 font pak installs - so no font work is needed for the pilot.
4. The carrier builder now covers ALL 35 ko-KR locres scopes (was NewP5 only); the pilot pak p3 is
   built, round-trip validated and unpack-verified (35/35 byte-identical) but NOT installed.
5. I found and fixed a real defect on the way: the currently installed p2 pak ships broken icon
   tags in the 7 game-tip rows (KI-019); p3 carries the fix, and the pilot check proves it in game.

---

## 1. Completed

- Cycle opening ritual: spec hash check PASS (`579f581e...61c35`), no changes to the spec.
- Phase 0 step 1: TOTAL definition applied - all master rows with a non-empty English source,
  excluding Status TECHNICAL/BLOCKED. Result: 27,618 rows, 19,996 unique English strings,
  TECHNICAL 0, BLOCKED 0, 7,622 rows reuse an already-counted string.
- Phase 0 step 2: `scripts/translation_plan.ps1` -> `reports/translation_plan.md` (deterministic
  work order: tier 1 UI/menus/HUD/items/weapons/skills, tier 2 dialogue/subtitles/cutscenes,
  tier 3 lore/mail/DLC/credits; cumulative cutoffs 6,905 / 13,809 / 20,714 / 27,618).
- Phase 0 step 3: `scripts/glossary_extract.ps1` -> `reports/glossary_candidates.tsv` (4,820
  candidates), then `glossary/glossary.tsv` = 136 curated entries (all DRAFT; reason marked
  transliterated / translated / preserved). Every entry verified to occur in the English corpus.
- Phase 0 step 3b: `glossary/glossary_questions.md` = 26 decisions for you (model codes, robot
  nicknames, science/Soviet terms, tone, formatting) with recommended defaults marked.
- Phase 0 step 4: `glossary/terminology.md` = style guide (MSA register map, Western digits,
  0-9 only, Arabic question mark/comma, byte-exact tags/placeholders/markers, UI length rule,
  translation-memory rule, Status workflow, validation gates).
- Pilot step 5: 60 pilot rows selected deterministically (`scripts/pilot_select.ps1` ->
  `reports/pilot_selection.tsv`), translated into `localization/working/pilot_tm.tsv` (57 unique
  strings), applied by `scripts/pilot_apply.ps1` (sets Arabic + Status DRAFT + a Notes tag).
- Pilot step 5b: `scripts/validate_translation.ps1` - 0 errors, 1 accepted length warning.
  It checks placeholders, rich-text tags, fragment/speaker markers, empty Arabic, untranslated
  English, UTF-8/control characters, mojibake, Arabic-letter presence, glossary compliance and
  UI length. Report: `reports/translation_validation.md`.
- Pilot step 5c: `localization/references/AR_EN_REFERENCE.md` regenerated (85 rows, Arabic first,
  English below) by `scripts/build_reference.ps1`.
- Pilot step 6: subtitle font settled with evidence + `scripts/glyph_gate.ps1` -> PASS (all 113
  distinct codepoints of the pilot Arabic present in the subtitle face BlenderPro-Medium, which
  the v2 font pak replaces with IBM Plex Sans Arabic Medium; Latin-Basic complete). No font pak
  extension required. Report: `reports/glyph_gate.md`.
- Pilot step 7: `scripts/build_carrier_locres_pak.ps1` rewritten to build EVERY ko-KR locres scope
  (35 scopes, from the game pak itself as the single source of truth), fill order Arabic > English
  > keep Korean, round-trip validate each scope, then pack and re-unpack for a byte-identical check.
- Pilot step 7b: pilot pak `build/package/zzz_atomicheart-ar_carrier_koKR_p3_P.pak` built:
  35 scopes, 27,618 keys (exactly the master row count), 85 Arabic, 27,533 English-filled,
  0 kept Korean, 0 round-trip failures, 35/35 entries byte-identical after unpack.
  sha256 `b58029662e5acf775087426ed85721905a5846127d6af5c209a482514f7b41df`, 3,612,753 bytes.
  NOT INSTALLED. Report: `reports/carrier_build.md`.
- Pilot step 8: `reports/pilot_in_game_checklist.md` written for you (non-developer, area by area,
  screenshots, what to send back). Standard docs updated: STATUS.md, KNOWN_ISSUES.md, DECISIONS.md.

## 2. Problems (and what I did)

| # | problem | status | action taken |
|---|---|---|---|
| 1 | The master TSV header was a literal backtick-t string, not real tabs | FIXED | rewrote the header line with real 13-column tabs; data rows untouched (27,618 intact) |
| 2 | The seed CSV stores CSV-escaped quotes (`""`) and the p2 builder never unescaped them, so the INSTALLED p2 pak carries broken tags in the 7 game-tip rows (`id=""Button.ConsumeItem""`) | FIXED in master + p3, in-game proof pending | KI-019; `pilot_apply.ps1` unescapes before writing; validator tag check catches it; pilot check Area E verifies in game |
| 3 | An Arabic literal inside a `.ps1` got mangled by PowerShell 5.1 (ANSI script parsing) and wrote mojibake into one row | FIXED | KI-021; Arabic now lives only in UTF-8 data files (`glossary_fixups.tsv`); validator hard-fails mojibake + U+FFFD |
| 4 | Python is not installed on this machine (Store alias stub only), so `scripts/validate_translation.py` cannot run | OPEN, needs your approval | KI-020; the identical checks run as `scripts/validate_translation.ps1` today |
| 5 | `$pid` is a reserved PowerShell variable; the glyph gate crashed on first run | FIXED | renamed to `$platID`/`$encID`; gate now PASSes |

## 3. Evidence (labels: PASS / FAIL / PARTIAL / BLOCKED / NOT TESTED; confidence CONFIRMED / LIKELY / UNKNOWN)

| item | label | confidence | evidence file |
|---|---|---|---|
| spec hash unchanged this cycle | PASS | CONFIRMED | `579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35` |
| TOTAL / unique strings | PASS | CONFIRMED | `reports/translation_plan.md` |
| glossary complete + verified in corpus | PASS | CONFIRMED | `glossary/glossary.tsv`, `reports/glossary_candidates.tsv` |
| pilot translation (85 rows with Arabic) | PASS | CONFIRMED | `reports/translation_validation.md`, `reports/review_sample.md` |
| validator (placeholders/tags/markers/UTF-8/glossary) | PASS (0 errors) | CONFIRMED | `reports/translation_validation.md` |
| master Arabic vs translation memory integrity | PASS (60/60 byte-identical) | CONFIRMED | `scripts/pilot_apply.ps1` output |
| subtitle-face glyph coverage for the pilot text | PASS (0 missing of 113 codepoints) | CONFIRMED | `reports/glyph_gate.md` |
| carrier p3 covers all 35 ko-KR scopes | PASS | CONFIRMED | `reports/carrier_build.md` |
| p3 round-trip + unpack byte-identity | PASS (0 fail, 35/35) | CONFIRMED | `reports/carrier_build.md` |
| p2 shipped broken icon tags in game tips | FAIL (defect, fixed in p3) | CONFIRMED | KI-019, unpacked p2 locres export |
| Arabic subtitles render in game | NOT TESTED | UNKNOWN | pilot check Area D (yours) |
| game tips with inline icons render correctly | NOT TESTED | UNKNOWN | pilot check Area E (yours) |
| LF->CRLF normalization inside locres values | NOTED (accepted) | CONFIRMED | KI-015, `reports/carrier_build.md` |

## 4. Files changed (this cycle, all local - nothing uploaded)

New tools:
- `scripts/translation_plan.ps1`, `scripts/glossary_extract.ps1`, `scripts/pilot_select.ps1`,
  `scripts/pilot_apply.ps1`, `scripts/validate_translation.ps1`, `scripts/glyph_gate.ps1`,
  `scripts/build_reference.ps1`, `scripts/review_sample.ps1`

Rewritten / edited:
- `scripts/build_carrier_locres_pak.ps1` (NewP5 only -> all 35 ko-KR scopes, per-scope validation)
- `localization/master/atomic-heart-ar.tsv` (header fixed; 85 rows filled: Arabic + DRAFT + Notes)
- `localization/references/AR_EN_REFERENCE.md` (regenerated: 85 rows)
- `STATUS.md`, `KNOWN_ISSUES.md` (KI-019/020/021), `DECISIONS.md` (DEC-023, DEC-024)

New data:
- `glossary/glossary.tsv`, `glossary/terminology.md`, `glossary/glossary_questions.md`
- `localization/working/pilot_tm.tsv`, `localization/working/tm.tsv`,
  `localization/working/glossary_fixups.tsv`

New reports:
- `reports/translation_plan.md`, `reports/glossary_candidates.tsv`, `reports/pilot_selection.tsv`,
  `reports/translation_validation.md`, `reports/carrier_build.md`, `reports/glyph_gate.md`,
  `reports/review_sample.md`, `reports/pilot_in_game_checklist.md`, this file

Build output (gitignored):
- `build/package/zzz_atomicheart-ar_carrier_koKR_p3_P.pak` (3,612,753 bytes, NOT installed)
- `build/staging/carrier_koKR_all/` (per-scope work + `carrier_record.txt`)

Not touched: the game folder except read-only reads; no EXE/DLL; no installs/uninstalls;
no uploads (`git remote -v` is empty).

## 5. Current Status

- Arabic coverage: **85 of 27,618 (0.3%)** - the pilot only. Everything else is English-filled.
- Master statuses: 27,533 UNTRANSLATED, 85 DRAFT, 0 TECHNICAL, 0 BLOCKED.
- Installed in `~mods` right now (from Test 3, unchanged by me):
  `zzz_atomicheart-ar_carrier_koKR_p2_P.pak` (has the KI-019 tip-tag defect) and
  `zzz_atomicheart-ar_font_p2_plex_P.pak` (good, keep it).
- The pilot pak p3 is ready in `build/package/` and has never been installed.
- Batches 1-4 have not started; they wait for your pilot result.

## 6. Next Action

1. You run the pilot check (`reports/pilot_in_game_checklist.md`) after installing p3 (your call,
   your approval) - the areas that matter most are D (subtitles) and E (game tip icons).
2. I wait. On your report I record the result, then start batch 1 (25% -> 6,905 rows cumulative,
   4,562 unique strings) on your "go"/"next".
3. If you approve Python, I install it and run `scripts/validate_translation.py` as the requested
   primary validator (the PowerShell twin stays as the fallback).

## 7. What I need you to do

- Run the pilot check and send back the filled block in section 5 of
  `reports/pilot_in_game_checklist.md` (or just tell me what you saw).
- Answer `glossary/glossary_questions.md` (26 items; anything unanswered keeps my recommended
  default, so leaving it blank is safe).
- Tell me whether to install Python 3 (for the `.py` validator) or keep the PowerShell validator.
- Confirm I may start batch 1 after the pilot report (one batch per "next").

---

## Decisions (current)

| id | decision |
|---|---|
| DEC-001..012 | repo layout; game read-only; repak primary; split localization; no-upload rule; UnrealLocres for locres; master DB seeded from en-US |
| DEC-014 | v1 Naskh font REJECTED (blanked Latin); v2 = IBM Plex Sans Arabic dual-script (OFL) |
| DEC-015 | language list is hardcoded in cooked DA_Audio (13 records); native `ar` needs Phase 8 tooling; fallback carrier slot = ko-KR |
| DEC-016 | carrier English-fill policy; LF<->CRLF equivalence accepted; font glyph gate enforces Cyrillic/Hangul unless exempted |
| DEC-017 | dialogue program rules; TOTAL = English-source strings only; RU-only tracked separately; batches cumulative 25/50/75/100 |
| DEC-021 | corrected asset classifier; TOTAL = 10,394 dialogue strings; master trimmed 27,729 -> 27,618 |
| DEC-022 | Test 3 results (menu + settings = A); subtitle FontObject = BlenderPro-Medium_Font; translation program approved |
| DEC-023 | translation program: TOTAL = 27,618 rows / 19,996 unique; tier order + cutoffs; glossary first; style guide; 4 cumulative batches; pilot gate |
| DEC-024 | pilot build: carrier builder extended to all 35 ko-KR scopes; p3 validated; glyph gate PASS; KI-019/020/021 recorded |

## Known issues (current)

| id | state | one-line |
|---|---|---|
| KI-009 | PARTIAL-CONFIRMED | menu + settings render Arabic (A); GameTips + subtitles still NOT TESTED |
| KI-013 | OPEN | native `ar` language entry needs DA_Audio schema tooling (Phase 8) |
| KI-017 | BLOCKED | one obfuscated cooked asset (NotLifted_17) - evidence only |
| KI-018 | NOTED | 248 RU-only cooked dialogue assets / 6,012 strings need a separate uasset path |
| KI-019 | FIXED in p3, in-game proof pending | p2 shipped broken icon tags in the 7 seeded game tips |
| KI-020 | OPEN (needs approval) | Python not installed; `.py` validator delivered but not run |
| KI-021 | MITIGATED | Arabic must never be a literal inside a `.ps1` (PowerShell ANSI parsing) |
| KI-015 | NOTED | UnrealLocres normalizes LF to CRLF inside multiline values (accepted) |
| KI-016 | NOTED | 728 pre-existing duplicate IDs in the master (cosmetic) |

## What I should send back (to you)

- The pilot in-game report (that is the current gate).
- Batch 1 starts only after your "next".

---

## Review sample (40 rows, Arabic first, English below)

The full list of every translated row is in `localization/references/AR_EN_REFERENCE.md`.
This is the standing 40-row per-batch sample: a deterministic spread, the longest rows, and
the tag-bearing rows.

<!-- BEGIN REVIEW SAMPLE -->

| # | scope | cat | why | Arabic (what the player sees) | English source |
|---|---|---|---|---|---|
| 1 | NewP5 | UI | spread | تكنوستاسيس | Technostasis |
| 2 | NewP5 | UI | spread | أحواض الدلافين | Dolphin Enclosures |
| 3 | NewP5 | UI | spread | الأداء | Performance |
| 4 | NewP5 | UI | spread | إنهاء اللعبة | Quit game |
| 5 | NewP5 | UI | spread | للقفز فوق جسم أو التسلّق عليه، اضغط <tag id="InputAction.Gameplay.jump"/>. | To vault or climb an object, press <tag id="InputAction.Gameplay.jump"/>. |
| 6 | NewP5 | UI | spread | الاندفاع أثناء القفز | Dashing while jumping |
| 7 | NewP5 | UI | spread | HAWK غير معرّف | UNIDENTIFIED HAWK |
| 8 | Pavlov_Dialogues | Dialogue | spread | *0.08*لا أستطيع الجزم. ربما تكون المسألة مسألة راحة. أجهزة THOUGHT تحتاج إلى إعادة ضبط في كل مرة تُلبَس. *0.04*أما الخاتم فيمكن خلعه وإلباسه من جديد دون عناء. | *0.08*I can't say for sure. Perhaps it's an issue of convenience. THOUGHT devices need to be reconfigured every time they are put on. *0.04*A ring can be taken off and put back on without inconvenience. |
| 9 | Schebetar_Subs | Subtitles | spread | *0.00-0.08* &Ministry of Culture curator& هذه مكنسة روبوتية أو "مكنسة روبوت". إنها رائعة تماماً! انظروا فقط كيف تتحرّك بالحركة البطيئة!*0.08-0.10* &Ministry of Culture curator& حسناً، لنرَ...*0.10-0.18* &Ministry of Culture curator& لها جسم مستطيل وكتفان ضيّقان جداً، ما يتيح لها شفط الأوساخ في أي مكان تقريباً.*0.18-0.28* &Ministry of Culture curator& انظروا إلى كل هذه القمامة في كل مكان! لكن المكنسة الروبوتية لا تهتم، إنها تدمّر كل ذلك الخردة وتواصل شفط الأوساخ.*0.29-0.39* &Ministry of Culture curator& أوه، لقد سكب أحدهم دلو دهان على المكنسة الروبوتية!*0.39-0.45* &Ministry of Culture curator& لكن المكنسة تتصرّف وكأنها لم تلاحظ أن الدهان اللزج تغطّى بها. انظروا إلى هذا الوغد — سينظّف كل شيء، وسيواصل الشفط فقط!*0.46-0.53* &Ministry of Culture curator& فهمت يا دميتري؟ هكذا يجب أن نفتح أعين مواطنينا على الأشياء المذهلة التي نصنعها هنا في المنشأة، لا ذلك الشريط الباهت*0.53-1.01* &Ministry of Culture curator& "مصنع زابوريجيا للسيارات يقدّم الطراز ROZGDFG-20 أو 40 أو أيّاً كان..." إنه ممل حتى الموت. | *0.00-0.08* &Ministry of Culture curator& This is a robot vacuum or "robo-vacuum." It's totally bad ass! Just look at it moving in slow motion!*0.08-0.10* &Ministry of Culture curator& Okay, let's see...*0.10-0.18* &Ministry of Culture curator& It's got an elongated body and very narrow shoulders, which allows it to suck up dirt in almost any area.*0.18-0.28* &Ministry of Culture curator& Just look at all the trash everywhere! But the robo-vacuum doesn't give a crap, it just destroys all that junk and keeps on sucking up the dirt.*0.29-0.39* &Ministry of Culture curator& Uh-oh, someone spilled a bucket of paint on the robo-vacuum!*0.39-0.45* &Ministry of Culture curator& But the robo-vacuum acts like it doesn't even notice it got sticky paint all over it. Look at that fucker—it'll just clean everything up, and it'll just keep on sucking!*0.46-0.53* &Ministry of Culture curator& Get it, Dmitry? That's how we need to open our fellow citizens' eyes to the amazing things we make here at the Facility, not your lame old*0.53-1.01* &Ministry of Culture curator& "the Zaporizhzhia Automotive Factory presents model ROZGDFG-20 or 40 or whatever..." It's boring to death. |
| 10 | NewP5 | UI | spread | للمراوغة بين الهجمات والأجسام الطائرة والمقذوفات، اضغط <tag id="InputAction.Gameplay.Dodge"/> أثناء التحرك. | To dodge attacks, flying objects, and projectiles, press <tag id="InputAction.Gameplay.Dodge"/> while moving. |
| 11 | VDNKh_Dialogues | Dialogue | spread | إليك ذراعك اليسرى. تفضّل وأصلح نفسك. | Here's your left arm. Go ahead and fix yourself up. |
| 12 | NewP5 | UI | spread | ملء الشاشة بإطار نافذة | Windowed Fullscreen |
| 13 | Theatre_Dialogues | Dialogue | spread | *0.08*أتقول ذلك حقاً؟! أتُظهر أنيابك؟ يا له من تعبير بديع، وإن كان سوقياً. تذكّر يا فتى: *0.04*أن تنتفخ صدرك وتتفاخر بالشخصية لا يعني أنك تملك تلك الشخصية فعلاً. | *0.08*You don't say?! Are you showing your teeth? What a delightful, if plebeian, expression. Remember, boy: *0.04*puffing your chest and showing off the character does not mean you are actually in possession of said character. |
| 14 | NewP5 | UI | spread | فريق العمل | Credits |
| 15 | PearTerminals | UI | spread | نادي الشطرنج | Chess club |
| 16 | NewP5 | UI | spread | هوارد فيليبس لوفكرافت | H. P. Lovecraft |
| 17 | VDNKh_Dialogues | Dialogue | spread | الأسلحة الآلية: واحد. الكاراتيه: صفر. | Automatic weapons, one. Karate, zero. |
| 18 | Chelomey_Dialogues | Dialogue | spread | ماذا تعني بـ"نوع جديد"؟ جديد كيف؟ | What do you mean, "new type?" New how? |
| 19 | NewP5 | UI | spread | متوازن | Balanced |
| 20 | OpenWorldVDNKh_Dialogues | Dialogue | spread | *0.06*وكيف لي أن أفعل؟ دهستني الجرّارة أول أمس، وما زلت ملقى في الخندق منذ ذلك الحين. *0.10*كنت أنتظر من يصطدم بي، لكن هذا المكان مهجور تماماً. طريق قلّ سالكوه، كما يقولون، صحيح؟ | *0.06*How can I? The tractor ran me over the day before yesterday, and I've been lying in the ditch ever since. *0.10*I've been waiting for someone to bump into me, but this place is positively deserted. A road less traveled and all that, right? |
| 21 | Schebetar_Subs | Subtitles | longest | *0.05-0.09* &Surgeon& مسحة. ركّزوا. راقبوا ذلك الشق!*0.09-0.10* &Nurse& حسناً... لحظة واحدة...*0.10-0.11* &Surgeon& ركّزوا!*0.16-0.18* &Surgeon& تبا. اضغطوا عليه، الآن!*0.22-0.25* &Surgeon& لم يتشرّبه النسيج بالبوليمر مجدداً، فأنشأ تجويفاً مرضياً.*0.26-0.32* &Surgeon& هناك عقد كهذه في كل جسده. ماذا تريد تلك الوحوش بلا قلب من الناس، هاه؟!*0.33-0.41* &Colonel& قد تكونون محقّين أيها الرفاق، لكن هذا ليس شأنكم. أدّوا عملكم. أيها الجندي، أدخل التالي.*0.42-0.43* &Private& نعم، أيها الرفيق العقيد.*0.44-0.50* &Colonel& يجب أن يتشرّب النسيج البوليمر. وإن لم يفعل، أنقذوا من تستطيعون إنقاذه...*0.51-0.53* &Colonel& ...ونظّفوا هذا المكان. | *0.05-0.09* &Surgeon& Swab. Focus. Keep an eye on that incision!*0.09-0.10* &Nurse& Okay... just a moment...*0.10-0.11* &Surgeon& Focus!*0.16-0.18* &Surgeon& Shit. Pressure on it, now!*0.22-0.25* &Surgeon& The Polymer wasn't absorbed by the tissue again, so it created a pathological cavity.*0.26-0.32* &Surgeon& There are nodules like this all over his body. What do those heartless animals want from people, huh?!*0.33-0.41* &Colonel& You may be right, comrades, but that is not your concern. Do your jobs. Private, bring in the next one.*0.42-0.43* &Private& Yes, Comrade Colonel.*0.44-0.50* &Colonel& The Polymer needs to be absorbed. And if it's not, save whoever you can...*0.51-0.53* &Colonel& ...And clean this place up. |
| 22 | Schebetar_Subs | Subtitles | longest | *0.00-0.06* &Goopy electrician& وماذا لو كانت روبوتاً؟ لم يكن الناس لطفاء معي يوماً. أما هي فلطيفة. الطريقة التي تنظر بها إليّ... *0.07-0.15* &Goopy electrician& كأن في عينيها تياراً من طاقة نقية. وهي تفهمني. أفضل مما فعلت أي فتاة. على أي حال، اتخذت قراري. سأطلب يدها غداً.*0.16-0.19* &Angry voice& ماذا تفعل هنا بحق الجحيم يا فاسيليتش؟ هل تعمل هنا أم لا؟*0.20-0.22* &Vasilitch& تبا... قادم! | *0.00-0.06* &Goopy electrician& So what if she's a robot? People have never been nice to me. But she is. The way she looks at me... *0.07-0.15* &Goopy electrician& It's like there's a stream of pure energy in her eyes. And she understands me. Better than any girl ever has. Anyway, I've made up my mind. I'm proposing to her tomorrow.*0.16-0.19* &Angry voice& What the fuck are you doing here, Vasilitch? Are you working here or not?*0.20-0.22* &Vasilitch&Shit... I'm coming! |
| 23 | Polygon_Dialogues | Dialogue | longest | *0.04*قسم التخطيط في ميدان الاختبار رقم 6 مسؤول عن:  *0.05*1. الحصول على حلول إنشاء ورش الاختبار المستقبلية ودعمها.  *0.07*2. إعداد التصاميم الإنشائية لإعادة بناء وترميم وبناء المباني الجديدة.  *0.05*3. إعداد المواصفات التصميمية والتقديرات لأعمال البناء.  *0.04*4. تحضير بيانات العمل المتعلقة بالتخطيط. | *0.04*Testing Ground #6's Planning Department is responsible for:  *0.05*1. Obtaining and supporting solutions for the construction of future testing workshops.  *0.07*2. Producing construction designs for the reconstruction, repair, and construction of new buildings.  *0.05*3. Producing design specifications and estimates for construction jobs.  *0.04*4. Preparing planning-related statements of work. |
| 24 | Chelomey_Dialogues | Dialogue | longest | *0.10*يمكنك الآن مشاهدة عمليات مصنع آلي يجمّع الروبوتات ويوزّع القطع الميكانيكية التي تحتاجها مجمّعات المنشأة المختلفة. *0.10*ومصنع كهذا، تتحكّم به عن بُعد عقدة من كوليكتيف 1.0، قادر على إدارة ما يصل إلى مئة طلب في الساعة وتنفيذها باستقلالية تامة. | *0.10*You can now observe the operations of an automated plant, performing robot assembly and distributing machine parts required by the Facility's various complexes. *0.10*Controlled remotely by a Kollektiv 1.0 node, a plant such as this is capable of autonomously managing and fulfilling up to a hundred orders per hour. |
| 25 | NewP5 | UI | tagged | لفتح عجلة الجرد، اضغط مع الاستمرار على <tag id="InputAction.Gameplay.RadialMenu"/>. | To open the Inventory Wheel, press and hold <tag id="InputAction.Gameplay.RadialMenu"/>. |
| 26 | NewP5 | UI | tagged | لإحداث ضرر خفيف، اضغط <tag id="InputAction.Gameplay.EquippedItemPrimaryAction"/>. هذه الضربات سريعة لكنها ليست قوية للغاية. | To deal light damage, press <tag id="InputAction.Gameplay.EquippedItemPrimaryAction"/>. Such attacks are fast but not particularly hard-hitting. |
| 27 | NewP5 | UI | tagged | للخروج من البوليمر، استخدم <tag id="InputAction.Gameplay.Dodge"/>. | To emerge from the Polymer, use <tag id="InputAction.Gameplay.Dodge"/>. |
| 28 | NewP5 | UI | tagged | تسلّق الأجسام بالضغط على <tag id="InputAction.Gameplay.Jump"/> بجانبها. | CLIMB objects by PRESSING <tag id="InputAction.Gameplay.Jump"/> next to them. |
| 29 | NewP5 | UI | tagged | لقد جُرحت! اضغط مع الاستمرار على <img id="Button.ConsumeItem"/> للعلاج | You've been injured! Press and hold <img id="Button.ConsumeItem"/> to heal |
| 30 | NewP5 | UI | tagged | لتشغيل الماسح، استمرّ بالضغط على <tag id="InputAction.Gameplay.Scannner"/>. | To activate the scanner, hold <tag id="InputAction.Gameplay.Scannner"/>. |
| 31 | NewP5 | UI | tagged | يمكن للأعداء تنفيذ ضربات قوية تُسقط P-3 إذا أصابته. عندما يستعد عدو لضربة قوية، سيشير تشارلز إلى أفضل لحظة للمراوغتها. عند رؤية التمييز الأحمر، <h>اضغط</> <tag id="InputAction.Gameplay.Dodge"/> للمراوغة. | Enemies can perform power attacks that knock P-3 down if they hit. When an enemy is charging a power attack, CHARLES will indicate the best moment to dodge it. Upon seeing the red highlight, <h>press</> <tag id="InputAction.Gameplay.Dodge"/> to dodge. |
| 32 | NewP5 | UI | tagged | لجمع الموارد وسلب الأعداء، اضغط مع الاستمرار على <tag id="InputAction.Gameplay.Use"/>. | To collect resources and loot enemies, press and hold <tag id="InputAction.Gameplay.Use"/>. |
| 33 | NewP5 | UI | tagged | الوصفة {0} مفتوحة بالفعل! | {0} recipe already unlocked! |
| 34 | NewP5 | UI | tagged | غالباً ما تُبرز الأجسام القابلة للإمساك بها باللون <h>الأصفر</>. | Objects that you can grab onto are often highlighted in <h>yellow</>. |
| 35 | NewP5 | UI | tagged | إذا فاجأت عدوًا، يمكنك التسلل إليه وطرحه أرضًا دون إطلاق إنذار. <h>لتنفيذ قتلة خادعة، اقترب من الخلف واضغط</> <tag id="InputAction.Gameplay.StealthKill"/>. أسرع، وإلا فقد تفقد عنصر المفاجأة. | If you catch an enemy unawares, you can sneak up and knock them out without raising the alarm. <h>To perform a stealth kill, approach from behind and press</> <tag id="InputAction.Gameplay.StealthKill"/>. Be quick, or you might lose the element of surprise. |
| 36 | Vavilov_Dialogues | Dialogue | spread | *0.11*أوه، لا أعرف. لقد انتهت صلاحيته، إن جاز التعبير. أظن أن اللقاح هو السبب في كل هذا — أعني أن الموتى صاروا ثرثارين. *0.04*نشاط دماغي متبقٍ أو شيء من هذا القبيل. ماذا يمكن أن يكون غير ذلك؟ | *0.11*Oh, I don't know. He kinda expired, so to speak. I think this must all be the vaccination's fault—dead people being so chatty, I mean. *0.04*Residual brain activity or something. What else could it be? |
| 37 | DIALOGUES FOR LQA | Dialogue | spread | *0.08*لا، لا، لا! لا نضيّع الوقت، اتفقنا؟ لم يبقَ منّي إلا القليل! انظر، لقد أجريت التحليل! *0.07*أجريت كل الحسابات! صدى الشبكة العصبية هذا الذي يسمح للموتى بالكلام — إنه مفتاح الخلود! | *0.08*No, no, no! Let's not waste time, okay? There's barely anything left of me! Look, I did the analysis! *0.07*I did all the calculations! This neural network echo that allows the dead to talk — it's the key to immortality! |
| 38 | NewP5 | UI | spread | ملء الشاشة | Fullscreen |
| 39 | PearTerminals | UI | spread | مسودة أولية | Rough draft |
| 40 | NewP5 | UI | spread | العودة إلى المنشأة 3826 | Return to Facility 3826 |
