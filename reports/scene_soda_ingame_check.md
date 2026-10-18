# In-game check: Arabic in the Chelomey canal boat scene (carrier p6)

Installed right now: carrier **p6** + font **v2**. The display language must stay **Korean**
(the Arabic rides in the Korean slot). Nothing in the game folder was changed except `~mods`.

## 0. Before you start

- Do not change the display language and do not install anything else.
- Screenshots: press `F12` (Steam) or the game's screenshot key; full screen if possible.
- If a pak-signature / "mod" notice appears, ignore it - that is the normal notice for a pak in `~mods`.

## 1. Which scene this is, and how to reach it

- It is the **canal / boat scene in Chelomey City**: the service drone with two dish antennas holds a
  glass of soda and talks to P-3. It is the exact scene you photographed.
- In the game data it is the dialogue asset `D_0072_Sipuha_BringSoda` (the Chelomey intro dialogue set).
- How to reach it again: **load the save you took the screenshot from** (or continue that save and replay
  the boat ride). Nothing has to be unlocked or configured.

## 2. What to look at - 5 subtitle lines + the bracketed labels

The labels inside the brackets are Arabic now for the drone, and `P-3` stays Latin by design.

| # | label to expect | Arabic to expect on screen |
|---|-----------------|----------------------------|
| 1 | `[ الحاسوب ]` | هل ترغب بمزيد من الغازية، أيها الرفيق؟ |
| 2 | `[ P-3 ]` | بالتأكيد، شكراً. |
| 3 | `[ تشارلز ]` | إنه يؤدّي وظيفته فحسب، أيها الرائد. |
| 4 | `[ P-3 ]` | سئمت من الروبوتات حتى الموت. دائماً تتدخّل في شؤوني! |
| 5 | `[ الحاسوب ]` | والآن، اغرب عن وجهي! |

Check these five things:

1. **Shape** - the letters are joined and Arabic-looking (no empty boxes, no `?`, no tofu squares).
2. **Order** - the text reads right to left; the soda question comes first, then the short thanks reply.
3. **Labels** - the bracketed name of the drone is Arabic (`الحاسوب`). If a label still shows `Computer`
   in Latin, the label row did not load - that is a real finding, please report it. `[ P-3 ]` must stay `P-3`.
4. **Wrapping** - no clipped tail and no text running out of the panel; the soda line is the longest one.
5. **Punctuation** - the question ends with the Arabic question mark `؟`, inner pauses use `،`, and `P-3`
   keeps its Latin letters and hyphen.

## 3. What to send me

- A screenshot of the soda line **with its bracketed label** (the same shot as yours, now Arabic).
- A screenshot of the "Sure, thanks." reply if you can catch it.
- Any of the remaining three lines ("It's just performing its function, Major." / the bots grumble /
  "Now get the hell outta here.") if you can catch them.

## 4. If something is wrong

Tell me which line it was and what you saw: English text still, a Latin speaker label, boxes instead of
letters, reversed order, or a clipped sentence. A screenshot is enough - no file edits from your side.

## 5. Rollback (only if you want the previous build back)

```
# back to the build that was installed before this scene
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\install_mod.ps1 -Carrier p4 -Font p2_plex

# alternative: the batch-1 build (p5) without this scene
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\install_mod.ps1 -Carrier p5 -Font p2_plex
```

Both variants are still in `C:\AtomicHeart-AR\build\package\`; the installer removes the currently installed
carrier only after its hash matches the manifest, and never touches the font pak.
