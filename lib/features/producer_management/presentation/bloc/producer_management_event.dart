import 'package:equatable/equatable.dart';

sealed class ProducerManagementEvent extends Equatable {
  const ProducerManagementEvent();
  @override
  List<Object?> get props => [];
}

class ProducerManagementStarted extends ProducerManagementEvent {
  const ProducerManagementStarted();
}

class ProducerManagementRefreshed extends ProducerManagementEvent {
  const ProducerManagementRefreshed();
}
