import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';

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
  final List<AdminProducer> producers;
  @override
  List<Object?> get props => [producers];
}

/// State emitted while an activate/deactivate mutation is in-flight.
/// Preserves the previous list so the UI can keep rendering it with
/// a loading overlay instead of going blank.
class AdminProducersMutating extends AdminProducersState {
  const AdminProducersMutating(this.previousProducers);
  final List<AdminProducer> previousProducers;
  @override
  List<Object?> get props => [previousProducers];
}

class AdminProducersFailure extends AdminProducersState {
  const AdminProducersFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

/// Mutation failure that preserves the list that was loaded before the
/// failed mutation, so the UI can surface a snackbar without wiping
/// the screen.
class AdminProducerMutationFailure extends AdminProducersState {
  const AdminProducerMutationFailure({
    required this.previousProducers,
    required this.message,
  });
  final List<AdminProducer> previousProducers;
  final String message;
  @override
  List<Object?> get props => [previousProducers, message];
}
