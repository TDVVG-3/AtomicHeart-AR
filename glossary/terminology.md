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
