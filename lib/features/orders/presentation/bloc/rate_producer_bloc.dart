import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/orders/domain/usecases/rate_producer.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/rate_producer_event.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/rate_producer_state.dart';

@injectable
class RateProducerBloc extends Bloc<RateProducerEvent, RateProducerState> {
  RateProducerBloc(this._rateProducer) : super(const RateProducerInitial()) {
    on<RateProducerStarSelected>(_onStarSelected);
    on<RateProducerSubmitted>(_onSubmitted);
  }

  final RateProducer _rateProducer;

  void _onStarSelected(RateProducerStarSelected event, Emitter<RateProducerState> emit) {
    final current = state is RateProducerInitial ? (state as RateProducerInitial).selectedRating : 0;
    emit(RateProducerInitial(selectedRating: event.rating == current ? 0 : event.rating));
  }

  Future<void> _onSubmitted(RateProducerSubmitted event, Emitter<RateProducerState> emit) async {
    emit(const RateProducerSubmitting());
    try {
      await _rateProducer(event.orderId, event.rating);
      emit(const RateProducerSuccess());
    } catch (e) {
      emit(RateProducerFailure(e.toString()));
    }
  }
}
