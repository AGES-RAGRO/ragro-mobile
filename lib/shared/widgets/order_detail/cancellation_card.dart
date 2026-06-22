import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

/// Cancellation reason card shared by the order detail screens.
///
/// The customer and producer screens keep their original (slightly different)
/// title texts and typography, so each one has a named constructor.
class CancellationCard extends StatelessWidget {
  /// Customer layout: red `Motivo` title, reason in black, details muted.
  const CancellationCard.customer({
    required this.reason,
    this.details,
    super.key,
  }) : _isCustomer = true;

  /// Producer layout: black `Motivo do cancelamento` title, reason in red.
  const CancellationCard.producer({
    required this.reason,
    this.details,
    super.key,
  }) : _isCustomer = false;

  /// Display-ready reason text (from the cancel dialog or backend).
  final String reason;

  final String? details;

  final bool _isCustomer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_outlined, size: 20, color: AppColors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _isCustomer ? _customerContent() : _producerContent(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _customerContent() {
    return [
      const Text(
        'Motivo',
        style: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.red,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        reason,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 14,
          color: AppColors.black,
        ),
      ),
      if (details != null && details!.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(
          details!,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            color: AppColors.placeholder,
          ),
        ),
      ],
    ];
  }

  List<Widget> _producerContent() {
    return [
      const Text(
        'Motivo do cancelamento',
        style: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.black,
        ),
      ),
      const SizedBox(height: 6),
      if (reason.isNotEmpty)
        Text(
          reason,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            color: AppColors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      if (details != null && details!.isNotEmpty) ...[
        const SizedBox(height: 4),
        Text(
          details!,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            color: AppColors.black,
          ),
        ),
      ],
    ];
  }
}
