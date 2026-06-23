# RAGRO API — Endpoint Reference

Base URL (prod): `https://9zjh97ezih.execute-api.us-east-2.amazonaws.com`

Local default: `http://localhost:8080`. The app resolves the base from `API_BASE_URL` (passed via `--dart-define-from-file=env/prod.json` or a process env var) and falls back to `http://localhost:8080`. On Android emulators it automatically rewrites `localhost`/`127.0.0.1` hosts to `10.0.2.2`, so no manual `10.0.2.2` value is needed (`lib/core/network/api_endpoints.dart`).

All authenticated endpoints require the header: `Authorization: Bearer <token>`. The backend is an OAuth2 resource server (Keycloak); the public chain only covers `/auth/config`, `/auth/register/customer`, `/auth/password/reset`, and `/auth/password/forgot`.

> Source of truth: `lib/core/network/api_endpoints.dart` (mobile) cross-checked against the backend controllers under `br.com.ragro.controller`.

---

## Auth

### GET /auth/config

Returns the Keycloak authentication configuration. No authentication required.

**Response (200 OK):**
```json
{
  "tokenUrl": "https://kwn6g5amn5.execute-api.us-east-2.amazonaws.com/realms/ragro/protocol/openid-connect/token",
  "clientId": "ragro-app",
  "realm": "ragro"
}
```

---

### POST {tokenUrl} (Keycloak)

Authenticates a user directly with Keycloak. The `tokenUrl` is obtained from `GET /auth/config`.

**Content-Type:** `application/x-www-form-urlencoded`

**Request Body:**
```
grant_type=password
client_id=ragro-app
username=customer@ragro.com.br
password=Test@123
```

**Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 300,
  "token_type": "Bearer"
}
```

**Errors:**
- `401 Unauthorized` → invalid email or password

---

### GET /auth/session

Returns the authenticated user's session data from the database. Requires valid JWT.

**Response (200 OK):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Ricardo Aguiar",
  "email": "consumer@ragro.com.br",
  "type": "customer",
  "active": true
}
```

The `type` field can be: `"customer"`, `"farmer"`, or `"admin"`. The app maps these to `consumer`, `producer`, `admin` respectively for routing.

**Errors:**
- `401 Unauthorized` → token missing or user not found in database

---

### POST /auth/register/customer

Registers a new customer. No authentication required.

**Request Body:**
```json
{
  "name": "João da Silva",
  "email": "joao@email.com",
  "password": "minhasenha123",
  "phone": "(51) 98765-4321",
  "address": {
    "zip_code": "90010-000",
    "street": "Rua das Flores",
    "number": "123",
    "complement": "Apto 45",
    "city": "Porto Alegre",
    "state": "RS"
  }
}
```

**Response (201 Created):**
```json
{
  "id": "user_c002",
  "name": "João da Silva",
  "email": "joao@email.com",
  "phone": "(51) 98765-4321",
  "type": "consumer",
  "active": true
}
```

**Errors:**
- `422 Unprocessable Entity` → email already registered or invalid data

---

### POST /auth/password/forgot

Starts the password-reset flow for the given email. No authentication required.

---

### POST /auth/password/reset

Completes a password reset. No authentication required.

---

## Customers

The profile API is scoped by JWT; there is no `:id` path parameter (the caller is identified by the token).

### GET /customers/me

Returns the authenticated customer's profile. Requires authentication.

**Response (200 OK):**
```json
{
  "id": "user_c001",
  "name": "Ricardo Aguiar",
  "email": "consumer@ragro.com.br",
  "phone": "(51) 99999-0001",
  "type": "consumer",
  "active": true,
  "address": {
    "zip_code": "90010-000",
    "street": "Rua das Flores",
    "number": "123",
    "city": "Porto Alegre",
    "state": "RS"
  }
}
```

---

### PUT /customers/me

Updates the authenticated customer's data. Requires authentication.

**Request Body:**
```json
{
  "name": "Ricardo Aguiar",
  "phone": "(51) 99999-0001",
  "fiscal_number": "123.456.789-00",
  "address": {
    "zip_code": "90010-000",
    "street": "Rua das Flores",
    "number": "123",
    "complement": "Apto 45",
    "city": "Porto Alegre",
    "state": "RS"
  }
}
```

**Response (200 OK):** updated customer object (same shape as GET)

---

### Favorite producers

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/customers/me/favorites` | Lists the customer's favorite producers |
| `POST` | `/customers/me/favorites/{producerId}` | Adds a producer to favorites |
| `DELETE` | `/customers/me/favorites/{producerId}` | Removes a producer from favorites |

All require customer authentication.

---

## Cart

The cart is scoped to the authenticated customer; `POST /orders` resolves the cart server-side.

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/customers/carts` | Returns the current cart |
| `POST` | `/customers/carts/items` | Adds an item to the cart |
| `PATCH` | `/customers/carts/items/{id}` | Updates a cart item (e.g. quantity) |
| `DELETE` | `/customers/carts/items/{id}` | Removes a cart item |
| `DELETE` | `/customers/carts` | Clears the cart |

All require customer authentication.

---

## Producers

### GET /producers

Lists producers with pagination and sorting (default `sortBy=rating`).

**Response (200 OK):**
```json
[
  {
    "id": "prod_001",
    "name": "Sítio Boa Vista",
    "ownerName": "João Silva",
    "description": "Produtos orgânicos certificados",
    "city": "Viamão",
    "state": "RS",
    "rating": 4.8,
    "photoUrl": "https://...",
    "active": true
  }
]
```

---

### GET /producers/locations

Returns producer locations for the map feature.

---

### GET /producers/{id}

Returns the complete producer profile, including a list of available products.

**Response (200 OK):**
```json
{
  "id": "prod_001",
  "name": "Sítio Boa Vista",
  "ownerName": "João Silva",
  "description": "Produtos orgânicos certificados",
  "story": "Nossa história começa em 1985...",
  "city": "Viamão",
  "state": "RS",
  "phone": "(51) 99999-0002",
  "rating": 4.8,
  "reviewCount": 42,
  "photoUrl": "https://...",
  "active": true,
  "memberSince": "2023-01-15T00:00:00Z",
  "products": [ ... ]
}
```

---

### Other producer endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/producers/{id}/profile` | Public producer profile |
| `GET` | `/producers/{id}/products` | Products of a producer |
| `GET` | `/producers/{producerId}/products/{productId}` | Single product of a producer |
| `GET` | `/producers/{id}/reviews` | Reviews for a producer |
| `POST` | `/producers/{id}/avatar` | Uploads the producer avatar (`multipart/form-data`) |
| `POST` | `/producers/{id}/cover` | Uploads the producer cover image (`multipart/form-data`) |

---

### GET /producers/me/dashboard

Returns metrics for the authenticated producer's dashboard. Requires producer authentication.

**Response (200 OK):**
```json
{
  "totalOrdersToday": 5,
  "totalRevenue": 450.00,
  "pendingOrders": 3,
  "activeProducts": 12
}
```

---

### GET /producers/me/dashboard/week

Returns daily sales data for the last 7 days (including today) for the authenticated producer's dashboard.

---

## Producer inventory

Producer inventory CRUD is scoped to the authenticated FARMER (no `producer_id` query parameter).

### GET /producers/products

Lists the authenticated producer's products. Requires producer authentication.

**Response (200 OK):**
```json
[
  {
    "id": "product_001",
    "producerId": "prod_001",
    "name": "Alface Crespa",
    "description": "Alface orgânica cultivada sem agrotóxicos",
    "price": 3.50,
    "unit": "unidade",
    "stock": 50,
    "category": "hortaliças",
    "imageUrl": "https://...",
    "active": true
  }
]
```

---

### GET /producers/products/categories

Lists the product categories available to the producer.

---

### POST /producers/products

Creates a new product in the producer's inventory. Requires producer authentication. The product photo is uploaded separately (see below) — there is no `imageUrl` field in this JSON body.

**Request Body:**
```json
{
  "name": "Alface Crespa",
  "description": "Alface orgânica cultivada sem agrotóxicos",
  "price": 3.50,
  "unit": "unidade",
  "stock": 50,
  "category": "hortaliças"
}
```

**Response (201 Created):** created product object

---

### PUT /producers/products/{id}

Updates an existing product. Requires producer authentication.

**Request Body:** same shape as POST

**Response (200 OK):** updated product object

---

### DELETE /producers/products/{id}

Removes a product from the inventory. Requires producer authentication.

**Response (204 No Content)**

---

### POST /producers/products/{id}/photo

Uploads/replaces the product photo. Requires producer authentication.

**Content-Type:** `multipart/form-data`

---

## Stock movements

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/producers/stock/entry` | Records a stock entry |
| `POST` | `/producers/stock/exit` | Records a stock exit |
| `GET` | `/producers/stock/movements` | Lists all stock movements |
| `GET` | `/producers/stock/{productId}/movements` | Lists movements for one product |

All require producer authentication.

---

## Products

The bare product endpoints back generic product lookups in the app.

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/products` | Lists products |
| `GET` | `/products/{id}` | Returns a single product |

> Producer-owned inventory CRUD lives under `/producers/products` (see **Producer inventory**), not here.

---

## Search

### GET /search

Powers the search feature. Requires authentication.

---

## Recommendations

### GET /recommendations

Returns recommended products and producers for the consumer home feed. Requires consumer authentication. (Backed by Spring AI → NVIDIA.)

**Response (200 OK):** illustrative shape
```json
{
  "featuredProducers": [ ... ],
  "recommendedProducts": [ ... ]
}
```

---

## Orders

Order status values follow the `OrderStatus` enum: `PENDING` → `CONFIRMED` → `IN_DELIVERY` → `DELIVERED`, plus `CANCELLED`. Refusal is a separate transition (see `/orders/{id}/refuse`).

### Consumer

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/orders/consumer` | Lists the authenticated consumer's orders |
| `GET` | `/orders/customer/{id}` | Returns the detail of one consumer order |
| `POST` | `/orders` | Creates an order from the active cart |
| `PATCH` | `/orders/customer/{id}/cancel` | Consumer cancels their order |
| `PATCH` | `/orders/customer/{id}/confirm-delivery` | Consumer confirms delivery |
| `PATCH` | `/orders/{id}/seen` | Marks the order as seen |
| `POST` | `/orders/{id}/repeat` | Repeats a previous order |

`POST /orders` takes no request body — the cart is resolved server-side from the authenticated customer's cart (`/customers/carts`), and the primary delivery address / default payment method are selected automatically.

**`GET /orders/customer/{id}` response (200 OK):**
```json
{
  "id": "order_001",
  "producerId": "prod_001",
  "producerName": "Sítio Boa Vista",
  "producerPhoto": "https://...",
  "ownerName": "João Silva",
  "status": "CONFIRMED",
  "total": 45.50,
  "createdAt": "2024-01-15T10:30:00Z",
  "estimatedDelivery": "2024-01-20T00:00:00Z",
  "items": [
    {
      "productId": "product_001",
      "productName": "Alface Crespa",
      "quantity": 2,
      "unitPrice": 3.50,
      "subtotal": 7.00
    }
  ]
}
```

### Producer

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/orders/producer` | Lists orders received by the authenticated producer |
| `PATCH` | `/orders/{id}/confirm` | Confirms a pending order |
| `PATCH` | `/orders/{id}/cancel` | Cancels an order |
| `PATCH` | `/orders/{id}/refuse` | Refuses an order |
| `PATCH` | `/orders/{id}/status` | Advances the order to the next status |
| `PATCH` | `/orders/{id}/confirm-delivery-with-code` | Producer confirms delivery using the consumer's 4-digit code |

> Today's/weekly producer metrics come from `GET /producers/me/dashboard` and `GET /producers/me/dashboard/week` — there is no `/orders/today` endpoint.

### GET /orders/{id}/tracking

Returns the tracking state for an order (delivery position, route stop, etc.). See **Routes & real-time tracking**.

---

## Reviews

### POST /reviews

Creates a review for a delivered order. Requires consumer authentication.

**Request Body:**
```json
{
  "orderId": "550e8400-e29b-41d4-a716-446655440000",
  "rating": 5,
  "comment": "Entrega rápida e produtos frescos"
}
```

`rating` must be between 1 and 5; `comment` is optional.

> Producer reviews are read via `GET /producers/{id}/reviews`.

---

## Routes & real-time tracking

Persisted delivery routes (E5) and real-time GPS tracking (E6). The legacy `/routes/optimize` was replaced by the persisted route.

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/routes` | Creates/optimizes a delivery route (Google Routes API) |
| `GET` | `/routes/active` | Returns the producer's active route |
| `PATCH` | `/routes/{routeId}/stops/{stopId}` | Updates a route stop |

**WebSocket (STOMP):** connect to `/ws`. The driver publishes position updates to `@MessageMapping("/routes/{routeId}/position")`; consumers subscribe for live tracking (powers the map feature).

---

## CO2 impact

Drives the impact feature module.

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/co2/calculate` | Calculates CO2 savings for a scenario |
| `GET` | `/co2/preference` | Returns the user's CO2 preference |
| `GET` | `/co2/emissions` | Returns emissions data |
| `POST` | `/co2/record-savings` | Records realized CO2 savings |
| `GET` | `/co2/options` | Lists CO2 options |
| `GET` | `/co2/total-saved` | Returns total CO2 saved |

---

## Notifications

Notifications are role-scoped: identical operations live under `/customers/me/notifications` (CUSTOMER) and `/producers/me/notifications` (FARMER); the mobile data source picks by logged-in role.

| Method | Path (per role prefix) | Description |
|--------|------------------------|-------------|
| `GET` | `/{role}/me/notifications` | Lists notifications |
| `GET` | `/{role}/me/notifications/unread-count` | Returns the unread count |
| `PATCH` | `/{role}/me/notifications/{id}/read` | Marks one notification as read |
| `PATCH` | `/{role}/me/notifications/read-all` | Marks all as read |

`{role}` is `customers` or `producers`.

### POST /notifications/token

Registers an FCM device token (role-agnostic; any authenticated user).

---

## Media

### GET /media/**

Serves all media through the backend (not presigned MinIO URLs). The app rewrites dev-host media URLs to the API base host via `resolveMediaUrl` so images stay reachable on emulators.

---

## Admin

All require admin authentication.

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/admin/dashboard` | Admin dashboard metrics |
| `GET` | `/admin/producers` | Lists all producers (active and inactive) |
| `POST` | `/admin/producers` | Registers a new producer |
| `GET` | `/admin/producers/{id}` | Producer detail |
| `PUT` | `/admin/producers/{id}` | Updates a producer |
| `PATCH` | `/admin/producers/{id}/activate` | Reactivates a producer |
| `PATCH` | `/admin/producers/{id}/deactivate` | Deactivates a producer |
| `GET` | `/admin/customers/{id}` | Customer detail |

**`POST /admin/producers` request body:**
```json
{
  "name": "Sítio Novo",
  "ownerName": "Maria Santos",
  "email": "maria@sitio.com",
  "password": "senha_temporaria",
  "phone": "(51) 99888-7777",
  "city": "Canoas",
  "state": "RS",
  "description": "Produção familiar de vegetais"
}
```

**Response (201 Created):** created producer object
