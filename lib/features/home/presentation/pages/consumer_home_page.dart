// Screen: Consumer Home
// User Story: US-12 — View Producer List, US-35 — Recommend Products
// Epic: EPIC 2 — Marketplace, EPIC 10 — Recommendations
// Routes: GET /producers, GET /recommendations

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/home/domain/entities/producer.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_state.dart';
import 'package:ragro_mobile/features/home/presentation/widgets/producers_section.dart';
import 'package:ragro_mobile/features/home/presentation/widgets/products_grid.dart';

class ConsumerHomePage extends StatelessWidget {
  const ConsumerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(const HomeStarted()),
      child: const _ConsumerHomeView(),
    );
  }
}

class _ConsumerHomeView extends StatelessWidget {
  const _ConsumerHomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return switch (state) {
              HomeLoading() || HomeInitial() => const _HomeLoadingView(),
              HomeLoaded(:final producers, :final products) => RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(const HomeRefreshed());
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: const Text(
                          'Início',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w700,
                            fontSize: 34,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverToBoxAdapter(
                      child: ProducersSection(
                        producers: producers,
                        onProducerTap: (p) => _onProducerTap(context, p),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    SliverToBoxAdapter(
                      child: ProductsGrid(
                        products: products,
                        onProductTap: (p) =>
                            context.push('/consumer/home/product/${p.id}'),
                        onAddToCart: (_) {
                          // TODO: navigate to cart / add to cart
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
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

  void _onProducerTap(BuildContext context, Producer producer) {
    context.push('/consumer/home/producer/${producer.id}');
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
        color: AppColors.placeholder.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
