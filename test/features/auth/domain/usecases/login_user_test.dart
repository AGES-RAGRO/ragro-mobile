import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';
import 'package:ragro_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:ragro_mobile/features/auth/domain/usecases/login_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUser loginUser;
  late MockAuthRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(UserType.customer);
  });

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
    when(() => mockRepo.loginUser(
          email: any(named: 'email'),
          password: any(named: 'password'),
          userType: any(named: 'userType'),
        )).thenAnswer((_) async => (user: tUser, token: 'tok'));

    final result = await loginUser(
      email: 'joao@test.com',
      password: '123456',
      userType: UserType.customer,
    );

    expect(result.user, tUser);
    expect(result.token, 'tok');
    verify(() => mockRepo.loginUser(
          email: 'joao@test.com',
          password: '123456',
          userType: UserType.customer,
        )).called(1);
  });
}
