# HANDOFF - Atomic Heart Arabic localization - cycle 016 + P4 + C6

**Date:** 2026-10-26 15:31 (+03:00)
**State:** P4.3 is complete as three build-only carriers. **None of p11e / p11f / p11ef is
installed.** The real game still runs the previously verified **p11c_tips_x150** set
(carrier p11c + font v3 + tips x1.5). The C6 RU-only pak and all new P4.3 paks remain
**NOT INSTALLED**.
**Rule for this file:** rewritten after every completed item, not only at cycle close.

---

## 1. Workstream status

| workstream | status | detail |
| --- | --- | --- |
| **P4.1 - tips / notifications** | **DONE (INSTALLED in `p11c_tips_x150`)** | 20 timed tips x1.5 + item notification `WaitTime` 5.25 s; read-back 42/42 |
| **P4.2 - subtitle hold** | **DONE (INSTALLED via p11c)** | p11c extends 632 explicit range ends (+0.3 s; long rows x1.15); singleton pages untouched |
| **P4.3 - final-page + shortening** | **DONE (BUILD-ONLY, NOT INSTALLED)** | p11e: 140 final singleton pages become explicit ranges; p11f: 153 long pages shortened to <=21 chars/s; p11ef: both |
| **P4.4 - gates** | **DONE** | p11e/f/ef validator + audit + glyph + carrier round-trip all pass; switch/test matrix pass |
| **P4.5 - blueprint hide investigation** | **DONE (read-only)** | CONFIRMED immediate `RemoveFromParent` and 0.15 s fades; no widget timer; no cooked INI hold constant; native scheduler UNKNOWN |
| **P4.6 - switch + guide** | **DONE** | p11e/f/ef + tips x1.5 + `-RuOnly` combinations added and exercised in temp installs |
| **A - subtitle timing (P1/P2)** | **DONE (analysis) / p11 baseline available** | 537/537 markers byte-exact; p11b and p11c are experiments |
| **B - subtitle shimmer (P3)** | **DONE (font builds + install) / VERDICT PENDING** | v3 installed; v3b built as experiment C |
| **C1 - tone pass** | **DONE** | 125 rules / 212 rows / 25 scopes |
| **C2 - guillemet pass** | **DONE** | 103 rules / 146 rows |
| **C3 - glossary** | **DONE** | 7 fixes + accepted variants + 5 compound exceptions; 0 glossary warnings |
| **C4 - 2,588 name-like values** | **DONE (reclassified)** | 2,519 already translated, 69 technical ids, 2 CHAR rows deliberate |
| **C5 - KI-028 `1 //` widget** | **BLOCKED** | widget-drawn, not in any data row; Phase 8 |
| **C6 - KI-018 RU-only assets** | **DONE (build-only, NOT INSTALLED)** | 248 assets; 13,802 source strings; pak round-trip 496/496 byte-identical |
| **C7 - KI-013 14th culture** | **BLOCKED (re-checked 2026-10-24)** | 13 cultures live in an opaque cooked `Extras` blob; Phase 8 editor only |
| **C8 - final reports** | **DONE** | coverage, English-filled list, 30 longest UI labels, reference, 40-row sample |

---

## 2. P4.3 build artifacts - **NOT INSTALLED**

| pak | bytes | SHA256 | built |
| --- | ---: | --- | --- |
| `build\package\zzz_atomicheart-ar_carrier_koKR_p11e_P.pak` | 4,474,840 | `f2e3af3499fe47f7bac7fa72edfbf41d1edab3172c05fe7fdd3e8f16b16e8e37` | 2026-10-25 23:26:26 +03:00 |
| `build\package\zzz_atomicheart-ar_carrier_koKR_p11f_P.pak` | 4,463,686 | `5fda2388b443a47832d54f33449a57e63c3afe747da8af4c3136ad9e4acc82c6` | 2026-10-25 23:27:08 +03:00 |
| `build\package\zzz_atomicheart-ar_carrier_koKR_p11ef_P.pak` | 4,465,714 | `82a9c373ac68ab64f93c51f533bc72bf02a2359b9bea1ca83f68238adfdb7dd3` | 2026-10-25 23:27:51 +03:00 |

Carrier build reports: `reports\carrier_build_p11e.md`, `reports\carrier_build_p11f.md`,
`reports\carrier_build_p11ef.md`. Each pak was unpacked and compared; round-trip PASS.

Variant masters:

- `build\variants\atomic-heart-ar_p11e.tsv` - 140 final singleton markers converted to
  explicit ranges; 264 non-monotonic/ambiguous marker rows left byte-identical and listed
  in `reports\p11e_last_page_ranges.md`.
- `build\variants\atomic-heart-ar_p11f.tsv` - separate p11f master; 153 pages shortened
  across 117 rows. The canonical master is untouched.
- `build\variants\atomic-heart-ar_p11ef.tsv` - p11e + the same 153 page replacements.

`p11f` page edits were validated in `build\p4\p11f_applied.tsv` (16 columns): **153/153**
replacements, 0 missing/extra, 0 tag/number mismatches, **0 still above 21 chars/s**.
Accepted page replacements were appended to `localization\working\tm_fixups.tsv` (153 rows).
Arabic reduction: **9,990 -> 6,503 chars (34.9%)**. Before/after report:
`reports\p11f_shortened.md`.

---

## 3. Installed set - unchanged

The real game `Paks\~mods` still contains exactly the 2026-10-25 11:21:07 set. No file in
the game folder was written during this work.

| file | bytes | SHA256 |
| --- | ---: | --- |
| `zzz_atomicheart-ar_carrier_koKR_p11c_P.pak` | 4,474,004 | `cfb590e87e6e14e17a07e704d7d6065c5392ea98b70cf6702231746d3c4b8815` |
| `zzz_atomicheart-ar_font_p3_unhinted_P.pak` | 1,455,228 | `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4` |
| `zzz_atomicheart-ar_tips_x150_P.pak` | 75,853 | `36de01c37231a8b88ec9fc744c4f663bb8461a56adede9a6a2151d78c7ef7fcc` |
| `atomic-heart-ar-install-manifest.json` | 2,386 | `8a2a29bafadea8b25af215df898761f678531005db8ae4ccb7bd038a1571c406` |

Optional RU-only add-on, also **NOT INSTALLED**:
`build\package\zzz_atomicheart-ar_ruonly_p1_P.pak` - 7,998,115 bytes -
`beceb894bcaaeac546da8d847af815b42493a971ed45dc8d8b2693332eaa1cc3`.

---

## 4. Gates for the new variants

| variant | validator | structural audit | glyph gate |
| --- | --- | --- | --- |
| `p11e` | **PASS**, 0 errors / 368 warnings (`-AllowFinalMarkerRange`) | 537 rows with Arabic; 140 converted; 264 ambiguous; **0 violations** | **PASS**; 0 introduced-by-Arabic missing; 37 source-inherited non-Latin |
| `p11f` | **PASS**, 0 errors / 243 warnings | 537 rows; 153 changed pages; **0 violations** | **PASS**; 0 introduced-by-Arabic missing; 37 source-inherited non-Latin |
| `p11ef` | **PASS**, 0 errors / 381 warnings (`-AllowFinalMarkerRange`) | 537 rows; 153 changed pages; **0 violations** | **PASS**; 0 introduced-by-Arabic missing; 37 source-inherited non-Latin |

Reports:

- `reports\p11e_translation_validation.md` (re-run 2026-10-25 23:37:43)
- `reports\p11e_audit.md` (re-run 2026-10-25 23:37:44)
- `reports\p11f_translation_validation.md`
- `reports\p11ef_translation_validation.md`
- `reports\glyph_gate_p11e.md`, `reports\glyph_gate_p11f.md`, `reports\glyph_gate_p11ef.md`

The 37 missing codepoints are inherited from the English/source content (Cyrillic, Japanese,
U+202F, U+2060), not introduced by the Arabic. The subtitle face has no Latin gaps.

---

## 5. P4.5 blueprint verdict - read-only

Full evidence: `reports\p4_subtitle_hide_blueprint.md`.

**CONFIRMED**

- `WBP_OneSubtitle.Hide` clears the typing text, clears the speaker name, then calls
  `RemoveFromParent` immediately. No timer/fade in that function.
- `WBP_Subtitle.HideSentence(Marker)` looks up the marker in the `Subtitles` map, calls
  `Hide` on the matching widget, and removes the map entry.
- `WBP_Subtitle.RemoveAllSubtitles` clears `VerticalBoxSubtitles` and the map; it does not
  own a display timer.
- `WBP_TypingTextBox.AnimatedHide()` plays a `Hide` animation whose `RenderOpacity` goes
  **1.0 -> 0.0 over 9000 ticks @ 60000 = 0.15 s**.
- `WBP_NPCSubtitle.HideBack` has the same **0.15 s** `RenderOpacity` fade (plus a
  `WidthOverride` track). `HideWidget` only toggles `Overlay_0` visibility.
- `BP_SubtitlesSubsystem` is a native `SubtitlesSubsystem` subclass with no script
  functions; its defaults are `WidgetTemplate`, `SubtitleSizeScale=0.75`, tables, and
  `bShouldBeCreated`.
- Cooked INI has **no** `[/Script/AtomicHeart.SubtitlesSubsystem]` section and 0 hits for
  `SubtitleSizeScale`, `HorizontalFreeSpace`, `bEnableShow`, `TimeBetweenChars`,
  `DisplayTime`, `MinDuration`, `MaxDuration`, `HideBack`, `RenderOpacity`.

**LIKELY**

- The marker/caller drives the hide; widgets do not own display duration.
- The 0.15 s values are visual fade-out only, not extra reading time.

**UNKNOWN**

- Exact native `SubtitlesSubsystem` scheduling: which event (audio marker boundary, row
  end, audio end, or explicit `Duration`) invokes `HideSentence`. No bytecode surgery was
  performed, and the native implementation is not in the cooked Blueprint data.

Safe **copy-only** property experiment: `HorizontalFreeSpace 40.0 -> 80.0` in a JSON copy,
read back 80.0, exactly 1 scalar changed, all `ScriptBytecode` blobs hash-identical. No
`.uasset` re-serialization, no pak, **NOT INSTALLED**. Evidence:
`build\blueprint_probe\experiment\readback.json`.

---

## 6. Switch and test matrix

`scripts\switch_variant.ps1` accepts:

```text
p11e  p11f  p11ef
p11e_tips_x150  p11f_tips_x150  p11ef_tips_x150
```

`-RuOnly` works on every one of them and is removed by switching to the same variant
without `-RuOnly`.

`scripts\test_variants_temp.ps1` result: **PASS**.

- 22 dry-run + temp real-install rows: all PASS.
- 12 forced-failure rollback rows (all p11e/f/ef plain, tips, `-RuOnly`, and
  tips+`-RuOnly` combinations): all PASS; exit code 1; exact baseline restored byte-for-byte;
  `ROLLED BACK TO` printed.
- Report: `reports\variant_test_matrix.md` (2026-10-26 15:30:12 +03:00).
- Real `Paks\~mods` was only read as the baseline copy; all test writes went to
  `build\test_mods` and `build\test_switch`.

A/B guide updated: `reports\ab_test_guide.md` now has one-line rows for p11e, p11f, p11ef,
their tips x1.5 combinations, rollback commands, and the `-RuOnly` note.

---

## 7. Commands

Close the game first. These commands install manually; nothing here was auto-installed.

```powershell
# p11e only (final singleton page explicit range)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11e

# p11f only (153 shortened pages)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11f

# both + tips x1.5
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11ef_tips_x150

# add the RU-only cooked-dialogue pak on top
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11ef -RuOnly

# remove the RU-only pak (same variant, no switch)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11ef

# roll back to the current verified installed set
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11c_tips_x150
```

`switch_variant.ps1` takes a before-snapshot, backs up `~mods`, verifies hashes of
superseded files, installs only inside `Paks\~mods`, runs `verify_install.ps1`, and restores
the backup on any failure.

---

## 8. What to test (if installed manually)

1. A cinematic conversation with several pages: does the **last page** stay a little longer
   under p11e?
2. A long NPC/cinematic line: is the shortened Arabic readable under p11f, with the same
   meaning, speaker tags, numbers, and markers?
3. p11ef: the long line plus its last page, the shortest reading-time case.
4. p11e_tips_x150 / p11f_tips_x150 / p11ef_tips_x150: same line plus a short tutorial hint
   and a pickup notification.
5. `-RuOnly` on any of the above: Chelomey/Academy RU-only dialogue, terminal mail/dossier,
   GooseRunner hint, world-space NPC name.
6. Rollback at any time with the command above; verify the installed manifest and hashes.

Known residual: ordinary singleton pages without an explicit end still depend on the native
audio/marker timeline. p11e can only extend the final page when the marker track is
monotonic; 264 non-monotonic rows are deliberately untouched and documented.

---

## 9. Key files

- `build\p4\p11f_applied.tsv` - 153 validated before/after page edits.
- `build\variants\atomic-heart-ar_p11e.tsv`, `_p11f.tsv`, `_p11ef.tsv` - variant masters.
- `scripts\p4_build_p11f_edits.ps1` - regenerates/validates p11f edits.
- `scripts\apply_p11f_edits.ps1` - applies validated edits to a base master.
- `scripts\p4_subtitle_audit_p11e.ps1`, `scripts\p4_subtitle_audit_p11f.ps1` - audits.
- `scripts\p4_probe_subtitle_constants.ps1` - copy-only constant/read-back probe.
- `scripts\switch_variant.ps1` - all variants + tips + RU-only.
- `scripts\test_variants_temp.ps1` - dry-run/install/rollback matrix.
- `reports\p4_subtitle_hide_blueprint.md` - blueprint/INI verdict.
- `reports\p11f_shortened.md` - p11f before/after.
- `reports\p11e_last_page_ranges.md` - 140 converted + 264 ambiguous rows.
- `reports\variant_test_matrix.md` - switch matrix.
- `reports\ab_test_guide.md` - one-line A/B table.

Working tree remains dirty/uncommitted; `build\` is untracked. No commit was made.

**STOP.**
