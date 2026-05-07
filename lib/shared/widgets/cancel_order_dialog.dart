import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

const _customerReasons = [
  'Não consigo receber o pedido',
  'Demorou mais do que o esperado',
  'Informei o endereço errado',
  'Mudei de ideia',
  'Problema no pagamento',
  'Outro',
];

const _producerReasons = [
  'Estoque insuficiente',
  'Endereço inválido',
  'Tempo de entrega muito grande',
  'Sem contato com cliente',
  'Cliente solicitou cancelamento',
  'Problema no pagamento',
  'Outro',
];

typedef CancelResult = ({String reason, String? details});

class CancelOrderDialog extends StatefulWidget {
  const CancelOrderDialog._({required this.reasons});

  final List<String> reasons;

  static Future<CancelResult?> showForCustomer(BuildContext context) =>
      _show(context, _customerReasons);

  static Future<CancelResult?> showForProducer(BuildContext context) =>
      _show(context, _producerReasons);

  static Future<CancelResult?> _show(
    BuildContext context,
    List<String> reasons,
  ) {
    return showDialog<CancelResult>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => CancelOrderDialog._(reasons: reasons),
    );
  }

  @override
  State<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  String? _selectedReason;
  final _detailsController = TextEditingController();

  bool get _isOther => _selectedReason == 'Outro';

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedReason == null) return;
    final details = _isOther && _detailsController.text.trim().isNotEmpty
        ? _detailsController.text.trim()
        : null;
    Navigator.of(context).pop<CancelResult>(
      (reason: _selectedReason!, details: details),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 28,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Cancelar Pedido',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Motivo do Cancelamento',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _ReasonDropdown(
              reasons: widget.reasons,
              selected: _selectedReason,
              onChanged: (value) => setState(() {
                _selectedReason = value;
                if (value != 'Outro') _detailsController.clear();
              }),
            ),
            if (_isOther) ...[
              const SizedBox(height: 16),
              const Text(
                'Detalhes',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _detailsController,
                maxLines: 3,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: AppColors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Detalhes do cancelamento',
                  hintStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: AppColors.placeholder,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.darkGreen),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
            const SizedBox(height: 24),
            _DialogButton(
              label: 'Confirmar cancelamento',
              color: _selectedReason != null
                  ? AppColors.darkGreen
                  : AppColors.darkGreen.withValues(alpha: 0.5),
              textColor: AppColors.white,
              onTap: _selectedReason != null ? _submit : null,
            ),
            const SizedBox(height: 10),
            _DialogButton(
              label: 'Voltar',
              color: AppColors.white,
              textColor: AppColors.black,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonDropdown extends StatefulWidget {
  const _ReasonDropdown({
    required this.reasons,
    required this.selected,
    required this.onChanged,
  });

  final List<String> reasons;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  State<_ReasonDropdown> createState() => _ReasonDropdownState();
}

class _ReasonDropdownState extends State<_ReasonDropdown> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isOpen = !_isOpen),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(_isOpen ? 0 : 12),
                bottomRight: Radius.circular(_isOpen ? 0 : 12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.selected ?? 'Selecione um motivo',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      color: widget.selected != null
                          ? AppColors.black
                          : AppColors.placeholder,
                    ),
                  ),
                ),
                Icon(
                  _isOpen ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.placeholder,
                ),
              ],
            ),
          ),
        ),
        if (_isOpen)
          Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFFE2E8F0)),
                right: BorderSide(color: Color(0xFFE2E8F0)),
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: widget.reasons.asMap().entries.map((entry) {
                final isLast = entry.key == widget.reasons.length - 1;
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        widget.onChanged(entry.value);
                        setState(() => _isOpen = false);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.border,
  });

  final String label;
  final Color color;
  final Color textColor;
  final BoxBorder? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: border,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
