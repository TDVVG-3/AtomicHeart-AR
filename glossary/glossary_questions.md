# Glossary questions for review (DRAFT - needs your decision)

Date: 2026-10-18
Scope: entries in `glossary/glossary.tsv` where the choice between
TRANSLITERATION (Arabic letters, sound kept), TRANSLATION (meaning rendered) and
PRESERVATION (kept in Latin script) is a judgement call, not a fact.

> **DECISION 2026-10-18 (user): all 26 recommended defaults are ACCEPTED.** Nothing in this file
> is open any more; the recommended option (marked `*`) is now the rule. The user will review the
> sensitive terms (robot nicknames in group B, science/Soviet terms in group C, tone items in
> group D) after batch 1, and any change will be applied through the standard reviewer-fix
> workflow (`localization/working/tm_fixups.tsv` + `scripts/apply_text_fixups.ps1`).

How to answer: reply with the item number and the option letter, e.g. "1B, 2A, 3C".
Anything you do not answer keeps my RECOMMENDED option (marked with `*`).

Rule I applied everywhere else: real people = transliterated; places = translated;
model codes = preserved; ordinary nouns (weapon/ability/UI) = translated unless the
English itself is a proper series name.

Arabic script for each option is in `glossary/glossary.tsv` (the Arabic column); this
file is ASCII-only on purpose (report/handling rule).

---

## A. Model codes and acronyms

1. **VOV-A6**, **HOG-7**, **BEA-D(s)**, **P-3**
   - A* preserve exactly in Latin (recommended: model codes stay readable)
   - B transliterate into Arabic letters

2. **PEAR** (terminal network), **HAWK** (uplink platform)
   - A* preserve in Latin (they are shown as brand-like names in the UI)
   - B transliterate

3. **VDNH** (the Moscow exhibition district)
   - A preserve "VDNH" in Latin
   - B transliterate as "FIDNKHA"
   - C* transliterate as "FY DY IN ITH" (letter-by-letter, common in Arabic press)
   - Note: the English source itself shows "VDNH", so A is the safest for UI width.

## B. Robot and weapon nicknames with a Russian meaning

4. **Plyusch** (Russian for ivy), **Burav** (drill), **Kondor** (condor),
   **Belyash** (fried-dough snack), **Secateur** (pruning shears),
   **PASHTET** (pate), **Gadfly**
   - A* transliterate as names (recommended: they behave like names in dialogue)
   - B translate the meaning in dialogue and keep the transliteration in the UI

5. **Ballerina / Prima Ballerina** (boss robot)
   - A* transliterate "Balerina" / "al-Balerina al-oola"
   - B translate "raqisat al-balih" / "raqisat al-balih al-oola"

6. **Dewdrop** (DLC3 robot)
   - A* translate "qatrat al-nada"
   - B transliterate "Dyu-drup"

7. **Fat Boy**, **Snowball**, **Swede**, **Needle**, **Whip**
   - Already translated (they are English nicknames, not transliterations).
   - Confirm: A* keep translated. B keep Latin.

## C. Science and soviet terms

8. **SHOK** (Russian for shock; shown as SHOK)
   - A* transliterate "SHUK"
   - B translate "al-sa'q" (the shock)

9. **Voskhod** (polymeric brain extension; Russian for sunrise)
   - A* transliterate "FOSKHOD"
   - B translate "al-shurooq"

10. **Argentum** (special-forces unit; Latin for silver)
    - A* transliterate "ARGENTUM"
    - B translate "al-fidda"

11. **Kollektiv / Kollektiv 2.0** (the neural network)
    - A* transliterate "KOLIKTIF"
    - B translate "al-jama'a" / "al-jama'iya"

12. **Limbo** (the neural-interface space)
    - A* transliterate "LIMBO"
    - B translate "al-ghayb" (the unseen)

13. **Neuropolymer** (chosen: translated "al-bulimer al-asabi") and
    **Cryopolymer** (chosen: transliterated "krayo-bulimer")
    - Inconsistent? A* keep both as chosen
    - B make both translated
    - C make both transliterated

14. **Neuromed** (medkit brand)
    - A* transliterate "NYUROMID"
    - B translate "al-dawa al-asabi"

15. **Telekinesis / Mass Telekinesis** (ability)
    - A* translate "tahrik al-ashya' an bu'd" (clear to players)
    - B transliterate "tilikinisis"

16. **Railgun**
    - A* translate "al-midfa' al-qadb-ani"
    - B transliterate "ra-ylghun"

17. **Monorail**
    - A* transliterate "MONORAIL"
    - B translate "uhadi al-sikka"

18. **Zvezdochka** (weapon series)
    - A* transliterate "ZVEZDOCHKA"
    - B translate "al-nujayma" (the little star)

19. **Frostbite** (ability)
    - A* translate "al-saqi'" (the frost)
    - B transliterate

## D. Tone and content

20. **Comrade**
    - A* "al-rafiq" (classic Soviet tone, recommended)
    - B "al-zamil" (neutral)

21. **Comrade Major**
    - A* "al-rafiq al-raid"
    - B "hadrat al-raid" (formal address)

22. **Profanity and insults** - your standing rule is "do not sanitize".
    - A* translate faithfully, keep the character's register (recommended)
    - B soften the strongest terms

23. **Fragment/timing markers** in dialogue, e.g. `*0.10*`, `*0.05*`, `\n`
    - A* preserve byte-exactly (recommended: they are engine markers, not prose)
    - B strip them from the Arabic (would change timing/behaviour - not recommended)

## E. Formatting

24. **Digits**: Western 0-9 everywhere (your rule).
    - A* as agreed. Numbers inside names (Facility 3826, Kollektiv 2.0) stay Western.

25. **Punctuation**: Arabic question mark and Arabic comma where natural.
    - A* as agreed (characters U+061F and U+060C).

26. **Ellipsis**: keep the source's "..." (three dots) rather than a single glyph.
    - A* three ASCII dots (matches the source, avoids font surprises)
    - B Arabic ellipsis character

---

## Mechanical items (no answer needed, listed for transparency)

- Rich-text tags `<h>...</>`, `<c>...</>`, `<img id="..."/>`, `<tag id="..."/>`,
  placeholders `{0}`, `%s`, escapes `\n` are copied byte-exactly into Arabic.
- Latin key names ("E", "Q", "ESC") stay Latin.
- These are enforced automatically by the validator, not by judgement.

---

## F. Batch 1 (2026-10-18) - items worth a reviewer decision

Full raw evidence: `reports/batch1_translator_notes.md` (427 lines, one bullet per uncertain choice,
grouped by chunk). Summary of the classes that need your judgement:

1. **Weapon and module nicknames**: translated (e.g. animal nicknames for weapon parts) rather than
   transliterated, so a weapon list stays readable. A few (SDC-2 Volan, BEA-D, PASHTET) stay Latin
   because the glossary says so. Decide whether you prefer translation or transliteration for the
   remaining Russian-meaning nicknames.
2. **`Chai! And chaps!`** - an untranslatable toast; rendered as an Arabic vocative cheer keeping
   both exclamation marks. No glossary entry for `Chai` as an exclamation.
3. **SHOK derivatives** (`SHOKer`, `SHOK therapy`): SHOK itself is glossary-fixed; the derivatives
   are transliterated/descriptive. Confirm or change.
4. **`Thrift`**, **`Carousel`**, **`Lumberjack`**, **`Greaser`**, **`Fox`**, **`Turbine`**: single
   ambiguous words read as the abstract quality / the descriptive meaning rather than as shop or
   brand names.
5. **Technical Latin kept**: `RTX`, `DLAA`, `Nvidia Reflex`, `FHD/HD/QHD/UHD`, `BIOS`, `SSD`, `HDD`,
   `BC`, `ORB`, `SHIFT`, `Space`, `BP_WayPoint50` are byte-identical to the English. Confirm you
   want these untranslated in the UI.
6. **86 shortened UI labels**: a second pass shortened Arabic that was more than 1.4x the English
   length (tags, placeholders, digits and glossary terms preserved). If any shortened label reads
   worse than the longer form, say which and it can be restored.
7. **Copy-class rows**: 170 distinct strings (378 rows) are intentionally identical to the English
   (numbers, symbols, lone tags, key letters, model codes, language endonyms, gibberish and
   pure-format strings like `{Class},  {Message}`). They stay UNTRANSLATED so the English shows
   through; the list is in `localization/working/batch1/copy_keep.tsv`.
8. **Glossary-pressure warnings (70)**: mostly plural forms the glossary matcher cannot see
   (`الخراطيش` for `Cartridge`) and `Shotgun` inside `4 shotgun shells`. These are wording choices,
   not errors; flag any you dislike.
   9. **Speaker-name dictionary (cycle 012, DEC-030)**: 292 names were given one Arabic each in every scope
      (1,264 rows). The whole dictionary is `localization/working/labels/speaker_names.tsv` and the per-name
      counts are in `localization/working/labels/label_apply_report.tsv`; the inventory of every name-like
      value in the project is `localization/working/labels/label_candidates.tsv` (3,611 distinct values /
      9,168 rows). Points worth a native check:
      - **Transliteration style** for personal names: `Sechenov`, `Petrov`, `Filatova`, `Stockhausen`,
        `Tereshkova`, `Zakharov`, `Molotov`, `Vavilov`, `Chelomey`, `Lebedev`, `Pavlov`, `Korolyov`,
        `Nechaev`/`Nechaeva`, `Chariton`, `Rafik`, `Blesna`, `Kheimsov`, `Orlikova`, `Samokhin`, `Tikhonov`,
        `Zhabov`, `Kuropatkin`, `Lepyoshkin`, `Isayeva`, `Dogov`, `Khosnak`. The glossary (already agreed)
        fixes `Doctor`, `Ballerina`, `Korolyov`, `Polymorph`, `Nechaev`, `Sergey Nechaev`, `Katya Nechaeva`,
        and that wording was adopted rather than replaced.
      - **Nicknames / puns**: `Teardrop`, `Robogirl`, `Nale`, `Cream pie`, `Fluffball`, `Angry one`,
        `Talking corpse` (and the whole `Dead ...` / `... corpse` family), `Granny Zina`,
        `Forgetful citizen`.
      - **Machine ids kept Latin on purpose**: `P-3` (1,140 rows), `VOV-A6`, `RAF-9`, `RACCOON-SP`,
        `WSP-9E`, `PTA-6` (rendered by sound in dialogue, Latin in its label). Confirm the Latin display is
        what you want inside the subtitle brackets.
      - **Left untranslated on purpose (technical service ids used as labels)**: `Start`, `NoText`,
        `SaidSecond`, `FinalDialog`, `RadioReroute`, `Order`, plus the two DLC4 `CHAR-les` rows and the
        single `Chariton` row in `Mails_01`. Say the word if any of these is actually shown to the player.
      - **Not yet curated (residual)**: 2,588 name-like values that occur only once in the whole project have
        not been individually reviewed; they are listed in `label_candidates.tsv` and can be swept in a
        later cycle if you spot any still in English.
   10. **Batch-2 opening chunk (cycle 012)**: the first 306 unique strings of the prologue (Chelomey boat
       narration, the arrival monologue, the aerobics/photo/poem/phone-prank conversations) are now in
       Arabic. If any line's tone, joke or insult reads wrong, name the chunk id (`b####`) - the file is
       `localization/working/batch2/ar_0001.tsv`, and the English is in
       `localization/working/batch2/plan_unique.tsv` under the same id.
    G. **The drink in the canal boat scene (cycle 013) - please confirm the term.** Your note was right:
       `الغازية` is colloquial and does not fit. I checked the Russian original (exported from the shipped
       ru-RU locres with `scripts/export_ru_reference.ps1` into `localization/extracted/ru_csv/`):
       - boat scene: `Дорогой товарищ, газировки не желаете?` - "газировка", the everyday Soviet fizzy
         drink (English "soda"). Now: **`تريد صودا يا رفيقي العزيز؟`**.
       - museum order list: `Газировка - 200 литров` (English "Soda, 200 liters"). Was `مياه غازية، 200 لتر`,
         now **`صودا، 200 لتر`**.
       - VDNH vending-machine sign: Russian is `ГАЗИРОВАННАЯ ВОДА` (sparkling water), English "SODA". The row
         is still untranslated; when authored it becomes **`مياه غازية`** - that is the precise Arabic for a
         water sign, which is why two Arabic terms exist for the two Russian ones.
       - buffet/museum signs also sell lemonades: `Крем-сода`, `Тархун`, `Дюшес` -> **`كريم صودا`, `طارخون`,
         `ديوشيس`** (flavour names, transliterated); `NEW FLAVORS: CREAM SODA AND SAKHALIN` -> `نكهات جديدة:
         كريم صودا وساخالين`. Those rows are still untranslated and will use these forms.
       - the metaphor "like popping the caps off soda bottles" (`словно бутылки газировки открывали`,
         Vavilov/LQA) is still untranslated and will use `زجاجات الصودا`.
       Q: is **`صودا`** the term you want (alternative: `مشروب غازي` everywhere), or should the sign form
       `مياه غازية` be avoided? DECISION NEEDED (glossary row `Soda` is DRAFT).
       Also note: `الغازية` was a substring of `التوربينات الغازية` ("gas turbines"), so the fix used a
       full-row match - the turbine row was NOT touched.
    H. **Style rule applied retroactively (cycle 013).** Your "too soft / polite / stiff" feedback is now a
       standing rule (`glossary/terminology.md` section 12) and was applied to the already-shipped content:
       40 rows rewritten (prologue, Chelomey, Academy, PearTerminals, NewP5), each compared with the Russian
       source. Before/after with the reason for every row: `reports/tone_pass.md`. Deliberately NOT changed:
       the PearTerminals/Mails official letters, whose Russian is itself a bureaucratic formula.
       Q: if any remaining line still reads soft, give me the scene and I will treat it as a rule 12
       violation - the same pass can be extended to more rows (my cap was 150 rows).
