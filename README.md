# منظومة فحص سرقات التيار الكهربائي

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-success.svg)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-Private-red.svg)](#)

تطبيق ميداني متكامل مبني باستخدام Flutter لتسجيل محاضر فحص سرقات التيار الكهربائي، وحساب المستحقات، وإدارة الملفات والتوثيق المرئي وفقًا للوائح والشرائح المعتمدة لشركة مصر الوسطى للطاقة الكهربائية.

## التجربة المباشرة

- النسخة Web: [theftinspectionv2.vercel.app](https://theftinspectionv2.vercel.app)
- المستودع: [Eng-Osama-Sadek/theft-inspection-app](https://github.com/Eng-Osama-Sadek/theft-inspection-app)

> النسخة الرئيسية مخصصة لنظام Android، وميزات التصوير والتخزين المحلي والتصدير تعمل بالكامل داخل التطبيق. نسخة الويب للعرض والإدارة ولا تحل محل التطبيق الأصلي عند الحاجة إلى نظام ملفات الجهاز والكاميرا.

## المميزات الرئيسية

- حساب كميات الاستهلاك المسروقة والمواد والأحمال بدقة.
- دعم شرائح النشاط المختلفة، ومعاملات التشتت، والتكرار، والغرامات، ورسم دمغة الاستهلاك، ودمغة النشاط ورسوم الإذاعة.
- إضافة تفاصيل الأحمال وتوثيق الاسم والقدرة وساعات التشغيل والأيام.
- متابعة المحاضر المحفوظة والبحث بالاسم أو رقم العداد.
- تصفية المحاضر حسب تاريخ البداية والنهاية مع عرض الإجماليات والنتائج المطابقة.
- تصدير تقرير Excel احترافي لكل حالة.
- حفظ صور البطاقة الشخصية ووثائق الصور والفيديو داخل مجلد خاص بالمحضر.
- تشغيل Offline-first مع حفظ البيانات محليًا على جهاز Android.
- واجهة عربية متجاوبة بتدرجات تصميمية واضحة ومناسبة للاستخدام الميداني.

## التقنيات والأدوات

| المجال | التقنية |
| --- | --- |
| إطار العمل | Flutter |
| لغة البرمجة | Dart |
| التخزين المحلي | Path Provider |
| التقارير | Excel |
| الوسائط | Image Picker وVideo Player |
| الأذونات | Permission Handler |
| الخطوط العربية | Google Fonts |

## متطلبات التشغيل

- Flutter SDK إصدار 3.x أو أحدث.
- Dart SDK متوافق مع إصدار Flutter المستخدم.
- Android Studio أو محرر يدعم Flutter.
- Android SDK مع جهاز فعلي أو محاكي يعمل بنظام Android.

## التشغيل المحلي

```bash
git clone https://github.com/Eng-Osama-Sadek/theft-inspection-app.git
cd theft-inspection-app
flutter pub get
flutter run
```

لتشغيل نسخة الويب:

```bash
flutter run -d chrome
```

لبناء إصدار Android Release:

```bash
flutter build apk --release
```

سيتم إنشاء ملف APK داخل:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## بناء نسخة الويب للنشر

```bash
flutter build web --release
```

مجلد الإخراج المستخدم للنشر هو:

```text
build/web
```

المشروع يدعم النشر على Vercel باستخدام إعدادات ملف `vercel.json` والسكربت الموجود داخل `scripts/vercel-build.sh`.

## هيكل المشروع

```text
lib/
├── main.dart                 # نقطة بدء التطبيق
├── logic/
│   └── calculator.dart       # منطق الحسابات والمحاضر
├── screens/
│   ├── home_screen.dart      # البحث والمحاضر والإحصاءات
│   ├── add_case_screen.dart  # إدخال بيانات الحالة
│   ├── camera_screen.dart    # توثيق الصور والفيديو
│   └── report_screen.dart    # عرض تفاصيل التقرير
└── services/
    └── file_manager.dart     # التخزين والتقرير والملفات المحلية
test/                         # اختبارات منطق التطبيق والواجهة
web/                          # ملفات تشغيل Flutter Web
```

## الاختبارات

تشغيل جميع اختبارات المشروع:

```bash
flutter test
```

تحليل جودة الكود:

```bash
flutter analyze
```

## حدود النسخة Web

تم تخصيص نسخة الويب لتعمل كواجهة عرض مستقرة على المتصفح. بعض وظائف Android غير متاحة مباشرة داخل المتصفح، ومنها:

- الوصول المباشر إلى مجلدات التنزيل الخاصة بـ Android.
- استخدام واجهة الكاميرا ونظام الملفات المحلي بالطريقة نفسها.
- حفظ ملفات PDF أو Excel داخل مساحة Android Download.
- تشغيل قنوات Platform Channels الخاصة بالتطبيق.

للاستخدام الميداني الكامل، يُفضل تثبيت النسخة المبنية لنظام Android.

## المطور

**م/ أسامة صادق**

مهندس برمجيات متخصص في تطوير تطبيقات الهاتف المحمول والحلول البرمجية لقطاع الطاقة والخدمات الحكومية.

- [LinkedIn](https://www.linkedin.com/in/osama-sadek-9a2951187?utm_source=share_via&utm_content=profile&utm_medium=member_android)
- [GitHub](https://github.com/Eng-Osama-Sadek)
