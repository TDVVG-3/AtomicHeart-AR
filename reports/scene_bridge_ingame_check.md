# In-game check: Arabic on the bridge (carrier p4)

Installed right now: carrier **p4** + font **v2**. Language in the game must stay **Korean**
(the Arabic is carried in the Korean slot). Nothing else in the game folder was changed.

## 0. Before you start

- Do not change the display language and do not install anything else.
- Screenshots: press F12 (Steam) or the game's own screenshot key; keep them full-screen.
- If the pause menu shows a "mod" warning, ignore it; it is the normal pak signature notice.

## 1. How to reach the same scene

Either way works:

- **Continue your save**: you were already on the bridge during the pilot. The loudspeaker
  announcements loop in that area, so simply stand on the bridge / walk back along it and wait
  for the PA speech to start again.
- **Reload the checkpoint**: load the autosave/checkpoint at the start of the quest
  "NO REST FOR THE WICKED" (objective "Cross the bridge").
- **Cleanest option (fresh run)**: start a new game and play through the short prologue;
  the bridge with the PA speech comes a few minutes in. The speech is triggered automatically
  while you walk.

The line that was checked in the pilot (row `/DC11CB9A4BFFB0AA5E099DAA4057EEE9`) is the
Sechenov welcome speech: it starts with "Greetings, comrades. I am Dmitry Sechenov..." and in
Arabic starts with `تحياتي أيها الرفاق. أنا دميتري سيتشينوف`.

## 2. What to look at

1. **Does Arabic appear at all** in the subtitle box, with correctly joined letters
   (not separated letters, not empty squares/boxes)?
2. **Reading direction**: does the sentence read right-to-left, right-aligned?
3. **The Sechenov speech**: watch one full announcement from start to finish. The Arabic is
   split at the same three timing points as the English, so you should see it arrive in parts.
4. **The open question (answers the pilot screenshot)**: watch the middle part of the
   Sechenov speech (`لم يبقَ بيننا وبين انتصار تطوّري مذهل... سوى خطوة واحدة. لا، أنا لا أبالغ!`).
   Does the subtitle end with `لا، أنا لا أبالغ!`, or does the last few words get cut off?
   Take one screenshot as soon as it appears and another three seconds later.
5. **Line wrapping**: does the text wrap at spaces, or is a word split across lines?
6. **Latin and digits inside Arabic** (`THOUGHT`, `3826`, `2.0`, `1955`): do they appear in the
   right place inside the sentence and not mirrored?
7. **Punctuation**: `!` and `،` and `.` in the right places?
8. **Crowd labels**: walk near the benches/cafe. The speaker name above a crowd line should show
   Arabic now (`مواطن`, `رجل على المقعد`, `أندري`, `الجدة زينا`).
9. **No garbage**: any square boxes, question marks, or reversed text is a defect worth reporting.

## 3. What to screenshot

1. The bridge while the Sechenov speech is on screen.
2. The same subtitle about three seconds later (to check the reveal/scroll question).
3. One crowd line that shows a speaker label.
4. Anything that looks broken (missing glyphs, cut text, wrong order) - a screenshot of the
   defect matters more than a description.

## 4. What to send back

- for each item above: PASS / FAIL, plus the screenshot number;
- item 4 in particular: did the last words of the middle part appear? yes / no;
- any text that looked wrong (copy the Arabic if you can, or point at the screenshot);
- the quest name/objective shown when you took the shot, so the scene can be matched to the key.

## 5. If something is wrong

Nothing needs to be reinstalled to fix text: the wording lives in the master database, a new
carrier pak is built from it, and only that one pak is replaced in `~mods`. Report first, then
the fix is built and installed in one step.
