# Cycle 009 report - pilot result recorded + opening-scene Arabic proof (carrier p4)

Date: 2026-10-18 (local 22:28 +03:00)  |  State: WAITING FOR USER (carrier p4 installed; bridge check pending)

## What this cycle did

1. Recorded the pilot result (your report, 2026-10-18): on the bridge, quest "NO REST FOR THE
   WICKED", objective "Cross the bridge", the subtitle showed the carrier's English text where
   Korean had been before. That CONFIRMS carrier p3 reaches the dialogue/subtitle scopes at runtime,
   not only the menu and settings text. Written into `STATUS.md` (Cycle 009), `KNOWN_ISSUES.md`
   (KI-009) and `DECISIONS.md` (DEC-026 part 1).

2. Answered the truncation question (`reports/subtitle_display_finding.md`): the locres string on
   disk is complete (431 chars, 3 markers) and the pak round-trip loses nothing, so nothing is cut
   at build time. The visible text in your screenshot began exactly at the second timing marker, so
   the game plays a row in marker-defined parts (CONFIRMED), and no marker text is printed on screen
   (the engine interprets it). Whether a part longer than the panel is clipped or scrolled is NOT
   TESTED - it is checklist item 4 in the new in-game sheet. New KI-022 records this.

3. Found and translated the opening scene: scope `Chelomey_Dialogues`, on-screen row
   `/DC11CB9A4BFFB0AA5E099DAA4057EEE9` (master line 289); the scene is the consecutive block
   master lines 284-324 of that asset - the loudspeaker/PA speech of the street and bridge plus the
   crowd speaker labels of the same asset. 41 rows: 40 new + 1 that already carried pilot Arabic.

4. Stored the Arabic as UTF-8 data only (`localization/working/scene_opening_ar.tsv`, plus the
   generated `scene_opening_rows.tsv`), applied by the ASCII-only `scripts/scene_apply.ps1`, which
   verifies the English of every row before it writes and is idempotent (2nd run: 40/40 already
   identical, 0 appended). Master rows are DRAFT with note `scene:bridge-opening`; the union memory
   grew 82 -> 102 entries.

5. Ran the full gate: validator PASS (125 translated, 0 hard errors, 2 warnings - 1 new
   number-as-word, 1 pre-existing UI length), glyph gate PASS (113 codepoints, 0 missing),
   `AR_EN_REFERENCE.md` regenerated (125 rows / 102 unique / 12 scopes), review sample refreshed.

6. Built and installed carrier p4 (your APPROVED order): p4 = p3 + your three cycle-008 reviewer
   fixes + the 40 scene rows. Builder unchanged: 35/35 scopes, 27,618 keys, 125 Arabic, 27,493
   English-filled, 0 kept Korean, 0 round-trip failures, 35/35 unpack byte-identical, sha256
   `aa894b44...32f22`, 3,614,845 bytes. Reconciling install: p3 removed hash-verified, font v2 kept
   untouched, manifest rewritten; before/after snapshot + `verify_install.ps1` -> PASS, nothing in
   the game folder changed outside `Paks\~mods`.

7. Wrote the short in-game sheet `reports/scene_bridge_ingame_check.md` (how to reach the scene,
   what to look at, what to screenshot) and rewrote `HANDOFF.md` with the standing 40-row AR/EN
   sample; STATUS / KNOWN_ISSUES / DECISIONS updated; history copies kept.

## Defects found and handled

- `scene_report.ps1` used a local `$out` next to a `[string]$Out` parameter; PowerShell's
  case-insensitive names turned the report list into a string and `.Add` failed. Renamed the local
  variable (same class of trap as `$target` last cycle).
- The new speech row states the date as a word ("13th of June"), so the validator's number-multiset
  warning fires; that warning class is explicitly accepted (numbers legitimately become words).
- `snapshot_game_folder.ps1` prints a blank count for the game root when it holds no files (an empty
  generic list unrolls to null on return) - pre-existing, harmless: the diff treats it as empty.
- Chinese/Arabic console output shows `?` in the terminal; all report files are UTF-8 and correct
  (checked through the file reader, not the console).

## Numbers

- master rows: 27,618 | unique English: 19,996 | rows with Arabic: **125 (DRAFT)** = 125 of 27,618 (0.45%)
- scene: 41 rows in `Chelomey_Dialogues` (12 speech + 29 crowd labels), 40 newly translated
- validator: 0 hard errors / 2 warnings | glyph gate: 0 missing | reference: 125 rows / 102 unique
- carrier p4: 3,614,845 bytes, sha256 `aa894b4468888ac22a3fd3e58619d4cdb70ae24a895c35f286b002b2f4132f22`
- installed in `Paks\~mods`: p4 + font v2 + manifest (exactly three files)

## Gate

STOPPED at the p4 bridge check. You run `reports/scene_bridge_ingame_check.md` (item 4 - whether the
last words of a part appear - decides the one open display question), report back, and batch 1 starts
on your "next". Nothing was uploaded; the only game-folder writes were the approved `~mods` changes
above.
