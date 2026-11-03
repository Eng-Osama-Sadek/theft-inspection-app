#!/bin/bash
set -e
FLUTTER_SDK_PATH=$HOME/flutter
if [ ! -d "$FLUTTER_SDK_PATH" ]; then
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git $FLUTTER_SDK_PATH
fi
export PATH="$FLUTTER_SDK_PATH/bin:$PATH"
flutter --version
flutter pub get
flutter build web --release