<div align="center">

![AtomicHeart-AR · Arabic localization and Windows installer](docs/assets/banner.svg)

# تعريب أتوميك هارت
### عالمٌ آخر. بلغتك.

تعريب مجتمعي للعبة **Atomic Heart** على الحاسب، مع تطبيق لويندوز ولينكس لإدارة التركيب والفحص والإزالة.

[![Windows x64](https://img.shields.io/badge/Windows-x64-263522?style=for-the-badge&logo=windows&logoColor=EEE9D8)](app/README.md)
[![Installer 1.0.2](https://img.shields.io/badge/Installer-1.0.2-E65043?style=for-the-badge&labelColor=172016)](docs/releases/v1.0.2.md)
[![Localization p12](https://img.shields.io/badge/Localization-p12-C4CFAF?style=for-the-badge&labelColor=172016)](https://github.com/TDVVG-3/AtomicHeart-AR/releases/tag/v1.0.0)
[![Code MIT](https://img.shields.io/badge/Code-MIT-C4CFAF?style=for-the-badge&labelColor=172016)](LICENSE)

**[تنزيل حزمة التعريب](https://github.com/TDVVG-3/AtomicHeart-AR/releases/download/v1.0.0/AtomicHeart-AR-1.0.0-p12.zip)** &nbsp; · &nbsp;
**[تطبيق 1.0.2 وحالة نشره](docs/releases/v1.0.2.md)** &nbsp; · &nbsp;
**[ابدأ من هنا](#ابدأ-من-هنا)** &nbsp; · &nbsp;
**[كل الإصدارات](https://github.com/TDVVG-3/AtomicHeart-AR/releases)**

</div>

---

## التجربة بالعربية

نصوص اللعبة وترجمتها النصية بخط داعم للعربية، مع الحفاظ على أسماء الأسلحة والعناصر
الإنجليزية وتعريب الأوصاف والتلميحات. يستخدم التعريب **خانة اللغة الكورية**؛ اختر
**Korean** من لغة النص، ويبقى الصوت الإنجليزي كما هو.

| النصوص | الأسماء | المتحدثون |
| :---: | :---: | :---: |
| **26,717** صفًا عربيًا في p12 | **458** صفًا تحفظ الأسماء الأصلية | **1,140** تسمية `P-3` أصبحت **«الرائد»** |

القاعدة الرئيسية تضم **27,618 صفًا**، وتبقى **443 حالة** غير مترجمة ضمن فئة النسخ.
هذه أرقام مجموعة p12 كما توثّقها [حالة المشروع](STATUS.md) و[تقرير توليد p12](reports/p12_master.md).

## تطبيق التركيب · 1.0.2

واجهة عربية بهوية داكنة ولمسات حمراء، تجمع خطوات التعريب في نافذة واحدة:

| الميزة | ما الذي تقدّمه؟ |
| --- | --- |
| **اختيار اللعبة** | اكتشاف مكتبات Steam، مع اختيار المجلد يدويًا عند الحاجة |
| **فحص قبل التركيب** | مطابقة أحجام الحزم وبصمات SHA256 مع مجموعة p12 المعتمدة |
| **تركيب مباشر** | استخدام مجلد `payload` المرفق بالنسخة الكاملة تلقائيًا |
| **إزالة محسوبة** | إزالة الملفات التي يديرها التطبيق، وترك المودات الأخرى |
| **استرجاع عند الفشل** | التراجع عن العملية؛ والاحتفاظ بملفات الاسترداد إذا تعذّر الاسترجاع |
| **سجل واضح** | عرض حالة العملية وتعليمات اختيار لغة النص |

 > **حالة 1.0.2:** النسخة الجديدة تضم Windows وAppImage وتعريبًا محدّثًا بثمانية تصحيحات نصية.
> الملفات تُبنى وتُختبر آليًا؛ نشر Release في المستودع الأصلي يحتاج صلاحية المالك.
> [ملاحظات الإصدار وطريقة تنزيله](docs/releases/v1.0.2.md). يبقى إصدار 1.0.0 متاحًا إلى حين النشر.

التطبيق يستخدم محرك تركيب مستقلًا، ولا يشغّل سكربتات PowerShell القديمة.
تفاصيل التشغيل والبناء في [دليل التطبيق](app/README.md).

## التنزيل

| الملف | الاستخدام |
| --- | --- |
| **[حزمة p12 المعتمدة](https://github.com/TDVVG-3/AtomicHeart-AR/releases/download/v1.0.0/AtomicHeart-AR-1.0.0-p12.zip)** | التعريب والخط والتلميحات، للتركيب اليدوي الآن |
| **[تطبيق 1.0.2](docs/releases/v1.0.2.md)** | Windows ZIP وLinux AppImage، مع حزمة التعريب المصحّحة |
| **[المصدر](https://github.com/TDVVG-3/AtomicHeart-AR/releases/download/v1.0.0/AtomicHeart-AR-1.0.0-source.zip)** | الكود وقاعدة الترجمة للمطورين |
| **[جميع الإصدارات](https://github.com/TDVVG-3/AtomicHeart-AR/releases)** | سجل التنزيلات والمتغيرات وملاحظات كل إصدار |

**Source code (zip)** التلقائي في GitHub لا يثبّت التعريب. للعب، استخدم حزمة p12 أو النسخة الكاملة من التطبيق عند نشرها.
المتغير **p12g تجريبي** لمعالجة التوقيت، وغير مرفق مع تطبيق 1.0.2 الافتراضي.

## ابدأ من هنا

### باستخدام التطبيق

1. فك ضغط `AtomicHeart-AR-1.0.2-win-x64.zip` بعد توفره؛ اترك مجلد `payload` بجانب `AtomicHeartAR.exe`.
2. أغلق اللعبة، وشغّل التطبيق، ثم اختر مجلد Atomic Heart الذي يحتوي على `AtomicHeart.exe`.
3. اضغط **فحص الملفات**، ثم **تثبيت التعريب**.
4. افتح اللعبة، واختر **Korean / الكورية** من **Text Language**.

على لينكس، استخدم `AtomicHeart-AR-1.0.2-linux-x86_64.AppImage`، وامنحه إذن التشغيل ثم افتحه في وضع سطح المكتب:

```sh
chmod +x AtomicHeart-AR-1.0.2-linux-x86_64.AppImage
./AtomicHeart-AR-1.0.2-linux-x86_64.AppImage
```

نسخة AppImage تشمل التعريب و.NET وتعمل مع مكتبات Steam / Proton، على Ubuntu 22.04 أو بيئة متوافقة x86_64. تحتاج X11 أو XWayland وخطًا عربيًا. للتشغيل عند تعذّر FUSE أضف `--appimage-extract-and-run`. راجع [دليل لينكس](app/README.md#linux--appimage). نسخة ويندوز أيضًا تتضمن بيئة التشغيل.
لإزالة التعريب، أغلق اللعبة واستخدم زر **إزالة التعريب**. يتوقف التطبيق إذا تغيّر ملف مسجّل
بعد التثبيت؛ راجع السجل بدل حذف ملفات موداتك الأخرى.

### التركيب اليدوي

1. [نزّل حزمة p12](https://github.com/TDVVG-3/AtomicHeart-AR/releases/download/v1.0.0/AtomicHeart-AR-1.0.0-p12.zip) وفك ضغطها خارج مجلد اللعبة.
2. أغلق اللعبة واحتفظ بنسخة احتياطية من مجلد `~mods` إن كان موجودًا.
3. انسخ ملفات `.pak` الثلاثة فقط إلى المسار التالي، وأنشئ `~mods` عند الحاجة:

   ```text
   ...\Atomic Heart\AtomicHeart\Content\Paks\~mods
   ```

4. اختر **Korean / الكورية** من لغة النص داخل اللعبة.

للإزالة اليدوية، احذف **أسماء الملفات الثلاثة أدناه فقط** واستعد نسختك الاحتياطية.
إذا استُخدمت سكربتات المشروع القديمة، راجع سجلها `atomic-heart-ar-install-manifest.json`؛
سجل التطبيق الجديد مستقل واسمه `atomic-heart-ar-app-manifest.json`.

## محتويات حزمة 1.0.2

| الوظيفة | الملف | الحجم بالبايت |
| --- | --- | ---: |
| النصوص | `zzz_atomicheart-ar_carrier_koKR_p12_P.pak` | 4,470,307 |
| الخط v3 | `zzz_atomicheart-ar_font_p3_unhinted_P.pak` | 1,455,228 |
| التلميحات x150 | `zzz_atomicheart-ar_tips_x150_P.pak` | 75,853 |

تجد بصمات 1.0.2 في [SHA256SUMS](docs/releases/v1.0.2-payload-SHA256SUMS.txt). للتحقق في PowerShell:

```powershell
Get-FileHash -Algorithm SHA256 .\*.pak
```

أُعيد بناء حزمة النصوص بإضافة ثمانية تصحيحات، مع فحص القيم بعد إعادة الاستخراج ومطابقة الملفات الـ35 داخل الحزمة. بقي الخط والتلميحات كما هما. اسم ملف النصوص بقي p12 لتسهيل الترقية، لكن بصمته تغيّرت.

## أسئلة سريعة

<details>
<summary><strong>ليش أختار الكورية؟ وين خيار العربية؟</strong></summary>

التعريب يستبدل موارد خانة الكورية؛ لا يضيف خيارًا مستقلًا باسم العربية.
راجع [توثيق اختيار اللغة](docs/LANGUAGE_SELECTION.md). الصوت الإنجليزي يبقى كما هو.

</details>

<details>
<summary><strong>هل يغيّر ملفات اللعبة أو يحذف المودات الأخرى؟</strong></summary>

محرك التطبيق يثبت أسماء حزمته المحددة داخل `Paks/~mods`، ويحافظ على الملفات الأخرى.
لا يعدّل EXE أو DLL أو حزم اللعبة الأصلية. إذا تعارضت بصمة ملف موجود، يرفض العملية بدل الكتابة فوقه.

</details>

<details>
<summary><strong>عندي تعريب مثبت يدويًا؛ أقدر أديره بالتطبيق؟</strong></summary>

نعم. يرقّي التطبيق مجموعة p12 المعتمدة إلى 1.0.2، ويحفظ النسخة القديمة أثناء التحديث ليسترجعها عند الفشل. الملفات المعدّلة أو المجموعات المختلفة تحتاج مراجعة قبل اعتمادها.

</details>

<details>
<summary><strong>هل التعريب كامل وخالٍ من المشاكل؟</strong></summary>

توجد 443 حالة غير مترجمة ضمن فئة النسخ، وبعض مشاكل التوقيت والتراكب أو قصّ أربعة أسطر.
إصدار 1.0.2 يصحّح ثمانية نصوص، ويصلح أدوات تدقيق التوقيت والخطوط. إصلاح قصّ HUD داخل اللعبة غير مثبت، ومتغير التوقيت التجريبي p12g غير مرفق.
راجع [المشاكل المعروفة](KNOWN_ISSUES.md) و[دليل اختبار الترجمة النصية](reports/stack_test_guide.md).

</details>

## التوافق والتحقق

| النطاق | الدليل أو الحالة |
| --- | --- |
| اللعبة الموثّقة | Atomic Heart · Steam app `668580` · build `24534183` |
| مجموعة التعريب الافتراضية | `p12 + font v3 + tips_x150` |
| تقارير الترجمة والبناء السابقة | [ملخص فحوص p12](reports/p12_gate_all.md) و[التسليم التقني](HANDOFF.md) |
| اختبارات محرك التطبيق | [اختبارات المجلدات الوهمية](app/AtomicHeartAR.Tests/Program.cs) لحماية المسارات والملفات والاسترجاع |
| حدود التحقق | تشغيل اللعبة والعرض البصري للعربية لم يُعاد اختبارهما ضمن تطوير التطبيق |

نتائج التقارير القديمة أدلة محفوظة، وتُفصل عن اختبارات التطبيق الجديدة.
للتبليغ، [افتح Issue](https://github.com/TDVVG-3/AtomicHeart-AR/issues/new) مع نسخة اللعبة،
وأسماء الحزم، والخطوات وصورة المشكلة. احذف أي بيانات شخصية من السجلات قبل مشاركتها.

## للمطورين والمساهمين

ابدأ من [CONTRIBUTING](CONTRIBUTING.md) و[دليل التطبيق](app/README.md).
يستخدم Windows واجهة WPF، وLinux واجهة Avalonia، وكلاهما يشتركان في محرك التثبيت. البناء يحتاج **.NET 8 SDK**. [مسار البناء الآلي](.github/workflows/release-1.0.2.yml) يجهّز الحزم ويختبرها.

```powershell
dotnet run --project app/AtomicHeartAR.Tests -c Release -- C:\temp\ah-ar-tests
dotnet publish app/AtomicHeartAR.Installer -c Release -r win-x64 --self-contained true -o build/app-1.0.2
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/package_installer.ps1 -PayloadZip dist/AtomicHeart-AR-1.0.2-payload.zip
```

لبناء حزم اللعبة نفسها، راجع [سلسلة الأدوات](docs/TOOLCHAIN.md) و[HANDOFF](HANDOFF.md).
موارد اللعبة والأدوات الثنائية والمخرجات المولّدة ليست ضمن نسخة المصدر.
تمر تعديلات الترجمة عبر TM/fixup مع الحفاظ على النص الإنجليزي.

| المسار | المحتوى |
| --- | --- |
| [app/](app/) | تطبيقا Windows وLinux واختبارات محرك التثبيت |
| [localization/master/](localization/master/) | قاعدة النص الإنجليزي والترجمة العربية |
| [localization/working/](localization/working/) | ذاكرة الترجمة وقواعد الإصلاح والمراجعة |
| [scripts/](scripts/) | أدوات الاستخراج والبناء والتدقيق والتغليف |
| [reports/](reports/) | تقارير التحقق والتجارب السابقة |
| [docs/](docs/) | توثيق المشروع وملاحظات الإصدارات |
| [glossary/](glossary/) | المصطلحات المعتمدة |
| `build/` و`dist/` | مخرجات محلية لا تُضاف إلى Git |

## أصحاب المشروع والحقوق

بإشراف **[TDVVG-3](https://github.com/TDVVG-3)** ومساهمات المجتمع.
هذا تعريب مجتمعي غير رسمي؛ Atomic Heart وأصولها وعلاماتها تخص Mundfish وأصحاب الحقوق المعنيين.
كود المشروع وتوثيقه تحت [MIT](LICENSE)، وتفاصيل المكونات الأخرى في
[THIRD_PARTY_LICENSES](THIRD_PARTY_LICENSES.md).

<div align="center">

**صُنع للاعبين العرب. ومفتوح لمساهماتهم.**

[الإصدارات](https://github.com/TDVVG-3/AtomicHeart-AR/releases) · [سجل التغييرات](CHANGELOG.md) · [حالة المشروع](STATUS.md) · [المساهمة](CONTRIBUTING.md)

</div>
