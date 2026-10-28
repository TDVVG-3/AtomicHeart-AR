# HANDOFF - Atomic Heart Arabic - p12 release

**Generated:** 2026-10-28 14:27:39 +03:00
**State:** release default installed and verified. `p12g`, `p12c`, `p12e`, `p12f`,
`p12ef`, and all RU-only combinations are built and gated but **NOT INSTALLED**.
**Write scope:** only the game's `Paks\~mods` was modified. No `.exe`, `.dll`, stock pak,
Steam, or Denuvo file was touched. Nothing was uploaded.

## 1. Current installed set (approved default)

`p12` carrier + font v3 (`p3_unhinted`) + `tips_x150`.

`Paks\~mods` contains exactly four files:

| file | size (bytes) | SHA256 |
| --- | ---: | --- |
| `atomic-heart-ar-install-manifest.json` | 2,383 | `5b17aaf4c538da6ecbdb6976bdf5c8eebf39f113955c5dcad4015a9e4c3c5c6a` |
| `zzz_atomicheart-ar_carrier_koKR_p12_P.pak` | 4,470,295 | `910c06f2609237ac021dc1d3e2a6af02a05c64a828efdfe497a711bac66860c3` |
| `zzz_atomicheart-ar_font_p3_unhinted_P.pak` | 1,455,228 | `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4` |
| `zzz_atomicheart-ar_tips_x150_P.pak` | 75,853 | `36de01c37231a8b88ec9fc744c4f663bb8461a56adede9a6a2151d78c7ef7fcc` |

Manifest variant string:

```text
carrier=zzz_atomicheart-ar_carrier_koKR_p12_P.pak ; font=zzz_atomicheart-ar_font_p3_unhinted_P.pak ; tips=x150
```

Install evidence: `reports/install_verification.md` - **PASS**, game-root changes 0,
Paks-directory changes 0, stock paks 19 before / 19 after, `AtomicHeart.exe` unchanged.
Snapshot: `build/snapshots/before_p12_tips_x150_20261028_142412.json`.
Backup of the previous `~mods`: `build/install_backup/p12_tips_x150_20261028_142412`.

## 2. Built and gated, but NOT INSTALLED

| carrier pak | size (bytes) | SHA256 | purpose |
| --- | ---: | --- | --- |
| `zzz_atomicheart-ar_carrier_koKR_p12g_P.pak` | 4,516,369 | `4109d8fcedc22160d836347fa6ee8e9a96beacbbf174175f8a5652dfa3eaee30` | p12 + H1t offsets + H2 caps + H3 caps/inserts |
| `zzz_atomicheart-ar_carrier_koKR_p12c_P.pak` | 4,471,621 | `a5dfda33fbf3ab1a8fdd1b45395d34aaf0212042c9f7f02fe3e16d6f6d98411b` | p11c base + p12 changes + H2 cap |
| `zzz_atomicheart-ar_carrier_koKR_p12e_P.pak` | 4,472,441 | `06a04207e6636b9923e532178184d1a5ead781023d3ba5a43deea446d19b18e9` | p11e base + p12 changes + H2 cap |
| `zzz_atomicheart-ar_carrier_koKR_p12f_P.pak` | 4,461,287 | `abb6db1075dfb82336495b8c69b2f0d4508caa9d633d269c32d442ad9f994b7d` | p11f base + p12 changes + H2 cap |
| `zzz_atomicheart-ar_carrier_koKR_p12ef_P.pak` | 4,463,315 | `db4387cc799e38c3fbcbfda5a2df63dbea99e1b5a8cb9e8332c771f2cd54974f` | p11ef base + p12 changes + H2 cap |
| `zzz_atomicheart-ar_ruonly_p1_P.pak` | 7,998,115 | `beceb894bcaaeac546da8d847af815b42493a971ed45dc8d8b2693332eaa1cc3` | RU-only dialogue add-on; **NOT INSTALLED** |

Rollback carrier:

| carrier pak | size (bytes) | SHA256 |
| --- | ---: | --- |
| `zzz_atomicheart-ar_carrier_koKR_p11c_P.pak` | 4,474,004 | `cfb590e87e6e14e17a07e704d7d6065c5392ea98b70cf6702231746d3c4b8815` |

`p12c`, `p12e`, `p12f`, and `p12ef` each changed `17` rows and applied `59` H2 caps;
their per-scope counts are in `reports/p12c_caps.md`, `reports/p12e_caps.md`,
`reports/p12f_caps.md`, and `reports/p12ef_caps.md`.

The installed font and tips paks are shared by the `_tips_x150` combinations; a
`p12g_tips_x150` install uses the `p12g` carrier above plus the same font and tips files.
The `p12`, `p12g`, `p12c`, `p12e`, `p12f`, `p12ef`, all `_tips_x150` combinations, and all
`-RuOnly` combinations passed the temp-install and forced-rollback matrix. Only the default
`p12 + font v3 + tips_x150` is approved for install; the other paks are build-only.

## 3. What p12 changes

### CHANGE 1 - keep original English weapon/item names

p12 starts from the clean canonical master `localization/master/atomic-heart-ar.tsv`, not
from p11c, p11e, or p11f. The p12 cell rules are in `tm_fixups_p12.tsv`; the same rules
were appended to `tm_fixups.tsv` for the record, but p12 never applies the older p11f
rules.

- `458` item NAME rows were marked `keep original name`; `445` had Arabic and `13` were
  empty. All `458` are `COPY` in the p12 master, so the carrier emits the English name.
- `125` sentence-like item-name candidates were scanned. `2` body-text rows containing
  `P-3` were removed from the cell-rule pool; `123` in-sentence rows were changed.
- Descriptions and tooltips stay translated. In-sentence names use the `[exact]`
  cell-scoped rules in `localization/working/tm_fixups_p12.tsv`; trailing punctuation is
  never glued onto a Latin name. A rule is never allowed to turn a translated Arabic
  sentence into an English-only cell; such candidates are skipped and logged.
- Ambiguous terms were left unchanged and are listed in
  `reports/keep_original_questions.md`.
- `123 of 27,618` rows changed by in-sentence cell rules; `458 of 27,618` rows are COPY
  names; body-text rows containing `P-3` changed: `0`.
- Before/after by scope: `reports/p12_master.md`.

### CHANGE 2 - P-3 speaker label

- `1,140 of 27,618` speaker-label rows that rendered `P-3` now render `الرائد` in every
  scope. Body text was not changed.
- Body rows containing `P-3` are excluded from all p12 cell rules. Body-P3 changed: `0`.
- Occurrence report: `reports/p3_name_occurrences.md` - `211` body rows; `100` Nechaev,
  `29` Major+Nechaev, `126` literal `P-3` (overlapping categories; per-scope table and row
  list in the report).

## 4. VEGA 9 subtitle-stack bug

### Finding

The screenshot scene is `VO_CS_01_15` (four lines: `Larisa_15`, `Victor_16`,
`Larisa_17`, `P3_18`). The audit found the four lines were markerless final pages with a
following scene row: the H3 pattern.

**Map-key source (CONFIRMED):** `WBP_Subtitle` stores each line in a map keyed by the
`Marker` argument to `ShowSentence(Text, Speaker, Marker)`. `ShowSentence` calls
`Map_Add(Subtitles, Marker, widget)`, and `HideSentence(Marker)` uses
`Map_Find` / `Map_Remove`. The key is the subtitle row marker, not the text, so duplicate
markers collide at the widget map. See `reports/p4_subtitle_hide_blueprint.md`.

| audit | p12 | p12g |
| --- | ---: | ---: |
| H1m marker/key collisions | 36 | 36 (stock level, not locres-fixable) |
| H1k key collisions | 15 | 15 (stock level, not locres-fixable) |
| H1t duplicate text-marker starts | 72 | 27 |
| H2 explicit end overlapping next start | 17 | 0 |
| H3 markerless/final page with following row | 2,953 | 343 |
| H4 stock en-US/ru-RU key collisions | 3 | 3 (stock level) |
| screenshot `VO_CS_01_15` H3 | 4/4 | 0/4 |

**Verdict:** H3 matches the screenshot: concurrent lines that never receive an explicit
end. H1/H2/H4 are not supported by the screenshot evidence. H1m/H1k/H4 are DataTable-level
stock conditions and cannot be repaired by a locres-only pak. H3 remaining 343 rows have no
usable clip duration; `p12g` inserted `*0-end*` for 2,422 markerless pages and added 188
explicit final-page ends.

p12g changed 2,658 rows. It applied `72` H1 duplicate-start offsets; `197` non-monotonic
H1 tracks were left byte-exact; it applied `59` H2 caps, `188` H3 final-page ends, and
`2,422` H3 markerless inserts. `343` H3 rows were skipped because no clip duration was
available. Absolute DataTable row start offsets are not
available, so H2/H3 uses the voice clip duration plus a 15 chars/s + 1.2 s reading
allowance rather than a true next-line start. This is the documented `UNKNOWN` limitation.

Reports:

- `reports/subtitle_stack_audit_p12.md` - baseline counts, per-scope table, 30 worst scenes.
- `reports/subtitle_stack_audit_p12g.md` - post-fix counts; screenshot scene 0/4 H3.
- `reports/p12g_caps.md` - per-scope H1/H2/H3 change counts.
- `scripts/subtitle_stack_audit.ps1` - H1-H4 audit, gated into the build chain.
- `scripts/apply_subtitle_caps.ps1` - H1/H2/H3 repairs.

### Bottom bar

`reports/subtitle_bottom_bar_p12.md` records read-only layout evidence:

- **CONFIRMED:** bottom-anchored, auto-size canvas; `150 px` top/bottom overlay padding;
  `2150 px` width; `SubtitleSizeScale=0.75`; sentence font `45` (`33.75 px` rendered);
  speaker font `35` (`26.25 px` rendered); sentence slot bottom padding `100 px`.
- **LIKELY:** four concurrent lines exceed the `150 px` bottom safe area at the current
  scale; the bottom-most P-3 line is the one that looks cut.
- **UNKNOWN:** exact engine clip owner (canvas / SizeBox / overlay / viewport). No bytecode
  or widget patch was made.

`p12g` reduces concurrency duration but cannot make the bottom bar taller. If the cut
remains when four lines are visible, the layout arithmetic is the remaining cause.

## 5. Gates and verification

| gate | result |
| --- | --- |
| validator - all six p12 variants | **PASS**, 0 hard errors |
| coverage - all six | **PASS**; 27,175 of 27,618 translated-or-copy; 443 untranslated copy-class; 27,618/27,618 accounted |
| glyph gate - font v3 | **PASS**; 37 source-inherited missing codepoints; 0 newly required by Arabic |
| stack audit - all six | **PASS**; H1-H4 report written |
| carrier round-trip | **35/35** for every p12-family carrier; unpack byte-identical; exact 27,617, newline 1, fail 0 |
| temp-install matrix | **PASS** for p12 family, `tips_x150`, and `-RuOnly` combinations |
| forced rollback matrix | **PASS** for every tested row |
| final install verification | **PASS**; outside `~mods` 0 changes; stock paks 19/19; EXE unchanged |

p12 validator warnings: `296`. p12g warnings: `2,952`, mostly number-multiset changes
caused by inserted timing markers; both variants have 0 hard errors. Gate summary:
`reports/p12_gate_all.md`; temp matrix: `reports/variant_test_matrix.md`; install proof:
`reports/install_verification.md`.

## 6. Exact switch/rollback commands

Run from `C:\AtomicHeart-AR`. Every command snapshots `~mods`, backs it up, installs,
runs `verify_install.ps1`, and rolls back automatically on failure.

```powershell
cd C:\AtomicHeart-AR

# Current release default
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12_tips_x150

# p12g (experimental H1/H2/H3 build), with and without tips
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12g
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12g_tips_x150

# p12c
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12c
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12c_tips_x150

# p12e
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12e
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12e_tips_x150

# p12ef
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12ef
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12ef_tips_x150

# p12f (built and gated; not in the required command list)
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12f
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12f_tips_x150

# Add the RU-only dialogue add-on to any variant
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12g -RuOnly
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12c -RuOnly
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12e -RuOnly
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12ef -RuOnly
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12g_tips_x150 -RuOnly

# Roll back to the previous known-good delivered set
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p11c_tips_x150

# Restore the current release default
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12_tips_x150
```

`-RuOnly` is supported for every variant in the `switch_variant.ps1` set, including the
`_tips_x150` names. RU-only remains **NOT INSTALLED** in the current default.

## 7. Play-test guide

`reports/stack_test_guide.md` is written for a non-developer tester:

- How to reach the VEGA 9 archive scene and recognize the four English lines.
- Three passes: English baseline; Korean with p12; Korean with p12g.
- Checklist for concurrent lines, cut line, wrapping, disappearance timing, P-3 label,
  and English-only text.
- Copy-paste report template and severity table.
- Coordinator-only switch commands.

## 8. Reports and key files

| path | contents |
| --- | --- |
| `reports/p12_master.md` | CHANGE 1 / CHANGE 2 counts and before/after by scope |
| `reports/keep_original_questions.md` | ambiguous names left unchanged |
| `reports/p3_name_occurrences.md` | P-3 body occurrences and per-scope counts |
| `reports/p12_gate_all.md` | validator / coverage / glyph / audit summary for all six |
| `reports/p12g_caps.md` | H1/H2/H3 per-scope repairs |
| `reports/subtitle_stack_audit_p12.md` | baseline H1-H4 and 30 worst scenes |
| `reports/subtitle_stack_audit_p12g.md` | post-fix H1-H4; screenshot scene 0/4 H3 |
| `reports/subtitle_bottom_bar_p12.md` | layout evidence and arithmetic |
| `reports/stack_test_guide.md` | non-developer test guide |
| `reports/variant_test_matrix.md` | temp-install and forced-rollback matrix |
| `reports/install_verification.md` | final installed-set proof |
| `localization/working/tm_fixups_p12.tsv` | 125 cell rules + 1 P-3 label rule |
| `localization/working/keep_original.tsv` | 458 keep-original NAME rows |
| `build/variants/atomic-heart-ar_p12.tsv` | p12 master, 27,618 rows |
| `build/package/` | all p12-family paks, font, tips, RU-only |

The canonical master `localization/master/atomic-heart-ar.tsv` is untouched. `build/` is
untracked and the working tree is dirty; do not commit unless explicitly requested.

## 9. Known limitations / open items

- H1m (36 marker/key collisions), H1k (15 key collisions), and H4 (3 stock en-US/ru-RU
  collisions) are DataTable-level stock conditions; a locres-only pak cannot repair them.
  Only H1t text-marker starts are repaired.
- 197 non-monotonic H1 tracks were left byte-exact and are documented; they were not
  reordered.
- 343 H3 rows remain because no clip duration is available; they are listed in the p12g
  audit. Absolute DataTable row start offsets are unavailable, so cross-line H2/H3 uses
  clip/reading caps, not true next-line starts.
- 4,790 of 8,853 stock rows could not be joined to master locres keys; H1t/H2/H3 were
  assessed only where matched.
- p12g warnings (2,952) are mostly number-multiset changes from inserted timing markers;
  the validator reports 0 hard errors.
- The bottom-bar cut may persist if four lines are simultaneously visible; p12g reduces
  the duration but does not change the 150 px bottom layout. `UNKNOWN` exact clip owner.
- PowerShell 5.1 cannot carry Arabic or Cyrillic literals in `.ps1`; all non-ASCII text must
  come from UTF-8 data files. Keep that rule for future scripts.

## 10. STOP

This handoff is complete. The release default is installed and verified. All other new
variants are build-only and **NOT INSTALLED**. Do not install them without explicit
approval.

Dated copy: `handoff_2026-10-28_p12.md`.
