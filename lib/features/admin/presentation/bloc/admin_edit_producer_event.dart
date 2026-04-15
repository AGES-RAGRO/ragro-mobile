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
    required this.number,
    required this.state,
    required this.cpfCnpj,
    required this.city,
    required this.farmName,
    required this.description,
    required this.scheduleWeekdays,
    required this.scheduleStart,
    required this.scheduleEnd,
    this.neighborhood,
    // ── PIX (opcional no update — partial) ──────────────────────────────
    this.pixKeyType,
    this.pixKey,
    // ── Conta Bancária (opcional no update — partial) ────────────────────
    this.bankName,
    this.bankCode,
    this.agency,
    this.accountNumber,
    this.accountType,
    this.accountHolder,
    this.bankFiscalNumber,
  });

  final String name;
  final String email;
  final String phone;
  final String cep;
  final String address;
  final String number;
  final String city;
  final String state;
  final String? neighborhood;
  final String cpfCnpj;
  final String farmName;
  final String description;
  final List<bool> scheduleWeekdays;
  final String scheduleStart;
  final String scheduleEnd;

  // PIX (opcional no update)
  final String? pixKeyType;
  final String? pixKey;

  // Conta Bancária (opcional no update)
  final String? bankName;
  final String? bankCode;
  final String? agency;
  final String? accountNumber;
  final String? accountType;
  final String? accountHolder;
  final String? bankFiscalNumber;

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    address,
    number,
    city,
    state,
    cpfCnpj,
    farmName,
    description,
    pixKeyType,
    pixKey,
    bankName,
    agency,
    accountNumber,
    accountType,
    accountHolder,
  ];
}
