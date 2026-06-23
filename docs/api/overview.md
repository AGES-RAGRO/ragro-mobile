# RAGRO API — Overview

## Base URL

The base URL is not hardcoded in the app — it is read from the `API_BASE_URL` key of the selected environment file under `env/` (e.g. the current prod build points to `https://9zjh97ezih.execute-api.us-east-2.amazonaws.com/`). The default, when no environment is provided, is the local backend `http://localhost:8080`.

All requests are made over HTTPS. There is no API version in the URL — versioning is managed via headers when necessary.

To switch backends, pass `--dart-define-from-file=env/<file>.json` (e.g. `env/local.json`, `env/prod.json`); each file sets `API_BASE_URL`. An optional `--dart-define=API_BASE_URL=https://...` override is also honored.

---

## Authentication

The API uses **Keycloak** as its identity provider. The backend does not have a login endpoint — the app authenticates directly with Keycloak and uses the resulting JWT for all backend calls.

### Login Flow

1. **Get configuration** — `GET /auth/config` (public, no token required)
   Returns the Keycloak token URL, client ID, and realm.

2. **Authenticate with Keycloak** — `POST {tokenUrl}` (direct to Keycloak)
   Sends email and password as `application/x-www-form-urlencoded`. Returns `access_token` and `refresh_token`.

3. **Get user session** — `GET /auth/session` (requires Bearer token)
   Returns the authenticated user's data from the database: `id`, `name`, `email`, `type`, `active`.

After login, the `access_token` must be included in the `Authorization` header of all subsequent requests:

```
Authorization: Bearer <access_token>
```

The project's `ApiClient` manages this automatically via `setAuthToken()`.

### Token Refresh

The `access_token` has a short lifespan (default: 5 minutes). When it expires, the app should attempt to refresh it using the `refresh_token` before redirecting to login:

```
POST {tokenUrl}
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token
client_id={clientId}
refresh_token={savedRefreshToken}
```

If the refresh succeeds, update both tokens locally. If it fails (refresh token expired), clear the session and redirect to login.

### Logout

Clear the tokens from local storage and remove the `Authorization` header from `ApiClient`. Optionally, call Keycloak's logout endpoint to invalidate the session server-side.

---

## Error Format

When a request fails, the API returns a JSON object:

```json
{
  "error": "Invalid credentials"
}
```

Common HTTP errors:

| Code | Meaning | App Handling |
|------|---------|--------------|
| `400` | Bad Request — invalid data in the body | `UnknownApiException` |
| `401` | Unauthorized — token missing or expired | `UnauthorizedException`, or `DeactivatedAccountException` when the `error` body indicates a deactivated account (`inativo`/`desativad`) |
| `403` | Forbidden — no permission for the resource | `ForbiddenException` |
| `404` | Not Found — resource does not exist | `NotFoundException` |
| `409` | Conflict — duplicate resource | `ConflictException` |
| `429` | Too Many Requests — rate limited | `RateLimitedException` |
| `500` | Internal Server Error — backend error | `ServerException` |

Connection-level failures (no HTTP status) are also mapped: connection/receive/send timeouts become `ApiTimeoutException`, and connection errors become `NetworkException`.

---

## Test Users

Three users are pre-configured in both Keycloak and the database when the backend starts with Docker:

| Role | Email | Password |
|------|-------|----------|
| Customer | `customer@ragro.com.br` | `Test@123` |
| Farmer | `farmer@ragro.com.br` | `Test@123` |
| Admin | `admin@ragro.com.br` | `Admin@123` |

These credentials authenticate against the local Keycloak instance at `http://localhost:8180` (or its AWS equivalent), depending on the backend selected through `API_BASE_URL`. The Keycloak token URL is not hardcoded in the app — it is discovered at runtime from `GET /auth/config`.

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

## Pagination

List endpoints follow the Spring Pageable convention. They support pagination parameters via query string:

```
GET /producers?page=0&size=20
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | `int` | `0` | Current page (0-indexed) |
| `size` | `int` | `20` | Items per page |

Paginated responses are decoded by `PaginatedResponse`, which exposes `content`, `page`, `size`, `totalElements`, and `totalPages`.

---

## ApiClient — Configuration

`ApiClient` is the Dio wrapper used in all remote datasources. It:

1. Configures timeouts (10s for connection, receive, and send)
2. Automatically adds the `Authorization: Bearer <token>` header, except on public endpoints (`ApiEndpoints.isPublic` — `/auth/register/customer`, `/auth/password/forgot`, `/auth/config`), which are sent without it
3. Throws typed `ApiException` instances on HTTP errors

```dart
// Usage in datasources:
final response = await _apiClient.dio.get<Map<String, dynamic>>(
  ApiEndpoints.producers,
  queryParameters: {'page': 0, 'size': 20},
);
```
