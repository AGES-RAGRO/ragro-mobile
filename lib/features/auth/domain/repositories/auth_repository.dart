import 'package:ragro_mobile/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<({User user, String token})> loginUser({
    required String email,
    required String password,
  });

  Future<User> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String fiscalNumber,
    required String password,
    required String zipCode,
    required String street,
    required String number,
    required String city,
    required String state,
    String? complement,
    String? neighborhood,
  });

  Future<void> logout();

  Future<void> requestPasswordReset();
  
  Future<void> forgotPassword(String email);

  Future<User?> getCurrentUser();
}
