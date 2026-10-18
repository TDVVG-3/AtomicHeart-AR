# Cycle 008 results - pilot install (p3) + reviewer fixes + speaker-marker check

Date: 2026-10-18 21:36 (+03:00)  |  State: WAITING FOR USER (pilot gate; carrier p3 installed)

This is the results file for the work you ordered in this turn (6 items). Everything below is
local only: nothing was uploaded, and the only game-folder writes are the `~mods` files listed.

---

## 1. Install (your task 1) - DONE and PROVEN

Order: uninstall only the old carrier p2 (hash-verified), install carrier p3, keep font v2,
verify the manifest and that `~mods` holds exactly the three files, prove nothing else changed.

`scripts/install_mod.ps1` was rewritten into a **reconciling** installer: it deletes only files
recorded in the previous manifest whose on-disk sha256 matches, then installs the requested set,
then verifies the folder and prints every hash. Result:

| action | file | size | sha256 |
|---|---|---|---|
| REMOVED (hash-verified) | `zzz_atomicheart-ar_carrier_koKR_p2_P.pak` | was 503,841 | `3d4b0ea65c5dc789be98b46aa18c7c27959445b7d36454616b91be2ae55fa9e1` |
| INSTALLED | `zzz_atomicheart-ar_carrier_koKR_p3_P.pak` | 3,612,753 | `b58029662e5acf775087426ed85721905a5846127d6af5c209a482514f7b41df` |
| KEPT | `zzz_atomicheart-ar_font_p2_plex_P.pak` | 1,461,408 | `02b17f31e61a46ddba20bea8c4da5be44164173df608d52697f68d27d8269747` |
| REWRITTEN | `atomic-heart-ar-install-manifest.json` | 1,823 | `346abd7f291f36d7aa033785c4e16d8dc9272e24d5d59443477130bc215298bd` |

Verification (`scripts/snapshot_game_folder.ps1` before/after + `scripts/verify_install.ps1`):
**PASS** - no file or directory added, removed or changed anywhere in the game folder outside
`Paks\~mods`; `AtomicHeart.exe` unchanged; 19/19 stock paks unchanged (same size and mtime);
`~mods` contains exactly the manifest + the two paks.
Evidence: `reports/install_verification.md`, before-snapshot `reports/install_verify/before_p3.json`.

## 2. Python (your task 2) - DECLINED, recorded

`scripts/validate_translation.ps1` (PowerShell) stays the primary and authoritative validator.
The `.py` twin remains a delivered artefact for a machine that has Python.
**KI-020 is CLOSED (not needed).**

## 3. Glossary questions (your task 3) - all 26 defaults ACCEPTED

`glossary/glossary_questions.md` now records that every recommended default is accepted
(2026-10-18). The sensitive groups (robot nicknames, science/Soviet terms, tone) are flagged for
your review after batch 1, and any change will go through the reviewer-fix workflow.

## 4. The three pilot fixes (your task 4) - APPLIED, revalidated, pak NOT rebuilt

Rules live in the UTF-8 data file `localization/working/tm_fixups.tsv` and are applied by
`scripts/apply_text_fixups.ps1` (master Arabic column + `localization/working/tm.tsv` +
`localization/working/phase7_seed.csv`). The pass is idempotent (a second run changes 0 rows).

| fix | rows touched | detail |
|---|---|---|
| (a) grammar | 2 | `Theatre_Dialogues` **and** its identical sibling `DIALOGUES FOR LQA` - both carry the same key `/962A2FA3462F1CE524EB09B650D0C297` and held the same phrase; you named the Theatre row, I fixed both so the sibling would not keep a known error (say the word and I revert the LQA one) |
| (b) stealth-kill tip | 1 | `NewP5`, key `ST_GameTips_Texts_/esli_protivnik_stoit_spinoy`; the `<h>...</>` and `<tag id="InputAction.Gameplay.StealthKill"/>` are byte-unchanged |
| (c) surgeon "Swab" | 1 | `Schebetar_Subs`, key `/9511248745986BD47D906A9DB6D80DE0` |

Proof: `scripts/verify_text_fixups.ps1` -> **PASS** (old text gone from master and memory, new text
present, master vs memory 85/85 identical); `scripts/validate_translation.ps1` -> **PASS, 0 errors,
1 accepted warning**; `localization/references/AR_EN_REFERENCE.md` regenerated (85 rows).
Log: `reports/text_fixups_log.md`. **No pak was rebuilt** - these fixes ship in p4.

## 5. Speaker markers (your task 5) - EVIDENCE + CHECK + RULE

Facts (`reports/speaker_markers.md`): 130 master rows contain an inline `&Speaker&` marker,
145 distinct tokens, and they exist **only** in three DLC2 "Schebetars" scopes
(`Schebetar_Subs` 90, `Schebetars_dlc1` 39, `Locations_dlc2` 1). The base game has none.
The markers are present in every language's string, so the game either strips them or displays them.

Your check is `reports/speaker_marker_check.md` - start any DLC2 subtitled conversation and tell me
which you see:

- **A** a styled name label / speaker name -> the game parses the marker: we translate the names.
- **B** the raw text `&Surgeon&` -> the game shows the marker literally: we keep it byte-exact and
  report a game-side bug.
- **C** no name at all -> the game strips it: we keep it byte-exact (current rule).
- "not reached" is a valid answer if you cannot get into DLC2 dialogue.

Rule if A: characters transliterated (glossary), roles translated, non-verbal cues translated,
unit/asset names from the glossary, delimiters always Latin `&`. Written in
`glossary/terminology.md` section 10 and DEC-025.

## 6. Handoff + docs

`HANDOFF.md` was rewritten for Cycle 008 (state WAITING FOR USER) and carries the standing 40-row
AR/EN review sample (Arabic first, English below), which now shows the three corrected rows.
Updated: `STATUS.md` (Cycle 008 block), `KNOWN_ISSUES.md` (KI-020 closed), `DECISIONS.md` (DEC-025),
`glossary/terminology.md` (sections 10-11). Copies kept in `reports/history/`.

## Numbers

| metric | value |
|---|---|
| coverage | **85 of 27,618 (0.3%)** - unchanged; fixes touched existing rows only |
| master statuses | 27,533 UNTRANSLATED, 85 DRAFT, 0 TECHNICAL, 0 BLOCKED |
| master rows | 27,618 (13 columns) |
| validator | 0 errors, 1 accepted warning (length, proper name) |
| review sample | 40 rows (25 spread / 4 longest / 11 tagged), 2,984 Arabic characters, 0 mojibake |
| installed paks | carrier p3 + font v2 + manifest (exactly three files) |

## Gate

STOPPED at the pilot gate. Please run `reports/pilot_in_game_checklist.md` (areas D and E matter
most) plus the one speaker-marker question, then report back. Batch 1 starts only on your "next".
