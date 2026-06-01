import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

const _kCloudSvg = '''
<svg width="43" height="32" viewBox="0 0 43 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M10.75 31.2728C7.78561 31.2728 5.25284 30.2402 3.1517 28.175C1.05057 26.1099 0 23.5857 0 20.6027C0 18.0458 0.76553 15.7675 2.29659 13.7679C3.82765 11.7683 5.83106 10.4898 8.30682 9.93256C8.86061 7.57235 10.2451 5.32687 12.4602 3.19612C14.6754 1.06537 17.0371 0 19.5455 0C20.6205 0 21.5407 0.385174 22.3063 1.15552C23.0718 1.92587 23.4545 2.85192 23.4545 3.93369V15.8331L26.5818 12.7845L29.3182 15.5381L21.5 23.4054L13.6818 15.5381L16.4182 12.7845L19.5455 15.8331V3.93369C17.0697 4.39262 15.1477 5.59731 13.7795 7.54776C12.4114 9.49822 11.7273 11.506 11.7273 13.5712H10.75C8.86061 13.5712 7.24811 14.2432 5.9125 15.5872C4.57689 16.9312 3.90909 18.5539 3.90909 20.4552C3.90909 22.3565 4.57689 23.9791 5.9125 25.3231C7.24811 26.6671 8.86061 27.3391 10.75 27.3391H34.2045C35.5727 27.3391 36.7292 26.8638 37.6739 25.9132C38.6186 24.9625 39.0909 23.7988 39.0909 22.422C39.0909 21.0452 38.6186 19.8815 37.6739 18.9309C36.7292 17.9802 35.5727 17.5049 34.2045 17.5049H31.2727V13.5712C31.2727 11.9977 30.9144 10.5308 30.1977 9.17041C29.4811 7.81001 28.5364 6.65449 27.3636 5.70385V1.13094C29.7742 2.27826 31.6799 3.97466 33.0807 6.22014C34.4814 8.46562 35.1818 10.916 35.1818 13.5712C37.4295 13.8335 39.2945 14.8087 40.7767 16.4969C42.2589 18.1851 43 20.1602 43 22.422C43 24.8806 42.1449 26.9704 40.4347 28.6913C38.7244 30.4123 36.6477 31.2728 34.2045 31.2728H10.75Z" fill="#1A432C"/>
</svg>
''';

const _kIconBg = Color(0x26008148);

class ImpactDetailPage extends StatefulWidget {
  const ImpactDetailPage({super.key});

  @override
  State<ImpactDetailPage> createState() => _ImpactDetailPageState();
}

class _ImpactDetailPageState extends State<ImpactDetailPage> {
  double _totalCo2Saved = 0;
  int _totalProducers = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final apiClient = getIt<ApiClient>();
      final results = await Future.wait([
        apiClient.dio.get<Map<String, dynamic>>(ApiEndpoints.co2TotalSaved),
        apiClient.dio.get<Map<String, dynamic>>(
          ApiEndpoints.producers,
          queryParameters: {'page': 0, 'size': 1},
        ),
      ]);

      final co2Response = results[0];
      final producersResponse = results[1];

      final total =
          (co2Response.data?['totalCo2Saved'] as num?)?.toDouble() ?? 0;

      final totalProducers =
          (producersResponse.data?['totalElements'] as num?)?.toInt() ?? 0;

      if (mounted) {
        setState(() {
          _totalCo2Saved = total;
          _totalProducers = totalProducers;
          _loading = false;
        });
      }
    } on DioException catch (e) {
      debugPrint(
        '[ImpactDetail] DioException: ${e.response?.statusCode} ${e.message}',
      );
      if (mounted) setState(() => _loading = false);
    } on Object catch (e) {
      debugPrint('[ImpactDetail] Error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // _totalCo2Saved está em kg → toneladas, com 2 casas decimais (vírgula),
    // para mostrar valores parciais (< 1 t) em vez de arredondar para 0.
    final co2Value = (_totalCo2Saved / 1000)
        .toStringAsFixed(2)
        .replaceAll('.', ',');

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.darkGreen),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.darkGreen),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Entender o impacto',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w700,
                            fontSize: 26,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 16,
                                  right: 24,
                                ),
                                child: Container(
                                  width: 84,
                                  height: 84,
                                  decoration: const BoxDecoration(
                                    color: _kIconBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SvgPicture.string(
                                          _kCloudSvg,
                                          width: 44,
                                          height: 33,
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'CO₂',
                                          style: TextStyle(
                                            fontFamily: 'Figtree',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                            color: AppColors.darkGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Mais de',
                                    style: TextStyle(
                                      fontFamily: 'Figtree',
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        co2Value,
                                        style: const TextStyle(
                                          fontFamily: 'Figtree',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 56,
                                          color: AppColors.darkGreen,
                                          height: 1,
                                        ),
                                      ),
                                      const Text(
                                        't de CO',
                                        style: TextStyle(
                                          fontFamily: 'Figtree',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18,
                                          color: AppColors.darkGreen,
                                        ),
                                      ),
                                      const Text(
                                        '₂',
                                        style: TextStyle(
                                          fontFamily: 'Figtree',
                                          fontSize: 12,
                                          color: AppColors.darkGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'poupadas com a Ragro',
                                    style: TextStyle(
                                      fontFamily: 'Figtree',
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        const Text(
                          'Como fazemos isso acontecer',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 16),

                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _ImpactCard(
                                  icon: Icons.location_on_outlined,
                                  title: 'Consumo local',
                                  description:
                                      'Conectamos você a produtores da sua região',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ImpactCard(
                                  icon: Icons.local_shipping_outlined,
                                  title: 'Rotas eficientes',
                                  description:
                                      'Menor distância, menos emissões',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ImpactCard(
                                  icon: Icons.eco_outlined,
                                  title: 'Menos desperdício',
                                  description:
                                      'Produtos frescos e bem aproveitados',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        const Text(
                          'Nosso impacto juntos',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 16),

                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$_totalProducers',
                                        style: const TextStyle(
                                          fontFamily: 'Figtree',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 32,
                                          color: AppColors.darkGreen,
                                        ),
                                      ),
                                      const Text(
                                        'Produtores\nlocais',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Figtree',
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Figtree',
                                        fontSize: 13,
                                        color: Color(0xFF475569),
                                        height: 1.4,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              'Grande\nvariedade de\nprodutos ',
                                        ),
                                        TextSpan(
                                          text: 'orgânicos',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Figtree',
                                        fontSize: 13,
                                        color: Color(0xFF475569),
                                        height: 1.4,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              'Ajuda o\nambiente com\nnossas rotas ',
                                        ),
                                        TextSpan(
                                          text: 'otimizadas',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/customer/home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Text(
                        'Entrar no marketplace',
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: _kIconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.darkGreen, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontSize: 11,
              color: Color(0xFF64748B),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
