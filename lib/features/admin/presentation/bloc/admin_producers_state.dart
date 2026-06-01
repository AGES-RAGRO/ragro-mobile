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

/// Activate/deactivate in flight; keeps the previous list so the UI can show a
/// loading overlay instead of going blank.
class AdminProducersMutating extends AdminProducersState {
  const AdminProducersMutating(this.previousProducers);
  final List<AdminProducerSummary> previousProducers;
  @override
  List<Object?> get props => [previousProducers];
}

class AdminProducersFailure extends AdminProducersState {
  const AdminProducersFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

/// Mutation failure that keeps the previously loaded list so the UI can show a
/// snackbar without wiping the screen.
class AdminProducerMutationFailure extends AdminProducersState {
  const AdminProducerMutationFailure({
    required this.previousProducers,
    required this.message,
  });
  final List<AdminProducerSummary> previousProducers;
  final String message;
  @override
  List<Object?> get props => [previousProducers, message];
}
