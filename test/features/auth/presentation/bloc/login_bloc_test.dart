import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';
import 'package:ragro_mobile/features/auth/domain/usecases/forgot_password.dart';
import 'package:ragro_mobile/features/auth/domain/usecases/login_user.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/login_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/login_event.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/login_state.dart';

class MockLoginUser extends Mock implements LoginUser {}

class MockForgotPassword extends Mock implements ForgotPassword {}

void main() {
  late LoginBloc bloc;
  late MockLoginUser mockLoginUser;
  late MockForgotPassword mockForgotPassword;

  setUp(() {
    mockLoginUser = MockLoginUser();
    mockForgotPassword = MockForgotPassword();
    bloc = LoginBloc(mockLoginUser, mockForgotPassword);
  });

  tearDown(() => bloc.close());

  const tUser = User(
    id: '1',
    name: 'João',
    email: 'j@t.com',
    type: UserType.customer,
    active: true,
  );

  blocTest<LoginBloc, LoginState>(
    'emits [Loading, Success] on successful login',
    build: () {
      when(
        () => mockLoginUser(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => (user: tUser, token: 'tok'));
      return bloc;
    },
    act: (b) => b.add(const LoginSubmitted(email: 'j@t.com', password: '123')),
    expect: () => [const LoginLoading(), const LoginSuccess(tUser)],
  );

  blocTest<LoginBloc, LoginState>(
    'emits [Loading, Failure] on UnauthorizedException',
    build: () {
      when(
        () => mockLoginUser(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const UnauthorizedException());
      return bloc;
    },
    act: (b) =>
        b.add(const LoginSubmitted(email: 'j@t.com', password: 'wrong')),
    expect: () => [
      const LoginLoading(),
      const LoginFailure('Credenciais inválidas'),
    ],
  );

  group('ForgotPassword', () {
    blocTest<LoginBloc, LoginState>(
      'emits [InProgress, Success] when forgot password succeeds',
      build: () {
        when(() => mockForgotPassword(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (b) => b.add(const LoginForgotPasswordRequested('test@test.com')),
      expect: () => [
        const LoginForgotPasswordInProgress(),
        const LoginForgotPasswordSuccess(),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [InProgress, Failure] when forgot password fails',
      build: () {
        when(() => mockForgotPassword(any()))
            .thenThrow(const UnknownApiException('Error'));
        return bloc;
      },
      act: (b) => b.add(const LoginForgotPasswordRequested('test@test.com')),
      expect: () => [
        const LoginForgotPasswordInProgress(),
        const LoginForgotPasswordFailure('Error'),
      ],
    );
  });
}
