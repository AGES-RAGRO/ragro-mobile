import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user.dart';
import 'package:ragro_mobile/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class RegisterCustomer {
  const RegisterCustomer(this._repository);
  final AuthRepository _repository;

  Future<User> call({
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
  }) => _repository.registerCustomer(
    name: name,
    phone: phone,
    email: email,
    fiscalNumber: fiscalNumber,
    password: password,
    zipCode: zipCode,
    street: street,
    number: number,
    city: city,
    state: state,
    complement: complement,
    neighborhood: neighborhood,
  );
}
