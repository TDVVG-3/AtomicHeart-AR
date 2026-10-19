# ROADMAP — Atomic Heart Arabic localization

**As of:** 2026-10-19 (cycle 014) · coverage **21,220 / 27,618 (76.83%)**

## Milestones

| # | milestone | target | state |
|---|---|---|---|
| 1 | repo + tooling + extraction contract (text only, read-only game) | — | DONE (cycle 001-006) |
| 2 | master DB seeded from en-US, 27,618 rows / 19,996 unique | 100% rows | DONE |
| 3 | batch 1 (UI/menus/settings) | 25% (6,905 rows) | DONE (cycle 012) |
| 4 | dual-script font v2 + carrier slot ko-KR + in-game proof | playable | DONE (cycle 013, p7 confirmed in game) |
| 5 | batch 2 (lore/dialogue, game-progression order) | 50% (13,809) | DONE (cycle 013) |
| 6 | batch 3 (DLC scopes, NTD, subtitles, remaining UI) | 75% (20,714) | DONE (cycle 014, 76.83%) |
| 7 | batch 4 — remaining strings | 100% (27,618) | NEXT (6,398 rows; chunks 0039+) |
| 8 | final carrier p10, full play-test sweep, close-out | shipped | pending |
| 9 | Phase 8 residuals (belown) | — | open |

## Milestone 7 — batch 4 plan

* Source: `localization\working\batch2\plan_unique.tsv`, next id **b11109** (chunks 0039 …).
* 300 ids per chunk in plan order; sheets via
  `scripts\batch2_sheet.ps1 -ChunkId NNNN -StartId bNNNN -Count 300`.
* Per chunk: `batch2_chunk.ps1` (gate) -> `batch2_apply.ps1` (fills empty cells) ->
  `verify_text_fixups.ps1` (DEC-038) -> `validate_translation.ps1` -> `glyph_gate.ps1`
  -> `trim_trailing_ws.ps1`; save resumable progress each time.
* Expected yield ~320 rows per chunk; ~20 chunks to finish.
* Copy-class rows stay untranslated with an empty Arabic cell.

## Milestone 8 — close-out

* Build `zzz_atomicheart-ar_carrier_koKR_p10_P.pak`, install with font `p2_plex`, snapshot proof
  (3 files, SHA256, manifest) and keep the rollback note.
* Regenerate `localization\references\AR_EN_REFERENCE.md` and `reports\review_sample.md`.
* Play-test sweep: menus, HUD, a Vavilov/VDNKh scene, a DLC2 cutscene, GameTips (KI-009),
  subtitle clip-vs-scroll (KI-022), UI fit (KI-026).

## Milestone 9 — Phase 8 residuals (not authoring)

| item | issue | note |
|---|---|---|
| native Arabic language list | KI-013 | needs `DA_Audio` schema tooling |
| 248 RU-only cooked dialogue assets / 6,012 strings (incl. `DT_Subtitles_*`) | KI-018 | needs a uasset decision; currently out of scope |
| `NotLifted_17` obfuscated | KI-017 | blocked, evidence only |
| GameTips popups | KI-009 | untested |
| subtitle clip-vs-scroll | KI-022 | untested |
| UI fit in game | KI-026 | untested beyond the canal-boat scene |
| choice number/separator `1 //` left of Arabic | KI-028 | cosmetic widget LTR, would need a UI asset edit |
| `<...>`-lookalike text stays Latin | KI-031 | 1 row, e.g. `<- ALCOHOL ->` |
| en-US vs ru-RU asset divergences | KI-032 | policy: English master is the anchor |
| glossary sense/form warnings | KI-033 | 10, reviewed and kept |
| label candidates sweep | KI-027 | 2,588 single-occurrence name-like values still uncurated |

## Standing rules that shape the plan

* Text only: no media extraction, no raw game assets committed, game folder read-only except `~mods`.
* Nothing uploaded; local git only. No installs beyond the approved carrier/font chain.
* Arabic never in a `.ps1`; keep names/P-3/PEAR/VOV-A6 Latin where the glossary says so.
* Coverage is always reported as "N of 27,618 (X%)". RU-only strings go to
  `reports\dialogue_ru_only.md` (KI-010), never into the English column.
