# Bottom subtitle bar - layout evidence for the VEGA 9 stack

**Generated:** 2026-10-28 14:22:32 +03:00
**Scope:** read-only inspection of the cooked `WBP_Subtitle`, `WBP_OneSubtitle`,
`WBP_TypingTextBox`, and `BP_SubtitlesSubsystem` exports already extracted under
`build/extracted/`. No `.uasset` was re-serialized, no bytecode was patched, no pak was
built, and nothing was installed.

## Verdict

| verdict | finding |
| --- | --- |
| **CONFIRMED** | `WBP_Subtitle` is a full-height, bottom-anchored canvas: `CanvasPanelSlot_0` anchors are `Min=(0.5, 0)`, `Max=(0.5, 1)`, alignment is `(0.5, 1)`, bottom offset is `0`, and `bAutoSize=True`. The subtitle stack therefore grows upward from the bottom edge. |
| **CONFIRMED** | The dialogue overlay slot reserves `Padding.Top=150.0` and `Padding.Bottom=150.0` px. The visible subtitle area above the bottom safe edge is therefore about 150 px before any widget reaches the screen edge. |
| **CONFIRMED** | `SizeBox_1` has `WidthOverride=2150.0` with the override enabled and no height override. The subtitle column is wide and auto-height; there is no fixed-height subtitle box in that branch. |
| **CONFIRMED** | `SubtitleScaleBox` uses `Stretch=EStretch::UserSpecified`; `BP_SubtitlesSubsystem.SubtitleSizeScale=0.75`. The sentence font is `45`, so the rendered sentence size is `45 x 0.75 = 33.75` px; the speaker font is `35`, i.e. `26.25` px. |
| **CONFIRMED** | `WBP_OneSubtitle` contains a sentence `SizeBox` whose vertical-box slot has `Padding.Bottom=100.0`, `SizeRule=Fill`, `HAlign_Left`, `VAlign_Bottom`. This is a per-subtitle bottom gap, not a scrollbar or a duration control. |
| **CONFIRMED** | The exported widgets contain no `ScrollBox`, no `SetClipping`, and no subtitle-life timer in `WBP_Subtitle` / `WBP_OneSubtitle`. Stacking is plain `VerticalBox.AddChildToVerticalBox`. |
| **LIKELY** | Four concurrent subtitle widgets (the three earlier VEGA lines plus the long P-3 line) need more than the 150 px bottom safe area. At a typical 1.2 em line box, one rendered line is about `1.2 x 33.75 = 40.5` px; four lines are about `162` px, already 12 px over the 150 px bottom padding before speaker names and the 100 px sentence gap are counted. The line nearest the bottom edge is the one that looks cut in the screenshot. |
| **LIKELY** | The 100 px sentence-slot bottom padding is applied inside each `WBP_OneSubtitle`; with several widgets the gap is paid repeatedly, so a four-line stack can exceed the bottom bar even when each individual line is short. |
| **UNKNOWN** | The exact engine clip owner (canvas, `SizeBox`, overlay, or viewport) and whether the 100 px padding is applied once per widget or once per page. The cooked exports do not identify a single clipping rectangle. A runtime test with 1, 2, 3, and 4 simultaneous lines is required to close this. |
| **UNKNOWN** | The `SizeBox_0` 1x1 override in `WBP_Subtitle` looks like a spacer/background branch, not the text container; if it were the sole text container no subtitle text would render at normal size. Its exact role is not proven from the export alone. |

## Evidence chain

### `WBP_Subtitle`

| node | property | value |
| --- | --- | --- |
| `CanvasPanelSlot_0` | anchors minimum | `X=0.5`, `Y=0.0` |
| `CanvasPanelSlot_0` | anchors maximum | `X=0.5`, `Y=1.0` |
| `CanvasPanelSlot_0` | alignment | `X=0.5`, `Y=1.0` |
| `CanvasPanelSlot_0` | offsets bottom | `+0` |
| `CanvasPanelSlot_0` | `bAutoSize` | `True` |
| dialogue overlay slot | padding top / bottom | `150.0` / `150.0` px |
| `SizeBox_1` | width override | `2150.0` px (override on) |
| `SizeBox_1` | height override | none |
| `SubtitleScaleBox` | stretch | `EStretch::UserSpecified` |
| `VerticalBoxSubtitles` | child policy | plain vertical stack; no scroll/clip property in the export |
| `BP_SubtitlesSubsystem` | `SubtitleSizeScale` | `0.75` |

The bottom anchor plus auto-size means the stack has no intrinsic vertical cap in this
widget. The only explicit vertical reserve found in the chain is the 150 px overlay
padding. A larger stack therefore competes with that reserve rather than with a fixed
subtitle height.

### `WBP_OneSubtitle`

| node | property | value |
| --- | --- | --- |
| root canvas slot | anchors maximum | `X=1.0`, `Y=1.0` |
| root canvas slot | `bAutoSize` | `True` |
| sentence `SizeBox` slot | `SizeRule` | `Fill` |
| sentence `SizeBox` slot | padding bottom | `100.0` px |
| sentence `SizeBox` slot | horizontal / vertical alignment | `HAlign_Left` / `VAlign_Bottom` |
| `Sentence_TypingTextBox` | font size | `45` |
| `SpeakerName_1_sub` | font size | `35` |
| speaker widgets | justification | `ETextJustify::Center` |

## Arithmetic for the screenshot

The archive scene `VO_CS_01_15` has four lines in the screenshot sequence:
`Larisa_15`, `Victor_16`, `Larisa_17`, and `P3_18`. The P-3 line is the long one.

- Rendered sentence font: `45 x 0.75 = 33.75` px.
- Typical line box at 1.2 em: `33.75 x 1.2 = 40.5` px.
- Three lines: about `121.5` px, which fits inside the 150 px bottom padding with ~28.5 px to spare.
- Four lines: about `162` px, which is 12 px past the 150 px padding before speaker names and the 100 px sentence gap are counted.
- If the P-3 line wraps to two rendered lines, the total is five lines (~202.5 px), well past the reserve.

This matches the screenshot shape: H3 timing lets several voice events overlap, and the
bottom bar has room for roughly three line boxes at the current 0.75 scale. The P-3 line
is the newest/bottom-most line, so it is the one that looks cut.

## What this does and does not prove

- It **does** prove that the subtitle stack is bottom-anchored, auto-sized, scaled by
  0.75, and padded by 150 px bottom / 100 px per sentence slot. There is no hidden
  subtitle hold timer in these widgets.
- It **does** explain why H3 concurrency produces the screenshot: H3 adds lines, and the
  layout has only about three line boxes of bottom safe area at the current font/scale.
- It **does not** prove the exact clipping rectangle. The export has no single
  `SetClipping`/`ScrollBox` node; the clip may be the viewport, the canvas, or a parent
  `SizeBox`. A runtime A/B with the same scene at 1, 2, 3, and 4 simultaneous lines is the
  only way to close that.
- No bytecode, widget, font, or `.uasset` change was made for this investigation.

## Relation to p12 and p12g

- `p12` is the clean baseline plus CHANGE 1 and CHANGE 2. It does not change subtitle
  timing, so the H3 stack remains.
- `p12g` adds explicit `*0-end*` ranges to markerless final pages and caps the other
  pages. In the audit, the four screenshot lines now carry `*0-end*` ranges and the
  baseline H3 count for the scene drops from 4/4 to 0/4. That reduces how long each line
  can remain, but it does not change the 150 px bottom reserve or the 0.75 scale.
- If `p12g` still shows a cut line when four lines are on screen at once, the remaining
  cause is the layout arithmetic above, not a missing end marker.
- The play-test guide is `reports/stack_test_guide.md`; it asks testers to compare the
  English source, Korean with `p12`, and Korean with `p12g`, and to report whether the
  old lines disappear and whether the bottom line is clipped.
