import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/recommendations/domain/entities/recommendation.dart';
import 'package:ragro_mobile/features/recommendations/domain/repositories/recommendations_repository.dart';
import 'package:ragro_mobile/features/recommendations/domain/usecases/get_recommendations_usecase.dart';

class MockRecommendationsRepository extends Mock
    implements RecommendationsRepository {}

void main() {
  late GetRecommendationsUsecase useCase;
  late MockRecommendationsRepository repo;

  final tRecommendations = [
    const Recommendation(
      id: 'b0000000-0000-0000-0000-000000000004',
      name: 'Espinafre Orgânico',
      price: 6,
      unityType: 'bunch',
      imageS3: null,
      farmerId: 'a0000000-0000-0000-0000-000000000003',
      farmName: 'Sítio Boa Vista',
      categoryNames: ['Verduras'],
      score: 85,
      reason: 'PURCHASE_HISTORY',
    ),
    const Recommendation(
      id: 'b0000000-0000-0000-0000-000000000005',
      name: 'Cenoura Baby',
      price: 7.5,
      unityType: 'kg',
      imageS3: null,
      farmerId: 'a0000000-0000-0000-0000-000000000003',
      farmName: 'Sítio Boa Vista',
      categoryNames: ['Legumes'],
      score: 70,
      reason: 'CATEGORY_PREFERENCE',
    ),
  ];

  setUp(() {
    repo = MockRecommendationsRepository();
    useCase = GetRecommendationsUsecase(repo);
  });

  group('GetRecommendationsUsecase', () {
    test('chama o repository e retorna lista de recomendações', () async {
      when(
        () => repo.getRecommendations(),
      ).thenAnswer((_) async => tRecommendations);

      final result = await useCase();

      expect(result, hasLength(2));
      expect(result.first.id, 'b0000000-0000-0000-0000-000000000004');
      expect(result.first.name, 'Espinafre Orgânico');
      expect(result.first.score, 85);
      expect(result.first.reason, 'PURCHASE_HISTORY');
      verify(() => repo.getRecommendations()).called(1);
    });

    test('retorna lista vazia quando não há recomendações', () async {
      when(
        () => repo.getRecommendations(),
      ).thenAnswer((_) async => []);

      final result = await useCase();

      expect(result, isEmpty);
      verify(() => repo.getRecommendations()).called(1);
    });

    test('propaga NetworkException em caso de erro de conectividade', () async {
      when(
        () => repo.getRecommendations(),
      ).thenThrow(const NetworkException());

      expect(
        () => useCase(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('propaga UnauthorizedException quando usuário não autenticado', () async {
      when(
        () => repo.getRecommendations(),
      ).thenThrow(const UnauthorizedException());

      expect(
        () => useCase(),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('propaga ServerException em erro do servidor', () async {
      when(
        () => repo.getRecommendations(),
      ).thenThrow(const ServerException());

      expect(
        () => useCase(),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
