import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

sealed class ProducerProfileEvent extends Equatable {
  const ProducerProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProducerProfileStarted extends ProducerProfileEvent {
  const ProducerProfileStarted(this.producerId, {this.isOwnerView = false});
  final String producerId;
  final bool isOwnerView;

  @override
  List<Object?> get props => [producerId, isOwnerView];
}

class ProducerProfileUpdateSubmitted extends ProducerProfileEvent {
  const ProducerProfileUpdateSubmitted({
    required this.producerId,
    required this.name,
    required this.description,
    required this.phone,
    required this.farmName,
    this.address,
    this.paymentMethods,
    this.availability,
  });

  final String producerId;
  final String name;
  final String description;
  final String phone;
  final String farmName;
  final Map<String, dynamic>? address;
  final List<Map<String, dynamic>>? paymentMethods;
  final List<Map<String, dynamic>>? availability;

  @override
  List<Object?> get props => [
    producerId,
    name,
    description,
    phone,
    farmName,
    address,
    paymentMethods,
    availability,
  ];
}

class ProducerAvatarPicked extends ProducerProfileEvent {
  const ProducerAvatarPicked(this.producerId, this.file);
  final String producerId;
  final XFile file;

  @override
  List<Object?> get props => [producerId, file.path];
}

class ProducerCoverPicked extends ProducerProfileEvent {
  const ProducerCoverPicked(this.producerId, this.file);
  final String producerId;
  final XFile file;

  @override
  List<Object?> get props => [producerId, file.path];
}
