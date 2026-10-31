# Status - Atomic Heart Arabic localization

## Localization release 1.0.3 (public)

- First public release after `1.0.0`; builds `1.0.1` and `1.0.2` remain internal and were never published.
- Stable `p12` carrier rebuilt with eight Arabic corrections: 4,470,307 bytes, SHA256 `69475f3548198e23733d833c7e577cf256eed0d875c1bb12f4cac3c2b57c9212`.
- Experimental `p12g` carrier keeps the `1.0.0` timing behavior plus the same corrections: 4,516,381 bytes, SHA256 `1cc7963d13a6eda77babf1f3617189d1ec2c5153455d16306f67e9e1c8b77dc9`.
- Font and tips payloads are unchanged: `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4` and `36de01c37231a8b88ec9fc744c4f663bb8461a56adede9a6a2151d78c7ef7fcc`.
- Gates: trim 0 changes, validator PASS, glyph PASS, fixup verifier PASS (124 cell rules applied, 3 documented no-ops), timing audit 537/537, carrier round-trip 35/35, `p12_gate_all.ps1` PASS for all six variants.
- Release assets: `AtomicHeart-AR-1.0.3-p12.zip`, `AtomicHeart-AR-1.0.3-p12g-experimental.zip`, `AtomicHeart-AR-1.0.3-source.zip`.
- The local installed `Paks\~mods` set was left untouched at the previously verified p12 hashes.
- See [1.0.3 release notes](docs/releases/v1.0.3.md).

## Installer 1.0.2 (internal build)

- Windows WPF and Linux Avalonia applications share the verified installation engine.
- Stable payload rebuilt with eight Arabic text corrections; all 35 contained assets round-trip verified.
- Approved p12 upgrades retain transaction backups; unknown files and conflicting carriers are refused.
- AppImage includes .NET, translation payload and license notices. Ubuntu 22.04 x86_64 is the CI baseline.
- Final CI passed: 27 Windows safety checks, 31 Linux safety checks, 18 display-tool regressions, and a packaged AppImage GUI render. Build: [40843554060](https://github.com/exelight7/AtomicHeart-AR/actions/runs/40843554060).
- See [1.0.2 release notes](docs/releases/v1.0.2.md) for build results and historical publication status.
- Game rendering and Steam Deck hardware testing remain outstanding; experimental p12g is excluded.

## Windows installer 1.0.1 (historical)

- Arabic desktop application source is under `app/`; the full package includes the approved p12 payload from upstream release `v1.0.0`.
- Installer verification: 20 safety checks passed, including install/verify/uninstall with the official payload in a fake game directory.
- Application packaging: `scripts/package_installer.ps1` builds a self-contained Windows x64 ZIP and a SHA256 sidecar.
- Upstream 1.0.1 publication is pending repository write access. Real game execution and visual Arabic rendering were not tested during app development.
- Legacy PowerShell translation/build tools keep their separate historical validation status; the desktop app uses its own installer engine.

**As of:** 2026-10-31 (local build, gates and publication)
**Release:** 1.0.3 p12 (`p12 + font v3 + tips_x150`)
**Game:** Atomic Heart, Steam app `668580`, build `24534183`

## Current release

| metric | value |
| --- | ---: |
| master rows | 27,618 |
| translated or copy-covered | 27,175 |
| Arabic rows | 26,717 |
| COPY (original English name) rows | 458 |
| untranslated copy-class rows | 443 |
| P-3 speaker-label rows changed to `الرائد` | 1,140 |
| in-sentence item-name rows changed | 123 |
| validator hard errors (p12) | 0 |
| validator warnings (p12) | 296 |

## Installed set

The release default is:

- `zzz_atomicheart-ar_carrier_koKR_p12_P.pak`
- `zzz_atomicheart-ar_font_p3_unhinted_P.pak`
- `zzz_atomicheart-ar_tips_x150_P.pak`
- `atomic-heart-ar-install-manifest.json`

`Paks\~mods` contains exactly these four files. The game language stays **Korean**; the
carrier fills the Korean text slot. Install verification is **PASS**: 0 changes outside
`~mods`, stock paks 19 before / 19 after, `AtomicHeart.exe` unchanged.
The machine used to build 1.0.3 was intentionally left on the previously verified
`1.0.0` p12 set: carrier `910c06f2609237ac021dc1d3e2a6af02a05c64a828efdfe497a711bac66860c3`,
font `f4ed506…`, tips `36de01c…`, manifest `5b17aaf4…`.

## Gates

| gate | result |
| --- | --- |
| validator, six p12 variants | PASS, 0 hard errors |
| coverage | PASS, 27,618/27,618 accounted |
| glyph gate, font v3 | PASS, 0 Arabic-introduced missing codepoints |
| carrier round-trip | 35/35, unpack byte-identical |
| subtitle stack audit | PASS, H1-H4 report written |
| temp install / forced rollback | PASS for p12 family, tips, RU-only |
| final install verification | PASS |

## Built but not installed

`p12g`, `p12c`, `p12e`, `p12f`, `p12ef`, and all RU-only combinations are built and gated
but **not installed**. Only the p12 default is approved for the current install. See
`HANDOFF.md` for SHA256s and exact switch/rollback commands.

## Known limitations

- H1m/H1k/H4 are stock DataTable-level conditions; a locres-only pak cannot repair them.
- 197 non-monotonic H1 tracks were left byte-exact.
- 343 H3 rows remain because no clip duration is available.
- Absolute DataTable row start offsets are unavailable; cross-line timing uses clip and
  reading-speed caps.
- The bottom-bar cut can remain when four lines are visible; `p12g` reduces concurrency
  duration but does not change the 150 px layout. The exact clip owner is `UNKNOWN`.

## Evidence

Start with:

- `reports/p12_gate_all.md`
- `reports/p12_master.md`
- `reports/install_verification.md`
- `reports/subtitle_stack_audit_p12.md`
- `reports/subtitle_stack_audit_p12g.md`
- `reports/subtitle_bottom_bar_p12.md`
- `reports/stack_test_guide.md`
- `HANDOFF.md`
