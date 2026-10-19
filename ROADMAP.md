# ROADMAP

High-level order of deliverables (details in PLAN.md).

1. **Investigation complete** — 10 questions answered with evidence (this session).
2. **Arabic Prototype v0.0.1** — 10–30 Arabic strings render correctly in game
   (font, shaping, BiDi acceptable), installable and removable, English preserved.
3. **Localization Pipeline v0.1** — full extraction, master TSV, AR/EN reference,
   validator, automated rebuild and PAK packaging.
4. **Arabic Translation Alpha** — gameplay UI, menus, HUD, tutorial, inventory,
   skills, objectives, initial story dialogue.
5. **Full coverage + QA + Release** — all text, DLC, credits, documented release.

## Deferred / parked

- Decision on which text culture carries Arabic (Strategy A/B/C, MASTER_PROMPT §23)
  — deferred until locres/culture structure is proven in Phase 5/7.
- KI-028 (COSMETIC, Phase 8): dialogue-choice layout. The choice number/separator (`1 //`) is drawn to the
  LEFT of the Arabic choice text because the choice widget lays out its row LTR; the text itself is correct
  Arabic. User decision 2026-10-19 (DEC-032): keep as-is, fix with the Phase 8 widget work.
- Pre-Phase-8 backlog (unchanged): KI-004 main-UI uassets, KI-013 DA_Audio language list, KI-017 obfuscated
  asset, KI-018 Russian-only cooked dialogue assets, KI-010 RU-only StringTables.
