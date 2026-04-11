import 'package:equatable/equatable.dart';

sealed class ProducerProfileEvent extends Equatable {
  const ProducerProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProducerProfileStarted extends ProducerProfileEvent {
  const ProducerProfileStarted(this.producerId);
  final String producerId;

  @override
  List<Object?> get props => [producerId];
}

class ProducerProfileUpdateSubmitted extends ProducerProfileEvent {
  const ProducerProfileUpdateSubmitted({
    required this.producerId,
    required this.name,
    required this.story,
    required this.phone,
    required this.location,
  });

  final String producerId;
  final String name;
  final String story;
  final String phone;
  final String location;

  @override
  List<Object?> get props => [producerId, name, story, phone, location];
}
