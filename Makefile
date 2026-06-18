# ============================================================
# Ragro Mobile — comandos de desenvolvimento
# ============================================================
# Uso: make <target>
# ============================================================

# Atualiza o IP do Mac em env/local-device.json automaticamente
.PHONY: update-ip
update-ip:
	@IP=$$(ipconfig getifaddr en0 || ipconfig getifaddr en1); \
	echo "{\"API_BASE_URL\": \"http://$$IP:8080\"}" > env/local-device.json; \
	echo "IP atualizado: $$IP"

# iOS Simulator (localhost funciona)
.PHONY: ios-sim
ios-sim:
	flutter run --dart-define-from-file=env/local.json

# iOS dispositivo físico (usa IP da rede local)
.PHONY: ios-device
ios-device: update-ip
	flutter run --dart-define-from-file=env/local-device.json

# Android emulador (10.0.2.2 já é tratado no código)
.PHONY: android
android:
	flutter run --dart-define-from-file=env/local.json

# Web (Chrome)
.PHONY: web
web:
	flutter run -d chrome --dart-define-from-file=env/local.json

# Regenerar código de injeção de dependência
.PHONY: gen
gen:
	dart run build_runner build --delete-conflicting-outputs

# Subir backend com Docker
.PHONY: backend
backend:
	cd ../ragro-backend && docker compose up -d

# Derrubar backend
.PHONY: backend-down
backend-down:
	cd ../ragro-backend && docker compose down
