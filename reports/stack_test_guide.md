# VEGA 9 archive subtitle stack - non-developer test guide

**Generated:** 2026-10-28 14:23:47 +03:00
**What this tests:** the cutscene at the VEGA 9 archive where several people speak at
the same time and the bottom Arabic line looks cut. You do **not** need to edit files,
install mods, or read code. The coordinator sets up each pass; you play the same scene
three times and report what you see.

## Correction — 2026-10-29

The published experimental p12g predates the seconds/minutes fix. Pass C below must
use a newly rebuilt, hash-identified candidate from the corrected scripts; do not
interpret the old PAK as a test of this fix. No corrected PAK is supplied by the source-only
repair. Record voice language, resolution, subtitle settings and a short video of the
entire line lifetime. Repeat at 1080p and 1440p if available. Check Arabic joining,
diacritics, mixed Latin/numbers and key prompts as well as overlap/clipping.
The 150 px padding is not a proven three-line display limit; see the corrected
[layout evidence](subtitle_bottom_bar_p12.md).

## 1. The scene to reach

**Location:** VEGA 9, inside the **Academy of Consequences archive** (the room with the
`VEGA 9 ARCHIVE` sign and the archive terminal).

**Story point:** P-3 and Larisa Filatova enter the archive and meet Viktor Petrov. This is
the scene where Larisa asks whether everything is ready, Viktor says the operation was
painless, and P-3 identifies himself as Major Nechaev.

**Internal scene name (for the coordinator):** `VO_CS_01_15` in
`DT_Subtitles_Cutscenes`.

### How to get there

1. Load a save **before** entering the archive. A save from the corridor or the elevator
   just outside the archive is ideal. Do not use a save from after the cutscene.
2. Follow the objective **"Reach the Archive"** / **"Academy of Consequences: Archive"**.
3. Enter the archive with Larisa and approach the archive terminal / the group near it.
4. The cutscene starts automatically. Do not skip it.
5. Stop at the moment when **four subtitle lines are on screen at once**. The four lines
   are:

| order | speaker | English line to recognize |
|---:|---|---|
| 1 | Larisa | "Are you okay? Is everything ready? Did you pull it off?" |
| 2 | Viktor | "Don't worry, honey, I'm right as rain. The operation was totally painless." |
| 3 | Larisa | "Good. You need to leave right now. There's a man coming for you, he's armed and wearing an experimental Polymer glove." |
| 4 | P-3 | "Major Nechaev, special operations. And that's the last question you get." |

The fourth line is the long P-3 line that looks cut. The previous lines may still be on
screen when it appears.

If you do not have a save near this scene, ask the coordinator for the shared VEGA 9 test
save. Do not overwrite your only save while testing.

## 2. The three passes

The coordinator installs one variant at a time. You only change the game's text language
and play the scene.

| pass | game text language | installed carrier | purpose |
|---|---|---|---|
| A - English baseline | English | anything (the mod only replaces the Korean text slot) | see the original four-line layout and how much room the game normally has |
| B - Korean p12 | Korean | `p12` (default release) | see the Arabic stack with the release build |
| C - Korean p12g | Korean | `p12g` (experimental timing build) | see whether explicit subtitle ends make the old lines disappear sooner |

Use the **same save**, the **same graphics settings**, and the **same screen resolution**
for all three passes. Do not change the subtitle size/scale between passes.

### Changing the game language

1. Main menu or pause menu -> **Options / Settings** -> **Gameplay** or **Interface**.
2. Set **Text Language** to **English** for pass A and **Korean** for passes B and C.
3. Apply and restart the game if the menu asks for a restart.
4. Load the VEGA 9 save again.

The mod replaces the Korean text slot. Setting the game to English gives the original
English lines; setting it to Korean gives the Arabic test text.

## 3. What to watch

Watch the same four-line moment in every pass. Use the checklist below.

### A. Visibility and timing

- [ ] Do all four lines appear at all?
- [ ] Does the fourth (P-3) line appear **before** the earlier lines disappear?
- [ ] How many lines are visible at the same time: 2, 3, or 4?
- [ ] Does an earlier line disappear when the next speaker starts, or does it stay?
- [ ] Does any line stay on screen after the scene/voice has ended?
- [ ] Does any line appear twice, or in the wrong order?

### B. The cut line

- [ ] Is the bottom P-3 line **cut off at the bottom edge** of the screen?
- [ ] Is it cut at the **left or right** edge, or is the last word missing?
- [ ] Does the P-3 line wrap onto a second line? If yes, how many lines does it occupy?
- [ ] Can you read the whole P-3 line before it disappears?
- [ ] Is the speaker name (`الرائد` for P-3) visible above the line?

### C. Comparison between p12 and p12g

- [ ] In p12, which line is cut, and at what moment?
- [ ] In p12g, do the earlier "Viktor!" lines disappear sooner?
- [ ] In p12g, is the P-3 line still cut? If yes, the remaining problem is the bottom-bar
      layout, not the missing subtitle end.
- [ ] Does p12g introduce a new problem: a line disappearing too early, a missing line,
      or text that is cut at the end of its allowed time?

### D. Text checks (quick)

- [ ] P-3's speaker label reads **الرائد**.
- [ ] Weapon and item names remain in English inside the Arabic sentence; the description
      around them is Arabic.
- [ ] No line is entirely English when it should be Arabic.
- [ ] No line shows `P-3` as the visible speaker label.

## 4. What to report

Send the coordinator a short report with these items. A screenshot or short video is more
useful than a long description.

```text
Tester:
Date/time:
Game version:
Save used (location):
Resolution / graphics preset:
Pass: A English / B Korean p12 / C Korean p12g
Variant shown in the install manifest:

Four-line moment:
- Lines visible at once:
- Which line is cut:
- Cut at: bottom / left / right / last word missing / not cut
- P-3 line wraps to: 1 / 2 / 3 lines
- Earlier lines disappear before P-3: yes / no / partially
- Any line stays after the voice: yes / no
- P-3 label shows الرائد: yes / no
- Any English-only or wrong-language line: yes / no

Screenshots/video:
- File name(s):
- Time code of the four-line moment:

Comparison:
- p12 vs p12g difference:
- Is the cut still present in p12g: yes / no
- New problem in p12g:

Severity:
- cosmetic / hard to read / blocks understanding / missing text
```

### What counts as a bug

| observation | severity |
|---|---|
| P-3 line is cut at the bottom and the last words are unreadable | **blocks understanding** |
| P-3 line is readable but touches the screen edge | cosmetic |
| An earlier line stays until the next scene | hard to read / timing bug |
| A line disappears before it can be read | hard to read |
| The speaker label is `P-3` instead of `الرائد` | text bug |
| A weapon/item name is translated when it should stay English | text bug |
| A line is entirely English or entirely Korean | wrong language |

## 5. For the coordinator only

Do not run these commands while a tester is playing. Each command writes only inside
`Paks\~mods`; it takes a snapshot, backs up the current set, verifies the install, and
rolls back automatically on failure.

```powershell
# Pass B - default release
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12_tips_x150

# Pass C - experimental timing build
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12g_tips_x150

# Pure p12 / p12g without the tips add-on
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12g

# Add the RU-only dialogue add-on
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12g -RuOnly

# Restore the release default after testing
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p12_tips_x150

# Roll back to the previous known-good set
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\switch_variant.ps1 -Variant p11c_tips_x150
```

The install manifest is
`Paks\~mods\atomic-heart-ar-install-manifest.json`. It lists the exact three files for the
default set: `zzz_atomicheart-ar_carrier_koKR_p12_P.pak`,
`zzz_atomicheart-ar_font_p3_unhinted_P.pak`, and
`zzz_atomicheart-ar_tips_x150_P.pak`.

### Why p12g may not change the cut

`p12g` adds explicit end times where the Arabic text has a page start and caps the final
page. The VEGA 9 lines are markerless in `p12`; `p12g` gives them a `*0-end*` range using
the voice clip length and a 15 characters/second reading allowance. That can make the
earlier short lines disappear sooner. It cannot make the bottom bar taller. If the cut
remains when four lines are visible, the cause is the layout arithmetic in
`reports/subtitle_bottom_bar_p12.md`: the stack is bottom-anchored, scaled to 0.75, and
has only about 150 px of bottom safe area, which is roughly three line boxes. The P-3 line
is the fourth/bottom-most line and is the one that gets cut.

## 6. Where to look for the evidence

- `reports/subtitle_stack_audit_p12.md` - before state; the four screenshot lines are H3.
- `reports/subtitle_stack_audit_p12g.md` - after state; the four lines now have `*0-end*`
  ranges and the scene H3 count is 0.
- `reports/subtitle_bottom_bar_p12.md` - layout measurements and the 150 px / 100 px /
  33.75 px arithmetic.
- `reports/p4_subtitle_hide_blueprint.md` - confirmed immediate-hide path; no fade/hold
  timer in the subtitle widgets.
