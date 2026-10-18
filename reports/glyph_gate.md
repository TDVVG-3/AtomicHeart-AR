# Glyph gate report (pilot)

Generated: 2026-10-19 00:42:14
Font pak under test: build/package/zzz_atomicheart-ar_font_p2_plex_P.pak -> build/staging/font_p2/modpakfont
Master: C:\AtomicHeart-AR\localization\master\atomic-heart-ar.tsv (7387 rows with Arabic)

VERDICT: **PASS**

Distinct codepoints used by the translated rows: 148
Codepoints missing from the subtitle face: 5
Codepoints missing from the union of all six installed faces: 5
Of those, source-inherited (also present in the English source of the same row): 5
Codepoints newly required by the Arabic and missing from the font: 0
Source-inherited exemption switch: ON (-AllowSourceInheritedNonLatin)

| face | mapped codepoints | missing (pilot chars) | Latin-Basic missing | Cyrillic | Hangul sample |
|---|---|---|---|---|---|
| BlenderPro-Medium (subtitle/dialogue) **(subtitle)** | 1032 | 5 | 0 | 0 | 0 |
| BlenderPro-Book | 1032 | 5 | 0 | 0 | 0 |
| BlenderPro-Bold | 1032 | 5 | 0 | 0 | 0 |
| BrutalType | 1032 | 5 | 0 | 0 | 0 |
| Gotham-Black | 1032 | 5 | 0 | 0 | 0 |
| Gotham-BookItalic | 1032 | 5 | 0 | 0 | 0 |

## Missing codepoints

- U+0410 (source-inherited) first seen in NewP5 key /1C6E001E4D463CC752CA8F90E80A18FF
- U+041A (source-inherited) first seen in NewP5 key /BAEB863F47A0F3CC4AD19488FB83C33C
- U+0445 (source-inherited) first seen in NewP5 key /973BEB76455E2025A20AC0988F20DA2C
- U+202F (source-inherited) first seen in NewP5 key /C963D0654B135C8FA61E1AA345081E80
- U+2060 (source-inherited) first seen in NewP5 key /C963D0654B135C8FA61E1AA345081E80

## Notes

- Scripts: the installed Plex payloads carry Latin-Basic + Arabic. Cyrillic and Hangul are
  served at runtime by the engine fallback face (DroidSansFallback / NotoSansKR-*), which is
  still present in pakchunk0 and was confirmed working in Test 3 (Korean text rendered).
- Tags, placeholders and Latin key names need U+0020..U+007E only, which the subtitle face
  covers completely.

