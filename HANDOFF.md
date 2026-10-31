# HANDOFF - Atomic Heart Arabic localization - 1.0.3 published

**Generated:** 2026-10-31 11:24:54 +03:00
**State:** `v1.0.3` is published on GitHub as the next public release after `1.0.0`.
Internal builds `1.0.1` and `1.0.2` were never published.
**Installed state:** the game's `Paks\~mods` was intentionally **not** changed by this
release work. It still contains the previously verified p12 set (carrier `910c06f...`).
**Write scope:** source tree, docs, reports, Git refs, and GitHub release assets only.
No game file, EXE, DLL, stock PAK, Steam file, Denuvo file, or installed mod was modified.
No token or password is written anywhere in the repository or this handoff.

## 1. Publication record

| item | value |
| --- | --- |
| repository | <https://github.com/TDVVG-3/AtomicHeart-AR> |
| release | <https://github.com/TDVVG-3/AtomicHeart-AR/releases/tag/v1.0.3> |
| release id | `429808456` |
| tag | `v1.0.3` (annotated object `4cd769ec2b3dd3131a54614348eb06d7584ab323`) |
| tag commit | `36984508ce6408afcab7122d14d73fd6a24db624` |
| main | `git rev-parse HEAD` at handoff commit (fast-forward from `b5c34b7`) |
| published at | 2026-10-31T08:20:32Z (11:20:32 +03:00) |
| draft / prerelease | false / false |
| latest | yes |
| old release `0` | unchanged, id `426659009`, 0 assets |
| old release `v1.0.0` | unchanged, id `426807665`, 3 assets |

The push was fast-forward only: `b5c34b7..29c3407 master -> main`. No force push and no
history rewrite was used. The tag commit is the source of all three release assets; a
follow-up main commit records the source ZIP hash, and this handoff is a later commit.

## 2. Release assets (verified after download)

| asset | bytes | SHA256 (GitHub digest matches) |
| --- | ---: | --- |
| `AtomicHeart-AR-1.0.3-p12.zip` | 2,373,935 | `dd74ab2d01c57fb97cacadc6fe3c8feee63d9426fd24154e336cda2607cb0ad6` |
| `AtomicHeart-AR-1.0.3-p12g-experimental.zip` | 2,377,997 | `071a055bb2928618324846ef3cf12c44f35f31a72b252d2210dec547ab0db6cc` |
| `AtomicHeart-AR-1.0.3-source.zip` | 30,616,979 | `1b3c34aeb94f4bfe9fd4f8287336dec6fdd797bbdf8254336120e872887029f8` |

Each game archive contains `README-INSTALL.txt`, `SHA256SUMS.txt`, and three PAKs.
Payload hashes:

| payload | bytes | SHA256 |
| --- | ---: | --- |
| `zzz_atomicheart-ar_carrier_koKR_p12_P.pak` | 4,470,307 | `69475f3548198e23733d833c7e577cf256eed0d875c1bb12f4cac3c2b57c9212` |
| `zzz_atomicheart-ar_carrier_koKR_p12g_P.pak` | 4,516,381 | `1cc7963d13a6eda77babf1f3617189d1ec2c5153455d16306f67e9e1c8b77dc9` |
| `zzz_atomicheart-ar_font_p3_unhinted_P.pak` | 1,455,228 | `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4` |
| `zzz_atomicheart-ar_tips_x150_P.pak` | 75,853 | `36de01c37231a8b88ec9fc744c4f663bb8461a56adede9a6a2151d78c7ef7fcc` |

The source archive has 1,555 entries, no PAK/EXE/DLL/game-asset/tool-binary paths, and
includes the 1.0.3 docs and READMEs.

## 3. What changed in 1.0.3

- Eight Arabic text corrections since `1.0.0`: white-weapon naming, two subject-verb
  fixes, robot plural agreement, `Secateur` and in-sentence item names, wish-tooltip
  phrasing, and a weakness label.
- The stable `p12` carrier was rebuilt from the corrected master. Its size changed from
  4,470,295 to 4,470,307 bytes and its hash from `910c06f...` to `69475f...`.
- The experimental `p12g` carrier keeps the `1.0.0` timing behavior and adds only the
  same eight corrections. Size changed from 4,516,369 to 4,516,381 bytes; hash is
  `1cc7963...`.
- `scripts/verify_text_fixups.ps1` is now scope-aware: cell rules, label rules,
  superseded global rules, and p11f-only timing rules are handled separately. Result:
  124 cell rules applied, 3 documented no-ops, PASS.
- New deterministic packaging: `scripts/package_release_1_0_3.ps1`.
- Decisions recorded: `DEC-048` (1.0.3 is the next public release after 1.0.0) and
  `DEC-049` (fast-forward-only publication and scope-aware fixup verification).

## 4. Gates (all passed)

| gate | result |
| --- | --- |
| trailing-whitespace trim | 0 changes |
| translation validator | PASS, 0 hard errors |
| glyph gate | PASS, 0 Arabic-introduced missing codepoints |
| text-fixup verifier | PASS, 124 cell rules applied + 3 documented no-ops |
| subtitle timing audit | 537/537 marker-identical, 0 defects |
| carrier round-trip, p12 | 35/35 byte-identical |
| carrier round-trip, p12g | 35/35 byte-identical |
| `p12_gate_all.ps1` | PASS for p12, p12g, p12c, p12e, p12f, p12ef |
| p12g stack audit | H1t 27, H2 0, H3 343 |

Evidence: `reports/p12_gate_all.md`, `reports/subtitle_timing_audit.md`,
`reports/subtitle_stack_audit_p12.md`, `reports/subtitle_stack_audit_p12g.md`,
`reports/p12_master.md`, and `reports/carrier_build.md`.

## 5. Current installed set (unchanged)

`Paks\~mods` still contains exactly these four files:

| file | size (bytes) | SHA256 |
| --- | ---: | --- |
| `atomic-heart-ar-install-manifest.json` | 2,383 | `5b17aaf4c538da6ecbdb6976bdf5c8eebf39f113955c5dcad4015a9e4c3c5c6a` |
| `zzz_atomicheart-ar_carrier_koKR_p12_P.pak` | 4,470,295 | `910c06f2609237ac021dc1d3e2a6af02a05c64a828efdfe497a711bac66860c3` |
| `zzz_atomicheart-ar_font_p3_unhinted_P.pak` | 1,455,228 | `f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4` |
| `zzz_atomicheart-ar_tips_x150_P.pak` | 75,853 | `36de01c37231a8b88ec9fc744c4f663bb8461a56adede9a6a2151d78c7ef7fcc` |

This is the previously verified `1.0.0` p12 set. It was **not** replaced with the new
1.0.3 carrier. To use 1.0.3 locally, install the new archive or run the switch command
after copying the new carrier into `build/package/`.

Install target:

```text
...\Atomic Heart\AtomicHeart\Content\Paks\~mods
```

Then select **Korean / الكورية** as the game's text language. English voice audio is
unchanged.

## 6. Rebuild / repackage 1.0.3

```powershell
cd C:\AtomicHeart-AR

# 1. Regenerate the p12 variant from the corrected master
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\make_p12_master.ps1

# 2. Rebuild the stable carrier
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\build_carrier_locres_pak.ps1 `
  -MasterTsV C:\AtomicHeart-AR\build\variants\atomic-heart-ar_p12.tsv `
  -PakOut C:\AtomicHeart-AR\build\package\zzz_atomicheart-ar_carrier_koKR_p12_103_P.pak `
  -VariantLabel p12_103

# 3. Rebuild p12g from the 1.0.0 timing variant plus the eight fixes, then the carrier
#    (see the history in docs/releases/translation-fixes-1.0.2.json)

# 4. Create the two payload ZIPs with hash checks
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\package_release_1_0_3.ps1

# 5. Source archive from the tag (tag must already exist)
git archive --format=zip -o dist\AtomicHeart-AR-1.0.3-source.zip v1.0.3
```

The carrier builder uses `repak` V11, mount point `../../../`, and
`RAYON_NUM_THREADS=1` for deterministic output. It unpacks and compares every entry
before reporting success.

## 7. p12 vs p12g

- **p12** is the stable default and the recommended package.
- **p12g** is experimental: it keeps the `1.0.0` H1/H2/H3 timing behavior.
- Never install both carriers in `~mods`; use one only.
- If p12g shows timing problems, switch back to p12.

## 8. Known limitations

- Subtitle timing is tied to the original audio clips; fast dialogue can stack lines.
- The bottom bar can clip lines when four lines are visible. The exact engine clip owner
  remains `UNKNOWN`.
- H1m/H1k/H4 are stock DataTable-level conditions and cannot be repaired by a
  locres-only PAK.
- 197 non-monotonic H1 tracks were left byte-exact.
- 343 H3 rows have no usable clip duration; they remain in p12g.
- In-game visual rendering and Steam Deck hardware were not retested for 1.0.3.
- The choice number `1 //` can appear on the left in some menus.
- Arabic and Cyrillic literals must stay in UTF-8 data files; PowerShell 5.1 scripts must
  remain ASCII-only (KI-021).

## 9. Key files

| path | contents |
| --- | --- |
| `docs/releases/v1.0.3.md` | Arabic + English release notes |
| `docs/releases/v1.0.3-SHA256SUMS.txt` | asset and payload hashes |
| `docs/releases/v1.0.3/README-INSTALL-p12.txt` | p12 archive README |
| `docs/releases/v1.0.3/README-INSTALL-p12g.txt` | p12g archive README |
| `scripts/package_release_1_0_3.ps1` | deterministic 1.0.3 packaging |
| `scripts/verify_text_fixups.ps1` | scope-aware fixup gate |
| `reports/p12_gate_all.md` | six-variant gate summary |
| `reports/open_source_publication.md` | publication record for 1.0.0 and 1.0.3 |
| `reports/subtitle_timing_audit.md` | 537/537 marker audit |
| `localization/working/tm_fixups.tsv` | rule source, including current cell/label rules |
| `docs/releases/translation-fixes-1.0.2.json` | the eight corrections carried into 1.0.3 |
| `build/verify_release_103/` | downloaded-asset verification copies (ignored) |

## 10. Open items / next steps

- Optionally install the published p12 1.0.3 carrier locally and play-test the eight
  corrected strings in game.
- Retest subtitle stacking and the bottom-bar clip with four visible lines.
- Steam Deck verification remains outstanding.
- If a future release changes game text, repeat the full gate chain and use a new tag;
  never reuse `v1.0.3`.
- Keep publication fast-forward only; see `DEC-049`.

## 11. STOP

`v1.0.3` is published and verified. The local installed `~mods` set is deliberately
unchanged. Do not replace, delete, or force-push anything without explicit approval.

Dated copy: `handoff_2026-10-31.md` (repository) and
`C:\Users\abona\Desktop\AtomicHeart-AR_HANDOFF_2026-10-31.md`.
Desktop shortcut file: `C:\Users\abona\Desktop\HANDOFF` (no extension).
