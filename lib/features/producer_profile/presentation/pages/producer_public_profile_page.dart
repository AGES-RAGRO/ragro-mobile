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
import 'package:ragro_mobile/features/producer_profile/presentation/widgets/availability_section.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/widgets/producer_stats_row.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/widgets/review_card.dart';
import 'package:url_launcher/url_launcher.dart';

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
            ProducerProfileInitial() ||
            ProducerProfileUpdating() ||
            ProducerProfileUpdateSuccess() ||
            ProducerPhotoUploading() => const Center(
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
                  expandedHeight: kToolbarHeight,
                ),
                // Producer info
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 224,
                        width: double.infinity,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                height: 160,
                                child: _CoverPhoto(
                                  coverUrl: producer.coverUrl,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Center(
                                child: CircleAvatar(
                                  radius: 64,
                                  backgroundColor: AppColors.white,
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: AppColors.mintGreen
                                        .withValues(alpha: 0.3),
                                    backgroundImage:
                                        producer.avatarUrl.isNotEmpty
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
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                                onPressed: () =>
                                    _openWhatsApp(context, producer.phone),
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
                            // Descrição
                            if (producer.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  producer.description,
                                  style: const TextStyle(
                                    fontFamily: 'Figtree',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Color(0xFF475569),
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
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
                            const SizedBox(height: 32),
                            // Availability section
                            AvailabilitySection(
                              availability: producer.availability,
                            ),
                            const SizedBox(height: 32),
                            // Stats
                            ProducerStatsRow(
                              productCount: producer.products?.length ?? 0,
                              rating: producer.averageRating,
                              yearsOnPlatform: producer.yearsOnPlatform,
                            ),
                            const SizedBox(height: 32),
                            // Products section header
                            if ((producer.products ?? const []).isNotEmpty)
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
                            if ((producer.products ?? const []).isNotEmpty)
                              const SizedBox(height: 16),
                            // Products grid
                            if ((producer.products ?? const []).isNotEmpty)
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
                                itemCount:
                                    (producer.products ?? const []).length,
                                itemBuilder: (_, i) => HomeProductCard(
                                  product: (producer.products ?? const [])[i],
                                  onTap: () => context.push(
                                    '/customer/home/product/${(producer.products ?? const [])[i].id}',
                                    extra: producer.id,
                                  ),
                                  onAddToCart: () {},
                                ),
                              ),
                            const SizedBox(height: 40),
                            // Reviews section header
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Avaliações Recentes',
                                style: TextStyle(
                                  fontFamily: 'Figtree',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Reviews list or empty state
                            if ((producer.reviews ?? const []).isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.rate_review_outlined,
                                        size: 48,
                                        color: AppColors.darkGreen.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Nenhuma avaliação ainda',
                                        style: TextStyle(
                                          fontFamily: 'Figtree',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: AppColors.darkGreen.withValues(
                                            alpha: 0.6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    (producer.reviews ?? const []).length,
                                itemBuilder: (_, i) => ReviewCard(
                                  review: (producer.reviews ?? const [])[i],
                                ),
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          };
        },
      ),
    );
  }

  Future<void> _openWhatsApp(BuildContext context, String phoneNumber) async {
    try {
      // Remove caracteres especiais (parênteses, hífens, espaços)
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Garante que tem o código de país
      final formattedPhone = cleanPhone.startsWith('+')
          ? cleanPhone.replaceFirst('+', '')
          : cleanPhone;

      final whatsappUrl = 'https://wa.me/$formattedPhone';

      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o WhatsApp'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } on Object catch (e) {
      debugPrint('Erro ao abrir WhatsApp: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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
