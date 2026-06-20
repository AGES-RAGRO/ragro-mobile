# PITCH RAGRO — Documento de Referência
> Duração: 10 minutos | Demo ao vivo obrigatória | Avaliação técnica e de relevância

---

## IDENTIDADE VISUAL

### Paleta de Cores

| Token | Hex | Uso |
|---|---|---|
| **Dark Green** (Primária) | `#1A432C` | Marca, botões, navegação ativa |
| **Light Green** (Secundária) | `#008148` | Estados interativos, bordas focadas |
| **Mint Green** (Accent) | `#87EFAC` | Destaques, chips, indicadores |
| **Cream** (Background) | `#FFF5E6` | Fundo padrão dos scaffolds |
| **Yellow** | `#FFB413` | Avaliações, alertas positivos |
| **Orange** | `#F67C3B` | Impacto, destaques secundários |
| **Red** | `#A63446` | Erros, cancelamentos |
| **Black** | `#1E1E1E` | Tipografia principal |
| **White** | `#FFFFFF` | Superfícies, cards |

### Tipografia

**Fonte:** Figtree (Google Fonts)

| Estilo | Tamanho | Peso |
|---|---|---|
| Large Title | 34px | Bold 700 |
| Title 1 | 28px | SemiBold 600 |
| Title 2 | 22px | SemiBold 600 |
| Body | 17px | Regular 400 |
| Highlight | 16px | Bold 700 |
| Caption | 12px | SemiBold 600 |

### Tom Visual

- Verde escuro agrícola como âncora de identidade
- Cream como fundo — sensação natural, artesanal, confiável
- Componentes com border radius generoso (24px) — app moderno, não institucional
- Material Design 3 com personalização consistente

---

## ESTRUTURA DA APRESENTAÇÃO — 10 MINUTOS

---

### SLIDE 1 — Abertura + Problema `[0:00–1:00]`

**Título:** O campo alimenta o Brasil. Mas quem alimenta o produtor?

**Conteúdo:**
- 77% dos alimentos consumidos no Brasil vêm de pequenos produtores (IBGE)
- Produtor rural tem dificuldade de vender com previsibilidade
- Sem ferramentas para organizar pedidos, controlar estoque e manter relacionamento com clientes
- Dependência de intermediários que capturam margem sem agregar valor

**Frase de fechamento:**
> "O Ragro não é só marketplace. É uma plataforma operacional para a agricultura local."

**Sugestão visual:** Foto real de produtor + mapa do Brasil com densidade agrícola

---

### SLIDE 2 — Proposta de Valor `[1:00–2:00]`

**Título:** Três problemas. Uma plataforma.

| Quem | O que o Ragro resolve |
|---|---|
| **Consumidor** | Descoberta, busca e compra de produtos locais com rastreabilidade |
| **Produtor** | Gestão real: pedidos, estoque, dashboard, perfil e reputação |
| **Plataforma** | Confiança via autenticação, avaliações, notificações e dados |

**Visual sugerido:** Diagrama simples com dois lados (consumidor ↔ produtor) e a plataforma como ponte

---

### SLIDE 3 — Demo ao Vivo `[2:00–6:30]`

**[SEM SLIDE — DEMO NO CELULAR/EMULADOR]**

**Roteiro sugerido (4:30 min):**

#### Bloco A — Lado Consumidor (2:30 min)
1. **Login** (`/login`) — rápido, mostrar autenticação com Keycloak
2. **Home** (`/customer/home`) — feed de produtores, busca por produto
3. **Detalhe do produto** (`/customer/home/product/:id`) — foto, preço por unidade, produtor
4. **Carrinho e pedido** (`/customer/cart` → `/customer/checkout`) — criação de pedido completo
5. **Acompanhamento de pedido** (`/customer/orders/:orderId`) — status em tempo real
6. **Bônus se estável:** mostrar tela de favoritos ou mapa (`/customer/map`)

#### Bloco B — Lado Produtor (2:00 min)
7. **Trocar para conta produtor** — login como farmer
8. **Dashboard de pedidos** (`/producer/home`) — pedidos recebidos, status
9. **Estoque** (`/producer/stock`) — listar produtos, mostrar histórico de movimentações
10. **Perfil do produtor** (`/producer/profile`) — avaliações recebidas, métricas

**Frase de transição:**
> "Isso está funcionando ponta a ponta, com dados reais."

---

### SLIDE 4 — Arquitetura Frontend `[6:30–7:30]`

**Título:** Flutter com Clean Architecture — estrutura que escala

**Diagrama de camadas:**
```
lib/
├── core/          → DI, Router, Theme, Network, Validators
├── features/      → 16 módulos independentes
│   └── [feature]/
│       ├── data/         → Repositórios, DataSources, Models
│       ├── domain/       → Entidades, UseCases, Interfaces
│       └── presentation/ → Pages, Widgets, BLoCs
└── shared/        → Componentes reutilizáveis
```

**Destaques técnicos:**
- **BLoC** para gerenciamento de estado — eventos/estados tipados com Equatable
- **GoRouter 17** com stateful shell routes — navegação por role sem reescrever o app
- **GetIt + Injectable** — injeção de dependência automática com `build_runner`
- **Dio 5.9** para HTTP com interceptors de autenticação JWT
- **very_good_analysis** — lint rigoroso (padrão Very Good Ventures)
- **3 perfis de navegação distintos:** Customer (5 tabs), Producer (3 tabs), Admin
- **Google Maps Flutter** + geolocator + geocoding para funcionalidade de mapa
- **flutter_secure_storage** para armazenamento seguro de tokens JWT

---

### SLIDE 5 — Arquitetura Backend `[7:30–8:00]`

**Título:** Spring Boot 3.3 + Java 21 — backend de produção

**Fluxo de requisição (documentado em `docs/architecture/01-overview.md`):**
```
App Mobile
    │  HTTP Request + Bearer JWT
    ▼
SecurityConfig (Spring Security Filter Chain)
    │  Valida assinatura JWT via Keycloak JWKS endpoint
    │  Extrai claim "groups" → ROLE_ADMIN / ROLE_FARMER / ROLE_CUSTOMER
    ▼
Controller — @Valid @RequestBody + @AuthenticationPrincipal Jwt
    │  Nunca expõe entidades JPA — apenas DTOs (Request/Response)
    ▼
Service — Business logic + @Transactional
    │  Lança exceções tipadas: BusinessException, NotFoundException, UnauthorizedException
    ▼
Repository — Spring Data JPA
    │  Interfaces com query methods + @Query para consultas complexas
    ▼
PostgreSQL 16
```

**Regras de dependência entre camadas (zero exceção):**

| Camada | Pode importar | Proibido |
|---|---|---|
| `controller` | `service/`, DTOs | `repository/`, entidades diretamente |
| `service` | `repository/`, `domain/`, `mapper/` | `controller/`, classes HTTP |
| `repository` | `domain/` | `service/`, `controller/` |
| `domain` | `domain.enums/` | qualquer outro pacote do projeto |

**Números do backend:**
| Métrica | Valor |
|---|---|
| Arquivos Java | ~206 |
| Controllers | 82 |
| Services | 26 |
| Repositories | 23 |
| Entities / Enums | 40 |
| Mappers | 11 |
| Tabelas no banco | 26 |
| Migrações Flyway | 19 |
| Arquivos de teste | 40 |

---

### SLIDE 6 — Segurança e Autenticação `[8:00–8:30]`

**Título:** Keycloak 26 — autenticação enterprise no projeto acadêmico

**Fluxo de autenticação (documentado em `docs/architecture/04-security.md`):**
```
Mobile App          Keycloak              Backend
    │                   │                    │
    │─── credentials ──▶│                    │
    │◀── JWT token ─────│                    │
    │                   │                    │
    │─────────── Bearer JWT ────────────────▶│
    │                   │    valida via JWKS  │
    │                   │◀── publicKey ───────│
    │◀─────────── Response ─────────────────-│
```

**Configuração do realm `ragro`:**
- Groups: `ADMIN`, `FARMER`, `CUSTOMER` → mapeados automaticamente para `ROLE_X`
- Client: `ragro-app` (público, Direct Access Grants habilitado)
- JWT claims usados: `sub` (→ `auth_sub` no banco), `email`, `groups`
- Política de senha: mín. 8 chars, lowercase, uppercase, dígito

**Proteção de rotas por padrão URL:**
```
/admin/**       → ROLE_ADMIN
/producers/**   → ROLE_FARMER
/customers/**   → ROLE_CUSTOMER
demais          → qualquer JWT válido
```

**Decisão crítica de design — compensating transactions:**
Ao registrar um usuário novo:
1. Cria usuário no Keycloak via Admin REST API
2. Persiste no PostgreSQL
3. Se o banco falhar → **deleta o usuário do Keycloak** para evitar conta órfã
4. Bridge entre os dois sistemas: campo `auth_sub` na tabela `users`

**Sessão stateless:**
- Sem `HttpSession` no servidor — `SessionCreationPolicy.STATELESS`
- CSRF desabilitado (API pura, sem formulários HTML)

---

### SLIDE 7 — Banco de Dados e Infraestrutura `[8:30–9:00]`

**Título:** PostgreSQL 16 + Flyway — esquema versionado, ambiente reproduzível

**Estratégia de banco (documentada em `docs/database.md`):**
- Hibernate em modo `validate` — nunca cria nem altera tabelas automaticamente
- Toda mudança de esquema via nova migration Flyway (`V{n}__descricao.sql`)
- 19 migrations versionadas com histórico completo de evolução do produto

**Tabelas principais por domínio:**

| Domínio | Tabelas |
|---|---|
| Usuários | `users`, `customers`, `farmers`, `addresses` |
| Produtos | `products`, `product_photos`, `product_categories` |
| Estoque | `stock_movements` |
| Pedidos | `orders`, `order_items` |
| Carrinho | `carts`, `cart_items` |
| Avaliações | `reviews` |
| Favoritos | `favorite_producers` |
| Sustentabilidade | `co2_emissions`, `co2_savings`, `vehicle_preferences` |
| Notificações | `notifications`, `fcm_tokens` |
| Pagamento | `payment_methods` |

**Ambiente Docker Compose (`docker-compose.yml`):**
```
PostgreSQL 16  → porta 5432 (compartilhado: app + Keycloak DBs)
Keycloak 26    → porta 8180 (realm pré-importado via ragro-realm.json)
MinIO          → porta 9000/9001 (S3-compatible para fotos)
Mailpit        → porta 1025/8025 (SMTP local para testes)
Backend App    → porta 8080 (multi-stage Dockerfile, non-root user)
```

**Um comando sobe o ambiente completo:**
```bash
docker compose up -d
```

**Infraestrutura AWS (Terraform em `infra/`):**

| Serviço AWS | Uso |
|---|---|
| **ECS Fargate** | Execução do backend containerizado |
| **RDS PostgreSQL** | Banco de dados gerenciado |
| **ECR** | Registry de imagens Docker |
| **S3** | Armazenamento de objetos (produção) |
| **API Gateway** | Exposição e roteamento da API |
| **CloudMap** | Service discovery interno |

**Dockerfile — multi-stage build:**
```dockerfile
# Stage 1: Builder (Maven + JDK)
FROM maven:3.9-eclipse-temurin-21 AS builder
COPY . .
RUN mvn package -DskipTests

# Stage 2: Runtime (JRE mínimo)
FROM eclipse-temurin:21-jre
USER nonroot          # segurança: sem root
HEALTHCHECK ...
CMD java -Xmx75% ...  # heap capped para compatibilidade ECS
```

**CI/CD — GitHub Actions (`.github/workflows/`):**

| Workflow | Trigger | O que faz |
|---|---|---|
| `ci.yml` | PR / push | Testes + Checkstyle + SpotBugs + Docker build |
| `aws.yml` | Push main | Deploy para AWS ECS |
| `terraform.yml` | Manual | Provisiona/atualiza infraestrutura |

---

### SLIDE 8 — Qualidade Técnica `[9:00–9:15]`

**Título:** Código que resiste à revisão

**Mobile:**
- Separação estrita de camadas — `domain` nunca depende de framework Flutter
- BLoCs testáveis com `bloc_test` + `mocktail` — sem dependências de UI nos testes
- Geração de código para DI (`injectable_generator`) — zero boilerplate manual
- Linting com `very_good_analysis` (nível rigoroso) em todo o projeto

**Backend:**
- **Spotless** (Google Java Format) — formatação uniforme automaticamente verificada na CI
- **Checkstyle** (`checkstyle.xml`) — regras de estilo obrigatórias na CI
- **SpotBugs** — análise estática de bugs em tempo de build
- **JaCoCo** — relatório de cobertura de código
- DTOs em 100% dos limites da API — entidades JPA jamais serializadas para o cliente
- `GlobalExceptionHandler` (@RestControllerAdvice) — respostas de erro padronizadas em JSON
- Convenções documentadas em `docs/conventions.md`: pacotes, commits, branches, workflow obrigatório

**Convenção de commit (Conventional Commits):**
```
feat(US-XX): descrição da mudança
fix(US-XX): descrição do fix
refactor: descrição
test: descrição
```

**API documentada e testável:**
- OpenAPI 3.0 gerado automaticamente pelo Spring
- Swagger UI em `/swagger-ui/index.html` com autenticação OAuth2 integrada (Keycloak)
- Qualquer endpoint pode ser testado sem Postman

---

### SLIDE 9 — Diferenciais Competitivos `[9:15–9:45]`

**Título:** Além do CRUD — produto com visão operacional

**O que nos diferencia:**

1. **Dois lados bem resolvidos** — consumer UX e producer ops no mesmo produto coeso; não é um catálogo com login de produtor
2. **Visão operacional real** — produtor tem dashboard com métricas, histórico de estoque, avaliações recebidas e gráfico semanal
3. **IA integrada** — `RecommendationService` com re-ranker LLM via **Spring AI + NVIDIA API** para relevância personalizada por consumidor
4. **Rastreabilidade e sustentabilidade** — `Co2Service` calcula emissões e economia de CO₂ por pedido; impacto ambiental visível ao consumidor na tela de Impact
5. **Notificações push reais** — Firebase FCM integrado ao backend; `NotificationService` e tabelas `notifications`/`fcm_tokens` no banco
6. **Infraestrutura de produto, não de protótipo** — Docker Compose reproduzível, Terraform na AWS, CI/CD com 3 workflows
7. **Domínio completo** — pedidos, estoque, avaliações, favoritos, notificações, mapa, rotas de entrega, perfil público: 26 tabelas conectadas
8. **Documentação de produto** — `docs/` com arquitetura, convenções, backlog e referência de API; não foi improvisado

---

### SLIDE 10 — Fechamento `[9:45–10:00]`

**Título:** Ragro — tecnologia a serviço da agricultura local

**Mensagem final:**

> O Ragro conecta consumo local com gestão real do produtor.  
> Produto funcional. Arquitetura sólida. Capacidade de evolução demonstrada.  
> **Da horta à mesa — com rastreabilidade, confiança e tecnologia.**

**Visual sugerido:** Screenshot final com os dois lados do app lado a lado (consumer home + producer dashboard)

---

## DESCRIÇÃO DAS TELAS PRINCIPAIS
> Contexto para criação de slides e mockups no Claude Design

---

### TELA 1 — Impact (Tela inicial do consumidor)

**Rota:** `/customer/impact`

**O que aparece:**
- Logo SVG do Ragro centralizado (110×110px, folha verde)
- Frase grande: **"Juntos já poupamos"**
- Número gigante em verde escuro (fonte 96pt): ex. **"12,47"**
- Subtítulo: **"toneladas de CO₂"**
- Texto: *"Cada pedido conecta o campo, reduz emissões e transforma o futuro."*
- Botão primário verde escuro: **"Entender o impacto"**
- Botão texto: "Agora não"

**Tom visual:** Tela de impacto emocional, fundo cream, número CO₂ é o herói visual. Sensação de causa, não de app de compras.

---

### TELA 2 — Impact Detail (Detalhe do impacto ambiental)

**Rota:** `/customer/impact/detail`

**O que aparece:**
- Card branco com borda: ícone nuvem + **"XX,XX t de CO₂"** em destaque + "poupadas com a Ragro"
- Seção **"Como fazemos isso acontecer"** — 3 cards em linha:
  - Ícone localização → "Consumo local"
  - Ícone caminhão → "Rotas eficientes"
  - Ícone folha → "Menos desperdício"
- Seção **"Nosso impacto juntos"** — 3 métricas em cards:
  - Total de produtores (ex.: "142 Produtores locais")
  - Variedade de produtos orgânicos
  - Otimização de rotas
- Botão full-width verde escuro: **"Entrar no marketplace"**

**Tom visual:** Educativo + motivacional. Dados reais de CO₂ calculados pelo `Co2Service` no backend. Cada pedido contribui para a métrica global.

**Diferencial técnico:** O CO₂ é calculado automaticamente no backend (`Co2Service`) a partir do tipo de veículo do produtor (`vehicle_preferences`), distância percorrida (`Google Maps API`) e quantidade transportada. Flyway migration V13 adicionou a tabela `vehicle_preferences`, V8 adicionou `co2_emissions` e `co2_savings`.

---

### TELA 3 — Consumer Home (Feed de produtos e produtores)

**Rota:** `/customer/home`

**O que aparece:**
- Título "Início" (34pt, verde escuro) no topo
- **Seção horizontal de produtores**: cards deslizáveis com foto, nome da fazenda, ícone de favorito (coração)
- **Grid 2 colunas de produtos**: foto, nome, preço, botão de adicionar ao carrinho
- Produtos têm badges de recomendação (quando o algoritmo de IA os destaca)
- Pull-to-refresh disponível

**Tom visual:** Marketplace local. Produtos artesanais/orgânicos em grid limpo. Produtores como identidade (foto + nome da fazenda, não marca genérica).

---

### TELA 4 — Pedidos do Consumidor (Tabs por status)

**Rota:** `/customer/orders`

**O que aparece:**
- Título "Pedidos" (34pt)
- **5 abas**: Pendentes | Aceitos | A caminho | Entregues | Cancelados
- Cada card de pedido: avatar do produtor + número do pedido + data + valor total + **badge colorido de status**
  - Amarelo = Pendente, Verde = Aceito, Laranja = A caminho, Azul = Entregue, Vermelho = Cancelado
- Estado vazio: ícone de sacola + mensagem por status

---

### TELA 5 — Detalhe do Pedido (Consumidor)

**Rota:** `/customer/orders/:orderId`

**O que aparece:**
- Cabeçalho: back button + "Detalhes do Pedido" + badge de status
- **Número do pedido** (#12345)
- **Header do produtor**: avatar + nome + timestamp de criação
- Card **"ITENS DO PEDIDO"**: lista com imagem 64×64, nome, qtd + unidade, preço por item → **Total em verde escuro (18pt)**
- Card **"ENTREGA"**: ícone localização + endereço completo (rua, cidade, CEP, referência)
- Card **"PAGAMENTO"**: chave PIX + banco + agência + conta
- Card **"MOTIVO DE CANCELAMENTO"** (vermelho, se cancelado)
- **Footer fixo** com botões de ação: Confirmar Entrega / Contato WhatsApp / Cancelar Pedido

---

### TELA 6 — Perfil Público do Produtor (Visão do consumidor)

**Rota:** `/customer/home/producer/:producerId`

**O que aparece:**
- **Foto de capa** full-width (160pt altura)
- **Avatar circular** (120pt) centralizado sobre a capa, com borda branca
- Nome da fazenda (22pt, verde escuro) + nome do produtor (14pt)
- Ícone coração (favoritar/desfavoritar)
- Localização: ícone + cidade/região
- **Avaliação**: estrela + nota (ex.: "4,8") + quantidade de avaliações → clicável para reviews
- Botão full-width com ícone WhatsApp: **"Contato"**
- Texto em itálico: história/descrição do produtor
- **Grade semanal de disponibilidade**: Seg-Dom com horários de atendimento e dot verde/cinza
- **3 cards de métricas**: Qtd de produtos | Nota média | Anos na plataforma
- **Grid 2 colunas** de produtos do produtor com add-to-cart

---

### TELA 7 — Pedidos do Produtor (Dashboard de pedidos recebidos)

**Rota:** `/producer/home`

**O que aparece:**
- Título "Pedidos" (34pt) + subtítulo **"Hoje, [dia] de [mês]"**
- **5 abas com filtro**: Pendentes | Aceitos | A caminho | Entregues | Cancelados
  - Aba ativa: sublinhado 3pt verde escuro
- **Badge "N pedidos novos"** quando há pendentes
- Cada card de pedido: nome do cliente + número + data/hora + resumo dos itens + valor total + status
- **Modo seleção** (aba "Aceitos"): checkboxes aparecem nos cards
  - Footer com botões: "Cancelar" (outlined) + "Salvar (N)" (filled)
- **Botão "Calcular Melhor Rota"** (aba "A caminho"): navega para tela de otimização de rota com Google Maps

---

### TELA 8 — Estoque do Produtor (Inventário)

**Rota:** `/producer/stock`

**O que aparece:**
- Título "Estoque" (34pt) + botão **"+ Novo"** (verde) no canto direito
- **2 cards de resumo**:
  - "Itens" com ícone de inventário + total de produtos
  - "Valor Total" com ícone de dinheiro + soma formatada em R$
- **Filtros em pills**: "Todos (N)" | "Ativos (N)" | "Indisponíveis"
  - Ativo = fundo verde escuro, texto branco
- **Lista de produtos**: imagem thumbnail + nome + quantidade em estoque + unidade + indicador ativo/inativo
- **Ações por produto**: Editar | Entrada | Saída | Histórico | Excluir

---

### TELA 9 — Dashboard do Produtor (Perfil + Analytics)

**Rota:** `/producer/profile`

**O que aparece:**
- **Foto de capa** (210pt) + **avatar circular** (112pt) com ícone câmera overlay
- Nome do produtor (22pt bold) + nome da fazenda (14pt verde)
- Avaliação: estrela + nota + "(N Avaliações)" → clicável
- Botão "Editar Perfil" outlined
- **Grade semanal de horários**: 7 colunas Seg-Dom com dot verde/cinza + horários
- **Filtro de período**: botão "[Mês]/[Ano]" com dropdown → modal para selecionar até 6 anos
- **Card de Vendas Totais** (fundo verde escuro, destaque):
  - Label "VENDAS TOTAIS"
  - Valor grande (28pt bold) ex.: **"R$ 4.280,00"**
  - Ícone trending up/down
  - Badge de variação: ex.: "+12%" em fundo tintado
  - "em relação a [mês anterior]"
- **2 cards de métricas** (lado a lado):
  - "Pedidos": ícone + total + variação percentual (verde)
  - "Estoque": ícone + percentual + variação (laranja)
- **Gráfico de barras semanal** ("Visão Semanal"):
  - 7 barras (S, T, Q, Q, S, S, D)
  - Barra do dia com maior valor: verde escuro sólido
  - Demais barras: verde claro/faint
  - Cantos arredondados nas barras
  - Badge "RELATÓRIO" ao lado do título

---

## RESUMO VISUAL DAS TELAS (para slides do Claude Design)

| Tela | Papel | Elemento herói | Diferencial |
|---|---|---|---|
| Impact | Consumidor | Número CO₂ em 96pt | Cálculo real por pedido via Google Maps + tipo de veículo |
| Impact Detail | Consumidor | 3 cards "Como fazemos" + métricas | CO₂ total + produtores reais cadastrados |
| Home | Consumidor | Grid produtos + produtores | Recomendações por IA marcadas com badge |
| Pedidos (abas) | Consumidor | 5 abas com badges coloridos | Status em tempo real com rastreabilidade |
| Detalhe Pedido | Consumidor | Cards ITENS + ENTREGA + PIX | Total + endereço + pagamento em uma tela |
| Perfil Produtor | Consumidor | Capa + avatar + disponibilidade | Avaliações reais + grade de horários |
| Pedidos Produtor | Produtor | Abas + badge "N novos" | Seleção múltipla + cálculo de rota |
| Estoque | Produtor | 2 cards resumo + lista | Entrada/Saída/Histórico por produto |
| Dashboard | Produtor | Card vendas verde + gráfico barras | Métricas com variação percentual + filtro por mês |

---

## CHECKLIST PARA A DEMO

- [ ] Conta customer criada com pedidos históricos visíveis
- [ ] Conta farmer com produtos, pedidos recebidos e avaliações
- [ ] Backend rodando (Docker Compose up)
- [ ] App buildado em modo release ou profile para performance
- [ ] Wi-Fi estável ou ambiente offline garantido
- [ ] Testar fluxo completo (login → produto → pedido → acompanhamento) 1h antes
- [ ] Tela do produtor com dados reais no dashboard (não vazia)
- [ ] Notificações funcionando (opcional, mostrar se estável)

---

## FRASES-CHAVE PARA O PITCH

- *"O Ragro não é só marketplace. É uma plataforma operacional para a agricultura local."*
- *"Dois lados do mesmo problema, resolvidos no mesmo produto."*
- *"O produtor não precisa de mais um app bonito. Ele precisa de gestão."*
- *"Código que resiste à revisão — separação de camadas, testes, CI/CD."*
- *"Da horta à mesa, com rastreabilidade e confiança."*

---

## REFERÊNCIAS TÉCNICAS PARA CITAR

### Mobile (Flutter)
| Aspecto | Detalhe |
|---|---|
| Arquitetura | Feature-first Clean Architecture — `data/domain/presentation` por módulo |
| State management | flutter_bloc 9.1 + Equatable — eventos/estados tipados |
| DI | GetIt + Injectable + build_runner — geração automática |
| Routing | GoRouter 17 — stateful shell routes com guards por role |
| HTTP | Dio 5.9 com interceptors JWT |
| Mapas | google_maps_flutter + geolocator + geocoding |
| Segurança local | flutter_secure_storage para tokens |
| Qualidade | very_good_analysis (Very Good Ventures) |
| Testes | bloc_test + mocktail |

### Backend (Spring Boot)
| Aspecto | Detalhe |
|---|---|
| Stack | Java 21 LTS + Spring Boot 3.3 + Maven |
| Autenticação | Keycloak 26, OAuth2 Direct Access Grants, JWT stateless |
| RBAC | 3 roles: ROLE_ADMIN, ROLE_FARMER, ROLE_CUSTOMER |
| ORM | Spring Data JPA, Hibernate modo `validate` |
| Banco | PostgreSQL 16, 26 tabelas, 19 migrações Flyway |
| Storage | MinIO S3-compatible (fotos de produtos/perfis) |
| Notificações | Firebase Admin SDK 9.8 + FCM |
| Geolocalização | Google Maps API 2.2 |
| IA | Spring AI 1.0.3 + NVIDIA LLM (re-ranker de recomendações) |
| Qualidade | Spotless (Google Java Format) + Checkstyle + SpotBugs + JaCoCo |
| Testes | JUnit 5 + Mockito, 40 arquivos (controller, service, mapper) |
| Docs | OpenAPI 3.0 + Swagger UI com OAuth2 integrado |
| Convenções | Conventional Commits, Gitflow, workflow de 10 passos documentado |

### Infraestrutura
| Aspecto | Detalhe |
|---|---|
| Local | Docker Compose: PostgreSQL + Keycloak + MinIO + Mailpit + App |
| Containerização | Dockerfile multi-stage (builder Maven + runtime JRE), usuário non-root |
| Cloud | Terraform → AWS ECS Fargate + RDS + ECR + S3 + API Gateway + CloudMap |
| Kubernetes | Manifests para Minikube (local) e EKS (AWS) — `k8s/` documentado |
| CI/CD | GitHub Actions: `ci.yml` (test+lint+build) + `aws.yml` (deploy) + `terraform.yml` |
| Segurança infra | Heap capped (75% para ECS), health checks, non-root container |
