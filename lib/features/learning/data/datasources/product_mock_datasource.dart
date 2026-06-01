// Mock data source: returns fake products with a simulated delay. _callCount
// forces an error every 3rd call to exercise the failure/retry UI. Kept as a
// lazySingleton so the counter persists across calls.

import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/learning/data/models/product_model.dart';

@lazySingleton
class ProductMockDataSource {
  int _callCount = 0;

  Future<List<ProductModel>> getProducts() async {
    await Future<void>.delayed(const Duration(seconds: 1));

    _callCount++;

    // Simulate a network error every 3rd call.
    if (_callCount % 3 == 0) {
      throw Exception(
        'Erro simulado: falha na conexão com o servidor. '
        'Isso é proposital para demonstrar o tratamento de erros!',
      );
    }

    return const [
      ProductModel(
        id: '1',
        name: 'Soja em Grão',
        description: 'Soja de alta qualidade para plantio',
        price: 152.30,
      ),
      ProductModel(
        id: '2',
        name: 'Milho Híbrido',
        description: 'Sementes de milho híbrido resistente',
        price: 89.90,
      ),
      ProductModel(
        id: '3',
        name: 'Fertilizante NPK',
        description: 'Fertilizante balanceado 10-10-10',
        price: 210,
      ),
      ProductModel(
        id: '4',
        name: 'Defensivo Agrícola',
        description: 'Proteção contra pragas e fungos',
        price: 340.50,
      ),
      ProductModel(
        id: '5',
        name: 'Adubo Orgânico',
        description: 'Adubo 100% natural para hortas',
        price: 45,
      ),
    ];
  }
}
