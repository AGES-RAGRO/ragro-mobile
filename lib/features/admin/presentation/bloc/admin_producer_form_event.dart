import 'package:equatable/equatable.dart';

sealed class AdminProducerFormEvent extends Equatable {
  const AdminProducerFormEvent();
  @override
  List<Object?> get props => [];
}

class AdminProducerFormSubmitted extends AdminProducerFormEvent {
  const AdminProducerFormSubmitted({
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
    required this.password,
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
  final String password;
  final List<bool> scheduleWeekdays;
  final String scheduleStart;
  final String scheduleEnd;

  @override
  List<Object?> get props => [name, email, phone];
}
