# Current State

Status snapshot after Cycle 003 (2026-10-18). Rule: PASS/FAIL/PARTIAL/BLOCKED/NOT TESTED
labels only; never claim success without evidence.

```
Phase 1  Repo structure + governing docs:   PASS (committed)
Phase 2  Steam + game detection:            PASS (App 668580, buildid 24534183)
Phase 3  Archive inventory (19 PAKs):       PASS (SHA256-hashed, headers parsed)
Phase 4  Toolchain:                         PASS (repak, UnrealLocres, LocResUtility v2.1.1 + .NET 8.0.32)
Phase 5  Extraction + master DB:            PASS (565 locres+locmeta; 27,618-row TSV)
Phase 6  Font discovery:                    PASS (49 fonts scanned)
Phase 7  Prototype attempt 1 (v1):          FAIL (font: Naskh swap blanks all Latin UI text,
                                            LIKELY caused FPS collapse/hang; paks UNINSTALLED)
Phase 7  Locres/locmeta path:               NOT TESTED (language menu not reached in test 1)
Phase 7  Font v2 (IBM Plex Sans Arabic):    BUILT + verification PASS (NOT TESTED in-game)
Mod loading pipeline (pak mount):           PASS (game booted, rendered with mod payloads)
Signature enforcement:                      not observed (game booted with modded paks mounted)
Arabic translation:                          25 strings (prototype seed corpus)
RTL rendering test:                          NOT TESTED
```

## Key findings this cycle (Cycle 003)

1. **Boot + pak mount WORKS**: the game launched and visibly used the mod payload (font
   swap active) — mod loading, and mounting our paks, are CONFIRMED functioning. Even the
   modified locmeta (ar culture added) did not block boot. No signature enforcement was
   observed in practice.
2. **v1 font approach FAIL CONFIRMED**: the menu rendered with empty buttons; only "2"
   and "!" were visible. Noto Naskh Arabic UI Latin-Basic coverage = 15 codepoints
   (digits + minimal punctuation) — exactly matching what survived on screen. Latin was
   blanked by the swap, and the heavy FPS collapse is LIKELY a missing-glyph fallback
   storm (UNCONFIRMED: no engine log; KI-012).
3. **No engine log exists** (KI-012): Saved\Logs has only the NGX log; diagnosis relies
   on render-output analysis + isolated variant tests. `-log` launch option to be used
   next round (optional).
4. **v2 font pak built and verified** (DEC-014): payload = IBM Plex Sans Arabic
   (official IBM/plex release 1.1.0, OFL 1.1, SHA256 recorded); coverage gate PASS —
   Latin-Basic 95/95, Arabic core 42/42, presentation forms complete.
5. Uninstall_mod.ps1 re-verified this cycle: both paks + manifest removed exactly, game
   folder back to stock (19 paks, no ~mods).

## Next

STOP. Awaiting user instruction to run test 1 (locres-only pak: expect normal Latin UI,
language list gains العربية) and test 2 (font v2 + locres paks: expect readable Plex
Latin; then Arabic selection test → shaping/RTL verdict). Full checklist in
lastreport.md / reports/history/report_003.md.
