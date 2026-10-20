# ROADMAP — Atomic Heart Arabic localization

**As of:** 2026-10-20 (cycle 015) · coverage **26,022 / 27,618 (94.22%)** · **100% of translatable rows**

## Milestones

| # | milestone | target | state |
|---|---|---|---|
| 1 | repo + tooling + extraction contract (text only, read-only game) | — | DONE (cycle 001-006) |
| 2 | master DB seeded from en-US, 27,618 rows / 19,996 unique | 100% rows | DONE |
| 3 | batch 1 (UI/menus/settings) | 25% (6,905 rows) | DONE (cycle 012) |
| 4 | dual-script font v2 + carrier slot ko-KR + in-game proof | playable | DONE (cycle 013, p7 confirmed in game) |
| 5 | batch 2 (lore/dialogue, game-progression order) | 50% (13,809) | DONE (cycle 013) |
| 6 | batch 3 (DLC scopes, NTD, subtitles, remaining UI) | 75% (20,714) | DONE (cycle 014, 76.83%) |
| 7 | batch 4 — remaining strings | 100% of translatable | **DONE (cycle 015)** — 26,022 of 26,022 translatable; 1,596 copy-class rows by design |
| 8 | final carrier p10, install, close-out | shipped | **carrier p10 installed and verified (2026-10-20)**; play-test sweep pending |
| 9 | Phase 8 residuals | — | OPEN, needs the user's go-ahead |

## Milestone 7 — batch 4 (closed)

* 16 chunks (0039–0054), ids b11109–b15824, 4,716 ids, **4,802 rows filled**, TM 15,410 → 19,733.
* Per-chunk chain held: gate → apply → `verify_text_fixups.ps1` → validator → glyph gate → trim.
* Two tooling defects were found and fixed while closing: the applier skipped the first entry of every
  headerless chunk file (DEC-042 / KI-034, all chunks replayed), and three glossary drifts plus one
  leaked debug row were corrected (DEC-046).
* Copy-class rows stay untranslated with an empty Arabic cell and are listed with a reason in
  `reports\english_filled_rows.tsv`.

## Milestone 8 — close-out (installed; play-test pending)

* Carrier `zzz_atomicheart-ar_carrier_koKR_p10_P.pak` built (4,473,788 B,
  sha256 `7fbed3a87fafb547ecf4a2557a590ae0d7c05da304a3c7f6facb7bb34ef49393`), installed with font
  `p2_plex`, snapshot proof PASS, 3 files in `~mods`, rollback `install_mod.ps1 -Carrier p9 -Font p2_plex`.
* `localization\references\AR_EN_REFERENCE.md` regenerated (6,988,783 B, 26,022 rows, 19,732 unique).
* `reports\review_sample.md` regenerated: 40 rows = 10 long dialogue / 10 short UI / 10 tagged /
  10 edge cases (DEC-045).
* Play-test sweep still to do: menus, HUD, a Vavilov/VDNKh scene, a DLC2 cutscene, an NTD sign,
  GameTips (KI-009), subtitle clip-vs-scroll (KI-022), UI fit (KI-026).

## Milestone 9 — Phase 8 residuals (not authoring, not started)

| item | issue | note |
|---|---|---|
| native Arabic language list | KI-013 | needs `DA_Audio` schema tooling |
| 248 RU-only cooked dialogue assets / 6,012 strings (incl. `DT_Subtitles_*`) | KI-018 | needs a uasset decision; currently out of scope |
| `NotLifted_17` obfuscated | KI-017 | blocked, evidence only |
| GameTips popups | KI-009 | untested |
| subtitle clip-vs-scroll | KI-022 | untested |
| UI fit in game | KI-026 | untested; evidence in `reports\ui_length_watch.md` (1,019 labels > 40 chars, longest 199) |
| choice number/separator `1 //` left of Arabic | KI-028 | cosmetic widget LTR, needs a UI asset edit |
| `<...>`-lookalike text stays Latin | KI-031 | 1 row, e.g. `<- ALCOHOL ->` |
| en-US vs ru-RU asset divergences | KI-032 | policy: English master is the anchor |
| glossary sense/form warnings | KI-033 | 25, reviewed and kept |
| straight quotes instead of guillemets | KI-035 | 220 rows, tag-safe pass needed |
| label candidates sweep | KI-027 | 2,588 single-occurrence name-like values still uncurated |
| p10 in-game proof | KI-036 | installed, not played |

## Standing rules that shape the plan

* Text only: no media extraction, no raw game assets committed, game folder read-only except `~mods`.
* Nothing uploaded; local git only. No installs beyond the approved carrier/font chain.
* Arabic never in a `.ps1`; keep names/P-3/PEAR/VOV-A6 Latin where the glossary says so.
* Coverage is always reported as "N of 27,618 (X%)" plus "N of translatable (X%)"; RU-only strings go
  to `reports\dialogue_ru_only.md` (KI-010), never into the English column.
* No Phase 8 work (native `ar`, RU-only assets, choice numbering) before the user decides.
