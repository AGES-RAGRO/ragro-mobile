import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/producer_profile/data/models/review_model.dart';
import 'package:ragro_mobile/features/producer_profile/domain/entities/review.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/widgets/review_card.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({
    required this.producerId,
    required this.producerName,
    required this.producerLocation,
    required this.averageRating,
    required this.totalReviews,
    super.key,
  });

  final String producerId;
  final String producerName;
  final String producerLocation;
  final double averageRating;
  final int totalReviews;

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  List<Review> _reviews = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final apiClient = getIt<ApiClient>();
      final response = await apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.producerReviews(widget.producerId),
        queryParameters: {'page': 0, 'size': 50},
      );
      final items = response.data!['content'] as List<dynamic>? ?? [];
      setState(() {
        _reviews = items
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _error =
            (e.error as ApiException?)?.message ??
            'Erro ao carregar avaliações';
        _loading = false;
      });
    } on Object catch (_) {
      setState(() {
        _error = 'Erro ao carregar avaliações';
        _loading = false;
      });
    }
  }

  Map<int, int> _buildDistribution() {
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _reviews) {
      final key = r.rating.round().clamp(1, 5);
      dist[key] = (dist[key] ?? 0) + 1;
    }
    return dist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.black),
        title: const Text(
          'Avaliações',
          style: TextStyle(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.darkGreen),
            )
          : _error != null
          ? Center(child: Text(_error!))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.producerName,
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  if (widget.producerLocation.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.producerLocation,
                          style: const TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0x1A64748B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumo das Avaliações',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontFamily: 'Figtree',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 52,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  _SummaryStarRow(rating: widget.averageRating),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${widget.totalReviews} Avaliações',
                                    style: const TextStyle(
                                      fontFamily: 'Figtree',
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _RatingDistribution(
                                  distribution: _buildDistribution(),
                                  total: _reviews.length,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  if (_reviews.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 48,
                              color: AppColors.darkGreen.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Nenhuma avaliação ainda',
                              style: TextStyle(
                                fontFamily: 'Figtree',
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
                      itemCount: _reviews.length,
                      itemBuilder: (_, i) => ReviewCard(review: _reviews[i]),
                    ),
                ],
              ),
            ),
    );
  }
}

class _SummaryStarRow extends StatelessWidget {
  const _SummaryStarRow({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star, size: 18, color: AppColors.darkGreen);
        } else if (i < rating) {
          return const Icon(
            Icons.star_half,
            size: 18,
            color: AppColors.darkGreen,
          );
        }
        return const Icon(
          Icons.star_border,
          size: 18,
          color: AppColors.darkGreen,
        );
      }),
    );
  }
}

class _RatingDistribution extends StatelessWidget {
  const _RatingDistribution({required this.distribution, required this.total});

  final Map<int, int> distribution;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [5, 4, 3, 2, 1].map((star) {
        final count = distribution[star] ?? 0;
        final ratio = total > 0 ? count / total : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(
                width: 10,
                child: Text(
                  '$star',
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 3),
              const Icon(Icons.star, size: 11, color: AppColors.darkGreen),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: const Color(0xFFD1D9E0),
                    color: AppColors.darkGreen,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 18,
                child: Text(
                  '$count',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
