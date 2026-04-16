# RAGRO — Mobile

Flutter app for RAGRO, a platform connecting small family farmers with urban consumers.

Built with **Clean Architecture + BLoC**.

---

## Tech Stack

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management (BLoC pattern) |
| `get_it` + `injectable` | Automatic dependency injection |
| `dio` | HTTP client |
| `go_router` | Navigation and routing |
| `equatable` | Value-based object comparison |
| `shared_preferences` | Local storage (token, settings) |
| `bloc_test` + `mocktail` | BLoC unit tests and mocks |

---

## Documentation

| Document | Description |
|----------|-------------|
| [`docs/architecture/01-overview.md`](docs/architecture/01-overview.md) | Clean Architecture + BLoC concept and request flow |
| [`docs/architecture/02-folder-structure.md`](docs/architecture/02-folder-structure.md) | Annotated folder tree for all features |
| [`docs/architecture/03-layers.md`](docs/architecture/03-layers.md) | Presentation / Domain / Data layers with code examples |
| [`docs/architecture/04-state-management.md`](docs/architecture/04-state-management.md) | BLoC: events, states, BlocProvider/Builder/Listener |
| [`docs/architecture/05-dependency-injection.md`](docs/architecture/05-dependency-injection.md) | get_it + injectable annotations and how to regenerate |
| [`docs/architecture/06-navigation.md`](docs/architecture/06-navigation.md) | GoRouter: auth guard, shell routes, route table |
| [`docs/architecture/07-new-feature.md`](docs/architecture/07-new-feature.md) | Step-by-step guide for adding a new feature |
| [`docs/api/overview.md`](docs/api/overview.md) | Base URL, Keycloak authentication, test users |
| [`docs/api/endpoints.md`](docs/api/endpoints.md) | All endpoints by domain |
| [`docs/conventions.md`](docs/conventions.md) | Naming conventions and layer boundary rules |
| [`docs/backlog_ragro.md`](docs/backlog_ragro.md) | User stories and acceptance criteria |
| [`docs/database.md`](docs/database.md) | PostgreSQL schema and ER diagram |
| [`docs/figma_screens.md`](docs/figma_screens.md) | Figma node IDs and screen-to-story mapping |

---

## Running the Project

### Prerequisites

| Tool | Min version |
|------|-------------|
| Flutter | 3.41+ |
| Dart | 3.11+ (bundled with Flutter) |

### Setup

```bash
# Install Flutter dependencies
flutter pub get

# Generate dependency injection code
dart run build_runner build --delete-conflicting-outputs

# Run the app (Chrome)
flutter run -d chrome
```

### Testing with the backend (real login)

The app authenticates via Keycloak. You need the backend running locally.

**1. Start the backend** (from `ragro-backend/`):

```bash
docker compose up -d --build
```

This starts PostgreSQL, Keycloak, and the Spring Boot API. Three test users are created automatically in both Keycloak and the database.

**2. Run the Flutter app:**

```bash
flutter run -d chrome
```

The app defaults to `http://localhost:8080` as the API base URL.

**3. Log in with one of the test users:**

| Role | Email | Password |
|------|-------|----------|
| Customer | `customer@ragro.com.br` | `Test@123` |
| Farmer | `farmer@ragro.com.br` | `Test@123` |
| Admin | `admin@ragro.com.br` | `Admin@123` |

The login flow calls `GET /auth/config` to discover the Keycloak token URL, authenticates directly with Keycloak, then calls `GET /auth/session` to get the user's profile. The app routes to the correct home screen based on the user type.

### Demo mode (skip login, no backend needed)

```bash
# As consumer
flutter run -d chrome --dart-define=DEMO_MODE=true --dart-define=DEMO_ROLE=consumer

# As producer
flutter run -d chrome --dart-define=DEMO_MODE=true --dart-define=DEMO_ROLE=producer

# As admin
flutter run -d chrome --dart-define=DEMO_MODE=true --dart-define=DEMO_ROLE=admin
```

### Production base URL

```bash
flutter run --dart-define=API_BASE_URL=https://api.ragro.com.br
```

### Run on Android

```bash
# List connected devices
flutter devices

# Run on device
flutter run -d <device-id>
```

---

## Tests

### Unit tests

```bash
flutter test
```

### Visual regression tests (Playwright)

Requires the Flutter app running on `http://localhost:8080`.

```bash
# 1. Start the app
flutter run -d chrome --dart-define=DEMO_MODE=true --dart-define=DEMO_ROLE=consumer

# 2. Install dependencies (first time only)
cd playwright && npm install

# 3. Run all tests
npm test

# Run by role
npm run test:consumer
npm run test:producer
npm run test:admin

# View HTML report
npm run report
```

---

## Useful Commands

```bash
# Analyze code
dart analyze

# Format code
dart format .

# Regenerate DI code
dart run build_runner build --delete-conflicting-outputs

# Build for web
flutter build web --no-tree-shake-icons
```
