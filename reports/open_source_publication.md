# Open-source publication - 2026-10-28

**Generated:** 2026-10-28 18:05 +03:00
**Target:** <https://github.com/TDVVG-3/AtomicHeart-AR>

## Result

**PUBLISHED.** The source, tag, and p12 Arabic localization release are live on GitHub.

| item | value |
| --- | --- |
| repository | <https://github.com/TDVVG-3/AtomicHeart-AR> |
| source commit | `a0aceee96f67012959e256b0331b901071604c30` |
| tag | `v1.0.0` |
| release | <https://github.com/TDVVG-3/AtomicHeart-AR/releases/tag/v1.0.0> |
| localization asset | `AtomicHeart-AR-1.0.0-p12.zip` |
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
- Source archive upload: PASS (`30,447,907` bytes)
- GitHub repository content: source, scripts, localization database, docs, and reports
- Release assets: localization zip + source archive

## Notes

- The public release does not redistribute Atomic Heart game PAKs, EXEs, DLLs,
  decrypted assets, or unlicensed third-party tools.
- Third-party tools remain governed by `THIRD_PARTY_LICENSES.md`.
- The translation database is derived from game text; game content remains the property
  of Mundfish and its licensors.
