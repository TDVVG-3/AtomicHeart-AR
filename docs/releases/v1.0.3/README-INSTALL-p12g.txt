AtomicHeart-AR - Arabic Localization - p12g EXPERIMENTAL (1.0.3)
===============================================================

CONTENTS
--------
1. zzz_atomicheart-ar_carrier_koKR_p12g_P.pak
2. zzz_atomicheart-ar_font_p3_unhinted_P.pak
3. zzz_atomicheart-ar_tips_x150_P.pak

INSTALL (Arabic)
----------------
1. أغلق اللعبة Atomic Heart بالكامل.
2. انسخ الملفات الثلاثة (PAK) إلى المجلد:
   ...\Atomic Heart\AtomicHeart\Content\Paks\~mods
3. من إعدادات اللعبة، اختر لغة النص: الكورية (Korean).
   الصوت الإنجليزي لا يتغيّر.
4. أعد تشغيل اللعبة إذا لم يظهر النص العربي مباشرة.

لماذا الكورية؟
-------------
اللعبة لا تعرض العربية في قائمة اللغات، لكنها تدعم الكورية. هذا المود يستبدل
نصوص الخانة الكورية بالنص العربي، لذلك اختر "الكورية" من إعدادات النص.

إلغاء التثبيت
-------------
احذف الملفات الثلاثة فقط من مجلد ~mods، ثم أعد نسختك الاحتياطية إن وجدت.
لا تحذف أي ملف PAK أصلي من اللعبة، ولا أي ملف خارج ~mods.

الأمان
------
هذا مود بيانات فقط. لا يعدّل AtomicHeart.exe أو ملفات DLL أو ملفات Steam أو
الحماية (Denuvo) أو ملفات PAK الأصلية.

p12g مقابل p12
--------------
- p12g: إصدار تجريبي يضيف تعديلات على توقيت الترجمة (H1/H2/H3).
- p12: الإصدار المستقر الافتراضي (المُوصى به).
لا تضع الحاملين p12g وp12 معاً في ~mods؛ اختر واحداً فقط.
هذه الحزمة هي p12g التجريبية. إن ظهرت مشاكل في التوقيت، استخدم حزمة p12.

ما الجديد في 1.0.3؟
-------------------
- ثمانية تصحيحات نصية عربية منذ 1.0.0.
- بقيت تعديلات التوقيت التجريبية كما هي في 1.0.0 مع إضافة التصحيحات النصية.
- تحديث الوثائق.

القيود المعروفة
---------------
- توقيت الترجمة مرتبط بملفات الصوت الأصلية.
- قد تتراكم سطور الترجمة في الحوارات السريعة.
- قد تُقصّ السطور عند ظهور أربعة سطور في الشريط السفلي.
- رقم الاختيار "1 //" يظهر على الجانب الأيسر في بعض القوائم.
- توجد 343 سطراً من نوع H3 بلا مدة مقطع صالحة.
- p12g تجريبي ولم يُختبر على Steam Deck.

INSTALL (English)
-----------------
1. Close Atomic Heart completely.
2. Back up:
   ...\Atomic Heart\AtomicHeart\Content\Paks\~mods
3. Copy only the three PAK files into the ~mods folder.
4. In the game settings, set Text Language to Korean.
   English voice audio is unchanged.
5. Restart the game if the text does not update immediately.

UNINSTALL
---------
Remove only these three PAK files from ~mods, then restore your backup if needed.
Do not delete any stock game PAK or any file outside ~mods.

P12G VS P12
-----------
- p12g: experimental H1/H2/H3 subtitle-timing changes.
- p12: stable default (recommended).
Do not keep both carriers in ~mods; install one only.
This package is the experimental p12g build. Use the p12 package if you see
timing problems.

WHAT CHANGED IN 1.0.3
---------------------
- Eight Arabic text corrections since 1.0.0.
- The 1.0.0 experimental timing changes are retained; the corrections are added.
- Documentation refreshed.

KNOWN LIMITATIONS
-----------------
- Subtitle timing is tied to the original audio clips.
- Lines can stack during fast dialogue exchanges.
- The bottom bar can clip lines when four lines are visible.
- The choice number "1 //" appears on the left side in some menus.
- 343 H3 rows have no usable clip duration.
- p12g is experimental and was not tested on Steam Deck.

VERIFY SHA256 (PowerShell)
--------------------------
Get-FileHash .\zzz_atomicheart-ar_carrier_koKR_p12g_P.pak -Algorithm SHA256
Get-FileHash .\zzz_atomicheart-ar_font_p3_unhinted_P.pak -Algorithm SHA256
Get-FileHash .\zzz_atomicheart-ar_tips_x150_P.pak -Algorithm SHA256

carrier : 1cc7963d13a6eda77babf1f3617189d1ec2c5153455d16306f67e9e1c8b77dc9
font    : f4ed50679d8ed7184354f6714f8d43def2fde60f03906d7bf36b7b7c8e663ef4
tips    : 36de01c37231a8b88ec9fc744c4f663bb8461a56adede9a6a2151d78c7ef7fcc

PROJECT
-------
https://github.com/TDVVG-3/AtomicHeart-AR
This is an unofficial fan project. Atomic Heart content belongs to Mundfish and
its licensors. Project code and documentation are MIT-licensed.
