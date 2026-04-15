import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/home/domain/entities/producer.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:ragro_mobile/features/home/presentation/widgets/producer_card.dart';

class ProducersSection extends StatefulWidget {
  const ProducersSection({
    required this.producers,
    required this.onProducerTap,
    required this.isLoadingMore,
    super.key,
  });

  final List<Producer> producers;
  final void Function(Producer) onProducerTap;
  final bool isLoadingMore;

  @override
  State<ProducersSection> createState() => _ProducersSectionState();
}

class _ProducersSectionState extends State<ProducersSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<HomeBloc>().add(const HomeLoadMoreProducers());
    }
  }

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
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.isLoadingMore
                ? widget.producers.length + 1
                : widget.producers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              if (index < widget.producers.length) {
                return ProducerCard(
                  producer: widget.producers[index],
                  onTap: () => widget.onProducerTap(widget.producers[index]),
                );
              }
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: CircularProgressIndicator(color: AppColors.darkGreen),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
