# STATUS — Atomic Heart Arabic localization (English-sourced, text only)

**As of:** 2026-10-20 23:41 +03:00 · cycle 015 closed · Steam app 668580

## Headline

| metric | value |
|---|---|
| coverage of all rows | **26,022 of 27,618 (94.22%)** |
| coverage of translatable rows | **26,022 of 26,022 (100%)** |
| tier 1 (25% = 6,905) | DONE |
| tier 2 (50% = 13,809) | DONE |
| tier 3 (75% = 20,714) | DONE |
| tier 4 (100% = 27,618) | DONE for translatable rows — batch 4 finished |
| remaining rows | 1,596 copy-class rows (identifiers, numbers, placeholders, proper names), English-filled by design |
| rows needing review | 0 |
| next unauthored plan id | none — all 15,824 ids authored (b0001–b15824) |

## Master, TM and plan

| item | value |
|---|---|
| master | `localization\master\atomic-heart-ar.tsv`, 27,618 rows × 13 cols, 26,022 Arabic (status DRAFT), 1,596 UNTRANSLATED copy-class |
| TM | `localization\working\tm.tsv`, 19,733 entries (line 1 is the header `english/arabic/source`) |
| work order | `localization\working\batch2\plan_unique.tsv`, 15,824 ids (game-progression order), fully authored |
| authoring chunks applied | 0002–0015 (cycle 013), 0016–0038 (cycle 014), **0039–0054 (cycle 015)** |
| copy-class accounting | `reports\coverage_cycle015.md` (reasons) and `reports\english_filled_rows.tsv` (all 1,596 rows) |

## Gates (last run, this cycle)

| gate | result |
|---|---|
| `validate_translation.ps1` | **PASS** — 27,618 rows, 26,022 translated, **0 errors**, 259 warnings (number 122 / length 112 / glossary 25) |
| `glyph_gate.ps1 -AllowSourceInheritedNonLatin` | **PASS** — 195 distinct codepoints, 46 source-inherited, **0 introduced by Arabic** |
| `verify_text_fixups.ps1` | **PASS** — 87 rules, integrity 85 rows, 0 mismatches, 0 English missing from TM (DEC-038) |
| `trim_trailing_ws.ps1` | 0 rows trimmed |
| carrier round-trip (`build_carrier_locres_pak.ps1`) | 35/35 scopes, 27,617 exact + 1 newline-normalised, **fail 0** |
| `verify_install.ps1` | **PASS** — 0 problems, expected file set |

Warnings are advisory and triaged:
* **number (122)** — Arabic writes numbers as words (`fifty`, `80 ألف`) or uses unseparated digits, and
  the checker counts timing markers separately; a sample with and without digits showed no lost or
  altered number.
* **length (112)** — Arabic longer than 1.2x the English; expected for dialogue, glossary-mandated
  terms and documents. UI length evidence: `reports\ui_length_watch.md` (KI-026).
* **glossary (25)** — sense/form cases only (Terminal 7, Major 6, Phasotron 2, Comrade 2, Upgrade 2,
  Argentum 1, Snowball 1, Archive 1, Neuropolymer 1, Professor 1, Doctor 1), all reviewed (KI-033).

## Installed build

* carrier **p10** `zzz_atomicheart-ar_carrier_koKR_p10_P.pak` — 4,473,788 B,
  sha256 `7fbed3a87fafb547ecf4a2557a590ae0d7c05da304a3c7f6facb7bb34ef49393`
* font **p2_plex** `zzz_atomicheart-ar_font_p2_plex_P.pak` — 1,461,408 B,
  sha256 `02b17f31e61a46ddba20bea8c4da5be44164173df608d52697f68d27d8269747`
* manifest `atomic-heart-ar-install-manifest.json` — sha256 `c34ac3a148c120a8d1a914641a2f5a91f2a1736d19d4ef7f43ac40867638d474`
* `~mods` holds exactly these 3 files; in-game language stays **Korean**
* rollback: `install_mod.ps1 -Carrier p9 -Font p2_plex`
* p10 is **not yet play-tested** (p7 canal-boat scene remains the last in-game proof)

## Docs

`DECISIONS.md` through DEC-046 · `KNOWN_ISSUES.md` through KI-036 · `ROADMAP.md` ·
`localization\working\batch2\AUTHORING_BRIEF.md` · `glossary\terminology.md` (§1-13) ·
`glossary\glossary.tsv` (pipe-separated accepted renderings, optional `cs` flag) ·
`reports\cycle015_results.md` · `reports\coverage_cycle015.md` · `reports\english_filled_rows.tsv` ·
`reports\ui_length_watch.md` · `reports\review_sample.md` · `reports\translation_validation.md` ·
`reports\carrier_build.md` · `reports\install_verification.md` · `reports\glyph_gate.md` ·
`reports\text_fixups_log.md` · `localization\references\AR_EN_REFERENCE.md`
