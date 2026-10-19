# Batch-2 authoring brief (Arabic, Atomic Heart)

Read this fully before writing anything. It is the contract for ONE chunk: `ar_<NNNN>.tsv`.
The English source strings are in `localization/working/batch2/plan_unique.tsv`
(`id<TAB>english<TAB>occurrences<TAB>scope<TAB>key<TAB>category<TAB>en_len`).

## 1. Deliverable

Write exactly one file:

    C:\AtomicHeart-AR\localization\working\batch2\ar_<NNNN>.tsv

Format: one line per id, `id<TAB>arabic`, no header, UTF-8 **without BOM**, LF or CRLF.
Ids come from your assigned line range of the plan. Do not reorder, do not invent ids,
do not add ids outside your range.

Then verify it yourself (this gate must PASS; fix and re-run until it does):

    powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\batch2_chunk.ps1 -ChunkId <NNNN>

## 2. Absolute rules (the provided scripts enforce several of these)

1. **Never** edit any file other than your own `ar_<NNNN>.tsv`. Never edit the master TSV,
   `tm.tsv`, `tm_fixups.tsv`, the glossary, the plan, or another chunk's files.
   Never run `batch2_apply.ps1`, `validate_translation.ps1`, `glyph_gate.ps1`,
   `build_*`, or `install_mod.ps1` - the lead agent does that.
2. Markers, tags and escapes are **byte-exact** and stay in place, in the same order:
   `*0.10*` style timing markers, `{0}` placeholders, `<tag .../>`, `&Speaker&`, `\n`,
   `[Xxx]`, Latin key names (E, Q, ESC, P-3). Translate only the words around them.
   A row whose only content is a marker/tag/symbol/number keeps it unchanged.
3. **Copy-class rows are omitted** (no line for them). A row is copy-class when the
   correct Arabic would be identical to the English or would contain no Arabic letter -
   e.g. `P-3`, `VOV-A6`, `PEAR`, `THOUGHT` alone, a bare number, `//////*+`, `...`.
   Omitting them is required: the gate rejects empty Arabic and Arabic with no Arabic letter.
4. Western digits (0-9). Arabic punctuation: `،` `؟` - never `,` `?`. Keep `!` `...` `—`.
   Do not use Arabic-Indic digits, do not add diacritics (tashkeel) except where needed
   to avoid real ambiguity. No trailing spaces.
5. Keep the Arabic short when the English is short (subtitle width). Stay under about
   1.6 x the English length; the gate warns above that.
6. Never translate proper names into a different name: use the terminology table below.

## 3. Style (standing rule - `glossary/terminology.md` section 12)

- **Natural spoken Modern Standard Arabic.** Write what a native speaker would really say
  out loud. No word-for-word calques, no stiff literary register. Short English = short Arabic.
- **One voice per character:** Char-les = cheerful/chatty/sarcastic; Sechenov and officials =
  pompous/cold/bureaucratic; soldiers, workers, peasants = blunt, rough, direct; robots and
  service machines = mechanical and polite-formal only when the English is; P-3 = sarcastic,
  often annoyed; NORA = cheerful product-assistant.
- **Never soften.** Insults, swearing, threats, sarcasm and dark humour keep their full
  strength and register (Russian-grade crudeness stays crude, e.g. "son of a bitch" = يا ابن
  العاهرة, "damn" = اللعنة).
- Keep jokes as jokes (do not explain them); keep the Soviet flavour
  (الرفيق/أيها الرفاق, المنشأة, الاتحاد السوفييتي).
- Formal letter/announcement rows stay formal - that is register, not stiffness.

## 4. Terminology (established in already-shipped content - use these exactly)

| English | Arabic |
|---|---|
| Comrade / Comrade Major | الرفيق / رفيق الرائد |
| Major (rank) | الرائد |
| Sechenov, Dmitry Sechenov | سيتشينوف، دميتري سيتشينوف |
| Nechaev, Sergey Nechaev | نيتشاييف، سيرغي نيتشاييف |
| P-3 | P-3 (Latin, copy-class) |
| CHAR-les / CHARLES / Charles | تشارلز |
| Computer | الحاسوب |
| Kollektiv / Kollektiv 2.0 | كوليكتيف / كوليكتيف 2.0 |
| Kollektiv Neural Network | الشبكة العصبية كوليكتيف |
| THOUGHT (the neuro-connector) | «الفكرة» |
| glove (the glove) | القفاز |
| Polymer / Neuropolymer | بوليمر / البوليمر العصبي |
| Facility 3826 | المنشأة 3826 |
| Soviet / Soviet Union | سوفييتي / الاتحاد السوفييتي |
| VDNH | فيدنخا |
| Chelomey | تشيلومي |
| Vavilov (complex) | فافيلوف (مجمّع فافيلوف) |
| Pavlov | بافلوف |
| NORA | نورا |
| Granny Zina | الجدة زينا |
| Stockhausen | شتوكهاوزن |
| Tereshkova | تيريشكوفا |
| Petrov / Filatova | بيتروف / فيلاتوفا |
| Zakharov / Chariton Zakharov | زاخاروف / خاريتون زاخاروف |
| Maya Plisetskaya | مايا بليستسكايا |
| Belyash (robot) | «بيلياش» |
| Vova | فوفا |
| Robot / robots | الروبوت / الروبوتات |
| Electrician | الكهربائي |
| Theatre | المسرح |
| Spark (polymer) | «سبارك» |
| radio of the future | «راديو المستقبل» |
| soda (the drink) | صودا |
| sparkling-water sign | مياه غازية |
| cream soda / Tarkhun / Duchess (lemonades) | كريم صودا / طارخون / ديوشيس |
| hot-and-cold (kids' game, "hot and cold") | حار وبارد |
| battleship (the game) | سفن المعركة |
| Archivist / archive | أمين الأرشيف / الأرشيف |
| Collective Farm / kolkhoz | المزرعة الجماعية |

Anything not listed: prefer the wording already used in the master. Check with
`grep` on `localization/master/atomic-heart-ar.tsv` (or on the shipped chunk
`localization/working/batch2/chunk_0001.tsv`) before inventing a rendering, and keep it
consistent inside your chunk.

## 5. Working method (recommended)

1. Read `localization/working/batch2/chunk_0001.tsv` lines 1-60 as the style/format
   reference (English, Arabic, note columns).
2. Read your assigned range of the todo file **in slices of about 40 lines** - the read
   tool truncates long output, and losing lines means losing ids. Slicing is mandatory.
3. Author the Arabic in story order, keeping each conversation's internal continuity
   (pronouns, names, jokes) because ids are in playback order.
4. Write the file, run the gate, fix anything it reports, re-run until PASS.
5. Report back: file path, number of lines written, number of copy-class ids omitted
   (with the ids), the exact gate result line, and 5 sample `id -> English -> Arabic`
   triples chosen from the start, middle and end of your range.
