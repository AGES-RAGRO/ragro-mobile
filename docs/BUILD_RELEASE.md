# RAGRO Mobile — Gerar build de release (Android APK/AAB + iOS)

Guia passo a passo para gerar os artefatos de produção do app. O app aponta para o
backend de produção (API Gateway AWS) via `env/prod.json`.

> **Resumo rápido**
> - **Android**: dá pra fazer em Linux/Mac/Windows (precisa Android SDK + JDK 21).
> - **iOS**: **só em macOS com Xcode** + conta Apple Developer. Não dá pra gerar em Linux/Windows.

---

## 0. Pré-requisitos (uma vez por máquina)

- **Flutter** stable 3.44+ (`flutter --version`) e Dart 3.11+.
- **Android**: Android SDK (via Android Studio) + **JDK 21**.
  - Se o `java` padrão da máquina não for o 21, exporte antes de buildar:
    `export JAVA_HOME=/caminho/para/jdk-21`.
- **iOS** (macOS): Xcode + Command Line Tools + CocoaPods (`sudo gem install cocoapods`).
- Clonar o repo e entrar em `ragro-mobile/`.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # gera DI/código
```

### Chave do Google Maps (obrigatória nos dois — senão o mapa abre em branco)

A chave **não** está no git (é secreta). Crie os arquivos locais (gitignored):

- **Android** → `android/local.properties` (adicione a linha):
  ```
  MAPS_API_KEY=AIza...sua-chave-android
  ```
- **iOS** → `ios/Flutter/Env.xcconfig`:
  ```
  GOOGLE_MAPS_API_KEY=AIza...sua-chave-ios
  ```

> Peça a chave para o Gustavo. Em produção a chave deve ser **restrita** no Google Cloud
> Console: Android = package `com.ragro.ragro_mobile` + SHA-1 do keystore de release;
> iOS = bundle id `com.ragro.ragroMobile`.

---

## 1. Android — APK / App Bundle de produção

### 1.1 Keystore de release (uma vez)

O build de release exige uma assinatura própria (NÃO use a debug). Gere o keystore uma vez:

```bash
keytool -genkey -v -keystore ~/ragro-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias ragro
```

Guarde as senhas. Crie `android/key.properties` (gitignored) a partir do exemplo
`android/key.properties.example`:

```properties
storeFile=/caminho/absoluto/para/ragro-release.jks
storePassword=SUA_SENHA
keyAlias=ragro
keyPassword=SUA_SENHA
```

> Sem `android/key.properties`, o build de release **cai para a chave de debug** (com um
> warning no log) — não publicável e sem autenticidade. Pegue o **SHA-1** do release com:
> `keytool -list -v -keystore ~/ragro-release.jks -alias ragro` e cadastre na restrição
> da chave do Maps, senão o mapa quebra no APK assinado.

### 1.2 Gerar o artefato

Há um script que valida os pré-requisitos e builda com a config de prod:

```bash
# APK (instalação direta / testes):
MAPS_API_KEY=AIza...sua-chave  ./scripts/build_apk_prod.sh

# App Bundle (.aab) para a Play Store:
MAPS_API_KEY=AIza...sua-chave  ./scripts/build_apk_prod.sh appbundle
```

Equivalente manual (o que o script faz):
```bash
flutter build apk --release --dart-define-from-file=env/prod.json
# ou
flutter build appbundle --release --dart-define-from-file=env/prod.json
```

### 1.3 Saída e verificação

- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

Confirme que está assinado com o keystore de release (não o debug):
```bash
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```
Instalar num device: `adb install build/app/outputs/flutter-apk/app-release.apk`.

---

## 2. iOS — build de produção (apenas em macOS)

### 2.1 Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
cd ios && pod install && cd ..
```
Garanta que `ios/Flutter/Env.xcconfig` tem o `GOOGLE_MAPS_API_KEY` (passo 0).

### 2.2 Assinatura (Apple Developer)

1. Abra o workspace no Xcode: `open ios/Runner.xcworkspace`.
2. Selecione o target **Runner** → aba **Signing & Capabilities**.
3. Marque **Automatically manage signing** e escolha o **Team** da conta Apple Developer.
4. Confirme o **Bundle Identifier**: `com.ragro.ragroMobile` (precisa estar registrado no
   portal da Apple e a chave do Maps liberada para ele).

### 2.3 Gerar o build

Opção A — Xcode (recomendada para TestFlight/App Store):
1. No topo do Xcode escolha **Any iOS Device (arm64)**.
2. Menu **Product → Archive**.
3. No **Organizer**, **Distribute App** → App Store Connect (TestFlight) ou Ad Hoc/Development.

Opção B — linha de comando:
```bash
flutter build ipa --release --dart-define-from-file=env/prod.json
```
Saída: `build/ios/ipa/*.ipa` (e o archive em `build/ios/archive/`). Para subir:
Xcode **Organizer** ou o app **Transporter**.

> Em iOS a base URL de prod também vem do `--dart-define-from-file=env/prod.json`.
> O mapa usa a chave do `Env.xcconfig` (lida no `AppDelegate.swift`).

---

## 3. Checklist final antes de distribuir

- [ ] `env/prod.json` aponta para a API de produção (hoje: `https://7ruopxdlm7.execute-api.us-east-2.amazonaws.com`).
- [ ] Android assinado com keystore de release (`apksigner verify`), não debug.
- [ ] Chave do Maps presente (Android `local.properties`, iOS `Env.xcconfig`) e **restrita** no Google Cloud (package/bundle + SHA-1).
- [ ] Mapa renderiza (não fica cinza/branco) no app instalado.
- [ ] Login funciona e persiste (token vai para armazenamento seguro).
- [ ] Fotos de produto carregam (backend precisa do `MEDIA_PUBLIC_URL` certo em prod — não `localhost`).
- [ ] Versão em `pubspec.yaml` (`version: 1.0.0+1`) incrementada se for nova publicação.

## Problemas comuns

| Sintoma | Causa | Correção |
|---|---|---|
| Mapa em branco/cinza | `MAPS_API_KEY`/`GOOGLE_MAPS_API_KEY` vazio ou chave não restrita p/ o app | Setar a chave (passo 0) e liberar package/bundle + SHA-1 no Google Cloud |
| `app-release.apk` rejeitado na Play Store | assinado com chave debug | Criar `android/key.properties` (passo 1.1) |
| Fotos não carregam só em prod | backend sem `MEDIA_PUBLIC_URL` (vira `localhost:8080`) | Config do backend/ECS (não é do app) |
| iOS não buildou | rodando em Linux/Windows | iOS exige macOS + Xcode |
