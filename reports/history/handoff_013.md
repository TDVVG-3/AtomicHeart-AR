# HANDOFF

**Date/time:** 2026-10-18 22:28 (+03:00)  |  **Cycle:** 009  |  **Step:** pilot result recorded + opening-scene Arabic proof build (carrier p4 installed)  |  **State:** WAITING FOR USER (p4 IS INSTALLED - run the bridge check and report)

---

## Summary (5 lines)

1. Your pilot result is recorded: on the bridge the subtitle showed the carrier's **English** where
   Korean had been before - so carrier p3 **does** reach the dialogue/subtitle scopes at runtime,
   not only the menu and settings text (KI-009 updated).
2. Your truncation question is answered: the string on disk is complete (431 chars) and the pak
   round-trip loses nothing; the visible text began **exactly at the second timing marker**, so the
   game plays each row in marker-defined parts. Whether a part longer than the panel is clipped or
   scrolled stays NOT TESTED and is checklist item 4 (`reports/subtitle_display_finding.md`, KI-022).
3. The scene is found and translated: scope **`Chelomey_Dialogues`**, the on-screen row is
   `/DC11CB9A4BFFB0AA5E099DAA4057EEE9`, and the scene is master lines 284-324 of that asset -
   **40 new rows** (11 speech + 29 crowd labels) plus 1 speech row that already had pilot Arabic.
4. Carrier **p4 is built and installed** (reconciling install: p3 removed hash-verified, font v2
   untouched, before/after snapshot PASS). p4 = p3 + your three cycle-008 fixes + the 40 scene rows,
   so the stealth-kill tip and the surgery line now show the corrected wording too.
5. Coverage is **125 of 27,618 (0.45%)**. Batches 1-4 are still not started; they start on your "next".

---

## 1. Completed

- Cycle opening ritual: spec hash check PASS (`579f581e...61c35`); the spec was not touched.
- **Pilot result recorded** (your report, 2026-10-18): the bridge subtitle in quest "NO REST FOR THE
  WICKED" (objective "Cross the bridge") showed the carrier's English text where Korean appeared
  before. `STATUS.md` (Cycle 009 block), `KNOWN_ISSUES.md` (KI-009), `DECISIONS.md` (DEC-026 part 1).
- **Truncation question answered** (`reports/subtitle_display_finding.md`):
  - the locres string is complete: 431 chars, 3 `*0.10*` markers; the carrier round-trip of all
    27,618 keys has 0 failures, so nothing is cut when the pak is built;
  - the ko-KR locres holds the same key as one 211-char string with **no** markers; only 7 of the
    1,204 strings of the Korean asset carry markers at all;
  - the screenshot text starts exactly at the 2nd marker boundary - marker-driven parts, CONFIRMED;
  - the mid-word cut is therefore a display-time effect; clip-vs-scroll is NOT TESTED (new KI-022).
- **Scene located** (`scripts/find_rows.ps1`, `reports/scene_search.md`): "step away from amazing
  evolutionary victory" exists in exactly one row - `Chelomey_Dialogues`
  `/DC11CB9A4BFFB0AA5E099DAA4057EEE9` (master line 289). Scene = master lines 284-324 of that asset.
- **Scene translated**: 40 new rows (11 loudspeaker/speech rows + 29 crowd speaker labels), each
  DRAFT, markers/tags/placeholders byte-exact. Row list and Arabic: `reports/scene_opening.md`.
  Arabic lives only in UTF-8 data (`localization/working/scene_opening_ar.tsv` +
  `scene_opening_rows.tsv`); `scripts/scene_apply.ps1` is ASCII-only and verifies the English of
  every row before writing (KI-021). The apply pass is idempotent (2nd run: 40/40 already identical).
- **Pipeline**: validator PASS (125 translated, 0 errors, 2 warnings - 1 new number-as-word, 1
  pre-existing), glyph gate PASS (113 codepoints, 0 missing), reference regenerated (125 rows /
  102 unique / 12 scopes), review sample regenerated (40 rows).
- **Carrier p4 built** (`scripts/build_carrier_locres_pak.ps1`, unchanged builder): 35/35 scopes,
  27,618 keys, 125 Arabic, 27,493 English-filled, 0 kept Korean, 0 round-trip failures, 35/35 unpack
  byte-identical, sha256 `aa894b44...32f22`, 3,614,845 bytes.
- **p4 installed** with `scripts/install_mod.ps1` (your APPROVED order): carrier p3 removed
  hash-verified against the old manifest, font v2 kept untouched, manifest rewritten; proof by
  `scripts/snapshot_game_folder.ps1` + `scripts/verify_install.ps1` -> **PASS** (nothing changed
  outside `Paks\~mods`, EXE unchanged, 19/19 stock paks unchanged).
- **In-game checklist** written: `reports/scene_bridge_ingame_check.md` (how to reach the scene,
  what to look at, what to screenshot).
- Standing docs updated: `STATUS.md`, `KNOWN_ISSUES.md` (KI-009 + new KI-022), `DECISIONS.md`
  (DEC-026).

## 2. Problems (and what I did)

| # | problem | status | action taken |
|---|---|---|---|
| 1 | `$out` in `scene_report.ps1` collided with the `[string]$Out` parameter (PowerShell is case-insensitive), so the report list became a string and `.Add` failed | FIXED | local list renamed; same trap as `$target` before - recorded so it does not recur |
| 2 | The new speech row 286 renders "13th of June" as a word, so the validator's number multiset warning fires | ACCEPTED | warning class is explicit ("numbers legitimately become words in Arabic"); 0 hard errors |
| 3 | `snapshot_game_folder.ps1` prints a blank for `root_files` when the game root holds no files (an empty generic list unrolls to null on return) | KNOWN, HARMLESS | pre-existing behaviour from cycle 008; the diff logic treats an absent list as empty, so the PASS is not weakened |
| 4 | The clip-vs-scroll half of your truncation question cannot be decided from a still frame | OPEN, NOT TESTED | written up as KI-022 and made checklist item 4 (watch the same line for ~5 s) |

## 3. Evidence (labels: PASS / FAIL / PARTIAL / BLOCKED / NOT TESTED; confidence CONFIRMED / LIKELY / UNKNOWN)

| item | label | confidence | evidence file |
|---|---|---|---|
| spec hash unchanged this cycle | PASS | CONFIRMED | `579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35` |
| pilot: carrier reaches the dialogue/subtitle scopes | PASS | CONFIRMED | your report; `KNOWN_ISSUES.md` KI-009 |
| on-disk subtitle string complete (not truncated data) | PASS | CONFIRMED | `reports/subtitle_display_finding.md` |
| subtitle played in marker-defined parts | PASS | CONFIRMED | screenshot text starts at the 2nd marker boundary |
| marker text is interpreted, not printed | PASS | LIKELY | no `*0.10*` visible on screen; the Korean asset keeps markers in 7/1,204 rows |
| part longer than the panel: clipped or scrolled? | NOT TESTED | UNKNOWN | checklist item 4 (yours) |
| scene rows applied, 0 mismatches | PASS | CONFIRMED | `scripts/scene_apply.ps1` output |
| apply is idempotent | PASS | CONFIRMED | 2nd run: 40 already identical, 0 appended |
| validator | PASS (0 errors, 2 warnings) | CONFIRMED | `reports/translation_validation.md` |
| glyph gate | PASS (0 missing) | CONFIRMED | `reports/glyph_gate.md` |
| reference regenerated | PASS (125 rows / 102 unique) | CONFIRMED | `localization/references/AR_EN_REFERENCE.md` |
| p4 round-trip | PASS (0 failures) | CONFIRMED | `reports/carrier_build.md` |
| p4 unpack byte-identical | PASS (35/35) | CONFIRMED | `reports/carrier_build.md` |
| p4 installed, p3 removed, font v2 untouched | PASS | CONFIRMED | `reports/install_verification.md` |
| nothing else in the game folder changed | PASS | CONFIRMED | `reports/install_verify/before_p4.json` + diff |
| Arabic subtitles render in game | NOT TESTED | UNKNOWN | checklist item 1-5 (yours) |
| GameTips popups with inline icons | NOT TESTED | UNKNOWN | pilot Area E (still unreached) |
| speaker markers shown to the player? | NOT TESTED | UNKNOWN | `reports/speaker_marker_check.md` (yours) |

## 4. Files changed (this cycle, all local - nothing uploaded)

New scripts:
- `scripts/scene_apply.ps1` (fills the master + TM for the scene; verifies English first; idempotent)
- `scripts/scene_report.ps1` (writes `reports/scene_opening.md`, including a per-segment length table)
- `scripts/find_rows.ps1` (generic master search tool with a UTF-8 pattern file)

New data:
- `localization/working/scene_opening_rows.tsv` (scope, key, English - generated from the master)
- `localization/working/scene_opening_ar.tsv` (key, Arabic - the 40 authored rows)
- `localization/working/scene_search.txt` (search patterns)

Edited:
- `localization/master/atomic-heart-ar.tsv` (40 rows: Arabic + DRAFT + note `scene:bridge-opening`)
- `localization/working/tm.tsv` (82 -> 102 entries)
- `localization/references/AR_EN_REFERENCE.md` (regenerated, 125 rows)
- `STATUS.md`, `KNOWN_ISSUES.md` (KI-009, KI-022), `DECISIONS.md` (DEC-026)

New reports:
- `reports/scene_opening.md`, `reports/scene_search.md`, `reports/subtitle_display_finding.md`,
  `reports/scene_bridge_ingame_check.md`, `reports/cycle009_results.md`,
  `reports/install_verification.md` (p4), `reports/carrier_build.md` (p4),
  `reports/translation_validation.md`, `reports/glyph_gate.md`, `reports/review_sample.md` (refreshed)

Installed into the game folder (this cycle, your approval - the ONLY files we ever write there):
- added `~mods\zzz_atomicheart-ar_carrier_koKR_p4_P.pak`, rewrote `~mods\atomic-heart-ar-install-manifest.json`,
  removed `~mods\zzz_atomicheart-ar_carrier_koKR_p3_P.pak`

Not touched: `AtomicHeart.exe`, any DLL, Steam/Denuvo files, the 19 stock paks, any other game file.
No uploads (`git remote -v` is empty).

## 5. Current Status

- Installed in `Paks\~mods` right now (**verified exactly these three**):
  | file | size | sha256 |
  |---|---|---|
  | `zzz_atomicheart-ar_carrier_koKR_p4_P.pak` | 3,614,845 | `aa894b4468888ac22a3fd3e58619d4cdb70ae24a895c35f286b002b2f4132f22` |
  | `zzz_atomicheart-ar_font_p2_plex_P.pak` | 1,461,408 | `02b17f31e61a46ddba20bea8c4da5be44164173df608d52697f68d27d8269747` |
  | `atomic-heart-ar-install-manifest.json` | 1,824 | `0f2584c91891d07eca83bb56237a861000d43f634a5c72c9928c7e6b0e9e9da9` |
  | (removed) `..._carrier_koKR_p3_P.pak` | was 3,612,753 | was `b58029662e5acf775087426ed85721905a5846127d6af5c209a482514f7b41df` |
- Coverage: **125 of 27,618 (0.45%)** - 85 pilot rows + 40 new opening-scene rows.
- Master statuses: 27,493 UNTRANSLATED, 125 DRAFT, 0 TECHNICAL, 0 BLOCKED.
- What p4 contains that p3 did not: your three cycle-008 reviewer fixes (grammar, stealth-kill tip,
  cotton-swab line) and the 41-row bridge scene in Arabic.
- Language must stay **Korean** in game (the carrier occupies the ko-KR slot).
- Expected in game: the bridge/street loudspeaker speech in Arabic (Sechenov's welcome), the crowd
  speaker labels in Arabic, and everything not yet translated still in English.
- Batches 1-4 have not started.

## 6. Next Action

1. You run `reports/scene_bridge_ingame_check.md`: walk to the bridge (continue the save or load the
   checkpoint of "NO REST FOR THE WICKED"), watch the Sechenov speech in Arabic, and answer
   checklist item 4 (does the last words of the middle part appear?) plus a screenshot or two.
2. I record the result (STATUS / KNOWN_ISSUES / DECISIONS / HANDOFF + history files) and commit.
3. On your "next" I start batch 1: 25%, cumulative 6,905 rows / 4,562 unique, last scope
   `Chelomey_Dialogues`; then the p5 carrier.

## 7. What I need you to do

- Run the bridge check and send back the answers (or just tell me what you saw); item 4 matters most.
- Still open from last cycle: the speaker-marker question in `reports/speaker_marker_check.md`
  (three cases A/B/C, or "not reached" - that is a fine answer).
- Say "next" when you want batch 1 to start (one batch per "next" message).
- Optional: approve or correct the proposed glossary additions listed in `reports/scene_opening.md`.

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
| DEC-025 | p3 install (reconciling installer + before/after proof); Python declined; all 26 glossary defaults accepted; 3 reviewer fixes via `tm_fixups.tsv`; speaker-marker rule (DLC2-only, conditional) |
| DEC-026 | pilot result recorded (subtitle scopes CONFIRMED reachable); opening scene = `Chelomey_Dialogues` lines 284-324 (41 rows, 40 new); scene translation conventions; p4 built + installed; subtitle-display rule (parts, keep segments <= English) |

## Known issues (current)

| id | state | one-line |
|---|---|---|
| KI-009 | PARTIAL-CONFIRMED + pilot evidence | menu/settings Arabic CONFIRMED (Test 3); carrier now CONFIRMED to reach dialogue/subtitle scopes; Arabic in a subtitle is the p4 test now running |
| KI-013 | OPEN | native `ar` language entry needs DA_Audio schema tooling (Phase 8) |
| KI-017 | BLOCKED | one obfuscated cooked asset (NotLifted_17) - evidence only |
| KI-018 | NOTED | 248 RU-only cooked dialogue assets / 6,012 strings need a separate uasset path |
| KI-019 | FIXED in p4, in-game proof pending | p2 shipped broken icon tags in the 7 seeded game tips; corrected in p3 and p4 |
| KI-020 | CLOSED | Python declined by the user; PowerShell validator is authoritative |
| KI-021 | MITIGATED | Arabic must never be a literal inside a `.ps1` (PowerShell ANSI parsing) |
| KI-022 | PARTIAL | subtitle display: parts CONFIRMED, clip-vs-scroll NOT TESTED (checklist item 4) |
| KI-015 | NOTED | UnrealLocres normalizes LF to CRLF inside multiline values (accepted) |
| KI-016 | NOTED | 728 pre-existing duplicate IDs in the master (cosmetic) |

## What I should send back (to you)

- Nothing until your next report: p4 is installed and the bridge check is in your hands.
- After your report: the result recorded in the standing docs + a commit, then batch 1 on "next".

---

## Review sample (40 rows, Arabic first, English below)

The full list of every translated row is in `localization/references/AR_EN_REFERENCE.md`.
This is the standing 40-row per-batch sample: a deterministic spread, the longest rows, and the
tag-bearing rows. This cycle's bridge-scene rows appear among the "longest" rows.

<!-- BEGIN REVIEW SAMPLE -->

| # | scope | cat | why | key | Arabic (what the player sees) | English source |
|---|---|---|---|---|---|---|
| 1 | Chelomey_Dialogues | Dialogue | spread | `/0274464A44F83E078C1ED59E0F7E2D71` | صوت واثق | Confident voice |
| 2 | NewP5 | UI | spread | `/40EF37E64730E4A368EA709B9D62FE92` | تكنوستاسيس | Technostasis |
| 3 | NewP5 | UI | spread | `/DB51C872475733ED3F563EA0ED902A7E` | أحواض الدلافين | Dolphin Enclosures |
| 4 | Chelomey_Dialogues | Dialogue | spread | `/C9FA9D244A8BA0F2DB8284B158F54198` | امرأة في المقهى | Woman in cafe |
| 5 | NewP5 | UI | spread | `AHGameSettings/PERFORMANCE` | الأداء | Performance |
| 6 | NewP5 | UI | spread | `ST_MenuText/Men_exitpopup` | إنهاء اللعبة | Quit game |
| 7 | Chelomey_Dialogues | Dialogue | spread | `/10E57B554D1CB6E33B614B829975AE99` | *0.09*أيها الرفيق! بوصفك مواطناً من الاتحاد السوفييتي العظيم، انضمّ إلى رفاقك وخُض البلمرة اليوم! قف مع كوليكتيف 2.0! *0.07*تعلّم كيف تتحكّم بالروبوتات بعقلك! استكشف الفضاء! ابلغ ذروة التطوّر! *0.10*سيكون الإطلاق العالمي لكوليكتيف 2.0، شبكتنا الرائعة، في اليوم الثالث عشر من شهر يونيو عام 1955، أي بعد يومين فقط! *0.10*احصل على جهاز THOUGHT اليوم، وكن من أوائل الإنسان المستقبلي! المستقبل صار لك بالفعل! | *0.09*Comrade! As a citizen of the mighty Soviet Union, join your compatriots and undergo polymerization today! Stand with Kollektiv 2.0! *0.07*Learn how to control robots with your own mind! Explore space! Reach the pinnacle of evolution! *0.10*The global launch of Kollektiv 2.0, our marvelous network, will be on the 13th day of the month of June, 1955, only two days away! *0.10*Get your THOUGHT device today, and become Homo Futurum among the first! The future is already yours! |
| 8 | Chelomey_Dialogues | Dialogue | spread | `/80D5E60948E59FE7EFD518B5253BFA92` | *0.08*كل مواطن في الاتحاد السوفييتي يستطيع الحصول على جهاز THOUGHT مجاناً! لكن هناك ما هو أفضل: هنا، في مجمّع تشيلومي الحبيب، يمكنك البدء باستخدام جهاز THOUGHT فوراً، *0.08*قبل يومين كاملين من الإطلاق الرسمي لشبكة كوليكتيف 2.0 العالمية! | *0.08*Any citizen of the USSR can obtain a THOUGHT device for free! But it gets even better: here, in our beloved Chelomey Complex, you can start using your THOUGHT device right now, *0.08*two full days ahead of the official launch of the Kollektiv 2.0 global network! |
| 9 | NewP5 | UI | spread | `/0B4FE5CE4A7BB60F4C06968E4B407AB9` | للقفز فوق جسم أو التسلّق عليه، اضغط <tag id="InputAction.Gameplay.jump"/>. | To vault or climb an object, press <tag id="InputAction.Gameplay.jump"/>. |
| 10 | NewP5 | UI | spread | `/415286224249C4324C7B50A0137D83C1` | الاندفاع أثناء القفز | Dashing while jumping |
| 11 | NewP5 | UI | spread | `/81193D4F4C38C8F13C5C3997B7B581DB` | HAWK غير معرّف | UNIDENTIFIED HAWK |
| 12 | Pavlov_Dialogues | Dialogue | spread | `/0136DBEB4EF88FFA06F2159616DE3977` | *0.08*لا أستطيع الجزم. ربما تكون المسألة مسألة راحة. أجهزة THOUGHT تحتاج إلى إعادة ضبط في كل مرة تُلبَس. *0.04*أما الخاتم فيمكن خلعه وإلباسه من جديد دون عناء. | *0.08*I can't say for sure. Perhaps it's an issue of convenience. THOUGHT devices need to be reconfigured every time they are put on. *0.04*A ring can be taken off and put back on without inconvenience. |
| 13 | Schebetar_Subs | Subtitles | spread | `/E50AF2A6487B6F7E0D4981819B984984` | *0.00-0.08* &Ministry of Culture curator& هذه مكنسة روبوتية أو "مكنسة روبوت". إنها رائعة تماماً! انظروا فقط كيف تتحرّك بالحركة البطيئة!*0.08-0.10* &Ministry of Culture curator& حسناً، لنرَ...*0.10-0.18* &Ministry of Culture curator& لها جسم مستطيل وكتفان ضيّقان جداً، ما يتيح لها شفط الأوساخ في أي مكان تقريباً.*0.18-0.28* &Ministry of Culture curator& انظروا إلى كل هذه القمامة في كل مكان! لكن المكنسة الروبوتية لا تهتم، إنها تدمّر كل ذلك الخردة وتواصل شفط الأوساخ.*0.29-0.39* &Ministry of Culture curator& أوه، لقد سكب أحدهم دلو دهان على المكنسة الروبوتية!*0.39-0.45* &Ministry of Culture curator& لكن المكنسة تتصرّف وكأنها لم تلاحظ أن الدهان اللزج تغطّى بها. انظروا إلى هذا الوغد — سينظّف كل شيء، وسيواصل الشفط فقط!*0.46-0.53* &Ministry of Culture curator& فهمت يا دميتري؟ هكذا يجب أن نفتح أعين مواطنينا على الأشياء المذهلة التي نصنعها هنا في المنشأة، لا ذلك الشريط الباهت*0.53-1.01* &Ministry of Culture curator& "مصنع زابوريجيا للسيارات يقدّم الطراز ROZGDFG-20 أو 40 أو أيّاً كان..." إنه ممل حتى الموت. | *0.00-0.08* &Ministry of Culture curator& This is a robot vacuum or "robo-vacuum." It's totally bad ass! Just look at it moving in slow motion!*0.08-0.10* &Ministry of Culture curator& Okay, let's see...*0.10-0.18* &Ministry of Culture curator& It's got an elongated body and very narrow shoulders, which allows it to suck up dirt in almost any area.*0.18-0.28* &Ministry of Culture curator& Just look at all the trash everywhere! But the robo-vacuum doesn't give a crap, it just destroys all that junk and keeps on sucking up the dirt.*0.29-0.39* &Ministry of Culture curator& Uh-oh, someone spilled a bucket of paint on the robo-vacuum!*0.39-0.45* &Ministry of Culture curator& But the robo-vacuum acts like it doesn't even notice it got sticky paint all over it. Look at that fucker—it'll just clean everything up, and it'll just keep on sucking!*0.46-0.53* &Ministry of Culture curator& Get it, Dmitry? That's how we need to open our fellow citizens' eyes to the amazing things we make here at the Facility, not your lame old*0.53-1.01* &Ministry of Culture curator& "the Zaporizhzhia Automotive Factory presents model ROZGDFG-20 or 40 or whatever..." It's boring to death. |
| 14 | Chelomey_Dialogues | Dialogue | spread | `/02EA6FCF4A4F49A39C2B63AE6B5C2EAD` | أندريه | Andrey |
| 15 | NewP5 | UI | spread | `ST_GameTips_Texts_/chtobi_uklonyatsya` | للمراوغة بين الهجمات والأجسام الطائرة والمقذوفات، اضغط <tag id="InputAction.Gameplay.Dodge"/> أثناء التحرك. | To dodge attacks, flying objects, and projectiles, press <tag id="InputAction.Gameplay.Dodge"/> while moving. |
| 16 | VDNKh_Dialogues | Dialogue | spread | `/BC80AD6147CE2576762634AE7971F2E0` | إليك ذراعك اليسرى. تفضّل وأصلح نفسك. | Here's your left arm. Go ahead and fix yourself up. |
| 17 | NewP5 | UI | spread | `AHGameSettings/Borderless Window` | ملء الشاشة بإطار نافذة | Windowed Fullscreen |
| 18 | Theatre_Dialogues | Dialogue | spread | `/962A2FA3462F1CE524EB09B650D0C297` | *0.08*أتقول ذلك حقاً؟! أتُظهر أنيابك؟ يا له من تعبير بديع، وإن كان سوقياً. تذكّر يا فتى: *0.04*أن تنفخ صدرك وتتفاخر بالشخصية لا يعني أنك تملك تلك الشخصية فعلاً. | *0.08*You don't say?! Are you showing your teeth? What a delightful, if plebeian, expression. Remember, boy: *0.04*puffing your chest and showing off the character does not mean you are actually in possession of said character. |
| 19 | NewP5 | UI | spread | `ST_MenuText/menu_titles` | فريق العمل | Credits |
| 20 | Chelomey_Dialogues | Dialogue | spread | `/AA64EBA041545F207BDF07BCB9C2166D` | صوت واثق | Confident voice |
| 21 | Schebetar_Subs | Subtitles | longest | `/9511248745986BD47D906A9DB6D80DE0` | *0.05-0.09* &Surgeon& قطنة. ركّزوا. راقبوا ذلك الشق!*0.09-0.10* &Nurse& حسناً... لحظة واحدة...*0.10-0.11* &Surgeon& ركّزوا!*0.16-0.18* &Surgeon& تبا. اضغطوا عليه، الآن!*0.22-0.25* &Surgeon& لم يتشرّبه النسيج بالبوليمر مجدداً، فأنشأ تجويفاً مرضياً.*0.26-0.32* &Surgeon& هناك عقد كهذه في كل جسده. ماذا تريد تلك الوحوش بلا قلب من الناس، هاه؟!*0.33-0.41* &Colonel& قد تكونون محقّين أيها الرفاق، لكن هذا ليس شأنكم. أدّوا عملكم. أيها الجندي، أدخل التالي.*0.42-0.43* &Private& نعم، أيها الرفيق العقيد.*0.44-0.50* &Colonel& يجب أن يتشرّب النسيج البوليمر. وإن لم يفعل، أنقذوا من تستطيعون إنقاذه...*0.51-0.53* &Colonel& ...ونظّفوا هذا المكان. | *0.05-0.09* &Surgeon& Swab. Focus. Keep an eye on that incision!*0.09-0.10* &Nurse& Okay... just a moment...*0.10-0.11* &Surgeon& Focus!*0.16-0.18* &Surgeon& Shit. Pressure on it, now!*0.22-0.25* &Surgeon& The Polymer wasn't absorbed by the tissue again, so it created a pathological cavity.*0.26-0.32* &Surgeon& There are nodules like this all over his body. What do those heartless animals want from people, huh?!*0.33-0.41* &Colonel& You may be right, comrades, but that is not your concern. Do your jobs. Private, bring in the next one.*0.42-0.43* &Private& Yes, Comrade Colonel.*0.44-0.50* &Colonel& The Polymer needs to be absorbed. And if it's not, save whoever you can...*0.51-0.53* &Colonel& ...And clean this place up. |
| 22 | Chelomey_Dialogues | Dialogue | longest | `/33EA844F4B8F028BC8002BB818499148` | *0.10*مسلّحاً بوصلة THOUGHT العصبية الأنيقة اللافتة للنظر، لن تضطر بعد الآن إلى حمل أجهزة اللاسلكي الضخمة، ولا الكاميرات الثقيلة، ولا مقاييس الضغط والحرارة، ولا البوصلة. *0.10*بل سيعمل هذا الجهاز المحمول أيضاً كمصباح للرأس بالغ الفائدة. سيتّجه ضوؤه دائماً إلى ما تنظر إليه فعلاً. والأجمل من ذلك *0.10*أن تغيير اتجاهه لا يحتاج إلى أي إدخال آخر سوى أمر ذهني واحد. هذا صحيح! يعمل جهاز THOUGHT كواجهة عصبية تربط مستخدمه *0.08*بشبكة كوليكتيف 2.0 العالمية، حيث يتحكّم كل شيء بقوة الفكر. | *0.10*Armed with a stylish, eye-catching THOUGHT Neural Connector, you will no longer have to lug around unwieldy radiotelephones, bulky cameras, barometers, thermometers, or compasses. *0.10*This portable device will even double as an incredibly useful headlight. Its light will always be directed at what you are actually looking at. And the best part is that *0.10*changing its direction requires no other input, save for a single mental command. That's right! The THOUGHT device works as a neural interface, connecting its user *0.08*to the global Kollektiv 2.0 network, where everything is controlled by the power of thought. |
| 23 | Chelomey_Dialogues | Dialogue | longest | `/1002A45848240DE4F7234C932386D3BF` | *0.10*ستكون قدراتك بلا حدود! أتريد أن تتعلّم لغة أجنبية في دقيقة؟ أن تتقن فيزياء الكم في يوم؟ أن تحفظ روائع الأدب من كل أنحاء العالم؟ *0.06*سيصبح كل ذلك ممكناً بمجرد تثبيت وصلة THOUGHT العصبية هنا على صدغك. *0.10*كل تواصل بين دماغك وجهاز THOUGHT الشخصي يصبح ممكناً عبر حقنة صغيرة من البوليمر العصبي في مركز البلمرة المحلي، *0.09*حيث ستحصل أيضاً على جهاز THOUGHT. في خمس دقائق، في خمس دقائق فقط! ستصبح المستقبل. | *0.10*Your potential will be unlimited! Want to learn a foreign language in a minute? Master quantum physics in a day? Memorize literary masterpieces from around the world? *0.06*This all will be possible once your THOUGHT neural connector is installed right here on your temple. *0.10*All communication between your brain and your personal THOUGHT device is made possible via a tiny injection of Neuropolymer at a local center for Polymerization, *0.09*where you will also receive your THOUGHT device. In five minutes—in just five minutes!—you'll become the future. |
| 24 | NewP5 | UI | tagged | `ST_GameTips_Texts_/zazhmite_i_uderzhivayte` | لفتح عجلة الجرد، اضغط مع الاستمرار على <tag id="InputAction.Gameplay.RadialMenu"/>. | To open the Inventory Wheel, press and hold <tag id="InputAction.Gameplay.RadialMenu"/>. |
| 25 | NewP5 | UI | tagged | `ST_GameTips_Texts_/nazhmite_slabiy_udar` | لإحداث ضرر خفيف، اضغط <tag id="InputAction.Gameplay.EquippedItemPrimaryAction"/>. هذه الضربات سريعة لكنها ليست قوية للغاية. | To deal light damage, press <tag id="InputAction.Gameplay.EquippedItemPrimaryAction"/>. Such attacks are fast but not particularly hard-hitting. |
| 26 | NewP5 | UI | tagged | `/BC6802EC46CE674AFC50749045219D52` | للخروج من البوليمر، استخدم <tag id="InputAction.Gameplay.Dodge"/>. | To emerge from the Polymer, use <tag id="InputAction.Gameplay.Dodge"/>. |
| 27 | NewP5 | UI | tagged | `/3DB8E81848CDC42CF3FA40A19CD43CEA` | تسلّق الأجسام بالضغط على <tag id="InputAction.Gameplay.Jump"/> بجانبها. | CLIMB objects by PRESSING <tag id="InputAction.Gameplay.Jump"/> next to them. |
| 28 | NewP5 | UI | tagged | `ST_GameTips_Texts_/vi_raneni` | لقد جُرحت! اضغط مع الاستمرار على <img id="Button.ConsumeItem"/> للعلاج | You've been injured! Press and hold <img id="Button.ConsumeItem"/> to heal |
| 29 | NewP5 | UI | tagged | `/D75D44284FEF0ED201C9B5965BEECFAB` | لتشغيل الماسح، استمرّ بالضغط على <tag id="InputAction.Gameplay.Scannner"/>. | To activate the scanner, hold <tag id="InputAction.Gameplay.Scannner"/>. |
| 30 | NewP5 | UI | tagged | `ST_GameTips_Texts_/protivniki_mogut_ispolzovat` | يمكن للأعداء تنفيذ ضربات قوية تُسقط P-3 إذا أصابته. عندما يستعد عدو لضربة قوية، سيشير تشارلز إلى أفضل لحظة للمراوغتها. عند رؤية التمييز الأحمر، <h>اضغط</> <tag id="InputAction.Gameplay.Dodge"/> للمراوغة. | Enemies can perform power attacks that knock P-3 down if they hit. When an enemy is charging a power attack, CHARLES will indicate the best moment to dodge it. Upon seeing the red highlight, <h>press</> <tag id="InputAction.Gameplay.Dodge"/> to dodge. |
| 31 | NewP5 | UI | tagged | `ST_GameTips_Texts_/sbor_resursov_2` | لجمع الموارد وسلب الأعداء، اضغط مع الاستمرار على <tag id="InputAction.Gameplay.Use"/>. | To collect resources and loot enemies, press and hold <tag id="InputAction.Gameplay.Use"/>. |
| 32 | NewP5 | UI | tagged | `/EF751A1342225BE3D42CB1A1DEF3A564` | الوصفة {0} مفتوحة بالفعل! | {0} recipe already unlocked! |
| 33 | NewP5 | UI | tagged | `/BBC40EA74D9F49E660961781E552A7F1` | غالباً ما تُبرز الأجسام القابلة للإمساك بها باللون <h>الأصفر</>. | Objects that you can grab onto are often highlighted in <h>yellow</>. |
| 34 | NewP5 | UI | tagged | `ST_GameTips_Texts_/esli_protivnik_stoit_spinoy` | إذا فاجأت عدوًا، يمكنك التسلل إليه وطرحه أرضًا دون إطلاق إنذار. <h>لتنفيذ تصفية خفية، اقترب من الخلف واضغط</> <tag id="InputAction.Gameplay.StealthKill"/>. أسرع، وإلا فقد تفقد عنصر المفاجأة. | If you catch an enemy unawares, you can sneak up and knock them out without raising the alarm. <h>To perform a stealth kill, approach from behind and press</> <tag id="InputAction.Gameplay.StealthKill"/>. Be quick, or you might lose the element of surprise. |
| 35 | PearTerminals | UI | spread | `/FD32B8A242D61151C033EFA20EEE90B3` | نادي الشطرنج | Chess club |
| 36 | Chelomey_Dialogues | Dialogue | spread | `/27A03C6345B688B2287FDC8863BAD936` | أندريه | Andrey |
| 37 | Chelomey_Dialogues | Dialogue | spread | `/32792B6D45AA530D09C717868CE8D20A` | الجدة زينا | Granny Zina |
| 38 | Chelomey_Dialogues | Dialogue | spread | `/45DCA8FD43DFD45159ED7D82418730E5` | *0.09*وصلة THOUGHT العصبية هي أحدث منتج بحثي وتطويري في المنشأة 3826، وثمرة نخبة من العلماء والمهندسين السوفييت الذين يعملون في طليعة *0.09*العلوم والتقنيات المتعدّدة التخصّصات. هذا الجهاز سيقلب العالم رأساً على عقب. فبفضل جهاز THOUGHT، وخلال يومين فقط، سيتمكّن أي مواطن سوفييتي مبلمَر *0.11*من تعلّم التحكّم بالروبوتات بقوة عقله. لن يعود العالم كما كان أبداً! | *0.09*The THOUGHT Neural Connector is Facility 3826's newest R&D product, the brainchild of an elite cadre of Soviet scientists and engineers working at the forefront *0.09*of multidisciplinary science and technology. This device is set to completely revolutionize the world. Armed with a THOUGHT device, in just two days, any polymerized Soviet citizen *0.11*will be able to learn to control robots with the power of their mind. The world will never be the same again! |
| 39 | NewP5 | UI | spread | `/B27E32FD4EAE23C949FC7BB3F6B800D5` | هوارد فيليبس لوفكرافت | H. P. Lovecraft |
| 40 | VDNKh_Dialogues | Dialogue | spread | `/61E6E69F4F621A89D6CCB8BC7863FFFF` | الأسلحة الآلية: واحد. الكاراتيه: صفر. | Automatic weapons, one. Karate, zero. |

<!-- END REVIEW SAMPLE -->
