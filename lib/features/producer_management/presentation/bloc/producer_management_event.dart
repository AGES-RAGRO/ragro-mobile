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

class ProducerDashboardPeriodChanged extends ProducerManagementEvent {
  const ProducerDashboardPeriodChanged({
    required this.month,
    required this.year,
  });

  final int month;
  final int year;

  @override
  List<Object?> get props => [month, year];
}
