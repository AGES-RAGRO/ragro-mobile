import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/get_today_route.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/route_event.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/route_state.dart';

@injectable
class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc(this._getTodayRoute) : super(const RouteInitial()) {
    on<RouteLoadStarted>(_onLoadStarted);
  }

  final GetTodayRoute _getTodayRoute;

  Future<void> _onLoadStarted(
    RouteLoadStarted event,
    Emitter<RouteState> emit,
  ) async {
    emit(const RouteLoading());
    try {
      final route = await _getTodayRoute();
      emit(RouteLoaded(route));
    } on Exception catch (e) {
      emit(RouteError(e.toString()));
    }
  }
}
