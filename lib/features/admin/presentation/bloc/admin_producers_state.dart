import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer_summary.dart';

sealed class AdminProducersState extends Equatable {
  const AdminProducersState();
  @override
  List<Object?> get props => [];
}

class AdminProducersInitial extends AdminProducersState {
  const AdminProducersInitial();
}

class AdminProducersLoading extends AdminProducersState {
  const AdminProducersLoading();
}

class AdminProducersLoaded extends AdminProducersState {
  const AdminProducersLoaded(this.producers);
  final List<AdminProducerSummary> producers;
  @override
  List<Object?> get props => [producers];
}

class AdminProducersFailure extends AdminProducersState {
  const AdminProducersFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
