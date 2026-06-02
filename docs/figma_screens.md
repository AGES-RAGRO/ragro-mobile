# RAGRO — Figma Screens Map

Figma File: [RAGRO](https://www.figma.com/design/8mGABAdTXf6ORLyiHx7rub/RAGRO)

Last updated: 2026-03-26

---

## File Structure

| Page | Purpose |
|------|---------|
| Cover | Project covers |
| User Flow | Navigation flows + reusable components + icons |
| Styleguide | Design tokens (colors and typography) |
| Moodboard e Benchmarking | Visual references |
| Brainstorm | AI references, screen drafts |
| Wireframes | All final screens organized by role |

---

## Design Tokens

### Colors (8 variables)

| Token | Hex | Usage |
|-------|-----|-------|
| Black | `#1E1E1E` | Text, icons |
| Cream | `#FFF5E6` | Backgrounds, cards |
| DarkGreen | `#1A432C` | Primary dark, headers |
| LightGreen | `#008148` | Primary, buttons, accents |
| MintGreen | `#87EFAC` | Success states, highlights |
| Red | `#A63446` | Error, destructive actions |
| White | `#FFFFFF` | Backgrounds, text on dark |
| Yellow | `#FFF275` | Warnings, badges |

### Typography (Font: Figtree)

| Style | Weight | Size | Usage |
|-------|--------|------|-------|
| Large Title | Bold | 34px | Section headers |
| Title 1 | SemiBold | 28px | Subsection headers, card titles |
| Title 2 | SemiBold | 22px | Descriptions, general content |
| Body | Regular | 17px | Main content |
| Footnote | Regular | 13px | Meta text, interface info |
| Caption | SemiBold | 12px | Tags, small labels |

---

## User Flows

### Customer

```
Onboarding -> Login/Register
  |
  +-- Home
  |     +-- Producers -> Producer Details
  |     +-- Product -> Product Details -> Add to Cart
  |
  +-- Orders
  |     +-- History
  |     +-- In-Progress Orders
  |
  +-- Profile
  |     +-- Address
  |
  +-- Search
  |     +-- Product Filter
  |     +-- Producer Filter
  |     +-- Search Result
  |
  +-- Cart
        +-- Checkout
        +-- Schedule Order
        +-- Remove from Cart
```

### Producer

```
Onboarding -> Login/Register
  |
  +-- Home
  |     +-- Dashboard
  |     +-- Orders
  |
  +-- Stock
  |     +-- Register Product
  |     +-- Product List
  |
  +-- Profile
        +-- Address
```

---

## Wireframes — Customer

| # | Screen | Figma Node ID | User Story | Status |
|---|--------|---------------|------------|--------|
| C01 | Login Screen | `392:1277` | US-02 | Ready |
| C02 | Producer Registration | `392:1312` | US-01 | Ready |
| C03 | Home Screen | `528:1288` | — | Ready |
| C04 | Home Screen with favorites | `528:1384` | — | Ready |
| C05 | Profile Screen | `528:1566` | US-03 | Ready |
| C06 | Edit Profile Screen | `619:2878` | US-04 | Ready |
| C07 | Search and Filters | `528:1665` | US-19 | Ready |
| C08 | Search Results (variant 1) | `621:907` | US-19 | Ready |
| C09 | Search Results (variant 2) | `621:1065` | US-19 | Ready |
| C10 | Search Results (variant 3) | `621:1413` | US-19 | Ready |
| C11 | Search Results (variant 4) | `621:1571` | US-19 | Ready |
| C12 | Producer Profile | `584:1195` | US-14 | Ready |
| C13 | Products Section | `584:1268` | US-14 | Ready |
| C14 | Product Detail Screen | `619:2947` | US-15 | Ready |
| C15 | Shopping Cart | `528:1910` | US-20 | Ready |
| C16 | Order Confirmation - Bank Details | `621:1841` | US-22 | Ready |
| C17 | Order Details | `542:1037` | US-24 | Ready |
| C18 | Pending Orders Screen | `619:2150` | US-24 | Ready |
| C19 | Accepted Orders Screen | `619:1985` | US-24 | Ready |
| C20 | Delivered Orders Screen | `619:2315` | US-24 | Ready |
| C21 | Cancelled Orders Screen | `619:2480` | US-24 | Ready |
| C22 | Rate Producer | `817:1018` | US-30 | Ready |

---

## Wireframes — Producer

| # | Screen | Figma Node ID | User Story | Status |
|---|--------|---------------|------------|--------|
| P01 | Login Screen | `621:3931` | US-08 | Ready |
| P02 | Producer Registration | `621:3965` | US-05 | Ready |
| P03 | Producer Profile (Management) | `621:3717` | US-06 + EPIC 10 | Ready |
| P04 | Edit Producer Profile | `621:3806` | US-07 | Ready |
| P05 | Producer Profile Settings | `621:3896` | US-07 | Ready |
| P06 | Received Orders - Pending | `621:2701` | US-25 | Ready |
| P07 | Received Orders - Accepted (v1) | `621:2786` | US-25 | Ready |
| P08 | Received Orders - Accepted (v2) | `621:2862` | US-25 | Ready |
| P09 | Received Orders - Accepted (v3) | `679:1659` | US-25 | Ready |
| P10 | Order Details - Pending | `621:3134` | US-26 | Ready |
| P11 | Order Details - Accepted | `621:3216` | US-26 | Ready |
| P12 | Order Details - Delivered | `621:3067` | US-26 | Ready |
| P13 | Order Details - On the way | `685:1677` | US-26 + EPIC 9 | Ready |
| P14 | Stock Screen | `621:3311` | US-16 | Ready |
| P15 | Register New Product | `621:3674` | US-13 | Ready |
| P16 | Edit Product | `621:3578` | US-15 | Ready |
| P17 | Route Calculation | `711:1221` | US-31 | Ready |

---

## Wireframes — Administrator

| # | Screen | Figma Node ID | User Story | Status |
|---|--------|---------------|------------|--------|
| A01 | Login Screen | `687:1327` | US-08 | Ready |
| A02 | Producer List | `758:988` | US-09 | Ready |
| A03 | Producer Registration | `790:965` | US-05 | Ready |

---

## Reusable Components

### Design System Components (User Flow page — section `Componentes`)

| Component | Type | Figma Node ID | Usage |
|-----------|------|---------------|-------|
| Navigation Bar | ComponentSet (variants) | `176:902` | Bottom nav by role (Customer 4 tabs, Producer 3 tabs) |
| Producer Card | Component | `176:2625` | Producer card on home and search |
| Product Card 6 | ComponentSet (variants) | `182:419` | Product card by category |
| Text Field | Component | `379:1023` | Form input |
| Background (8 variants) | Components | `484:777` — `484:784` | Backgrounds by category |

### Standalone Components (Wireframes page)

| Component | Figma Node ID | Usage |
|-----------|---------------|-------|
| Reject order | `727:1045` | Confirmation dialog |
| Order placed | `727:1056` | Status card |
| Order Confirmed | `727:1061` | Status card |
| Delivery confirmed | `727:1066` | Status card |
| Delivery started | `727:1071` | Status card |
| Clear Cart button | `726:1048` | Action dialog |
| Remove cart item | `726:1059` | Action dialog |
| Confirm Order | `726:1070` | Action dialog |
| Customer Login Confirmation | `726:1081` | Success dialog |
| Rate Producer | `817:1018` | Rating modal |

### Icons

| Icon | Figma Node ID | Variants |
|------|---------------|----------|
| home | `176:546`, `176:1104` | Light, dark |
| search | `176:543` | — |
| local_mall | `176:549`, `176:1108` | Light, dark |
| person | `176:552`, `176:1100` | Light, dark |
| verified | `176:2632`, `176:2647` | Light, dark |

---

## Notes

- Frames named `Android Compact - X` were renamed by the team to descriptive names
- Customer login and Producer login share the same layout — reusable component opportunity
- Order Details (Producer) uses 4 status states with distinct action buttons per state
- Edit Product and Register New Product share the same layout — single widget with mode parameter
- Producer Profile (Management) combines profile + dashboard + schedule — may split into sub-widgets
- Missing: Order Details - Cancelled (Producer side) — confirm if intentional
