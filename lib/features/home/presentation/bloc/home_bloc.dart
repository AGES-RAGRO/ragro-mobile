import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/home/domain/repositories/favorite_producer_repository.dart';
import 'package:ragro_mobile/features/home/domain/usecases/get_home_data.dart';
import 'package:ragro_mobile/features/home/domain/usecases/get_producers.dart';
import 'package:ragro_mobile/features/home/domain/usecases/get_recommended_products.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_state.dart';

@lazySingleton
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(
    this._getHomeData,
    this._getProducers,
    this._getRecommendedProducts,
    this._favoriteRepository,
  ) : super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onStarted);
    on<HomeLoadMoreProducers>(_onLoadMoreProducers);
    on<HomeLoadMoreProducts>(_onLoadMoreProducts);
    on<HomeFavoriteToggled>(_onFavoriteToggled);
  }

  final GetHomeData _getHomeData;
  final GetProducers _getProducers;
  final GetRecommendedProducts _getRecommendedProducts;
  final FavoriteProducerRepository _favoriteRepository;

  Future<void> _onStarted(HomeEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    try {
      final (
        :producers,
        :products,
        :hasMoreProducts,
      ) = await _getHomeData();

      final favorites = await _favoriteRepository.getFavorites();

      emit(
        HomeLoaded(
          producers: producers.content,
          products: products,
          favorites: favorites,
          favoriteIds: {for (final f in favorites) f.producerId},
          currentProducersPage: producers.page,
          hasMoreProducers: producers.page < producers.totalPages - 1,
          hasMoreProducts: hasMoreProducts,
        ),
      );
    } on ApiException catch (e) {
      emit(HomeFailure(e.message));
    } on Exception catch (_) {
      emit(const HomeFailure('Erro ao carregar dados. Tente novamente.'));
    }
  }

  Future<void> _onFavoriteToggled(
    HomeFavoriteToggled event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is! HomeLoaded) return;

    final isFav = current.isFavorite(event.producerId);

    final newIds = Set<String>.from(current.favoriteIds);
    final newFavorites = isFav
        ? current.favorites
            .where((f) => f.producerId != event.producerId)
            .toList()
        : current.favorites;

    if (isFav) {
      newIds.remove(event.producerId);
    } else {
      newIds.add(event.producerId);
    }

    emit(current.copyWith(favorites: newFavorites, favoriteIds: newIds));

    try {
      if (isFav) {
        await _favoriteRepository.unfavoriteProducer(event.producerId);
      } else {
        await _favoriteRepository.favoriteProducer(event.producerId);
      }
      final favorites = await _favoriteRepository.getFavorites();
      emit(
        current.copyWith(
          favorites: favorites,
          favoriteIds: {for (final f in favorites) f.producerId},
        ),
      );
    } on Object {
      emit(current.copyWith(favoriteIds: current.favoriteIds));
    }
  }

  Future<void> _onLoadMoreProducers(
    HomeLoadMoreProducers event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeLoaded ||
        !currentState.hasMoreProducers ||
        currentState.isFetchingMoreProducers) {
      return;
    }

    emit(currentState.copyWith(isFetchingMoreProducers: true));

    try {
      final nextPage = currentState.currentProducersPage + 1;
      final response = await _getProducers(page: nextPage);

      emit(
        currentState.copyWith(
          producers: [...currentState.producers, ...response.content],
          currentProducersPage: nextPage,
          hasMoreProducers: nextPage < response.totalPages - 1,
          isFetchingMoreProducers: false,
        ),
      );
    } on Object {
      emit(currentState.copyWith(isFetchingMoreProducers: false));
    }
  }

  Future<void> _onLoadMoreProducts(
    HomeLoadMoreProducts event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeLoaded ||
        !currentState.hasMoreProducts ||
        currentState.isFetchingMoreProducts) {
      return;
    }

    emit(currentState.copyWith(isFetchingMoreProducts: true));

    try {
      final nextPage = currentState.currentProductsProducerPage + 1;
      final result = await _getRecommendedProducts(producerPage: nextPage);

      emit(
        currentState.copyWith(
          products: [...currentState.products, ...result.products],
          currentProductsProducerPage: nextPage,
          hasMoreProducts: result.hasMore,
          isFetchingMoreProducts: false,
        ),
      );
    } on Object {
      emit(currentState.copyWith(isFetchingMoreProducts: false));
    }
  }
}
