import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

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


    required this.farmName,
  });

  final String producerId;
  final String name;
  final String story;
  final String phone;
  final String farmName;

  @override
  List<Object?> get props => [producerId, name, story, phone, farmName];
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
