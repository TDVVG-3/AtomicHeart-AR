# Batch 1 translation brief — English to Arabic (Atomic Heart)

You are a professional English -> Modern Standard Arabic game localizer.
Game: Atomic Heart (retro-futuristic Soviet FPS, USSR 1955). UI text, tips, item
descriptions, terminals, mail and dialogue.

This file is the contract for the job. Follow it exactly.

## 1. What you produce

You get one input file, e.g. `localization/working/batch1/chunk_NN_en.tsv`.
Format (tab separated, first line is a header):

```
id	english	scope	key	category	en_len
u0001	NEUROPOLYMER	NewP5	/280DCEA846FF0EA25019E8B676395611	UI	12
```

You write `localization/working/batch1/chunk_NN_ar.tsv` (same NN) with EXACTLY:

```
id	arabic
u0001	نيوروبوليمر
u0002	...
```

Rules for the output file:
- Line 1 is the header `id` TAB `arabic`.
- Then one line per input id, SAME ORDER as the input, `id` TAB `arabic`.
- Every input id appears exactly once. No extra ids. No blank lines. No commentary.
- Create the file with your file-writing tool (it writes UTF-8, no BOM).
  NEVER put Arabic inside a `.ps1` script or a shell command (PowerShell 5.1
  would mangle it). Arabic goes only into the `.tsv`/`.md` data file.
- Also write `localization/working/batch1/chunk_NN_notes.md` with one bullet per
  uncertain choice (see section 7). If nothing is uncertain, write a single line
  `- (no uncertain terms)`.

## 2. Authoritative glossary (read first)

- `glossary/glossary.tsv` — columns: `term  arabic  category  reason  status  notes`.
  If an English term is listed there, use its Arabic form. You may inflect it
  naturally (add case endings / prefixes / suffixes / definiteness) but keep the
  same root and transliteration. The `notes` column often explains variants.
- `glossary/terminology.md` — style rules (speaker markers, reviewer fixes, etc.).

## 3. Language and style

- Modern Standard Arabic, natural game-localization register: fluent and
  idiomatic, NOT literal word-for-word.
- Keep the Soviet / military / retro-futuristic flavour, the dark humour, the
  irony and the insults. Do NOT sanitize, soften or censor anything.
- Keep character voice: P-3 / Major Nechaev is sarcastic and blunt; CHAR-les is
  chatty and cheerful; scientists are pompous; propaganda is grandiose.
- Sentences must be grammatical. Check your own spelling, agreement and
  definiteness. (No errors like an invented/mis-vocalised word.)
- Contracted English apostrophes and possessives have no Arabic equivalent:
  translate the meaning, do not invent apostrophes.

## 4. HARD RULES — byte-exact tokens (never change/drop/reorder/translate)

These are consumed by the game/build. Any change corrupts the string:

1. Rich-text tags: `<h>`, `</>`, `<Bold>`, `<title>`, `<value>`,
   `<checkbox title>`, `<slider title>`, `<tag id="..."/>`.
   Keep every tag exactly, including attributes, quotes, spacing and the
   self-closing `/>`. You may MOVE a tag to its natural Arabic position, but the
   tag text itself must be byte-identical and appear the same number of times.
2. Placeholders: `{0}` `{a}` `{b}` `{Class}` `{Left}` `{Max}` `{Message}` —
   keep exactly, no spaces added inside.
3. Key names kept in Latin: `E`, `Q`, `ESC`, `Ctrl`, `LMB`, `RMB`, `Space`,
   `Shift`, `Alt`, `Tab`.
4. Digits: keep numbers with Western numerals (0-9). Translate unit/word parts
   only: `+40 HP` -> `+40 صحة`, `30 mm` -> `30 مم`.
5. `%`, `+`, `#`, `/`, `|`, `||`, `( )`, `[ ]` stay as symbols.
6. Em dash `—` (U+2014) used as a separator in compound technical names
   (`KALASH—CARTRIDGE`, `DOMINATOR—SPINNING ORB`, `KS-23—DAMPER—POLYMERIC STOCK`):
   keep the em dash in the same structural position.
7. Language endonyms in the language-selection list are copied EXACTLY:
   `español`, `français`, `português (Brazil)`, `日本語`, `漢語`, `한국어`.
   Do not translate or Arabicize them.
8. Gibberish / test / symbol-only strings are copied as-is: e.g. `d????dsss  ghhg`,
   `-`, `—`, `°`, `º`, `/`.
9. Surrounding whitespace that is structural is preserved (`[ Flatlined ]` keeps
   the spaces inside the brackets).
10. Speaker labels of the form `&Name&` (if any appear) stay byte-exact.

## 5. Punctuation

- Arabic question mark `؟` and Arabic comma `،` inside Arabic sentences.
- Western digits (0-9) everywhere. No Arabic-Indic digits.
- Keep parentheses/brackets/colons in the position that reads naturally.

## 6. Length (UI fit)

- Column `en_len` is the English character count. For UI labels keep the Arabic
  the same length or shorter when possible; never more than ~15% longer for
  labels under 40 characters.
- Terse English 1-3 word labels get terse Arabic labels.
- Long descriptions (tips, letters, dossiers) may be a bit longer, but stay
  concise and natural.

## 7. Reuse and uncertainty

- A repeated English string appears only once in your chunk, so translate it once,
  well. Prefer wording that also reads well in the other contexts it may occur in.
- If the English already exists in `localization/working/tm.tsv` (columns
  `english  arabic  ...`) and the context matches, reuse that Arabic wording.
- Never leave an id untranslated. Never write `?`, `???`, `TBD` or empty Arabic.
- If a term is genuinely ambiguous, pick the best choice, use it consistently,
  and record it in the notes file:
  `- <english> -> <arabic chosen> — because <reason>`.

## 8. Do NOT

- Do not modify any file other than your two output files.
- Do not touch `localization/master/**`, `localization/working/tm.tsv`,
  `glossary/**`, or any `scripts/**`.
- Do not run build / validate / install scripts.
- Do not add a BOM, do not gzip, do not rename the file.

## 9. Examples

| english | arabic |
|---|---|
| `NEUROPOLYMER` | `نيوروبوليمر` |
| `yrs` | `سنة` |
| `+40 HP` | `+40 صحة` |
| `+10% damage to robots` | `+10% ضرر للروبوتات` |
| `Charge speed` | `سرعة الشحن` |
| `Character rotation` | `دوران الشخصية` |
| `PRESS <tag id="InputAction.MainMenuWidget.UI_MainMenu_AnyButton"/> TO START` | `اضغط <tag id="InputAction.MainMenuWidget.UI_MainMenu_AnyButton"/> للبدء` |
| `<title>` (tag only) | `<title>` |
| `E-response \|\| Q-none` | `استجابة E \|\| لا شيء Q` |
| `The use of superconductors reduces the loss of incoming kinetic impact velocity, increasing the recirculation chamber energy recovery rate.` | `يقلل استخدام الموصلات الفائقة من فقدان سرعة الاصطدام الحركية الواردة، ما يزيد معدل استعادة الطاقة في غرفة إعادة التدوير.` |

## 10. Final self-check before you finish

1. The output file has exactly `1 + N` lines, N = number of input rows.
2. Every id matches, in order.
3. Every Arabic cell is non-empty.
4. Count of each `<...>` tag and each `{...}` placeholder matches the English row.
5. No `?` inside an Arabic cell (except inside a copied Latin fragment or a
   copied `?` from a gibberish/obfuscated English string).

Then return ONLY a 3-line summary: output path, number of rows written, number of
notes recorded.
