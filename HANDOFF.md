# HANDOFF - Atomic Heart Arabic localization

DATE-TIME: 2026-10-18 19:52 (local)
CYCLE: 006
CURRENT STEP: Test 3 checklist issued to the user - awaiting in-game results
STATE: WAITING FOR USER

## Summary (5 lines)

1. Dialogue/cutscene program is COMPLETE: 10,394 of 10,394 (100%) English-source strings covered.
2. Test 3 checklist is written and handed over: reports/test3_checklist.md (non-developer, A/B/C/D).
3. The installed set is confirmed read-only: carrier p2 (503,841 B) + font v2 (1,461,408 B); 19 stock paks untouched.
4. Test 3 covers Settings labels (9 Arabic seeds), a Game Tips popup (7 seeds) and a dialogue/subtitle look.
5. Arabic is NOT expected in dialogue yet; that screen only checks visible-vs-blank. Nothing installed/removed.

## Completed

- Wrote reports/test3_checklist.md: step-by-step checklist with what to screenshot and the
  per-screen A/B/C/D letter meanings, plus an appendix listing the exact expected Arabic.
- Recovered the original Test-3 semantics and letter definitions from report_005.md so the
  new checklist stays consistent with what the user already confirmed (main menu = A).
- Verified the installed mod set read-only (manifest SHA256 match; 19 stock paks untouched).
- Spec hash re-checked: PASS.

## Problems

- None this step. No game-side change was made.
- Standing: KI-016 (728 pre-existing duplicate IDs) unchanged; KI-017 (obfuscated asset)
  and KI-018 (Russian-only assets) are documented and blocked/noted, not acted on.

## Evidence

- reports/test3_checklist.md (8,002 bytes) - the checklist + expected-Arabic appendix.
- Read-only install check: ~mods has exactly the two paks + manifest; manifest SHA256
  values match the files; Paks root file count = 19.
- Seed source: localization/working/phase7_seed.csv (25 keys: 9 menu, 9 settings, 7 tips).
- Dialogue program evidence stays in reports/dialogue_inventory.md and report_009.md.

## Files Changed

- New: reports/test3_checklist.md, reports/history/report_010.md,
  reports/history/handoff_010.md.
- HANDOFF.md, lastreport.md refreshed. No game files touched.

## Current Status

- Dialogue/cutscene coverage: 10,394 of 10,394 (100%) - COMPLETE (cycle 006).
- Arabic translation: NOT STARTED (column empty, by design).
- Test 3: checklist delivered; awaiting the user's 3 screenshots and A/B/C/D letters.
- Test 3 result so far: Settings / GameTips / Dialogue = NOT REPORTED YET.
  (Earlier: main menu = outcome A CONFIRMED.)
- Nothing installed or removed this step; game folder read-only; nothing uploaded.

## Next Action

Wait for the user's Test-3 report. When it arrives:
- record the result in STATUS.md, KNOWN_ISSUES.md (KI-009) and DECISIONS.md;
- if outcome A, propose the scale-up plan (full corpus translation, composite font
  Phase 8, KI-013 language-list tooling);
- if B/C/D, diagnose from the screenshots before changing any file.

## What I need you to do

- Run the three checks in reports/test3_checklist.md and send:
  three screenshots (Settings, Game Tips, Dialogue) plus the block
  "Settings: A/B/C/D - GameTips: A/B/C/D - Dialogue: A/B/C/D".
- Do not install or uninstall anything; keep the language on Korean.
- If the game crashes or shows an anti-tamper/signature error, stop and tell me.

## Decisions made (relevant)

| ID | Decision |
|---|---|
| DEC-016 | Carrier English-fill policy (25 Arabic seeds + 5,572 English-filled of 5,597 keys) |
| DEC-017 | Dialogue program rules; Test-3 main menu = outcome A confirmed (Part 1) |
| DEC-021 | Classifier corrected; dialogue TOTAL = 10,394 (100% covered) |

## Known issues (relevant)

| ID | State | Note |
|---|---|---|
| KI-009 | MENU-CONFIRMED | Arabic renders in the main menu; settings pages + Game Tips still unverified (this test) |
| KI-013 | OPEN | Native "ar" needs DA_Audio schema tooling (Phase 8); carrier ko-KR is the interim route |
| KI-014 | CONFIRMED | Replacement font faces have zero Hangul; mitigated by English-fill carrier p2 |
| KI-017 | BLOCKED | Obfuscated dialogue asset NotLifted_17 (not text) - reports/dialogue_obfuscated.md |
| KI-018 | NOTED | All non-locres cooked dialogue assets are Russian-only: 248 assets / 6,012 strings |

## What I should send back

- The three screenshots and the one-line A/B/C/D block. That is all I need.
