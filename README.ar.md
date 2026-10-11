# ملفات Madabina CLI التنفيذية

Madabina CLI برنامج احتكاري توزعه Madabina LLC. هذا المستودع مخصص لتوزيع الإصدارات الرسمية بصيغة ملفات تنفيذية، ولا يحتوي على الشيفرة المصدرية للبرنامج.

## حالة الإصدارات

الإصدار `v0.1.0` هو أول إصدار رسمي لملفات Madabina CLI التنفيذية. نزّل الملفات المضغوطة ذات الأرقام وحزم Debian وملف SHA-256 من [صفحة إصدارات Madabina CLI](https://github.com/madabina-com/madabina-cli/releases). اختر الحزمة المناسبة لنظام التشغيل ومعمارية المعالج، ثم تحقّق من قيمة SHA-256 قبل التثبيت. تؤكد قيمة التحقق التي تُنزّل من الإصدار نفسه سلامة النقل، لكنها لا تثبت هوية الناشر بشكل مستقل.

لم يتم اختبار مُثبّت Linux على بيئة Linux فعلية لهذا الإصدار. راجع ملاحظات الإصدار قبل التثبيت. لا تثبّت ولا تعِد توزيع الملفات التي تحمل العلامة `SNAPSHOT`؛ فهي ملفات محلية للاختبار وليست إصدارات رسمية.

## التثبيت على Windows

يجري إرفاق مُثبّتَي المستخدم لنظام Windows بمعماريتي x64 وARM64 بإصدار v0.1.0. بعد ظهور ملفي `*_setup.exe` في صفحة الإصدار، استخدم PowerShell لتنزيل المُثبّت وملف checksums والتحقق من SHA-256 ثم تشغيله:

```powershell
$version = '0.1.0'; $arch = 'amd64' # استخدم 'arm64' لأجهزة Windows ARM64
$name = "madabina_${version}_windows_${arch}_setup.exe"
$base = "https://github.com/madabina-com/madabina-cli/releases/download/v$version"
$checksums = Join-Path $env:TEMP 'madabina-checksums.txt'; $installer = Join-Path $env:TEMP $name
curl.exe --fail --location --silent --show-error "$base/checksums.txt" --output $checksums; if ($LASTEXITCODE -ne 0) { throw 'فشل تنزيل ملف checksums' }
curl.exe --fail --location --silent --show-error "$base/$name" --output $installer; if ($LASTEXITCODE -ne 0) { throw 'فشل تنزيل المُثبّت' }
$expected = ([regex]::Match((Get-Content -Raw $checksums), "(?m)^([0-9a-fA-F]{64})\s+\*?$([regex]::Escape($name))\s*$")).Groups[1].Value
if (-not $expected -or (Get-FileHash $installer -Algorithm SHA256).Hash -ne $expected) { throw 'فشل التحقق من SHA-256' }
Start-Process $installer -Wait
```

يثبّت البرنامج في مجلد البرامج المحلي للمستخدم، ويحدّث `PATH` الخاص به، ويحافظ على الترخيص وإشعارات المكونات الخارجية، ولا يحتاج إلى صلاحيات المدير. يُعدّ سير العمل بيان WinGet المجتمعي، لكنه لم يُقدّم أو يُدمج بعد؛ لذلك فإن `winget install Madabina.MadabinaCLI` غير متاح حالياً. تتحقق بصمة checksums المنشورة مع الإصدار نفسه عبر HTTPS من سلامة النقل، لكنها لا توثّق الناشر بشكل مستقل.

## الترخيص والإشعارات

يسمح ترخيص Madabina CLI بالاستخدام وإعادة التوزيع المجاني للملفات التنفيذية الأصلية غير المعدّلة، وفقاً لشروط الترخيص المرفق. ولا يسمح بإعادة توزيع الشيفرة المصدرية أو الملفات التنفيذية المعدّلة. تتطلب إعادة البيع إذناً كتابياً منفصلاً من Madabina LLC. راجع [الترخيص](LICENSE) و[إشعارات المكونات الخارجية](THIRD_PARTY_NOTICES.md).

تخضع المكونات الخارجية لشروط تراخيصها الخاصة، وتوجد نسخها ضمن `third_party_licenses/` عند الاقتضاء.

## الأنظمة المستهدفة

يتضمن الإصدار `v0.1.0` أنظمة Windows وLinux وmacOS بمعماريتي AMD64 وARM64، بالإضافة إلى حزم Debian بمعماريتي AMD64 وARM64. سيُضاف Android/Termux ARM64 في إصدار لاحق.

## مستودع APT لأنظمة Debian / Ubuntu

يجري إعداد نشر مستودع APT. بعد نجاح النشر الأول، ثبّت البرنامج بالأوامر التالية:

```sh
curl -fsSL https://madabina-com.github.io/madabina-cli/madabina-archive-keyring.gpg | sudo tee /usr/share/keyrings/madabina-cli-archive-keyring.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/madabina-cli-archive-keyring.gpg] https://madabina-com.github.io/madabina-cli stable main" | sudo tee /etc/apt/sources.list.d/madabina-cli.list >/dev/null
sudo apt update
sudo apt install madabina
```

سيغطي المستودع Debian/Ubuntu بمعماريتي AMD64 وARM64. إلى أن ينجح النشر الأول، ثبّت حزمة `.deb` من [صفحة الإصدارات](https://github.com/madabina-com/madabina-cli/releases). راجع [`apt/SETUP.md`](apt/SETUP.md) لإعداد النشر لأول مرة.
