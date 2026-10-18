# Subtitle display: timed parts vs truncated text

Question raised with the pilot screenshot (bridge scene, quest "NO REST FOR THE WICKED"):
the visible line ended mid-word ("... No, I'm not exagger"). Is the subtitle shown in
timed parts, or is the text truncated?

Verification status: **PARTIAL / CONFIRMED for the data, LIKELY for the display,
NOT TESTED for one remaining case.** No game files were modified to answer this.

## 1. What is actually on disk (CONFIRMED)

The row that was on screen is master row 289, scope `Chelomey_Dialogues`, key
`/DC11CB9A4BFFB0AA5E099DAA4057EEE9`.

- English source length: 431 characters, containing 3 timing markers: `*0.10*`, `*0.10*`, `*0.07*`.
- The string is complete: it ends with "... transformed in the last few decades!"
  It is the same string the carrier pak ships; nothing is cut when the pak is built
  (round-trip validation of all 27,618 keys: 0 failures).
- The ko-KR locres for the same key holds 211 characters and **no timing markers at all**.

So the on-disk string is not truncated. Whatever cuts the line on screen happens at display time.

## 2. What the screenshot shows (CONFIRMED)

The visible text began exactly at the 2nd marker boundary:

    part 1  "Greetings, comrades. I am Dmitry Sechenov, and this is Facility 3826.
             A warm welcome to your future! Today we stand on the brink of the greatest
             event in the history of mankind. "                     (not visible in the shot)
    part 2  "We find ourselves just a step away from amazing evolutionary victory that
             will profoundly change the world as we know it. No, I'm not exagger|"   <- on screen
    part 3  "Just look at how our beloved Soviet Union has been transformed in the last
             few decades!"                                           (not visible in the shot)

The on-screen text starts exactly where the second marker ends, not at the beginning of the
string and not at an arbitrary offset. That is what a marker-driven, part-by-part display looks
like: the game plays part 1, then replaces it with part 2, and so on.

## 3. Supporting evidence from the shipped files (CONFIRMED / LIKELY)

| evidence | value | reading |
|---|---|---|
| master rows carrying markers | 539 of 27,619 | the marker system is used broadly, not only here |
| - range style `*0.05-0.09*` | 135 rows | absolute time windows (used by DLC subtitle rows) |
| - single-value style `*0.10*` | 404 rows | the style used by this speech |
| ko-KR `Chelomey_Dialogues` strings with markers | 7 of 1,204 | the Korean localization mostly dropped them; the game runs fine without them |
| markers visible on screen in the screenshot | none | the engine interprets them; they are not printed as text |
| Korean text for the same key | 211 chars, no markers | Korean is one long string here and is known to display correctly |
| widget asset | `AtomicHeart/Content/Core/UI/Dialogue/WBP_TypingTextBox.uasset` | name and its "Pausing"/"Paused" strings point to a progressive (typewriter) reveal |

Because the Korean 211-character string (about 4 readable lines) is displayed correctly in the
Korean build, the subtitle panel cannot be a hard 2-line clip: it must grow, scroll, or reveal
progressively. That makes "a frame captured in the middle of the reveal" the most likely
explanation for the mid-word cut. Confidence: LIKELY, not CONFIRMED.

## 4. What is still NOT TESTED

Whether a single part that is longer than the panel can lose its tail (true clipping) or is
always fully revealed (scrolling/typing). A still frame cannot decide this. The in-game pass
described in `reports/scene_bridge_ingame_check.md` settles it: watch the same subtitle for
about 5 seconds and note whether its last words appear.

## 5. Why this matters for the Arabic build

Each Arabic row keeps the marker multiset of its English row byte-for-byte, and every Arabic
part is shorter in characters than the English part it replaces:

| master line | key | EN parts | EN longest | AR parts | AR longest |
|---|---|---|---|---|---|
| 284 | `/390799324C98ED38868918AC228ADC4C` | 1 | 57 | 1 | 52 |
| 285 | `/4C81F68D466B7E53EDEB3BADA39F3810` | 3 | 107 | 3 | 79 |
| 286 | `/10E57B554D1CB6E33B614B829975AE99` | 4 | 131 | 4 | 113 |
| 287 | `/714401B1409AD14630429692B0DFAFF5` | 2 | 158 | 2 | 115 |
| 288 | `/C6CA53CF4667BE6A271CFB8BFCF56BFB` | 5 | 125 | 5 | 89 |
| 289 | `/DC11CB9A4BFFB0AA5E099DAA4057EEE9` | 3 | 177 | 3 | 129 |
| 290 | `/1002A45848240DE4F7234C932386D3BF` | 4 | 166 | 4 | 127 |
| 291 | `/80D5E60948E59FE7EFD518B5253BFA92` | 2 | 176 | 2 | 160 |
| 292 | `/993C32CD4606AD8982BE078429495AB0` | 4 | 150 | 4 | 126 |
| 293 | `/33EA844F4B8F028BC8002BB818499148` | 4 | 179 | 4 | 163 |
| 294 | `/45DCA8FD43DFD45159ED7D82418730E5` | 3 | 180 | 3 | 145 |
| 295 | `/07DA2375411F20CAD0FE25B87105AE07` | 3 | 174 | 3 | 139 |

If the panel does clip, Arabic has about 25% more headroom than the English fill that was
tested, so the Arabic scene is the easier case, not the harder one.
