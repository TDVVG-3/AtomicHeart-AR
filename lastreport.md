# Cycle 008 report - pilot install (p3) + reviewer fixes + speaker-marker check

Date: 2026-10-18 (local 21:36 +03:00)  |  State: WAITING FOR USER (pilot gate; carrier p3 installed)

## What this cycle did

1. Install, with your approval (your task 1): rewrote `scripts/install_mod.ps1` into a reconciling
   installer that removes only files we previously installed (verified against the old manifest's
   sha256) and installs the requested set. It removed the old carrier p2
   (`3d4b0ea6...5fa9e1`), installed carrier p3 (`b5802966...f7b41df`, 3,612,753 bytes), kept the
   font v2 (`02b17f31...8269747`) and rewrote the manifest (`346abd7f...5298bd`).
   Proof by new tools `scripts/snapshot_game_folder.ps1` (read-only before/after snapshot) and
   `scripts/verify_install.ps1`: PASS - nothing outside `Paks\~mods` was added, removed or changed;
   `AtomicHeart.exe` unchanged; 19/19 stock paks unchanged; `~mods` holds exactly the three files.
   Evidence: `reports/install_verification.md`.

2. Python (your task 2): declined; the PowerShell validator stays primary. KI-020 closed.

3. Glossary (your task 3): all 26 recommended defaults accepted; sensitive groups to be reviewed
   after batch 1.

4. Your three pilot corrections (your task 4) applied to the master, the memory and the seed CSV
   by `scripts/apply_text_fixups.ps1` with rules in the UTF-8 data file
   `localization/working/tm_fixups.tsv` (never as literals in a script, KI-021):
   (a) grammar fix - 2 rows (`Theatre_Dialogues` + its identical `DIALOGUES FOR LQA` sibling, same
   key); (b) stealth-kill tip - 1 row, tag byte-unchanged; (c) surgeon "Swab" - 1 row.
   Proved by `scripts/verify_text_fixups.ps1` (old text gone, master == memory 85/85) and the
   validator (0 errors, 1 accepted warning). Reference regenerated. **No pak was rebuilt** - the
   fixes ship in p4, as ordered. Log: `reports/text_fixups_log.md`.

5. Speaker markers (your task 5): evidence in `reports/speaker_markers.md` - 130 rows, 145 distinct
   tokens, DLC2 "Schebetars" scopes ONLY; the base game has none. The short in-game check is
   `reports/speaker_marker_check.md` (cases A/B/C). The conditional translate-the-names rule is
   written in `glossary/terminology.md` section 10 and DEC-025.

6. HANDOFF.md rewritten for Cycle 008 (WAITING FOR USER) with the standing 40-row AR/EN review
   sample; STATUS.md, KNOWN_ISSUES.md, DECISIONS.md updated; history copies kept.

## Defects found and handled

- The old installer could not "remove only p2, keep font v2" (hardcoded two-file set). Fixed by the
  reconciling installer; a hash mismatch on a superseded file aborts instead of deleting.
- `-f` inside a method-argument list mis-parses (`.Add('...' -f a, b)`): formatted values are now
  assigned to variables first (known PowerShell 5.1 trap).
- Case-insensitive variable names struck again while building the handoff splicer: assigning a
  string array to `$target` hit the `[string]$Target` parameter and silently coerced it into one
  space-joined string. Fixed with a distinct variable name; the splicer is idempotent
  (`scripts/embed_review_sample.ps1`).
- Two rows held the same grammar error (Theatre + LQA sibling, same key): both corrected; the
  sibling change is reversible on request.

## Numbers

- master rows: 27,618 | unique English: 19,996 | rows with Arabic: 85 (DRAFT) = 85 of 27,618 (0.3%)
- installed: carrier p3 + font v2 + manifest (exactly three files in `Paks\~mods`)
- validator: 0 errors / 1 warning | fixup verify: PASS | review sample: 40 rows, 0 mojibake
- speaker markers: 130 rows / 145 tokens, DLC2 only

## Gate

STOPPED at the pilot gate. The user runs `reports/pilot_in_game_checklist.md` (areas D and E matter
most) plus the speaker-marker question, reports back, and batch 1 starts on their "next". Nothing was
uploaded; the only game-folder writes were the approved `~mods` changes above.
