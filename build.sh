#!/bin/bash
set -e

# 1. تنزيل Flutter SDK لو مش موجود
FLUTTER_SDK_PATH="$HOME/flutter"
if [ ! -d "$FLUTTER_SDK_PATH" ]; then
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git $FLUTTER_SDK_PATH
fi

# 2. إضافة Flutter للـ PATH
export PATH="$FLUTTER_SDK_PATH/bin:$PATH"

# 3. التأكد من إن Flutter شغال
flutter --version

# 4. تنزيل الاعتماديات
flutter pub get

# 5. بناء نسخة الويب
flutter build web --release