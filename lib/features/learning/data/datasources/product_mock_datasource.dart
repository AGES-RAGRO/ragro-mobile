// DATA/DATASOURCES — De onde vêm os "ingredientes" da cozinha.
// Em produção, aqui ficaria a chamada HTTP real (ex: dio.get('/products')).
// Neste exemplo, usamos dados fake com Future.delayed para simular latência de API.
//
// O contador _callCount simula erros a cada 3 chamadas, para que seja possivel ver
// o estado de Failure e o botão "Tentar novamente" funcionando na tela.
//
// @lazySingleton: uma instância só (mantém o contador entre chamadas).

import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/learning/data/models/product_model.dart';

@lazySingleton
class ProductMockDataSource {
  int _callCount = 0;

  Future<List<ProductModel>> getProducts() async {
    // Simula latência de rede (1 segundo)
    await Future<void>.delayed(const Duration(seconds: 1));

    _callCount++;

    // A cada 3 chamadas, simula um erro de rede
    if (_callCount % 3 == 0) {
      throw Exception(
        'Erro simulado: falha na conexão com o servidor. '
        'Isso é proposital para demonstrar o tratamento de erros!',
      );
    }

    // Dados fake que simulam resposta da API
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
