import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/producer_profile/domain/entities/public_producer.dart';

class AvailabilitySection extends StatelessWidget {
  const AvailabilitySection({required this.availability, super.key});

  final List<AvailabilitySlot> availability;

  static const List<String> weekdayShortNames = [
    'Dom',
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sab',
  ];

  String _getWeekdayShortName(int weekday) {
    if (weekday < 0 || weekday >= weekdayShortNames.length) {
      return '?';
    }
    return weekdayShortNames[weekday];
  }

  @override
  Widget build(BuildContext context) {
    if (availability.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 48,
                color: AppColors.darkGreen.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'Esse produtor não tem disponibilidade de atendimento',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppColors.darkGreen.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Order days for display (Mon -> Sun) and keep only those with a slot.
    final orderedWeekdays = [1, 2, 3, 4, 5, 6, 0]; // Mon..Sun
    final shownWeekdays = orderedWeekdays
        .where((d) => availability.any((s) => s.weekday == d))
        .toList();

    return Column(
      children: [
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, _) {
            return Row(
              children: shownWeekdays.map((weekday) {
                final matches = availability.where((s) => s.weekday == weekday);
                final slot = matches.first;

                return Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getWeekdayShortName(weekday),
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.darkGreen,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        slot.opensAt,
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 2,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.darkGreen.withValues(alpha: 0.25),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        slot.closesAt,
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
