# HANDOFF - Atomic Heart Arabic localization - cycle 016 + P4

**Date:** 2026-10-24 16:30 (+03:00)
**State:** text passes complete, gates green, p11 + font v3 installed. **P4 DONE (builds + gates + docs), C6/C7 re-checked and still blocked. p11 untouched and still the default.**
**Rule for this file:** rewritten after every completed item, not only at cycle close.

---

## 1. Workstream status

| workstream | status | detail |
| --- | --- | --- |
| **P4.1 - tips / notifications** | **DONE (NOT INSTALLED)** | 20 timed tips x1.25 / x1.5 + item notification `WaitTime` 3.5 -> 4.375 / 5.25 s; read-back 42/42 |
| **P4.2 - subtitle hold** | **DONE (partial lever, NOT INSTALLED)** | p11c extends 632 explicit range ends (+0.3 s; long rows x1.15); singleton pages have no end field -> UNKNOWN |
| **P4.3 - gates** | **DONE** | validator PASS, glyph PASS, adapted audit 0 violations, carrier round-trip 35/35, all read-backs pass |
| **P4.4 - switch + guide** | **DONE** | `switch_variant.ps1` / `install_mod.ps1` / `reports/ab_test_guide.md` extended; dry-run verified |
| **A - subtitle timing (P1/P2)** | **DONE (analysis) / p11 default** | 537/537 markers byte-exact; p11b and p11c are experiments |
| **B - subtitle shimmer (P3)** | **DONE (font builds + install) / VERDICT PENDING** | v3 installed; v3b built as experiment C |
| **C1 - tone pass** | **DONE** | 125 rules / 212 rows / 25 scopes |
| **C2 - guillemet pass** | **DONE** | 103 rules / 146 rows |
| **C3 - glossary** | **DONE** | 7 fixes + accepted variants + 5 compound exceptions; **0 glossary warnings** |
| **C4 - 2,588 name-like values** | **DONE (reclassified)** | 2,519 already translated, 69 technical ids, 2 CHAR rows deliberate |
| **C5 - KI-028 `1 //` widget** | **BLOCKED** | widget-drawn, not in any data row; Phase 8 |
| **C6 - KI-018 RU-only assets** | **BLOCKED (re-checked 2026-10-24)** | 248 assets / 6,012 strings, no Arabic translations exist; needs an external RU->AR batch |
| **C7 - KI-013 14th culture** | **BLOCKED (re-checked 2026-10-24)** | 13 cultures live in an opaque cooked `Extras` blob; Phase 8 editor only |
| **C8 - final reports** | **DONE** | coverage, English-filled list, 30 longest UI labels, reference, 40-row sample |

---

## 2. P4 results

### 2.1 Tips / notifications - CONFIRMED sources

| source | field | value | verdict |
| --- | --- | --- | --- |
| 60 `DA_InputTipInfo` DataAssets (20 timed) | `DurationTime` + `bHasDuration` | 5 / 7 / 8 / 10 / 15 / 20 s | **CONFIRMED** |
| `WBP_ItemNotificationEntryWidget` | `WaitTime` | 3.5 s | **CONFIRMED** |
| `WBP_ItemsNotifiersWidget` | `MinDelayBetweenNotifications` | 0.5 s | **LIKELY** (queue spacing, not reading time) |
| `WBP_ShortHint` | `Delay` | 0.03 s | not display time (animation tick) |
| quest / new-place / recipe / deactivate banners | - | - | **UNKNOWN** (animation-driven, no scalar field) |

Full evidence: `reports/p4_timing_sources.md`, `build/p4/tip_durations.tsv`, `build/p4/ui_time_fields.tsv`.

### 2.2 Subtitles - partial lever

- Markers are **minutes** into the VO clip; `*t*` = page start, `*a-b*` = explicit range.
- All 8,853 `DT_Subtitles_*` rows have `Duration = 0`, so the last page of a singleton row ends with the audio.
- No min-hold / fade / hide-delay field exists in `BP_SubtitlesSubsystem`, `WBP_Subtitle`, `WBP_OneSubtitle` or `WBP_NPCSubtitle` (only `SubtitleSizeScale = 0.75` and layout floats). No subtitle settings DataAsset in the pak.
- 537 marker rows: **133 with ranges (683 ranges), 404 singleton-only**. p11c extends **632 range ends** (+0.3 s = 0.005 min; long rows >=100 visible chars also x1.15 span), capped strictly before the next page start; no end shrinks; starts byte-exact.
- Stock English source has a defect on the Academy key (`*0.10* ... *0.10*` duplicate); ru-RU carries the proper `*0.00-0.08* ... *0.09-0.25*` ranges.

Full evidence: `reports/p4_subtitle_investigation.md`, `reports/p11c_marker_hold.md`, `reports/p11c_audit.md`, `build/p4/subtitle_markers.tsv`, `build/p4/locres_src`.

---

## 3. Installed set (UNCHANGED - p11 remains the default)

| file | bytes | SHA256 |
| --- | --- | --- |
| `zzz_atomicheart-ar_carrier_koKR_p11_P.pak` | 4,472,812 | `0ffd9cb8b3ab5861007689c093c7f3bff761b7b245e5c56cbc5a20cf47def225` |
| `zzz_atomicheart-ar_font_p3_unhinted_P.pak` | 1,455,228 | `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4` |
| `atomic-heart-ar-install-manifest.json` | 1,556 | `c3fe0eba9115a4e7c5c5e8d53c6cb859afd0825c32fb63eb264ba3ef8066d1be` |

`~mods` has not been written in this P4 session (verified: same 3 files, same hashes, timestamps 2026-10-21). Nothing outside `Paks\~mods` was ever written.

**Rollback (restores p10 + Plex v2):**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p10
```

**Back to the current default (also removes any tips pak):**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11
```

---

## 4. Builds

| pak | bytes | SHA256 | state |
| --- | --- | --- | --- |
| `carrier_koKR_p11` | 4,472,812 | `0ffd9cb8b3ab5861007689c093c7f3bff761b7b245e5c56cbc5a20cf47def225` | **installed** |
| `font_p3_unhinted` (v3) | 1,455,228 | `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4` | **installed** |
| `carrier_koKR_p11b_retime` | 4,472,806 | `851c8bd66ec740d4337b8a6437937367a63effb0fd399ca1dc42b2291f78d63a` | experiment B |
| `font_p3b_linemetrics` (v3b) | 1,455,228 | `ed2659f1ebf29d51411e8ecc08a97c155e24c29b2007c917f66d5afe55d5fd94` | experiment C |
| `carrier_koKR_p10` | 4,473,788 | `7fbed3a87fafb547ecf4a2557a590ae0d7c05da304a3c7f6facb7bb34ef49393` | rollback |
| `carrier_koKR_p11c` | 4,474,004 | `cfb590e87e6e14e17a07e704d7d6065c5392ea98b70cf6702231746d3c4b8815` | **NOT INSTALLED** |
| `tips_x125` | 75,853 | `3f585026c33aafacab017f6be888dc362ab35874e5f184ee8f12819d4937b95b` | **NOT INSTALLED** |
| `tips_x150` | 75,853 | `36de01c37231a8b88ec9fc744c4f663bb8461a56adede9a6a2151d78c7ef7fcc` | **NOT INSTALLED** |

New paks live in `build/package/`; `switch_variant.ps1` finds them there.

---

## 5. Gates run (P4)

| gate | scope | result |
| --- | --- | --- |
| `validate_translation.ps1` | canonical master (p11) | **PASS**, 0 errors, 230 warnings (120 number / 110 UI / 0 glossary) |
| `glyph_gate.ps1 -MasterTsV p11c -AllowSourceInheritedNonLatin` | p11c variant | **PASS**, 0 newly required codepoints (37 source-inherited) |
| `subtitle_timing_audit.ps1` | canonical master | **537/537 identical**, 0 mismatches |
| `p4_subtitle_audit_p11c.ps1` | p11c variant | **0 violations**; 683 ranges, 624 ends extended, starts/type/order/text byte-identical |
| tips read-back | 42 edited values | **42/42** exact; property diff `same` everywhere else |
| carrier p11c round-trip | 35 locres | **35/35 byte-identical**; 27,618 keys, 26,022 Arabic, 1,596 English fill, 0 Korean, 0 fail |
| tips pak unpack | 42 entries each | **42/42 byte-identical** |

The stock subtitle audit intentionally does not "pass" p11c (it compares AR markers to EN byte-exact); the adapted audit is the gate for the intended end-only change.

---

## 6. Exact resume point

1. **P4 complete.** Optionally commit the P4 scripts, reports and tool change (explicit paths only; `build/` stays untracked).
2. **C6 / C7 are blocked by data, not by code:**
   - C6 (KI-018): 248 RU-only assets / 6,012 strings have no Arabic source; needs an external Russian->Arabic translation batch before anything can be built.
   - C7 (KI-013): the 13 culture names live in an opaque cooked `Extras` byte blob in `DA_Audio`; rewriting bytes is unsafe and can break audio settings.
3. Final step: refresh this HANDOFF, print its path/size/LastWriteTime, STOP.

---

## 7. Blocked items (evidence: `reports/blocked_items.md`)

- **KI-028** - the `1 //` prefix is not in any localized row; 19 `//` rows are broadcast headers; the widget composes the number LTR.
- **KI-013** - UAssetAPI parses `DA_Audio` but the cultures live in the export's opaque `Extras` byte blob (13 cultures, count `0x4E`, FName indices + FStrings), not in named properties. Interim: ko-KR carrier. *Re-checked 2026-10-24: asset unchanged (2,765 B), no schema, no safe data-only path.*
- **KI-018** - 248 RU-only assets / 6,012 strings (4,790 subtitle keys with no master row); no Arabic translations exist. *Re-checked 2026-10-24: `reports/dialogue_ru_only.md` still reports 248 / 6,012; blocked on translation supply, not tooling.*
- **C4** - reclassified, no work: 2,519 of 2,588 values already translated, 69 technical ids kept Latin, 2 CHAR rows deliberate.
- **Font/widget** - UMG Size=35 hard-coded; Cyrillic/Hangul absent from Plex (37 source-inherited, 0 newly required Arabic); `NotLifted_17` obfuscated (KI-017).
- **P4 subtitle hold** - no data-side min-hold/fade/hide-delay setting; singleton-only pages inherit the VO end. p11c covers explicit range ends only.

---

## 8. Safety state

- P4 wrote only under `build/`, `reports/`, `scripts/`, `tools/src/` and `HANDOFF*.md`.
- No `~mods` write, no install, no switch, no EXE/DLL/Steam/Denovo change, no signature bypass, nothing uploaded, no raw game assets committed.
- `build/` is untracked; commit only explicit paths.
- Spec hash: `MASTER_PROMPT.md` = `579F581E5BB8CAAE2AFF6EF60326F1F461688F1B1392391A56A97A6148A61C35`.
- Local commits before P4: `142fe19`, `7b36514`, `7a92fac`, `10f9f44`, `2bcc311`.

---

## 9. Tooling added in P4

- `tools/src/uasettool/Program.cs`: new `setfloat` / `setbool` / `setint` modes (walk property tree, set value, `asset.Write`). Fixed an enum-parse bug where a numeric value (e.g. `10`) was mistaken for an `EngineVersion`.
- `scripts/p4_extract_ui_assets.ps1`, `p4_dump_tip_durations.ps1`, `p4_scan_ui_time_fields.ps1`, `p4_scan_subsys_time_fields.ps1`, `p4_analyze_subtitle_markers.ps1`, `p4_extract_locres.ps1`, `p4_extract_cultures.ps1` - read-only evidence.
- `scripts/p4_build_tips_variants.ps1` - builds both tips paks with read-back + unpack verification.
- `scripts/make_p11c_marker_variant.ps1` - p11c master.
- `scripts/p4_subtitle_audit_p11c.ps1` - adapted gate.

---

## 10. Key paths

```
HANDOFF.md                                  this file (rewritten per item)
localization/master/atomic-heart-ar.tsv     master (27,618 x 13)
build/variants/atomic-heart-ar_p11c.tsv     p11c variant master
build/package/zzz_atomicheart-ar_carrier_koKR_p11c_P.pak
build/package/zzz_atomicheart-ar_tips_x125_P.pak
build/package/zzz_atomicheart-ar_tips_x150_P.pak
reports/p4_timing_sources.md                tips/notification source evidence
reports/p4_subtitle_investigation.md        marker semantics + no-hold evidence
reports/p11c_marker_hold.md                 p11c build stats
reports/p11c_audit.md                       adapted gate (0 violations)
reports/ab_test_guide.md                    A/B/C + P4 one-line table
reports/blocked_items.md                    KI-028 / KI-013 / KI-018 evidence
reports/subtitle_timing_audit.md            537 markers, 0 mismatches
reports/translation_validation.md           PASS, 230 warnings
reports/glyph_gate.md                       PASS, 0 newly required
scripts/switch_variant.ps1                  p11/p11b/p11c/tips variants + rollback
scripts/install_mod.ps1                     exact-set install + manifest
build/p4/tip_durations.tsv                  60 tips: bHasDuration + DurationTime
build/p4/ui_time_fields.tsv                 widget float time fields
build/p4/subtitle_markers.tsv               marker census (539 rows)
build/p4/locres_src                         culture marker proof
build/p4/tips_src / ui_src                  original assets + JSON dumps
```

---

## 11. Closing state (2026-10-24)

- P4.1 / P4.2 / P4.3 / P4.4 are complete. Three new paks are built, hash-recorded and
  **NOT INSTALLED**: `p11c`, `tips_x125`, `tips_x150`.
- The installed set is still p11 + font v3; `~mods` has exactly the same three files and
  hashes as before this session.
- To test, close the game, run one command from `reports/ab_test_guide.md` (for example
  `-Variant p11c_tips_x150`), and roll back with `-Variant p11`.
- C6 and C7 were re-checked against their evidence and remain blocked by missing Arabic
  source (C6) and by the opaque `DA_Audio` culture blob (C7). No unsafe byte surgery and
  no fabricated translations were attempted.
- Final action performed: this file rewritten, path/size/LastWriteTime printed, STOP.

