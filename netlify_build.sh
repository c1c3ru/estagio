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
if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo "[Netlify] WARNING: SUPABASE_URL or SUPABASE_ANON_KEY not set in Netlify env. Build will proceed but app may fail to auth."
fi
flutter build web --release --no-tree-shake-icons \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:-}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"

echo "[Netlify] Build finished. Output at build/web"
