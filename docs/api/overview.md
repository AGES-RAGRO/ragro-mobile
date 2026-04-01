# RAGRO API — Overview

## Base URL

```
https://api.ragro.com.br
```

All requests are made over HTTPS. There is no API version in the URL — versioning is managed via headers when necessary.

---

## Authentication

The API uses **Bearer Token** (JWT) authentication.

After a successful login (`POST /auth/login`), the server returns a `token`. This token must be included in the `Authorization` header of all subsequent requests:

```
Authorization: Bearer <token>
```

The project's `ApiClient` manages this automatically via `setAuthToken()` and adds the header through a Dio interceptor. Once the token is saved locally (SharedPreferences), it is restored and configured in the `ApiClient` when the app starts.

**Token duration**: expiration is managed by the backend. When the token expires, the API will return `401 Unauthorized` and the app will redirect the user to login.

---

## Error Format

When a request fails, the API returns a JSON object with the `error` key:

```json
{
  "error": "Invalid credentials"
}
```

Common HTTP errors:

| Code | Meaning | App Handling |
|------|---------|--------------|
| `400` | Bad Request — invalid data in the body | `UnknownApiException` |
| `401` | Unauthorized — token missing or expired | `InvalidCredentialsApiException` |
| `403` | Forbidden — no permission for the resource | Redirect to login |
| `404` | Not Found — resource does not exist | `UnknownApiException` |
| `422` | Unprocessable Entity — validation failed | Message shown to user |
| `500` | Internal Server Error — backend error | `UnknownApiException` |

---

## Demo Mode (DEMO_MODE)

For visual development, Playwright testing, and demonstrations without a real backend, the app supports a demo mode:

```bash
# Start in demo mode as a producer (default)
flutter run -d chrome --dart-define=DEMO_MODE=true

# Demo mode as a consumer
flutter run -d chrome --dart-define=DEMO_MODE=true --dart-define=DEMO_ROLE=consumer

# Demo mode as an admin
flutter run -d chrome --dart-define=DEMO_MODE=true --dart-define=DEMO_ROLE=admin
```

When `DEMO_MODE=true`, `getCurrentUser()` returns a mocked user without checking the local token and without making any HTTP calls. Authentication is skipped and the app goes directly to the home screen for the configured role.

---

## Demo Credentials

For normal login (via form) during development, the following mocked credentials are available in `AuthRemoteDataSource`:

| Role | Email | Password |
|------|-------|----------|
| Consumer | consumer@ragro.com.br | 123456 |
| Producer | produtor@ragro.com.br | 123456 |
| Admin | admin@ragro.com.br | 123456 |

> These credentials only work with the current mock in `AuthRemoteDataSource.loginUser()`. When the real backend is connected, replace the mock with the real implementation (the code is commented in the file).

---

## Pagination

List endpoints support pagination parameters via query string:

```
GET /producers?page=1&limit=20
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | `int` | `1` | Current page (1-indexed) |
| `limit` | `int` | `20` | Items per page |

---

## ApiClient — Configuration

`ApiClient` is the Dio wrapper used in all remote datasources. It:

1. Configures timeouts (connection: 15s, receive: 30s)
2. Automatically adds the `Authorization: Bearer <token>` header via interceptor
3. Throws typed `ApiException` instances on HTTP errors

```dart
// Usage in datasources:
final response = await _apiClient.dio.get<Map<String, dynamic>>(
  ApiEndpoints.producers,
  queryParameters: {'page': 1, 'limit': 20},
);
```
