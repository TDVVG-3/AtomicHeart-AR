# Cycle 007 report - Arabic translation program: Phase 0 + pilot build

Date: 2026-10-18 (local 20:49 +03:00 / UTC 17:49)  |  State: PILOT BUILT, NOT INSTALLED - gate reached

## What this cycle did

1. Phase 0 (no stopping between steps):
   - TOTAL = 27,618 master rows with a non-empty English source (Status TECHNICAL 0, BLOCKED 0);
     19,996 UNIQUE English strings = the size of the work, since each unique string is
     translated once and reused where the context matches.
   - Work order written to reports/translation_plan.md: tier 1 UI/menus/HUD/tutorials/items/
     weapons/skills/objectives, tier 2 dialogue/subtitles/cutscenes, tier 3 lore/mail/DLC/credits.
     Cumulative cutoffs: batch1 6,905 (25%), batch2 13,809 (50%), batch3 20,714 (75%),
     batch4 27,618 (100%).
   - Glossary built BEFORE translating: 136 entries (all DRAFT), every entry verified to occur
     in the English corpus. 26 judgement calls left for the user in glossary_questions.md.
   - Style guide glossary/terminology.md: MSA, register map per character, Western digits only,
     Arabic question mark/comma, byte-exact tags/placeholders/engine markers, UI length rule,
     translation-memory rule, Status workflow, validation gates.

2. Pilot (steps 5-8):
   - 60 rows translated (20 UI, 20 short dialogue, 20 long subtitle incl. tags/markers/numbers)
     = 57 unique strings, plus the 25 phase-7 seed rows carried forward => 85 rows with Arabic,
     all Status DRAFT. Coverage: 85 of 27,618 (0.3%).
   - Validator PASS with 0 errors (1 accepted length warning on a proper name).
   - Glyph gate PASS: all 113 distinct codepoints used by the pilot Arabic exist in the subtitle
     face the v2 font pak installs (BlenderPro-Medium -> IBM Plex Sans Arabic Medium). No font
     pak extension is needed for the pilot.
   - Carrier builder extended from NewP5-only to ALL 35 ko-KR locres scopes (UI, dialogue,
     subtitles, cutscenes, mail, DLC). Pilot pak p3: 27,618 keys, 85 Arabic, 27,533 English-fill,
     0 kept Korean, round-trip 0 failures, unpack verify 35/35 byte-identical. NOT installed.

## Defects found and handled

- KI-019 (FIXED, in-game proof pending): the INSTALLED p2 carrier ships malformed rich-text tags
  in the 7 seeded game-tip rows (CSV-escaped quotes never unescaped -> `id=""Button.ConsumeItem""`).
  Found by the new validator, confirmed by unpacking the installed pak. p3 fixes it.
- KI-020 (OPEN, needs approval): Python is not installed (Store alias only), so the requested
  scripts/validate_translation.py cannot run; the same checks run via the PowerShell twin.
- KI-021 (MITIGATED): PowerShell 5.1 reads .ps1 as ANSI without a BOM, mangling Arabic literals
  inside scripts. Rule: Arabic only in UTF-8 data files. The validator now hard-fails mojibake.

## Numbers

- master rows: 27,618 | unique English: 19,996 | rows with Arabic: 85 (DRAFT)
- p3 pak: sha256 b58029662e5acf775087426ed85721905a5846127d6af5c209a482514f7b41df, 3,612,753 bytes
- validator: 0 errors / 1 warning | glyph gate: 0 missing / 113 used | carrier: 0 round-trip failures

## Gate

STOPPED at the pilot gate. The user runs reports/pilot_in_game_checklist.md (install p3 on their
approval), reports back, and batch 1 starts on their "next". Nothing was installed, uploaded, or
changed outside the project folder; the game folder was only read.
