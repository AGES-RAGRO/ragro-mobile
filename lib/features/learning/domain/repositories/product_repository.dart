// DOMAIN/REPOSITORIES — O "contrato" do cardápio.
// Define O QUE a cozinha (data/) deve saber fazer, sem dizer COMO.
// É abstrato — não tem implementação aqui. A implementação real fica em data/repositories/.
// Isso permite trocar a "cozinha" (ex: de mock para API real) sem mudar nada no domain/.

import 'package:ragro_mobile/features/learning/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
}
