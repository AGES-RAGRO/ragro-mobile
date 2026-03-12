// 📋 DOMAIN/ENTITIES — O "cardápio" do restaurante.
// Esta classe representa um Produto PURO — sem JSON, sem HTTP, sem nada externo.
// Ela pertence ao domain/ e NUNCA importa de data/ ou presentation/.
// Extends Equatable para comparação por valor (dois Products com mesmos campos são iguais).

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
