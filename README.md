# RAGRO - Mobile

Bem-vindo ao app mobile do RAGRO! Este documento vai te guiar pela arquitetura do projeto do zero. Mesmo que você nunca tenha visto Flutter, Dart, BLoC ou Clean Architecture na vida — ao final desse README você vai entender como tudo se conecta.

---

## Antes de tudo: o que é Flutter e Dart?

**Dart** é a linguagem de programação. Pense nela como um JavaScript tipado — tem classes, async/await, e roda tanto no celular quanto na web.

**Flutter** é o framework que usa Dart pra construir telas. Tudo no Flutter é um **Widget** — um botão é um widget, um texto é um widget, a tela inteira é um widget. Widgets se encaixam como peças de LEGO pra montar a interface.

```dart
// Exemplo: um texto na tela
Text('Olá, mundo!')

// Exemplo: um botão
ElevatedButton(
  onPressed: () => print('clicou!'),
  child: Text('Clique aqui'),
)
```

---

## A arquitetura: Clean Architecture + BLoC

Nosso projeto usa dois conceitos juntos:

- **Clean Architecture** — como organizamos as pastas e separamos responsabilidades
- **BLoC** — como gerenciamos o estado da tela (loading, erro, sucesso, etc.)

Pra entender, vamos usar uma analogia: **um restaurante**.

---

## A Analogia do Restaurante

Imagine que o app é um restaurante. Cada feature (login, cadastro, dashboard, etc.) é um prato do cardápio. Pra preparar um prato, temos 3 setores:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   SALÃO (presentation/)                                         │
│   O que o cliente vê. Garçom anota o pedido e traz o prato.    │
│   → Telas, botões, formulários, animações                      │
│   → O BLoC é o garçom: recebe pedidos e entrega resultados     │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   CARDÁPIO + REGRAS (domain/)                                   │
│   O que o restaurante sabe fazer. "Temos estrogonofe? Sim."    │
│   → Entities: como um prato se parece (nome, preço, foto)      │
│   → UseCases: as ações possíveis ("fazer login")               │
│   → Repository (contrato): o que a cozinha DEVE saber fazer    │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   COZINHA (data/)                                               │
│   Onde o trabalho pesado acontece. Pega ingredientes e cozinha. │
│   → DataSources: de onde vêm os dados (API, cache local)       │
│   → Models: como o JSON da API vira um objeto Dart             │
│   → Repository (impl): a cozinha real que implementa o contrato│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Regra de ouro:** o salão nunca entra na cozinha. O cardápio não sabe como o prato é feito. Cada setor só conhece o setor diretamente abaixo dele.

---

## Estrutura de pastas

```
lib/
├── main.dart                          ← Liga o app
├── app.dart                           ← Configura tema e rotas
│
├── core/                              ← Coisas compartilhadas por todas as features
│   ├── di/                            ← Injeção de dependência (explico abaixo)
│   ├── network/                       ← Cliente HTTP, URLs da API, exceções
│   ├── theme/                         ← Cores, fontes, tema visual
│   └── router/                        ← Navegação entre telas
│
├── features/                          ← Cada feature do app vive aqui
│   ├── auth/                          ← Feature: autenticação (login, registro)
│   │   ├── data/                      ← 🍳 Cozinha
│   │   │   ├── datasources/           ← De onde vêm os dados
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/                ← Tradutores de JSON
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/          ← Implementação real
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/                    ← 📋 Cardápio + Regras
│   │   │   ├── entities/              ← Objetos puros (sem JSON, sem HTTP)
│   │   │   │   └── user.dart
│   │   │   ├── repositories/          ← Contrato abstrato
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/              ← Ações de negócio
│   │   │       └── login_with_email.dart
│   │   └── presentation/             ← 🍽️ Salão
│   │       ├── bloc/                  ← Garçom (eventos + estados)
│   │       │   ├── login_bloc.dart
│   │       │   ├── login_event.dart
│   │       │   └── login_state.dart
│   │       ├── pages/                 ← Telas
│   │       │   └── login_page.dart
│   │       └── widgets/              ← Pedaços de tela reutilizáveis
│   │           ├── email_field.dart
│   │           └── password_field.dart
│   │
│   ├── dashboard/                     ← Mesma estrutura, outra feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── profile/                       ← Mesma estrutura, outra feature
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── shared/                            ← Widgets usados em várias features
    └── widgets/
```

Toda feature nova segue esse mesmo molde. É copy-paste da estrutura.

---

## Entendendo cada camada na prática

Vamos acompanhar o que acontece quando o usuário faz login com email e senha, passo a passo.

### Passo 1 — O usuário digita email/senha e clica "Entrar"

A **tela** (`presentation/pages/login_page.dart`) captura a ação e envia um **evento** pro BLoC:

```dart
// Na tela, quando o usuário clica em "Entrar":
context.read<LoginBloc>().add(
  LoginSubmitted(
    email: 'joao@email.com',
    password: '123456',
  ),
);
```

Traduzindo: "Ei garçom, o cliente quer fazer login com esse email e senha."

### Passo 2 — O BLoC recebe o evento

O **BLoC** (`presentation/bloc/login_bloc.dart`) é o garçom. Ele recebe o pedido e chama o UseCase:

```dart
@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  // O UseCase é injetado automaticamente (explico depois)
  LoginBloc(this._loginWithEmail)
      : super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  final LoginWithEmail _loginWithEmail;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    // Avisa a tela: "tô autenticando, mostra o loading"
    emit(const LoginLoading());

    try {
      // Chama o UseCase
      final user = await _loginWithEmail(
        email: event.email,
        password: event.password,
      );
      // Deu certo! Avisa a tela
      emit(LoginSuccess(user));
    } on ApiException catch (e) {
      // Deu erro! Avisa a tela
      emit(LoginFailure(e.message));
    }
  }
}
```

Traduzindo: "Anotei o pedido, vou pra cozinha. Enquanto isso, mostra o loading pro cliente."

### Passo 3 — O UseCase chama o Repository

O **UseCase** (`domain/usecases/login_with_email.dart`) representa a ação de negócio. Ele chama o contrato do Repository:

```dart
@lazySingleton
class LoginWithEmail {
  const LoginWithEmail(this._repository);

  final AuthRepository _repository;

  Future<User> call({
    required String email,
    required String password,
  }) => _repository.loginWithEmail(email: email, password: password);
}
```

"Mas pra que esse arquivo se ele só repassa a chamada?"

Boa pergunta. Agora ele é simples, mas imagine que no futuro o login precise:
1. Chamar a API pra autenticar
2. Salvar o token no armazenamento seguro
3. Buscar os dados do perfil do usuário
4. Registrar o dispositivo pra push notifications

Toda essa lógica ficaria aqui, sem poluir o BLoC nem o Repository.

### Passo 4 — O Repository (contrato) define o que pode ser feito

O **Repository abstrato** (`domain/repositories/auth_repository.dart`) é o cardápio da cozinha — diz O QUE ela sabe fazer, sem dizer COMO:

```dart
abstract class AuthRepository {
  Future<User> loginWithEmail({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<User?> getCurrentUser();
}
```

### Passo 5 — A implementação faz o trabalho real

O **RepositoryImpl** (`data/repositories/auth_repository_impl.dart`) é a cozinha de verdade:

```dart
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(email: email, password: password);
    // Salva o token localmente pra manter o usuário logado
    await _localDataSource.saveToken(result.token);
    return result.user;
  }
}
```

O `@LazySingleton(as: AuthRepository)` diz: "quando alguém pedir um `AuthRepository`, entrega essa implementação".

### Passo 6 — O DataSource faz a chamada HTTP

O **DataSource** (`data/datasources/auth_remote_datasource.dart`) é quem realmente fala com a API:

```dart
@lazySingleton
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return LoginResponseModel.fromJson(response.data);
  }
}
```

E o **DataSource local** (`data/datasources/auth_local_datasource.dart`) salva o token:

```dart
@lazySingleton
class AuthLocalDataSource {
  const AuthLocalDataSource(this._storage);

  final SharedPreferences _storage;

  Future<void> saveToken(String token) async {
    await _storage.setString('auth_token', token);
  }

  String? getToken() {
    return _storage.getString('auth_token');
  }

  Future<void> clearToken() async {
    await _storage.remove('auth_token');
  }
}
```

### Passo 7 — Model traduz o JSON, Entity é o objeto puro

O JSON da API chega assim:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "abc123",
    "name": "João Silva",
    "email": "joao@email.com"
  }
}
```

O **Model** (`data/models/`) sabe ler esse JSON:

```dart
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class LoginResponseModel {
  const LoginResponseModel({required this.token, required this.user});

  final String token;
  final UserModel user;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
```

A **Entity** (`domain/entities/`) é o objeto puro, sem saber nada de JSON:

```dart
class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  @override
  List<Object?> get props => [id, name, email];
}
```

**Por que dois arquivos?** Porque a Entity pertence ao `domain/` (não depende de nada) e o Model pertence ao `data/` (sabe ler JSON). O Model **extends** a Entity — ou seja, ele É um User, mas com superpoderes de parsing.

---

## O fluxo completo em um desenho

```
  USUÁRIO CLICA "ENTRAR"
         │
         ▼
  ┌──────────────┐
  │    TELA       │  presentation/pages/
  │  (Widget)     │  Dispara o evento
  └──────┬───────┘
         │ add(LoginSubmitted)
         ▼
  ┌──────────────┐
  │    BLOC       │  presentation/bloc/
  │  (Garçom)     │  Emite Loading, chama UseCase
  └──────┬───────┘
         │ _loginWithEmail()
         ▼
  ┌──────────────┐
  │   USE CASE    │  domain/usecases/
  │  (Ação)       │  Chama o Repository
  └──────┬───────┘
         │ _repository.loginWithEmail()
         ▼
  ┌──────────────┐
  │  REPOSITORY   │  domain/repositories/ (contrato)
  │  (Contrato)   │  data/repositories/   (implementação)
  └──────┬───────┘
         │ _remoteDataSource.login()
         ▼
  ┌──────────────┐
  │  DATASOURCE   │  data/datasources/
  │  (HTTP)       │  Faz o POST, recebe JSON
  └──────┬───────┘
         │ fromJson()
         ▼
  ┌──────────────┐
  │    MODEL      │  data/models/
  │  (Tradutor)   │  Converte JSON → objeto Dart
  └──────┬───────┘
         │ extends
         ▼
  ┌──────────────┐
  │   ENTITY      │  domain/entities/
  │  (Obj puro)   │  Sobe limpo até o BLoC
  └──────┘───────┘
         │
         ▼
  BLOC emite LoginSuccess(user)
         │
         ▼
  TELA reage e navega pro dashboard
```

---

## Entendendo o BLoC: Eventos e Estados

O BLoC funciona como um walkie-talkie entre a tela e os dados.

### Eventos — o que o usuário faz

Definidos em `presentation/bloc/login_event.dart`:

```dart
// Classe base selada — só essas subclasses existem
sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

// "Quero fazer login"
class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
```

### Estados — o que a tela mostra

Definidos em `presentation/bloc/login_state.dart`:

```dart
// Classe base selada
sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {     // tela parada, formulário vazio
  const LoginInitial();
}

class LoginLoading extends LoginState {     // mostra spinner, desabilita botão
  const LoginLoading();
}

class LoginSuccess extends LoginState {     // deu certo! tem o usuário
  const LoginSuccess(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

class LoginFailure extends LoginState {     // deu erro, mostra mensagem
  const LoginFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
```

### Como a tela usa o BLoC

```dart
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Cria o BLoC via injeção de dependência
      create: (_) => getIt<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      // BlocListener escuta "side-effects" (navegação, snackbar, etc.)
      listener: (context, state) {
        if (state is LoginSuccess) {
          // Login deu certo → vai pro dashboard
          context.go('/dashboard');
        } else if (state is LoginFailure) {
          // Login falhou → mostra erro na tela
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Campo de email
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                controller: _emailController,
              ),
              // Campo de senha
              TextField(
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 24),

              // BlocBuilder reconstroi o botão baseado no estado
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  return ElevatedButton(
                    // Se tá carregando, desabilita o botão
                    onPressed: state is LoginLoading
                        ? null
                        : () {
                            context.read<LoginBloc>().add(
                              LoginSubmitted(
                                email: _emailController.text,
                                password: _passwordController.text,
                              ),
                            );
                          },
                    child: state is LoginLoading
                        ? const CircularProgressIndicator()
                        : const Text('Entrar'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Injeção de dependência: como tudo se conecta

Você deve ter notado que o BLoC recebe o UseCase, que recebe o Repository, que recebe o DataSource... mas ninguém faz `new` manualmente. Quem faz isso é a **injeção de dependência** (DI).

Usamos dois pacotes: **get_it** (um "armário" global) e **injectable** (lê as anotações e monta tudo sozinho).

### As anotações

```dart
@injectable          // cria uma instância NOVA toda vez (usado em BLoCs)
@lazySingleton       // cria UMA vez e reutiliza sempre (usado em UseCases, DataSources)
@LazySingleton(as: AuthRepository)  // registra pela interface
```

### O resultado: uma cadeia automática

```
getIt<LoginBloc>()
  └→ precisa de LoginWithEmail
       └→ LoginWithEmail precisa de AuthRepository
            └→ AuthRepositoryImpl precisa de AuthRemoteDataSource + AuthLocalDataSource
                 └→ AuthRemoteDataSource precisa de ApiClient
                      └→ ApiClient é criado com Dio
                 └→ AuthLocalDataSource precisa de SharedPreferences
```

Tudo isso é resolvido automaticamente. Na tela, basta:

```dart
BlocProvider(
  create: (_) => getIt<LoginBloc>(),  // mágica acontece aqui
  child: const LoginPage(),
)
```

### Como gerar o código de DI

Quando você criar ou modificar classes com essas anotações, rode:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Isso atualiza o arquivo `lib/core/di/injection.config.dart` com todas as dependências mapeadas.

---

## Tratamento de erros

A API pode falhar de várias formas. Temos uma hierarquia de exceções em `core/network/api_exception.dart`:

```dart
sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
}

class UnauthorizedException extends ApiException {       // 401 — email/senha errados
  const UnauthorizedException(super.message);
}
class NotFoundException extends ApiException {            // 404
  const NotFoundException(super.message);
}
class RateLimitedException extends ApiException {         // 429 — muitas tentativas
  const RateLimitedException(super.message);
}
class TimeoutException extends ApiException {             // timeout
  const TimeoutException(super.message);
}
class NetworkException extends ApiException {             // sem internet
  const NetworkException(super.message);
}
class ServerException extends ApiException {              // 500+
  const ServerException(super.message);
}
class UnknownApiException extends ApiException {          // qualquer outro
  const UnknownApiException(super.message);
}
```

O `ApiClient` intercepta erros do Dio e converte pra essas exceções. O BLoC pega com `on ApiException catch (e)` e emite um estado de falha com a mensagem certa.

---

## Navegação

Usamos **GoRouter** pra gerenciar as rotas do app:

```
/login              ← Tela de login
/register           ← Tela de cadastro
/dashboard          ← Tela inicial (após login)
/profile            ← Perfil do usuário
/settings           ← Configurações
```

A navegação é declarativa — você define as rotas num arquivo central (`core/router/app_router.dart`) e navega com `context.go('/dashboard')`.

---

## Criando uma feature nova — passo a passo

Quer criar a feature "Cadastro de Usuário"? Siga esse checklist:

### 1. Crie a estrutura de pastas

```
lib/features/register/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

### 2. Comece pelo domain/ (de dentro pra fora)

```dart
// domain/entities/register_result.dart
class RegisterResult extends Equatable {
  final String userId;
  final String email;
  // ... campos puros, sem JSON
}

// domain/repositories/register_repository.dart
abstract class RegisterRepository {
  Future<RegisterResult> register({
    required String name,
    required String email,
    required String password,
  });
}

// domain/usecases/register_user.dart
@lazySingleton
class RegisterUser {
  const RegisterUser(this._repository);
  final RegisterRepository _repository;

  Future<RegisterResult> call({
    required String name,
    required String email,
    required String password,
  }) => _repository.register(name: name, email: email, password: password);
}
```

### 3. Implemente o data/

```dart
// data/models/register_result_model.dart
class RegisterResultModel extends RegisterResult {
  factory RegisterResultModel.fromJson(Map<String, dynamic> json) { ... }
}

// data/datasources/register_remote_datasource.dart
@lazySingleton
class RegisterRemoteDataSource {
  // chamada HTTP real: POST /auth/register
}

// data/repositories/register_repository_impl.dart
@LazySingleton(as: RegisterRepository)
class RegisterRepositoryImpl implements RegisterRepository {
  // delega pro datasource
}
```

### 4. Crie o BLoC no presentation/

```dart
// presentation/bloc/register_event.dart
sealed class RegisterEvent extends Equatable {}

class RegisterSubmitted extends RegisterEvent {
  final String name;
  final String email;
  final String password;
}

// presentation/bloc/register_state.dart
sealed class RegisterState extends Equatable {}

class RegisterInitial extends RegisterState {}
class RegisterLoading extends RegisterState {}
class RegisterSuccess extends RegisterState { ... }
class RegisterFailure extends RegisterState { ... }

// presentation/bloc/register_bloc.dart
// Siga o padrão do LoginBloc como referência
```

### 5. Rode o build_runner e registre a rota

```bash
dart run build_runner build --delete-conflicting-outputs
```

Adicione a rota no `core/router/app_router.dart`.

---

## Regras do projeto

### Dependências entre camadas

```
✅ presentation/ importa de domain/ (entities, usecases)
✅ data/ importa de domain/ (entities, repositories)
❌ domain/ NUNCA importa de data/ ou presentation/
❌ presentation/ NUNCA importa de data/ (exceto via DI)
```

### Convenções de nomenclatura

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Entity | `nome.dart` | `user.dart` |
| Model | `nome_model.dart` | `user_model.dart` |
| Repository (contrato) | `nome_repository.dart` | `auth_repository.dart` |
| Repository (impl) | `nome_repository_impl.dart` | `auth_repository_impl.dart` |
| DataSource (remoto) | `nome_remote_datasource.dart` | `auth_remote_datasource.dart` |
| DataSource (local) | `nome_local_datasource.dart` | `auth_local_datasource.dart` |
| UseCase | `verbo_substantivo.dart` | `login_with_email.dart` |
| BLoC | `nome_bloc.dart` | `login_bloc.dart` |
| Event | `nome_event.dart` | `login_event.dart` |
| State | `nome_state.dart` | `login_state.dart` |
| Page | `nome_page.dart` | `login_page.dart` |

---

## Stack tecnológica

| Pacote | Pra que serve |
|--------|---------------|
| `flutter_bloc` | Gerenciamento de estado (BLoC pattern) |
| `get_it` + `injectable` | Injeção de dependência automática |
| `dio` | Cliente HTTP (chamadas de API) |
| `go_router` | Navegação entre telas |
| `equatable` | Comparação de objetos por valor |
| `shared_preferences` | Armazenamento local simples (token, configs) |

### Dev/Test

| Pacote | Pra que serve |
|--------|---------------|
| `bloc_test` | Testes de BLoC |
| `mocktail` | Mocks pra testes |
| `build_runner` | Geração de código (DI) |

---

## Rodando o projeto

```bash
# Instalar dependências
flutter pub get

# Gerar código de injeção de dependência
dart run build_runner build --delete-conflicting-outputs

# Rodar o app
flutter run

# Rodar testes
flutter test
```

---

## TL;DR

1. Cada feature tem 3 pastas: `data/` (cozinha), `domain/` (cardápio), `presentation/` (salão)
2. O **BLoC** fica no `presentation/` — recebe eventos da tela, chama UseCases, emite estados
3. O **UseCase** fica no `domain/` — representa uma ação de negócio
4. O **Repository** tem o contrato no `domain/` e a implementação no `data/`
5. O **DataSource** fica no `data/` — faz a chamada HTTP real (ou acesso local)
6. O **Model** traduz JSON, a **Entity** é o objeto puro
7. Tudo se conecta automaticamente via **injeção de dependência** (get_it + injectable)
8. Pra criar uma feature nova, copie a estrutura de uma existente e siga o padrão
