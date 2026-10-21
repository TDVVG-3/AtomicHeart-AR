# Font A/B evidence - original faces vs Plex v3 / v3b

Date: 2026-10-21 (cycle 016). All numbers below are measured from the shipped payloads and
the built paks, not estimated.

## 1. What the game ships

The six UI faces replaced by the mod are cooked `FontFace` assets. Extracted payloads
(`build/fonts/original`, 6 `.ufont`):

| property | original faces | consequence |
|---|---|---|
| outline format | **CFF / OTF** | glyphs are rendered by the CFF rasterizer |
| hinting tables | **none** (`fpgm`, `prep`, `cvt ` absent) | no TrueType hint program runs on the original text |
| `head.flags` | **0x0003** | bit 3 (force ppem to integer) and bit 4 (instructions may alter advance) are clear |
| units per em | 1000 | - |
| x-height / cap height | 430 / 600 | - |
| hhea / OS/2 typo asc-desc-linegap | 800 / -200 / 200 | line box = **1.20 em** |

## 2. What the previously installed Plex build (v2) shipped

IBM Plex Sans Arabic (OFL 1.1) **TrueType** outlines:

| property | Plex TTF | difference from the original |
|---|---|---|
| tables | 19, including **`fpgm` + `prep`** | a TrueType hint program runs on every glyph |
| `head.flags` | **0x0009** | bit 3 set: ppem forced to integer, hinting interacts with fractional scaling |
| x-height / cap height | 516 / 700 | taller glyphs at the same point size |
| hhea asc-desc-linegap | 1000 / -300 / 250 | line box = **1.50 em** (+25%) |

Two candidate causes for P3 (shimmer while the camera moves) follow directly: the hint
program re-snapping stems at fractional screen sizes, and the taller line box changing how
the widget fits the subtitle.

## 3. v3 - hinting removed (default)

`scripts/strip_font_hinting.ps1` rewrites the sfnt directory and checksums of each weight:

- drops `fpgm` and `prep` (19 -> **17 tables**);
- clears the force-ppem bits: `head.flags` **0x0009 -> 0x0003** (same as the original faces);
- recomputes every table checksum and `head.checkSumAdjustment` (verified valid);
- leaves all glyph outlines, metrics and cmap untouched.

Coverage gate after the transformation (`scripts/probe_font_blocks.ps1`,
`build/fonts/probe_v3.txt`):

| payload | Latin-Basic | Arabic-core | Cyrillic | Hangul |
|---|---|---|---|---|
| Regular / Medium / Bold (unhinted) | 95/95 FULL | 42/42 FULL | 0 | 0 |
| Regular / Medium / Bold (v3b) | 95/95 FULL | 42/42 FULL | 0 | 0 |

Cyrillic and Hangul are absent exactly as in the installed v2 Plex pak (the original
BlenderPro covers Cyrillic, so Cyrillic text inside the master now falls back; the glyph gate
counts 46 source-inherited codepoints - Japanese quote in one DLC4 mail, Cyrillic letters
inside Latin weapon names - and **0 newly required Arabic codepoints**; verdict PASS with the
documented `-AllowSourceInheritedNonLatin` exemption).

## 4. v3b - hinting removed + original vertical metrics (experiment)

Same payloads as v3 plus the original face's vertical metrics written into `hhea` and `OS/2`:

- `hhea` ascender 800, descender -200, lineGap 200;
- `OS/2` typo ascender 800, descender -200, lineGap 200; win ascent 800, descent 200.

Line box therefore returns to **1.20 em** instead of Plex's 1.50 em. Glyph size and shapes are
unchanged, so v3b isolates "line box" from "hinting".

## 5. Built paks (NOT installed except where stated)

| pak | bytes | sha256 | state |
|---|---|---|---|
| `zzz_atomicheart-ar_font_p3_unhinted_P.pak` | 1,455,228 | `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4` | **installed now** with p11 |
| `zzz_atomicheart-ar_font_p3b_linemetrics_P.pak` | 1,455,228 | `ed2659f1ebf29d51411e8ecc08a97c155e24c29b2007c917f66d5afe55d5fd94` | experiment (variant C) |

Both paks: 6 entries (the same six FontFace paths as the v2 pak), round-trip
`repak unpack` payloads byte-identical to the source TTFs, coverage gate passed before packing.

## 6. How to judge it in game

Follow `reports/ab_test_guide.md`, combination A (v3) then C (v3b). The three questions:

1. Does the subtitle shimmer disappear in A compared with the old p10 + Plex v2 set?
2. Does C change the subtitle line spacing / vertical position compared with A?
3. Is any line clipped or pushed off-screen in C (the smaller line box can help or hurt,
   depending on how the widget anchors the text)?

If A fixes the shimmer, v3 stays the default and v3b is only a spacing experiment. If the
shimmer survives in A but disappears in C, adopt v3b's metrics in the default font.
