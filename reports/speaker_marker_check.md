# Speaker-marker check (short, in-game)

Date: 2026-10-18  |  Purpose: find out whether the `&Speaker&` markers inside subtitle lines are
shown to the player, so we know whether speaker names must be translated.

## What the evidence already tells us

- 130 master rows contain a `&Speaker&` marker; they live in ONLY three scopes, all DLC2
  "Schebetars": `Schebetar_Subs` (90 rows), `Schebetars_dlc1` (39), `Locations_dlc2` (1).
- Base-game dialogue has NO speaker markers at all. So nothing in the base game is affected.
- The markers exist in every language's text (they are part of the string, not added by us).
- Three of our pilot rows carry markers (the surgery scene, the museum-curator commentary, the
  electrician scene) and all three are in `Schebetar_Subs`, i.e. in the content installed now
  as English-filled text.

## The check (one scene is enough)

You need any DLC2 "Schebetars" dialogue that shows subtitles. Start the DLC2 mission, or load a
save inside it, and trigger a conversation with subtitles.

Look at the subtitle line and tell me which of these three you see:

| what you see | meaning | what we do |
|---|---|---|
| **A** - a name label or the speaker's name shown in its own style (e.g. "SURGEON" / "Surgeon:" or a coloured name above the line) | the game PARSES the marker and displays the name | we translate the 145 speaker names through the glossary (rule below) |
| **B** - the raw text `&Surgeon&` (ampersands visible) | the game does NOT parse the marker and shows it literally | we leave the marker byte-exact and report it as a game-side bug; nothing to translate |
| **C** - no name at all, just the spoken line | the game strips the marker silently | we leave the marker byte-exact (current behaviour; the validator already enforces the marker count) |

Please screenshot the subtitle line in whichever case you see. The exact text to look for in the
surgery scene starts with "Swab. Focus. Keep an eye on that incision!" and continues with a
nurse, a colonel and a private - so if case A is true you would see four different names.

If you cannot reach any DLC2 dialogue (DLC not installed, or the save is not there yet), reply
"not reached" and it stays NOT TESTED - that is a perfectly fine answer, and nothing else depends
on it.

## Rule we will apply (only if the answer is A)

1. The `&` delimiters and everything outside them stay byte-exact (the game's parser must still
   match the token).
2. Names inside the markers are translated by category:
   - characters (Petrov, Lastochkin, Sechenov, Lebedev, Sanina, ...) -> transliterated per glossary
   - roles/descriptors (Surgeon, Nurse, Colonel, Private, Programmer, Ministry of Culture
     curator, Computer voice, Grumpy trainee, ...) -> translated into natural Arabic
   - non-verbal cues (Moo!, WOOF!, KABOOM!, children laughing, Radio of the Future music,
     Sound of a train derailing) -> translated as the Arabic onomatopoeia / sound description
   - unit/asset names (P-3, NORA, Kollektiv PA, Argentum soldier, BEA-D) -> glossary form
     (preserved or transliterated as the glossary already decides)
3. The 145 tokens get added to `glossary/glossary.tsv` before batch 1 touches DLC2, and a
   validator rule will then require the translated name inside the marker.
4. If the answer is B or C, the existing rule stands: the marker is copied byte-exactly and the
   validator keeps enforcing the marker multiset (identical count and text).

## Where this is recorded

- Evidence: `reports/speaker_markers.md` (all 145 tokens with counts).
- Style guide: `glossary/terminology.md`, section 10.
- Decision log: DEC-025.
