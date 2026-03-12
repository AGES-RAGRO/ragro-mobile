// 🍽️ PRESENTATION/BLOC — Os "pedidos" que o cliente (tela) faz ao garçom (BLoC).
// Cada evento representa uma ação do usuário.
// Sealed class: só as subclasses definidas aqui existem (o compilador garante).
// Extends Equatable: permite comparar eventos por valor.

import 'package:equatable/equatable.dart';

sealed class LearningEvent extends Equatable {
  const LearningEvent();

  @override
  List<Object?> get props => [];
}

/// Evento disparado quando a tela carrega ou quando o usuário toca "Tentar novamente"
class LearningProductsRequested extends LearningEvent {
  const LearningProductsRequested();
}
