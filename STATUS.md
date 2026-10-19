# STATUS — Atomic Heart Arabic localization (English-sourced, text only)

**As of:** 2026-10-19 20:55 +03:00 · cycle 014 closed · Steam app 668580

## Headline

| metric | value |
|---|---|
| coverage | **21,220 of 27,618 rows (76.83%)** |
| tier 1 (25% = 6,905) | DONE |
| tier 2 (50% = 13,809) | DONE |
| tier 3 (75% = 20,714) | DONE |
| tier 4 (100% = 27,618) | IN PROGRESS (+6,398 rows to go) |
| remaining rows | 6,398 English-fill (no Arabic yet) |
| next unauthored plan id | b11109 (chunk 0039) |

## Master, TM and plan

| item | value |
|---|---|
| master | `localization\master\atomic-heart-ar.tsv`, 27,618 rows x 13 cols, Status = DRAFT/UNTRANSLATED |
| TM | `localization\tm\tm.tsv`, 15,410 entries (0 conflicts on the last 22 applies) |
| work order | `localization\working\batch2\plan_unique.tsv`, 15,824 ids (game-progression order) |
| authoring chunks applied | 0002-0015 (cycle 013), 0016-0038 (cycle 014) |
| copy-class ids omitted | 71 in cycle 014 (numbers, Latin-only, key names, asset ids) |

## Gates (last run, this cycle)

| gate | result |
|---|---|
| `validate_translation.ps1` | **PASS** — 27,618 rows, 21,220 translated, **0 errors**, 215 warnings (number 93 / length 112 / glossary 10) |
| `glyph_gate.ps1 -AllowSourceInheritedNonLatin` | **PASS** — 164 distinct codepoints, 15 source-inherited, **0 introduced by Arabic** |
| `verify_text_fixups.ps1` | **PASS** — 83 rules, 0 stale rules, run after every chunk (DEC-038) |
| `trim_trailing_ws.ps1` | 0 rows trimmed |
| carrier round-trip (`build_carrier_locres_pak.ps1`) | 35/35 scopes, fail 0, unpack byte-identical 35/35 |

Warnings are advisory and triaged:
* **number (93)** — Arabic writes numbers as words (`50` -> خمسين, `3D` -> ثلاثية الأبعاد,
  `17th` -> السابع عشر) or unseparated digits; no defect found on review.
* **length (112)** — Arabic runs longer than 1.6x the English; expected for dialogue/UI, no truncation
  observed in game so far (KI-026 still open).
* **glossary (10)** — sense/form cases only (Terminal x6, Major x3, Upgrade x1), all reviewed (KI-033).

## Installed build

* carrier **p9** `zzz_atomicheart-ar_carrier_koKR_p9_P.pak` — 4,276,477 B,
  sha256 `90d41d78bdd5744ab2cae63980fa7b1376fd3a449c5987fbf9ac143e8f887de0`
* font **p2_plex** `zzz_atomicheart-ar_font_p2_plex_P.pak` — 1,461,408 B,
  sha256 `02b17f31e61a46ddba20bea8c4da5be44164173df608d52697f68d27d8269747`
* manifest `atomic-heart-ar-install-manifest.json` — sha256 `008cc3bcdf51049874090abab635e356996493eb5a12d05c8bc388859cf34578`
* `~mods` holds exactly these 3 files; in-game language stays **Korean**
* rollback: `install_mod.ps1 -Carrier p8 -Font p2_plex`
* p9 is **not yet play-tested** (p7 canal-boat scene remains the last in-game proof)

## Docs

`DECISIONS.md` through DEC-041 · `KNOWN_ISSUES.md` through KI-033 · `ROADMAP.md` ·
`localization\working\batch2\AUTHORING_BRIEF.md` · `glossary\terminology.md` (§1-13) ·
`glossary\glossary.tsv` (pipe-separated accepted renderings, optional `cs` flag) ·
`reports\translation_validation.md`, `reports\carrier_build.md`, `reports\glyph_gate.md`,
`reports\text_fixups_log.md`, `reports\review_sample.md`, `localization\references\AR_EN_REFERENCE.md`
