import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/home/domain/entities/favorite_producer.dart';
import 'package:ragro_mobile/features/home/domain/entities/producer.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:ragro_mobile/features/home/presentation/widgets/producer_card.dart';

class ProducersSection extends StatefulWidget {
  const ProducersSection({
    required this.producers,
    required this.favorites,
    required this.favoriteIds,
    required this.onProducerTap,
    required this.isLoadingMore,
    super.key,
  });

  final List<Producer> producers;
  final List<FavoriteProducer> favorites;
  final Set<String> favoriteIds;
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
        if (widget.favorites.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Seus produtores favoritos',
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
              itemCount: widget.favorites.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final fav = widget.favorites[index];
                final producer = Producer(
                  id: fav.producerId,
                  name: fav.farmName,
                  description: fav.producerName,
                  avatarUrl: fav.avatarUrl,
                  coverUrl: '',
                  averageRating: fav.averageRating,
                  ownerName: fav.producerName,
                );
                return ProducerCard(
                  producer: producer,
                  isFavorite: true,
                  onTap: () => widget.onProducerTap(producer),
                  onFavoriteTap: () => context.read<HomeBloc>().add(
                    HomeFavoriteToggled(fav.producerId),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
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
                final producer = widget.producers[index];
                return ProducerCard(
                  producer: producer,
                  onTap: () => widget.onProducerTap(producer),
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
