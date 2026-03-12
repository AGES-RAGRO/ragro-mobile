# RAGRO - Mobile

App mobile do RAGRO, construído com Flutter usando Clean Architecture + BLoC.

Para entender a arquitetura do projeto em detalhes, leia o [Guia de Arquitetura](docs/ARCHITECTURE.md).

---

## Pré-requisitos

Antes de começar, instale as seguintes ferramentas:

| Ferramenta | Versão mínima | Instalação |
|------------|---------------|------------|
| Flutter | 3.41+ | [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) |
| Dart | 3.11+ | Incluso no Flutter |
| Lefthook | 2.1+ | `scoop install lefthook` (Windows) / `brew install lefthook` (macOS) / `snap install lefthook` (Linux) |

---

## Setup do projeto

```bash
# 1. Clone o repositório
git clone <url-do-repo>
cd ragro-mobile

# 2. Instale as dependências do Flutter
flutter pub get

# 3. Instale os git hooks (lefthook)
lefthook install

# 4. Gere o código de injeção de dependência
dart run build_runner build --delete-conflicting-outputs

# 5. Rode o app
flutter run
```

---

## Conventional Commits

O projeto usa **Conventional Commits** para padronizar as mensagens de commit. O Lefthook valida automaticamente antes de cada commit.

### Formato

```
<tipo>(<escopo>): <descrição>
```

### Tipos permitidos

| Tipo | Quando usar |
|------|-------------|
| `feat` | Nova funcionalidade |
| `fix` | Correção de bug |
| `docs` | Alteração em documentação |
| `style` | Formatação, ponto e vírgula, etc. (sem mudança de lógica) |
| `refactor` | Refatoração de código (sem feat nem fix) |
| `test` | Adição ou correção de testes |
| `chore` | Tarefas de manutenção (configs, dependências, etc.) |
| `ci` | Mudanças em CI/CD |
| `build` | Mudanças no sistema de build |
| `perf` | Melhoria de performance |

### Exemplos

```bash
feat(auth): adiciona tela de login
fix(dashboard): corrige loading infinito ao buscar dados
docs: atualiza README com instruções de setup
chore: atualiza dependências do Flutter
refactor(profile)!: altera estrutura de dados do usuário  # breaking change
```

---

## Git Hooks (Lefthook)

O Lefthook roda automaticamente em cada commit:

| Hook | Comando | O que faz |
|------|---------|-----------|
| `pre-commit` | `dart format` | Bloqueia se o código não estiver formatado |
| `pre-commit` | `dart analyze` | Bloqueia se houver warnings ou erros de lint |
| `commit-msg` | Regex check | Bloqueia se a mensagem não seguir Conventional Commits |

Se o commit for bloqueado, corrija o problema e tente novamente.

---

## Linting

Usamos o pacote **very_good_analysis** com regras rigorosas de lint. A configuração está em `analysis_options.yaml`.

```bash
# Rodar análise manualmente
dart analyze

# Formatar código
dart format .
```

---

## EditorConfig

O projeto inclui um `.editorconfig` que padroniza:

- **Indentação:** 2 espaços (padrão Dart/Flutter)
- **Encoding:** UTF-8
- **Line endings:** LF (mesmo no Windows)
- **Trailing whitespace:** removido automaticamente

> No VS Code, instale a extensão [EditorConfig for VS Code](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig). No Android Studio/IntelliJ já funciona nativamente.

---

## Comandos úteis

```bash
# Instalar dependências
flutter pub get

# Gerar código de DI
dart run build_runner build --delete-conflicting-outputs

# Rodar o app
flutter run

# Rodar testes
flutter test

# Formatar código
dart format .

# Analisar código
dart analyze
```

---

## Stack tecnológica

| Pacote | Função |
|--------|--------|
| `flutter_bloc` | Gerenciamento de estado (BLoC) |
| `get_it` + `injectable` | Injeção de dependência automática |
| `dio` | Cliente HTTP |
| `go_router` | Navegação entre telas |
| `equatable` | Comparação de objetos por valor |
| `shared_preferences` | Armazenamento local (token, configs) |

### Dev/Test

| Pacote | Função |
|--------|--------|
| `very_good_analysis` | Regras de lint rigorosas |
| `injectable_generator` + `build_runner` | Geração de código (DI) |
| `bloc_test` | Testes de BLoC |
| `mocktail` | Mocks para testes |

---

## Estrutura de pastas

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── di/              ← Injeção de dependência
│   ├── network/         ← Cliente HTTP, exceções
│   ├── theme/           ← Cores, fontes, tema visual
│   └── router/          ← Navegação entre telas
├── features/            ← Cada feature do app
│   └── <feature>/
│       ├── data/        ← DataSources, Models, Repository impl
│       ├── domain/      ← Entities, UseCases, Repository contrato
│       └── presentation/← BLoC, Pages, Widgets
└── shared/
    └── widgets/         ← Widgets reutilizáveis
```

Para detalhes completos sobre a arquitetura, camadas e exemplos de código, leia o [Guia de Arquitetura](docs/ARCHITECTURE.md).
