# Cycle 005 Report - 2026-10-18

## Objective
Fix the Test-2 blank-label problem (game side of the ko-KR carrier + font v2 stack),
report font glyph coverage for Cyrillic/Latin, upgrade the glyph gate with a Cyrillic
check, build the English-fill carrier, and prepare Test 3 for the user. Nothing was
installed or uninstalled this cycle (per the standing rule; awaiting user go).

## Standing verifications
- MASTER_PROMPT.md integrity: SHA256 verified OK at cycle start (5637... prefix of the
  guard hash; auto-restore not needed).
- git remote -v: EMPTY (local-only commits; no-upload rule respected).
- Game folder untouched except Paks/~mods; no EXE/DLL/Steam files touched.

## Test 2 diagnosis (outcome D = partial) - Hypothesis CONFIRMED
1. User hypothesis CONFIRMED: the blank labels are untranslated Korean locres strings.
   IBM Plex Sans Arabic has ZERO Hangul glyphs, so those strings render blank:
   `reports/font_block_probe.txt` shows for all three Plex weights:
   - Latin-Basic: 95 FULL (digits/Latin visible in-game, matches Test-2 report)
   - Arabic-core: 42 FULL
   - Cyrillic: 0 ABSENT
   - Hangul-Syllables: 0 ABSENT
   - Hangul-Jamo: 0 ABSENT
2. The two visible Russian labels are NOT locres text; they render through stock faces
   this project never replaces. Cyrillic-capable stock faces (evidence:
   `reports/font_glyph_coverage.txt`): BlenderPro family (Cyrillic 94),
   Gotham-BookItalic (170), Gotham-Black, BrutalType (94), RobotoMono Regular/Bold/Thin
   (255), Roboto, DroidSansFallback, Noto Sans KR (66 + Hangul). Our font pak replaced
   only 6 faces (BlenderPro Book/Medium/Bold, BrutalType, Gotham-BookItalic,
   Gotham-Black) - all other faces keep their original payloads, hence Cyrillic
   survival. The red color is text styling, not a font artifact.
3. Font coverage answer (requested): replacement font = IBM Plex Sans Arabic
   Regular/Medium/Bold - Latin FULL 95/95, Arabic FULL 42/42, Cyrillic ABSENT (0),
   Hangul ABSENT (0). Latin was the v1 lesson (Naskh had only 15 Latin codepoints);
   v2 keeps Latin intact. Cyrillic and Hangul are absent by design of this font.

## Work done (evidence)
- Fixed the file-size display bug in `scripts/probe_font_blocks.ps1` and reran it;
  `reports/font_block_probe.txt` regenerated with correct byte sizes (PASS evidence).
- Glyph gate upgraded in `scripts/build_fontpak_p2_plex.ps1` (PASS with flags, see
  DEC-016): gate now parses explicit block counts per mapped font and requires
  Latin-Basic >= 95 AND Arabic-core >= 42; Cyrillic == 0 or Hangul == 0 hard-fails the
  build unless `-AllowMissingCyrillicHangul` is explicitly passed after human review.
  v2 was rebuilt under that flag: PASS for all 6 face mappings; the rebuilt font pak's
  6 payload files are byte-identical to the installed font pak (unpack-compare; only
  repak container timestamps differ), so the installed font pak stays valid.
- Carrier builder reworked (`scripts/build_carrier_locres_pak.ps1`):
  a) Added RFC4180 CSV reading (TextFieldParser). Finding: UnrealLocres exports embed
     real newlines inside quoted values; the old single-line parser produced 5742
     pseudo-keys from 5751 lines, with garbage fragment keys. Correct parse: 5597 real
     keys in BOTH ko-KR and en-US exports (counts agree exactly).
  b) English-fill policy per user order (DEC-016): seed keys keep Arabic; every other
     ko-KR key gets the en-US text of the same namespace/key; keys missing in en-US
     would stay Korean (none in NewP5).
  c) Full three-class round-trip validation (value = re-export column 1).

## Carrier p2 build result
- Pak: `build/package/zzz_atomicheart-ar_carrier_koKR_p2_P.pak`
  (zzz_atomicheart-ar_carrier_koKR_p2_P.pak, V11, mount ../../../; new name avoids
  stale confusion with installed p1)
- Size: 503,841 bytes; SHA256
  3d4b0ea65c5dc789be98b46aa18c7c27959445b7d36454616b91be2ae55fa9e1
- Coverage counts (of 5,597 NewP5 ko-KR keys):
  - Arabic seed rows: 25
  - English-filled rows: 5,572
  - kept Korean (no en-US text): 0
- Validation: 0 failures across 5,597 keys. 5,541 byte-exact; 56 multiline values
  differ ONLY in newline encoding (LF vs CRLF) - PASS with recorded delta:
  UnrealLocres v1.1.0 import normalizes embedded LF to CRLF inside multiline values
  (KI-015). The engine demonstrably tolerates CRLF: the game's own ko locres ships
  one native CRLF value. Packing + unpack round-trip: byte-identical (PASS).
- NOT INSTALLED. Build record: `build/staging/carrier_koKR/carrier_record.txt`.

## Documents updated
- DECISIONS.md: DEC-016 (English-fill carrier policy + CRLF acceptance + glyph gate
  upgrade, with the human-review exemption flag).
- KNOWN_ISSUES.md: KI-009 updated (Test-2 partial pass + trade-off), new KI-014
  (Hangul-blank mechanism CONFIRMED, English-fill mitigation), new KI-015
  (UnrealLocres LF->CRLF normalization).
- STATUS.md, CHANGELOG.md: cycle 005 state.

## Next steps (Test 3 prepared - needs user GO)
1. On user's GO: uninstall the Test-2 paks, then install exactly:
   - zzz_atomicheart-ar_carrier_koKR_p2_P.pak (English-fill carrier)
   - zzz_atomicheart-ar_font_p2_plex_P.pak (installed copy reused)
   Manifest-based scripts: uninstall_mod.ps1, then installer set for Test 3.
2. User in-game test (ko-KR already selected; English voice stays by design).
   Where to look, and what to screenshot:
   a) MAIN MENU: menu buttons (seed strings should show Arabic).
   b) SETTINGS pages: captions such as Balanced / On / Off / Fullscreen
      (seed strings; untranslated settings text now English instead of blank).
   c) GO POPUPS: skip a GameTips popup during a mission (Arabic seed text).
   d) Anything still blank, Russian-only, or rendered right-to-left incorrectly.
   Screenshot: one of each of a)+b)+c) minimum, plus anything unexpected.
3. Outcomes: A = Arabic visible in popups/captions AND no more blanks elsewhere
   (prototype PASS; then plan scale-up: full corpus, composite font Phase 8, KI-013
   schema tooling); B = Arabic visible but shaped/backwards artifacts (font wiring
   iteration); C = untranslated text English but Arabic missing where expected
   (carrier/locres wiring check); D = still blank (needs deeper diagnosis).
   - If any signature-enforcement error appears: STOP and report (standing rule).

## Artifacts
- scripts/probe_font_blocks.ps1 (fixed), reports/font_block_probe.txt (regenerated)
- scripts/build_fontpak_p2_plex.ps1 (gate), rebuild + payload-identity check
- scripts/build_carrier_locres_pak.ps1 (RFC4180 + fill policy + 3-class validation)
- build/package/zzz_atomicheart-ar_carrier_koKR_p2_P.pak + carrier_record.txt
- DECISIONS.md / KNOWN_ISSUES.md / STATUS.md / CHANGELOG.md / this report

## Standing rules at close
- No installs/uninstalls performed this cycle (Test-2 paks remain in ~mods).
- No uploads: git remote check EMPTY before commit; commit local-only.
- KI-010 (ST_GooseRunner_Hints) remains deferred until after the prototype.
