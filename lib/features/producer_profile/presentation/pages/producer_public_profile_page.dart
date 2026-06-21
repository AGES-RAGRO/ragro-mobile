// Producer public profile (consumer view, US-14). Route: GET /producers/:id.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

const _kWhatsAppSvg = '''
<svg viewBox="0 0 448 512" xmlns="http://www.w3.org/2000/svg">
<path fill="#FDFDFD" d="M380.9 97.1C339 55.1 283.2 32 223.9 32c-122.4 0-222 99.6-222 222 0 39.1 10.2 77.3 29.6 111L0 480l117.7-30.9c32.4 17.7 68.9 27 106.1 27h.1c122.3 0 224.1-99.6 224.1-222 0-59.3-25.2-115-67.1-157zm-157 341.6c-33.2 0-65.7-8.9-94-25.7l-6.7-4-69.8 18.3L72 359.2l-4.4-7c-18.5-29.4-28.2-63.3-28.2-98.2 0-101.7 82.8-184.5 184.6-184.5 49.3 0 95.6 19.2 130.4 54.1 34.8 34.9 56.2 81.2 56.1 130.5 0 101.8-84.9 184.6-186.6 184.6zm101.2-138.2c-5.5-2.8-32.8-16.2-37.9-18-5.1-1.9-8.8-2.8-12.5 2.8-3.7 5.6-14.3 18-17.6 21.8-3.2 3.7-6.5 4.2-12 1.4-32.6-16.3-54-29.1-75.5-66-5.7-9.8 5.7-9.1 16.3-30.3 1.8-3.7.9-6.9-.5-9.7-1.4-2.8-12.5-30.1-17.1-41.2-4.5-10.8-9.1-9.3-12.5-9.5-3.2-.2-6.9-.2-10.6-.2-3.7 0-9.7 1.4-14.8 6.9-5.1 5.6-19.4 19-19.4 46.3 0 27.3 19.9 53.7 22.6 57.4 2.8 3.7 39.1 59.7 94.8 83.8 35.2 15.2 49 16.5 66.6 13.9 10.7-1.6 32.8-13.4 37.4-26.4 4.6-13 4.6-24.1 3.2-26.4-1.3-2.5-5-3.9-10.5-6.6z"/>
</svg>
''';

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
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            producer.farmName.isNotEmpty
                                                ? producer.farmName
                                                : producer.name,
                                            style: const TextStyle(
                                              fontFamily: 'Figtree',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 22,
                                              color: AppColors.darkGreen,
                                            ),
                                          ),
                                          if (producer.farmName.isNotEmpty)
                                            Text(
                                              producer.name,
                                              style: const TextStyle(
                                                fontFamily: 'Figtree',
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                        ],
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
                                          '/customer/producer/${producer.id}/reviews',
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
                                icon: SvgPicture.string(
                                  _kWhatsAppSvg,
                                  width: 22,
                                  height: 22,
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
                            const SizedBox(height: 16),
                            AvailabilitySection(
                              availability: producer.availability,
                            ),
                            const SizedBox(height: 16),
                            ProducerStatsRow(
                              productCount: producer.products?.length ?? 0,
                              rating: producer.averageRating,
                              yearsOnPlatform: producer.yearsOnPlatform,
                            ),
                            const SizedBox(height: 20),
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
                              const SizedBox(height: 12),
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
