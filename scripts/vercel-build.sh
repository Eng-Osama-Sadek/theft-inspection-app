#!/usr/bin/env bash
set -e

if ! command -v flutter >/dev/null 2>&1; then
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$HOME/flutter"
fi

export PATH="$HOME/flutter/bin:$PATH"
flutter config --enable-web
flutter pub get
flutter build web --release
