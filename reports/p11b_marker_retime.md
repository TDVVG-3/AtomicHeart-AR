# p11b marker-retime variant (experiment)

Generated from the master by slowing every subtitle cue by 15%: each marker number in
the Arabic cell is multiplied by 1.15. Marker count, order and format are unchanged.
Hypothesis under test: if the Arabic pages disappear too early / play too fast, a uniform
15% lengthening should be visible; if the markers are absolute audio cues, this variant
will desync progressively and the p11 (byte-exact English markers) build wins.

Rows with markers in both EN and AR: 537 | rows retimed: 537
Ratio: mean 1.150 | min 1.150 | max 1.150

## Examples

- L2  r=1.150  *0.10* -> *0.12*
- L3  r=1.150  *0.10* -> *0.12*
- L92  r=1.150  *0.07* -> *0.08*
- L111  r=1.150  *0.06* -> *0.07*
- L112  r=1.150  *0.10* -> *0.12*
- L122  r=1.150  *0.08* -> *0.09*
- L134  r=1.150  *0.10* -> *0.12*
- L140  r=1.150  *0.06* -> *0.07*

This variant is NOT validated by scripts/subtitle_timing_audit.ps1 on purpose: the audit
proves the shipped master keeps the English marker values byte-exact, and this file is the
deliberate counter-example for the in-game A/B test. Only the pak built from it is shipped,
as an alternative (p11b), never as the default.
