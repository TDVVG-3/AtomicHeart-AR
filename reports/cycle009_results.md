# Cycle 009 results - pilot result recorded, opening-scene Arabic proof (carrier p4)

Date: 2026-10-18. State: WAITING FOR USER (p4 installed - run the bridge check and report).
Spec hash this cycle: `579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35` (unchanged, PASS).

## 1. What the user asked for, and what was done

| # | request | result | evidence |
|---|---|---|---|
| 1 | Record the pilot result (English where Korean was) in STATUS/KI/DECISIONS | DONE | `STATUS.md` Cycle 009, KI-009 updated, DEC-026 part 1 |
| 2 | Say whether the subtitle is shown in timed parts or truncated | ANSWERED (PARTIAL) | `reports/subtitle_display_finding.md`, KI-022 |
| 3 | Find the scene (search the 4 phrases) | DONE | `reports/scene_search.md`; scope `Chelomey_Dialogues`, row `/DC11CB9A4BFFB0AA5E099DAA4057EEE9` |
| 4 | Translate the scene (about 40 rows) | DONE | `reports/scene_opening.md` (41 rows: 12 speech + 29 labels) |
| 5 | Arabic only in UTF-8 data, TM + master + DRAFT + validator + glyph gate + reference | DONE | `scene_opening_ar.tsv`, `scene_apply.ps1`, `reports/translation_validation.md`, `reports/glyph_gate.md`, `AR_EN_REFERENCE.md` |
| 6 | Build carrier p4 (p3 + three fixes + scene) and install it reconciled | DONE | `reports/carrier_build.md` (p4), `reports/install_verification.md` |
| 7 | Short in-game checklist | DONE | `reports/scene_bridge_ingame_check.md` |
| 8 | Rewrite HANDOFF and stop | DONE | `HANDOFF.md` (+ `reports/history/handoff_013.md`) |

## 2. Scene located (request 3)

- The phrase "step away from amazing evolutionary victory" exists in exactly one master row:
  scope **`Chelomey_Dialogues`**, key **`/DC11CB9A4BFFB0AA5E099DAA4057EEE9`**, master line 289,
  431 characters with 3 timing markers. The same key exists in the ko-KR locres (211 chars), which
  confirms the carrier can fill it.
- The scene was taken as the consecutive block of that asset, master lines **284-324**:
  12 loudspeaker/PA speech rows (284-295) + 29 crowd speaker-label rows (296-324).
- "Dmitry Sechenov" appears in 16 rows (the speech + lore rows in other scopes); "Facility 3826"
  in lore rows across `NTD`, `NewP5` and others; "Welcome to the future" in the speech only.

## 3. Translation (request 4) - 40 new rows, DRAFT

- 11 new speech rows + 29 label rows = **40 rows**; the 12th speech row already carried pilot Arabic
  and was left untouched, so the scene is **41 rows**.
- Markers (`*0.10*` ...), tags and placeholders are byte-identical to the English (the validator
  compares the multiset of markers, tags, placeholders and escapes).
- Every Arabic segment is shorter than the English segment it replaces, so the Arabic should fit
  the subtitle panel at least as well as the English fill did.
- Made-up terms and their treatment are listed in `reports/scene_opening.md` and DEC-026 part 3.

## 4. Pipeline results (request 5)

| check | result |
|---|---|
| `scripts/scene_apply.ps1` (first run) | 40 master rows filled, 0 mismatches, TM 82 -> 102 entries |
| `scripts/scene_apply.ps1` (second run, idempotency) | 40 rows "already identical", 0 appended |
| `scripts/validate_translation.ps1` | PASS - 27,618 rows, 125 with Arabic, **0 hard errors**, 2 warnings (1 new number-as-word, 1 pre-existing UI length) |
| `scripts/glyph_gate.ps1` | PASS - 113 distinct codepoints, 0 missing in the subtitle face and in the union |
| `scripts/build_reference.ps1` | 125 rows / 102 unique / 12 scopes |
| coverage | **125 of 27,618 (0.45%)** |

## 5. Carrier p4 (request 6)

| property | value |
|---|---|
| file | `zzz_atomicheart-ar_carrier_koKR_p4_P.pak` |
| size | 3,614,845 bytes |
| sha256 | `aa894b4468888ac22a3fd3e58619d4cdb70ae24a895c35f286b002b2f4132f22` |
| scopes | 35 of 35 |
| keys | 27,618 (Arabic 125, English-filled 27,493, kept Korean 0) |
| round-trip | 26,128 byte-exact, 1,490 newline-normalized only (accepted, KI-015), 0 failures |
| unpack check | 35 of 35 entries byte-identical |

Installed with the reconciling installer (APPROVED): carrier p3 removed (hash-verified), font v2
kept unchanged, manifest rewritten, before/after snapshot diff **PASS** - nothing in the game
folder changed outside `Paks\~mods`, `AtomicHeart.exe` unchanged, 19/19 stock paks unchanged.

## 6. Subtitle display question (request 2) - answer in one paragraph

The string on disk is complete (431 chars) and the pak round-trip loses nothing, so the mid-word
cut in the screenshot is a display-time effect, not truncated data. The visible text started
exactly at the second timing marker, which shows the game plays the row in marker-defined parts;
no marker text is printed on screen, so the engine interprets the markers. Whether a part longer
than the visible panel can lose its tail (clipping) or is always fully revealed (typing/scroll)
cannot be decided from a still frame: the widget is `WBP_TypingTextBox` and the Korean 211-char
string is known to display fine, which suggests reveal/scroll rather than a hard 2-line clip.
Checklist item 4 settles it. Full analysis: `reports/subtitle_display_finding.md` (KI-022).

## 7. Not done / open

- Batches 1-4 have not started (they wait for "next").
- Speaker-marker question still unanswered by the user.
- The 3 pilot areas (GameTips popups, subtitle Arabic rendering, tip icons) are answered for the
  bridge subtitle only; GameTips remains NOT TESTED.
- Proposed glossary additions are documented but deliberately not yet written into
  `glossary/glossary.tsv` (they would add validator warnings where Arabic does not repeat the
  English term).
