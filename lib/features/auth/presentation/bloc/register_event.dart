import 'package:equatable/equatable.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();
  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted({
    required this.name,
    required this.phone,
    required this.email,
    required this.fiscalNumber,
    required this.password,
    required this.zipCode,
    required this.street,
    required this.number,
    required this.city,
    required this.state,
    this.complement,
    this.neighborhood,
  });

  final String name;
  final String phone;
  final String email;
  final String fiscalNumber;
  final String password;
  final String zipCode;
  final String street;
  final String number;
  final String city;
  final String state;
  final String? complement;
  final String? neighborhood;

  @override
  List<Object?> get props => [
    name,
    phone,
    email,
    fiscalNumber,
    password,
    zipCode,
    street,
    number,
    city,
    state,
    complement,
    neighborhood,
  ];
}
