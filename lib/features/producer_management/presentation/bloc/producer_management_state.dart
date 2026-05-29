import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/producer_management/domain/entities/producer_dashboard.dart';

sealed class ProducerManagementState extends Equatable {
  const ProducerManagementState({
    required this.selectedMonth,
    required this.selectedYear,
  });

  final int selectedMonth;
  final int selectedYear;

  @override
  List<Object?> get props => [selectedMonth, selectedYear];
}

class ProducerManagementInitial extends ProducerManagementState {
  ProducerManagementInitial()
    : super(
        selectedMonth: DateTime.now().month,
        selectedYear: DateTime.now().year,
      );
}

class ProducerManagementLoading extends ProducerManagementState {
  const ProducerManagementLoading({
    required super.selectedMonth,
    required super.selectedYear,
  });
}

class ProducerManagementLoaded extends ProducerManagementState {
  const ProducerManagementLoaded(
    this.dashboard, {
    required super.selectedMonth,
    required super.selectedYear,
  });

  final ProducerDashboard dashboard;

  @override
  List<Object?> get props => [dashboard, selectedMonth, selectedYear];
}

class ProducerManagementFailure extends ProducerManagementState {
  const ProducerManagementFailure(
    this.message, {
    required super.selectedMonth,
    required super.selectedYear,
  });

  final String message;

  @override
  List<Object?> get props => [message, selectedMonth, selectedYear];
}
