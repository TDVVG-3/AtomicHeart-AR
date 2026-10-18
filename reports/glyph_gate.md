# Glyph gate report (pilot)

Generated: 2026-10-18 20:50:47
Font pak under test: build/package/zzz_atomicheart-ar_font_p2_plex_P.pak -> build/staging/font_p2/modpakfont
Master: C:\AtomicHeart-AR\localization\master\atomic-heart-ar.tsv (85 rows with Arabic)

VERDICT: **PASS**

Distinct codepoints used by the translated rows: 113
Codepoints missing from the subtitle face: 0
Codepoints missing from the union of all six installed faces: 0

| face | mapped codepoints | missing (pilot chars) | Latin-Basic missing | Cyrillic | Hangul sample |
|---|---|---|---|---|---|
| BlenderPro-Medium (subtitle/dialogue) **(subtitle)** | 1032 | 0 | 0 | 0 | 0 |
| BlenderPro-Book | 1032 | 0 | 0 | 0 | 0 |
| BlenderPro-Bold | 1032 | 0 | 0 | 0 | 0 |
| BrutalType | 1032 | 0 | 0 | 0 | 0 |
| Gotham-Black | 1032 | 0 | 0 | 0 | 0 |
| Gotham-BookItalic | 1032 | 0 | 0 | 0 | 0 |

## Notes

- Scripts: the installed Plex payloads carry Latin-Basic + Arabic. Cyrillic and Hangul are
  served at runtime by the engine fallback face (DroidSansFallback / NotoSansKR-*), which is
  still present in pakchunk0 and was confirmed working in Test 3 (Korean text rendered).
- Tags, placeholders and Latin key names need U+0020..U+007E only, which the subtitle face
  covers completely.

