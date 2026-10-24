# p11c adapted subtitle audit

Generated: 2026-10-24 16:22:27 +03:00

Gate for the intended end-marker change. The stock audit compares AR to EN byte-exact and
is expected to differ; this audit allows only an end increase on explicit ranges.

Rows compared: 27616 | explicit ranges: 683 | ends extended: 624
Mean end delta: 0.007 min | max: 0.096 min
Violations: 0

Checks: 12 non-Arabic columns byte-identical; visible Arabic text byte-identical;
marker count/order/type/start identical to English; no end shrinks; no new overlap.

## Examples

- L6408  *0.00-0.02* -> *0.00-0.025*
- L6408  *0.10-0.12* -> *0.10-0.125*
- L19679  *0.00-0.02* -> *0.00-0.025*
- L19679  *0.03-0.12* -> *0.03-0.125*
- L19679  *0.13-0.19* -> *0.13-0.195*
- L19679  *0.20-0.24* -> *0.20-0.245*

