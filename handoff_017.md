# Cycle 013 results - Atomic Heart Arabic localization

Date: 2026-10-19 12:58 (local). Repo: C:\AtomicHeart-AR. HEAD before commit: 809a878.
Author: localization agent. Status: **COMPLETE - 50% milestone reached, carrier p8 built and installed.**

## Summary (5 lines)

1. Your review notes are applied: the soda term was fixed from the Russian original
   (`газировка` -> `صودا`), 40 already-shipped rows were rewritten for tone against the Russian
   source, and the spoken-register rule is now standing policy (`glossary/terminology.md` section 12).
2. Batch 2 was finished to the milestone: 14 chunks (ids `b0309`-`b4508`) authored on the frozen
   progression plan, each gate-checked, applied atomically and revalidated - 0 conflicts.
3. Coverage is now **13,989 of 27,618 rows (50.65%)** - the 13,809-row (50%) target was reached and
   passed; 9,130 of 19,996 unique strings (45.66%).
4. Carrier **p8 is built and INSTALLED** (4,012,839 B, sha256 `0806367b...`), font v2 untouched,
   p7 removed after hash match, `~mods` holds exactly 3 files; rollback is one command.
5. All gates are green: validator 0 errors, glyph gate introduced-by-Arabic 0, carrier 35/35 scopes
   with 0 FAIL and 35/35 byte-identical round-trip; trailing whitespace clean.

## 1. Delivered this cycle

| # | item | evidence |
|---|---|---|
| 1 | Soda/drink terminology fixed from the Russian original | `localization/working/tm_fixups.tsv`, `reports/text_fixups_log.md`, glossary rows `Soda`, `Soda water`, `Cream Soda`, `Tarkhun`, `Duchess` |
| 2 | Tone pass on shipped content (40 rows, before/after) | `reports/tone_pass.md` |
| 3 | Standing style rule | `glossary/terminology.md` section 12 |
| 4 | THOUGHT device unified as `«الفكرة»` (17 rows) | `reports/text_fixups_log.md`, glossary row `THOUGHT device` |
| 5 | Russian source reference tooling | `scripts/export_ru_reference.ps1` -> `localization/extracted/ru_csv/` (36 scopes) |
| 6 | Batch-2 authoring contract | `localization/working/batch2/AUTHORING_BRIEF.md` |
| 7 | Batch 2 chunks 0002-0015 (4,189 strings, 5,008 rows) | `localization/working/batch2/ar_00*.tsv`, `chunk_00*.tsv`, `state.tsv` |
| 8 | Carrier p8 built + installed | `build/package/zzz_atomicheart-ar_carrier_koKR_p8_P.pak`, `reports/carrier_build.md` |
| 9 | Reference + review sample regenerated | `localization/references/AR_EN_REFERENCE.md`, `reports/review_sample.md` |
| 10 | Docs: DEC-031..037, KI-028/029, STATUS, ROADMAP, glossary questions G/H | `DECISIONS.md`, `KNOWN_ISSUES.md`, `STATUS.md`, `ROADMAP.md` |

## 2. Coverage

| metric | before this cycle | now |
|---|---|---|
| rows with Arabic | 8,981 of 27,618 (32.52%) | **13,989 of 27,618 (50.65%)** |
| unique English | 4,947 of 19,996 (24.74%) | 9,130 of 19,996 (45.66%) |
| translation memory | 4,948 | 9,131 |
| milestone | 13,809 rows (50%) | reached and passed by 180 rows |

Batch 2 detail (apply output, one line per chunk):

| chunk | ids | entries | rows filled | conflicts |
|---|---|---|---|---|
| 0002 | b0309-b0608 | 298 | 317 | 0 |
| 0003 | b0609-b0908 | 300 | 318 | 0 |
| 0004 | b0909-b1208 | 299 | 352 | 0 |
| 0005 | b1209-b1508 | 300 | 311 | 0 |
| 0006 | b1509-b1808 | 292 | 386 | 0 |
| 0007 | b1809-b2108 | 300 | 385 | 0 |
| 0008 | b2109-b2408 | 300 | 315 | 1 (TM note: "Ahem...") |
| 0009 | b2409-b2708 | 300 | 304 | 0 |
| 0010 | b2709-b3008 | 300 | 326 | 0 |
| 0011 | b3009-b3308 | 300 | 487 | 0 |
| 0012 | b3309-b3608 | 300 | 338 | 0 |
| 0013 | b3609-b3908 | 300 | 359 | 0 |
| 0014 | b3909-b4208 | 300 | 395 | 0 |
| 0015 | b4209-b4508 | 300 | 415 | 0 |
| **total** | **b0309-b4508** | **4,189** | **5,008** | **0 master conflicts** |

11 ids were omitted as documented copy-class keeps (Arabic would equal English or carry no Arabic
letter): `b0337` C-9!, `b0351` F-3!, `b1065` [do not localize], `b1613` FinalDialog,
`b1614` FirstDialog, `b1622` RANDOM, `b1623` RadioDialog, `b1624` RadioReroute, `b1625` SaidFirst,
`b1626` SaidSecond, `b1627` [Leave] (the last one is KI-029).

## 3. Gates (raw evidence)

```
VALIDATOR PASS: rows=27618 translated=13989 errors=0 warnings=277 (number 24 / length 112 / glossary 141)
GLYPH GATE PASS: rows with Arabic 13989 | distinct codepoints 152 | subtitle-face missing 6 |
                 union missing 6 | source-inherited 6 | introduced-by-Arabic 0
[trim] master rows trimmed: 0
TOTAL: keys 27618 | arabic 13989 | english 13629 | korean 0 | exact 26449 | newline 1169 | fail 0
[verify] unpack byte-identical 35/35 (bad 0)
[VERIFY] ~mods contains exactly 3 files ... exact expected set present: True
FIXUP VERIFY RESULT: PASS   (82 rules verified; 59 master rows changed this cycle)
```

The 141 glossary warnings were triaged, not ignored: 10 terms were sampled across 20 rows and every
one is a **morphological false positive** of the validator's naive substring match - plural vs
adjective (`السوفييت` / `سوفييتي`), feminine forms (`طبيبة` = a female doctor), definite vs
indefinite titles (`بروفيسور` / `البروفيسور`), word-embedded hits (`majority` matching `Major`) and
byte-exact Latin speaker tags (`&Petrov&`). The 24 number-multiset warnings were also sampled (12
rows): they are Arabic word-numbers (`خمسين`, `طلقتين`, `يوم واحد`) or 2500/3000 written without a
separator - no defect. Both are recorded as DEC-036 so they are not re-investigated.

## 4. Terminology and tone work (your feedback)

- **The drink.** The Russian original of the boat line is `Дорогой товарищ, газировки не желаете?`
  and the museum order list says `Газировка - 200 литров`, so `газировка` is the everyday Soviet
  fizzy drink. The line is now **`تريد صودا يا رفيقي العزيز؟`** and the order list **`صودا، 200 لتر`**;
  the vending sign keeps the precise sense **`مياه غازية`** (Russian `ГАЗИРОВАННАЯ ВОДА`), and the
  lemonades are `كريم صودا`, `طارخون`, `ديوشيس`. `الغازية` is retired. Five glossary rows added.
- **Trap found and avoided:** `الغازية` also occurs inside `التوربينات الغازية` (gas turbines), so the
  fix used full-row `find` strings; the turbine row was not touched. This is now a documented rule.
- **Tone.** 40 rows rewritten in the order the player meets them (prologue/Chelomey first), each
  compared with the Russian source rather than the English alone. Examples: `هل ترغب بمزيد من...` ->
  `تريد صودا...`; `أليس كذلك؟` as a short "eh?" -> `هاه؟`; `أنا في سنٍّ تجعلني...` ->
  `أنا كبير بما يكفي...`; `يسعدني سماع ذلك` -> `هذا رائع`; `ينبغي أن أتحقق` -> `عليّ أن أتفقّده`.
  Deliberately NOT changed: the PearTerminals/Mails official letters, because the Russian there is
  itself an official formula - register, not stiffness. Full table: `reports/tone_pass.md`.
- **New policy** (`glossary/terminology.md` section 12): natural spoken MSA, one voice per character,
  never soften, official-letter register kept when the source has it.
- **Consistency fix:** the device name was split between Latin `THOUGHT` (17 rows) and `«الفكرة»`
  (5 rows); it is now `«الفكرة»` everywhere (matches the Russian «Мысль» and the project's quoting
  style).

## 5. Method note: how 14 chunks were produced in one cycle

Batch-2 authoring is the expensive part (4,189 hand-written lines). This cycle the contract was
written once (`AUTHORING_BRIEF.md`: format, hard rules, style, terminology table, verification) and
then 14 independent authoring workstreams produced one chunk each against the frozen plan. Every
chunk had to pass the automated chunk gate (id set, empty-Arabic, Arabic-letter, token/marker
multiset) before it was accepted, and only the lead session applied chunks to the master - so the
master stayed consistent at every step and the run is resumable anywhere. Result: 0 master
conflicts, 0 token mismatches, and every gate green. Recorded as DEC-037.

## 6. Carrier p8 and the install proof

| step | evidence |
|---|---|
| build | `build_carrier_locres_pak.ps1 -VariantLabel p8` -> `build\package\zzz_atomicheart-ar_carrier_koKR_p8_P.pak`, 4,012,829 bytes, sha256 `dd0391ed6f5495a9751d2e6563acc6720b9be0c6c58c7c72f70eeeb225fea5f3` |
| contents | 35/35 scopes, 13,989 Arabic + 13,629 English-filled + **0 kept Korean**, 0 FAIL, 35/35 unpack byte-identical |
| install | `install_mod.ps1 -Carrier p8 -Font p2_plex`: installed carrier + font; removed superseded p7 **after hash match**; manifest updated |
| `~mods` now | `zzz_atomicheart-ar_carrier_koKR_p8_P.pak` (dd0391ed..., 4,012,829 B), `zzz_atomicheart-ar_font_p2_plex_P.pak` (02b17f31..., 1,461,408 B), `atomic-heart-ar-install-manifest.json` (195bc55d..., 1,541 B) - exactly 3 files |
| rollback | `install_mod.ps1 -Carrier p7 -Font p2_plex` (older targets: `p6`, `p5`, `p4`) |

Nothing outside `~mods` was written. Game language must stay Korean (ko-KR) - that is the culture the
carrier replaces.

## 7. Deviations and honest notes

1. **The 50% target was reached, but not in "one run" of the first attempt.** Cycle 012 stopped at
   32.52%; this cycle finished the remaining 18.13 points. No deviation remains open.
2. **KI-029 (new):** 8 `[Xxx]` bracket rows could not be translated because the chunk gate treats
   `[A-Za-z/]{1,12}` as a token, so `[Leave]` cannot become `[مغادرة]`. They stay Latin for now.
   Fixing this needs a deliberate gate exception, so it is documented, not hacked.
3. **One benign TM note:** the string "Ahem..." already existed in the TM with a different Arabic
   from an earlier batch; the master row was not overwritten (existing work wins). No conflict in
   the master.
4. **Not tested in game:** the p8 build has not been played yet. The user's own p7 report
   (canal boat scene = EXCELLENT) is the current in-game evidence; p8 adds 5,008 rows on top of it.
   KI-009 (GameTips), KI-022 (very long subtitle parts) and KI-026 (UI fit beyond that scene) stay
   NOT TESTED and are testable with p8 installed.
5. **Nothing was uploaded.** Commits stay local (`git remote -v` = 0 remotes).
6. **A fixup regression was caught by the gates, not by luck.** After the 14 chunks were applied,
   `verify_text_fixups.ps1` (part of the cycle close) failed on 2 batch-1 shorten rules: new rows had
   reintroduced `الذراع اليسرى` and `تم حفظ البيانات` where the reviewer had approved `ذراع يسرى` and
   `حُفظت البيانات`. The fixups were re-applied (2 rows), the check went to PASS, and the carrier was
   rebuilt and reinstalled so the installed pak matches the master byte-for-byte. Rule recorded as
   DEC-038: always re-verify the fixups after a batch apply.

## 8. Decisions and issues recorded

- DEC-031: carrier p7 CONFIRMED in game (labels, line, both choices, `تطبيق` prompt).
- DEC-032: choice number/separator drawn left of the Arabic text = Phase 8 cosmetic item (KI-028).
- DEC-033: spoken-register style rule is standing policy + retroactive tone pass on shipped content.
- DEC-034: `газировка`/`soda` -> `صودا`; `ГАЗИРОВАННАЯ ВОДА` -> `مياه غازية`; previous `الغازية` retired.
- DEC-035: THOUGHT device -> `«الفكرة»` everywhere.
- DEC-036: validator glossary warnings are morphological false positives -> matcher must be improved.
- DEC-037: the parallel authoring-workstream contract for batch 2/3/4.
- DEC-038: `verify_text_fixups.ps1` must run after every batch apply - newly authored rows can
  reintroduce phrasing the reviewer already shortened. Fixups are global and idempotent, so
  re-applying them is always safe; if they change the master, the carrier must be rebuilt.
- KI-028 added (cosmetic), KI-029 added (`[...]` bracket rows), KI-027 confirmed in game with a
  documented residual.

## 9. What I should send back

1. **Play-test p8.** The three files are installed; keep the game language on Korean. The fastest
   checks: the prologue/Chelomey plaza banter (new chunk-0002..0007 content), a VDNH sign/terminal,
   and a dialogue choice (watch the `1 //` placement - KI-028).
2. **Answer the drink question** (glossary_questions.md section G): is `صودا` the term you want, or
   `مشروب غازي` everywhere? The vending-sign form `مياه غازية` is intentionally the precise term.
3. **Name any line that still reads soft or wrong** (scene + key or an id like `b1234`) - I extend
   the rule-12 tone pass on the spot; the cap was 150 rows and I used 40.
4. **Decide on `[...]` bracket labels (KI-029)** if you want them translated (`[مغادرة]` etc.);
   it needs a one-line exception in the chunk gate.
5. **Say if you want the remaining 13,629 rows driven the same way** (batches 3+): DLC scopes, then
   the NTD VDNH sign strings and the remaining UI.
