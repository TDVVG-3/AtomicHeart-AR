# AtomicHeart-AR

Arabic localization for **Atomic Heart** on PC (Steam app `668580`).

This is an open-source, script-driven localization pipeline: it extracts the game's
localization resources read-only, keeps the English source next to the Arabic
translation, validates every change, builds a data-only Korean-slot pak, and installs
only inside `Paks\~mods`. The game executable, DLLs, stock paks, and DRM files are never
modified.

**Repository:** <https://github.com/TDVVG-3/AtomicHeart-AR>
**License:** MIT for the project's own code and documentation. Atomic Heart content
remains the property of Mundfish and its licensors.

This project is maintained as open source under the MIT license. The public repository
is the source of truth for code, documentation, and the translation database; binary
game paks and unlicensed third-party tools are not committed.

## Current release

The current release is **p12** (`p12 + font v3 + tips_x150`).

| component | file | size (bytes) | SHA256 |
| --- | --- | ---: | --- |
| carrier | `zzz_atomicheart-ar_carrier_koKR_p12_P.pak` | 4,470,295 | `910c06f2609237ac021dc1d3e2a6af02a05c64a828efdfe497a711bac66860c3` |
| font | `zzz_atomicheart-ar_font_p3_unhinted_P.pak` | 1,455,228 | `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4` |
| tips | `zzz_atomicheart-ar_tips_x150_P.pak` | 75,853 | `36de01c37231a8b88ec9fc744c4f663bb8461a56adede9a6a2151d78c7ef7fcc` |

Release highlights:

- 27,618 master rows; 27,175 translated-or-copy; 443 untranslated copy-class rows.
- 458 weapon/item names keep their original English spelling; descriptions and
  tooltips remain Arabic. In-sentence names use exact, cell-scoped rules.
- All 1,140 speaker-label rows that used to show `P-3` now show `الرائد`.
- Font v3 covers Arabic and the source-inherited Latin/Cyrillic/Hangul glyphs without
  introducing new missing codepoints.
- `p12g` is an experimental build that repairs H1/H2/H3 subtitle timing patterns. It is
  built and gated but **not installed** by default.
- The VEGA 9 archive scene is documented in `reports/subtitle_stack_audit_p12.md` and
  `reports/subtitle_bottom_bar_p12.md`; `p12g` removes the scene's H3 markerless endings.

The full list of verified paks, including build-only variants, is in `HANDOFF.md`.

## Download and install

1. Download a release from
   <https://github.com/TDVVG-3/AtomicHeart-AR/releases> or build from source (below).
2. Close Atomic Heart.
3. Back up `AtomicHeart\Content\Paks\~mods`.
4. Copy the release paks into:
   `...\Atomic Heart\AtomicHeart\Content\Paks\~mods`
5. Set the game's **Text Language** to **Korean**. The mod replaces the Korean text slot;
   English voice audio is unchanged.
6. To uninstall, remove only the files listed in
   `atomic-heart-ar-install-manifest.json` and restore your backup.

The project never writes outside `Paks\~mods` and never modifies
`AtomicHeart.exe`, DLLs, stock paks, Steam files, or Denuvo components.

## Build from source

Requirements: Windows, PowerShell 5.1, .NET 8, Python 3, and the tools described in
`tools/tools.lock.json`. Third-party tool binaries are not committed and are not
redistributed by this repository.

```powershell
cd C:\AtomicHeart-AR
# Tool setup and verification
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\setup_tools.ps1

# Validate the p12 master, run the glyph gate, and build the carrier
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validate_translation.ps1 -Master build\variants\atomic-heart-ar_p12.tsv
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\glyph_gate.ps1 -PayloadRoot build\staging\font_v3\modpakfont -ReportPath reports\glyph_gate_local.md
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\build_carrier_locres_pak.ps1 -Master build\variants\atomic-heart-ar_p12.tsv -VariantLabel p12
```

The complete build and gate chain is documented in `docs/TOOLCHAIN.md` and
`scripts/p12_gate_all.ps1`. The installed-set switcher, with snapshot, backup,
verification, and automatic rollback, is `scripts/switch_variant.ps1`.

## Repository layout

| path | purpose |
| --- | --- |
| `localization/master/` | canonical English + Arabic translation database |
| `localization/working/` | TM, fixups, keep-original lists, review data |
| `scripts/` | extraction, validation, carrier/font build, install, rollback, audits |
| `reports/` | gate evidence, audits, play-test guide, handoffs |
| `docs/` | format, toolchain, language-selection, and font research |
| `glossary/` | terminology and accepted renderings |
| `config/` | local game paths and build settings |
| `build/` | local build output; not committed |
| `dist/` | local release output; paks not committed |

## Verification

The release gates are reproducible and recorded under `reports/`:

- validator: 0 hard errors for all six p12-family variants;
- coverage: 27,618/27,618 accounted, 27,175 translated-or-copy;
- glyph gate: PASS, 0 Arabic-introduced missing codepoints;
- carrier round-trip: 35/35, unpack byte-identical;
- subtitle audit: H1-H4 counts and 30 worst scenes;
- temp-install and forced-rollback matrix: PASS;
- final install verification: PASS, 0 changes outside `~mods`, stock paks 19/19, EXE
  unchanged.

Start with `reports/p12_gate_all.md`, `reports/install_verification.md`, and
`reports/stack_test_guide.md`.

## Privacy and publishing

This project is released under the MIT license and is intended for public distribution
through <https://github.com/TDVVG-3/AtomicHeart-AR> (DEC-047). The repository contains
project code, documentation, and the translation database. It does **not** contain
Atomic Heart game archives, PAKs, EXEs, DLLs, decrypted game assets, or unlicensed
third-party tools. Build artifacts and the local `build/` directory are ignored.

## Contributing

Contributions are welcome. Read `CONTRIBUTING.md` first. In short:

- never write to the game installation outside `Paks\~mods`;
- never commit game PAKs, EXEs, DLLs, or unlicensed tool binaries;
- keep code, comments, filenames, and script output in English;
- preserve the English source column;
- add translation changes through the fixup/TM workflow, not by hand-editing the master;
- include gate evidence with every behavior change.

## Legal

- Atomic Heart and all related content, names, and trademarks belong to Mundfish and
  its applicable rights holders.
- This is an unofficial fan localization, not an official product.
- The project's own code and documentation are MIT licensed; see `LICENSE`.
- Third-party components and their licenses are listed in `THIRD_PARTY_LICENSES.md`.
- No DRM, Steam authentication, or licensing code is bypassed or modified.
