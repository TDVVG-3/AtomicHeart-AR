# UI-length warning audit (cycle 016)

**Date:** 2026-10-21
**Scope:** all 112 `UI length` warnings in `reports/translation_validation.md`
(Arabic longer than 1.2 x English, category UI).
**Data:** `reports/ui_length_review.tsv` (line, scope, EN/AR lengths, ratio, both strings).

## Result

**112 / 112 reviewed. 5 labels shortened, 107 accepted as normal Arabic expansion.**
Arabic needs ~1.2-1.4x the English character count for the same meaning; the threshold
flags every label that exceeds it, so most hits are expected. Ratios after the fix are
1.20-1.77 (the single 1.77 is the proper name "CPSU Central Committee", kept intact).

## Shortened labels (fixed-width UI only)

| rows | before | after | ratio before -> after |
|---|---|---|---|
| 11208 | `أداة BIOS — الاتحاد السوفييتي` | `أداة BIOS السوفييتية` | 2.07 -> 1.57 |
| 11210, 20469 (+1 dup) | `أداة BIOS. الاتحاد السوفييتي. 1954` | `أداة BIOS السوفييتية. 1954` | 1.62 -> 1.24 |
| 12251, 12252 | `جودة المجسّمات ثلاثية الأبعاد` | `جودة المجسّمات 3D` | 1.81 -> 1.31 |

The attributive form `السوفييتية` is now a sanctioned USSR rendering in
`glossary/glossary.tsv` (was flagged once, then accepted as a variant). `3D` stays Latin,
matching the project's handling of `BIOS`, `PEAR`, `LUC-1` and the validator's existing
`3D` rows.

## Not changed (reason)

- Proper names and titles: CPSU Central Committee, H. P. Lovecraft, LUC-1 Rocket Owl,
  Lesnaya Maglev Station - shortening would rename an entity.
- Technical compounds: `Polymeric backplate`, `Relay overload`, `Neuropolymeric maximum` -
  the Arabic is the standard term; the widget must wrap (1.3-1.37x).
- Full sentences in tooltips/help text: they wrap by design (`Out of ammo. Find or craft
  more ammo.` 1.32x).
- Lore quotes (`Man is the only animal that blushes...` 1.35x): content fidelity wins.

## Warning budget after this audit

| class | count | status |
|---|---|---|
| number multiset | 120 | audited: 0 defects (`reports/number_warnings_audit.md`) |
| UI length | 110 | audited: 5 shortened, rest accepted (this file) |
| glossary | 0 | resolved via accepted variants + 5 compound exceptions |
| hard errors | 0 | - |
