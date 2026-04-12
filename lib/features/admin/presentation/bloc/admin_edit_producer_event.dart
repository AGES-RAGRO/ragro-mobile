import 'package:equatable/equatable.dart';

sealed class AdminEditProducerEvent extends Equatable {
  const AdminEditProducerEvent();
  @override
  List<Object?> get props => [];
}

class AdminEditProducerLoadRequested extends AdminEditProducerEvent {
  const AdminEditProducerLoadRequested(this.producerId);
  final String producerId;
  @override
  List<Object?> get props => [producerId];
}

class AdminEditProducerSubmitted extends AdminEditProducerEvent {
  const AdminEditProducerSubmitted({
    required this.name,
    required this.email,
    required this.phone,
    required this.cep,
    required this.address,
    required this.city,
    required this.state,
    required this.bank,
    required this.agency,
    required this.account,
    required this.accountHolder,
    required this.cpfCnpj,
    required this.scheduleWeekdays,
    required this.scheduleStart,
    required this.scheduleEnd,
  });

  final String name;
  final String email;
  final String phone;
  final String cep;
  final String address;
  final String city;
  final String state;
  final String bank;
  final String agency;
  final String account;
  final String accountHolder;
  final String cpfCnpj;
  final List<bool> scheduleWeekdays;
  final String scheduleStart;
  final String scheduleEnd;

  @override
  List<Object?> get props => [name, email, phone];
}
