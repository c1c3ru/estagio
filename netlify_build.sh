#!/usr/bin/env bash
set -euo pipefail

# Install Flutter SDK (stable) and build Flutter Web

echo "[Netlify] Cloning Flutter SDK (stable)..."
if [ ! -d "flutter" ]; then
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable
else
  echo "[Netlify] Flutter directory already exists, using cached copy."
fi

export PATH="$PWD/flutter/bin:$PATH"

echo "[Netlify] Flutter version:"
flutter --version

# Enable web and fetch deps
flutter config --enable-web
flutter pub get

# Build web
echo "[Netlify] Building Flutter Web (release)..."
flutter build web --release --no-tree-shake-icons

echo "[Netlify] Build finished. Output at build/web"
