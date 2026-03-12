import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/features/learning/domain/entities/product.dart';
import 'package:ragro_mobile/features/learning/domain/repositories/product_repository.dart';
import 'package:ragro_mobile/features/learning/domain/usecases/get_products.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late GetProducts useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProducts(mockRepository);
  });

  final testProducts = [
    const Product(
      id: '1',
      name: 'Soja',
      description: 'Soja em grão',
      price: 150,
    ),
  ];

  test('should return list of products from repository', () async {
    when(
      () => mockRepository.getProducts(),
    ).thenAnswer((_) async => testProducts);

    final result = await useCase();

    expect(result, equals(testProducts));
    verify(() => mockRepository.getProducts()).called(1);
  });

  test('should rethrow exception when repository fails', () async {
    when(
      () => mockRepository.getProducts(),
    ).thenThrow(Exception('Erro simulado'));

    expect(() => useCase(), throwsException);
    verify(() => mockRepository.getProducts()).called(1);
  });
}
