import 'package:equatable/equatable.dart';

class AdminBankAccount extends Equatable {
  const AdminBankAccount({
    required this.bankName,
    required this.agency,
    required this.accountNumber,
    required this.holderName,
    required this.fiscalNumber,
    this.bankCode,
  });

  final String bankName;
  final String agency;
  final String accountNumber;
  final String holderName;
  final String fiscalNumber;
  final String? bankCode;

  Map<String, dynamic> toJson() => {
    'bankName': bankName,
    'agency': agency,
    'accountNumber': accountNumber,
    'holderName': holderName,
    'fiscalNumber': fiscalNumber.replaceAll(RegExp(r'\D'), ''),
    if (bankCode != null) 'bankCode': bankCode,
  };

  @override
  List<Object?> get props => [
    bankName,
    agency,
    accountNumber,
    holderName,
    fiscalNumber,
  ];
}
