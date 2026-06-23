import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ragro_mobile/core/formatters/input_masks.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/field_label.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/pix_mask.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/producer_form_controllers.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/producer_text_field.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/uppercase_formatter.dart';

/// Pix key types accepted by the backend, in dropdown order.
const kPixKeyTypes = ['cpf', 'cnpj', 'email', 'phone', 'random'];

/// User-facing labels for [kPixKeyTypes].
const kPixKeyTypeLabels = {
  'cpf': 'CPF',
  'cnpj': 'CNPJ',
  'email': 'E-mail',
  'phone': 'Telefone',
  'random': 'Chave aleatória',
};

/// Address block of the producer forms: CEP, street + number, neighborhood
/// and city + UF. Layout is shared; each page passes its own validators so
/// the (diverging) messages and required rules stay with the page.
class AddressFields extends StatelessWidget {
  const AddressFields({
    required this.controllers,
    super.key,
    this.enabled = true,
    this.autovalidateMode,
    this.cepValidator,
    this.streetValidator,
    this.numberValidator,
    this.neighborhoodValidator,
    this.cityValidator,
    this.stateValidator,
    this.statePrefixIcon,
  });

  final ProducerFormControllers controllers;
  final bool enabled;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? cepValidator;
  final String? Function(String?)? streetValidator;
  final String? Function(String?)? numberValidator;
  final String? Function(String?)? neighborhoodValidator;
  final String? Function(String?)? cityValidator;
  final String? Function(String?)? stateValidator;
  final IconData? statePrefixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('CEP'),
        const SizedBox(height: 8),
        ProducerTextField(
          controller: controllers.cep,
          hint: '00000-000',
          prefixIcon: Icons.location_on_outlined,
          keyboardType: TextInputType.number,
          enabled: enabled,
          autovalidateMode: autovalidateMode,
          inputFormatters: [CepInputFormatter()],
          validator: cepValidator,
        ),
        const SizedBox(height: 12),
        const FieldLabel('Endereço'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: ProducerTextField(
                controller: controllers.address,
                hint: 'Rua / Avenida',
                prefixIcon: Icons.location_on_outlined,
                enabled: enabled,
                autovalidateMode: autovalidateMode,
                validator: streetValidator,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ProducerTextField(
                controller: controllers.number,
                hint: 'Nº',
                keyboardType: TextInputType.number,
                enabled: enabled,
                autovalidateMode: autovalidateMode,
                validator: numberValidator,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const FieldLabel('Bairro'),
        const SizedBox(height: 8),
        ProducerTextField(
          controller: controllers.neighborhood,
          hint: 'Bairro',
          prefixIcon: Icons.map_outlined,
          enabled: enabled,
          autovalidateMode: autovalidateMode,
          validator: neighborhoodValidator,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel('Cidade'),
                  const SizedBox(height: 8),
                  ProducerTextField(
                    controller: controllers.city,
                    hint: 'Cidade',
                    prefixIcon: Icons.location_city_outlined,
                    enabled: enabled,
                    autovalidateMode: autovalidateMode,
                    validator: cityValidator,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel('Estado'),
                  const SizedBox(height: 8),
                  // Intentionally not wired to [enabled]: none of the
                  // original pages disabled the UF field while busy.
                  ProducerTextField(
                    controller: controllers.state,
                    hint: 'UF',
                    prefixIcon: statePrefixIcon,
                    autovalidateMode: autovalidateMode,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(2),
                      UppercaseFormatter(),
                    ],
                    validator: stateValidator,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// "Chave PIX" card: key-type dropdown plus the masked key field shown once
/// a type is selected.
class PixSectionCard extends StatelessWidget {
  const PixSectionCard({
    required this.pixKeyType,
    required this.dropdownValue,
    required this.pixKeyController,
    required this.keyFormatters,
    required this.onTypeChanged,
    super.key,
    this.typeLabel = 'Tipo da chave',
    this.dropdownHint = 'Selecione',
    this.itemTextStyle,
    this.randomKeyHint = 'Chave aleatória',
    this.dropdownEnabled = true,
    this.fieldEnabled = true,
    this.autovalidateMode,
  });

  /// Currently selected key type; controls the key-field visibility and mask.
  final String? pixKeyType;

  /// Value handed to the dropdown (pages may sanitize unknown types).
  final String? dropdownValue;
  final TextEditingController pixKeyController;
  final List<TextInputFormatter> keyFormatters;
  final ValueChanged<String?> onTypeChanged;
  final String typeLabel;
  final String dropdownHint;
  final TextStyle? itemTextStyle;
  final String randomKeyHint;
  final bool dropdownEnabled;
  final bool fieldEnabled;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.inputBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chave PIX',
              style: TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 12),
            FieldLabel(typeLabel),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: dropdownValue,
              decoration: _dropdownDecoration(),
              hint: Text(
                dropdownHint,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  color: AppColors.placeholder,
                ),
              ),
              items: kPixKeyTypes
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        kPixKeyTypeLabels[t] ?? t,
                        style: itemTextStyle,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: dropdownEnabled ? onTypeChanged : null,
            ),
            if (pixKeyType != null) ...[
              const SizedBox(height: 12),
              const FieldLabel('Chave Pix'),
              const SizedBox(height: 8),
              ProducerTextField(
                key: ValueKey(pixKeyType),
                controller: pixKeyController,
                hint: pixKeyHint(pixKeyType!, randomHint: randomKeyHint),
                keyboardType: pixKeyboardType(pixKeyType!),
                enabled: fieldEnabled,
                autovalidateMode: autovalidateMode,
                inputFormatters: keyFormatters,
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkGreen, width: 1.5),
      ),
    );
  }
}

/// "Conta Bancária" card: bank, code + agency, account, holder and holder
/// fiscal number.
class BankSectionCard extends StatelessWidget {
  const BankSectionCard({
    required this.controllers,
    super.key,
    this.enabled = true,
    this.codeLabel = 'Código (3 dígitos)',
    this.fiscalLabel = 'CPF / CNPJ do Titular (opcional)',
    this.agencyFormatters,
    this.autovalidateMode,
  });

  final ProducerFormControllers controllers;
  final bool enabled;
  final String codeLabel;
  final String fiscalLabel;
  final List<TextInputFormatter>? agencyFormatters;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.inputBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conta Bancária',
              style: TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 12),
            const FieldLabel('Banco'),
            const SizedBox(height: 8),
            ProducerTextField(
              controller: controllers.bankName,
              hint: 'Nome do banco',
              prefixIcon: Icons.account_balance_outlined,
              enabled: enabled,
              autovalidateMode: autovalidateMode,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FieldLabel(codeLabel),
                      const SizedBox(height: 8),
                      ProducerTextField(
                        controller: controllers.bankCode,
                        hint: '001',
                        keyboardType: TextInputType.number,
                        enabled: enabled,
                        autovalidateMode: autovalidateMode,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(3),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Agência'),
                      const SizedBox(height: 8),
                      ProducerTextField(
                        controller: controllers.agency,
                        hint: '0000',
                        keyboardType: TextInputType.number,
                        enabled: enabled,
                        autovalidateMode: autovalidateMode,
                        inputFormatters: agencyFormatters,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const FieldLabel('Conta'),
            const SizedBox(height: 8),
            ProducerTextField(
              controller: controllers.account,
              hint: '000000-0',
              enabled: enabled,
              keyboardType: TextInputType.number,
              autovalidateMode: autovalidateMode,
              inputFormatters: [BankAccountInputFormatter()],
            ),
            const SizedBox(height: 12),
            const FieldLabel('Titular'),
            const SizedBox(height: 8),
            ProducerTextField(
              controller: controllers.holder,
              hint: 'Nome completo do titular',
              prefixIcon: Icons.account_circle_outlined,
              enabled: enabled,
              autovalidateMode: autovalidateMode,
            ),
            const SizedBox(height: 12),
            FieldLabel(fiscalLabel),
            const SizedBox(height: 8),
            ProducerTextField(
              controller: controllers.bankFiscal,
              hint: '000.000.000-00',
              prefixIcon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              enabled: enabled,
              autovalidateMode: autovalidateMode,
              inputFormatters: [FiscalNumberInputFormatter()],
            ),
          ],
        ),
      ),
    );
  }
}

/// Seg..Dom weekday chips (UI order: 0=Mon..6=Sun).
class WeekdaySelector extends StatelessWidget {
  const WeekdaySelector({
    required this.selected,
    required this.onToggle,
    super.key,
    this.enabled = true,
    this.runSpacing = 0,
  });

  final List<bool> selected;
  final ValueChanged<int> onToggle;
  final bool enabled;
  final double runSpacing;

  static const _weekdayLabels = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: runSpacing,
      children: List.generate(7, (i) {
        final isSelected = selected[i];
        return GestureDetector(
          onTap: enabled ? () => onToggle(i) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.darkGreen
                  : AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _weekdayLabels[i],
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isSelected ? AppColors.white : AppColors.placeholder,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// "Início -> Fim" schedule row used by the admin producer forms.
class ScheduleHoursRow extends StatelessWidget {
  const ScheduleHoursRow({
    required this.startController,
    required this.endController,
    super.key,
    this.enabled = true,
  });

  final TextEditingController startController;
  final TextEditingController endController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FieldLabel('Início'),
              const SizedBox(height: 8),
              ProducerTextField(
                controller: startController,
                hint: '08:00',
                prefixIcon: Icons.schedule_outlined,
                keyboardType: TextInputType.datetime,
                enabled: enabled,
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 28, left: 12, right: 12),
          child: Icon(
            Icons.arrow_forward,
            color: AppColors.placeholder,
            size: 18,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FieldLabel('Fim'),
              const SizedBox(height: 8),
              ProducerTextField(
                controller: endController,
                hint: '18:00',
                prefixIcon: Icons.schedule_outlined,
                keyboardType: TextInputType.datetime,
                enabled: enabled,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Full-width green submit button with the shared busy spinner.
class ProducerFormSubmitButton extends StatelessWidget {
  const ProducerFormSubmitButton({
    required this.label,
    required this.busy,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkGreen,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.darkGreen.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: busy
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
