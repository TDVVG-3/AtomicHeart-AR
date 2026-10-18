# Cycle 006 report (addendum) - Test 3 checklist issued

Date: 2026-10-18 19:5x. Spec hash: unchanged/PASS
(579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35).
Local git only; `git remote -v` empty; nothing uploaded.

## What was done

- Pulled the original Test-3 checklist and its A/B/C/D semantics back out of
  reports/history/report_005.md, and the Arabic seed list from
  localization/working/phase7_seed.csv, so the new checklist matches what is actually
  seeded in the installed carrier.
- Read-only verification of the installed set (nothing installed or removed):
  - `~mods/zzz_atomicheart-ar_carrier_koKR_p2_P.pak` 503,841 B
  - `~mods/zzz_atomicheart-ar_font_p2_plex_P.pak` 1,461,408 B
  - manifest atomic-heart-ar-install-manifest.json matches both SHA256 values
  - stock Paks root = 19 files, untouched
- Wrote reports/test3_checklist.md: a non-developer checklist for
  (1) the Settings page, (2) a Game Tips popup, (3) a dialogue/subtitle scene, with
  exactly what to screenshot and the A/B/C/D letter definitions per screen, plus an
  appendix containing the exact expected Arabic for the 9 settings labels, the 7 game
  tips and the 9 menu strings.

## Checklist content (summary)

- Do not install/uninstall; keep the language on Korean; English voice is normal.
- Settings (Step 1): the nine seeded labels - Balanced, Performance, Quality, Boost,
  On, Off, Fullscreen, Window, Borderless Window - should be Arabic; everything else on
  the page should be readable English (previously blank).
  Screenshot 1.
- Game Tips (Step 2): seven tutorial tips are seeded Arabic; trigger one by playing an
  early save. Screenshot 2 (or "not reached").
- Dialogue/subtitle (Step 3): observation only - Arabic is NOT expected here yet; we
  only want to know whether subtitles are visible, English, or blank. Screenshot 3.
- Letter definitions per screen: A = correct/visible, B = present but broken glyphs,
  C = readable but wrong language, D = blank/boxes/freeze.
- Stop-and-report trigger: any crash, freeze or anti-tamper/signature error.

## State

- Nothing was installed, removed or modified on the game side by this step.
- The dialogue program (cycle 006) stays complete: 10,394 of 10,394 (100%) English-source
  strings covered, master 27,618 rows, Arabic column empty (no translation performed).
- Awaiting the user's Test-3 report (3 screenshots + A/B/C/D).
