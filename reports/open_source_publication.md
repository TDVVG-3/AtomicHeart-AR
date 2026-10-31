# Open-source publication - 2026-10-28

**Generated:** 2026-10-28 18:05 +03:00 (updated 2026-10-31 for 1.0.3)
**Target:** <https://github.com/TDVVG-3/AtomicHeart-AR>

## Release 1.0.3 (2026-10-31)

**PUBLISHED.** `v1.0.3` is the next public localization release after `v1.0.0`.
Internal builds `1.0.1` and `1.0.2` were never published as public releases.

| item | value |
| --- | --- |
| repository | <https://github.com/TDVVG-3/AtomicHeart-AR> |
| release | <https://github.com/TDVVG-3/AtomicHeart-AR/releases/tag/v1.0.3> |
| release id | `429808456` |
| tag | `v1.0.3` (annotated object `4cd769ec2b3dd3131a54614348eb06d7584ab323`) |
| tag commit | `36984508ce6408afcab7122d14d73fd6a24db624` |
| main after publication | `29c3407e860b050797867484b4afd3731a8e6f63` |
| published at | 2026-10-31T08:20:32Z |
| draft / prerelease | false / false |
| latest | yes |

### Assets

| asset | bytes | SHA256 (download = GitHub digest) |
| --- | ---: | --- |
| `AtomicHeart-AR-1.0.3-p12.zip` | 2,373,935 | `dd74ab2d01c57fb97cacadc6fe3c8feee63d9426fd24154e336cda2607cb0ad6` |
| `AtomicHeart-AR-1.0.3-p12g-experimental.zip` | 2,377,997 | `071a055bb2928618324846ef3cf12c44f35f31a72b252d2210dec547ab0db6cc` |
| `AtomicHeart-AR-1.0.3-source.zip` | 30,616,979 | `1b3c34aeb94f4bfe9fd4f8287336dec6fdd797bbdf8254336120e872887029f8` |

The p12 archive contains carrier `69475f3548198e23733d833c7e577cf256eed0d875c1bb12f4cac3c2b57c9212`
(4,470,307 bytes), font `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4`
(1,455,228 bytes), and tips `36de01c37231a8b88ec9fc744c4f663bb8461a56adede9a6a2151d78c7ef7fcc`
(75,853 bytes). The p12g archive differs only in its carrier:
`1cc7963d13a6eda77babf1f3617189d1ec2c5153455d16306f67e9e1c8b77dc9` (4,516,381 bytes).

### Publication checks

- Fast-forward push `b5c34b7..29c3407 master -> main`: PASS; no force push.
- Tag push `v1.0.3`: PASS; tag commit verified remotely.
- Release creation and three asset uploads: PASS.
- Re-download of every asset: SHA256 equals `SHA256SUMS.txt` and the GitHub API digest: PASS.
- Arabic release title and Arabic/English body: PASS.
- Latest status: PASS; release `0` and `v1.0.0` unchanged (`0` still has 0 assets, `v1.0.0` still has 3).
- Source archive: 1,555 entries, no PAK/EXE/DLL/game-asset/tool-binary paths, includes 1.0.3 docs.
- Game `Paks\~mods` untouched: carrier `910c06f...`, font `f4ed506...`, tips `36de01c...`, manifest `5b17aaf...`.

## Release 1.0.0 (2026-10-28)

**PUBLISHED.** The source, tag, and p12 Arabic localization release are live on GitHub.

| item | value |
| --- | --- |
| repository | <https://github.com/TDVVG-3/AtomicHeart-AR> |
| source commit | `a0aceee96f67012959e256b0331b901071604c30` |
| tag | `v1.0.0` |
| release | <https://github.com/TDVVG-3/AtomicHeart-AR/releases/tag/v1.0.0> |
| localization asset | `AtomicHeart-AR-1.0.0-p12.zip` |
| experimental asset | `AtomicHeart-AR-1.0.0-p12g-experimental.zip` |
| source asset | `AtomicHeart-AR-1.0.0-source.zip` |

## Downloaded release 1 (before publication)

Release 1 was the GitHub release named **AtomicHeart-AR1**, tag **`0`**, published
2026-10-28 12:46:59 UTC. It had **no uploaded assets**.

The tag archive was downloaded and expanded:

| item | value |
| --- | --- |
| archive | `build/downloads/AtomicHeart-AR_release1_tag0.zip` |
| size | 408 bytes |
| expanded content | one file, `README.md`, 16 bytes |
| assets | none |

The public repository was cloned to `build/github_upstream`; at that point it contained
only the 16-byte placeholder `README.md` and initial commit
`a5085599b49c482bfe8d0966373b394c81300b9d`.

## Published localization package

`AtomicHeart-AR-1.0.0-p12.zip` contains:

| file | bytes | SHA256 |
| --- | ---: | --- |
| `zzz_atomicheart-ar_carrier_koKR_p12_P.pak` | 4,470,295 | `910c06f2609237ac021dc1d3e2a6af02a05c64a828efdfe497a711bac66860c3` |
| `zzz_atomicheart-ar_font_p3_unhinted_P.pak` | 1,455,228 | `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4` |
| `zzz_atomicheart-ar_tips_x150_P.pak` | 75,853 | `36de01c37231a8b88ec9fc744c4f663bb8461a56adede9a6a2151d78c7ef7fcc` |

The zip also contains `README-INSTALL.txt` and `SHA256SUMS.txt`.

Install target:

```text
...\Atomic Heart\AtomicHeart\Content\Paks\~mods
```

Then set **Text Language** to **Korean**. The mod replaces the Korean text slot; English
voice audio is unchanged.

## Open-source preparation

- `README.md` rewritten with release, install, build, verification, privacy, legal, and
  contributing sections.
- `STATUS.md` updated to the p12 release state.
- `CONTRIBUTING.md` expanded for public contributions.
- `CHANGELOG.md` gained a `1.0.0` release section.
- `DECISIONS.md`: DEC-012 marked superseded; DEC-047 records the user-approved
  open-source publication policy.
- `.gitignore` ignores the entire local `build/` directory.
- MIT `LICENSE` retained; third-party and game-content restrictions documented.

The commit contains 175 changed/added files and 85,019 insertions in the main release
commit. It does not contain `build/`, game PAKs, EXEs, DLLs, or unlicensed tool binaries.

## Publication verification

- Source push: PASS (`master:main`, 4 commits)
- Tag push: PASS (`v1.0.0`)
- Release creation: PASS (`426807665`)
- Localization asset upload: PASS (`2,371,883` bytes)
- Experimental p12g asset upload: PASS (`2,377,620` bytes)
- Source archive upload: PASS (`30,447,907` bytes)
- GitHub repository content: source, scripts, localization database, docs, and reports
- Release assets: localization zip + source archive

## Notes

- The public release does not redistribute Atomic Heart game PAKs, EXEs, DLLs,
  decrypted assets, or unlicensed third-party tools.
- Third-party tools remain governed by `THIRD_PARTY_LICENSES.md`.
- The translation database is derived from game text; game content remains the property
  of Mundfish and its licensors.
