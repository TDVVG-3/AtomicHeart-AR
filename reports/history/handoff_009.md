# HANDOFF - Atomic Heart Arabic localization

DATE-TIME: 2026-10-18 19:41 (local)
CYCLE: 006
CURRENT STEP: dialogue batch 4 of 4 (100%) - DONE (program complete)
STATE: WAITING FOR USER

## Summary (5 lines)

1. The dialogue/cutscene program is COMPLETE: 10,394 of 10,394 (100%) English-source strings covered.
2. Batch 4's first attempt FAILED, and fixing it corrected the whole inventory (important - see Problems).
3. Corrected finding: the ONLY English dialogue source is the 14 en-US locre scopes (10,394 strings).
4. All non-locres dialogue assets are Russian-only (248 assets / 6,012 strings, KI-018) or obfuscated (1, KI-017, BLOCKED).
5. Master TSV 27,618 rows, all 14 scopes canonical; Arabic still empty (no translation); validator PASS.

## Completed

- Batch 4 (100%) applied after correction: covered 10,394 of 10,394 (100%), validator PASS.
- Two defects found and fixed (see Problems): a PowerShell row-builder bug and a wrong
  EN-source classifier.
- The 111 wrongly added rows were removed from the master (27,729 -> 27,618); verified.
- EN-source classifier corrected (DEC-021) and the finalizer re-run.
- New report: reports/dialogue_obfuscated.md (BLOCKED asset, KI-017).
- Rewritten report: reports/dialogue_ru_only.md (248 assets / 6,012 strings).
- Final on-disk verification of all 14 dialogue scopes: 10,394 rows, all canonical.
- Spec hash re-checked at step start: PASS.

## Problems

1. PowerShell comma-binds-tighter-than-'+': the new-row builder's
   'cooked asset scan; ... batch ' + $Batch was split into two array elements,
   producing 111 rows with 14 fields. The validator caught it (batch aborted, master
   NOT written on that run). Fixed by parenthesising; documented in the script.
2. WRONG SCOPE (the important one): those 111 strings were not English at all - they were
   Cyrillic subtitles with timecodes (plus a Latin phrase inside Russian lines) and one
   encoded payload. The old test "contains 3+ Latin letters" was too weak. Corrected:
   EN = Latin-dominant, ZERO Cyrillic, vowel ratio >= 0.15 (DEC-021).
3. Consequence: TOTAL corrected from 10,505 to 10,394; earlier batches had delivered
   2,626 / 5,253 / 7,879 which are at or above the corrected 25/50/75% marks
   (2,599 / 5,197 / 7,796), so nothing had to be re-delivered.
4. Obfuscated asset reported BLOCKED, not guessed (KI-017).

## Evidence

- Batch 4 (final) console output in reports/history/report_009.md section 4.
- On-disk scope verification table in report_009 section 5 (all 14 scopes, all canonical).
- reports/dialogue_inventory.md: TOTAL = 10,394, sole source = 14 en-US locre scopes.
- reports/dialogue_ru_only.md: 248 assets / 6,012 strings (complete DT_Subtitles_* family).
- reports/dialogue_obfuscated.md: NotLifted_17 sample `LKKELLMKLM"!...` (no vowels).
- Validator: PASS, 0 problems, 27,618 rows, UTF-8 round-trip OK, 0 new duplicate ids.

## Files Changed

- localization/master/atomic-heart-ar.tsv (Category canonicalization; 111 bogus rows
  removed; 27,618 rows).
- scripts/dialogue_finalize.ps1 (DEC-021 classifier + obfuscated report),
  scripts/dialogue_batch_apply.ps1 (row-builder fix, dump-path fix, hard error on
  missing dump).
- DECISIONS.md (DEC-021), KNOWN_ISSUES.md (KI-017, KI-018), STATUS.md, HANDOFF.md.
- reports/dialogue_inventory.md, reports/dialogue_ru_only.md,
  reports/dialogue_obfuscated.md, reports/dialogue_inventory_raw/sources_st.tsv,
  localization/references/AR_EN_REFERENCE.md, reports/history/report_009.md.

## Current Status

- Dialogue/cutscene coverage: 10,394 of 10,394 (100%) - COMPLETE.
- Arabic translation: NOT STARTED (column empty, by design).
- Test 3: main menu Arabic CONFIRMED earlier; settings pages/GameTips still open.
- Nothing installed or removed; game folder read-only; nothing uploaded.
- All four batches committed locally (see git log); working tree clean after this commit.

## Next Action

Wait for the user. Options once the user is ready:
- start translation of the 10,394 dialogue rows (English -> Arabic), then rebuild the
  carrier pak and re-test in game; or
- decide how to handle RU-only content (KI-018) and the obfuscated asset (KI-017); or
- finish Test 3 (settings captions + GameTips popups).

## What I need you to do

- Tell me which of these you want next: "translate dialogue", "test 3", or "next phase".
- No permissions are pending; nothing is running in the background right now.

## Decisions made (relevant)

| ID | Decision |
|---|---|
| DEC-017 | Dialogue program rules: scope, TOTAL = English-only, cumulative batches, order rule, no duplicate rows |
| DEC-018 | Count-pass dump generations: purged stale dumps/TSVs, rerun with verified decoder |
| DEC-019 | Prose filter: what counts as dialogue text in cooked assets |
| DEC-020 | Batch coverage arithmetic; retag-per-source boundary rule; duplicate baseline |
| DEC-021 | Classifier corrected (EN/RU-only/obfuscated/mixed/skip); TOTAL = 10,394; cutoffs 2,599/5,197/7,796/10,394 |

## Known issues (relevant)

| ID | State | Note |
|---|---|---|
| KI-010 | OPEN | RU-native-only text with no English (e.g. GooseRunner hints); now covered by the KI-018 asset list |
| KI-013 | OPEN | Native "ar" needs DA_Audio schema tooling (Phase 8); carrier ko-KR is the interim route |
| KI-014 | CONFIRMED | Replacement font faces have zero Hangul; mitigated by English-fill carrier p2 |
| KI-015 | NOTED | UnrealLocres normalizes LF to CRLF inside multiline values (5 values / 56 keys) |
| KI-016 | NOTED | 728 duplicate IDs already existed in the master before this program; baseline, not ours |
| KI-017 | BLOCKED | Obfuscated dialogue asset NotLifted_17 (encoded payload, not text) - evidence in reports/dialogue_obfuscated.md |
| KI-018 | NOTED | All non-locres cooked dialogue assets are Russian-only: 248 assets / 6,012 strings (complete DT_Subtitles_* family) |

## What I should send back

- One instruction: "translate dialogue" (start EN -> AR for the 10,394 rows),
  "test 3" (finish the in-game checklist), or "next phase".
