# Test 3 checklist - for a non-developer

This is the in-game test of the Arabic prototype. Please do NOT install or uninstall
anything, and do NOT change the language setting: the game must stay on **Korean**.
(English voice is normal - the carrier keeps the English voice on purpose.)

While you test, the game is using exactly these two mod files (already installed):

- `zzz_atomicheart-ar_carrier_koKR_p2_P.pak` (503,841 bytes) - the Arabic text carrier
- `zzz_atomicheart-ar_font_p2_plex_P.pak` (1,461,408 bytes) - the Arabic-capable font

The 19 original game pak files are untouched.

**Important expectation:** Arabic was only seeded into THREE places - the main menu (already
confirmed working), the Settings labels, and the Game Tips. Do NOT expect Arabic in
dialogue or subtitles yet; there we only want to know whether text is VISIBLE or BLANK.

**If the game crashes, freezes, or shows any anti-tamper / "signature" error, stop and
tell me** - do not try to fix it yourself.

---

## Before you start (2 minutes)

1. Start the game and go to the main menu. It should again show the usual Arabic menu
   (this was confirmed before) - if it does not, tell me before continuing.
2. If you cannot see subtitles in game, turn them on first (this is a normal game
   setting, not a mod): Settings -> Game (or Audio) -> Subtitles -> On.
3. Keep the text language on **Korean**. Do not change it.

---

## Step 1 - Settings page (the important one)

Where: main menu -> **Options / Settings** -> the video/graphics page (the one that
contains the preset row Balanced / Performance / Quality and the On / Off / Fullscreen
switches).

What to look at - these nine labels are the ones prepared in Arabic:

| English label | What it should look like |
|---|---|
| Balanced | Arabic |
| Performance | Arabic |
| Quality | Arabic |
| Boost | Arabic |
| On | Arabic |
| Off | Arabic |
| Fullscreen | Arabic |
| Window | Arabic |
| Borderless Window | Arabic |

Everything else on that page (values, descriptions, other rows) should now be readable
English instead of blank - that is expected and good.

**Screenshot 1:** the whole Settings page (one shot that includes the Balanced/On/Off/
Fullscreen labels).

**Letter for this screen:**
- **A** = the nine labels are in Arabic, letters joined, right-to-left correct, and no
  label on the page is blank.
- **B** = Arabic appears but looks wrong (letters separated, backwards, or misplaced).
- **C** = the labels are readable but NOT Arabic (e.g. English).
- **D** = some labels are blank / empty boxes, or the game froze.

---

## Step 2 - A Game Tips popup

Where: go into the game and play until a tutorial tip appears on screen (these are the
"press X to do Y" popups in the early missions). Seven of these tips are prepared in
Arabic.

Easiest ways to see one quickly:
- **Continue / Load game** on an early save and walk into the starting area; the first
  tutorial tips appear within a minute or two.
- If you have no early save and don't mind, **New game** shows them almost immediately.
  (Your progress is not uploaded anywhere; starting a new game may overwrite an autosave
  slot - use an early save instead if you have one.)

**Screenshot 2:** the tip popup on screen (the popup text itself must be visible).

**Letter for this screen:**
- **A** = the tip text is in Arabic, letters joined, right-to-left correct.
- **B** = the tip shows Arabic but looks wrong (separated/backwards letters).
- **C** = the tip text is readable but NOT Arabic (English or Korean).
- **D** = the tip is blank / empty boxes, or the game froze.

If no tip appears within a few minutes, skip this step and write "not reached".

---

## Step 3 - A dialogue or subtitle scene (quick look only)

Where: in any save, trigger a spoken line. The quickest ones:
- press the interact key on a **NORA** vending machine (the upgrade station), or
- a **Char-les / terminal** message, or
- any NPC conversation / radio call.

Arabic is NOT expected here yet. We only want to know if the subtitle is visible.

**Screenshot 3:** a frame that shows the subtitle line at the bottom of the screen.

**Letter for this screen:**
- **A** = subtitles are visible and readable (Korean is fine here - that is not a failure).
- **B** = subtitles are visible but the letters look broken / boxes.
- **C** = subtitles show English instead of Korean (interesting - please note it).
- **D** = subtitles are blank / empty boxes / nothing appears / the game froze.

---

## What to send me

Three screenshots (Settings, Game Tips, Dialogue) and this short block:

```
Settings:  A / B / C / D   (circle one)
GameTips:  A / B / C / D   (or "not reached")
Dialogue:  A / B / C / D
Anything unexpected (red text, blank labels, crashes, other languages):
```

Screenshots: Steam's **F12** (saved in your Steam screenshot folder) or just a photo of
the screen with your phone - either is fine. Please keep the subtitle/popup text inside
the picture.

That is all. Do not change any files, and do not install or remove anything.


---

## Appendix - the exact Arabic text prepared for each label

If what you see on screen matches these, that is a PASS.

**Main menu (already confirmed working):**

| key | Arabic on screen |
|---|---|
| menu_openworld | العودة إلى المنشأة 3826 |
| Men_exitpopup | إنهاء اللعبة |
| menu_exit | خروج |
| menu_loadgame | تحميل لعبة |
| menu_start | لعبة جديدة |
| menu_ngplus | لعبة جديدة+ |
| menu_options | الخيارات |
| menu_continue | متابعة |
| menu_titles | فريق العمل |

**Settings labels (Step 1) - these nine should be Arabic:**

| English label | Arabic on screen |
|---|---|
| BALANCED | متوازن |
| BOOST | تعزيز |
| Fullscreen | ملء الشاشة |
| OFF | إيقاف |
| ON | تشغيل |
| PERFORMANCE | الأداء |
| QUALITY | الجودة |
| Window | نافذة |
| Borderless Window | ملء الشاشة بإطار نافذة |

**Game Tips (Step 2) - these seven popups should be Arabic:**

| tip (short name) | Arabic on screen |
|---|---|
| vi_raneni | لقد جُرحت! اضغط مع الاستمرار على <img id=""Button.ConsumeItem""/> للعلاج |
| esli_protivnik_stoit_spinoy | إذا فاجأت عدوًا، يمكنك التسلل إليه وطرحه أرضًا دون إطلاق إنذار. <h>لتنفيذ قتلة خادعة، اقترب من الخلف واضغط</> <tag id=""InputAction.Gameplay.StealthKill""/>. أسرع، وإلا فقد تفقد عنصر المفاجأة. |
| zazhmite_i_uderzhivayte | لفتح عجلة الجرد، اضغط مع الاستمرار على <tag id=""InputAction.Gameplay.RadialMenu""/>. |
| sbor_resursov_2 | لجمع الموارد وسلب الأعداء، اضغط مع الاستمرار على <tag id=""InputAction.Gameplay.Use""/>. |
| nazhmite_slabiy_udar | لإحداث ضرر خفيف، اضغط <tag id=""InputAction.Gameplay.EquippedItemPrimaryAction""/>. هذه الضربات سريعة لكنها ليست قوية للغاية. |
| protivniki_mogut_ispolzovat | يمكن للأعداء تنفيذ ضربات قوية تُسقط P-3 إذا أصابته. عندما يستعد عدو لضربة قوية، سيشير CHARLES إلى أفضل لحظة للمراوغتها. عند رؤية التمييز الأحمر، <h>اضغط</> <tag id=""InputAction.Gameplay.Dodge""/> للمراوغة. |
| chtobi_uklonyatsya | للمراوغة بين الهجمات والأجسام الطائرة والمقذوفات، اضغط <tag id=""InputAction.Gameplay.Dodge""/> أثناء التحرك. |

(7 game-tip strings.)

Note: the on-screen text may show a small button icon where the tables above contain
`<tag id="..."/>` or `<img id="..."/>` - that is normal, the game draws the button
picture there.
