# chunk_02 notes — uncertain choices

- `Lorem ipsum` rows (u0565–u0571) -> Arabic paraphrase of the Latin sense ("no one loves pain for its own sake…") — because the source is pseudo-Latin placeholder text; leaving it in Latin verbatim would fail the "no untranslated English" gate, so it was rendered as natural Arabic prose of comparable length.
- `MOB` (u0580) -> حشد — the entry sits in an alphabetical debug-menu list; read as "mob" (crowd / spawn group), not as an acronym.
- `Ergonomics` (u0400) -> الراحة — not in the glossary; chose the player-readable weapon-stat wording over the transliteration "إرغونوميا".
- `Deuteranopia` (u0368) -> عمى الأخضر — descriptive colour-vision term instead of the scientific transliteration, so the option is understandable in a settings list.
- `HDD` (u0472), `DLAA` (u0338), `FHD (1080p)` (u0409), `HD (720p)` (u0471), `Fidelity FX` (u0416), keys `E` (u0378) / `K` (u0537) / `L` (u0544) kept in Latin — display-mode names, technology acronyms and key names.
- `IN USE` (u0385) -> مستخدم — terse status chip; "قيد الاستخدام" would exceed the short label width.
- `Crosshair` (u0319) -> التصويب — length constraint (en 9); "مؤشّر التصويب" is clearer but too long for the label.
- `Gendin` (u0458) -> غيندين, `Drofa` (u0375) -> دروفا, `Krepysh` (u0542) -> كريبيش, `Suslik` (u0444) -> سوسليك — names absent from the glossary; transliterated provisionally (candidates for glossary_questions).
- `ForesterSuslik1Camera1` (u0444) -> كاميرا الحارس سوسليك 1 — internal debug-camera asset name; "Forester" translated (الحارس), "Suslik" transliterated, digits kept.
- `Terminal` (u0333, u0470) -> المحطة الطرفية — glossary form محطة طرفية with the natural definite article (allowed by terminology 4.1).
- `HOLD (tag) TO SKIP` (u0476) — the literal Latin placeholder "(tag)" is kept byte-exact; it is not a rich-text tag.
- `E—response || Q—none` (u0379) — the two em dashes (U+2014) and the `||` separator are kept in the same structural position as the source.
- Trailing spaces preserved on u0567 and u0570 (source rows end with a space); the five-space run between the repeated halves of u0570 is preserved as well.
- camelCase internal identifiers (`DebugGun`, `DecreaseRMBCost`, `GivesArmorOnEnemyKilled`, `Attack hints`, `KilledEnemyCreatesLightnings`, `DoubleBossHealthbar`, …) -> readable Arabic debug-menu labels, since these strings are displayed in the debug/console UI.
