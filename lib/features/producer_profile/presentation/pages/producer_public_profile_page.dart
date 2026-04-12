// Screen: Producer Public Profile (Consumer View)
// User Story: US-14 — View Producer Profile
// Epic: EPIC 3 — Producer Profile and Catalog
// Routes: GET /producers/:id

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/home/presentation/widgets/home_product_card.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_bloc.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_event.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_state.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/widgets/producer_stats_row.dart';

class ProducerPublicProfilePage extends StatelessWidget {
  const ProducerPublicProfilePage({required this.producerId, super.key});

  final String producerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ProducerProfileBloc>()..add(ProducerProfileStarted(producerId)),
      child: const _ProducerPublicProfileView(),
    );
  }
}

class _ProducerPublicProfileView extends StatelessWidget {
  const _ProducerPublicProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocBuilder<ProducerProfileBloc, ProducerProfileState>(
        builder: (context, state) {
          return switch (state) {
            ProducerProfileLoading() ||
            ProducerProfileInitial() => const Center(
              child: CircularProgressIndicator(color: AppColors.darkGreen),
            ),
            ProducerProfileFailure(:final message) => Center(
              child: Text(message),
            ),
            ProducerProfileLoaded(:final producer) => CustomScrollView(
              slivers: [
                // Header with blur background
                SliverAppBar(
                  backgroundColor: Colors.white.withValues(alpha: 0.85),
                  leading: GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back, color: AppColors.black),
                  ),
                  title: const Text(
                    'Perfil do Produtor',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                  pinned: true,
                  expandedHeight: 256,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _CoverPhoto(coverUrl: producer.coverUrl),
                  ),
                ),
                // Producer info
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      children: [
                        // Avatar — overlapping cover
                        Transform.translate(
                          offset: const Offset(0, -64),
                          child: CircleAvatar(
                            radius: 64,
                            backgroundColor: AppColors.white,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.mintGreen.withValues(
                                alpha: 0.3,
                              ),
                              backgroundImage: producer.avatarUrl.isNotEmpty
                                  ? NetworkImage(producer.avatarUrl)
                                  : null,
                              child: producer.avatarUrl.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 48,
                                      color: AppColors.darkGreen,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -48),
                          child: Column(
                            children: [
                              Text(
                                producer.name,
                                style: const TextStyle(
                                  fontFamily: 'Figtree',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 24,
                                  color: AppColors.darkGreen,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    producer.location,
                                    style: const TextStyle(
                                      fontFamily: 'Figtree',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Contact button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.phone_outlined,
                                    color: AppColors.white,
                                  ),
                                  label: const Text(
                                    'Contato',
                                    style: TextStyle(
                                      fontFamily: 'Figtree',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.darkGreen,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Story
                              Text(
                                producer.story,
                                style: const TextStyle(
                                  fontFamily: 'Figtree',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Color(0xFF334155),
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              // Stats
                              ProducerStatsRow(
                                productCount: producer.products.length,
                                rating: producer.averageRating,
                                yearsOnPlatform: producer.yearsOnPlatform,
                              ),
                              const SizedBox(height: 32),
                              // Products section header
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Produtos',
                                  style: TextStyle(
                                    fontFamily: 'Figtree',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Products grid
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.55,
                                    ),
                                itemCount: producer.products.length,
                                itemBuilder: (_, i) => HomeProductCard(
                                  product: producer.products[i],
                                  onTap: () => context.push(
                                    '/customer/home/product/${producer.products[i].id}',
                                  ),
                                  onAddToCart: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          };
        },
      ),
    );
  }
}

class _CoverPhoto extends StatelessWidget {
  const _CoverPhoto({required this.coverUrl});
  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    if (coverUrl.isNotEmpty) {
      return Image.network(coverUrl, fit: BoxFit.cover);
    }
    return ColoredBox(
      color: AppColors.darkGreen.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(Icons.landscape, size: 64, color: AppColors.white),
      ),
    );
  }
}
