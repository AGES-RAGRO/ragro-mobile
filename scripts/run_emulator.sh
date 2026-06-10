#!/usr/bin/env bash
set -euo pipefail

# Arquivo de environment a usar (padrão: env/local.json — localhost, sem segredos).
# Para prod: ENV_FILE=env/prod.json ./scripts/run_emulator.sh
# Para outro env: ENV_FILE=env/staging.json ./scripts/run_emulator.sh
ENV_FILE="${ENV_FILE:-env/local.json}"

DEVICE="${DEVICE:-emulator-5554}"
KEYCLOAK_PORT="${KEYCLOAK_PORT:-8180}"
ADB="${ADB:-$HOME/Android/Sdk/platform-tools/adb}"

cd "$(dirname "$0")/.."

# A chave do Google Maps fica APENAS no git-ignored android/local.properties
# (mesma fonte que o build Android lê), nunca no env JSON commitado. Encaminhamos
# para o Dart via --dart-define para a chamada da Directions API funcionar sem a
# chave viver em arquivo versionado. Sobrescreva exportando MAPS_API_KEY antes de
# rodar.
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
