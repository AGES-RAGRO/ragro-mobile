import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ragro_mobile/core/formatters/input_masks.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';
import 'package:ragro_mobile/features/producer_profile/domain/entities/public_producer.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/pix_mask.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/weekday_mapper.dart';

/// Strips every non-digit character.
String digitsOnly(String v) => v.replaceAll(RegExp(r'\D'), '');

/// The [TextEditingController]s (plus pix key type and weekday selection)
/// shared by the producer form pages: admin create producer, admin edit
/// producer and producer edit profile.
class ProducerFormControllers {
  // Personal data
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final fiscal = TextEditingController();
  final farmName = TextEditingController();
  final description = TextEditingController();

  // Address
  final cep = TextEditingController();
  final address = TextEditingController();
  final number = TextEditingController();
  final neighborhood = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();

  // PIX
  String? pixKeyType;
  final pixKey = TextEditingController();

  // Bank account
  final bankName = TextEditingController();
  final bankCode = TextEditingController();
  final agency = TextEditingController();
  final account = TextEditingController();
  final holder = TextEditingController();
  final bankFiscal = TextEditingController();

  // Business hours: a single open/close window applied to the selected
  // weekdays (UI order: 0=Mon..6=Sun).
  final scheduleStart = TextEditingController();
  final scheduleEnd = TextEditingController();
  final List<bool> weekdays = List.filled(7, false);

  /// True when the four required bank-account fields are filled. The edit
  /// flows only send the bank account when this holds.
  bool get hasCompleteBank =>
      bankName.text.trim().isNotEmpty &&
      agency.text.trim().isNotEmpty &&
      account.text.trim().isNotEmpty &&
      holder.text.trim().isNotEmpty;

  void disposeAll() {
    name.dispose();
    phone.dispose();
    email.dispose();
    fiscal.dispose();
    farmName.dispose();
    description.dispose();
    cep.dispose();
    address.dispose();
    number.dispose();
    neighborhood.dispose();
    city.dispose();
    state.dispose();
    pixKey.dispose();
    bankName.dispose();
    bankCode.dispose();
    agency.dispose();
    account.dispose();
    holder.dispose();
    bankFiscal.dispose();
    scheduleStart.dispose();
    scheduleEnd.dispose();
  }

  /// Pre-fills the controllers from an [AdminProducer] (admin edit flow).
  void hydrateFromAdminProducer(AdminProducer producer) {
    name.text = producer.name;
    phone.text = _applyMask(producer.phone, PhoneInputFormatter());
    email.text = producer.email;
    fiscal.text = _applyMask(
      producer.fiscalNumber,
      FiscalNumberInputFormatter(),
    );
    farmName.text = producer.farmName;
    description.text = producer.description;
    cep.text = _applyMask(
      producer.producerAddress?.zipCode ?? '',
      CepInputFormatter(),
    );
    address.text = producer.producerAddress?.street ?? '';
    number.text = producer.producerAddress?.number ?? '';
    neighborhood.text = producer.producerAddress?.neighborhood ?? '';
    city.text = producer.producerAddress?.city ?? '';
    state.text = producer.producerAddress?.state ?? '';

    final pix = producer.paymentMethods
        ?.where((pm) => pm.type == 'pix')
        .firstOrNull;
    if (pix != null) {
      _hydratePix(pix.pixKeyType, pix.pixKey);
    }

    final bank = producer.paymentMethods
        ?.where((pm) => pm.type == 'bank_account')
        .firstOrNull;
    if (bank != null) {
      _hydrateBank(
        bankName: bank.bankName,
        bankCode: bank.bankCode,
        agency: bank.agency,
        accountNumber: bank.accountNumber,
        holderName: bank.holderName,
        fiscalNumber: bank.fiscalNumber,
      );
    }

    scheduleStart.text = producer.availability?.firstOrNull?.opensAt ?? '';
    scheduleEnd.text = producer.availability?.firstOrNull?.closesAt ?? '';
    for (var i = 0; i < 7; i++) {
      weekdays[i] = false;
    }
    if (producer.availability != null) {
      for (final slot in producer.availability!) {
        final uiIndex = WeekdayMapper.toUi(slot.weekday);
        if (uiIndex >= 0 && uiIndex < 7) weekdays[uiIndex] = true;
      }
    }
  }

  /// Pre-fills the controllers from a [PublicProducer] (producer edit
  /// profile flow). Falls back to the 08:00-18:00 window when the producer
  /// has no availability configured.
  void hydrateFromPublicProducer(PublicProducer producer) {
    name.text = producer.name;
    description.text = producer.description;
    phone.text = _applyMask(producer.phone, PhoneInputFormatter());
    farmName.text = producer.farmName;

    if (producer.producerAddress != null) {
      final addr = producer.producerAddress!;
      cep.text = _applyMask(addr.zipCode, CepInputFormatter());
      address.text = addr.street;
      number.text = addr.number;
      neighborhood.text = addr.neighborhood ?? '';
      city.text = addr.city;
      state.text = addr.state;
    }

    if (producer.paymentMethods != null) {
      final pix = producer.paymentMethods!
          .where((pm) => pm.type == 'pix')
          .firstOrNull;
      if (pix != null) {
        _hydratePix(pix.pixKeyType, pix.pixKey);
      }

      final bank = producer.paymentMethods!
          .where((pm) => pm.type == 'bank_account')
          .firstOrNull;
      if (bank != null) {
        _hydrateBank(
          bankName: bank.bankName,
          bankCode: bank.bankCode,
          agency: bank.agency,
          accountNumber: bank.accountNumber,
          holderName: bank.holderName,
          fiscalNumber: bank.fiscalNumber,
        );
      }
    }

    if (producer.availability.isNotEmpty) {
      scheduleStart.text = producer.availability.first.opensAt;
      scheduleEnd.text = producer.availability.first.closesAt;
      for (var i = 0; i < 7; i++) {
        weekdays[i] = false;
      }
      for (final slot in producer.availability) {
        final uiIndex = WeekdayMapper.toUi(slot.weekday);
        if (uiIndex >= 0 && uiIndex < 7) weekdays[uiIndex] = true;
      }
    } else {
      scheduleStart.text = '08:00';
      scheduleEnd.text = '18:00';
    }
  }

  void _hydratePix(String? type, String? key) {
    pixKeyType = type;
    final mask = pixMaskFor(type);
    pixKey.text = mask != null ? _applyMask(key ?? '', mask) : (key ?? '');
  }

  void _hydrateBank({
    String? bankName,
    String? bankCode,
    String? agency,
    String? accountNumber,
    String? holderName,
    String? fiscalNumber,
  }) {
    this.bankName.text = bankName ?? '';
    this.bankCode.text = bankCode ?? '';
    this.agency.text = agency ?? '';
    account.text = _applyMask(accountNumber ?? '', BankAccountInputFormatter());
    holder.text = holderName ?? '';
    bankFiscal.text = _applyMask(
      fiscalNumber ?? '',
      FiscalNumberInputFormatter(),
    );
  }

  String _applyMask(String val, TextInputFormatter formatter) {
    if (val.isEmpty) return val;
    return formatter
        .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: val))
        .text;
  }
}
