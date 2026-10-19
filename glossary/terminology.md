# Arabic terminology and style guide (DRAFT v1)

Project: Atomic Heart Arabic localization (Steam app 668580).
Date: 2026-10-18. Status: DRAFT - applies from the pilot onward.
Owner rule set: MASTER_PROMPT.md + DEC-023. This file is ASCII-only by project rule
(Arabic examples are given in `glossary/glossary.tsv` and in the review samples).

---

## 1. Target language and voice

1.1 Modern Standard Arabic (MSA). Natural, clear, professional game localization.
    No word-for-word calques; restructure the sentence when Arabic demands it.

1.2 Keep the character's personality, humour, insults, military and Soviet tone.
    Do NOT sanitize dialogue. If the English is crude, the Arabic is crude in the
    same register (colloquial fillers such as "hmm", "ugh", "well" become natural
    Arabic equivalents, not "hmmm").

1.3 Register map:
    - Sechenov / officials / Academy records: formal, bureaucratic, cold.
    - CHAR-les (the glove): chatty, sarcastic, informal.
    - Granny Zina / peasants / workers: warm, simple, slightly rustic.
    - Soldiers and the Major: clipped, military, direct.
    - NORA: cheerful product-assistant tone.

1.4 Idioms and jokes are localized, not explained. If a pun cannot survive, keep the
    function (insult/joke/tease) even if the image changes. Never add a translator note.

## 2. Numbers, dates, punctuation

2.1 Western digits 0-9 only (`2026`, `3826`, `2.0`, `500`). No Eastern Arabic numerals.

2.2 Arabic question mark U+061F and Arabic comma U+060C where natural inside Arabic
    sentences. A sentence that is entirely Latin (a key name, a code) keeps ASCII
    punctuation.

2.3 Ellipsis: three ASCII dots "..." exactly as in the source. Do not invent a single
    ellipsis glyph.

2.4 Quotation: use Arabic double quotes where the source uses quotes around speech;
    keep straight quotes when they sit inside a tag or placeholder.

2.5 Non-breaking spaces are not introduced. Trailing/leading spaces in the source are
    preserved exactly (some UI strings are used as fragments).

## 3. Tags, placeholders, escapes (byte-exact)

3.1 Copy EXACTLY, character for character:
    - rich text: `<h>...</>`, `<c>...</>`, `<img id="..."/>`, `<tag id="..."/>`
    - placeholders: `{0}`, `{1}`, `%s`, `%d`
    - escapes: `\n` (two characters), `\r`, `\t`
    - engine markers seen in dialogue: `*0.10*`, `*0.05*` (fragment/timing)
      -> preserved before the Arabic fragment they belong to.

3.2 Never translate, split, reorder or drop a tag. Never move a tag across a
    sentence boundary. The validator fails the row if the tag multiset differs.

3.3 Latin key names and button names stay Latin: `E`, `Q`, `ESC`, `W`, `A`, `S`, `D`,
    `LMB`, `RMB`, `Shift`, `Ctrl`, `Alt`, `Tab`, `Space`.

## 4. Glossary use

4.1 Every proper name, robot, location, weapon, ability and material MUST match
    `glossary/glossary.tsv` exactly (including the chosen transliteration).

4.2 If a term is missing from the glossary, do not invent silently: use a provisional
    rendering and add the term to `glossary/glossary_questions.md`.

4.3 Do not translate terms marked `preserved` (they stay in Latin script).

## 5. Length and UI fit

5.1 Target length: Arabic <= English length where the English is a short UI label;
    up to ~120% for menu items; dialogue may be longer but should not add new content.

5.2 Buttons, tabs, HUD chips (<= 16 characters English): keep Arabic to one or two
    words. Prefer established Arabic UI words over long descriptive phrases.

5.3 Do not use tatweel (U+0640) to stretch text, and do not use manual letter
    joining/isolated forms. The renderer shapes the text.

## 6. Translation memory

6.1 Each UNIQUE English string is translated once. Identical English may be reused
    across rows ONLY when the context (SourceEnglish + Speaker + Category + scope)
    is compatible. Different meaning in a different context = a new translation.

6.2 The memory key is the exact English string. Rows sharing a key inherit the same
    Arabic unless a reviewer overrides that specific row (recorded in Notes).

## 7. Status workflow (master TSV, column "Status")

    UNTRANSLATED -> DRAFT -> REVIEWED -> APPROVED
    TECHNICAL   = must not be translated (engine/technical)
    BLOCKED     = cannot be translated (missing/obfuscated source)

7.1 Every batch sets new rows to DRAFT. Reviewed rows are only changed by an explicit
    correction (Status stays REVIEWED, Notes records the change).

7.2 Arabic column is written as UTF-8, no BOM, no U+FFFD, no mojibake.

## 8. Validation gates (per batch, all must pass)

8.1 Placeholder multiset identical to the English source (per row).
8.2 Rich-text tag multiset identical (per row).
8.3 No empty Arabic for a row whose Status is DRAFT/REVIEWED/APPROVED.
8.4 No untranslated English left in Arabic (whole-value equality with the English).
8.5 UTF-8 clean: no U+FFFD, no lone surrogates, no control chars other than the
    preserved escapes.
8.6 Glossary compliance: every glossary term found in the English is rendered with the
    glossary Arabic (substring check, case-insensitive).
8.7 Length warning: Arabic longer than 1.2 x English on UI rows (warning, not failure).

## 9. Review artefacts

9.1 `localization/references/AR_EN_REFERENCE.md` - Arabic first, English below, one
    block per translated row, grouped by scope. Regenerated every batch.

9.2 HANDOFF.md carries a 40-row review sample per batch (random across categories,
    plus the longest rows and rows containing tags).

9.3 Install/uninstall only with `scripts/install_mod.ps1` / `scripts/uninstall_mod.ps1`,
    and only after explicit user approval.

## 10. Speaker markers in subtitle lines (DLC2 "Schebetars" only)

10.1 130 master rows contain an inline marker of the form `&Speaker Name&`, all inside three
    DLC2 scopes: `Schebetar_Subs` (90), `Schebetars_dlc1` (39), `Locations_dlc2` (1). Base-game
    dialogue has none. Evidence: reports/speaker_markers.md (145 distinct tokens).

10.2 Standing rule: the marker and its delimiters are copied BYTE-EXACTLY into the Arabic, exactly
    like a rich-text tag. The validator enforces the marker multiset per row.

10.3 Conditional rule (activates ONLY if the in-game check shows the names are displayed to the
    player - report case A in reports/speaker_marker_check.md):
      - characters            -> transliterated using the glossary
      - roles/descriptors     -> translated (Surgeon, Nurse, Colonel, Private, ...)
      - non-verbal cues       -> translated (Moo!, WOOF!, KABOOM!, sound descriptions)
      - unit/asset names      -> glossary form (P-3, NORA, Kollektiv PA, BEA-D, Argentum soldier)
    The delimiters stay Latin `&`; only the text between them changes.

10.4 If the check shows the markers are stripped or shown raw (cases B/C), 10.2 remains the whole
    rule and no speaker name is ever translated.

## 11. Reviewer fix workflow

11.1 Reviewer corrections are never typed into a script (PowerShell 5.1 mangles non-ASCII script
    literals, KI-021). They live in `localization/working/tm_fixups.tsv` as `find <tab> replace
    <tab> note` and are applied by `scripts/apply_text_fixups.ps1` to the master Arabic column,
    the translation memory and the seed CSV; `scripts/verify_text_fixups.ps1` then proves the old
    text is gone and the master still matches the memory. The pass is idempotent.

11.2 A fix is recorded in `reports/text_fixups_log.md` with the exact rows it touched, and is
    mentioned in HANDOFF.md.

## 12. Spoken-register rule (standing, cycle 013 - user style decision)

12.1 Natural spoken-register Modern Standard Arabic. Every line must read the way a native
    speaker would really say it out loud in a game: not a literal word-by-word rendering of the
    English, and not a formal literary register. If the English is short, the Arabic is short.
    Prefer common everyday words over rare literary ones.

12.2 Each character keeps their own voice; the English and (where the tone is ambiguous) the
    RUSSIAN source decide how blunt or polite the line is:
    - Char-les: cheerful, chatty, sarcastic, informal.
    - Sechenov and officials: pompous, cold, bureaucratic.
    - Soldiers, workers, peasants: blunt, rough, direct.
    - Robots and service machines: mechanical, polite-formal ONLY when the English/Russian is.
    - P-3 (Nechaev): sarcastic, often annoyed.
    - NORA: cheerful product-assistant tone.
    A line that is polite in the source stays polite - the rule is against stiffness the source
    does not have, not against politeness the source does have.

12.3 Never soften. Insults, swearing, threats, sarcasm and dark humour keep their full strength
    and stay in the same register as the original (see 1.2 - no sanitizing).

12.4 Typical stiffness markers to avoid unless the source is formal:
    - "هل ترغب / هل تودّ" -> "تريد" (question formed by intonation, as in speech)
    - "أليس كذلك؟" for a short "eh?/huh?" -> "هاه؟"
    - "أودّ أن / أرغب في" -> "أريد / يا ليتني" depending on meaning
    - "ينبغي أن" -> "عليّ أن"
    - "يسعدني سماع ذلك" -> "هذا رائع"
    - "من فضلك" for a shouted order or a plain request -> drop it or use a direct imperative
    - "أنا في سنٍّ تجعلني..." -> "أنا كبير بما يكفي..."
    - official-letter formulas ("من واجبي أن أسترعي انتباهكم") are KEPT where the Russian is
      itself an official-letter formula - that is register, not stiffness.

12.5 Applied retroactively to already-shipped content (prologue, Chelomey, cutscenes) through
    `localization/working/tm_fixups.tsv`; listed with before/after in `reports/tone_pass.md`.
    New batch-2/3/4 authoring follows it from the start.

## 13. Glossary cell syntax (cycle 014)

The Arabic cell of `glossary/glossary.tsv` may list more than one accepted rendering, separated by `|`
(e.g. `Cartridge -> خرطوشة|خراطيش`). The validator accepts the row when ANY listed rendering is present
in the translation, and it also accepts inflected forms (plural/feminine/definite article, tanween) of a
listed rendering. Add a rendering to the cell only when the shipped Arabic is correct and natural; that
keeps the check honest instead of loosening it. The optional 7th column may hold `cs`, which makes the
English-side match case-sensitive (`Major` uses it so that `major damage` does not warn).
