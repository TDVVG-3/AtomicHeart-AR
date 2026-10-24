# P4.1 - where tip / popup / notification display time lives

**Date:** 2026-10-24 16:23 (+03:00)
**Method:** read-only extraction from `pakchunk0-WindowsNoEditor.pak` with `repak`, JSON dumps
with `tools/bin/uasettool`, full float-property scan of every dumped asset. Originals are
kept under `build/p4/`; nothing in the game folder was touched.

## Verdict per source

| # | source (asset) | field | current value | verdict | why |
| --- | --- | --- | --- | --- | --- |
| 1 | `Core/Data/InputTips/**.DA_InputTipInfo` | `DurationTime` (Float), gated by `bHasDuration` (Bool) | 5 / 7 / 8 / 10 / 15 / 20 s (per asset) | **CONFIRMED** | 20 assets carry `bHasDuration=True`; class `DA_InputTipInfo` is consumed by `BP_InputTipComponent`, which drives `WBP_ShortHint` (short tips) and `WBP_FullscreenHint_Single/Double` (tutorials) |
| 2 | `Core/UI/HUD/Widgets/WBP_ItemNotificationEntryWidget` | `WaitTime` (Float) | **3.5 s** | **CONFIRMED** | widget owns `TimerHandle` + `K2_SetTimerDelegate` + `Show`/`Hide` animations; this is the per-item pickup/recipe notification hold |
| 3 | `Core/UI/HUD/WBP_ItemsNotifiersWidget` | `MinDelayBetweenNotifications` (Float) | **0.5 s** | **LIKELY** | queue spacing between two notifications; not the reading time of one notification |
| 4 | `Core/UI/Widgets/Hints/ShortHint/WBP_ShortHint` | `Delay` (Float) | 0.03 s | **NOT DISPLAY TIME** | animation tick / start delay; excluded from all variants |
| 5 | `WBP_QuestNotify`, `WBP_NewPlaceNotification`, `WBP_CustomItemNotification`, `WBP_RecipeNotification`, `WBP_DeactivateNotification` | - | - | **UNKNOWN** | full float scan (`build/p4/ui_time_fields.tsv`) finds no scalar time field; lifetime is driven by widget animations and the spawning system |
| 6 | `DA_InputTipInfo` assets with `DurationTime` but no serialized `bHasDuration` (e.g. `DA_ScannerTip` 20 s) | `DurationTime` | 7-20 s | **LIKELY** | field exists, the Bool flag is not serialized (class default unknown); left unscaled so event-driven tips do not change behaviour |

Evidence files:

- `build/p4/tip_durations.tsv` - all 60 `DA_InputTipInfo` assets: `bHasDuration`, `DurationTime`, `HintVisibilityRules`.
- `build/p4/ui_time_fields.tsv` - every float property whose name looks time-ish in the 11 UI widgets; exactly 3 hits (rows 2-4 above).
- `build/p4/tips_src` - 122 original files + 60 JSON dumps.
- `build/p4/ui_src` - 11 widget packages + JSON dumps.

## Variants built (data-only overrides, originals untouched)

| variant | pak | bytes | SHA256 | changes |
| --- | --- | --- | --- | --- |
| `tips_x125` | `zzz_atomicheart-ar_tips_x125_P.pak` | 75,853 | `3f585026c33aafacab017f6be888dc362ab35874e5f184ee8f12819d4937b95b` | 20 `DurationTime` x1.25 (5->6.25, 7->8.75, 8->10, 10->12.5, 15->18.75, 20->25) + `WaitTime` 3.5->4.375 |
| `tips_x150` | `zzz_atomicheart-ar_tips_x150_P.pak` | 75,853 | `36de01c37231a8b88ec9fc744c4f663bb8461a56adede9a6a2151d78c7ef7fcc` | same x1.5 (7.5 / 10.5 / 12 / 15 / 22.5 / 30) + `WaitTime` 3.5->5.25 |

Both paks hold 42 entries (21 packages x `.uasset`+`.uexp`). Verification performed:

1. read-back of every edited float from the written package (42/42 equal, `build/p4/tips_variants_build.tsv`);
2. full property-map diff against the original dump - only the edited property differs (`other_props=same` on every row);
3. `repak` unpack and per-entry SHA256 comparison - 42/42 byte-identical.

**State: NOT INSTALLED.** p11 remains the default; no `~mods` write.

## What to look at in game

- Short input tip (e.g. first tutorial prompt / "repair weapon"): should stay ~1.25x or 1.5x longer.
- Item pickup notification: should remain on screen 4.4 s / 5.25 s instead of 3.5 s.
- Fullscreen tutorial hints without `bHasDuration`: expected unchanged (input-dismissed).
- Quest / new-place banners: expected unchanged (UNKNOWN, animation-driven).
