#!/usr/bin/env bash
#
# Builds the production Android APK:
#   - prod config via --dart-define-from-file=env/prod.json (API base URL = AWS API Gateway)
#   - native Google Maps key injected via MAPS_API_KEY (build.gradle.kts reads it)
#   - release signing requires android/key.properties (see android/key.properties.example)
#
# Usage:
#   MAPS_API_KEY=AIza...your-android-maps-key  ./scripts/build_apk_prod.sh
#   # or build an app bundle for the Play Store:
#   MAPS_API_KEY=AIza...  ./scripts/build_apk_prod.sh appbundle
#
set -euo pipefail

cd "$(dirname "$0")/.."

TARGET="${1:-apk}" # apk | appbundle

if [[ -z "${MAPS_API_KEY:-}" ]]; then
  echo "ERROR: MAPS_API_KEY is not set — the release APK would ship a blank Google Maps key." >&2
  echo "       export MAPS_API_KEY=<your android maps key> and re-run." >&2
  exit 1
fi

if [[ ! -f android/key.properties ]]; then
  echo "ERROR: android/key.properties not found — release would be signed with the debug key." >&2
  echo "       Copy android/key.properties.example to android/key.properties and fill it in." >&2
  exit 1
fi

if [[ ! -f env/prod.json ]]; then
  echo "ERROR: env/prod.json not found (prod API base URL)." >&2
  exit 1
fi

echo "Building release ${TARGET} (prod config, MAPS_API_KEY set, release keystore)..."
flutter build "${TARGET}" --release --dart-define-from-file=env/prod.json

echo "Done. Verify signature with:  apksigner verify --print-certs build/app/outputs/**/app-release.apk"
