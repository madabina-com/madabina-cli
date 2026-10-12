# تثبيت الخدمات المحلية

تستهدف `madabina install` حالياً أنظمة Ubuntu/Debian التي تستخدم `apt` و`systemd`. تعرض الحزم المحددة والخدمة التي ستُفعّل والمنافذ المعنية، ثم تنتظر تأكيداً صريحاً بكلمة `yes`. شغّلها من الطرفية بصلاحية root أو بحساب مُعدّ لاستخدام `sudo`.

```sh
madabina install dns
madabina install telephony       # الاسم البديل: madabina install asterisk
madabina install proxy
madabina help install dns
madabina -h install dns
```

تثبّت هذه الأوامر حزم BIND9 أو Asterisk أو Caddy ثم تفعّل وحدة systemd الخاصة بها وتشغّلها. لا تغيّر قواعد UFW. إعداد مناطق/واجهات DNS وصفحة الإدارة `/dns` غير متاح في هذا الإصدار الجزئي. كما أن أمر الوكيل لا ينشئ بعد ملف Caddy أو بيانات المشغّل أو وحدة systemd لتشغيل Madabina Web؛ أعدّها منفصلة قبل إتاحة لوحة التحكم. أبقِ المنفذ 7410 على loopback خلف وكيل HTTPS يتطلب المصادقة.

يتطلب DNS العام عنوان IP عاماً واتصالات UDP/TCP الواردة على المنفذ 53 وتفويض NS من مسجل النطاق. ويتطلب HTTPS عبر Caddy سجلات DNS عامة واتصالات TCP الواردة على 80 و443. لا تعدّل Madabina إعدادات المسجل أو الجدار الناري.

للتفاصيل استخدم `madabina -h install <component>` أو `madabina help install <component>`.
