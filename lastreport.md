# Cycle 016 report - 2026-10-21

**Outcome:** p11 (text passes) + font v3 installed and verified; p11b (timing) and v3b
(line metrics) built as A/B experiments; every remaining Workstream C item either done or
logged with evidence.

## Installed (verified, `VERIFY INSTALL PASS`)

- `zzz_atomicheart-ar_carrier_koKR_p11_P.pak` 4,472,842 B
  `94fc9d4a8ef1ae676a9da440dd131a1419557058b9f122a2b55413e8c618e1f7`
- `zzz_atomicheart-ar_font_p3_unhinted_P.pak` 1,455,228 B
  `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4`
- manifest `9e98e085755dbd55ed4b9331f77b7c0071a9bc060948434f9681102c550f6d26`

Rollback: `scripts\switch_variant.ps1 -Variant p10`.

## Text (267 rows changed vs cycle 015)

- C1 tone pass: 125 rules / 212 rows / 25 scopes (`reports/tone_pass.md`).
- C2 quote pass: 103 rules / 146 rows (tag-safe guillemets).
- C3 glossary: 7 rules (Upgrade noun/verb, polymeric upgrades, transformative upgrades).
- C3b content fix: line 23237 `dire straits` (was "copper pipes") + an intruding Russian word.
- All new rules are cell-scoped (`[exact]`), so short finds cannot bleed into other rows.
  Found and repaired during the pass by reverting to HEAD and reapplying exactly.
- `verify_text_fixups.ps1` PASS, `validate_translation.ps1` PASS (0 hard errors),
  `glyph_gate.ps1` PASS (`-AllowSourceInheritedNonLatin`, 0 newly required Arabic),
  `subtitle_timing_audit.ps1` 0 mismatches (537/537 marker rows byte-exact).

## Timing (P1/P2)

Mechanism proven from data: subtitle lifetime is native/audio-driven (8,853 rows with VO
markers, Duration=0, Priority=0); the master keeps all 537 English marker multisets/values
byte-exact. Official cultures do retime/drop markers, so p11b (uniform x1.15 cue length) is
the controlled in-game experiment. Verdict pending.

## Font (P3)

Original faces: CFF, no fpgm/prep, head.flags 0x0003, line box 1.20 em.
Old Plex v2: TTF, fpgm+prep, flags 0x0009, 1.50 em.
v3 = hinting removed (17 tables, flags 0x0003); v3b = v3 + original vertical metrics.
Latin 95/95, Arabic 42/42, round-trip byte-identical.

## Coverage

27,618 rows | 26,022 Arabic | 1,596 copy-class | 26,022/26,022 translatable (100%) |
0 review-needed. Reports: `reports/coverage_cycle016.md`, `english_filled_rows.tsv`,
`ui_longest_labels.md`, `localization/references/AR_EN_REFERENCE.md`.

## Workstream C

- C4 reclassified: the 2,588 "name-like" values are UI/lore strings; 2,519 already
  translated, 69 technical ids kept Latin; the 2 CHAR-les rows are deliberate Latin reveals;
  no DLC4 defect.
- C5 (KI-028): BLOCKED - the `1 //` prefix is widget-drawn, not in any data row.
- C6 (KI-018): BLOCKED - 248 RU-only assets / 6,012 strings, no Arabic translations yet.
- C7 (KI-013): BLOCKED - 13 cultures live in an opaque cooked `Extras` blob; unsafe rewrite.
- C8: done (coverage, English list, 30 longest UI labels, reference, 40-row sample).

Details and evidence: `reports/blocked_items.md`; A/B instructions: `reports/ab_test_guide.md`;
entry point: `HANDOFF.md`.
