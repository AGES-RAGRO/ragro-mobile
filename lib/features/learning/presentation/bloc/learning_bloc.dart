// 🍽️ PRESENTATION/BLOC — O "garçom" do restaurante.
// Recebe eventos (pedidos) da tela, chama o UseCase (cozinha), e emite estados (respostas).
//
// @injectable: o injectable cria uma instância NOVA do BLoC toda vez que alguém pedir.
// Isso é importante porque o BLoC tem estado interno — cada tela precisa do seu próprio BLoC.
//
// Fluxo:
// 1. Tela dispara LearningProductsRequested
// 2. BLoC emite LearningLoading (mostra spinner)
// 3. BLoC chama GetProducts (UseCase)
// 4. Se deu certo → emite LearningSuccess(products)
// 5. Se deu erro → emite LearningFailure(mensagem)

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
