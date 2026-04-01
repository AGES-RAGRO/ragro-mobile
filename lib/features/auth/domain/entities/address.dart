import 'package:equatable/equatable.dart';

class Address extends Equatable {
  const Address({
    required this.id,
    required this.street,
    required this.number,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.isPrimary,
    this.complement,
    this.neighborhood,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String street;
  final String number;
  final String city;
  final String state;
  final String zipCode;
  final bool isPrimary;
  final String? complement;
  final String? neighborhood;
  final double? latitude;
  final double? longitude;

  @override
  List<Object?> get props => [
    id, street, number, city, state, zipCode,
    isPrimary, complement, neighborhood, latitude, longitude,
  ];
}
