# Bottom subtitle bar — corrected interpretation (2026-10-29)

The earlier claim that bottom padding of 150 px means room for only three subtitle
lines is withdrawn. Padding is spacing around content, not its clipping rectangle.

## Recorded properties

These values come from the previous cooked-asset inspection. Raw extracted assets
are not committed; they are historical observations, not fresh runtime measurements.

| property | recorded value |
| --- | --- |
| WBP_Subtitle anchors | Min=(0.5, 0), Max=(0.5, 1) |
| alignment / auto-size | (0.5, 1) / True |
| dialogue overlay padding | Top=150, Bottom=150 px |
| SizeBox_1 | WidthOverride=2150; no height override |
| SubtitleScaleBox / subsystem scale | UserSpecified / 0.75 |
| WBP_OneSubtitle sentence slot | Bottom padding=100, Fill, Left / Bottom |
| sentence / speaker font size | 45 / 35 |
| container | VerticalBox; no ScrollBox observed |

## What remains unknown

Available height depends on parent geometry, viewport, DPI/layout scale and runtime
allocation. A bottom-anchored auto-sized stack can grow upward; the padding is not a
150 px content viewport. The old three-line/four-line arithmetic cannot identify
the clipping owner or prove why P-3's last words were cut.

It also assumed a 1.2 em line box, while the default Plex v3 retains different metrics
(see [font evidence](font_ab_evidence.md)). Neither number alone establishes the actual
rendered line height. The 100 px slot padding is worth measuring, not blindly removing.

## Timing and layout are separate

The p12 baseline does not repair timing. The published experimental p12g predates the
seconds/minutes fix in apply_subtitle_caps.ps1. Fixing source does not update a PAK:
a rebuilt, hash-identified candidate is required for a new comparison.

Explicit end markers may reduce overlap, but do not prove the HUD is fixed. The
0.15 s hide animation is not additional reading time. No widget, font or game asset
was changed by this correction.

## Verification still required

Use the same save, voice language, resolution and subtitle settings for every pass.
Compare English, Arabic p12 and a rebuilt corrected candidate separately. Capture
the full lifetime of one through four concurrent subtitle widgets at 1080p and 1440p:

- Last words, Arabic descenders/diacritics, wrapping and speaker names.
- Arabic joining, mixed Latin/numbers and key prompts.
- Whether old text remains alive or merely fades.
- Allocated widget bounds and first clipping ancestor, if tooling exposes them.

See the [test guide](stack_test_guide.md). The clipping owner, RTL appearance and
correct layout adjustment remain unverified until runtime testing.
