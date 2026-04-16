import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';

sealed class AdminEditProducerState extends Equatable {
  const AdminEditProducerState();
  @override
  List<Object?> get props => [];
}

class AdminEditProducerInitial extends AdminEditProducerState {
  const AdminEditProducerInitial();
}

class AdminEditProducerLoading extends AdminEditProducerState {
  const AdminEditProducerLoading();
}

class AdminEditProducerLoaded extends AdminEditProducerState {
  const AdminEditProducerLoaded(this.producer);
  final AdminProducer producer;
  @override
  List<Object?> get props => [producer];
}

class AdminEditProducerSaving extends AdminEditProducerState {
  const AdminEditProducerSaving();
}

class AdminEditProducerSuccess extends AdminEditProducerState {
  const AdminEditProducerSuccess();
}

class AdminEditProducerFailure extends AdminEditProducerState {
  const AdminEditProducerFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
