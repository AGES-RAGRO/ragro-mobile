import 'package:equatable/equatable.dart';

sealed class AdminProducersEvent extends Equatable {
  const AdminProducersEvent();
  @override
  List<Object?> get props => [];
}

class AdminProducersStarted extends AdminProducersEvent {
  const AdminProducersStarted();
}

class AdminProducerDeactivated extends AdminProducersEvent {
  const AdminProducerDeactivated(this.producerId);
  final String producerId;
  @override
  List<Object?> get props => [producerId];
}

class AdminProducerActivated extends AdminProducersEvent {
  const AdminProducerActivated(this.producerId);
  final String producerId;
  @override
  List<Object?> get props => [producerId];
}


class AdminProducersRefreshed extends AdminProducersEvent {
  const AdminProducersRefreshed();
}
