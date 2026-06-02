// Producer public profile (consumer view, US-14). Route: GET /producers/:id.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_event.dart';
import 'package:ragro_mobile/features/home/domain/repositories/favorite_producer_repository.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:ragro_mobile/features/home/presentation/widgets/home_product_card.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_bloc.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_event.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_state.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/widgets/availability_section.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/widgets/producer_stats_row.dart';
import 'package:ragro_mobile/shared/widgets/confirm_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ProducerPublicProfilePage extends StatelessWidget {
  const ProducerPublicProfilePage({required this.producerId, super.key});

  final String producerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ProducerProfileBloc>()..add(ProducerProfileStarted(producerId)),
      child: _ProducerPublicProfileView(producerId: producerId),
    );
  }
}

class _ProducerPublicProfileView extends StatefulWidget {
  const _ProducerPublicProfileView({required this.producerId});

  final String producerId;

  @override
  State<_ProducerPublicProfileView> createState() =>
      _ProducerPublicProfileViewState();
}

class _ProducerPublicProfileViewState
    extends State<_ProducerPublicProfileView> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final favorites = await getIt<FavoriteProducerRepository>().getFavorites();
    if (mounted) {
      setState(() {
        _isFavorite = favorites.any((f) => f.producerId == widget.producerId);
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      final confirmed = await ConfirmDialog.show(
        context: context,
        title: 'Tem certeza que quer tirar o produtor dos seus favoritos?',
        confirmLabel: 'Tirar dos favoritos',
        confirmColor: AppColors.red,
      );
      if (!(confirmed ?? false)) return;
    }

    final wasAdding = !_isFavorite;
    getIt<HomeBloc>().add(HomeFavoriteToggled(widget.producerId));

    if (mounted) {
      setState(() => _isFavorite = !_isFavorite);
      if (wasAdding) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produtor adicionado aos favoritos'),
            backgroundColor: AppColors.lightGreen,
          ),
        );
      }
    }
  }

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
                                child: _CoverPhoto(coverUrl: producer.coverUrl),
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
                                    backgroundColor: AppColors.darkGreen
                                        .withValues(alpha: 0.3),
                                    backgroundImage:
                                        producer.avatarUrl.isNotEmpty
                                        ? NetworkImage(producer.avatarUrl)
                                        : null,
                                    onBackgroundImageError:
                                        producer.avatarUrl.isNotEmpty
                                        ? (_, __) {}
                                        : null,
                                    child: producer.avatarUrl.isEmpty
                                        ? Text(
                                            producer.name.isNotEmpty
                                                ? producer.name[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              fontFamily: 'Figtree',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 40,
                                              color: AppColors.darkGreen,
                                            ),
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        producer.name,
                                        style: const TextStyle(
                                          fontFamily: 'Figtree',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 24,
                                          color: AppColors.darkGreen,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              producer.location,
                                              style: const TextStyle(
                                                fontFamily: 'Figtree',
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () => context.push(
                                          '/customer/home/producer/${producer.id}/reviews',
                                          extra: {
                                            'producerName': producer.name,
                                            'producerLocation':
                                                producer.location,
                                            'averageRating':
                                                producer.averageRating,
                                            'totalReviews':
                                                producer.totalReviews,
                                          },
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              size: 16,
                                              color: AppColors.darkGreen,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${producer.averageRating.toStringAsFixed(1)} (${producer.totalReviews} Avaliações)',
                                              style: const TextStyle(
                                                fontFamily: 'Figtree',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppColors.darkGreen,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.chevron_right,
                                              size: 16,
                                              color: AppColors.darkGreen,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  onPressed: _toggleFavorite,
                                  splashRadius: 24,
                                  icon: Icon(
                                    _isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 38,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
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
                            AvailabilitySection(
                              availability: producer.availability,
                            ),
                            const SizedBox(height: 32),
                            ProducerStatsRow(
                              productCount: producer.products?.length ?? 0,
                              rating: producer.averageRating,
                              yearsOnPlatform: producer.yearsOnPlatform,
                            ),
                            const SizedBox(height: 32),
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
                                itemBuilder: (_, i) {
                                  final product =
                                      (producer.products ?? const [])[i];
                                  return HomeProductCard(
                                    product: product,
                                    onTap: () => context.push(
                                      '/customer/home/product/${product.id}',
                                      extra: producer.id,
                                    ),
                                    onAddToCart: () {
                                      getIt<CartBloc>().add(
                                        CartItemAdded(
                                          productId: product.id,
                                          quantity: 1,
                                        ),
                                      );
                                      context.push('/customer/cart');
                                    },
                                  );
                                },
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
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final formattedPhone = cleanPhone.startsWith('+')
        ? cleanPhone.replaceFirst('+', '')
        : cleanPhone;
    final uri = Uri.parse('https://wa.me/$formattedPhone');

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o WhatsApp'),
            duration: Duration(seconds: 2),
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
      return Image.network(
        coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ColoredBox(
          color: AppColors.darkGreen.withValues(alpha: 0.3),
          child: const Center(
            child: Icon(Icons.landscape, size: 64, color: AppColors.white),
          ),
        ),
      );
    }
    return ColoredBox(
      color: AppColors.darkGreen.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(Icons.landscape, size: 64, color: AppColors.white),
      ),
    );
  }
}
