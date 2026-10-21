# HANDOFF - Atomic Heart Arabic localization - cycle 016

**Date:** 2026-10-21 14:12 (+03:00)
**State:** all text passes applied, all gates green, p11 + font v3 rebuilt and installed.
**Rule for this file:** rewritten after every completed item, not only at cycle close.

---

## 1. Workstream status

| workstream | status | detail |
| --- | --- | --- |
| **A - subtitle timing (P1/P2)** | **DONE (analysis + builds) / VERDICT PENDING** | mechanism proven from data; 537/537 markers byte-exact; p11 default + p11b experiment built |
| **B - subtitle shimmer (P3)** | **DONE (font builds + install) / VERDICT PENDING** | v3 (hinting removed) installed; v3b (1.20 em line box) built as experiment C |
| **C1 - tone pass** | **DONE** | 125 rules / 212 rows / 25 scopes; target 150 exceeded |
| **C2 - guillemet pass** | **DONE** | 103 rules / 146 rows; 74 tag-only rows skipped |
| **C3 - glossary** | **DONE** | 7 fixes + accepted-variant entries + 5 compound exceptions; **0 glossary warnings** |
| **C4 - 2,588 name-like values** | **DONE (reclassified)** | 2,519 already translated, 69 technical ids, 2 CHAR rows deliberate; no DLC4 defect |
| **C5 - KI-028 `1 //` widget** | **BLOCKED** | widget-drawn, not in any data row; Phase 8 |
| **C6 - KI-018 RU-only assets** | **BLOCKED** | 248 assets / 6,012 strings, no Arabic translations yet |
| **C7 - KI-013 14th culture** | **BLOCKED** | 13 cultures live in an opaque cooked `Extras` blob |
| **C8 - final reports** | **DONE** | coverage, English-filled list, 30 longest UI labels, reference, 40-row sample |
| **Warning audit** | **DONE (number) / RUNNING (UI length)** | 122 number warnings audited: 0 defects; 112 UI-length warnings next |

---

## 2. Installed set (verified live, `VERIFY INSTALL PASS: problems 0`)

| file | bytes | SHA256 |
| --- | --- | --- |
| `zzz_atomicheart-ar_carrier_koKR_p11_P.pak` | 4,472,886 | `567126733d5435ce55964c050d57b5372bfb8b73c7a3e22ca27b2120fecc31af` |
| `zzz_atomicheart-ar_font_p3_unhinted_P.pak` | 1,455,228 | `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4` |
| `atomic-heart-ar-install-manifest.json` | 1,556 | `75cbef143e17437774bfc81aa5e3a794e152c6b85f60153120d0a5f59c6b107e` |

Before-snapshot: `build/snapshots/before_p11_20261021_141216.json`.
Install proof: `reports/install_verification.md`. Nothing outside `Paks\~mods` was written.

**Rollback (restores p10 + Plex v2):**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p10
```

**Switch variants (one command each):**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11      # default (installed)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11b     # timing x1.15
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11_3b   # line metrics
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11b3b   # both experiments
```

---

## 3. Builds (all rebuilt from the current master)

| pak | bytes | SHA256 | state |
| --- | --- | --- | --- |
| `carrier_koKR_p11` | 4,472,886 | `567126733d5435ce55964c050d57b5372bfb8b73c7a3e22ca27b2120fecc31af` | **installed** |
| `font_p3_unhinted` (v3) | 1,455,228 | `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4` | **installed** |
| `carrier_koKR_p11b_retime` | 4,472,880 | `e293f9d366be87bbe6743b8516de2695ce4cc06d9825372a28f67da6c5d7f3a0` | experiment B |
| `font_p3b_linemetrics` (v3b) | 1,455,228 | `ed2659f1ebf29d51411e8ecc08a97c155e24c29b2007c917f66d5afe55d5fd94` | experiment C |
| `carrier_koKR_p10` | 4,473,788 | `7fbed3a87fafb547ecf4a2557a590ae0d7c05da304a3c7f6facb7bb34ef49393` | rollback |

---

## 4. Text state and gates (current master)

- Master: 27,618 rows x 13; Arabic = column 6. 278 rows changed vs the cycle-015 commit.
- Rules: `localization/working/tm_fixups.tsv` (297 lines); cycle-016 rules are cell-scoped
  (`[exact]`) so short finds cannot bleed into unrelated rows.
- `verify_text_fixups.ps1` **PASS** | `validate_translation.ps1` **PASS** (0 hard errors,
  **234 warnings**: 122 number / 112 UI length / **0 glossary**, 5 compound exceptions) |
  `glyph_gate.ps1` **PASS** (`-AllowSourceInheritedNonLatin`: 37 source-inherited, **0
  introduced by Arabic**) | `subtitle_timing_audit.ps1` **0 mismatches** (537/537).
- Coverage: 26,022 / 26,022 translatable = **100%**; 1,596 copy-class English-filled;
  0 rows needing review (`reports/coverage_cycle016.md`).

### Completed this session
- Number-warning audit: 122/122 reviewed, **0 real losses** (`reports/number_warnings_audit.md`,
  `reports/number_warnings_review.tsv`). One grammar fix in 6 tooltip rows.
- Glossary warnings: **26 -> 0** via accepted renderings (Major, Terminal, Upgrade, Snowball,
  Neuropolymer, Phasotron, Argentum, Archive, Comrade, Professor, Doctor) plus
  `glossary/glossary_exceptions.tsv` (Major League / Major depression / Sergeant Major /
  terminal branch).
- Quality fixes: restored 2 dropped vocatives (`Major!`), Comrade consistency
  (`زميل` -> `رفيق`) in 2 rows, restored a condensed sentence in `L7831`.
- p11 rebuilt (4,472,886 B) and reinstalled + verified; p11b rebuilt from the same master.

---

## 5. P1 / P2 / P3 - evidence in hand

- **P1/P2:** all 8,853 `DT_Subtitles_*` rows carry a VO `Marker`, `Duration=0`,
  `Priority=0` -> lifetime is native/audio-driven, not text-length-driven. 537/537 master
  subtitle rows keep the English marker multiset **and order byte-exact**; 0 value/order
  mismatches. Official cultures do retime/drop markers (de-DE 221, ko-KR 207), but values
  average ~1.0, so English markers are the safe default. p11b (all cues x1.15) is the
  controlled experiment for "too early/fast".
- **P3:** original faces are CFF, no `fpgm`/`prep`, `head.flags=0x0003`, line box 1.20 em.
  Plex v2 was TTF with `fpgm`+`prep`, flags `0x0009`, line box 1.50 em. v3 removes the hint
  program and clears the flags; v3b also restores the 1.20 em metrics. Both keep Latin 95/95
  and Arabic 42/42.
- Verdict needs the in-game pass in `reports/ab_test_guide.md` (A/B/C + rollback).

---

## 6. Resume point (exact)

1. **NOW RUNNING - UI-length warning review.** 112 warnings (Arabic longer than English);
   export them like the number audit, classify (buttons/menus vs lore/subtitles), shorten
   only fixed-widget labels where meaning survives. Report as
   `reports/ui_length_audit.md`.
2. Apply any fixes -> `apply_text_fixups.ps1` -> `verify_text_fixups.ps1` -> rebuild p11 ->
   reinstall -> update this file with the new hashes.
3. **In-game A/B verdict** (user-run): A = p11 + v3 (installed), B = p11b, C = p11_3b.
   Then either keep this set or promote p11b / v3b.
4. **Phase 8 only** (cannot be done data-side): KI-028 choice widget RTL, KI-013 DA_Audio
   14th culture, KI-018 Russian-only assets.

---

## 7. Blocked items (evidence: `reports/blocked_items.md`)

- **KI-028** - the `1 //` prefix is not in any localized row; 19 `//` rows are broadcast
  headers; the choices are plain strings and the widget composes the number LTR.
- **KI-013** - UAssetAPI parses `DA_Audio` (VER_UE4_27, 1 export), but the 13 cultures live in
  the export's opaque `Extras` byte blob (count `0x4E`, FName indices + FStrings
  `English(US)`/`en-US` ... `uk-UA`), not in named properties; a wrong byte breaks the audio
  settings. Interim: ko-KR carrier.
- **KI-018** - 248 RU-only assets / 6,012 strings (4,790 subtitle keys with no master row);
  no Arabic translations exist; needs a Russian->Arabic batch.
- **C4** - reclassified, no work: 2,519 of the 2,588 values are already translated, 69 are
  technical ids kept Latin, 2 CHAR rows are deliberate Latin reveals.
- **Font/widget** - UMG Size=35 is hard-coded; Cyrillic/Hangul absent from Plex (37
  source-inherited codepoints, 0 newly required Arabic); `NotLifted_17` obfuscated (KI-017).

---

## 8. Safety state

Only `Paks\~mods` was written. No EXE/DLL/Steam/Deno breakage, no signature bypass, nothing
uploaded, no raw game assets committed. Spec hash at cycle start:
`MASTER_PROMPT.md` = `579F581E5BB8CAAE2AFF6EF60326F1F461688F1B1392391A56A97A6148A61C35`.
Local commits: `142fe19` (cycle 016), `7b36514` (gitignore hygiene).

---

## 9. Key paths

```
HANDOFF.md                                  this file (rewritten per item)
localization/master/atomic-heart-ar.tsv     master (27,618 x 13)
localization/working/tm_fixups.tsv          297 rules ([exact] = cell-scoped)
glossary/glossary.tsv                       accepted renderings (variants after '|')
glossary/glossary_exceptions.tsv            compound-sense exceptions (data-driven)
reports/ab_test_guide.md                    A/B/C commands + scene + report sheet
reports/blocked_items.md                    KI-028 / KI-013 / KI-018 / C4 evidence
reports/font_ab_evidence.md                 original vs Plex v2 vs v3/v3b
reports/subtitle_timing_audit.md            537 markers, 0 mismatches
reports/number_warnings_audit.md            122 warnings, 0 defects, classification
reports/coverage_cycle016.md                coverage by scope and category
reports/english_filled_rows.tsv             1,596 copy-class rows
reports/ui_longest_labels.md                top 30 UI labels by length
reports/tone_pass.md                        212 tone rows, before/after
scripts/switch_variant.ps1                  switch + snapshot + verify + rollback
scripts/cycle016_reports.ps1                regenerate coverage / English list / UI labels
```
