import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_event.dart';
import 'package:ragro_mobile/features/home/domain/entities/producer.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_state.dart';
import 'package:ragro_mobile/features/home/presentation/widgets/producers_section.dart';
import 'package:ragro_mobile/features/home/presentation/widgets/products_grid.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/active_delivery_cubit.dart';
import 'package:ragro_mobile/features/orders/presentation/widgets/active_delivery_banner.dart';
import 'package:ragro_mobile/features/recommendations/domain/entities/recommendation.dart';
import 'package:ragro_mobile/features/recommendations/presentation/bloc/recommendations_bloc.dart';
import 'package:ragro_mobile/features/recommendations/presentation/bloc/recommendations_event.dart';
import 'package:ragro_mobile/features/recommendations/presentation/bloc/recommendations_state.dart';
import 'package:ragro_mobile/shared/widgets/notification_bell.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<HomeBloc>()),
        BlocProvider(
          create: (_) =>
              getIt<RecommendationsBloc>()..add(const RecommendationsStarted()),
        ),
        BlocProvider.value(value: getIt<ActiveDeliveryCubit>()),
      ],
      child: const _CustomerHomeView(),
    );
  }
}

class _CustomerHomeView extends StatefulWidget {
  const _CustomerHomeView();

  @override
  State<_CustomerHomeView> createState() => _CustomerHomeViewState();
}

class _CustomerHomeViewState extends State<_CustomerHomeView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load the in-transit order (top banner); reloaded on pull-to-refresh and
    // when reopening the Home tab.
    context.read<ActiveDeliveryCubit>().load();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      context.read<HomeBloc>().add(const HomeLoadMoreProducts());
    }
  }

  Future<void> _onProducerTap(BuildContext context, Producer producer) async {
    await context.push('/customer/home/producer/${producer.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return switch (state) {
              HomeLoading() || HomeInitial() => const _HomeLoadingView(),
              HomeLoaded(:final producers, :final products) =>
                BlocBuilder<RecommendationsBloc, RecommendationsState>(
                  builder: (context, recommendationsState) {
                    final recommendations = switch (recommendationsState) {
                      RecommendationsLoaded(:final recommendations) =>
                        recommendations,
                      _ => <Recommendation>[],
                    };

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<HomeBloc>().add(const HomeRefreshed());
                        context.read<RecommendationsBloc>().add(
                          const RecommendationsRefreshRequested(),
                        );
                        await context.read<ActiveDeliveryCubit>().load();
                      },
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(16, 12, 6, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Início',
                                    style: TextStyle(
                                      fontFamily: 'Figtree',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 34,
                                      color: AppColors.darkGreen,
                                    ),
                                  ),
                                  NotificationBell(),
                                ],
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: ActiveDeliveryBanner()),
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                          SliverToBoxAdapter(
                            child: ProducersSection(
                              producers: producers,
                              favorites: state.favorites,
                              favoriteIds: state.favoriteIds,
                              onProducerTap: (p) => _onProducerTap(context, p),
                              isLoadingMore: state.isFetchingMoreProducers,
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 32)),
                          SliverToBoxAdapter(
                            child: ProductsGrid(
                              products: products,
                              recommendations: recommendations,
                              isLoadingMore: state.isFetchingMoreProducts,
                              onProductTap: (p) => context.push(
                                '/customer/home/product/${p.id}',
                                extra: p.producerId,
                              ),
                              onAddToCart: (product) {
                                getIt<CartBloc>().add(
                                  CartItemAdded(
                                    productId: product.id,
                                    quantity: 1,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 32)),
                        ],
                      ),
                    );
                  },
                ),
              HomeFailure(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<HomeBloc>().add(const HomeRefreshed()),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            };
          },
        ),
      ),
    );
  }
}

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(width: 80, height: 40),
                SizedBox(height: 24),
                _ShimmerBox(width: 120, height: 24),
                SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ShimmerBox(width: 256, height: 282),
                      SizedBox(width: 16),
                      _ShimmerBox(width: 256, height: 282),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.placeholder.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
