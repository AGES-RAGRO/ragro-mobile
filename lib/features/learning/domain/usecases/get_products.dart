// DOMAIN/USECASES — Uma "ação" do cardápio.
// Representa uma ação de negócio: "buscar lista de produtos".
// O UseCase chama o Repository (contrato), sem saber se os dados vêm de API, cache ou mock.
// @lazySingleton: o injectable cria UMA instância e reutiliza sempre (UseCase não tem estado).

import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/learning/domain/entities/product.dart';
import 'package:ragro_mobile/features/learning/domain/repositories/product_repository.dart';

@lazySingleton
class GetProducts {
  const GetProducts(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call() => _repository.getProducts();
}
