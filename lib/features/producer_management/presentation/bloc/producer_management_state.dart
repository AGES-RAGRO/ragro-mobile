import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/producer_management/domain/entities/producer_dashboard.dart';

sealed class ProducerManagementState extends Equatable {
  const ProducerManagementState();
  @override
  List<Object?> get props => [];
}

class ProducerManagementInitial extends ProducerManagementState {
  const ProducerManagementInitial();
}

class ProducerManagementLoading extends ProducerManagementState {
  const ProducerManagementLoading();
}

class ProducerManagementLoaded extends ProducerManagementState {
  const ProducerManagementLoaded(this.dashboard);
  final ProducerDashboard dashboard;
  @override
  List<Object?> get props => [dashboard];
}

class ProducerManagementFailure extends ProducerManagementState {
  const ProducerManagementFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
