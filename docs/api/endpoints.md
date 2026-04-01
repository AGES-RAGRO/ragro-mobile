# RAGRO API — Endpoint Reference

Base URL: `https://api.ragro.com.br`

All authenticated endpoints require the header: `Authorization: Bearer <token>`

---

## Auth

### POST /auth/login

Authenticates a user (consumer, producer, or admin).

**Request Body:**
```json
{
  "email": "consumer@ragro.com.br",
  "password": "123456"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user_c001",
    "name": "Ricardo Aguiar",
    "email": "consumer@ragro.com.br",
    "phone": "(51) 99999-0001",
    "type": "consumer",
    "active": true
  }
}
```

The `type` field can be: `"consumer"`, `"producer"`, or `"admin"`. Used for post-login routing.

**Errors:**
- `401 Unauthorized` → invalid credentials

---

### POST /auth/register/consumer

Registers a new consumer.

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

## Consumers

### GET /consumers/:id

Returns the complete consumer profile. Requires authentication.

**Path Parameters:** `id` — consumer ID

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

### PUT /consumers/:id

Updates consumer data. Requires authentication. Only the consumer themselves can update.

**Path Parameters:** `id` — consumer ID

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

**Response (200 OK):** updated consumer object (same shape as GET)

---

## Producers

### GET /producers

Lists active producers with pagination and filter support.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | `int` | Page number (default: 1) |
| `limit` | `int` | Items per page (default: 20) |
| `active` | `bool` | Filter by active/inactive status |

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

### GET /producers/:id

Returns the complete producer profile, including a list of available products.

**Path Parameters:** `id` — producer ID

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

### GET /recommendations

Returns recommended products and producers for the consumer home feed. Requires consumer authentication.

**Response (200 OK):**
```json
{
  "featuredProducers": [ ... ],
  "recommendedProducts": [ ... ]
}
```

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

## Products / Inventory

### GET /products?producer_id=

Lists products for a producer. Requires producer authentication.

**Query Parameters:** `producer_id` — producer ID

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

### POST /products

Creates a new product in the producer's inventory. Requires producer authentication.

**Request Body:**
```json
{
  "name": "Alface Crespa",
  "description": "Alface orgânica cultivada sem agrotóxicos",
  "price": 3.50,
  "unit": "unidade",
  "stock": 50,
  "category": "hortaliças",
  "imageUrl": "https://..."
}
```

**Response (201 Created):** created product object

---

### PUT /products/:id

Updates an existing product. Requires producer authentication.

**Path Parameters:** `id` — product ID

**Request Body:** same shape as POST

**Response (200 OK):** updated product object

---

### DELETE /products/:id

Removes a product from the inventory. Requires producer authentication.

**Path Parameters:** `id` — product ID

**Response (204 No Content)**

---

## Orders — Consumer

### GET /orders?status=

Lists orders for the authenticated consumer.

**Query Parameters:**
| Parameter | Type | Values | Description |
|-----------|------|--------|-------------|
| `status` | `string` | `pending`, `confirmed`, `delivered`, `cancelled` | Filter by status |

**Response (200 OK):**
```json
[
  {
    "id": "order_001",
    "producerName": "Sítio Boa Vista",
    "producerPhoto": "https://...",
    "status": "confirmed",
    "total": 45.50,
    "createdAt": "2024-01-15T10:30:00Z",
    "items": [ ... ]
  }
]
```

---

### GET /orders/:id

Returns the complete detail of a consumer order.

**Response (200 OK):**
```json
{
  "id": "order_001",
  "producerId": "prod_001",
  "producerName": "Sítio Boa Vista",
  "producerPhoto": "https://...",
  "ownerName": "João Silva",
  "status": "confirmed",
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

---

### POST /orders

Creates a new order from the current cart. Requires consumer authentication.

**Request Body:**
```json
{
  "cart_id": "cart_abc123"
}
```

**Response (201 Created):** created order object

---

### POST /orders/:id/rating

Rates the producer after order delivery.

**Path Parameters:** `id` — order ID

**Request Body:**
```json
{
  "rating": 5
}
```

**Response (200 OK):** rating confirmation

---

## Orders — Producer

### GET /orders/producer?status=

Lists orders received by the authenticated producer.

**Query Parameters:** `status` — same values as the consumer listing

**Response (200 OK):** array of orders (same shape)

---

### GET /orders/today

Lists today's orders for the authenticated producer. Used for the daily summary on the dashboard.

**Response (200 OK):** array of today's orders

---

### POST /orders/:id/confirm

Confirms a pending order.

**Path Parameters:** `id` — order ID

**Response (200 OK):** order with status `"confirmed"`

---

### POST /orders/:id/cancel

Cancels an order.

**Path Parameters:** `id` — order ID

**Response (200 OK):** order with status `"cancelled"`

---

### PATCH /orders/:id/status

Updates an order's status to the next step in the flow.

**Path Parameters:** `id` — order ID

**Request Body:**
```json
{
  "status": "delivered"
}
```

**Valid status values:** `pending` → `confirmed` → `out_for_delivery` → `delivered`

**Response (200 OK):** updated order

---

## Admin

### GET /admin/producers

Lists all producers (active and inactive). Requires admin authentication.

**Response (200 OK):** array of producers with the `active` field

---

### POST /admin/producers

Registers a new producer on the platform. Requires admin authentication.

**Request Body:**
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

---

### PATCH /admin/producers/:id/deactivate

Deactivates a producer (blocks access to the platform). Requires admin authentication.

**Path Parameters:** `id` — producer ID

**Response (200 OK):** producer with `active: false`

---

### PATCH /admin/producers/:id/activate

Reactivates a previously deactivated producer. Requires admin authentication.

**Path Parameters:** `id` — producer ID

**Response (200 OK):** producer with `active: true`
