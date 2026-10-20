# handoff_019 — Atomic Heart Arabic localization (cycle 015 closed)

**Date/time:** 2026-10-20 23:38 +03:00
**Installed:** carrier **p10** + font **p2_plex** (Korean slot, 3 files in `~mods`)
**Coverage:** **26,022 of 27,618 rows (94.22%)** — **100% of the 26,022 translatable rows**; 1,596 copy-class rows intentionally English-filled
**Next step:** wait for the user (play-test p10 + the seven questions in `lastreport.md` §9). Do **not** start Phase 8 without approval.

---

## 1. Repository state

| item | value |
|---|---|
| repo | `C:\AtomicHeart-AR` (local git only, 0 remotes, nothing uploaded) |
| master DB | `localization\master\atomic-heart-ar.tsv` — 27,618 rows × 13 cols, UTF-8 no BOM, CRLF |
| Arabic rows | 26,022 (status DRAFT) |
| copy-class rows | 1,596 (empty Arabic, documented reasons in `reports\english_filled_rows.tsv`) |
| TM | `localization\working\tm.tsv` — 19,733 entries (line 1 is the header `english<TAB>arabic<TAB>source`) |
| work order | `localization\working\batch2\plan_unique.tsv` — 15,824 ids, **all authored** (b0001–b15824) |
| chunks applied | batch 2: 0002–0015; batch 3: 0016–0038; **batch 4: 0039–0054** (this cycle) |
| fixup rules | `localization\working\tm_fixups.tsv` — 87 rules (3 added this cycle) |
| glossary | `glossary\glossary.tsv` (pipe-separated renderings, optional `cs` column), `glossary\terminology.md` §1–13 |

## 2. Installed build and rollback

| item | value |
|---|---|
| carrier p10 | `zzz_atomicheart-ar_carrier_koKR_p10_P.pak`, 4,473,788 B, sha256 `7fbed3a87fafb547ecf4a2557a590ae0d7c05da304a3c7f6facb7bb34ef49393` |
| font | `zzz_atomicheart-ar_font_p2_plex_P.pak`, 1,461,408 B, sha256 `02b17f31e61a46ddba20bea8c4da5be44164173df608d52697f68d27d8269747` |
| manifest | `atomic-heart-ar-install-manifest.json`, sha256 `c34ac3a148c120a8d1a914641a2f5a91f2a1736d19d4ef7f43ac40867638d474` |
| game path | `C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart\AtomicHeart\Content\Paks\~mods` |
| rollback | `powershell -NoProfile -File scripts\install_mod.ps1 -Carrier p9 -Font p2_plex` |
| rebuild p10 | `powershell -NoProfile -File scripts\build_carrier_locres_pak.ps1 -VariantLabel p10` |
| reinstall | `... install_mod.ps1 -Carrier p10 -Font p2_plex` then `verify_install.ps1 -Before <snapshot.json>` |

Game folder stays read-only except `~mods`; never touch EXE/DLL/Denuvo. Only `pakchunk0` carries locres; the carrier covers 35/35 scopes.

## 3. Gate chain (run in this order after any master change)

```powershell
cd C:\AtomicHeart-AR
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\trim_trailing_ws.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validate_translation.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\glyph_gate.ps1 -AllowSourceInheritedNonLatin
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\verify_text_fixups.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\coverage_report.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\cycle015_report.ps1   # full cycle evidence
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\ui_length_watch.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\review_sample.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\build_reference.ps1
```

Expected now: trim 0 · validator PASS (0 errors, 259 warnings) · glyph PASS · fixups PASS (87 rules) · coverage 26,022 of 26,022 (100%) translatable.

## 4. Authoring pipeline (if more rows ever appear)

1. `scripts\batch2_sheet.ps1 -ChunkId NNNN -StartId bNNNNN -Count 300` → `sheet_NNNN.tsv`
2. author `ar_NNNN.tsv` (id TAB arabic), copy-class rows omitted
3. `scripts\batch2_chunk.ps1 -ChunkId NNNN` → must print `[chunk NNNN] entries: N` with no ERROR
4. `scripts\batch2_apply.ps1 -ChunkId NNNN` → then **always** `verify_text_fixups.ps1`
5. gates from §3, then rebuild/install

The plan is exhausted; new work would need a plan extension (append ids after b15824), which is a decision for the user.

## 5. Tooling gotchas (hard-won, do not repeat)

- **Chunk files have no header.** `batch2_apply.ps1` must read `chunk_*.tsv` from line 0 (fixed this cycle, DEC-042, KI-034). `tm.tsv` **does** have a header, so tm readers legitimately start at line 1.
- PowerShell 5.1 parses `.ps1` as ANSI: **never** put Arabic (or « ») in a script — build strings from `[char]0x....` or read a UTF-8 data file (KI-021). Two scripts failed this way this cycle; both were fixed.
- Do not split TSV with a backtick-t inside a shell-quoted string; use `.Split([char]9)`.
- `@{}` keys are case-insensitive — use ordinal `Dictionary[string,string]` / `HashSet[string]` (KI-023).
- UnrealLocres prints Arabic/Korean as `?` on the console; verify by reading files, not stdout.
- Locres cannot store leading/trailing whitespace: trim before every build (KI-024); the build logs `EDGE-WS` / newline-normalised rows and tolerates them.
- `Get-Content` without `-Encoding UTF8` mangles UTF-8-no-BOM files in this console; use `[IO.File]::ReadAllLines(path, [Text.Encoding]::UTF8)`.
- `verify_text_fixups.ps1` runs after every apply (DEC-038). Reviewer text fixes go only into `tm_fixups.tsv`, never a direct master edit (DEC-046).

## 6. Open items (nothing blocking delivery)

| id | state | note |
|---|---|---|
| KI-009 | NOT TESTED | GameTips popups |
| KI-022 | NOT TESTED | subtitle clip-vs-scroll |
| KI-026 | NOT TESTED in game | evidence produced: 1,019 UI labels > 40 chars, longest 199 (`reports\ui_length_watch.md`) |
| KI-028 | COSMETIC (Phase 8) | choice number/separator `1 //` sits left of Arabic |
| KI-031 | OPEN (1 row) | prose inside `<- … ->` stays Latin |
| KI-032 | OPEN (policy) | EN/RU asset divergences; English master is the anchor |
| KI-033 | OPEN (accepted) | 25 glossary sense/form warnings, reviewed |
| KI-035 | OPEN (cosmetic) | 220 rows with straight quotes instead of guillemets; needs a tag-safe pass |
| KI-036 | OPEN | p10 installed, not play-tested |
| KI-013 | Phase 8 | native `ar` language-list entry needs `DA_Audio` tooling |
| KI-018 | Phase 8 | 248 RU-only cooked assets / 6,012 strings (incl. `DT_Subtitles_*`) |
| KI-017 | BLOCKED | `NotLifted_17` obfuscated, evidence only |
| KI-027 | residual | 2,588 uncurated single-occurrence label candidates; 2 DLC4 `CHAR-les` rows |

## 7. Questions awaiting the user

1. Play-test p10 (menus/HUD, one DLC2 scene, one NTD sign, subtitles) — any clip, overlap, box glyph or English leak?
2. "Upgrade" in dialogue: unify the verb to the noun term (ترقية) or keep the split (noun UI / verb speech, تطوير)?
3. KI-032: English anchor or Russian canon?
4. Bracket labels: translate the 7 remaining technical ids or keep Latin?
5. KI-031: translate prose inside `<- … ->`?
6. Tone pass: extend beyond the 40 of 150 sampled rows?
7. KI-035: guillemet pass now or Phase 8?

## 8. Where the evidence is

- `reports\cycle015_results.md` — full cycle report (sections 1–10).
- `reports\coverage_cycle015.md` — coverage per scope/category with copy-class reasons.
- `reports\english_filled_rows.tsv` — 1,596 rows, line/key/scope/category/english/reason.
- `reports\ui_length_watch.md`, `reports\review_sample.md` — KI-026 evidence and the 40-row AR/EN sample.
- `reports\carrier_build.md`, `reports\install_verification.md`, `reports\translation_validation.md`, `reports\glyph_gate.md`, `reports\text_fixups_log.md`.
- `localization\references\AR_EN_REFERENCE.md` — AR/EN reference (6,988,783 B).
- `DECISIONS.md` (through DEC-046), `KNOWN_ISSUES.md` (through KI-036), `STATUS.md`, `ROADMAP.md`, `lastreport.md`, `reports\history\report_019.md`.
