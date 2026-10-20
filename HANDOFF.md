# HANDOFF — Atomic Heart Arabic localization

**Last updated:** 2026-10-20 23:38 +03:00 (cycle 015 closed)
**Installed in game:** carrier **p10** + font **p2_plex** (Korean language slot, exactly 3 files in `~mods`)
**Coverage:** **26,022 of 27,618 rows (94.22%)** — **100% of the 26,022 translatable rows**; 1,596 copy-class rows intentionally English-filled
**Validator:** PASS, 0 errors · **Glyph gate:** PASS, 0 glyphs introduced by Arabic

---

## 1. State in one screen

| item | value |
|---|---|
| master DB | `localization\master\atomic-heart-ar.tsv` — 27,618 rows × 13 cols, **26,022 Arabic** (DRAFT) |
| English-fill rows | 1,596 — all **copy-class** (identifiers `P-3` ×1,140, numbers, placeholders, proper names, `[do not localize]`, debug labels), each with a reason in `reports\english_filled_rows.tsv` |
| kept-Korean rows | 0 |
| TM | `localization\working\tm.tsv` — 19,733 entries (line 1 = header) |
| work order | `localization\working\batch2\plan_unique.tsv` — 15,824 ids, **all authored** (b0001–b15824) |
| chunks applied | batch 2: 0002–0015 · batch 3: 0016–0038 · **batch 4: 0039–0054** |
| review sample | `reports\review_sample.md` — 40 rows: 10 long dialogue, 10 short UI, 10 tagged, 10 edge cases (DEC-045) |
| AR/EN reference | `localization\references\AR_EN_REFERENCE.md` — 6,988,783 B, 26,022 rows, 19,732 unique English, 35 scopes |

## 2. Installed build

| item | value |
|---|---|
| carrier | `zzz_atomicheart-ar_carrier_koKR_p10_P.pak` — 4,473,788 B, sha256 `7fbed3a87fafb547ecf4a2557a590ae0d7c05da304a3c7f6facb7bb34ef49393` |
| font | `zzz_atomicheart-ar_font_p2_plex_P.pak` — 1,461,408 B, sha256 `02b17f31e61a46ddba20bea8c4da5be44164173df608d52697f68d27d8269747` |
| manifest | `atomic-heart-ar-install-manifest.json` — sha256 `c34ac3a148c120a8d1a914641a2f5a91f2a1736d19d4ef7f43ac40867638d474` |
| `~mods` | exactly these 3 files; p9 removed hash-verified |
| install proof | `verify_install.ps1 -Before <snapshot>` → **VERIFY INSTALL PASS, problems 0** |
| rollback | `scripts\install_mod.ps1 -Carrier p9 -Font p2_plex` |
| in-game language | **Korean** (carrier occupies the ko-KR slot) |
| play-tested | **NO** — p10 is installed but has not been played; last in-game proof is p7 (canal boat scene) |

## 3. How to rebuild / reinstall

```powershell
cd C:\AtomicHeart-AR
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\trim_trailing_ws.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validate_translation.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\glyph_gate.ps1 -AllowSourceInheritedNonLatin
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\verify_text_fixups.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\build_carrier_locres_pak.ps1 -VariantLabel p10
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\snapshot_game_folder.ps1 -RepoRoot C:\AtomicHeart-AR -Out C:\Users\abona\AppData\Local\Temp\ah_before.json
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\install_mod.ps1 -Carrier p10 -Font p2_plex
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\verify_install.ps1 -Before C:\Users\abona\AppData\Local\Temp\ah_before.json
```

Report regeneration: `coverage_report.ps1`, `cycle015_report.ps1`, `ui_length_watch.ps1`, `review_sample.ps1`, `build_reference.ps1`.

## 4. Cycle 015 results (what changed)

- Batch 4 finished: chunks 0039–0054, 4,716 ids authored, **4,802 rows** filled, TM 15,410 → 19,733.
- Coverage 21,220 → 26,022 of 27,618 (94.22%); **26,022 of 26,022 translatable rows (100%)**; 0 rows needing review.
- Gates all green; carrier p10 built and installed with snapshot proof.
- Defects found by the gates and fixed: **first-entry loss in `batch2_apply.ps1`** (chunk files are headerless; fixed and all chunks replayed — DEC-042 / KI-034), a leaked NewP5 debug row (`english` → `arabic`), three glossary drifts (Crystal Complex ×23, Sakhalin ×2, Kollektiv ×3 — DEC-046), plus the wave-1 tag/chirper/deprecated-spelling repairs.
- 7 chunk conflicts (same English, second nuance later): master keeps the first shipped variant; all reviewed, stylistic only.
- Evidence: `reports\cycle015_results.md` (sections 1–10), `reports\coverage_cycle015.md`, `reports\english_filled_rows.tsv`, `reports\ui_length_watch.md`, `reports\review_sample.md`, `reports\carrier_build.md`, `reports\install_verification.md`.

## 5. Docs and decisions

`DECISIONS.md` through **DEC-046** · `KNOWN_ISSUES.md` through **KI-036** · `STATUS.md` · `ROADMAP.md` · `lastreport.md` · `reports\history\report_019.md` · `handoff_019.md` (this cycle) · earlier handoffs kept (never deleted).

New this cycle: DEC-042 (appliers read chunk files from line 0), DEC-043 (plan is order-only; coverage from master + end-of-cycle copy-class audit), DEC-044 (copy-class definition and headline metric), DEC-045 (stratified review sample), DEC-046 (glossary unification via `tm_fixups.tsv`). New issues: KI-034 (fixed), KI-035 (straight quotes vs guillemets, cosmetic Phase 8), KI-036 (p10 not play-tested).

## 6. Open items (nothing blocking delivery)

| id | state | note |
|---|---|---|
| KI-009 | NOT TESTED | GameTips popups |
| KI-022 | NOT TESTED | subtitle clip-vs-scroll |
| KI-026 | NOT TESTED in game | 5,890 UI rows with Arabic, 1,019 labels > 40 chars, longest label 199 (`reports\ui_length_watch.md`) |
| KI-028 | COSMETIC (Phase 8) | choice number/separator `1 //` left of Arabic |
| KI-031 | OPEN (1 row) | prose inside `<- … ->` stays Latin |
| KI-032 | OPEN (policy) | EN/RU divergences; English master is the anchor |
| KI-033 | OPEN (accepted) | 25 glossary sense/form warnings (Terminal 7, Major 6, Phasotron 2, Comrade 2, Upgrade 2, +6 single) |
| KI-035 | OPEN (cosmetic) | 220 rows with straight quotes instead of «»; tag-safe pass needed |
| KI-036 | OPEN | p10 not play-tested |
| KI-013 / KI-018 | Phase 8 | native `ar` language entry · 248 RU-only assets / 6,012 strings |
| KI-017 | BLOCKED | `NotLifted_17` obfuscated, evidence only |
| KI-027 | residual | 2,588 uncurated label candidates; 2 DLC4 `CHAR-les` rows |

## 7. Questions awaiting your answer

1. **Play-test p10** — menus/HUD, one DLC2 scene, one NTD sign, subtitles: any clip, overlap, box glyph or English leak?
2. **"Upgrade" in dialogue** — unify the verb to the noun term (ترقية), or keep the split (noun for UI, verb in speech, تطوير)?
3. **KI-032** — keep the English master as the anchor or follow the Russian canon?
4. **Bracket labels** — translate the 7 remaining technical ids or keep them Latin?
5. **KI-031** — may prose inside `<- … ->` be translated?
6. **Tone pass** — extend beyond the 40 of 150 sampled rows?
7. **KI-035** — guillemet pass now or in Phase 8?

## 8. Rules that must not break

- Text only: no media extraction, no raw game assets committed; game folder read-only except `~mods`; never touch EXE/DLL/Denuvo.
- Installs only with explicit approval; nothing uploaded (local git only).
- Arabic only in UTF-8 data files, **never** a literal in a `.ps1` (KI-021); reviewer text fixes only via `tm_fixups.tsv` (DEC-046); `verify_text_fixups.ps1` after every apply (DEC-038).
- Placeholders, tags, escapes, timing markers and `&Speaker&` byte-exact; never add a tag the English lacks.
- Coverage always stated as "N of TOTAL (X%)"; RU-only strings never enter the English column (KI-010).
- Trim trailing whitespace before every carrier build (KI-024).
- Phase 8 (native `ar`, RU-only assets, choice numbering) starts only after your decision.
