# Blocked items - cycle 016 (2026-10-21)

Status values: **BLOCKED** = cannot be completed with data-only changes / current tooling;
**RECLASSIFIED** = investigated, the original description was wrong, no work is needed.

Every item below has a file-level evidence trail. Nothing here is a guess.

---

## 1. KI-028 - the `1 //` choice widget - BLOCKED (widget, Phase 8)

**Symptom.** In dialogue choices the number+separator (`1 //`, `2 //`, ...) is drawn on the
left of the Arabic choice text instead of following the RTL flow.

**Why it is not data-only.** The prefix is not in any localized row:

- 0 master rows contain the choice number + `//` pattern in the Arabic column.
- The 19 rows that do contain `//` are broadcast/contents headers (`// LIVE BROADCAST`,
  `// CONTENTS`), not choices.
- The choices themselves are plain Arabic strings; the number/separator is composed by the
  UMG choice widget at runtime, which lays its horizontal box out LTR.

**Evidence.**
- `localization/master/atomic-heart-ar.tsv` (search `//`: 19 rows, all headers).
- `DECISIONS.md` DEC-032 (choice widget layout deferred to Phase 8; no data-side lever).
- `KNOWN_ISSUES.md` KI-028.

**Next step (Phase 8).** Either (a) set the choice text block's flow direction / wrapping to
RTL in the widget, or (b) move the number into the localized string and let the widget render
it, or (c) use a full-row RTL text block with the separator inside the FText. All three are
UMG edits; none can be shipped as a locres/pak override.

---

## 2. KI-013 - 14th culture entry in DA_Audio - BLOCKED (opaque cooked struct)

**Goal.** Add `ar-SA` to the in-game Options language list (13 cultures today) and ship the
`ar` locres/locmeta so the game can select Arabic natively instead of the ko-KR carrier.

**What the asset actually contains.**

- `UAssetAPI 1.1.0` parses `source/original/uasset/settings_da/DA_Audio.uasset`
  (`VER_UE4_27`, 1 export, `DA_Audio`). The dump is at
  `source/original/uasset/settings_da/DA_Audio.uasset.json`.
- The named properties are **audio settings** (`GameSetting` array: volumes, voice bus,
  etc.). The 13-culture list is **not** a named property.
- The culture list lives in the export's opaque `Extras` byte blob. Decoded, it is:
  `4E 00 00 00` (record/count area) followed by records built from FName indices and
  FStrings - `English(US)`/`en-US`, `Russian`/`ru-RU`, `French(FR)`/`fr-FR`,
  `Italian(IT)`/`it-IT`, `German(DE)`/`de-DE`, `Spanish(ES)`/`es-ES`,
  `Portuguese(BR)`/`pt-BR`, `Polish(PL)`/`pl-PL`, `Chinese(CN)`/`zh-CN` + `zh-hans`,
  `English(US)`/`zh-TW` + `zh-hant`, `English(US)`/`ko-KR`, `English(US)`/`ja-JP`,
  `English(US)`/`uk-UA`.
- There is no published schema for this custom `Extras` layout. Adding a 14th record means
  reconstructing the struct, inserting two FStrings, fixing the record/count area and any
  offsets, and re-serializing the same asset that also holds the audio settings.

**Why it is blocked.** A wrong byte in `DA_Audio` breaks the Options menu (audio settings),
not just the language list. We cannot validate the result in-game without a build, and the
asset is shared. The standing rule is "data-only pak overrides or nothing".

**Interim already shipped.** The ko-KR carrier pak makes the game run our Arabic locres
through the Korean culture slot; that is why the mod works today without a 14th entry.

**Evidence.** `source/original/uasset/settings_da/DA_Audio.uasset` + `.uasset.json`,
`docs/LANGUAGE_SELECTION.md`, `KNOWN_ISSUES.md` KI-013, `DECISIONS.md` (language route).

**Re-check 2026-10-24 (C7):** evidence unchanged - the asset is still 2,765 bytes, the
culture list still lives only in the opaque `Extras` blob, and there is still no schema.
No safe data-only path exists; this remains a Phase 8 editor task.

**Next step (Phase 8).** Build a dedicated DA_Audio editor with the decoded layout, write
`ar-SA` (and `ar` locres/locmeta), re-open the asset with UAssetAPI, diff every other byte,
and ship as a **separate optional pak** - never in the default set - then test on a copy of
the save/settings.

---

## 3. KI-018 - 248 Russian-only assets / 6,012 strings - BLOCKED (translation capacity)

**What.** All non-locres cooked dialogue assets are Russian-only: 248 assets, 6,012 strings,
including the complete `DT_Subtitles_*` family (DLC1-4 and base game). They carry no English
source anywhere; 4,790 of those subtitle keys have no master row.

**Why it is blocked.** There are no Arabic translations for these strings and no English
source to translate from. The asset text is Russian; a Russian -> Arabic pass needs a
translator (or a reviewed MT pipeline) and a Russian term base. This is not a tooling gap.

**Evidence.** `reports/dialogue_ru_only.md`, `KNOWN_ISSUES.md` KI-018, `DECISIONS.md`
(DEC-019 string selection: RU-only assets are tracked separately and excluded from the
English source column).

**Re-check 2026-10-24 (C6):** `reports/dialogue_ru_only.md` still reports **248 assets /
6,012 strings**; no Arabic translation batch exists for them and there is no English
source. C6 stays blocked until a reviewed Russian->Arabic pass is available.

**Next step.** Batch the strings through the existing chunk pipeline with Russian as the
source column, in ~300-string chunks, with the same gates. Until then the game falls back to
the Russian text for these assets, which is the original behaviour.

---

## 4. C4 residual - 2,588 "name-like" values - RECLASSIFIED (no work needed)

**Original description.** 2,588 single-occurrence name-like values "not yet curated", plus
"2 DLC4 CHAR-les rows".

**What the audit found.**

- The 2,588 values are **not speaker names**. They are UI/lore/achievement/terminal strings
  (`A bad hunch`, `Ability 1`, `ACCEPT`, `A TRAIN TO SOLNECHNAYA`, ...). The inventory in
  `localization/working/labels/label_candidates.tsv` was built for speaker labels and
  mis-classified them.
- 2,519 of the 2,588 are **already translated** in the master. Spot checks:
  `A bad hunch` -> `حدس سيئ`, `Ability 1` -> `المهارة 1`, `ACCEPT` -> `قبول`,
  `A TRAIN TO SOLNECHNAYA` -> `قطار إلى سولنيتشنايا`.
- The remaining 69 are technical ids/names deliberately kept Latin (copy-class):
  `AK`, `All`, `CanBuy`, `CarsStage`, `DX11`, `DUMMY Y`, `HAWK 01`-`HAWK 08`, ...
- CHAR-les audit: 1,025 rows mention CHAR-les/Charles/CHARLES; **1,023 carry the glossary
  render** (`تشارلز|CHAR-les`). The two exceptions are in `Academy_Dialogues` and are
  **intentional Latin reveals** of the acronym itself (`"CHARLES"` / `CHAR-LES` in the
  dialogue), not mistranslations. **No DLC4 CHAR-les defect exists.**

**Evidence.** `reports/label_single_sample.txt`, `reports/label_single_untranslated.txt`,
`reports/charles_rows.tsv`, `reports/charles_bad_rows.tsv`, `glossary/glossary.tsv`.

**Conclusion.** Nothing to curate. The master already carries the Arabic; the two "defects"
are deliberate. Logged here so the residual is not re-opened as if it were untranslated text.

---

## 5. Font / widget limits - ACCEPTED (documented, not fixable data-side)

- **UMG font size 35** for subtitles cannot be changed from data; the widget hard-codes it.
  Font size/line spacing experiments are therefore scoped to what the font payload can do
  (v3 = unhinted, v3b = original vertical metrics). See `reports/font_ab_evidence.md`.
- **Cyrillic + Hangul are absent from IBM Plex Sans Arabic.** 37 codepoints used by the
  master are source-inherited (Cyrillic letters inside Latin weapon ids such as `АK47`,
  `VOV-А6`, `КS-23`, and a Japanese quote in one DLC4 mail). The original faces cover
  Cyrillic but not the CJK quote either. Glyph gate: **0 newly required Arabic codepoints**;
  verdict PASS with the documented `-AllowSourceInheritedNonLatin` exemption (DEC-027).
- **U+202F (narrow no-break space) and U+2060 (word joiner)** are also missing from Plex and
  are source-inherited.
- **`NotLifted_17`** (KI-017) is obfuscated; skipped and logged, not translated.

---

## 6. What is NOT blocked

- The text passes (quote, tone, glossary, content fix) are applied, verified and shipped in
  p11: `verify_text_fixups.ps1` PASS, `validate_translation.ps1` PASS (0 hard errors),
  `glyph_gate.ps1` PASS, `subtitle_timing_audit.ps1` 0 mismatches.
- The font variants v3 / v3b are built, round-trip verified and installable in one command
  (`scripts/switch_variant.ps1`).
- The timing experiment p11b is built and installable; it only needs the in-game A/B verdict.
