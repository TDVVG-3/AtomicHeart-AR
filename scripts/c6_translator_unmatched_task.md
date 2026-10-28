# C6 Russian -> Arabic translation task (residual / extras chunk)

You are translating the remaining Russian strings from the game Atomic Heart into Arabic for a fan localization.

## Input / output

- Input: the concrete path given in your prompt under `C:\AtomicHeart-AR\build\c6\chunks_unmatched\`.
- Output: the concrete path given in your prompt under `C:\AtomicHeart-AR\build\c6\ar\`.
- Input columns: `id, ru, category, speakers, asset, markers, kind, field, count`. Only `id` and `ru` matter for translation.
- Output: UTF-8, no BOM, header `id<TAB>ar`, one row per input id, same order. No other text in the file.

## Read first

- `C:\AtomicHeart-AR\build\c6\style_guide.tsv` - authoritative Arabic names/terms. Use these exact forms.
- `C:\AtomicHeart-AR\glossary\glossary.tsv` - authoritative game terminology.

## What this chunk contains

These are real game strings that an earlier filter excluded because they were short, contained `:`, `/`, or code-like tokens:

- short exclamations and one-word lines (`Именно.`, `Катя?`, `Ха-ха!`)
- UI/tutorial hints with key names (`<h>A/D</>`, `<h>Q/E</>`, `<h>ПКМ</>`)
- terminal subjects, mail bodies, dossiers, positions, place names
- character names, surnames, patronymics
- dialogue/subtitle lines that contain `:` or quoted titles
- a few long archive/narration lines

Translate all of them. Do not drop rows because they are short.

## Voice

Spoken-register Modern Standard Arabic: natural, idiomatic game/film dialogue, not stiff literary MSA.

- P-3 / Nechaev: sarcastic, blunt, informal, occasional rough slang; short sentences.
- Lebedev: professor, formal, polite, measured, longer sentences.
- Sechenov: cold, authoritative, commanding.
- Char-les (glove): sarcastic, cocky, informal.
- Computer: terse, neutral, no emotion.
- Zinaida / Muravyova: sharp, commanding, mocking.
- Filatova: clinical, precise.
- Petrov: cynical, crude.
- Terminals, archives, narrator: formal bureaucratic or neutral narration.
- If the speaker is empty, infer the register from the line and the asset; keep it natural. Do not invent a speaker name.

## Preservation rules (hard requirements)

1. Subtitle markers such as `*0.10*` or `*0.00-0.10*`: same count, same order, byte-identical.
2. Highlight tags `<h>` and `</>`: same count, same order, byte-identical. Translate the text inside them; keep the tag delimiters unchanged.
3. Placeholders `{0}`, `%s`, `%d`: unchanged.
4. Key separators `/` (for example `A/D`, `Q/E`, `W или Space`): keep the same number of `/` characters. Translate key names naturally (`ПКМ` -> `زر الفأرة الأيمن`, `Пробел` -> `مسافة`, `Движение Мышью` -> `حركة الفأرة`).
5. Keep Latin model/code tokens that already appear in the Russian source: P-3, A/D, Q/E, W, S, F, Space, GooseRunner, SlideMode, and the like. Do not add new Latin prose.
6. Western digits 0-9 only. Never Arabic-Indic digits.
7. Arabic punctuation: use `،` `؟` `؛` and `«»` or `…` naturally. Avoid ASCII `,` `?` `;` in prose. A colon `:` may be kept when it is a UI label separator.
8. No Russian and no Cyrillic characters in the Arabic output.
9. Names: use the style guide. If a name is not there, transliterate it naturally into Arabic; do not leave it in Cyrillic.
10. Every `ar` cell must contain at least one Arabic letter.
11. Keep length close to the Russian. Short lines may be short; do not pad them.

Write the output file with the write tool. Then reply with only: `DONE <path> rows=<n>`.
