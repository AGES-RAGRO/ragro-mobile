import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';
import 'package:ragro_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:ragro_mobile/features/auth/domain/usecases/login_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUser loginUser;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    loginUser = LoginUser(mockRepo);
  });

  const tUser = User(
    id: 'user-1',
    name: 'João',
    email: 'joao@test.com',
    type: UserType.customer,
    active: true,
  );

  test('calls repository with correct params', () async {
    when(
      () => mockRepo.loginUser(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => (user: tUser, token: 'tok'));

    final result = await loginUser(email: 'joao@test.com', password: '123456');

    expect(result.user, tUser);
    expect(result.token, 'tok');
    verify(
      () => mockRepo.loginUser(email: 'joao@test.com', password: '123456'),
    ).called(1);
  });

  test('propagates UnauthorizedException from repository', () async {
    when(
      () => mockRepo.loginUser(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const UnauthorizedException());

    expect(
      () => loginUser(email: 'j@t.com', password: 'wrong'),
      throwsA(isA<UnauthorizedException>()),
    );
  });
}
