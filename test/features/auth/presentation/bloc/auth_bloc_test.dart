import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';
import 'package:ragro_mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:ragro_mobile/features/auth/domain/usecases/logout.dart';
import 'package:ragro_mobile/features/auth/domain/usecases/request_password_reset.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_state.dart';

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockLogout extends Mock implements Logout {}

class MockRequestPasswordReset extends Mock implements RequestPasswordReset {}

void main() {
  late AuthBloc bloc;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockLogout mockLogout;
  late MockRequestPasswordReset mockRequestPasswordReset;

  setUp(() {
    mockGetCurrentUser = MockGetCurrentUser();
    mockLogout = MockLogout();
    mockRequestPasswordReset = MockRequestPasswordReset();
    bloc = AuthBloc(mockGetCurrentUser, mockLogout, mockRequestPasswordReset);
  });

  tearDown(() => bloc.close());

  const tUser = User(
    id: '1',
    name: 'Maria',
    email: 'm@t.com',
    type: UserType.customer,
    active: true,
  );

  blocTest<AuthBloc, AuthState>(
    'emits [Loading, Authenticated] when user exists',
    build: () {
      when(() => mockGetCurrentUser()).thenAnswer((_) async => tUser);
      return bloc;
    },
    act: (b) => b.add(const AuthStarted()),
    expect: () => [const AuthLoading(), const AuthAuthenticated(tUser)],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [Loading, Unauthenticated] when no user',
    build: () {
      when(() => mockGetCurrentUser()).thenAnswer((_) async => null);
      return bloc;
    },
    act: (b) => b.add(const AuthStarted()),
    expect: () => [const AuthLoading(), const AuthUnauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [Unauthenticated] on logout',
    build: () {
      when(() => mockLogout()).thenAnswer((_) async {});
      return bloc;
    },
    seed: () => const AuthAuthenticated(tUser),
    act: (b) => b.add(const AuthLogoutRequested()),
    expect: () => [const AuthUnauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [InProgress, Success] when password reset succeeds',
    build: () {
      when(() => mockRequestPasswordReset()).thenAnswer((_) async {});
      return bloc;
    },
    seed: () => const AuthAuthenticated(tUser),
    act: (b) => b.add(const AuthPasswordResetRequested()),
    expect: () => [
      const AuthPasswordResetInProgress(tUser),
      const AuthPasswordResetSuccess(tUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [InProgress, Failure] when password reset fails',
    build: () {
      when(
        () => mockRequestPasswordReset(),
      ).thenThrow(Exception('Erro ao enviar e-mail'));
      return bloc;
    },
    seed: () => const AuthAuthenticated(tUser),
    act: (b) => b.add(const AuthPasswordResetRequested()),
    expect: () => [
      const AuthPasswordResetInProgress(tUser),
      const AuthPasswordResetFailure(tUser, 'Exception: Erro ao enviar e-mail'),
    ],
  );
}
