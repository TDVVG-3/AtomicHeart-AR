# HANDOFF - AtomicHeart-AR

- **Cycle:** 005 (continuing) - **Date/time:** 2026-10-18 ~14:00 UTC
- **Project:** AtomicHeart-AR - Arabic localization for Atomic Heart (Steam App ID 668580)
- **Current milestone:** Prototype v0.0.1, **Test 3** (installed 2026-10-18, awaiting user's in-game result)

## Project summary (5 lines)
Goal: make Atomic Heart display Arabic text without touching the game EXE or stores.
Strategy: no native Arabic menu entry is possible yet (the Options > Language list is
hardcoded in a cooked asset), so we borrow the **ko-KR (Korean) language slot** and
inject our text through a custom `.pak` in the game's `~mods` folder, replacing 6
UI font payloads with IBM Plex Sans Arabic (Latin + Arabic capable).
Right now in `~mods` (exactly 2 paks + 1 manifest): `zzz_atomicheart-ar_carrier_koKR_p2_P.pak`
(25 Arabic strings + 5,572 keys filled with English so nothing shows blank) and
`zzz_atomicheart-ar_font_p2_plex_P.pak` (the font). Game build ID: **24534183**.
Everything is local-only Git (no remotes, no uploads, ever).

## 1. Completed (this cycle so far)
- Test 2 (carrier p1 + font v2) result diagnosed: outcome D (partial) - no hang, 258
  FPS normal, digits visible, labels blank. Mechanism CONFIRMED: replacement font has
  zero Hangul glyphs, so untranslated Korean text rendered blank.
- Font evidence regenerated: IBM Plex Sans Arabic covers Latin 95/95 and Arabic 42/42;
  Cyrillic 0, Hangul 0 (`reports/font_block_probe.txt`).
- Glyph gate hardened: any future font lacking Cyrillic or Hangul now fails the build
  unless a special human-reviewed flag is passed.
- Carrier pak v2 built with English-fill policy (DEC-016): of 5,597 NewP5 ko-KR keys -
  25 Arabic seed + 5,572 English-filled + 0 skipped; full round-trip validation, 0 failures
  (55 values differ only by LF vs CRLF - tool quirk, recorded as KI-015).
- Repository organized per user instruction: plan in `reports/organize_plan.md`
  (6 historical logs moved to `reports/logs/`, no deletions), `INDEX.md` created,
  spec hash verified PASS, installer/uninstaller dry-check PASS.

## 2. Problems
- (resolved this cycle) Blank labels: caused by missing Hangul in the font; the English
  fill removes all blank untranslated text.
- (open) Real Arabic visibility unproven in-game so far - that is exactly what Test 3
  checks (the p1 carrier also had Arabic strings but the menu test focused on Korean
  slots; user report listed no Arabic seen yet).
- (open, deferred).phase 8 items: composite font that keeps Cyrillic (native font
  objects), schema tooling for the hardcoded language list, RU-native-only StringTables.
- (minor, recorded) UnrealLocres import converts embedded LF to CRLF in multiline
  values (5 values); engine itself ships one CRLF natively, so tolerated.

## 3. Evidence
- Font block probe (PASS evidence): `reports/font_block_probe.txt` - Regular/Medium/Bold
  all: Latin-Basic 95 FULL, Arabic-core 42 FULL, Cyrillic 0 ABSENT, Hangul 0 ABSENT.
- Cyrillic survival explanation: stock faces we never replaced are Cyrillic-capable -
  BlenderPro family 94, Gotham-BookItalic 170, BrutalType 94, RobotoMono 255
  (`reports/font_glyph_coverage.txt`).
- Carrier p2: SHA256 3d4b0ea65c5dc789be98b46aa18c7c27959445b7d36454616b91be2ae55fa9e1,
  503,841 bytes; unpack round-trip byte-identical; counts and validation in
  `build/staging/carrier_koKR/carrier_record.txt`; report in `reports/history/report_005.md`.
- Org verification: spec SHA256 == 579f581e...61c35 (PASS); install/uninstall scripts
  parse clean and all referenced repo paths exist (PASS, dry check only).

## 4. Files changed
- `scripts/build_carrier_locres_pak.ps1` (RFC4180 parser + English-fill + 3-class validation)
- `scripts/build_fontpak_p2_plex.ps1` (Cyrillic/Hangul gate + exemption flag)
- `scripts/probe_font_blocks.ps1` (size-display fix), new `reports/font_block_probe.txt`
- `scripts/install_mod.ps1` (Test-3 set: carrier p2 + font v2)
- `lastreport.md`, `reports/history/report_005.md`, `DECISIONS.md` (DEC-016),
  `KNOWN_ISSUES.md` (KI-009 update, KI-014, KI-015), `STATUS.md`, `CHANGELOG.md`
- Org: `reports/organize_plan.md`, `INDEX.md`, 6 logs moved to `reports/logs/`
- Commits: ffb93e4 (cycle 005 build), 9160bab (organization), + this stretch (Test-3 install + handoff)

## 5. Current status
- `~mods` = Test-3 set installed and SHA-verified (carrier p2 + font v2 + manifest).
- Stock Paks folder untouched (19 files). Game not launched yet since install.
- Awaiting: user plays and reports Test 3 outcome (A/B/C/D, see section 7).

## 6. Next action
- User runs Test 3 (ko-KR still selected) and returns screenshots + outcome letter.
- On A (pass): plan scale-up - full corpus pipeline, composite-font phase 8 work,
  KI-013 schema tooling; close prototype.
- On B/C/D: iterate per within-cycle diagnosis; if any signature-enforcement error
  appears in game: STOP and report (standing rule).

## 7. What I need you to do
Play the game with Korean selected and check:
1. MAIN MENU: buttons should be readable - the 9 menu seed strings in Arabic.
2. SETTINGS: captions like "Balanced / On / Off / Fullscreen" in Arabic; other settings
   text in ENGLISH instead of blank.
3. A GameTips popup during a mission: Arabic seed text.
4. Note anything still blank, Russian-only, or wrongly shaped/backwards.
Send: screenshot of (1), (2), (3), plus any anomaly; final answer = outcome letter
A / B / C / D as described in `reports/history/report_005.md` section "Next steps".

## Decisions so far
| DEC  | Decision (one line)                                                                 | Status   |
|------|-------------------------------------------------------------------------------------|----------|
| 001  | Repo layout per spec section 8                                                      | ACTIVE   |
| 002  | Game folder READ-ONLY except Paks/~mods                                             | ACTIVE   |
| 003  | repak is the primary pak tool                                                       | ACTIVE   |
| 004  | Split localization (per-culture files, zzz_-prefix mod paks)                        | ACTIVE   |
| 005  | No uploads: local Git only, remotes must stay empty                                 | ACTIVE   |
| 006  | UnrealLocres for locres work (csv round-trip)                                       | ACTIVE   |
| 007  | Fallback carrier = ko-KR slot (user-approved); zh-TW/uk-UA alternatives rejected     | ACTIVE   |
| 008  | Spec integrity guard: read-only backup + SHA256 + auto-restore each cycle           | ACTIVE   |
| 009  | Master DB built from en-US (27,618 rows)                                             | ACTIVE   |
| 010  | Text QA: placeholders/tags preserved exactly; round-trip validation required         | ACTIVE   |
| 011  | ASCII-only reports; all chat reporting in English                                    | ACTIVE   |
| 012  | Evidence labels PASS/FAIL/PARTIAL/BLOCKED/NOT TESTED + CONFIRMED/LIKELY/UNKNOWN      | ACTIVE   |
| 013  | Variant naming for pak rebuilds (p1, p2, ...) to avoid stale-pak confusion           | ACTIVE   |
| 014  | Font: replace payloads with IBM Plex Sans Arabic (v2); Naskh v1 rejected             | ACTIVE (test-grade) |
| 015  | Language list is hardcoded; native `ar` = phase 8 schema tooling; carrier meanwhile   | ACTIVE   |
| 016  | Carrier fill: untranslated ko-KR keys get en-US English; glyph gate enforces Cyrillic/Hangul | ACTIVE |

## Open issues
| KI     | One line                                                                        | Status                  |
|--------|----------------------------------------------------------------------------------|-------------------------|
| KI-002 | Empty MASTER_PROMPT incident; spec guard since deployed                          | MITIGATED               |
| KI-003 | ~155 GB archive hashing                                                         | RESOLVED                |
| KI-004 | Main UI text is NOT in locres (cooked assets); needs phase 5/8 asset extraction  | OPEN                    |
| KI-005 | LocResUtility/UnrealLocres unlicensed - local use only, no redistribution         | OPEN (conduct rule)     |
| KI-006 | Custom Mundfish JSON pre-header on every pak; mod-pak requirement unproven       | OPEN                    |
| KI-007 | exe has no version metadata; identify game by build id 24534183                  | NOTED                   |
| KI-008 | .NET 8 runtimes for LocResUtility (user-approved winget install)                 | RESOLVED                |
| KI-009 | Font: v2 Plex (test-grade) keeps Latin+Arabic, loses Cyrillic/Hangul on swapped faces | PARTIAL PASS        |
| KI-010 | RU-native-only StringTables (ST_GooseRunner_Hints etc.) need separate uasset path | OPEN (deferred)         |
| KI-012 | No engine log even with -log; diagnostics via render/asset analysis only         | CONFIRMED (negative)    |
| KI-013 | Language menu hardcoded in DA_Audio (cooked, unversioned) - schema tooling needed | OPEN (phase 8)          |
| KI-014 | Hangul blanks CONFIRMED; mitigation = English-fill carrier p2                    | CONFIRMED, mitigated    |
| KI-015 | UnrealLocres import LF->CRLF in multiline values                                 | NOTED (accepted)        |
