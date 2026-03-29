import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/home/domain/entities/producer.dart';
import 'package:ragro_mobile/features/home/presentation/widgets/producer_card.dart';

class ProducersSection extends StatelessWidget {
  const ProducersSection({
    super.key,
    required this.producers,
    required this.onProducerTap,
  });

  final List<Producer> producers;
  final void Function(Producer) onProducerTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            'Produtores',
            style: TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w600,
              fontSize: 22,
              color: AppColors.black,
            ),
          ),
        ),
        SizedBox(
          height: 282,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: producers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) => ProducerCard(
              producer: producers[index],
              onTap: () => onProducerTap(producers[index]),
            ),
          ),
        ),
      ],
    );
  }
}
