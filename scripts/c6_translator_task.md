# C6 Russian -> Arabic translation task (one chunk)

You are translating Russian dialogue/subtitle strings from the game Atomic Heart into Arabic for a fan localization.

## Input / output

- Input: `C:\AtomicHeart-AR\build\c6\chunks_official\chunk_<NNNN>.tsv` (UTF-8, tab-separated, header: id, ru, category, speakers, asset, markers).
- Output: `C:\AtomicHeart-AR\build\c6\ar\chunk_<NNNN>.tsv` (UTF-8, no BOM), header `id<TAB>ar`, one row per input id, same order. No other text in the file.
- Translate every row. Do not merge or split rows. Do not skip ids.

## Read first

- `C:\AtomicHeart-AR\build\c6\style_guide.tsv` - authoritative Arabic names/terms. Use these exact forms.
- `C:\AtomicHeart-AR\glossary\glossary.tsv` - authoritative game terminology.

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

## Preservation rules (hard requirements)

1. Subtitle markers such as `*0.10*` or `*0.00-0.10*`: same count, same order, byte-identical, same position relative to the sentence.
2. Tags such as `<h>...</>`, `<tag .../>`, `</>`: byte-identical and same order.
3. Newlines, leading and trailing spaces: preserve count and positions.
4. Placeholders `{0}`, `%s`, `%d`: unchanged.
5. Western digits 0-9 only. Never Arabic-Indic digits.
6. No Russian. No Latin prose. Latin is allowed only for model/code tokens that already appear in the Russian source: P-3, BUS-A, SHZ-5, VOV-A6, BEA-D, HOG-7, PEAR, and the like.
7. Arabic punctuation: use `،` `؟` `؛` and `«»` or `…` naturally. Avoid ASCII `,` `?` `;` in prose.
8. Keep length close to the Russian (subtitles must fit): aim <= 1.4x characters. Never omit meaning.
9. Sounds/interjections/caps: natural Arabic letters (آه، أوه، هاها) preserving intensity.
10. Terminal headers/technical labels: concise and formal.
11. Every `ar` cell must contain at least one Arabic letter.

Write the output file with the write tool. Then reply with only: `DONE <path> rows=<n>`.
