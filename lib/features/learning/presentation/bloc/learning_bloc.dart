// Receives events from the screen, calls the GetProducts use case, and emits
// loading/success/failure states.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/learning/domain/usecases/get_products.dart';
import 'package:ragro_mobile/features/learning/presentation/bloc/learning_event.dart';
import 'package:ragro_mobile/features/learning/presentation/bloc/learning_state.dart';

@injectable
class LearningBloc extends Bloc<LearningEvent, LearningState> {
  LearningBloc(this._getProducts) : super(const LearningInitial()) {
    on<LearningProductsRequested>(_onProductsRequested);
  }

  final GetProducts _getProducts;

  Future<void> _onProductsRequested(
    LearningProductsRequested event,
    Emitter<LearningState> emit,
  ) async {
    emit(const LearningLoading());

    try {
      final products = await _getProducts();
      emit(LearningSuccess(products));
    } on Exception catch (e) {
      emit(LearningFailure(e.toString()));
    }
  }
}
