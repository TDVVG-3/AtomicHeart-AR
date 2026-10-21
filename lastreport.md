# Cycle 016 report - 2026-10-21 14:21

**Outcome:** all text work closed, all warning classes audited, p11 + font v3 rebuilt from
the current master and installed with proof. Remaining items are the in-game A/B verdict
(user) and three Phase 8 blockers with recorded evidence.

## Installed (verified, `VERIFY INSTALL PASS: problems 0`)

- `zzz_atomicheart-ar_carrier_koKR_p11_P.pak` 4,472,812 B
  `0ffd9cb8b3ab5861007689c093c7f3bff761b7b245e5c56cbc5a20cf47def225`
- `zzz_atomicheart-ar_font_p3_unhinted_P.pak` 1,455,228 B
  `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4`
- manifest `c3fe0eba9115a4e7c5c5e8d53c6cb859afd0825c32fb63eb264ba3ef8066d1be`
- before-snapshot `build/snapshots/before_p11_20261021_142031.json`

Rollback: `scripts\switch_variant.ps1 -Variant p10`.

## Text (282 rows changed vs cycle 015)

- C1 tone pass: 125 rules / 212 rows / 25 scopes.
- C2 quote pass: 103 rules / 146 rows (tag-safe guillemets; 74 tag-only rows skipped).
- C3 glossary: 7 rules + accepted renderings; `glossary/glossary_exceptions.tsv` added.
- C3b content fixes: `dire straits`, dropped Major vocatives (2), Comrade consistency (2),
  condensed sentence restored (L7831), Arabic word order for "4-float vector" (6 rows).
- UI-fit: BIOS title labels (3 rows) and "3D model quality" (2 rows) shortened.
- All cycle-016 rules are cell-scoped (`[exact]`); substring bleed was found and repaired
  by reverting to HEAD and reapplying exactly.

## Gates (all green)

| gate | result |
|---|---|
| `verify_text_fixups.ps1` | PASS (85 rules checked, 0 mismatches) |
| `validate_translation.ps1` | PASS, 0 hard errors, 230 warnings (120 number / 110 UI / 0 glossary) |
| `glyph_gate.ps1 -AllowSourceInheritedNonLatin` | PASS, 37 source-inherited, 0 introduced by Arabic |
| `subtitle_timing_audit.ps1` | 537/537 markers identical, 0 mismatches |
| carrier round-trip | 27,617 exact + 1 newline-normalized, 0 failures |

## Warning audits (new this session)

- **Number multiset, 122 -> 120:** all reviewed (`reports/number_warnings_audit.md`),
  0 real losses; Arabic number words/dual/ordinals/separators. One grammar fix, and two
  rows cleared by writing "3D" as a token.
- **UI length, 112 -> 110:** all reviewed (`reports/ui_length_audit.md`); 5 fixed-width
  labels shortened, 107 accepted as normal Arabic expansion.
- **Glossary, 26 -> 0:** accepted variants + 5 data-driven compound exceptions
  (Major League / Major depression / Sergeant Major / terminal branch).

## Coverage

26,022 / 26,022 translatable = **100%**; 1,596 copy-class English-filled;
0 rows needing review. `AR_EN_REFERENCE.md` and `review_sample.md` regenerated from the
current master.

## P1 / P2 / P3

- P1/P2: markers are audio-driven; 537/537 byte-exact; p11 keeps them, p11b slows every cue
  by 15% as the controlled experiment.
- P3: font v3 removes hinting (17 tables, flags 0x0003); v3b restores 1.20 em metrics.
  Latin 95/95, Arabic 42/42 in all faces.
- Decision needs the user-run pass in `reports/ab_test_guide.md`.

## Blocked (evidence in `reports/blocked_items.md`)

- KI-028 `1 //` choice widget: not in any data row; widget-drawn LTR (Phase 8).
- KI-013 DA_Audio 14th culture: 13 cultures in an opaque cooked `Extras` blob.
- KI-018: 248 RU-only assets / 6,012 strings, no Arabic translations exist.

## Safety

Only `Paks\~mods` written; no EXE/DLL/Steam/Denuvo change, no signature bypass, nothing
uploaded, no raw game assets committed. Spec hash verified at start.
Commits: `142fe19`, `7b36514`, `7a92fac`, `10f9f44`.
