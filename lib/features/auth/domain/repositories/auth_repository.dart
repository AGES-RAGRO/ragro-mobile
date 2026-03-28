import 'package:ragro_mobile/features/auth/domain/entities/user.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';

abstract class AuthRepository {
  Future<({User user, String token})> loginUser({
    required String email,
    required String password,
    required UserType userType,
  });

  Future<User> registerConsumer({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String zipCode,
    required String street,
    required String number,
    required String city,
    required String state,
    String? complement,
  });

  Future<void> logout();

  Future<User?> getCurrentUser();
}
