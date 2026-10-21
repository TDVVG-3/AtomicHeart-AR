# Number-multiset warning audit (cycle 016)

**Date:** 2026-10-21
**Scope:** all 122 `number multiset differs` warnings in `reports/translation_validation.md`.
**Method:** every warning row was exported with its English and Arabic cell to
`reports/number_warnings_review.tsv` and reviewed one by one.

## Result

**122 / 122 reviewed - 0 real number losses.** The validator compares digit tokens only;
Arabic writes numbers as words, uses dual forms, ordinals, and local separators, so the
warning is a false positive by design. One unrelated grammar issue found during the review
was fixed (see below).

## Classification

| class | rows | example |
|---|---|---|
| Arabic number words (1-99, hundreds, thousands) | ~75 | L22680 `24 hours` -> `الساعات الأربع والعشرين` |
| dual form (2) / ordinals | ~12 | L21951 `2 rounds` -> `طلقتين`; L22944 `June 19th` -> `التاسع عشر` |
| thousands separators removed (Arabic style) | 6 | L21648 `1,850 t` -> `1850 طناً`; L26869 `2,500` -> `2500` |
| zero-padded call signs / labels | 20 | L19789 `PEAR #2` -> `PEAR 02` (deliberate in-game call-sign style) |
| marker timestamps / tags | 4 | L286 `*0.09*` etc.; L20045 `&Professor&` |
| compound adjectives | 6 | L20235 `4-float vector` -> `متجه الأعداد العشرية الأربعة` |
| date ordinals | 2 | L26986 `March 1` -> `الأول من مارس` |

The Arabic-number-word mapping was checked by hand against the digit multiset: e.g.
`50` -> `خمسين` (L27191), `25` -> `خمسة وعشرين` (L22929), `30` -> `الثلاثين` (L23082-84),
`100` -> `المئة` (L7690), `80,000` -> `80 ألف` (L2547).

## Fix applied

| row(s) | before | after | reason |
|---|---|---|---|
| 20235, 20236, 20432-20435 | `متجه الأربعة أعداد العشرية` | `متجه الأعداد العشرية الأربعة` | correct Arabic word order for "4-float vector" |

`tm_fixups.tsv` rule: one global rule, applied to 6 rows; `verify_text_fixups.ps1` PASS.

## Remaining warning budget

After this audit and the glossary work, `reports/translation_validation.md` reports
**0 hard errors**, 122 number warnings (this document: informational only), 112 UI-length
warnings (Arabic is longer than English; reviewed via `reports/ui_longest_labels.md`),
and **0 glossary warnings** (26 resolved by accepted-variant entries plus 5 data-driven
compound exceptions).
