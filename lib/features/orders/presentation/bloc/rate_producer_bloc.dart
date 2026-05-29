import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/orders/domain/usecases/CreateReview.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/rate_producer_event.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/rate_producer_state.dart';

@injectable
class RateProducerBloc extends Bloc<RateProducerEvent, RateProducerState> {
  RateProducerBloc(this._rateProducer) : super(const RateProducerInitial()) {
    on<RateProducerStarSelected>(_onStarSelected);
    on<RateProducerCommentChanged>(_onCommentChanged);
    on<RateProducerSubmitted>(_onSubmitted);
  }

  final CreateReview _rateProducer;

  void _onStarSelected(
    RateProducerStarSelected event,
    Emitter<RateProducerState> emit,
  ) {
    final currentState = state;
    final current = currentState is RateProducerInitial
        ? currentState.selectedRating
        : currentState is RateProducerSubmitting
        ? currentState.selectedRating
        : 0;
    final currentComment = currentState is RateProducerInitial
        ? currentState.comment
        : currentState is RateProducerSubmitting
        ? currentState.comment
        : '';
    emit(
      RateProducerInitial(
        selectedRating: event.rating == current ? 0 : event.rating,
        comment: currentComment,
      ),
    );
  }

  void _onCommentChanged(
    RateProducerCommentChanged event,
    Emitter<RateProducerState> emit,
  ) {
    final currentState = state;
    final currentRating = currentState is RateProducerInitial
        ? currentState.selectedRating
        : currentState is RateProducerSubmitting
        ? currentState.selectedRating
        : 0;
    emit(
      RateProducerInitial(
        selectedRating: currentRating,
        comment: event.comment,
      ),
    );
  }

  Future<void> _onSubmitted(
    RateProducerSubmitted event,
    Emitter<RateProducerState> emit,
  ) async {
    emit(
      RateProducerSubmitting(
        selectedRating: event.rating,
        comment: event.comment,
      ),
    );
    try {
      await _rateProducer(event.orderId, event.rating, event.comment);
      emit(const RateProducerSuccess());
    } on Exception catch (e) {
      final message = e is ApiException ? e.message : e.toString();
      emit(
        RateProducerFailure(
          message,
          selectedRating: event.rating,
          comment: event.comment,
        ),
      );
    }
  }
}
