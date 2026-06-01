// States the BLoC emits; sealed so the BlocBuilder switch can be exhaustive.

import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/learning/domain/entities/product.dart';

sealed class LearningState extends Equatable {
  const LearningState();

  @override
  List<Object?> get props => [];
}

class LearningInitial extends LearningState {
  const LearningInitial();
}

class LearningLoading extends LearningState {
  const LearningLoading();
}

class LearningSuccess extends LearningState {
  const LearningSuccess(this.products);

  final List<Product> products;

  @override
  List<Object?> get props => [products];
}

class LearningFailure extends LearningState {
  const LearningFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
