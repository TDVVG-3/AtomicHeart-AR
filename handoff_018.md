# HANDOFF — Atomic Heart Arabic localization

**Last updated:** 2026-10-19 20:55 +03:00 (cycle 014 closed)
**Installed in game:** carrier **p9** + font **p2_plex** (Korean language slot, 3 files in `~mods`)
**Coverage:** **21,220 of 27,618 rows (76.83%)** — validator PASS, 0 hard errors

---

## 1. State in one screen

| item | value |
|---|---|
| master DB | `localization\master\atomic-heart-ar.tsv` — 27,618 rows x 13 cols, 21,220 Arabic (DRAFT) |
| English-fill rows | 6,398 (no Arabic yet; carrier falls back to the en-US text of the same key) |
| kept-Korean rows | 0 |
| TM | `localization\tm\tm.tsv` — 15,410 entries |
| work order | `localization\working\batch2\plan_unique.tsv` — 15,824 ids; **next unauthored id: b11109** |
| chunks applied | batch 2: 0002-0015 (cycle 013); batch 3: 0016-0038 (cycle 014) |
| validator | `scripts\validate_translation.ps1` → PASS, errors 0, warnings 215 (number 93 / length 112 / glossary 10) |
| glyph gate | PASS, 164 distinct codepoints, 0 introduced by Arabic (15 source-inherited, allowed) |
| fixups | `localization\working\tm_fixups.tsv` — 83 rules, applied globally, verifier PASS |
| decisions | `DECISIONS.md` through **DEC-041** |
| known issues | `KNOWN_ISSUES.md` through **KI-033** |

## 2. What is installed right now

`C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart\AtomicHeart\Content\Paks\~mods\`
holds exactly three files:

| file | bytes | sha256 |
|---|---|---|
| `zzz_atomicheart-ar_carrier_koKR_p9_P.pak` | 4,276,477 | `90d41d78bdd5744ab2cae63980fa7b1376fd3a449c5987fbf9ac143e8f887de0` |
| `zzz_atomicheart-ar_font_p2_plex_P.pak` | 1,461,408 | `02b17f31e61a46ddba20bea8c4da5be44164173df608d52697f68d27d8269747` |
| `atomic-heart-ar-install-manifest.json` | 1,824 | `008cc3bcdf51049874090abab635e356996493eb5a12d05c8bc388859cf34578` |

* In-game language must stay **Korean** (the carrier occupies the ko-KR slot, DEC-015).
* Carrier build report: `reports\carrier_build.md` (35/35 scopes, keys 27,618, arabic 21,220,
  english 6,398, korean 0, round-trip fail 0, unpack byte-identical 35/35).
* **Rollback:** `powershell -File scripts\install_mod.ps1 -Carrier p8 -Font p2_plex`
  (p8 = previous carrier, 4,012,829 B, sha `dd0391ed…`).
* p9 has **NOT been play-tested** yet. Last in-game evidence remains the p7 canal-boat scene
  (Arabic label + line + both choices + prompt), plus the p8 install verification.

## 3. What cycle 014 did

1. **Closed KI-029** (bracket labels): the chunk gate now treats `[...]` as its own token class
   (count must match; each Arabic bracket must equal the English one or contain an Arabic letter).
   `[Leave]` -> `[مغادرة]` shipped (chunk 0016, 5 rows). Three tamper cases still hard-fail.
2. **Rebuilt the validator glossary matcher** (DEC-040): normalisation, suffix/word-prefix tolerance,
   pipe-separated accepted renderings, `cs` flag, prose-only English side. Glossary warnings
   141 -> 2 on the old corpus; after batch 3 it is 10, all sense/form cases triaged in KI-033.
3. **Batch 3** (chunks 0017-0038, 22 chunks): 6,530 ids authored, 7,226 rows filled,
   coverage 50.67% -> **76.83%**. Copy-class ids omitted: 71 (numbers, Latin-only, key names,
   asset ids such as `BP_WayPoint*`, `x{mult}`).
   New authoring input: `scripts\batch2_sheet.ps1` → `sheet_<nnnn>.tsv` (id, scope, category,
   english, **ru**, **tm**) — the Russian reference is resolved per key, including readable
   string-table keys like `NTD_StringTable/gazirovka`.
4. **Defects found by the gates and fixed** (11 rows): missing range marker `*0.01-0.28*`;
   a date taken from the RU asset while the English says another date; 3 content reductions
   (polymer expansion, "a doctor", "on Soviet soil"); 2 route-terminal labels; 3 rows with a literal
   mistranslation of the recurring expletive; 1 leading space.
5. **Carrier p9** built, validated and installed (DEC-041 path fix: `-VariantLabel` now names the
   file; the round-trip tolerates edge whitespace only).

## 4. Gates — how to reproduce

```powershell
cd C:\AtomicHeart-AR
powershell -File scripts\validate_translation.ps1          # expect VALIDATOR PASS, errors=0
powershell -File scripts\glyph_gate.ps1 -AllowSourceInheritedNonLatin   # expect GLYPH GATE PASS
powershell -File scripts\trim_trailing_ws.ps1              # expect rows trimmed: 0
powershell -File scripts\verify_text_fixups.ps1            # expect FIXUP VERIFY RESULT: PASS
```

Per-chunk loop (never skip a step):

```powershell
powershell -File scripts\batch2_chunk.ps1  -ChunkId 0039   # author gate, must print "entries: N"
powershell -File scripts\batch2_apply.ps1  -ChunkId 0039   # fills EMPTY cells only
powershell -File scripts\verify_text_fixups.ps1            # DEC-038: after EVERY chunk
powershell -File scripts\apply_text_fixups.ps1             # global, idempotent, if verifier complains
powershell -File scripts\validate_translation.ps1
powershell -File scripts\glyph_gate.ps1 -AllowSourceInheritedNonLatin
```

Authoring sheet for a new chunk:

```powershell
powershell -File scripts\batch2_sheet.ps1 -ChunkId 0039 -StartId b11109 -Count 300
# -> localization\working\batch2\sheet_0039.tsv  (id, scope, category, english, ru, tm)
```

## 5. Next move (batch 4, to 100%)

* Remaining: **6,398 rows**. Author chunks **0039 onward** from id **b11109** (plan order = game
  progression). 300 ids per chunk, ~320 rows per chunk, so ~20 chunks.
* Workstreams read `AUTHORING_BRIEF.md` + `glossary\terminology.md` + the chunk sheet; they may write
  only `ar_<nnnn>.tsv` and must pass `batch2_chunk.ps1`. Only the lead runs `batch2_apply.ps1`.
* Style contract: spoken-register MSA, one voice per character, never soften insults/threats/sarcasm,
  short English = short Arabic, UI strings as short as natural, Western digits, `،` and `؟`.
  When the English tone is unclear, consult the `ru` column (the Russian is the flavour source; the
  **English master is factual anchor** — see KI-032).
* Copy-class rows stay UNTRANSLATED with an empty Arabic cell (never reuse the English).
* At 100%: build `p10`, install `-Carrier p10 -Font p2_plex`, snapshot proof + SHA256 + rollback note,
  regenerate `localization\references\AR_EN_REFERENCE.md` and `reports\review_sample.md`, then close.

## 6. Open issues that are NOT batch-4 work

| id | state |
|---|---|
| KI-009 | GameTips popups — NOT TESTED |
| KI-013 | native `ar` language list needs Phase-8 `DA_Audio` tooling |
| KI-017 | `NotLifted_17` obfuscated — BLOCKED (evidence only) |
| KI-018 | 248 RU-only cooked dialogue assets / 6,012 strings (incl. `DT_Subtitles_*`) — Phase 8 decision |
| KI-022 | subtitle clip-vs-scroll — NOT TESTED |
| KI-026 | UI fit in game — NOT TESTED beyond the canal-boat scene |
| KI-027 | technical service ids, 2 DLC4 `CHAR-les` rows, 2,588 single-occurrence name-like values uncurated |
| KI-028 | choice number/separator `1 //` renders left of the Arabic — cosmetic, Phase 8 |
| KI-031 | `<...>`-lookalike plain text stays Latin (1 row, e.g. `<- ALCOHOL ->`) |
| KI-032 | en-US vs ru-RU asset divergences (dates/names); English master is the anchor |
| KI-033 | 10 residual glossary warnings, sense/form cases, reviewed and kept |

## 7. House rules that keep biting (read before authoring)

* **Arabic never goes into a `.ps1`** (PS 5.1 parses scripts as ANSI): build strings from
  `[char]0x....` or read them from a UTF-8 data file (KI-021).
* PowerShell `@{}` keys are case-insensitive → use `Dictionary[string,string]` with
  `[StringComparer]::Ordinal` for keys (KI-023).
* `-replace` replacements do NOT expand `\uXXXX`; use literal characters.
* Trailing whitespace is trimmed before every carrier build (KI-024); leading whitespace cannot be
  stored by the locres at all (handled by the build as `EDGE-WS`).
* The console prints Arabic/Korean/Russian as `?` — always verify from a UTF-8 file read, not stdout.
