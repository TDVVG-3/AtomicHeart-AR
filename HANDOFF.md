# HANDOFF

**Date/time:** 2026-10-18 21:36 (+03:00)  |  **Cycle:** 008  |  **Step:** pilot gate - install p3, reviewer fixes, speaker-marker check  |  **State:** WAITING FOR USER (p3 IS INSTALLED - run the pilot check and report)

---

## Summary (5 lines)

1. Pilot carrier **p3 is installed** exactly as ordered: the old carrier p2 was removed (hash-verified
   against the previous manifest), p3 was installed, font v2 was left untouched, and the manifest was
   rewritten - proven by a before/after snapshot: **nothing else in the game folder changed**.
2. **Python is declined**: `scripts/validate_translation.ps1` stays the authoritative validator;
   KI-020 is closed. All 26 glossary questions are **accepted as recommended**; you review the
   sensitive terms after batch 1.
3. Your three pilot corrections are applied to the master, the translation memory and the seed CSV
   (4 master rows: the grammar fix touched both the Theatre and its identical LQA sibling), the
   validator re-passes with 0 errors, and the reference was regenerated - **no pak was rebuilt**,
   so the fixes ship in p4 with the pilot results, exactly as you asked.
4. Speaker markers are a **DLC2-only** phenomenon: 130 rows, 145 distinct tokens, all inside the three
   "Schebetars" scopes - the base game has none. `reports/speaker_marker_check.md` tells you exactly
   what to look at, and the "translate the names" rule is written and ready to activate if you see them.
5. Coverage is unchanged at **85 of 27,618 (0.3%)** - this cycle only installed, corrected and
   investigated. Batches 1-4 have not started; they wait for your pilot report and your "next".

---

## 1. Completed

- Cycle opening ritual: spec hash check PASS (`579f581e...61c35`); the spec was not touched.
- User task 1 (install, APPROVED): `scripts/install_mod.ps1` was rewritten from a fixed two-file
  installer into a **reconciling** installer - it removes only files it previously installed (each
  verified against the old manifest's sha256) and installs the requested set, then verifies the
  folder contents and prints every hash. Result:
  - removed, hash-verified: `zzz_atomicheart-ar_carrier_koKR_p2_P.pak`
    (sha256 `3d4b0ea65c5dc789be98b46aa18c7c27959445b7d36454616b91be2ae55fa9e1` - matched the old manifest)
  - installed: `zzz_atomicheart-ar_carrier_koKR_p3_P.pak`
    (sha256 `b58029662e5acf775087426ed85721905a5846127d6af5c209a482514f7b41df`, 3,612,753 bytes)
  - kept: `zzz_atomicheart-ar_font_p2_plex_P.pak`
    (sha256 `02b17f31e61a46ddba20bea8c4da5be44164173df608d52697f68d27d8269747`)
  - manifest rewritten: sha256 `346abd7f291f36d7aa033785c4e16d8dc9272e24d5d59443477130bc215298bd`
- User task 1d/1e (proof): new tools `scripts/snapshot_game_folder.ps1` (read-only before/after
  snapshot) and `scripts/verify_install.ps1` -> **PASS**: no file or directory added, removed or
  changed anywhere in the game folder outside `Paks\~mods`; `AtomicHeart.exe` unchanged; 19/19 stock
  paks unchanged; `~mods` holds **exactly** carrier p3 + font v2 + manifest.
  Evidence: `reports/install_verification.md`, before-snapshot `reports/install_verify/before_p3.json`.
- User task 2 (Python): recorded as DECLINED; `scripts/validate_translation.ps1` is the primary and
  authoritative validator; the `.py` twin stays as a delivered artefact. **KI-020 closed.**
- User task 3 (glossary): `glossary/glossary_questions.md` records that **all 26 recommended
  defaults are accepted** (2026-10-18), with the sensitive groups (robot nicknames, science/Soviet
  terms, tone) flagged for your review after batch 1.
- User task 4 (three reviewer fixes; master + memory, NO pak rebuild):
  - (a) grammar fix, 2 rows - `Theatre_Dialogues` **and** its identical sibling `DIALOGUES FOR LQA`
    (both hold the same key `/962A2FA3462F1CE524EB09B650D0C297`, so both had the same phrase);
  - (b) stealth-kill game tip, 1 row (`NewP5`, key `ST_GameTips_Texts_/esli_protivnik_stoit_spinoy`);
    the `<h>...</>` and `<tag id="InputAction.Gameplay.StealthKill"/>` are byte-unchanged;
  - (c) surgeon "Swab", 1 row (`Schebetar_Subs`, key `/9511248745986BD47D906A9DB6D80DE0`).
  - Mechanics: rules live in the UTF-8 data file `localization/working/tm_fixups.tsv` (never as
    literals inside a script, KI-021) and are applied by `scripts/apply_text_fixups.ps1` to the
    master Arabic column, `localization/working/tm.tsv` and `localization/working/phase7_seed.csv`.
    The pass is idempotent (second run changes 0 rows). Log: `reports/text_fixups_log.md`.
  - Proof: `scripts/verify_text_fixups.ps1` -> **PASS** (old text gone from master and memory, new
    text present, master vs memory 85/85 identical); `scripts/validate_translation.ps1` -> **PASS,
    0 errors, 1 accepted warning**; `localization/references/AR_EN_REFERENCE.md` regenerated (85 rows).
- User task 5 (speaker markers): evidence scan `scripts/speaker_markers.ps1` ->
  `reports/speaker_markers.md`: 130 rows carry a `&Speaker&` marker, 145 distinct tokens, and they
  exist **only** in DLC2 "Schebetars" (`Schebetar_Subs` 90, `Schebetars_dlc1` 39, `Locations_dlc2` 1);
  the base game has none. `reports/speaker_marker_check.md` = the short in-game check (three possible
  outcomes and what each means). The conditional rule (characters transliterated, roles translated,
  non-verbal cues translated, unit names per glossary, delimiters always Latin `&`) was added to
  `glossary/terminology.md` section 10 and to DEC-025; it activates only if you see the names.
- Standing docs updated: `STATUS.md` (Cycle 008 block), `KNOWN_ISSUES.md` (KI-020 closed),
  `DECISIONS.md` (DEC-025), `glossary/terminology.md` (sections 10 and 11).

## 2. Problems (and what I did)

| # | problem | status | action taken |
|---|---|---|---|
| 1 | The old installer installed a hardcoded two-file set, so it could not "remove only p2 and keep font v2" | FIXED | `install_mod.ps1` is now a reconciling installer: it deletes only files recorded in the previous manifest whose on-disk sha256 matches; any mismatch aborts instead of deleting |
| 2 | Two pilot rows held the same grammar error (Theatre + its LQA sibling, same key); you named only the Theatre row | HANDLED, tell me if you disagree | applied the fix to both, because the Arabic was identical and the sibling would otherwise keep a known error; log lists both rows |
| 3 | PowerShell 5.1 mangles non-ASCII literals inside `.ps1` files (KI-021) | WORKED AROUND | reviewer fixes are stored as UTF-8 data (`tm_fixups.tsv`) and applied/verified by scripts that contain no Arabic |
| 4 | `-f` inside a method-argument list mis-parses (`.Add('...' -f a, b)`) | FIXED | formatted values are assigned to variables first; same known PowerShell 5.1 trap as before |
| 5 | Python not installed (Store alias stub, exit 9009) | CLOSED by your decision | KI-020 closed; PowerShell validator is authoritative |

## 3. Evidence (labels: PASS / FAIL / PARTIAL / BLOCKED / NOT TESTED; confidence CONFIRMED / LIKELY / UNKNOWN)

| item | label | confidence | evidence file |
|---|---|---|---|
| spec hash unchanged this cycle | PASS | CONFIRMED | `579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35` |
| p2 removed hash-verified (it is really gone) | PASS | CONFIRMED | `reports/install_verification.md` |
| p3 installed, bytes match the built artefact | PASS | CONFIRMED | `reports/install_verification.md` (`b5802966...f7b41df`) |
| font v2 untouched | PASS | CONFIRMED | `reports/install_verification.md` (`02b17f31...8269747`) |
| ~mods holds exactly the 3 expected files | PASS | CONFIRMED | `reports/install_verification.md` |
| nothing else in the game folder changed | PASS | CONFIRMED | before/after snapshot diff, `reports/install_verify/before_p3.json` |
| EXE and 19/19 stock paks unchanged | PASS | CONFIRMED | `reports/install_verification.md` |
| reviewer fixes applied everywhere | PASS | CONFIRMED | `reports/text_fixups_log.md`, `scripts/verify_text_fixups.ps1` |
| master Arabic == memory (85/85) after the fixes | PASS | CONFIRMED | `scripts/verify_text_fixups.ps1` output |
| validator after the fixes | PASS (0 errors, 1 warning) | CONFIRMED | `reports/translation_validation.md` |
| speaker markers are DLC2-only (130 rows / 145 tokens) | PASS | CONFIRMED | `reports/speaker_markers.md` |
| markers shown to the player? | NOT TESTED | UNKNOWN | `reports/speaker_marker_check.md` (yours) |
| Arabic subtitles render in game | NOT TESTED | UNKNOWN | pilot check Area D (yours) |
| game tips with inline icons render correctly | NOT TESTED | UNKNOWN | pilot check Area E (yours) |
| p3 fixes the KI-019 tip tags in game | NOT TESTED | LIKELY | KI-019, Area E (yours) |

## 4. Files changed (this cycle, all local - nothing uploaded)

New tools:
- `scripts/snapshot_game_folder.ps1`, `scripts/verify_install.ps1` (install proof)
- `scripts/apply_text_fixups.ps1`, `scripts/verify_text_fixups.ps1` (reviewer-fix workflow)
- `scripts/speaker_markers.ps1` (marker evidence)

Rewritten / edited:
- `scripts/install_mod.ps1` (hardcoded two-file installer -> reconciling installer)
- `localization/master/atomic-heart-ar.tsv` (4 rows corrected; still 27,618 rows, 85 with Arabic)
- `localization/working/tm.tsv` (4 entries corrected), `localization/working/phase7_seed.csv` (1 value)
- `localization/references/AR_EN_REFERENCE.md` (regenerated, 85 rows)
- `STATUS.md`, `KNOWN_ISSUES.md` (KI-020 closed), `DECISIONS.md` (DEC-025),
  `glossary/terminology.md` (sections 10, 11), `glossary/glossary_questions.md` (defaults accepted)

New data:
- `localization/working/tm_fixups.tsv` (the three reviewer fixes as UTF-8 data)

New reports:
- `reports/install_verification.md`, `reports/text_fixups_log.md`, `reports/speaker_markers.md`,
  `reports/speaker_marker_check.md`, `reports/review_sample.md` (refreshed), this file

Installed into the game folder (this cycle, with your approval - the ONLY files we ever write there):
- added `~mods\zzz_atomicheart-ar_carrier_koKR_p3_P.pak`, rewrote `~mods\atomic-heart-ar-install-manifest.json`,
  removed `~mods\zzz_atomicheart-ar_carrier_koKR_p2_P.pak`

Not touched: `AtomicHeart.exe`, any DLL, Steam/Denuvo files, the 19 stock paks, any other game file.
No uploads (`git remote -v` is empty).

## 5. Current Status

- Installed in `Paks\~mods` right now (**verified exactly these three**):
  | file | size | sha256 |
  |---|---|---|
  | `zzz_atomicheart-ar_carrier_koKR_p3_P.pak` | 3,612,753 | `b58029662e5acf775087426ed85721905a5846127d6af5c209a482514f7b41df` |
  | `zzz_atomicheart-ar_font_p2_plex_P.pak` | 1,461,408 | `02b17f31e61a46ddba20bea8c4da5be44164173df608d52697f68d27d8269747` |
  | `atomic-heart-ar-install-manifest.json` | 1,823 | `346abd7f291f36d7aa033785c4e16d8dc9272e24d5d59443477130bc215298bd` |
  | (removed) `..._carrier_koKR_p2_P.pak` | was 503,841 | was `3d4b0ea65c5dc789be98b46aa18c7c27959445b7d36454616b91be2ae55fa9e1` |
- Coverage: **85 of 27,618 (0.3%)** - the pilot only; everything else is English-filled.
- Master statuses: 27,533 UNTRANSLATED, 85 DRAFT, 0 TECHNICAL, 0 BLOCKED.
- The installed p3 does NOT contain this cycle's three text fixes (you ordered "install p3 as built";
  they go into p4 together with the pilot results), so if you look at the stealth-kill tip or the
  surgery scene in game you will still see the old wording - that is expected.
- Language must stay **Korean** in game (the carrier occupies the ko-KR slot).
- Batches 1-4 have not started.

## 6. Next Action

1. You run the pilot check: `reports/pilot_in_game_checklist.md` (areas A-G; D = subtitles and
   E = game-tip icons matter most) plus the one speaker-marker question in
   `reports/speaker_marker_check.md`, and send the result back.
2. I record the result (STATUS/KNOWN_ISSUES/DECISIONS/HANDOFF + history) and commit.
3. On your "next" I start batch 1: 25%, cumulative 6,905 rows / 4,562 unique, last scope
   `Chelomey_Dialogues`; then the p4 carrier (pilot text fixes included).

## 7. What I need you to do

- Run the pilot check and send back the filled block from section 5 of
  `reports/pilot_in_game_checklist.md` (or just tell me what you saw).
- Answer the speaker-marker question in `reports/speaker_marker_check.md` (three cases A/B/C, or
  "not reached" if you cannot get into DLC2 dialogue - that is a fine answer).
- Say "next" when you want batch 1 to start (one batch per "next" message).
- Optional: review the sensitive glossary groups after batch 1 (already accepted as defaults now).

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
| DEC-025 | p3 install (reconciling installer + before/after proof); Python declined; all 26 glossary defaults accepted; 3 reviewer fixes via `tm_fixups.tsv` (no pak rebuild); speaker-marker rule (DLC2-only, conditional) |

## Known issues (current)

| id | state | one-line |
|---|---|---|
| KI-009 | PARTIAL-CONFIRMED | menu + settings render Arabic (A); GameTips + subtitles still NOT TESTED (pilot Areas D/E) |
| KI-013 | OPEN | native `ar` language entry needs DA_Audio schema tooling (Phase 8) |
| KI-017 | BLOCKED | one obfuscated cooked asset (NotLifted_17) - evidence only |
| KI-018 | NOTED | 248 RU-only cooked dialogue assets / 6,012 strings need a separate uasset path |
| KI-019 | FIXED in p3, in-game proof pending | p2 shipped broken icon tags in the 7 seeded game tips |
| KI-020 | CLOSED | Python declined by the user; PowerShell validator is authoritative |
| KI-021 | MITIGATED | Arabic must never be a literal inside a `.ps1` (PowerShell ANSI parsing) |
| KI-015 | NOTED | UnrealLocres normalizes LF to CRLF inside multiline values (accepted) |
| KI-016 | NOTED | 728 pre-existing duplicate IDs in the master (cosmetic) |

## What I should send back (to you)

- The pilot in-game report plus the speaker-marker answer (that is the current gate).
- Batch 1 starts only after your "next".

---

## Review sample (40 rows, Arabic first, English below)

The full list of every translated row is in `localization/references/AR_EN_REFERENCE.md`.
This is the standing 40-row per-batch sample: a deterministic spread, the longest rows, and
the tag-bearing rows. Rows 13, 21 and 35 include this cycle's reviewer fixes.

<!-- BEGIN REVIEW SAMPLE -->

| # | scope | cat | why | key | Arabic (what the player sees) | English source |
|---|---|---|---|---|---|---|
| 1 | NewP5 | UI | spread | `/40EF37E64730E4A368EA709B9D62FE92` | تكنوستاسيس | Technostasis |
| 2 | NewP5 | UI | spread | `/DB51C872475733ED3F563EA0ED902A7E` | أحواض الدلافين | Dolphin Enclosures |
| 3 | NewP5 | UI | spread | `AHGameSettings/PERFORMANCE` | الأداء | Performance |
| 4 | NewP5 | UI | spread | `ST_MenuText/Men_exitpopup` | إنهاء اللعبة | Quit game |
| 5 | NewP5 | UI | spread | `/0B4FE5CE4A7BB60F4C06968E4B407AB9` | للقفز فوق جسم أو التسلّق عليه، اضغط <tag id="InputAction.Gameplay.jump"/>. | To vault or climb an object, press <tag id="InputAction.Gameplay.jump"/>. |
| 6 | NewP5 | UI | spread | `/415286224249C4324C7B50A0137D83C1` | الاندفاع أثناء القفز | Dashing while jumping |
| 7 | NewP5 | UI | spread | `/81193D4F4C38C8F13C5C3997B7B581DB` | HAWK غير معرّف | UNIDENTIFIED HAWK |
| 8 | Pavlov_Dialogues | Dialogue | spread | `/0136DBEB4EF88FFA06F2159616DE3977` | *0.08*لا أستطيع الجزم. ربما تكون المسألة مسألة راحة. أجهزة THOUGHT تحتاج إلى إعادة ضبط في كل مرة تُلبَس. *0.04*أما الخاتم فيمكن خلعه وإلباسه من جديد دون عناء. | *0.08*I can't say for sure. Perhaps it's an issue of convenience. THOUGHT devices need to be reconfigured every time they are put on. *0.04*A ring can be taken off and put back on without inconvenience. |
| 9 | Schebetar_Subs | Subtitles | spread | `/E50AF2A6487B6F7E0D4981819B984984` | *0.00-0.08* &Ministry of Culture curator& هذه مكنسة روبوتية أو "مكنسة روبوت". إنها رائعة تماماً! انظروا فقط كيف تتحرّك بالحركة البطيئة!*0.08-0.10* &Ministry of Culture curator& حسناً، لنرَ...*0.10-0.18* &Ministry of Culture curator& لها جسم مستطيل وكتفان ضيّقان جداً، ما يتيح لها شفط الأوساخ في أي مكان تقريباً.*0.18-0.28* &Ministry of Culture curator& انظروا إلى كل هذه القمامة في كل مكان! لكن المكنسة الروبوتية لا تهتم، إنها تدمّر كل ذلك الخردة وتواصل شفط الأوساخ.*0.29-0.39* &Ministry of Culture curator& أوه، لقد سكب أحدهم دلو دهان على المكنسة الروبوتية!*0.39-0.45* &Ministry of Culture curator& لكن المكنسة تتصرّف وكأنها لم تلاحظ أن الدهان اللزج تغطّى بها. انظروا إلى هذا الوغد — سينظّف كل شيء، وسيواصل الشفط فقط!*0.46-0.53* &Ministry of Culture curator& فهمت يا دميتري؟ هكذا يجب أن نفتح أعين مواطنينا على الأشياء المذهلة التي نصنعها هنا في المنشأة، لا ذلك الشريط الباهت*0.53-1.01* &Ministry of Culture curator& "مصنع زابوريجيا للسيارات يقدّم الطراز ROZGDFG-20 أو 40 أو أيّاً كان..." إنه ممل حتى الموت. | *0.00-0.08* &Ministry of Culture curator& This is a robot vacuum or "robo-vacuum." It's totally bad ass! Just look at it moving in slow motion!*0.08-0.10* &Ministry of Culture curator& Okay, let's see...*0.10-0.18* &Ministry of Culture curator& It's got an elongated body and very narrow shoulders, which allows it to suck up dirt in almost any area.*0.18-0.28* &Ministry of Culture curator& Just look at all the trash everywhere! But the robo-vacuum doesn't give a crap, it just destroys all that junk and keeps on sucking up the dirt.*0.29-0.39* &Ministry of Culture curator& Uh-oh, someone spilled a bucket of paint on the robo-vacuum!*0.39-0.45* &Ministry of Culture curator& But the robo-vacuum acts like it doesn't even notice it got sticky paint all over it. Look at that fucker—it'll just clean everything up, and it'll just keep on sucking!*0.46-0.53* &Ministry of Culture curator& Get it, Dmitry? That's how we need to open our fellow citizens' eyes to the amazing things we make here at the Facility, not your lame old*0.53-1.01* &Ministry of Culture curator& "the Zaporizhzhia Automotive Factory presents model ROZGDFG-20 or 40 or whatever..." It's boring to death. |
| 10 | NewP5 | UI | spread | `ST_GameTips_Texts_/chtobi_uklonyatsya` | للمراوغة بين الهجمات والأجسام الطائرة والمقذوفات، اضغط <tag id="InputAction.Gameplay.Dodge"/> أثناء التحرك. | To dodge attacks, flying objects, and projectiles, press <tag id="InputAction.Gameplay.Dodge"/> while moving. |
| 11 | VDNKh_Dialogues | Dialogue | spread | `/BC80AD6147CE2576762634AE7971F2E0` | إليك ذراعك اليسرى. تفضّل وأصلح نفسك. | Here's your left arm. Go ahead and fix yourself up. |
| 12 | NewP5 | UI | spread | `AHGameSettings/Borderless Window` | ملء الشاشة بإطار نافذة | Windowed Fullscreen |
| 13 | Theatre_Dialogues | Dialogue | spread | `/962A2FA3462F1CE524EB09B650D0C297` | *0.08*أتقول ذلك حقاً؟! أتُظهر أنيابك؟ يا له من تعبير بديع، وإن كان سوقياً. تذكّر يا فتى: *0.04*أن تنفخ صدرك وتتفاخر بالشخصية لا يعني أنك تملك تلك الشخصية فعلاً. | *0.08*You don't say?! Are you showing your teeth? What a delightful, if plebeian, expression. Remember, boy: *0.04*puffing your chest and showing off the character does not mean you are actually in possession of said character. |
| 14 | NewP5 | UI | spread | `ST_MenuText/menu_titles` | فريق العمل | Credits |
| 15 | PearTerminals | UI | spread | `/FD32B8A242D61151C033EFA20EEE90B3` | نادي الشطرنج | Chess club |
| 16 | NewP5 | UI | spread | `/B27E32FD4EAE23C949FC7BB3F6B800D5` | هوارد فيليبس لوفكرافت | H. P. Lovecraft |
| 17 | VDNKh_Dialogues | Dialogue | spread | `/61E6E69F4F621A89D6CCB8BC7863FFFF` | الأسلحة الآلية: واحد. الكاراتيه: صفر. | Automatic weapons, one. Karate, zero. |
| 18 | Chelomey_Dialogues | Dialogue | spread | `/BC1D6CD849ABD1FB2CC273976D4A2AD3` | ماذا تعني بـ"نوع جديد"؟ جديد كيف؟ | What do you mean, "new type?" New how? |
| 19 | NewP5 | UI | spread | `AHGameSettings/BALANCED` | متوازن | Balanced |
| 20 | OpenWorldVDNKh_Dialogues | Dialogue | spread | `/B857B2AB48656A1EE2AEEC8DB9BC524C` | *0.06*وكيف لي أن أفعل؟ دهستني الجرّارة أول أمس، وما زلت ملقى في الخندق منذ ذلك الحين. *0.10*كنت أنتظر من يصطدم بي، لكن هذا المكان مهجور تماماً. طريق قلّ سالكوه، كما يقولون، صحيح؟ | *0.06*How can I? The tractor ran me over the day before yesterday, and I've been lying in the ditch ever since. *0.10*I've been waiting for someone to bump into me, but this place is positively deserted. A road less traveled and all that, right? |
| 21 | Schebetar_Subs | Subtitles | longest | `/9511248745986BD47D906A9DB6D80DE0` | *0.05-0.09* &Surgeon& قطنة. ركّزوا. راقبوا ذلك الشق!*0.09-0.10* &Nurse& حسناً... لحظة واحدة...*0.10-0.11* &Surgeon& ركّزوا!*0.16-0.18* &Surgeon& تبا. اضغطوا عليه، الآن!*0.22-0.25* &Surgeon& لم يتشرّبه النسيج بالبوليمر مجدداً، فأنشأ تجويفاً مرضياً.*0.26-0.32* &Surgeon& هناك عقد كهذه في كل جسده. ماذا تريد تلك الوحوش بلا قلب من الناس، هاه؟!*0.33-0.41* &Colonel& قد تكونون محقّين أيها الرفاق، لكن هذا ليس شأنكم. أدّوا عملكم. أيها الجندي، أدخل التالي.*0.42-0.43* &Private& نعم، أيها الرفيق العقيد.*0.44-0.50* &Colonel& يجب أن يتشرّب النسيج البوليمر. وإن لم يفعل، أنقذوا من تستطيعون إنقاذه...*0.51-0.53* &Colonel& ...ونظّفوا هذا المكان. | *0.05-0.09* &Surgeon& Swab. Focus. Keep an eye on that incision!*0.09-0.10* &Nurse& Okay... just a moment...*0.10-0.11* &Surgeon& Focus!*0.16-0.18* &Surgeon& Shit. Pressure on it, now!*0.22-0.25* &Surgeon& The Polymer wasn't absorbed by the tissue again, so it created a pathological cavity.*0.26-0.32* &Surgeon& There are nodules like this all over his body. What do those heartless animals want from people, huh?!*0.33-0.41* &Colonel& You may be right, comrades, but that is not your concern. Do your jobs. Private, bring in the next one.*0.42-0.43* &Private& Yes, Comrade Colonel.*0.44-0.50* &Colonel& The Polymer needs to be absorbed. And if it's not, save whoever you can...*0.51-0.53* &Colonel& ...And clean this place up. |
| 22 | Schebetar_Subs | Subtitles | longest | `/A2103A53484B5DBD9475938EDC04C376` | *0.00-0.06* &Goopy electrician& وماذا لو كانت روبوتاً؟ لم يكن الناس لطفاء معي يوماً. أما هي فلطيفة. الطريقة التي تنظر بها إليّ... *0.07-0.15* &Goopy electrician& كأن في عينيها تياراً من طاقة نقية. وهي تفهمني. أفضل مما فعلت أي فتاة. على أي حال، اتخذت قراري. سأطلب يدها غداً.*0.16-0.19* &Angry voice& ماذا تفعل هنا بحق الجحيم يا فاسيليتش؟ هل تعمل هنا أم لا؟*0.20-0.22* &Vasilitch& تبا... قادم! | *0.00-0.06* &Goopy electrician& So what if she's a robot? People have never been nice to me. But she is. The way she looks at me... *0.07-0.15* &Goopy electrician& It's like there's a stream of pure energy in her eyes. And she understands me. Better than any girl ever has. Anyway, I've made up my mind. I'm proposing to her tomorrow.*0.16-0.19* &Angry voice& What the fuck are you doing here, Vasilitch? Are you working here or not?*0.20-0.22* &Vasilitch&Shit... I'm coming! |
| 23 | Polygon_Dialogues | Dialogue | longest | `/AC2F37D6452B6C67A19A3A9A6BECFF7D` | *0.04*قسم التخطيط في ميدان الاختبار رقم 6 مسؤول عن:  *0.05*1. الحصول على حلول إنشاء ورش الاختبار المستقبلية ودعمها.  *0.07*2. إعداد التصاميم الإنشائية لإعادة بناء وترميم وبناء المباني الجديدة.  *0.05*3. إعداد المواصفات التصميمية والتقديرات لأعمال البناء.  *0.04*4. تحضير بيانات العمل المتعلقة بالتخطيط. | *0.04*Testing Ground #6's Planning Department is responsible for:  *0.05*1. Obtaining and supporting solutions for the construction of future testing workshops.  *0.07*2. Producing construction designs for the reconstruction, repair, and construction of new buildings.  *0.05*3. Producing design specifications and estimates for construction jobs.  *0.04*4. Preparing planning-related statements of work. |
| 24 | Chelomey_Dialogues | Dialogue | longest | `/B0DD819448F77EBBB149729CA05FFE18` | *0.10*يمكنك الآن مشاهدة عمليات مصنع آلي يجمّع الروبوتات ويوزّع القطع الميكانيكية التي تحتاجها مجمّعات المنشأة المختلفة. *0.10*ومصنع كهذا، تتحكّم به عن بُعد عقدة من كوليكتيف 1.0، قادر على إدارة ما يصل إلى مئة طلب في الساعة وتنفيذها باستقلالية تامة. | *0.10*You can now observe the operations of an automated plant, performing robot assembly and distributing machine parts required by the Facility's various complexes. *0.10*Controlled remotely by a Kollektiv 1.0 node, a plant such as this is capable of autonomously managing and fulfilling up to a hundred orders per hour. |
| 25 | NewP5 | UI | tagged | `ST_GameTips_Texts_/zazhmite_i_uderzhivayte` | لفتح عجلة الجرد، اضغط مع الاستمرار على <tag id="InputAction.Gameplay.RadialMenu"/>. | To open the Inventory Wheel, press and hold <tag id="InputAction.Gameplay.RadialMenu"/>. |
| 26 | NewP5 | UI | tagged | `ST_GameTips_Texts_/nazhmite_slabiy_udar` | لإحداث ضرر خفيف، اضغط <tag id="InputAction.Gameplay.EquippedItemPrimaryAction"/>. هذه الضربات سريعة لكنها ليست قوية للغاية. | To deal light damage, press <tag id="InputAction.Gameplay.EquippedItemPrimaryAction"/>. Such attacks are fast but not particularly hard-hitting. |
| 27 | NewP5 | UI | tagged | `/BC6802EC46CE674AFC50749045219D52` | للخروج من البوليمر، استخدم <tag id="InputAction.Gameplay.Dodge"/>. | To emerge from the Polymer, use <tag id="InputAction.Gameplay.Dodge"/>. |
| 28 | NewP5 | UI | tagged | `/3DB8E81848CDC42CF3FA40A19CD43CEA` | تسلّق الأجسام بالضغط على <tag id="InputAction.Gameplay.Jump"/> بجانبها. | CLIMB objects by PRESSING <tag id="InputAction.Gameplay.Jump"/> next to them. |
| 29 | NewP5 | UI | tagged | `ST_GameTips_Texts_/vi_raneni` | لقد جُرحت! اضغط مع الاستمرار على <img id="Button.ConsumeItem"/> للعلاج | You've been injured! Press and hold <img id="Button.ConsumeItem"/> to heal |
| 30 | NewP5 | UI | tagged | `/D75D44284FEF0ED201C9B5965BEECFAB` | لتشغيل الماسح، استمرّ بالضغط على <tag id="InputAction.Gameplay.Scannner"/>. | To activate the scanner, hold <tag id="InputAction.Gameplay.Scannner"/>. |
| 31 | NewP5 | UI | tagged | `ST_GameTips_Texts_/protivniki_mogut_ispolzovat` | يمكن للأعداء تنفيذ ضربات قوية تُسقط P-3 إذا أصابته. عندما يستعد عدو لضربة قوية، سيشير تشارلز إلى أفضل لحظة للمراوغتها. عند رؤية التمييز الأحمر، <h>اضغط</> <tag id="InputAction.Gameplay.Dodge"/> للمراوغة. | Enemies can perform power attacks that knock P-3 down if they hit. When an enemy is charging a power attack, CHARLES will indicate the best moment to dodge it. Upon seeing the red highlight, <h>press</> <tag id="InputAction.Gameplay.Dodge"/> to dodge. |
| 32 | NewP5 | UI | tagged | `ST_GameTips_Texts_/sbor_resursov_2` | لجمع الموارد وسلب الأعداء، اضغط مع الاستمرار على <tag id="InputAction.Gameplay.Use"/>. | To collect resources and loot enemies, press and hold <tag id="InputAction.Gameplay.Use"/>. |
| 33 | NewP5 | UI | tagged | `/EF751A1342225BE3D42CB1A1DEF3A564` | الوصفة {0} مفتوحة بالفعل! | {0} recipe already unlocked! |
| 34 | NewP5 | UI | tagged | `/BBC40EA74D9F49E660961781E552A7F1` | غالباً ما تُبرز الأجسام القابلة للإمساك بها باللون <h>الأصفر</>. | Objects that you can grab onto are often highlighted in <h>yellow</>. |
| 35 | NewP5 | UI | tagged | `ST_GameTips_Texts_/esli_protivnik_stoit_spinoy` | إذا فاجأت عدوًا، يمكنك التسلل إليه وطرحه أرضًا دون إطلاق إنذار. <h>لتنفيذ تصفية خفية، اقترب من الخلف واضغط</> <tag id="InputAction.Gameplay.StealthKill"/>. أسرع، وإلا فقد تفقد عنصر المفاجأة. | If you catch an enemy unawares, you can sneak up and knock them out without raising the alarm. <h>To perform a stealth kill, approach from behind and press</> <tag id="InputAction.Gameplay.StealthKill"/>. Be quick, or you might lose the element of surprise. |
| 36 | Vavilov_Dialogues | Dialogue | spread | `/CD81CACE4DCFD2A7E3E24CB16B0B9D52` | *0.11*أوه، لا أعرف. لقد انتهت صلاحيته، إن جاز التعبير. أظن أن اللقاح هو السبب في كل هذا — أعني أن الموتى صاروا ثرثارين. *0.04*نشاط دماغي متبقٍ أو شيء من هذا القبيل. ماذا يمكن أن يكون غير ذلك؟ | *0.11*Oh, I don't know. He kinda expired, so to speak. I think this must all be the vaccination's fault—dead people being so chatty, I mean. *0.04*Residual brain activity or something. What else could it be? |
| 37 | DIALOGUES FOR LQA | Dialogue | spread | `/B56010C94E3ACF20E0F087B81E9CC41C` | *0.08*لا، لا، لا! لا نضيّع الوقت، اتفقنا؟ لم يبقَ منّي إلا القليل! انظر، لقد أجريت التحليل! *0.07*أجريت كل الحسابات! صدى الشبكة العصبية هذا الذي يسمح للموتى بالكلام — إنه مفتاح الخلود! | *0.08*No, no, no! Let's not waste time, okay? There's barely anything left of me! Look, I did the analysis! *0.07*I did all the calculations! This neural network echo that allows the dead to talk — it's the key to immortality! |
| 38 | NewP5 | UI | spread | `AHGameSettings/Fullscreen` | ملء الشاشة | Fullscreen |
| 39 | PearTerminals | UI | spread | `/78F56146484B8E04AD8CA3B14755A710` | مسودة أولية | Rough draft |
| 40 | NewP5 | UI | spread | `ST_MenuText/menu_openworld` | العودة إلى المنشأة 3826 | Return to Facility 3826 |

<!-- END REVIEW SAMPLE -->
