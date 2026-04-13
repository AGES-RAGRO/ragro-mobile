import 'package:equatable/equatable.dart';

/// Representa um método de pagamento do produtor (pix ou bank_account).
/// Espelha o contrato do backend: POST /admin/producers → paymentMethods[].
class AdminPaymentMethod extends Equatable {
  const AdminPaymentMethod({
    required this.type,
    this.pixKeyType,
    this.pixKey,
    this.bankCode,
    this.bankName,
    this.agency,
    this.accountNumber,
    this.accountType,
    this.holderName,
    this.fiscalNumber,
  });

  /// 'pix' ou 'bank_account'
  final String type;

  // ── PIX ──────────────────────────────────────────────────────────────
  /// 'cpf' | 'cnpj' | 'email' | 'phone' | 'random'
  final String? pixKeyType;
  final String? pixKey;

  // ── Conta Bancária ────────────────────────────────────────────────────
  final String? bankCode;
  final String? bankName;
  final String? agency;
  final String? accountNumber;
  /// 'checking' | 'savings'
  final String? accountType;
  final String? holderName;
  final String? fiscalNumber;

  Map<String, dynamic> toJson() => {
    'type': type,
    if (pixKeyType != null) 'pixKeyType': pixKeyType,
    if (pixKey != null) 'pixKey': pixKey,
    if (bankCode != null) 'bankCode': bankCode,
    if (bankName != null) 'bankName': bankName,
    if (agency != null) 'agency': agency,
    if (accountNumber != null) 'accountNumber': accountNumber,
    if (accountType != null) 'accountType': accountType,
    if (holderName != null) 'holderName': holderName,
    if (fiscalNumber != null) 'fiscalNumber': fiscalNumber,
  };

  @override
  List<Object?> get props => [
    type, pixKeyType, pixKey, bankCode, bankName,
    agency, accountNumber, accountType, holderName, fiscalNumber,
  ];
}
