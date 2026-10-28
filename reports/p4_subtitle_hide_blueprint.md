# P4 - subtitle hide/fade blueprint evidence

**Generated:** 2026-10-26 15:28 +03:00
**Scope:** `WBP_Subtitle`, `WBP_OneSubtitle`, `WBP_NPCSubtitle`, `WBP_TypingTextBox`,
`BP_SubtitlesSubsystem`, and the cooked INI files. This was a read-only investigation of
the extracted cooked assets and the stock paks. No `.uasset` was re-serialized into a game
pak, no EXE/DLL was touched, and nothing was installed.

## Verdict

| verdict | finding |
| --- | --- |
| **CONFIRMED** | `WBP_OneSubtitle.Hide` clears the typing text, clears the speaker name, and calls `RemoveFromParent` immediately. There is no timer, fade, or delay in that function. |
| **CONFIRMED** | `WBP_Subtitle.HideSentence(Marker)` looks the marker up in the `Subtitles` map, calls `Hide` on the matching `WBP_OneSubtitle`, and removes the map entry. |
| **CONFIRMED** | `WBP_Subtitle.RemoveAllSubtitles` calls `VerticalBoxSubtitles.ClearChildren()` and clears the `Subtitles` map. It does not own a display timer. |
| **CONFIRMED** | `WBP_NPCSubtitle.HideSentence` calls `WBP_TypingTextBox.AnimatedHide()` when `bEnableShow && UpdateBackSize`; otherwise it clears the typing text with an empty `UpdateData`. |
| **CONFIRMED** | `WBP_TypingTextBox.AnimatedHide()` plays the `Hide` animation. Its only track is `RenderOpacity`, 1.0 -> 0.0 over **9000 ticks at 60000 ticks/s = 0.15 s**. |
| **CONFIRMED** | `WBP_NPCSubtitle` has a `HideBack` animation section of **9000 ticks / 60000 = 0.15 s**: `RenderOpacity` 1.0 -> 0.0, plus a `WidthOverride` key at 9000 ticks. `ShowSentence` plays it in reverse; `Tick` has a branch that plays it forward when `bIsShown` is true. |
| **CONFIRMED** | `WBP_NPCSubtitle.HideWidget(bInShouldHide)` only calls `Overlay_0.SetVisibility`: `Collapsed` (byte 1) when true, `HitTestInvisible` (byte 3) when false. No animation. |
| **LIKELY** | The subtitle page is hidden by the caller/marker timeline, not by a widget-owned display duration. `HideSentence` is the only marker-specific hide path in `WBP_Subtitle`; it is a consumer of the caller's marker, not a scheduler. |
| **LIKELY** | The **0.15 s** values are visual fade-out durations only. They do not add reading time: the fade starts when the caller invokes the hide path. |
| **UNKNOWN** | The exact handoff inside the native `SubtitlesSubsystem` parent class: which event (audio marker boundary, row end, audio end, or explicit `Duration`) invokes `HideSentence`, and whether the subsystem or a cutscene track owns that call. `BP_SubtitlesSubsystem` contains no script bytecode that can answer it. |
| **UNKNOWN** | Any global minimum-hold/hide-delay setting. None was found in the widgets or in the cooked INI files. |

## 1. Marker-to-widget path

`WBP_Subtitle` is a map of marker -> `WBP_OneSubtitle` widgets plus a `VerticalBoxSubtitles`
container.

| function | confirmed operations |
| --- | --- |
| `ShowSentence(Text, Speaker, Marker)` | creates a `WBP_OneSubtitle`; calls `UpdateData(Text, Speaker)`; `Map_Add(Subtitles, Marker, widget)`; `AddChildToVerticalBox(widget)`. |
| `HideSentence(Marker)` | `Map_Find(Subtitles, Marker)`; if found, `WBP_OneSubtitle.Hide()`; `Map_Remove(Subtitles, Marker)`. |
| `RemoveAllSubtitles()` | `VerticalBoxSubtitles.ClearChildren()` and `Subtitles` map clear. |
| `Construct()` | applies `SubtitleScaleBox.SetUserSpecifiedScale(SubtitleSizeScale)` and initializes the empty state. |
| `SetPause(bPause)` | forwards `SetPause` to every subtitle currently in the map. |
| `UseAlternativeLocation(bUseLocation)` | changes the `VerticalBoxSlot` vertical alignment; layout only. |

`WBP_OneSubtitle.Hide` is the decisive immediate path:

```text
Sentence_TypingTextBox.UpdateData(<empty text>)
Sentence_TypingTextBox.TypeText(0)
SpeakerName_1_sub.SetText(<empty text>)
RemoveFromParent()
```

There is **no** `SetTimer`, `SetLifeSpan`, `Delay`, or fade call in `Hide`. The widget is
gone in the same call.

## 2. NPC / typing widget fade

`WBP_NPCSubtitle` is used for the NPC/world subtitle presentation and owns the typing text
widget plus a backdrop (`BackSizeBox` / `Image_47`).

| function | confirmed operations |
| --- | --- |
| `ShowSentence(Text)` | if `bEnableShow`: set `bIsShown=true`; `WBP_TypingTextBox.UpdateData(Text)`; `TypeText(0)`; `PlayAnimation(HideBack, 0, 1, Reverse=1, 1.0)`; set `UpdateBackSize=true`. |
| `HideSentence()` | if `bEnableShow && UpdateBackSize`: `WBP_TypingTextBox.AnimatedHide()`; set `UpdateBackSize=false`; else `WBP_TypingTextBox.UpdateData(<empty text>)`. |
| `Tick(DeltaTime)` | if `bIsShown`: `PlayAnimation(HideBack, 0, 1, Forward=0, 1.0)` and set `bIsShown=false`; else set `UpdateBackSize=false`. |
| `PreConstruct()` | while shown/updating, sets `BackSizeBox.WidthOverride = TextDesiredSize.X + HorizontalFreeSpace`. |
| `HideWidget(bInShouldHide)` | sets `Overlay_0` visibility only: `Collapsed` (1) or `HitTestInvisible` (3). |
| `Construct` / `Destruct` | bind/unbind the game-paused delegate. |

`HideBack` animation data from the cooked asset:

| track | keys |
| --- | --- |
| `RenderOpacity` | time 0 -> 9000 ticks; value 1.0 -> 0.0 |
| `WidthOverride` | key at 9000 ticks; value 0.0 |

Tick resolution is `60000/1`, so `9000 / 60000 = 0.15 s`. `WBP_TypingTextBox.Hide` has the
same `RenderOpacity` 1.0 -> 0.0 curve over 9000 ticks, i.e. another **0.15 s** fade.

The code contains no `SetTimer`/`SetLifeSpan` call in any of these four widgets. `Delay`
appears only in `WBP_TypingTextBox` for typing cadence; its defaults are
`TimeBetweenChars=0.001` and `CharPerTick=1`. Those control typing speed, not display
duration.

## 3. Subsystem and data

`BP_SubtitlesSubsystem` is a Blueprint subclass of the native `SubtitlesSubsystem`. It has
no script functions. Its default object only configures:

| property | value |
| --- | --- |
| `WidgetTemplate` | `/Game/Core/UI/Subtitles/WBP_Subtitle` |
| `SubtitleSizeScale` | `0.75` |
| `Tables` | 34 subtitle data tables (base game + DLC) |
| `AdditionalTables` | 23 DLC narrative tables |
| `bShouldBeCreated` | true |

There is no hold/fade/minimum-display field on the subsystem. The individual data tables
have a `Duration` column, but the earlier P4 audit found it zero on all rows; the marker
strings are the timing data.

## 4. Cooked INI evidence

The read-only extracts are in `build/blueprint_probe/ini/`:
`DefaultGame.ini`, `DefaultEngine.ini`, `DefaultInput.ini`, `WindowsGame.ini`,
`WindowsEngine.ini`.

Searches found **0** hits for each of:

```text
SubtitlesSubsystem  SubtitleSizeScale  HorizontalFreeSpace  bEnableShow
TimeBetweenChars    ShowDelay          HideBack             RenderOpacity
DisplayTime         MinDuration        MaxDuration          SubtitleDuration
SubtitleHold
```

The only case-insensitive `subtitle` hit is the collision profile
`+Profiles=(Name="NTD",...,HelpMessage="Visibility Only for Narrative Subtitle")` in
`DefaultEngine.ini`. There is no `[/Script/AtomicHeart.SubtitlesSubsystem]` section and no
subtitle duration/hold/fade setting in the cooked INI files.

## 5. Safe property read-back experiment

A safe **copy-only** experiment was run with `scripts/p4_probe_subtitle_constants.ps1`:

- input: extracted `WBP_NPCSubtitle.uasset.json` (read-only);
- copy: `build/blueprint_probe/experiment/WBP_NPCSubtitle.uasset.property80.json`;
- changed property: `Default__WBP_NPCSubtitle_C.HorizontalFreeSpace`, `40.0 -> 80.0`;
- read-back: `80.0`; exactly **1** scalar property changed;
- all serialized `ScriptBytecode` blobs hash-identical before/after;
- no `.uasset` re-serialization, no pak, **NOT INSTALLED**.

`HorizontalFreeSpace` only widens the backdrop by `TextDesiredSize.X + 40 -> + 80`. It is
not a hold/duration control, so this experiment is evidence of a safe data/property
read-back path, not a candidate fix.

Evidence files:

- `build/blueprint_probe/subtitle_constants.json`
- `build/blueprint_probe/experiment/readback.json`
- `build/blueprint_probe/experiment/WBP_NPCSubtitle.uasset.property80.json`

## 6. What this means for p11e / p11f / p11ef

The Arabic timing variants change only localization data. They do not change the widgets,
the 0.15 s fades, or the native hide schedule.

- `p11e` adds an explicit end to the final singleton page. The caller now has an explicit
  end marker to pass to `HideSentence` for that page.
- `p11f` shortens long Arabic pages so the existing marker window is more readable.
- Neither variant can create a hold where no explicit end exists; the remaining singleton
  pages still depend on the native subsystem/audio timeline.

## 7. Residual work

The native `SubtitlesSubsystem` implementation is not in the cooked Blueprint data. Closing
the last `UNKNOWN` would require read-only binary/symbol inspection of the native class or
an in-game timing test. No bytecode surgery was performed.
