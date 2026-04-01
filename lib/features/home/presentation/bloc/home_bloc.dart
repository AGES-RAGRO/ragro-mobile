import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/home/domain/usecases/get_home_data.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._getHomeData) : super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onStarted);
  }

  final GetHomeData _getHomeData;

  Future<void> _onStarted(HomeEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    try {
      final data = await _getHomeData();
      emit(HomeLoaded(producers: data.producers, products: data.products));
    } on ApiException catch (e) {
      emit(HomeFailure(e.message));
    } catch (_) {
      emit(const HomeFailure('Erro ao carregar dados. Tente novamente.'));
    }
  }
}
