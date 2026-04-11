import 'package:equatable/equatable.dart';

sealed class ConsumerProfileEvent extends Equatable {
  const ConsumerProfileEvent();

  @override
  List<Object?> get props => [];
}

class ConsumerProfileStarted extends ConsumerProfileEvent {
  const ConsumerProfileStarted(this.userId);
  final String userId;

  @override
  List<Object?> get props => [userId];
}

class ConsumerProfileUpdateSubmitted extends ConsumerProfileEvent {
  const ConsumerProfileUpdateSubmitted({
    required this.name,
    required this.phone,
    required this.address,
    this.fiscalNumber,
  });

  final String name;
  final String phone;
  final String address;
  final String? fiscalNumber;

  @override
  List<Object?> get props => [name, phone, address, fiscalNumber];
}
