// Pure domain entity (no JSON/HTTP); Equatable for value comparison.

import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  final String id;
  final String name;
  final String description;
  final double price;

  @override
  List<Object?> get props => [id, name, description, price];
}
