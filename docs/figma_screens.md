# RAGRO — Figma Screens Map

Figma File: [RAGRO](https://www.figma.com/design/8mGABAdTXf6ORLyiHx7rub/RAGRO)
File Key: `8mGABAdTXf6ORLyiHx7rub`

Last updated: 2026-03-26

---

## File Structure

| Page | Purpose |
|------|---------|
| Cover | Capas do projeto |
| User Flow | Fluxos de navegacao + componentes reutilizaveis + icones |
| Styleguide | Design tokens (cores e tipografia) |
| Moodboard e Benchmarking | Referencias visuais |
| Brainstorm | Referencias de IA, rascunhos de telas |
| Wireframes | Todas as telas finais organizadas por role |

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

### Comprador

```
Onboarding -> Login/Cadastro
  |
  +-- Home
  |     +-- Produtores -> Detalhes do Produtor
  |     +-- Produto -> Detalhes do Produto -> Adicionar ao Carrinho
  |
  +-- Pedidos
  |     +-- Historico
  |     +-- Pedidos em Andamento
  |
  +-- Perfil
  |     +-- Endereco
  |
  +-- Pesquisa
  |     +-- Filtro de Produto
  |     +-- Filtro de Produtor
  |     +-- Resultado da Pesquisa
  |
  +-- Carrinho
        +-- Checkout
        +-- Agendar Pedido
        +-- Remover do Carrinho
```

### Produtor

```
Onboarding -> Login/Cadastro
  |
  +-- Home
  |     +-- Dashboard
  |     +-- Pedidos
  |
  +-- Estoque
  |     +-- Cadastrar Produto
  |     +-- Lista de Produtos
  |
  +-- Perfil
        +-- Endereco
```

---

## Wireframes — Comprador

| # | Screen | Figma Node ID | User Story | Status |
|---|--------|---------------|------------|--------|
| C01 | Tela de Login | `392:1277` | US-02 | Ready |
| C02 | Cadastro de Produtor | `392:1312` | US-01 | Ready |
| C03 | Tela de Inicio | `528:1288` | — | Ready |
| C04 | Tela de Inicio com favoritos | `528:1384` | — | Ready |
| C05 | Tela de Perfil | `528:1566` | US-03 | Ready |
| C06 | Tela de Editar Perfil | `619:2878` | US-04 | Ready |
| C07 | Busca e Filtros | `528:1665` | US-19 | Ready |
| C08 | Resultados da Busca (variacao 1) | `621:907` | US-19 | Ready |
| C09 | Resultados da Busca (variacao 2) | `621:1065` | US-19 | Ready |
| C10 | Resultados da Busca (variacao 3) | `621:1413` | US-19 | Ready |
| C11 | Resultados da Busca (variacao 4) | `621:1571` | US-19 | Ready |
| C12 | Perfil do Produtor | `584:1195` | US-14 | Ready |
| C13 | Products Section | `584:1268` | US-14 | Ready |
| C14 | Tela de Detalhe do Produto | `619:2947` | US-15 | Ready |
| C15 | Carrinho de Compras | `528:1910` | US-20 | Ready |
| C16 | Confirmacao de Pedido - Dados Bancarios | `621:1841` | US-22 | Ready |
| C17 | Detalhes do Pedido | `542:1037` | US-24 | Ready |
| C18 | Tela de Pedidos Pendentes | `619:2150` | US-24 | Ready |
| C19 | Tela de Pedidos Aceitos | `619:1985` | US-24 | Ready |
| C20 | Tela de Pedidos Entregues | `619:2315` | US-24 | Ready |
| C21 | Tela de Pedidos Cancelados | `619:2480` | US-24 | Ready |
| C22 | Avaliar Produtor | `817:1018` | US-30 | Ready |

---

## Wireframes — Produtor

| # | Screen | Figma Node ID | User Story | Status |
|---|--------|---------------|------------|--------|
| P01 | Tela de Login | `621:3931` | US-08 | Ready |
| P02 | Cadastro de Produtor | `621:3965` | US-05 | Ready |
| P03 | Perfil do Produtor (Gestao) | `621:3717` | US-06 + EPIC 10 | Ready |
| P04 | Editar Perfil do Produtor | `621:3806` | US-07 | Ready |
| P05 | Configuracoes Perfil do Produtor | `621:3896` | US-07 | Ready |
| P06 | Pedidos Recebidos - Pendentes | `621:2701` | US-25 | Ready |
| P07 | Pedidos Recebidos - Aceitos (v1) | `621:2786` | US-25 | Ready |
| P08 | Pedidos Recebidos - Aceitos (v2) | `621:2862` | US-25 | Ready |
| P09 | Pedidos Recebidos - Aceitos (v3) | `679:1659` | US-25 | Ready |
| P10 | Detalhes do Pedido - Pendente | `621:3134` | US-26 | Ready |
| P11 | Detalhes do Pedido - Aceito | `621:3216` | US-26 | Ready |
| P12 | Detalhes do Pedido - Entregue | `621:3067` | US-26 | Ready |
| P13 | Detalhes do Pedido - A caminho | `685:1677` | US-26 + EPIC 9 | Ready |
| P14 | Tela de Estoque | `621:3311` | US-16 | Ready |
| P15 | Cadastrar Novo Produto | `621:3674` | US-13 | Ready |
| P16 | Editar Produto | `621:3578` | US-15 | Ready |
| P17 | Calculo de rota | `711:1221` | US-31 | Ready |

---

## Wireframes — Administrador

| # | Screen | Figma Node ID | User Story | Status |
|---|--------|---------------|------------|--------|
| A01 | Tela de Login | `687:1327` | US-08 | Ready |
| A02 | Lista de Produtores | `758:988` | US-09 | Ready |
| A03 | Cadastro de Produtor | `790:965` | US-05 | Ready |

---

## Reusable Components

### Design System Components (User Flow page — section `Componentes`)

| Component | Type | Figma Node ID | Usage |
|-----------|------|---------------|-------|
| Navigation Bar | ComponentSet (variants) | `176:902` | Bottom nav por role (Comprador 4 tabs, Produtor 3 tabs) |
| Producer Card | Component | `176:2625` | Card de produtor na home e busca |
| Product Card 6 | ComponentSet (variants) | `182:419` | Card de produto por categoria |
| Text Field | Component | `379:1023` | Input de formulario |
| Background (8 variants) | Components | `484:777` — `484:784` | Backgrounds por categoria |

### Standalone Components (Wireframes page)

| Component | Figma Node ID | Usage |
|-----------|---------------|-------|
| Recusar pedido | `727:1045` | Dialog de confirmacao |
| Pedido realizado | `727:1056` | Status card |
| Pedido Confirmado | `727:1061` | Status card |
| Entrega confirmada | `727:1066` | Status card |
| Entrega iniciada | `727:1071` | Status card |
| Botao Limpar Carrinho | `726:1048` | Action dialog |
| Remover item carrinho | `726:1059` | Action dialog |
| Confirmar Pedido | `726:1070` | Action dialog |
| Confirmacao Login Comprador | `726:1081` | Success dialog |
| Avaliar Produtor | `817:1018` | Rating modal |

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
- Comprador login and Produtor login share the same layout — reusable component opportunity
- Detalhes do Pedido (Produtor) uses 4 status states with distinct action buttons per state
- Editar Produto and Cadastrar Novo Produto share the same layout — single widget with mode parameter
- Perfil do Produtor (Gestao) combines profile + dashboard + schedule — may split into sub-widgets
- Missing: Detalhes do Pedido - Cancelado (Produtor side) — confirm if intentional
