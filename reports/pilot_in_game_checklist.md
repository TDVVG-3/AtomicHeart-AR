# Pilot in-game check (non-developer checklist)

Date: 2026-10-18  |  Pilot pak: `zzz_atomicheart-ar_carrier_koKR_p3_P.pak`  |  Status: NOT INSTALLED

This is the pilot gate. Nothing has been installed for you. This sheet tells you exactly
what to install, where to look, what to screenshot, and what to send back.

You do NOT need to know anything about the project to run this. Just follow the steps.

---

## 0. What is different from the build you already tested (Test 3)

| thing | Test 3 (what you have now) | Pilot (p3) |
|---|---|---|
| Arabic coverage | 25 labels (menu + settings + game tips) | 85 rows: 25 labels + 20 UI + 20 short dialogue + 20 long subtitles |
| Scope | menus/settings/HUD only | menus, settings, tutorials, items, PEAR apps, dialogue subtitles, long cutscene text |
| Carried text outside Arabic | Korean, replaced with English | English for all 35 scopes (nothing is left Korean) |
| Game-tip icons | BROKEN in the tips we shipped (double quotes inside the icon tag) | FIXED (this pilot proves it) |
| Font pak | `..._font_p2_plex_P.pak` (keep it, unchanged) | same font pak, no change |

The font pak is not touched by this pilot. The only new file is the p3 carrier pak.

---

## 1. Before you start

1. Close Atomic Heart completely (no game window, no launcher running).
2. Do NOT verify game files and do NOT update the game while a mod pak is installed.
3. Keep the game language set to Korean exactly as it was for Test 3. Do not change it.
4. Do not modify, move, or delete any other pak in the Paks folder.

## 2. How to install (one command)

Open PowerShell in `C:\AtomicHeart-AR` and run:

    powershell -NoProfile -ExecutionPolicy Bypass -File scripts\install_mod.ps1

The new pilot pak is already sitting in `build\package\`. If your install script asks
which pak, point it at:

    C:\AtomicHeart-AR\build\package\zzz_atomicheart-ar_carrier_koKR_p3_P.pak

Expected: the file appears in the game's `~mods` folder and the old p2 carrier is replaced.
The font pak `zzz_atomicheart-ar_font_p2_plex_P.pak` must stay installed.

If you would rather I prepare the exact install command for your setup, say so in your reply -
I will not install anything myself without your go-ahead.

## 3. Where to look (in this order)

Work through the areas below. Each one names the exact text to look for.

### Area A - Main menu (should look the same as Test 3)
- Continue / New game / Load game / Options / Exit.
- PASS looks like: correct Arabic, letters connected, order right-to-left, no blank labels.

### Area B - Options > Settings (same as Test 3)
- Look at Window Mode and the ON/OFF/QUALITY/PERFORMANCE labels.
- PASS looks like: Arabic renders, Latin values (e.g. OFF/ON) still readable, no blanks.

### Area C - HUD / quest panel / inventory (this is NEW: English should appear)
- Any quest title and objective text, the ammo/health chips, the item grid.
- The 20 UI rows include tutorial prompts that appear in the first minutes:
  - "CLIMB objects by PRESSING <Jump> next to them."
  - "To activate the scanner, hold <Scan>."
  - "To emerge from the Polymer, use <Dodge>."
  - "Objects that you can grab onto are often highlighted in yellow."
  - "To vault or climb an object, press <Jump>."
- PASS looks like: those prompts show ARABIC, and the button/key icon sits inside the
  sentence where the tag is (not at the end, not missing).
- Also check item names in crafting/inventory: Endorphin Adapter, Neuropolymeric
  supercharger, Kinetic Reflector, Technostasis, Rough draft, Close the door on the way out.
- WEAPONS/ITEMS screen: nothing should be blank. Any blank box or "tofu" square is a FAIL
  to report.

### Area D - Subtitles and dialogue (the main event)
- Start/continue a save where CHAR-les (the glove) talks to you, or trigger any dialogue
  with subtitles. Any early conversation works.
- The 20 short + 20 long pilot lines are spread across the base game and the DLC dialogue
  scopes, so you may not hit every one - that is fine, report what you see.
- Things to watch for on the Arabic subtitle line:
  1. letters connected and shaped (not isolated letters)
  2. reading order right-to-left
  3. the line is not blank, not boxes, not upside-down
  4. numbers stay Western (1951, 3826)
  5. Latin key names inside a sentence stay Latin (E, Q, ESC) and are readable
  6. for the long lines: the emotion markers and break marks are not visible as garbage
     text (e.g. you should NOT see `*0.10*` printed on screen; it is an engine marker)

### Area E - Game tip popups (the fix)
- Trigger any tip popup (they appear on screen edges during the intro and in some areas).
  If you cannot reach one, say so - it stays NOT TESTED, that is an acceptable answer.
- The tips that had broken icons are the ones with an icon inside the sentence, e.g.
  "You've been injured! Press and hold [heal icon] to heal".
- PASS looks like: the sentence is in Arabic AND the icon/key is drawn inline.
- FAIL looks like: a literal text fragment such as `id=""Button...""` or a missing icon.

### Area F - PEAR terminal apps (quick)
- Open any PEAR terminal and look at the app/entry names.
- Four pilot rows live there: "Intrusion", "Chess club", "Man posing for a picture",
  "Rough draft".
- PASS looks like: Arabic, no blanks, no cut-off text.

### Area G - Long multi-speaker text (only if convenient)
- Three pilot lines are long transcripts with speaker labels (surgery scene, a museum
  curator commentary, an electrician talking about a robot). They are rare to run into.
- If you see one: check that the speaker label and the speech are readable and that nothing
  spills off-screen. If you never see one, answer "not reached".

## 4. What to screenshot (one per area)

| area | screenshot | what I compare it against |
|---|---|---|
| A main menu | whole menu | unchanged from Test 3 |
| B settings | the window-mode row + values | unchanged from Test 3 |
| C HUD/tutorial | one tutorial prompt **and** the inventory grid | new Arabic + English elsewhere |
| D subtitles | any Arabic subtitle line | the pilot lines in this sheet's sample |
| E game tip | the tip popup with the icon | the icon must be inline, not text |
| F PEAR terminal | the app list | four Arabic entries |

If the game refuses to start, or the screen stays black, that is also a result: screenshot
it and say "did not boot".

## 5. What to send back (copy this block and fill it in)

    Area A main menu:        A / B / C / D  (A = all good, D = broken; same scale as Test 3)
    Area B settings:         A / B / C / D
    Area C HUD/tutorial:     A / B / C / D   + note which prompts you saw
    Area D subtitles:        A / B / C / D   + did you see ARABIC? connected letters? RTL?
    Area E game tip:         A / B / C / D / not reached   + was the icon drawn inline?
    Area F PEAR terminal:    A / B / C / D / not reached
    Area G long transcript:  A / B / C / D / not reached
    Anything blank or as a box (tofu):  yes / no  -> where:
    Anything that looked reversed:      yes / no  -> where:
    Subtitles still Korean anywhere:    yes / no  -> where:
    Free notes:

Scale used in Test 3: A = everything good, B = minor problem, C = major problem,
D = broken/blank. If you prefer, just describe what you saw in plain words.

## 6. How to go back

- To restore the previous state, reinstall the Test 3 pak:
  `build\package\zzz_atomicheart-ar_carrier_koKR_p2_P.pak` (same install script).
- To remove the mod entirely: `scripts\uninstall_mod.ps1` (removes our files from `~mods`).

## 7. Reference material (for you, if you want to compare text)

- `localization/references/AR_EN_REFERENCE.md` - every translated row, Arabic first then
  English, grouped by game area.
- `reports/review_sample.md` - the 40-row review sample for this pilot.
- `glossary/glossary.tsv` + `glossary/terminology.md` - the terms and the style rules the
  translation follows.
- `glossary/glossary_questions.md` - 26 decisions I need from you (defaults are marked).
