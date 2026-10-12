# ملفات Madabina CLI التنفيذية

Madabina CLI برنامج احتكاري توزعه Madabina LLC. هذا المستودع مخصص لتوزيع الإصدارات الرسمية بصيغة ملفات تنفيذية، ولا يحتوي على الشيفرة المصدرية للبرنامج.

## حالة الإصدارات

الإصدار `v0.3.0` هو الإصدار الحالي. نزّل الملفات المضغوطة وحزم Debian ومثبتات Windows وملف SHA-256 من [صفحة الإصدارات](https://github.com/madabina-com/madabina-cli/releases). اختر الحزمة المناسبة لنظام التشغيل والمعمارية، ثم تحقّق من SHA-256 قبل التثبيت. تؤكد قيمة التحقق من الإصدار نفسه سلامة النقل، لكنها لا تثبت هوية الناشر بشكل مستقل.

يضيف الإصدار v0.3.0 أدوات التثبيت المحلية المؤكدة لحزم BIND9 وAsterisk وCaddy على Ubuntu/Debian مع systemd (`madabina install dns|telephony|proxy`). تقتصر هذه الأوامر على تثبيت الحزم وتشغيلها؛ ولا تُعدّ مناطق DNS أو إعداد Caddy موثقاً أو خدمة Madabina Web. راجع [دليل التثبيت](docs/installation.ar.md). ويتضمن الإصدار واجهة Asterisk على `/telephony` والخيار `--trusted-origin` للوصول عن بُعد عبر وكيل HTTPS موثّق. يبقى CLI مرتبطاً بـ loopback؛ ولا يتيح ربط LAN المباشر التحكم في Asterisk. النظام المدعوم هو Ubuntu/Debian مع systemd، ويلزم مساعد منفصل لتعديل الإعدادات والتحكم بالخدمة. اقرأ الدليل [بالعربية](docs/telephony.ar.md) أو [الفرنسية](docs/telephony.fr.md) أو [الإنجليزية](docs/telephony.md). لا تثبّت ولا توزّع الملفات التي تحمل العلامة `SNAPSHOT`؛ فهي ملفات اختبار محلية وليست إصدارات رسمية.

## التثبيت عبر npm (قيد الإعداد)

تم إرسال إصدار npm `v0.1.1` من `madabina-cli` وحزم المنصات إلى npm، وهي بانتظار المراجعة والموافقة. التثبيت عبر npm غير متاح حالياً. بعد الموافقة، ثبّت باستخدام `npm install --global madabina-cli`، ثم تحقق بالأمر `madabina --version`. ستدعم حزم npm نظامي Linux وmacOS بمعماريتي x64 وARM64، إضافة إلى Windows ARM64. يظل Windows x64 متاحاً عبر مُثبّتات إصدار GitHub. لا يشمل ذلك Termux/Android. راجع [`npm/README.md`](npm/README.md) لمعرفة حالة التثبيت والمنصات المدعومة.

## التثبيت على Windows

تتوفر مُثبّتات المستخدم لنظام Windows بمعماريتي x64 وARM64 في [صفحة الإصدار v0.2.2](https://github.com/madabina-com/madabina-cli/releases/tag/v0.2.2).

### التثبيت بأمر واحد

افتح PowerShell والصق هذا الأمر. ينزّل البرنامج النصي الأولي ويتحقق من SHA-256، ثم يختار أحدث إصدار مستقر ومعمارية Windows، ويتحقق من ملف التثبيت باستخدام checksums الخاصة بالإصدار، ثم يبدأ التثبيت للمستخدم الحالي:

```powershell
$d=Join-Path $env:TEMP ('madabina-'+[guid]::NewGuid().ToString('N'));New-Item -ItemType Directory -Path $d|Out-Null;try{$s=Join-Path $d 'madabina-install-windows.ps1';$m=Join-Path $d 'install-windows.ps1.sha256';curl.exe -fsSL https://packages.madabina.com/install-windows.ps1 -o $s;if($LASTEXITCODE -ne 0){throw 'فشل تنزيل البرنامج النصي'};curl.exe -fsSL https://packages.madabina.com/install-windows.ps1.sha256 -o $m;if($LASTEXITCODE -ne 0){throw 'فشل تنزيل checksum'};$e=[regex]::Match((Get-Content -Raw $m),'(?m)^([0-9a-fA-F]{64})\s+madabina-install-windows\.ps1\s*$').Groups[1].Value;$a=(Get-FileHash -LiteralPath $s -Algorithm SHA256).Hash;if(-not $e -or $a -ne $e){throw 'فشل التحقق من SHA-256 للبرنامج النصي'};powershell.exe -NoProfile -ExecutionPolicy Bypass -File $s;if($LASTEXITCODE -ne 0){throw "فشل التثبيت، الرمز $LASTEXITCODE"}}finally{Remove-Item -LiteralPath $d -Recurse -Force -ErrorAction SilentlyContinue}
```

يتم استضافة ملف SHA-256 على نطاق HTTPS نفسه؛ فهو يكشف أخطاء النقل لكنه لا يثبت هوية ناشر البرنامج النصي بشكل مستقل.

### التنزيل والتحقق يدوياً

لتنزيل ملف التثبيت بنفسك، اختر `amd64` لنظام Windows x64 أو `arm64` لنظام Windows ARM64، وتحقق من قيمته في `checksums.txt` ثم شغّله:

```powershell
$version = '0.2.2'; $arch = 'amd64' # استخدم 'arm64' لأجهزة Windows ARM64
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

يتضمن الإصدار `v0.3.0` أنظمة Windows وLinux وmacOS بمعماريتي AMD64 وARM64، بالإضافة إلى حزم Debian بمعماريتي AMD64 وARM64. لا يتضمن هذا الإصدار Android/Termux ARM64.

## مستودع APT لأنظمة Debian / Ubuntu

#### التثبيت بأمر واحد

على Debian أو Ubuntu بمعماريتي AMD64 أو ARM64، ينزّل هذا الأمر المُثبّت وملف SHA-256 ويتحقق منه قبل تشغيله، ثم يضيف مستودع APT الموقّع ويثبّت Madabina CLI:

```sh
d="$(mktemp -d)" && trap 'rm -rf "$d"' EXIT && curl -fsSL https://packages.madabina.com/install.sh -o "$d/madabina-install.sh" && curl -fsSL https://packages.madabina.com/install.sh.sha256 -o "$d/install.sh.sha256" && (cd "$d" && sha256sum -c install.sh.sha256) && bash "$d/madabina-install.sh"
```

يتحقق المُثبّت من أن بصمة مفتاح APT الذي تم تنزيله تطابق البصمة المثبّتة `A6561F99594315269612AD984B8D3B0CB32D4F67` قبل إضافة المستودع. سيطلب `sudo` عند الحاجة. يتم تنزيل SHA-256 من نطاق HTTPS نفسه؛ وهو يكشف أخطاء النقل لكنه لا يثبت هوية ناشر المُثبّت بشكل مستقل.

#### إعداد APT يدوياً

إذا أردت إعداد APT يدوياً:

```sh
curl -fsSL https://packages.madabina.com/madabina-archive-keyring.gpg -o /tmp/madabina-archive-keyring.gpg
fingerprint="$(gpg --batch --show-keys --with-colons /tmp/madabina-archive-keyring.gpg | awk -F: '$1 == "fpr" { print toupper($10); exit }')"
test "$fingerprint" = 'A6561F99594315269612AD984B8D3B0CB32D4F67' || { echo 'بصمة مفتاح APT غير صحيحة' >&2; exit 1; }
sudo install -D -m 0644 /tmp/madabina-archive-keyring.gpg /usr/share/keyrings/madabina-cli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/madabina-cli-archive-keyring.gpg] https://packages.madabina.com stable main" | sudo tee /etc/apt/sources.list.d/madabina-cli.list >/dev/null
sudo apt update
sudo apt install madabina
```

يغطي المستودع Debian/Ubuntu بمعماريتي AMD64 وARM64. راجع [`apt/SETUP.md`](apt/SETUP.md) لإعداد النشر.
