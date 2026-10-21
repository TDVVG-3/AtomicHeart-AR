# HANDOFF - Atomic Heart Arabic localization - cycle 016

**Date:** 2026-10-21 13:00 (+03:00)
**Status:** p11 (text passes) + font v3 installed and verified. Timing/font A/B builds ready.
**Entry point:** this file. Everything below is reproducible from the repo; nothing else is needed.

---

## 1. Read this first

The game folder contains **exactly** these three files in `Paks\~mods` (verified):

| file | bytes | SHA256 |
| --- | --- | --- |
| `zzz_atomicheart-ar_carrier_koKR_p11_P.pak` | 4,472,842 | `94fc9d4a8ef1ae676a9da440dd131a1419557058b9f122a2b55413e8c618e1f7` |
| `zzz_atomicheart-ar_font_p3_unhinted_P.pak` | 1,455,228 | `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4` |
| `atomic-heart-ar-install-manifest.json` | 1,556 | `9e98e085755dbd55ed4b9331f77b7c0071a9bc060948434f9681102c550f6d26` |

- Install proof: `reports/install_verification.md` -> `VERIFY INSTALL PASS: problems 0`.
- Before-snapshot of that install: `build/snapshots/before_p11_20261021_125919.json`.
- Nothing outside `Paks\~mods` was written. No EXE/DLL/Steam/Denuvo file was touched.

**Rollback (one command, restores the last delivered set p10 + Plex v2):**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p10
```

**Switch back to the current default:**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11
```

Every switch takes a read-only before-snapshot, verifies the SHA256 of what it removes,
installs only inside `~mods`, and ends with `VERIFY INSTALL PASS`.

---

## 2. P1 / P2 / P3 status

| problem | status | evidence level |
| --- | --- | --- |
| **P1** subtitles early / too fast | **not reproduced in data; in-game verdict pending** | Data-proven mechanism + A/B build ready |
| **P2** previous subtitle lingers | **not reproduced in data; in-game verdict pending** | Data-proven mechanism + A/B build ready |
| **P3** shimmer while the camera moves | **font cause removed (v3); in-game verdict pending** | Font tables measured; v3 shipped |

**P1/P2 - what the data proves (Workstream A).**

- All 8,853 `DT_Subtitles_*` rows carry a VO `Marker` and `Duration=0`, `Priority=0`; the
  subtitle lifetime is native and audio-driven, not text-length-driven.
- 4,062 of 4,063 DataTable keys resolve to identical Russian text in the ru-RU locres.
- **537 of 537** subtitle marker rows in the master keep the English marker multiset **and
  order byte-exact**; 0 missing, 0 extra, 0 value changes, 0 order changes, 0 balance outliers.
  (`scripts/subtitle_timing_audit.ps1` -> `reports/subtitle_timing_audit.md`.)
- Official localizations sometimes retime/drop markers per culture (de-DE 221 retimed,
  ko-KR 207 dropped), but the marker values average ~1.0 versus English. Keeping the English
  markers byte-exact is therefore the safest default.
- Conclusion: P1/P2 are **not** marker loss, key misalignment or content shift. They are
  either engine-side cue timing or a perception effect of the longer English timing; p11b is
  the controlled experiment that tells us which.

**P3 - what was changed (Workstream B).**

- The original faces are CFF/OTF with **no** `fpgm`/`prep`, `head.flags=0x0003`, line box
  **1.20 em**. The old Plex v2 payload was TrueType with `fpgm`+`prep`, `head.flags=0x0009`,
  line box **1.50 em** - two plausible shimmer causes.
- **v3** removes `fpgm`+`prep` and clears the force-ppem bits (`0x0009 -> 0x0003`), keeping
  every glyph and metric. **v3b** additionally restores the original vertical metrics
  (1.20 em). Both keep Latin 95/95 and Arabic 42/42 coverage.
- v3 is installed now. v3b is the experiment (variant C).

**In-game verdict is the only missing piece.** The guide and the exact commands are in
`reports/ab_test_guide.md` (3 combinations A/B/C + rollback).

---

## 3. What changed this cycle

**Master:** 267 rows changed versus the cycle-015 committed master, in three passes plus one
content fix. Every change is a rule in `localization/working/tm_fixups.tsv` and is proven by
`scripts/verify_text_fixups.ps1` (**PASS**, 85 rules checked, 0 tm mismatches).

| pass | rules | rows | report |
| --- | --- | --- | --- |
| C1 tone pass (spoken register) - cycles 013+016 | 125 | 212 | `reports/tone_pass.md` |
| C2 quote pass (ASCII `"` -> Arabic guillemets, tag-safe) | 103 | 146 | `reports/text_fixups_log.md` |
| C3 glossary (Upgrade noun/verb, EN anchor, brackets, `<- ... ->` Latin) | 7 | 7 | `reports/glossary_anchor_issues.tsv` |
| C3b content fix (`dire straits` -> a serious predicament) | 1 | 1 | `reports/text_fixups_log.md` |

Tone pass detail: `بالتأكيد -> أكيد`, `هل يمكنك -> ممكن`, `أودّ أن -> أريد أن`,
`أرغب في -> أريد`, plus 24 hand-targeted lines - applied **only** to
Dialogue/Cutscene/Subtitles rows, never to letters, lore or UI.

All cycle-016 rules are **cell-scoped** (`[exact]` in the note): a short rule can no longer
bleed into an unrelated long row. This was found and fixed during the pass (a 9-character
`بالتأكيد` rule had touched two lore letters; the master was reverted to HEAD and every rule
reapplied with `[exact]`, so the two letters keep their formal wording).

Glossary result: 1,025 CHAR-les/Charles rows audited, 1,023 use the glossary render
`تشارلز|CHAR-les`; the 2 exceptions are intentional Latin reveals of the acronym. The single
`<- ALCOHOL ->` row keeps its Latin. 51 bracket-label rows follow DEC-039 (count matches;
translated labels accepted).

---

## 4. Builds

| pak | bytes | SHA256 | state |
| --- | --- | --- | --- |
| `carrier_koKR_p11` | 4,472,842 | `94fc9d4a8ef1ae676a9da440dd131a1419557058b9f122a2b55413e8c618e1f7` | **installed** |
| `font_p3_unhinted` (v3) | 1,455,228 | `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4` | **installed** |
| `carrier_koKR_p11b_retime` | 4,472,836 | `2abc4ddcda886547592b785be09b210dffcf5e45ff7c7275031bd3469130fb23` | experiment B |
| `font_p3b_linemetrics` (v3b) | 1,455,228 | `ed2659f1ebf29d51411e8ecc08a97c155e24c29b2007c917f66d5afe55d5fd94` | experiment C |
| `carrier_koKR_p10` (rollback) | 4,473,788 | `7fbed3a87fafb547ecf4a2557a590ae0d7c05da304a3c7f6facb7bb34ef49393` | last known-good |

p11: 35 locres entries, 27,618 keys (26,022 Arabic / 1,596 English-filled), 27,617 byte-exact
+ 1 newline-only, 0 failures, 35/35 round-trip.
p11b: same, with every one of the 537 subtitle cue numbers multiplied by 1.15
(`reports/p11b_marker_retime.md`).
Font paks: 6 entries each, round-trip byte-identical, coverage gate passed.

---

## 5. Workstream C status

| item | status | artifact |
| --- | --- | --- |
| C1 tone pass to 150 rows | **DONE** - 125 rules / 212 rows (target exceeded) | `reports/tone_pass.md` |
| C2 guillemet pass on 220 straight-quote rows | **DONE** - 146 converted, 74 tag-only skipped, 103 rules | `reports/text_fixups_log.md` |
| C3 glossary (Upgrade, EN anchor, brackets, `<- ... ->`) | **DONE** - 7 fixes; audit 139 rows | `reports/glossary_anchor_audit.tsv`, `glossary_anchor_issues.tsv` |
| C4 curate 2,588 name-like values + 2 DLC4 CHAR-les | **RECLASSIFIED, no work needed** - 2,519 already translated, 69 technical ids kept, 2 CHAR rows are deliberate Latin; 0 DLC4 defects | `reports/blocked_items.md` sec. 4, `charles_rows.tsv` |
| C5 KI-028 `1 //` choice widget | **BLOCKED** - not in data (widget-drawn); Phase 8 | `reports/blocked_items.md` sec. 1 |
| C6 KI-018 248 RU-only assets / 6,012 strings | **BLOCKED** - no Arabic translations exist; translator capacity | `reports/blocked_items.md` sec. 3 |
| C7 KI-013 14th culture in DA_Audio | **BLOCKED** - cultures live in an opaque cooked `Extras` blob; unsafe to rewrite without schema | `reports/blocked_items.md` sec. 2 |
| C8 final reports | **DONE** | `reports/coverage_cycle016.md`, `english_filled_rows.tsv`, `ui_longest_labels.md`, `localization/references/AR_EN_REFERENCE.md`, `reports/review_sample.md` |

Coverage (`reports/coverage_cycle016.md`):

- 27,618 master rows; 26,022 with Arabic; 1,596 copy-class (English-filled by design).
- 26,022 translatable rows; **26,022 translated = 100.0%**; 0 rows needing review.
- 35 scopes, 13 categories; reference regenerated (26,022 rows, 19,732 unique English).
- 30 longest UI labels listed in `reports/ui_longest_labels.md` for the in-game clipping pass.

Gates on the shipped master: `validate_translation.ps1` **PASS** (0 hard errors; 260 warnings
= number multisets, UI length watch, glossary watch), `glyph_gate.ps1` **PASS** with the
documented `-AllowSourceInheritedNonLatin` exemption (37 source-inherited codepoints, **0
newly required Arabic**), `subtitle_timing_audit.ps1` **0 mismatches**.

---

## 6. In-game test checklist (no developer tools needed)

Follow `reports/ab_test_guide.md` for the A/B/C commands and the recording sheet. Short form:

1. **Close the game**, run the switch command for the run you want, start the game.
2. **Opening cutscene** (long Sechenov/Chelomey speech): watch 4-5 subtitle pages.
   Note: does a page disappear *before the voice finishes* (P1)? Does the previous page stay
   *after the voice moved on* (P2)?
3. **Canal boat dialogue**: check the choice widget (`1 //` + Arabic) and the NPC subtitle.
4. **One open-world NPC**: walk up to a talking NPC and watch a world-space subtitle.
5. **NORA upgrade menu**: the longest labels (`reports/ui_longest_labels.md`); check clipping,
   line spacing and subtitle size.
6. **Camera sweep** during a subtitle: does the text shimmer/ripple (P3)?
7. Repeat for A (p11 + v3), B (p11b), C (p11_3b). Report per run; "same as before" is useful.
8. **Rollback** at any time: `scripts\switch_variant.ps1 -Variant p10`.

Known and accepted: the Japanese quote in one DLC4 mail and Cyrillic letters inside Latin
weapon ids (`АK47`, `VOV-А6`, `КS-23`) cannot render with the Plex faces; they are inherited
from the English source, the original font has the same gap for the CJK quote, and the glyph
gate reports **0 newly required Arabic codepoints**.

---

## 7. Blocked list (with evidence)

`reports/blocked_items.md`:

1. **KI-028** `1 //` choice widget - widget-drawn, no data-side lever (DEC-032, Phase 8).
2. **KI-013** 14th culture in `DA_Audio` - 13 cultures live in an opaque cooked `Extras`
   byte blob (FName indices + FStrings, custom layout), not in named properties; rewriting it
   risks the audio settings asset. Interim: ko-KR carrier. Phase 8 only.
3. **KI-018** 248 Russian-only assets / 6,012 strings - no English source, no Arabic
   translations; a Russian->Arabic translation batch, not a tooling task.
4. **C4 residual** - reclassified: the 2,588 values are UI/lore strings, 2,519 already
   translated, 69 technical ids kept, 2 CHAR rows are deliberate; no DLC4 defect.

Also documented there: the UMG Size=35 subtitle font cannot be changed data-side (KI-017
`NotLifted_17` obfuscated, skipped), and the Cyrillic/Hangul limits above.

---

## 8. Where everything lives

```
localization/master/atomic-heart-ar.tsv        27,618 x 13 master (Arabic = col 6)
localization/working/tm_fixups.tsv             292 rules (all passes; [exact] = cell-scoped)
localization/working/tm.tsv                    translation memory
reports/ab_test_guide.md                       A/B instructions + commands + what to report
reports/font_ab_evidence.md                    original vs Plex v2 vs v3/v3b, measured
reports/subtitle_timing_audit.md               537 marker rows, 0 mismatches
reports/p11b_marker_retime.md                  exactly what p11b changes
reports/tone_pass.md                           before/after for all 212 tone rows
reports/coverage_cycle016.md                   coverage by scope and category
reports/english_filled_rows.tsv                the 1,596 copy-class rows
reports/ui_longest_labels.md                   top 30 UI labels by length
reports/blocked_items.md                       this cycle's blocked/reclassified items
reports/install_verification.md                current install proof
reports/history/                               per-cycle reports (016 here)
scripts/switch_variant.ps1                     one-command variant switch + verify + rollback
scripts/cycle016_reports.ps1                   regenerates coverage / English list / UI labels
scripts/make_p11b_marker_variant.ps1           regenerates the p11b master
scripts/subtitle_timing_audit.ps1              marker gate (runs in the gate chain)
source/original/uasset/settings_da/            DA_Audio + dump (KI-013 evidence)
```

Safety/standing rules honoured: only `Paks\~mods` was written; no EXE/DLL/Steam/Denuvo
change; no signature bypass; nothing uploaded; no raw game assets committed; spec hash checked
(`MASTER_PROMPT.md` = `579F581E5BB8CAAE2AFF6EF60326F1F461688F1B1392391A56A97A6148A61C35`).

---

## 9. Resume point

1. **In-game A/B verdict** (the only open question for P1/P2/P3): run A/B/C per
   `reports/ab_test_guide.md`, then either keep p11 + v3 or promote p11b / v3b as the default
   (one `switch_variant.ps1` call each way).
2. If the verdict changes the default: rebuild nothing (the paks are already built), just
   switch and update the installed-set hashes in this file and `reports/install_verification.md`.
3. **Phase 8 work** (needs a widget/asset pipeline): KI-028 choice-widget RTL, KI-013 14th
   culture + `ar` locres/locmeta, KI-018 Russian-only asset translation.
4. If more text passes are wanted: add rules to `tm_fixups.tsv`, run
   `apply_text_fixups.ps1` -> `verify_text_fixups.ps1` -> rebuild carrier -> reinstall.
   Do **not** re-run the old substring rules on a changed master; use `[exact]` rules.
