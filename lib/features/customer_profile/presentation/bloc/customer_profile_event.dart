import 'package:equatable/equatable.dart';

sealed class CustomerProfileEvent extends Equatable {
  const CustomerProfileEvent();

  @override
  List<Object?> get props => [];
}

class CustomerProfileStarted extends CustomerProfileEvent {
  const CustomerProfileStarted();
}

class CustomerProfileUpdateSubmitted extends CustomerProfileEvent {
  const CustomerProfileUpdateSubmitted({
    required this.name,
    required this.phone,
    required this.street,
    required this.number,
    required this.city,
    required this.state,
    required this.zipCode,
    this.complement,
    this.neighborhood,
  });

  final String name;
  final String phone;
  final String street;
  final String number;
  final String city;
  final String state;
  final String zipCode;
  final String? complement;
  final String? neighborhood;

  @override
  List<Object?> get props => [
    name,
    phone,
    street,
    number,
    city,
    state,
    zipCode,
    complement,
    neighborhood,
  ];
}
