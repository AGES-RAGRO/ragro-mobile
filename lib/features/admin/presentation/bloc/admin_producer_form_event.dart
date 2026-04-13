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
    required this.number,
    required this.fiscalNumber,
    required this.fiscalNumberType,
    required this.farmName,
    required this.password,
    required this.scheduleWeekdays,
    required this.scheduleStart,
    required this.scheduleEnd,
    // ── PIX (obrigatório) ────────────────────────────────────────────────
    required this.pixKeyType,
    required this.pixKey,
    // ── Conta Bancária (obrigatória) ─────────────────────────────────────
    required this.bankName,
    required this.agency,
    required this.accountNumber,
    required this.accountType,
    required this.accountHolder,
    this.bankCode,
    this.bankFiscalNumber,
  });

  final String name;
  final String email;
  final String phone;
  final String cep;
  final String address;
  final String city;
  final String state;
  final String number;
  final String fiscalNumber;
  final String fiscalNumberType;
  final String farmName;
  final String password;
  final List<bool> scheduleWeekdays;
  final String scheduleStart;
  final String scheduleEnd;

  // PIX (obrigatório)
  final String pixKeyType;
  final String pixKey;

  // Conta Bancária (obrigatória)
  final String bankName;
  final String agency;
  final String accountNumber;
  final String accountType;
  final String accountHolder;
  final String? bankCode;
  final String? bankFiscalNumber;

  @override
  List<Object?> get props => [
    name, email, phone, address, city, state, number, password,
    fiscalNumber, fiscalNumberType, farmName,
    pixKeyType, pixKey, bankName, agency, accountNumber, accountType, accountHolder,
  ];
}
