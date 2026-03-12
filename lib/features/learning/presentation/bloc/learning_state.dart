// 🍽️ PRESENTATION/BLOC — Os "estados" que o garçom (BLoC) comunica para a tela.
// A tela reage a cada estado: mostra loading, lista, ou erro.
// Sealed class: o BlocBuilder pode usar switch/if exaustivo.

import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/learning/domain/entities/product.dart';

sealed class LearningState extends Equatable {
  const LearningState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial — tela ainda não fez nenhum pedido
class LearningInitial extends LearningState {
  const LearningInitial();
}

/// Carregando — mostra spinner, desabilita interações
class LearningLoading extends LearningState {
  const LearningLoading();
}

/// Sucesso — temos a lista de produtos para mostrar
class LearningSuccess extends LearningState {
  const LearningSuccess(this.products);

  final List<Product> products;

  @override
  List<Object?> get props => [products];
}

/// Falha — algo deu errado, mostra mensagem + botão retry
class LearningFailure extends LearningState {
  const LearningFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
