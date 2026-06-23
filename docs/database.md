# RAGRO — Database Documentation

> PostgreSQL 16 · ~26 tables · 2 triggers

> **Note — Source of truth**: The runtime schema lives in the **ragro-backend** Flyway migrations at `ragro-backend/src/main/resources/db/migration/` (`V1` … `V24`, current head `V24__route_positions`). This document describes that schema — when in doubt, the migrations win. Schema changes are made by adding a new migration, never by editing a hand-maintained file.

---

## Table of Contents

- [Entity-Relationship Diagram](#entity-relationship-diagram)
- [Domains](#domains)
- [Tables](#tables)
  - [Users and Profiles](#users-and-profiles)
  - [Products and Inventory](#products-and-inventory)
  - [Cart and Orders](#cart-and-orders)
  - [Reviews and Favorites](#reviews-and-favorites)
  - [Logistics](#logistics)
  - [Sustainability / CO2](#sustainability--co2)
  - [Notifications](#notifications)
  - [Payment](#payment)
- [Triggers](#triggers)
---

## Entity-Relationship Diagram

```mermaid
erDiagram
    users {
        uuid id PK
        varchar name
        varchar email
        varchar phone
        varchar type
        boolean active
        text auth_sub
        timestamptz created_at
        timestamptz updated_at
    }
    farmers {
        uuid id PK_FK
        varchar fiscal_number
        varchar fiscal_number_type
        varchar farm_name
        text description
        text avatar_s3
        text display_photo_s3
        integer total_reviews
        decimal average_rating
        integer total_orders
        decimal total_sales_amount
        timestamptz created_at
        timestamptz updated_at
    }
    producer_profiles {
        uuid id PK_FK
        text story
        text photo_url
        date member_since
        timestamptz created_at
        timestamptz updated_at
    }
    customers {
        uuid id PK_FK
        char fiscal_number
        timestamptz created_at
        timestamptz updated_at
    }
    addresses {
        uuid id PK
        uuid user_id FK
        varchar street
        varchar number
        varchar city
        char state
        char zip_code
        decimal latitude
        decimal longitude
        boolean is_primary
        varchar geocode_status
        timestamptz geocoded_at
        timestamptz created_at
    }
    farmer_availability {
        uuid id PK
        uuid farmer_id FK
        smallint weekday
        time opens_at
        time closes_at
        boolean active
    }
    product_categories {
        serial id PK
        varchar name
        text description
    }
    products {
        uuid id PK
        uuid farmer_id FK
        varchar name
        text description
        decimal price
        varchar unity_type
        decimal stock_quantity
        text image_s3
        boolean active
        bigint version
        timestamptz created_at
        timestamptz updated_at
    }
    product_category_assignments {
        uuid product_id PK_FK
        integer category_id PK_FK
    }
    product_photos {
        uuid id PK
        uuid product_id FK
        text url
        smallint display_order
        timestamptz created_at
    }
    stock_movements {
        uuid id PK
        uuid product_id FK
        varchar type
        varchar reason
        decimal quantity
        text notes
        timestamptz created_at
    }
    carts {
        uuid id PK
        uuid customer_id FK
        uuid farmer_id FK
        boolean active
        timestamptz created_at
        timestamptz updated_at
    }
    cart_items {
        uuid id PK
        uuid cart_id FK
        uuid product_id FK
        decimal quantity
        boolean active
    }
    orders {
        uuid id PK
        uuid customer_id FK
        uuid farmer_id FK
        uuid delivery_address_id FK
        jsonb delivery_address_snapshot
        varchar status
        uuid payment_method_id FK
        varchar payment_status
        timestamptz scheduled_for
        timestamptz delivered_at
        text notes
        text cancellation_reason
        text cancellation_details
        boolean seen_by_farmer
        varchar confirmation_code
        integer confirmation_attempts
        timestamptz confirmation_locked_until
        timestamptz created_at
        timestamptz updated_at
    }
    order_items {
        uuid id PK
        uuid order_id FK
        uuid product_id FK
        varchar product_name_snapshot
        decimal unit_price_snapshot
        varchar unity_type_snapshot
        decimal quantity
        decimal subtotal
    }
    order_status_history {
        uuid id PK
        uuid order_id FK
        varchar status
        timestamptz changed_at
    }
    review {
        uuid id PK
        uuid order_id FK
        uuid farmer_id FK
        uuid customer_id FK
        smallint rating
        text comment
        timestamptz created_at
    }
    favorites {
        uuid customer_id PK_FK
        uuid farmer_id PK_FK
        timestamptz created_at
    }
    delivery_routes {
        uuid id PK
        uuid farmer_id FK
        varchar status
        decimal origin_latitude
        decimal origin_longitude
        decimal total_distance_km
        integer total_duration_seconds
        decimal baseline_distance_km
        text overview_polyline
        timestamptz created_at
        timestamptz completed_at
    }
    route_stops {
        uuid id PK
        uuid route_id FK
        uuid order_id FK
        integer sequence
        varchar status
        decimal latitude
        decimal longitude
        text address_text
        decimal leg_distance_km
        integer leg_duration_seconds
        timestamptz eta
        timestamptz completed_at
    }
    route_positions {
        uuid id PK
        uuid route_id FK
        decimal latitude
        decimal longitude
        decimal accuracy_meters
        decimal speed_kmh
        timestamptz recorded_at
    }
    payment_methods {
        uuid id PK
        uuid farmer_id FK
        varchar type
        varchar pix_key_type
        varchar pix_key
        varchar bank_name
        varchar agency
        varchar account_number
        varchar account_type
        varchar holder_name
        boolean active
        timestamptz created_at
        timestamptz updated_at
    }
    notifications {
        uuid id PK
        uuid user_id FK
        varchar title
        text message
        varchar type
        varchar reference_type
        uuid reference_id
        jsonb metadata
        boolean is_read
        timestamptz created_at
        timestamptz read_at
    }
    fcm_tokens {
        uuid id PK
        uuid user_id FK
        text token
        timestamptz updated_at
    }
    vehicle_preferences {
        uuid user_id PK_FK
        varchar vehicle_type
        varchar fuel_type
        double average_consumption
        timestamptz created_at
        timestamptz updated_at
    }
    co2_savings {
        uuid id PK
        uuid user_id FK
        double distance_optimized
        double distance_non_optimized
        double co2_saved
        varchar vehicle_type
        varchar fuel_type
        double average_consumption
        timestamptz created_at
    }
    co2_emissions {
        uuid id PK
        uuid vehicle_preference_user_id FK
        double route_distance_km
        double co2_emission
        varchar vehicle_type
        varchar fuel_type
        double average_consumption
        timestamptz created_at
    }

    users ||--o{ addresses : "has"
users ||--|| farmers : "is"
users ||--|| customers : "is"
users ||--o{ notifications : "receives"
users ||--o{ fcm_tokens : "registers"
users ||--o| vehicle_preferences : "has"
users ||--o{ co2_savings : "accrues"
farmers ||--|| producer_profiles : "has"
farmers ||--o{ farmer_availability : "has"
farmers ||--o{ products : "sells"
farmers ||--o{ delivery_routes : "creates"
farmers ||--o{ payment_methods : "has"
farmers ||--o{ carts : "receives from"
farmers ||--o{ orders : "receives"
customers ||--o{ carts : "has"
customers ||--o{ orders : "places"
customers ||--o{ review : "writes"
customers ||--o{ favorites : "has"
products ||--o{ product_photos : "has"
products ||--o{ product_category_assignments : "belongs to"
products ||--o{ stock_movements : "tracks"
products ||--o{ cart_items : "is in"
products ||--o{ order_items : "is in"
product_categories ||--o{ product_category_assignments : "has"
carts ||--o{ cart_items : "contains"
orders ||--o{ order_items : "contains"
orders ||--o{ order_status_history : "tracks"
orders ||--|| review : "has"
orders ||--o| route_stops : "has"
payment_methods ||--o{ orders : "used in"
addresses ||--o{ orders : "delivered to"
delivery_routes ||--o{ route_stops : "has"
delivery_routes ||--o{ route_positions : "tracks"
vehicle_preferences ||--o{ co2_emissions : "produces"
```

---

## Domains

| Domain | Tables |
|--------|--------|
| 👤 Users and Profiles | `users` `farmers` `producer_profiles` `customers` `addresses` `farmer_availability` |
| 📦 Products and Inventory | `products` `product_categories` `product_category_assignments` `product_photos` `stock_movements` |
| 🛒 Cart and Orders | `carts` `cart_items` `orders` `order_items` `order_status_history` |
| ⭐ Reviews and Favorites | `review` `favorites` |
| 🚚 Logistics | `delivery_routes` `route_stops` `route_positions` |
| 🌱 Sustainability / CO2 | `vehicle_preferences` `co2_savings` `co2_emissions` |
| 🔔 Notifications | `notifications` `fcm_tokens` |
| 💳 Payment | `payment_methods` |

---

## Tables

### Users and Profiles

#### `users`
Base authentication table shared across all user types.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Automatically generated primary key |
| `name` | varchar(120) | ✅ | User’s full name |
| `email` | varchar(254) | ✅ | Unique email — used as login |
| `phone` | varchar(20) | ❌ | Contact phone number |
| `type` | varchar(20) | ✅ | User role: `farmer` \| `customer` \| `admin` |
| `active` | boolean | ✅ | `false` = account disabled, prevents system access |
| `auth_sub` | text | ✅ | Unique identifier from Keycloak. Links the JWT token to the database record |
| `created_at` | timestamptz | ✅ | Record creation timestamp |
| `updated_at` | timestamptz | ✅ | Last update timestamp |

> **Note:** The `auth_sub` acts as the bridge between the authentication system (Keycloak) and the database. When the user logs in, the backend reads the `sub` from the JWT token and fetches the corresponding record using `WHERE auth_sub = ?`.

---

#### `farmers`
Extended profile for farmers. The `id` is the same as `users.id` — a 1:1 relationship.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | FK → `users.id` — same identifier |
| `fiscal_number` | varchar(14) | ✅ | CPF (11 digits) or CNPJ (14 digits) |
| `fiscal_number_type` | varchar(5) | ✅ | Document type: `cpf` \| `cnpj` |
| `farm_name` | varchar(150) | ✅ | Farm name displayed in the marketplace |
| `description` | text | ❌ | Short description shown on marketplace cards |
| `avatar_s3` | text | ❌ | Profile picture URL stored in S3 |
| `display_photo_s3` | text | ❌ | Cover photo URL stored in S3 |
| `total_reviews` | integer | ✅ | Denormalized counter — updated after each review |
| `average_rating` | decimal(3,2) | ✅ | Denormalized rating average — updated after each review |
| `total_orders` | integer | ✅ | Total delivered orders — used in financial dashboard |
| `total_sales_amount` | decimal(14,2) | ✅ | Total revenue in BRL — used in financial dashboard |
| `created_at` | timestamptz | ✅ | Record creation timestamp |
| `updated_at` | timestamptz | ✅ | Last update timestamp |

> **Note:** The fields `total_reviews`, `average_rating`, `total_orders`, and `total_sales_amount` are intentionally denormalized to avoid expensive `COUNT`/`AVG` queries on every profile load. Maintaining consistency of these values is the responsibility of the application layer when processing orders and reviews.

---

#### `producer_profiles`
Extra producer-facing profile data (narrative, cover photo, member-since). The `id` is the same as `farmers.id` / `users.id` — a 1:1 relationship.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | FK → `farmers.id` — same identifier |
| `story` | text | ❌ | Full story displayed on the detailed profile |
| `photo_url` | text | ❌ | Cover photo URL |
| `member_since` | date | ✅ | Date the producer joined — backfilled from `users.created_at` in `V21` |
| `created_at` | timestamptz | ✅ | Record creation timestamp |
| `updated_at` | timestamptz | ✅ | Last update timestamp |

---

#### `customers`
Extended profile for customers. The `id` is the same as `users.id` — a 1:1 relationship.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | FK → `users.id` — same identifier |
| `fiscal_number` | char(11) | ✅ | Customer CPF — 11 digits, unique in the system |
| `created_at` | timestamptz | ✅ | Record creation timestamp |
| `updated_at` | timestamptz | ✅ | Last update timestamp |

---

#### `addresses`
User addresses. A user can have multiple; `is_primary` identifies the main one.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `user_id` | uuid | ✅ | FK → `users.id` |
| `street` | varchar(200) | ✅ | Street |
| `number` | varchar(10) | ✅ | Number |
| `complement` | varchar(100) | ❌ | Complement |
| `neighborhood` | varchar(100) | ❌ | Neighborhood |
| `city` | varchar(100) | ✅ | City |
| `state` | char(2) | ✅ | State (UF) — two characters |
| `zip_code` | char(8) | ✅ | ZIP code — exactly 8 digits, no hyphen |
| `latitude` | decimal(10,7) | ❌ | Latitude geocoded at registration via maps API |
| `longitude` | decimal(10,7) | ❌ | Longitude geocoded at registration via maps API |
| `is_primary` | boolean | ✅ | `true` = user's primary address |
| `geocode_status` | varchar(12) | ❌ | Geocoding bookkeeping: `OK` \| `AMBIGUOUS` \| `FAILED` — `null` = never attempted (added in `V23`) |
| `geocoded_at` | timestamptz | ❌ | When geocoding was last attempted (added in `V23`) |
| `created_at` | timestamptz | ✅ | Record creation timestamp |

> **Note:** `latitude` and `longitude` are filled only once when the address is created, using the Google Maps API or device GPS. From then on, all proximity queries use the database directly — avoiding additional API costs per query.

---

#### `farmer_availability`
Farmer availability hours by weekday. Displayed on the public profile.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `farmer_id` | uuid | ✅ | FK → `farmers.id` |
| `weekday` | smallint | ✅ | Day of the week: `0`=Sunday, `1`=Monday, ..., `6`=Saturday |
| `opens_at` | time | ✅ | Opening time |
| `closes_at` | time | ✅ | Closing time |
| `active` | boolean | ✅ | Allows disabling a day without removing the record |

**Unique index:** `(farmer_id, weekday)` — only one schedule per day per farmer.

---

### Products and Inventory

#### `products`

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `farmer_id` | uuid | ✅ | FK → `farmers.id` — product belongs to a farmer |
| `name` | varchar(150) | ✅ | Product name displayed in the marketplace |
| `description` | text | ❌ | Detailed product description |
| `price` | decimal(10,2) | ✅ | Current unit price in BRL |
| `unity_type` | varchar(20) | ✅ | Unit: `kg` \| `g` \| `unit` \| `box` \| `liter` \| `ml` \| `dozen` |
| `stock_quantity` | decimal(12,3) | ✅ | Current available stock — decremented when order is confirmed |
| `image_s3` | text | ❌ | Main image URL stored in S3 |
| `active` | boolean | ✅ | `false` = product hidden from marketplace (soft delete) |
| `version` | bigint | ✅ | Optimistic-lock version — guards concurrent `stock_quantity` read-modify-write on sale/cancel (added in `V22`) |
| `created_at` | timestamptz | ✅ | Record creation timestamp |
| `updated_at` | timestamptz | ✅ | Last update timestamp |

> **Note:** When a product is deactivated, the trigger `trg_product_deactivated` automatically disables all `cart_items` associated with that product and any carts that end up with no active items.

---

#### `product_categories`

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | serial | ✅ | Auto-incremented primary key |
| `name` | varchar(80) | ✅ | Unique category name — e.g., Vegetables, Fruits |
| `description` | text | ❌ | Category description |

---

#### `product_category_assignments`
Junction table (N:N) between products and categories. A product can belong to multiple categories.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `product_id` | uuid | ✅ | FK → `products.id` — part of the composite primary key |
| `category_id` | integer | ✅ | FK → `product_categories.id` — part of the composite primary key |

---

#### `product_photos`
Photo gallery per product. Display order is controlled by `display_order`.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `product_id` | uuid | ✅ | FK → `products.id` |
| `url` | text | ✅ | Photo URL stored in S3 |
| `display_order` | smallint | ✅ | Display order — lower values appear first |
| `created_at` | timestamptz | ✅ | Record creation timestamp |

---

#### `stock_movements`
Immutable log of all stock movements. Insert-only — never updated.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `product_id` | uuid | ✅ | FK → `products.id` |
| `type` | varchar(10) | ✅ | Direction: `entry` (incoming) \| `exit` (outgoing) |
| `reason` | varchar(20) | ✅ | Reason: `sale` \| `loss` \| `disposal` \| `manual_entry` |
| `quantity` | decimal(12,3) | ✅ | Quantity moved |
| `notes` | text | ❌ | Optional note from the farmer |
| `created_at` | timestamptz | ✅ | Movement timestamp |

> **Note:** Every change to `stock_quantity` in `products` must generate a record here. This enables full stock auditing and powers the movement history for Epic 5.

---

### Cart and Orders

#### `carts`
Active cart for the customer. A `UNIQUE` index on `customer_id` ensures one cart per customer.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `customer_id` | uuid | ✅ | FK → `customers.id` — UNIQUE, one cart per customer |
| `farmer_id` | uuid | ✅ | FK → `farmers.id` — enforces the rule of one farmer per cart |
| `active` | boolean | ✅ | `false` = cart emptied or deactivated by trigger |
| `created_at` | timestamptz | ✅ | Record creation timestamp |
| `updated_at` | timestamptz | ✅ | Last update timestamp |

> **Note:** The one-farmer-per-cart rule is enforced by the `farmer_id` field. When attempting to add a product from another farmer, the application should warn the user and, if confirmed, clear the current cart before creating a new one.

---

#### `cart_items`

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `cart_id` | uuid | ✅ | FK → `carts.id` |
| `product_id` | uuid | ✅ | FK → `products.id` |
| `quantity` | decimal(12,3) | ✅ | Quantity selected by the customer |
| `active` | boolean | ✅ | `false` = item removed or product deactivated |

**Unique index:** `(cart_id, product_id)` — no duplicate items in the same cart.

---

#### `orders`
Order generated from the cart. Line items and address snapshot are immutable after creation; status transitions are tracked in `order_status_history`.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `customer_id` | uuid | ✅ | FK → `customers.id` |
| `farmer_id` | uuid | ✅ | FK → `farmers.id` |
| `delivery_address_id` | uuid | ✅ | FK → `addresses.id` — current address |
| `delivery_address_snapshot` | jsonb | ✅ | Copy of the address at order time — immutable |
| `status` | varchar(20) | ✅ | `PENDING` \| `CONFIRMED` \| `IN_DELIVERY` \| `DELIVERED` \| `CANCELLED` (see `OrderStatus` enum) |
| `payment_method_id` | uuid | ✅ | FK → `payment_methods.id` |
| `payment_status` | varchar(20) | ✅ | `pending` \| `paid` \| `refunded` |
| `scheduled_for` | timestamptz | ❌ | Scheduled delivery date and time |
| `delivered_at` | timestamptz | ❌ | Actual delivery date and time |
| `notes` | text | ❌ | Customer notes |
| `cancellation_reason` | text | ❌ | Reason/category for the cancellation (e.g. `CUSTOMER_GIVE_UP`, `REFUSED_BY_FARMER`, free text) — filled when cancelled |
| `cancellation_details` | text | ❌ | Longer justification optionally provided by whoever cancelled (added in `V12`) |
| `seen_by_farmer` | boolean | ✅ | `false` until the farmer opens the order — drives new-order badges (added in `V17`) |
| `confirmation_code` | varchar(4) | ❌ | 4-digit delivery confirmation code, generated when the order moves to `IN_DELIVERY` (added in `V19`) |
| `confirmation_attempts` | integer | ✅ | Wrong-code attempt counter — brute-force protection (added in `V19`) |
| `confirmation_locked_until` | timestamptz | ❌ | Lockout timestamp after too many wrong attempts (added in `V19`) |
| `created_at` | timestamptz | ✅ | Record creation timestamp |
| `updated_at` | timestamptz | ✅ | Last update timestamp |

> **Note:** `delivery_address_snapshot` exists because the customer may change their address after placing the order. The snapshot ensures the history reflects where the delivery was actually intended.

---

#### `order_items`
Order items with snapshots of product data at the time of purchase.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `order_id` | uuid | ✅ | FK → `orders.id` |
| `product_id` | uuid | ✅ | FK → `products.id` — current reference |
| `product_name_snapshot` | varchar(150) | ✅ | Product name at the time of purchase |
| `unit_price_snapshot` | decimal(10,2) | ✅ | Unit price at the time of purchase |
| `unity_type_snapshot` | varchar(20) | ✅ | Unit of measure at the time of purchase |
| `quantity` | decimal(12,3) | ✅ | Quantity purchased |
| `subtotal` | decimal(12,2) | ✅ | `quantity × unit_price_snapshot` |

> **Note:** The three snapshot fields ensure that order history remains accurate even if the farmer later changes the product name, price, or unit.

---

#### `order_status_history`
Immutable log of all order status transitions. Insert-only.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `order_id` | uuid | ✅ | FK → `orders.id` |
| `status` | varchar(20) | ✅ | Status recorded in this transition |
| `changed_at` | timestamptz | ✅ | Timestamp of the status change |

---

### Reviews and Favorites

#### `review`
One review per order — enforced by a `UNIQUE` constraint on `order_id`. Can only be created for orders with status `delivered`.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `order_id` | uuid | ✅ | FK → `orders.id` — UNIQUE, one review per order |
| `farmer_id` | uuid | ✅ | FK → `farmers.id` — reviewed farmer |
| `customer_id` | uuid | ✅ | FK → `customers.id` — review author |
| `rating` | smallint | ✅ | Rating from 1 to 5 |
| `comment` | text | ❌ | Optional comment |
| `created_at` | timestamptz | ✅ | Review timestamp |

> **Note:** After each insert into `review`, the application must recalculate `average_rating` and increment `total_reviews` in `farmers` to keep the denormalized fields consistent.

---

#### `favorites`
Junction table between customers and their favorite farmers. Composite primary key prevents duplicates.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `customer_id` | uuid | ✅ | FK → `customers.id` — part of the composite primary key |
| `farmer_id` | uuid | ✅ | FK → `farmers.id` — part of the composite primary key |
| `created_at` | timestamptz | ✅ | Timestamp when the farmer was favorited |

---

### Logistics

> Redesigned in `V23__delivery_routes_v2` (the original V1 logistics tables were never mapped by an entity and were dropped). Real-time GPS tracking (`route_positions`) was added in `V24`.

#### `delivery_routes`
A delivery trip by the producer, built from the optimized order via the Google Routes API. At most one `ACTIVE` route per producer (a new `POST /routes` replaces the previous one).

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `farmer_id` | uuid | ✅ | FK → `farmers.id` |
| `status` | varchar(20) | ✅ | `ACTIVE` \| `COMPLETED` \| `CANCELLED` |
| `origin_latitude` | decimal(10,7) | ✅ | Route origin latitude (producer's location) |
| `origin_longitude` | decimal(10,7) | ✅ | Route origin longitude (producer's location) |
| `total_distance_km` | decimal(10,2) | ❌ | Total optimized road distance in km |
| `total_duration_seconds` | integer | ❌ | Total estimated duration in seconds |
| `baseline_distance_km` | decimal(10,2) | ❌ | Round-trip-per-stop baseline (Route Matrix) used as the CO2-savings baseline |
| `overview_polyline` | text | ❌ | Encoded polyline used to render the route on the map |
| `created_at` | timestamptz | ✅ | Record creation timestamp |
| `completed_at` | timestamptz | ❌ | When the route was completed |

**Unique index:** `(farmer_id) WHERE status = 'ACTIVE'` — at most one active route per producer.

---

#### `route_stops`
Each stop in the route. An order can appear at most once per route — enforced by `UNIQUE` on `(route_id, order_id)`. `ON DELETE CASCADE` from `delivery_routes`.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `route_id` | uuid | ✅ | FK → `delivery_routes.id` |
| `order_id` | uuid | ✅ | FK → `orders.id` |
| `sequence` | integer | ✅ | Visit sequence in the route — defined by route optimization |
| `status` | varchar(20) | ✅ | `PENDING` \| `ARRIVED` \| `DELIVERED` \| `FAILED` |
| `latitude` | decimal(10,7) | ✅ | Stop latitude |
| `longitude` | decimal(10,7) | ✅ | Stop longitude |
| `address_text` | text | ❌ | Human-readable address of the stop |
| `leg_distance_km` | decimal(10,2) | ❌ | Distance of the leg from the previous point to this stop |
| `leg_duration_seconds` | integer | ❌ | Duration of the leg from the previous point to this stop |
| `eta` | timestamptz | ❌ | Absolute ETA at this stop (`created_at` + sum of legs up to here) |
| `completed_at` | timestamptz | ❌ | When the stop was completed |

**Unique indexes:**
- `(route_id, sequence)` — no duplicate stop numbers within the same route
- `(route_id, order_id)` — an order appears at most once per route

---

#### `route_positions`
Real-time GPS trail recorded while the producer runs the route (used by the live tracking WebSocket). `ON DELETE CASCADE` from `delivery_routes`. Retained 7 days, then purged by a daily job.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `route_id` | uuid | ✅ | FK → `delivery_routes.id` |
| `latitude` | decimal(10,7) | ✅ | Recorded latitude |
| `longitude` | decimal(10,7) | ✅ | Recorded longitude |
| `accuracy_meters` | decimal(8,2) | ❌ | Reported GPS accuracy in meters |
| `speed_kmh` | decimal(6,2) | ❌ | Reported speed in km/h |
| `recorded_at` | timestamptz | ✅ | When the position was recorded |

---

### Sustainability / CO2

> Powers the `/co2` impact feature. Added in `V13` (`vehicle_preferences`, `co2_savings`) and `V14` (`co2_emissions`).

#### `vehicle_preferences`
The producer's vehicle/fuel profile used to compute emissions. Keyed by `user_id` (1:1 with `users`).

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `user_id` | uuid | ✅ | PK / FK → `users.id` |
| `vehicle_type` | varchar(50) | ✅ | Vehicle type |
| `fuel_type` | varchar(50) | ✅ | Fuel type |
| `average_consumption` | double precision | ✅ | Average consumption used in the emission formula |
| `created_at` | timestamptz | ❌ | Record creation timestamp |
| `updated_at` | timestamptz | ❌ | Last update timestamp |

---

#### `co2_savings`
A computed CO2-savings record: optimized vs. non-optimized distance for a delivery run.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `user_id` | uuid | ✅ | FK → `users.id` |
| `distance_optimized` | double precision | ✅ | Distance with route optimization |
| `distance_non_optimized` | double precision | ✅ | Baseline distance without optimization |
| `co2_saved` | double precision | ✅ | Computed CO2 saved |
| `vehicle_type` | varchar(50) | ✅ | Vehicle type at computation time |
| `fuel_type` | varchar(50) | ✅ | Fuel type at computation time |
| `average_consumption` | double precision | ✅ | Average consumption at computation time |
| `created_at` | timestamptz | ❌ | Record creation timestamp |

---

#### `co2_emissions`
A computed emission record for a route distance, tied to a vehicle profile.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `vehicle_preference_user_id` | uuid | ✅ | FK → `vehicle_preferences.user_id` |
| `route_distance_km` | double precision | ✅ | Route distance used in the computation |
| `co2_emission` | double precision | ✅ | Computed CO2 emission |
| `vehicle_type` | varchar(50) | ✅ | Vehicle type at computation time |
| `fuel_type` | varchar(50) | ✅ | Fuel type at computation time |
| `average_consumption` | double precision | ✅ | Average consumption at computation time |
| `created_at` | timestamptz | ❌ | Record creation timestamp |

---

### Notifications

> Backs the in-app notification feed and FCM push. Added in `V16` (`notifications`) and `V20` (`fcm_tokens`).

#### `notifications`
In-app notification feed entry for a user.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `user_id` | uuid | ✅ | FK → `users.id` — recipient |
| `title` | varchar(120) | ✅ | Notification title |
| `message` | text | ✅ | Notification body |
| `type` | varchar(40) | ✅ | Notification category/type |
| `reference_type` | varchar(40) | ❌ | Type of the referenced entity (e.g. order) for deep-linking |
| `reference_id` | uuid | ❌ | Id of the referenced entity |
| `metadata` | jsonb | ❌ | Extra payload for the client |
| `is_read` | boolean | ✅ | `false` until the user reads it |
| `created_at` | timestamptz | ✅ | Record creation timestamp |
| `read_at` | timestamptz | ❌ | When the notification was read |

---

#### `fcm_tokens`
Firebase Cloud Messaging device tokens per user, for push delivery.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `user_id` | uuid | ✅ | FK → `users.id` |
| `token` | text | ✅ | FCM device token — `UNIQUE` |
| `updated_at` | timestamptz | ✅ | Last time the token was registered/refreshed |

---

### Payment

#### `payment_methods`
Payment methods registered by the farmer. Supports PIX and bank accounts.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `id` | uuid | ✅ | Primary key |
| `farmer_id` | uuid | ✅ | FK → `farmers.id` |
| `type` | varchar(20) | ✅ | Type: `pix` \| `bank_account` |
| `pix_key_type` | varchar(20) | ❌ | PIX key type: `cpf` \| `cnpj` \| `email` \| `phone` \| `random` |
| `pix_key` | varchar(100) | ❌ | PIX key — filled only if `type = pix` |
| `bank_code` | char(3) | ❌ | Bank COMPE code — 3 digits |
| `bank_name` | varchar(100) | ❌ | Bank name |
| `agency` | varchar(10) | ❌ | Branch number |
| `account_number` | varchar(20) | ❌ | Account number |
| `account_type` | varchar(20) | ❌ | Type: `checking` \| `savings` |
| `holder_name` | varchar(120) | ❌ | Account holder name |
| `fiscal_number` | varchar(14) | ❌ | Holder CPF or CNPJ |
| `active` | boolean | ✅ | `false` = method disabled |
| `created_at` | timestamptz | ✅ | Record creation timestamp |
| `updated_at` | timestamptz | ✅ | Last update timestamp |

**Unique index:** `(farmer_id, type, pix_key)` — prevents duplicate registration of the same payment method for the same farmer.

---

## Triggers

### `trg_product_deactivated`
Triggered after an `UPDATE` on the `active` field of `products` when the value changes from `true` to `false`.

**Cascade effect:**
1. Deactivates all `cart_items` where `product_id = deactivated product`
2. Checks each affected cart — if no active items remain, the cart is also deactivated

**Why it exists:** If a farmer deactivates a product that is in a customer’s cart, the item cannot remain there — the customer would attempt to purchase something unavailable. This trigger automatically resolves the issue at the database level, regardless of which part of the system performed the deactivation.

```sql
AFTER UPDATE OF active ON products
FOR EACH ROW
WHEN (OLD.active = true AND NEW.active = false)
-- deactivates cart_items and carts left with no active items
```

---

### `trg_farmer_deactivated`
Triggered after an UPDATE on users when type = 'farmer' and active changes to false.

**Cascade Effect:**
1. Deactivates all cart_items from all carts related to that farmer
2. Deactivates all carts where farmer_id = deactivated farmer

**Why it exists:** When an administrator deactivates a farmer, all customers with carts from that farmer must be affected and their carts cleared. The trigger guarantees this behavior automatically, regardless of which part of the system performed the deactivation.

```sql
AFTER UPDATE OF active ON users
FOR EACH ROW
WHEN (OLD.type = 'farmer' AND OLD.active = true AND NEW.active = false)
-- deactivates all carts and items related to the farmer
```