import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/home/domain/usecases/get_home_data.dart';
import 'package:ragro_mobile/features/home/domain/usecases/get_producers.dart';
import 'package:ragro_mobile/features/home/domain/usecases/get_recommended_products.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(
    this._getHomeData,
    this._getProducers,
    this._getRecommendedProducts,
  ) : super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onStarted);
    on<HomeLoadMoreProducers>(_onLoadMoreProducers);
    on<HomeLoadMoreProducts>(_onLoadMoreProducts);
  }

  final GetHomeData _getHomeData;
  final GetProducers _getProducers;
  final GetRecommendedProducts _getRecommendedProducts;

  Future<void> _onStarted(HomeEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    try {
      final data = await _getHomeData();
      emit(
        HomeLoaded(
          producers: data.producers.content,
          products: data.products,
          currentProducersPage: data.producers.page,
          hasMoreProducers: data.producers.page < data.producers.totalPages - 1,
          hasMoreProducts: data.hasMoreProducts,
        ),
      );
    } on ApiException catch (e) {
      emit(HomeFailure(e.message));
    } on Exception catch (_) {
      emit(const HomeFailure('Erro ao carregar dados. Tente novamente.'));
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
