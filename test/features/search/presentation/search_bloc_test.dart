import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/search/data/datasources/search_local_datasource.dart';
import 'package:ragro_mobile/features/search/domain/entities/search_result.dart';
import 'package:ragro_mobile/features/search/domain/repositories/search_repository.dart';
import 'package:ragro_mobile/features/search/domain/usecases/search_producers_and_products.dart';
import 'package:ragro_mobile/features/search/presentation/bloc/search_bloc.dart';
import 'package:ragro_mobile/features/search/presentation/bloc/search_event.dart';
import 'package:ragro_mobile/features/search/presentation/bloc/search_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

class MockSearchProducersAndProducts extends Mock
    implements SearchProducersAndProducts {}

void main() {
  late MockSearchRepository mockRepository;
  late SearchProducersAndProducts usecase;
  late SearchBloc bloc;

  const tProducer = SearchResult(
    id: 'a0000000-0000-0000-0000-000000000003',
    type: SearchResultType.producer,
    name: 'Farmer Test',
    subtitle: 'Sítio Boa Vista',
    imageUrl: '',
    rating: 0,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    mockRepository = MockSearchRepository();
    usecase = SearchProducersAndProducts(mockRepository);
    bloc = SearchBloc(usecase, SearchLocalDataSource(prefs));
  });

  tearDown(() => bloc.close());

  group('SearchQueryChanged', () {
    blocTest<SearchBloc, SearchState>(
      'emite [SearchIdle] quando query está vazia',
      build: () => bloc,
      act: (b) => b.add(const SearchQueryChanged('')),
      expect: () => [const SearchIdle()],
    );

    blocTest<SearchBloc, SearchState>(
      'emite [SearchIdle] quando query é apenas espaços',
      build: () => bloc,
      act: (b) => b.add(const SearchQueryChanged('   ')),
      expect: () => [const SearchIdle()],
    );

    blocTest<SearchBloc, SearchState>(
      'emite [SearchLoading, SearchLoaded] quando busca retorna resultados',
      build: () {
        when(
          () => mockRepository.search(query: 'Farmer'),
        ).thenAnswer((_) async => [tProducer]);
        return bloc;
      },
      act: (b) => b.add(const SearchQueryChanged('Farmer')),
      expect: () => [
        const SearchLoading(),
        const SearchLoaded(results: [tProducer], query: 'Farmer'),
      ],
      verify: (_) {
        verify(() => mockRepository.search(query: 'Farmer')).called(1);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emite [SearchLoading, SearchLoaded] com lista vazia quando não há resultados',
      build: () {
        when(
          () => mockRepository.search(query: 'xyzabc'),
        ).thenAnswer((_) async => []);
        return bloc;
      },
      act: (b) => b.add(const SearchQueryChanged('xyzabc')),
      expect: () => [
        const SearchLoading(),
        const SearchLoaded(results: [], query: 'xyzabc'),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emite [SearchLoading, SearchFailure] quando ocorre ApiException',
      build: () {
        when(
          () => mockRepository.search(query: 'erro'),
        ).thenThrow(const UnknownApiException());
        return bloc;
      },
      act: (b) => b.add(const SearchQueryChanged('erro')),
      expect: () => [const SearchLoading(), isA<SearchFailure>()],
    );

    blocTest<SearchBloc, SearchState>(
      'emite [SearchLoading, SearchFailure] quando ocorre Exception genérica',
      build: () {
        when(
          () => mockRepository.search(query: 'erro'),
        ).thenThrow(Exception('erro genérico'));
        return bloc;
      },
      act: (b) => b.add(const SearchQueryChanged('erro')),
      expect: () => [
        const SearchLoading(),
        const SearchFailure('Erro ao buscar. Tente novamente.'),
      ],
    );
  });

  group('SearchCategoryChanged', () {
    blocTest<SearchBloc, SearchState>(
      'não emite estados ao trocar categoria',
      build: () => bloc,
      act: (b) => b.add(const SearchCategoryChanged('Horta')),
      expect: () => <SearchState>[],
    );

    blocTest<SearchBloc, SearchState>(
      'busca com categoria quando categoria não é Tudo',
      build: () {
        when(
          () => mockRepository.search(query: 'tomate', category: 'Horta'),
        ).thenAnswer((_) async => [tProducer]);
        return bloc;
      },
      act: (b) async {
        b.add(const SearchCategoryChanged('Horta'));
        await Future<void>.delayed(Duration.zero);
        b.add(const SearchQueryChanged('tomate'));
      },
      expect: () => [
        const SearchLoading(),
        const SearchLoaded(results: [tProducer], query: 'tomate'),
      ],
      verify: (_) {
        verify(
          () => mockRepository.search(query: 'tomate', category: 'Horta'),
        ).called(1);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'busca sem categoria quando categoria é Tudo',
      build: () {
        when(
          () => mockRepository.search(query: 'tomate'),
        ).thenAnswer((_) async => [tProducer]);
        return bloc;
      },
      act: (b) async {
        b.add(const SearchCategoryChanged('Tudo'));
        await Future<void>.delayed(Duration.zero);
        b.add(const SearchQueryChanged('tomate'));
      },
      expect: () => [
        const SearchLoading(),
        const SearchLoaded(results: [tProducer], query: 'tomate'),
      ],
      verify: (_) {
        verify(() => mockRepository.search(query: 'tomate')).called(1);
      },
    );
  });

  group('SearchRecentItemRemoved', () {
    blocTest<SearchBloc, SearchState>(
      'remove item das buscas recentes',
      build: () => bloc,
      seed: () => const SearchIdle(recentSearches: ['tomate', 'alface']),
      act: (b) => b.add(const SearchRecentItemRemoved('tomate')),
      expect: () => [
        const SearchIdle(recentSearches: ['alface']),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'não faz nada se o estado não for SearchIdle',
      build: () => bloc,
      seed: () => const SearchLoading(),
      act: (b) => b.add(const SearchRecentItemRemoved('tomate')),
      expect: () => <SearchState>[],
    );
  });
}
