# Font Research — Atomic Heart (Steam, build 24534183)

Research state labels: CONFIRMED / LIKELY / UNKNOWN (§52).
Evidence: 2026-10-17 via `repak list` (asset discovery); 2026-10-18 **cmap coverage scanned**
with `scripts/font_glyph_scan.ps1` (pure PowerShell TTF/OTF parser, formats 4 + 12).
Full machine report: `reports/font_glyph_coverage.txt` + `reports/font_glyph_coverage.csv`.

## Font asset locations (CONFIRMED)

```
AtomicHeart/Content/Development/UI/Fonts/            (main UI fonts)
AtomicHeart/Content/Development/UI/Fonts/MultiLanguage/
AtomicHeart/Content/Development/UI/Fonts/Noto_Sans_JP/
AtomicHeart/Content/Development/NTD/Fonts/           (notes/terminal font)
AtomicHeart/Content/Core/UI/Fonts/                   (text style DataTable)
```

## Latin base fonts (CONFIRMED present)

| Asset | Style |
|-------|-------|
| Gotham-BookItalic | Italic (NTD/notes) |
| BlenderPro-Book | Regular |
| BlenderPro-Medium | Medium |
| BlenderPro-Bold | Bold |
| Blender_Pro_Heavy | Heavy |
| Blender_Pro_Bold_Italic | Bold Italic |
| BrutalType | Display |
| AH_Pixel_digits | Pixel/digital digits (HUD numerals) |

Each ships as `.uasset` + `.uexp` + `.ufont`, plus a `*_Font.uasset` (Font object) and
`*_DistanceField.uasset` (SDF) in some cases. This is the standard UE4 Slate font setup.

## CJK / multi-script fonts (CONFIRMED present)

- `Noto_Sans_JP/NotoSansJP-{Black,Bold,...}` — Japanese.
- **`MultiLanguage/`** folder:
  - `AnekBangla-Bold` — Bengali (Bangla) script
  - `Sarpanch-Bold` — Devanagari + Latin
  - `Srisakdi-Bold` — Thai script
  - `MultiLanguage_Font.uasset` — a composite/multi-language font object

## Arabic coverage scan results (CONFIRMED, 2026-10-18)

49 font binaries (47 + 2 dupes across Engine/Game paths) were extracted to the gitignored
`source/original/fonts/` and their cmap tables parsed. Highlights:

| Font | Verdict | Detail |
|------|---------|--------|
| **Engine/Content/Slate/Fonts/NotoNaskhArabicUI-Regular.ttf** | **FULL** | 42/42 core letters (U+0621..U+064A), 1,092 Arabic codepoints total — Arabic, Supplement, ExtA, Presentation A+B complete |
| Gotham-BookItalic / Gotham-Black (UI notes font) | NONE | Latin + 170 Cyrillic + Greek |
| BlenderPro (all weights) | NONE | Latin + Cyrillic + Greek |
| BrutalType, TitanOne, AH_Pixel_digits | NONE | Latin only |
| RobotoMono / Roboto (all) | NONE | 1 stray Arabic *presentation* codepoint; zero core letters |
| NotoSansJP/KR/SC, DroidSansFallback | NONE | 64–68 Arabic-block "stray" codepoints (registry symbols/persian-adjacent), zero core letters |
| MultiLanguage: AnekBangla, Sarpanch, Srisakdi | NONE | Bengali / Devanagari / Thai respectively; no Arabic |

### Conclusions (CONFIRMED)

1. **No game UI font renders Arabic.** Every font the game's own UI uses lacks the Arabic
   core letter set. An Arabic UI therefore **requires a font solution** (override or fallback).
2. **A fully Arabic-capable font already ships in the game**: stock UE4 Slate
   `NotoNaskhArabicUI-Regular.ttf` (Noto Naskh Arabic UI, SIL OFL/Apache-licensed by Google).
   It exists in pakchunk0 and can legally be **reused/redirected** — with its license text
   shipped alongside — even though nothing in the game's widgets references it today.
3. The `MultiLanguage/` composite-font hypothesis stands (Bengali/Devanagari/Thai shipped),
   but **Arabic BiDi remains UNKNOWN** until tested in-game.

### Font strategy options for Phase 7/8 (to prototype)

- **Option A (preferred prototype)**: override the FontFace assets for the fonts widgets
  actually use (Gotham/BlenderPro), repointing their bulk data to Arabic-capable glyphs
  (IBM Plex Sans Arabic per §18, or reuse shipped Noto Naskh Arabic UI for first tests).
- **Option B (fallback)**: add Arabic as a fallback face on the existing font objects
  (UE4 CompositeFont / SubFaces chain) so Latin stays native-looking and Arabic falls back.
- Arabic shaping (Naskh) requires the engine text shaper; game ships with shaping for
  complex scripts already (evidence: Bengali/Thai fonts), BiDi untested.
