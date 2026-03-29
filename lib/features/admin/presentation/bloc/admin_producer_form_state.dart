import 'package:equatable/equatable.dart';

sealed class AdminProducerFormState extends Equatable {
  const AdminProducerFormState();
  @override
  List<Object?> get props => [];
}

class AdminProducerFormInitial extends AdminProducerFormState {
  const AdminProducerFormInitial();
}

class AdminProducerFormLoading extends AdminProducerFormState {
  const AdminProducerFormLoading();
}

class AdminProducerFormSuccess extends AdminProducerFormState {
  const AdminProducerFormSuccess();
}

class AdminProducerFormFailure extends AdminProducerFormState {
  const AdminProducerFormFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
