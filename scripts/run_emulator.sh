#!/usr/bin/env bash
set -euo pipefail

# Env file to use (default: env/local.json — localhost, no secrets).
# Override: ENV_FILE=env/prod.json ./scripts/run_emulator.sh
ENV_FILE="${ENV_FILE:-env/local.json}"

DEVICE="${DEVICE:-emulator-5554}"
KEYCLOAK_PORT="${KEYCLOAK_PORT:-8180}"
ADB="${ADB:-$HOME/Android/Sdk/platform-tools/adb}"

cd "$(dirname "$0")/.."

# Google Maps key lives only in git-ignored android/local.properties (same source
# the Android build reads), never in committed env JSON. Forwarded to Dart via
# --dart-define so the Directions API works. Override by exporting MAPS_API_KEY.
MAPS_API_KEY="${MAPS_API_KEY:-$(grep -E '^MAPS_API_KEY=' android/local.properties 2>/dev/null | cut -d '=' -f2- | tr -d '[:space:]')}"

if [ -x "$ADB" ]; then
  "$ADB" -s "$DEVICE" reverse "tcp:${KEYCLOAK_PORT}" "tcp:${KEYCLOAK_PORT}" >/dev/null
  echo "adb reverse tcp:${KEYCLOAK_PORT} -> host tcp:${KEYCLOAK_PORT} (Keycloak)"
else
  echo "warn: adb not found at $ADB — skipping reverse port forward"
fi

exec flutter run \
  -d "$DEVICE" \
  --dart-define-from-file="$ENV_FILE" \
  --dart-define=MAPS_API_KEY="$MAPS_API_KEY" \
  "$@"
