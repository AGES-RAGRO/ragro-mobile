import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/shared/utils/unity_type_label.dart';

/// Base form shared by the stock entry/exit pages: product header, quantity
/// input, optional reason dropdown, notes field and submit button.
///
/// Each page configures texts, colors, allowed reasons and validation limits,
/// and receives the parsed values via [onSubmit].
class StockMovementForm extends StatefulWidget {
  const StockMovementForm({
    required this.title,
    required this.productName,
    required this.unit,
    required this.accentColor,
    required this.notesHint,
    required this.submitLabel,
    required this.submitColor,
    required this.isLoading,
    required this.onSubmit,
    this.productSubtitle,
    this.maxQuantity,
    this.maxQuantityMessage,
    this.reasons = const [],
    super.key,
  });

  /// App bar title (e.g. `Registrar Entrada`).
  final String title;

  final String productName;

  /// Raw unity type, localized for the quantity suffix.
  final String unit;

  /// Color of the product header card (icon + name).
  final Color accentColor;

  /// Optional second line in the product header (e.g. `Saldo atual: ...`).
  final String? productSubtitle;

  final String notesHint;

  final String submitLabel;

  final Color submitColor;

  final bool isLoading;

  /// Upper bound for the quantity; when exceeded [maxQuantityMessage] is
  /// shown. Null disables the check.
  final double? maxQuantity;

  final String? maxQuantityMessage;

  /// Allowed movement reasons as (value, label) pairs; empty hides the
  /// dropdown and [onSubmit] receives a null reason.
  final List<(String, String)> reasons;

  /// Called with the parsed quantity, the selected reason (null when
  /// [reasons] is empty) and the trimmed notes (null when blank).
  final void Function(double quantity, String? reason, String? notes) onSubmit;

  @override
  State<StockMovementForm> createState() => _StockMovementFormState();
}

class _StockMovementFormState extends State<StockMovementForm> {
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedReason;

  @override
  void initState() {
    super.initState();
    if (widget.reasons.isNotEmpty) {
      _selectedReason = widget.reasons.first.$1;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final qtyText = _quantityController.text.trim().replaceAll(',', '.');
    final qty = double.tryParse(qtyText);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe uma quantidade válida.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    final maxQuantity = widget.maxQuantity;
    if (maxQuantity != null && qty > maxQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.maxQuantityMessage ?? ''),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    final notes = _notesController.text.trim();
    widget.onSubmit(qty, _selectedReason, notes.isEmpty ? null : notes);
  }

  InputDecoration _fieldDecoration({String? hintText, String? suffixText}) {
    return InputDecoration(
      hintText: hintText,
      suffixText: suffixText,
      hintStyle: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 15,
        color: AppColors.placeholder,
      ),
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

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.isLoading;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductHeader(
              productName: widget.productName,
              subtitle: widget.productSubtitle,
              accentColor: widget.accentColor,
            ),

            const SizedBox(height: 24),

            const _FieldLabel('Quantidade'),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9,.]')),
              ],
              enabled: !isLoading,
              decoration: _fieldDecoration(
                hintText: '0',
                suffixText: localizeUnityType(widget.unit),
              ),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                color: AppColors.black,
              ),
            ),

            if (widget.reasons.isNotEmpty) ...[
              const SizedBox(height: 16),

              const _FieldLabel('Motivo'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: DropdownButton<String>(
                  value: _selectedReason,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: widget.reasons
                      .map(
                        (r) => DropdownMenuItem(
                          value: r.$1,
                          child: Text(
                            r.$2,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 15,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: isLoading
                      ? null
                      : (val) {
                          if (val != null) {
                            setState(() => _selectedReason = val);
                          }
                        },
                ),
              ),
            ],

            const SizedBox(height: 16),

            const _FieldLabel('Observações (opcional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              maxLength: 500,
              enabled: !isLoading,
              decoration: _fieldDecoration(hintText: widget.notesHint),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                color: AppColors.black,
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _submit(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.submitColor,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: widget.submitColor.withValues(
                    alpha: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        widget.submitLabel,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  const _ProductHeader({
    required this.productName,
    required this.subtitle,
    required this.accentColor,
  });

  final String productName;
  final String? subtitle;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final name = Text(
      productName,
      style: TextStyle(
        fontFamily: 'Figtree',
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: accentColor,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.eco_outlined, color: accentColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: subtitle == null
                ? name
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      name,
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          color: accentColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppColors.black,
      ),
    );
  }
}
