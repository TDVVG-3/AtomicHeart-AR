# Glyph gate report (pilot)

Generated: 2026-10-19 20:45:31
Font pak under test: build/package/zzz_atomicheart-ar_font_p2_plex_P.pak -> build/staging/font_p2/modpakfont
Master: C:\AtomicHeart-AR\localization\master\atomic-heart-ar.tsv (21220 rows with Arabic)

VERDICT: **PASS**

Distinct codepoints used by the translated rows: 164
Codepoints missing from the subtitle face: 15
Codepoints missing from the union of all six installed faces: 15
Of those, source-inherited (also present in the English source of the same row): 15
Codepoints newly required by the Arabic and missing from the font: 0
Source-inherited exemption switch: ON (-AllowSourceInheritedNonLatin)

| face | mapped codepoints | missing (pilot chars) | Latin-Basic missing | Cyrillic | Hangul sample |
|---|---|---|---|---|---|
| BlenderPro-Medium (subtitle/dialogue) **(subtitle)** | 1032 | 15 | 0 | 0 | 0 |
| BlenderPro-Book | 1032 | 15 | 0 | 0 | 0 |
| BlenderPro-Bold | 1032 | 15 | 0 | 0 | 0 |
| BrutalType | 1032 | 15 | 0 | 0 | 0 |
| Gotham-Black | 1032 | 15 | 0 | 0 | 0 |
| Gotham-BookItalic | 1032 | 15 | 0 | 0 | 0 |

## Missing codepoints

- U+0410 (source-inherited) first seen in NewP5 key /1C6E001E4D463CC752CA8F90E80A18FF
- U+041A (source-inherited) first seen in NewP5 key /BAEB863F47A0F3CC4AD19488FB83C33C
- U+0445 (source-inherited) first seen in NewP5 key /973BEB76455E2025A20AC0988F20DA2C
- U+202F (source-inherited) first seen in NewP5 key /C963D0654B135C8FA61E1AA345081E80
- U+2060 (source-inherited) first seen in NewP5 key /C963D0654B135C8FA61E1AA345081E80
- U+0435 (source-inherited) first seen in Schebetar_Subs key /7F79D9724D1856FEEE7C9BB106E43C2E
- U+043F (source-inherited) first seen in Triton_dlc3 key DT_Subtitles_DLC03_Triton/Triton_235_Sentences
- U+0440 (source-inherited) first seen in Triton_dlc3 key DT_Subtitles_DLC03_Triton/Triton_235_Sentences
- U+0430 (source-inherited) first seen in Triton_dlc3 key DT_Subtitles_DLC03_Triton/Triton_235_Sentences
- U+0432 (source-inherited) first seen in Triton_dlc3 key DT_Subtitles_DLC03_Triton/Triton_235_Sentences
- U+0438 (source-inherited) first seen in Triton_dlc3 key DT_Subtitles_DLC03_Triton/Triton_235_Sentences
- U+043B (source-inherited) first seen in Triton_dlc3 key DT_Subtitles_DLC03_Triton/Triton_235_Sentences
- U+044C (source-inherited) first seen in Triton_dlc3 key DT_Subtitles_DLC03_Triton/Triton_235_Sentences
- U+043D (source-inherited) first seen in Triton_dlc3 key DT_Subtitles_DLC03_Triton/Triton_235_Sentences
- U+043E (source-inherited) first seen in Triton_dlc3 key DT_Subtitles_DLC03_Triton/Triton_235_Sentences

## Notes

- Scripts: the installed Plex payloads carry Latin-Basic + Arabic. Cyrillic and Hangul are
  served at runtime by the engine fallback face (DroidSansFallback / NotoSansKR-*), which is
  still present in pakchunk0 and was confirmed working in Test 3 (Korean text rendered).
- Tags, placeholders and Latin key names need U+0020..U+007E only, which the subtitle face
  covers completely.

