# HANDOFF - Atomic Heart Arabic localization (cycle 013)

Generated: 2026-10-19 12:58 (local). Repo: C:\AtomicHeart-AR. Gaming target: Steam app 668580.
Status: **carrier p8 built and INSTALLED; coverage 13,989 of 27,618 rows (50.65%) - the 50% milestone
was reached and passed.** Everything is DRAFT and reviewable. No blockers.

Read this file first; it is the complete current state. Supporting evidence lives in `reports/`.

---

## 1. What is installed in the game right now

The game folder is `C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart`. Only
`AtomicHeart\Content\Paks\~mods` is ever written. Nothing else in the game was touched
(no EXE, no DLL, no Denuvo, no unpacking, no uninstall).

`~mods` contains exactly 3 files (verified by `scripts/install_mod.ps1`):

| file | bytes | sha256 |
|---|---|---|
| `zzz_atomicheart-ar_carrier_koKR_p8_P.pak` | 4,012,829 | `dd0391ed6f5495a9751d2e6563acc6720b9be0c6c58c7c72f70eeeb225fea5f3` |
| `zzz_atomicheart-ar_font_p2_plex_P.pak` | 1,461,408 | `02b17f31e61a46ddba20bea8c4da5be44164173df608d52697f68d27d8269747` |
| `atomic-heart-ar-install-manifest.json` | 1,541 | `195bc55db3f9b00e21d849691158e27c8bea724768899ee43fe7bac5ce56b608` |

- p8 was built, installed, then **rebuilt and reinstalled once**: `verify_text_fixups.ps1` caught 2 batch-2
  rows that had reintroduced a phrasing the batch-1 reviewer had already shortened, the fixups were
  re-applied (2 rows), and the carrier was rebuilt so the installed pak is byte-for-byte the current
  master (DEC-038). The hashes above are the final, currently installed build.
- The superseded carrier p7 was removed by the installer **after** its hash matched the manifest,
  so the folder can never hold two carriers.
- The game language MUST stay **Korean (ko-KR)**. That is the culture whose locres the carrier
  replaces; changing the game language to English or Russian unhooks the whole build
  (this is Strategy A, DEC-005/DEC-023).
- One-command rollback to the previous carrier:
  `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\install_mod.ps1 -Carrier p7 -Font p2_plex`
  Older builds are still on disk and are valid rollback targets: `p6`, `p5`, `p4`
  (`build\package\`). Use `scripts\uninstall_mod.ps1` to remove the mod entirely
  (the game files themselves were never modified, so removing the folder entry fully reverts it).
- Aside from the 3 files above, no other change is pending in the game folder.

## 2. Coverage

| metric | value |
|---|---|
| rows translated (DRAFT) | **13,989 of 27,618 (50.65%)** |
| unique English strings covered | 9,130 of 19,996 (45.66%) |
| milestone target | 13,809 rows (50%) - reached and passed by 180 rows |
| this cycle (batch 2, chunks 0002-0015) | 4,189 strings authored, 5,008 rows filled |
| plan ids authored so far | `b0001`-`b4508` (4,508 ids; 11 of them documented copy-class keeps) |
| next unauthored plan id | `b4509` |
| translation memory | 9,131 entries (`localization\working\tm.tsv`) |
| master DB | 9,864,410 bytes, 27,618 rows, Status is only UNTRANSLATED or DRAFT |

Scopes finished or nearly finished (dialogue/cutscene frontier, DEC-029 game-progression order):
`Chelomey_Dialogues`, `CUTSCENES` (prologue), `VDNKh_Dialogues`, `Vavilov_Dialogues`,
`Pavlov_Dialogues`, `Polygon_Dialogues`, `Theatre_Dialogues`, `OpenWorldVDNKh_Dialogues`,
`ChelomeyFinal_Dialogues`, `Academy_Dialogues` and the `DIALOGUES FOR LQA` material they reuse.
Still mostly untranslated (next batches): `NTD` (1,428 rows - the VDNH sign string tables),
`Mails_01`, `PearTerminals`, the DLC scopes (DLC1-DLC4) and the remaining UI scopes
(`NewP5` is largely done, `Misc`, `PearTerminals`). Exact per-scope numbers:
`localization\working\batch2\plan_summary.txt`.

## 3. What changed this cycle

1. **Reviewer feedback applied (style + term).**
   - `glossary/terminology.md` gained section 12, the standing **spoken-register rule**:
     natural spoken MSA (not word-for-word, not formal literary), one voice per character
     (Char-les cheerful, Sechenov pompous, soldiers/workers blunt, robots mechanical and
     polite only when the source is, P-3 sarcastic), never soften insults/swearing/threats/
     sarcasm/dark humour, and official-letter register is kept where the Russian is an official
     letter.
   - **Tone pass:** 40 already-shipped rows rewritten (prologue, Chelomey, Academy,
     PearTerminals, NewP5). Every row was compared against the **Russian source**, which is now
     exported locally by the new `scripts/export_ru_reference.ps1` into
     `localization/extracted/ru_csv/` (36 scopes, gitignored, regenerable). Before/after with the
     reason for each row: `reports/tone_pass.md`.
   - **Soda term fixed (DEC-034):** the Russian original says `газировка` (the everyday Soviet
     fizzy drink), so the boat-scene line is now `تريد صودا يا رفيقي العزيز؟` and the museum order
     list `صودا، 200 لتر`; the vending-machine sign term is `مياه غازية`, the lemonade flavours are
     `كريم صودا` / `طارخون` / `ديوشيس`. `الغازية` is retired. Glossary rows added for all of them.
   - **THOUGHT device (DEC-035):** the Latin `THOUGHT` (17 rows) was unified with the already
     translated `«الفكرة»` (Russian original «Мысль»); glossary row added.
2. **Batch 2 (the milestone block).** 14 chunks, ids `b0309`-`b4508`, authored against the frozen
   progression plan (`localization\working\batch2\plan_unique.tsv`) under the new reusable contract
   `localization\working\batch2\AUTHORING_BRIEF.md`. Every chunk passed the chunk gate
   (id set, empty-Arabic, token/placeholder multiset), was applied atomically to the master and
   re-validated; **0 apply conflicts** (one benign TM note on the string "Ahem...").
3. **New tooling:** `scripts/export_ru_reference.ps1` (Russian reference export),
   `scripts/tone_pass_report.ps1` (builds `reports/tone_pass.md` from `tm_fixups.tsv`).
4. **Docs:** DEC-031..DEC-037, KI-028 (cosmetic choice layout) and KI-029 (`[...]` bracket rows),
   STATUS.md cycle 013, ROADMAP deferred list, `glossary/glossary_questions.md` sections G and H
   (two questions for you: the `صودا` term, and more tone rows on request).
5. **Carrier p8** built and installed (section 1); after the fixup re-verification it was rebuilt once so
   the installed pak matches the current master byte-for-byte.

All reviewer text fixes live in `localization/working/tm_fixups.tsv` (KI-021) and were applied by
`scripts/apply_text_fixups.ps1`, verified by `scripts/verify_text_fixups.ps1` (PASS) and logged in
`reports/text_fixups_log.md`.

## 4. Gates (all green)

| gate | command | result |
|---|---|---|
| validator | `scripts\validate_translation.ps1` | **PASS** rows=27,618 translated=13,989 **errors=0** warnings=277 (number 24 / length 112 / glossary 141) |
| glyph gate | `scripts\glyph_gate.ps1 -AllowSourceInheritedNonLatin` | **PASS** rows with Arabic 13,989, distinct codepoints 152, **introduced-by-Arabic 0**, source-inherited 6 (KI-025) |
| carrier build | `scripts\build_carrier_locres_pak.ps1 -VariantLabel p8` | 35/35 scopes, 0 FAIL, 0 kept Korean, round-trip unpack **35/35 byte-identical** |
| install | `scripts\install_mod.ps1 -Carrier p8 -Font p2_plex` | exactly 3 files, hashes match, p7 removed after hash match |
| trailing whitespace | `scripts\trim_trailing_ws.ps1` | 0 rows trimmed (KI-024 clean) |
| chunk gates | `scripts\batch2_chunk.ps1 -ChunkId NNNN` (14x) | all PASS, 0 token mismatches |
| fixups | `scripts\apply_text_fixups.ps1` + `verify_text_fixups.ps1` | 32 new rules, 59 master rows (40 tone + 17 THOUGHT + 2 re-shortened), **FIXUP VERIFY PASS** |

Warning triage (this is important, so it is not re-investigated next cycle):
- **141 glossary warnings are all morphological false positives** of the validator's naive
  substring match: plurals/nouns vs the glossary adjective (`السوفييت` vs `سوفييتي`), feminine
  forms (`طبيبة` for a female doctor), definite/indefinite titles (`بروفيسور` vs `البروفيسور`),
  word-embedded matches (`majority` matching `Major`) and byte-exact Latin speaker tags
  (`&Petrov&`). 10 terms were sampled and verified; none is a real inconsistency (DEC-036).
- **24 number-multiset warnings were spot-checked (12 rows): none defective.** They are cases where
  Arabic spells the number as a word (`خمسين`, `طلقتين`, `يوم واحد`) or writes 2500/3000 without a
  thousands separator, or where the English number is an identifier (`3D model` -> `ثلاثية الأبعاد`).
- **112 length warnings are unchanged from the pilot** (112 at 8,981 rows and at 13,989 rows) and
  are UI labels the reviewer already accepted.

## 5. Exact resume point (no re-planning needed)

The master is consistent after every chunk (each apply is atomic), so the run is resumable at any
point without cleanup.

1. Next work order: plan ids from **`b4509`** onward. The English for the plan is in
   `localization\working\batch2\plan_unique.tsv` (`id<TAB>english<TAB>occurrences<TAB>scope<TAB>key<TAB>category<TAB>en_len`);
   the frozen order is DEC-029 (game progression).
2. Author a new chunk file `localization\working\batch2\ar_0016.tsv` (`id<TAB>arabic`, no header,
   UTF-8 no BOM, omit copy-class rows) following `localization\working\batch2\AUTHORING_BRIEF.md`.
3. Then, per chunk:
   `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\batch2_chunk.ps1 -ChunkId 0016`
   `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\batch2_apply.ps1 -ChunkId 0016`
   `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validate_translation.ps1`
   `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\glyph_gate.ps1 -AllowSourceInheritedNonLatin`
4. Remaining volume: **13,629 rows** (11,316 plan ids) - roughly 5 more 300-id chunks per +1,000 rows;
   the DLC and UI scopes are the tail.
5. Rebuild/reinstall when a new milestone is reached:
   `scripts\build_carrier_locres_pak.ps1 -PakOut build\package\zzz_atomicheart-ar_carrier_koKR_p9_P.pak -VariantLabel p9`
   then `scripts\install_mod.ps1 -Carrier p9 -Font p2_plex` (**needs explicit user approval**, per the
   standing install rule; the p8 install was approved for this cycle).

## 6. Standing rules that did not change

- TEXT ONLY: no media, no raw game assets committed, game folder read-only except `~mods`,
  never touch EXE/DLL/Denuvo, no uploads (local git only), no installs without approval.
- Arabic lives only in UTF-8 **data** files (`master/*.tsv`, `working/batch2/ar_*.tsv`,
  `tm_fixups.tsv`, glossary); `.ps1` files stay ASCII (KI-021) - and non-ASCII inside an inline
  shell command is mangled too, so Cyrillic/Arabic patterns are built from `[char]0x....` codes.
- Placeholders, tags, escapes, timing markers, `&Speaker&` and line breaks are byte-exact;
  Western digits; Arabic `،` and `؟`.
- Copy-class rows (Arabic would equal English or carry no Arabic letter) stay UNTRANSLATED with an
  empty Arabic cell; the validator hard-fails both.
- Coverage is always quoted as "N of TOTAL (X%)"; Russian-only strings go to
  `reports/dialogue_ru_only.md` (KI-010), never into the English column.
- After every batch apply, run `scripts\verify_text_fixups.ps1`: a newly authored row can reintroduce
  phrasing a reviewer already shortened (that happened with 2 rows this cycle, DEC-038). Fixups are
  global and idempotent, so re-applying them is always safe.
- Every turn: real date + time, docs updated, `reports/history/report_NNN.md` kept, old handoffs
  never deleted, and a results `.md` delivered.

## 7. Open items

| id | state | item |
|---|---|---|
| KI-029 | OPEN (new) | `[Xxx]`-style bracket rows cannot pass the chunk gate: the gate treats `[A-Za-z/]{1,12}` as a token, so `[Leave]` cannot become `[مغادرة]`. 8 such ids were skipped in chunk 0006. Needs a gate exception (or a dedicated applier) before those labels can ship. |
| KI-028 | COSMETIC / Phase 8 | Dialogue-choice layout: the choice number/separator (`1 //`) draws to the LEFT of the Arabic text (row is laid out LTR). Text is correct; fix with the Phase 8 widget work (DEC-032). |
| KI-018 | BLOCKED / Phase 8 | 248 RU-only cooked dialogue assets (6,012 strings) need a uasset decision; currently dead text. |
| KI-013 | BLOCKED / Phase 8 | native `ar` language entry in `DA_Audio` needs schema tooling. |
| KI-017 | BLOCKED / evidence | `NotLifted_17` obfuscated. |
| KI-004 / KI-010 | parked | main-UI uassets; RU-only StringTables. |
| KI-027 | CONFIRMED in game, residual | 2,588 single-occurrence name-like values not individually curated (`localization\working\labels\label_candidates.tsv`); sweep if a label shows up in English. |
| KI-009 / KI-022 / KI-026 | partial | GameTips popups not seen; very-long subtitle parts not seen; UI fit beyond the confirmed scene not tested. All testable right now with p8 installed. |
| DEC-036 | follow-up | Give the validator a morphology-aware glossary matcher so the 141 false positives stop masking real ones. |

## 8. Reports and how to read them

- `reports\cycle013_results.md` = `lastreport.md` = `reports\history\report_017.md`
  (= `handoff_017.md`) - this cycle's full results.
- `reports\tone_pass.md` - the 40 rewritten rows with before/after and the Russian source reason.
- `reports\text_fixups_log.md` - per-rule counts for all 81 fixup rules (idempotent).
- `reports\carrier_build.md` - per-scope build table for p8 + the sha256.
- `reports\translation_validation.md` - rows, errors, and every warning with its line number.
- `reports\glyph_gate.md`, `reports\review_sample.md`, `reports\scene_cycle012_ingame_check.md`.
- `localization\references\AR_EN_REFERENCE.md` - regenerated this cycle: 3,269,014 bytes,
  13,989 Arabic rows / 9,130 unique English / 34 scopes.
- `glossary\glossary_questions.md` - the running question list for you (sections A-H).

## 9. Review sample (40 rows from the current master)

`reports\review_sample.md` (47,977 bytes) holds 40 rows sampled from the 13,989 translated rows:
opening scenes, dialogue, tagged rows with `*0.xx*`/`&tags&`, and long UI strings. Read each block
as Arabic first, then the English it came from. If a line reads soft, stiff or wrong, name its key
or its scope and it becomes a rule-12 fix in the next cycle (that is exactly how this cycle's 40
fixes were produced).
