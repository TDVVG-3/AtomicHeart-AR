# Subtitle timing and HUD glyph checks — 2026-10-29

These are source fixes, not a new installed translation or a verified HUD-layout patch.
The published p12/p12g PAKs and the installer bundle still contain their original assets.

## Changes

- Convert `clip_seconds` to marker minutes before aggregation/comparison. A 300-letter
  page on a two-second clip previously generated `*0-0.353*` (21.18 seconds); the fixed
  script emits an end below two seconds, including for very short clips.
- Resolve groups of duplicate starts within the available interval; preserve six decimal
  places so close starts/end caps do not collapse during serialization. This ensures
  numerical ordering, not adequate reading time or synchronization with the voice.
- Cap overlapping page ends strictly between the page start and next start.
- Keep malformed, descending or unrepresentable tracks unchanged and list their keys
  for manual audio review. Do not partially rewrite an unparseable track.
- Check missing glyphs against the English source of each translated occurrence. A
  character inherited on one row cannot exempt a new occurrence on another row.
- Require coverage in each replacement face, including HUD fonts, and enforce complete
  Basic Latin. Read supplementary Unicode as codepoints rather than surrogate halves.
- Withdraw the unsupported claim that 150 px bottom padding limits subtitles to three
  lines. Correct both the report and the generator so future reports do not repeat it.

## Reproduce

From the repository root, on Windows with Python 3 and Windows PowerShell:

```powershell
python tests/test_display_regressions.py
New-Item -ItemType Directory -Force build/display-fix-check | Out-Null
powershell -NoProfile -File scripts/apply_subtitle_caps.ps1 -InTsV localization/master/atomic-heart-ar.tsv -OutTsV build/display-fix-check/candidate.tsv -Mode H1H2H3 -AuditRows reports/subtitle_stack_rows_p12.tsv
```

The 18 tests cover seconds/minutes, short clips, duplicate audit records, duplicate-start
groups, overlap, invalid tracks, missing durations, cross-row exemptions, a missing HUD
glyph, Basic Latin and supplementary Unicode. Font fixtures are synthetic cmap data;
they verify the checker, not rendering in the game.

The full-master regression processes 27,618 rows, preserves visible text and all other
columns, checks the timing bounds of every changed row and repeats the transformation
to require byte-identical output. The current canonical master produces:

| result | count |
| --- | ---: |
| rows with changed timing | 2,561 |
| duplicate starts shifted | 72 |
| explicit ends capped before next start | 59 |
| final singleton ends inserted | 91 |
| markerless pages given explicit ranges | 2,422 |
| descending tracks retained for audio review | 197 |
| malformed numeric track retained | 1 |
| final-page repairs unavailable without clip duration | 336 |
| changes on second application | 0 |

Counts describe the committed canonical master and stored audit mapping, not a newly
extracted game build or the final p12 release master. The malformed track is line 19736,
key `/5B8B06AA4583001BAF44468576710125`, containing `*0.-39.50*`. Its intended timing is
not guessed. Generated caps reports list keys of retained malformed/descending tracks.

## Still needed before a playable release

The game/extracted build assets are unavailable here. Rebuild the carrier from the
intended release master using the corrected scripts, run the font gate on the actual
payload, verify packing round-trip and record hashes. Keep the candidate separate from
the default until voice synchronization and reading time are checked.

No widget dimensions, font metrics or Arabic strings were changed. Layout clipping,
Arabic joining/RTL, mixed numbers and engine fallback still require the same-scene
runtime comparison in [the test guide](stack_test_guide.md). See the corrected
[layout evidence](subtitle_bottom_bar_p12.md). Historical generated gate reports do not
certify the new checker or candidate.
