#!/usr/bin/env bash
set -euo pipefail

API_BASE_URL="${API_BASE_URL:-http://10.0.2.2:8080}"
DEVICE="${DEVICE:-emulator-5554}"
KEYCLOAK_PORT="${KEYCLOAK_PORT:-8180}"
ADB="${ADB:-$HOME/Android/Sdk/platform-tools/adb}"

cd "$(dirname "$0")/.."

if [ -x "$ADB" ]; then
  "$ADB" -s "$DEVICE" reverse "tcp:${KEYCLOAK_PORT}" "tcp:${KEYCLOAK_PORT}" >/dev/null
  echo "adb reverse tcp:${KEYCLOAK_PORT} -> host tcp:${KEYCLOAK_PORT} (Keycloak)"
else
  echo "warn: adb not found at $ADB — skipping reverse port forward"
fi

exec flutter run \
  -d "$DEVICE" \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  "$@"
