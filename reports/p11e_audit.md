# p11e structural and formula audit

Generated: 2026-10-25 23:37:44 +03:00

Rows with Arabic markers: 537 | final singleton converted: 140 | violations: 0

Checks: row/column count; 12 non-Arabic columns byte-identical; visible Arabic text byte-identical;
marker count/order and every start identical; only the final singleton may gain an end; no earlier
marker type changes; no end reaches a later start; end >= max(clip end, t + Arabic chars/15 + 1.2 s).

## Examples

- L259  *0.08* -> *0.08-0.263* (88 chars)
- L900  *0.12* -> *0.12-0.378* (103 chars)
- L1134  *0.10* -> *0.10-0.317* (74 chars)
- L1195  *0.07* -> *0.07-0.230* (46 chars)
- L1231  *0.14* -> *0.14-0.442* (131 chars)
- L1274  *0.19* -> *0.19-0.637* (111 chars)
- L1275  *0.11* -> *0.11-0.337* (101 chars)
- L1320  *0.14* -> *0.14-0.271* (100 chars)

