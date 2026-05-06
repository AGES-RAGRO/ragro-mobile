import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/search/presentation/bloc/search_bloc.dart';
import 'package:ragro_mobile/features/search/presentation/bloc/search_event.dart';
import 'package:ragro_mobile/features/search/presentation/bloc/search_state.dart';
import 'package:ragro_mobile/features/search/presentation/pages/search_result_page.dart';
import 'package:ragro_mobile/features/search/presentation/widgets/category_chip.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SearchBloc>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();
  String _selectedCategory = 'Tudo';
  final _categories = const [
    'Tudo',
    'Frutas',
    'Verduras',
    'Legumes',
    'Laticínios',
    'Ovos',
    'Grãos e Cereais',
    'Carnes',
    'Mel e Derivados',
    'Processados Artesanais',
    'Plantas e Mudas',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToResults(BuildContext context, String query) {
    if (query.trim().isEmpty) return;
    context.read<SearchBloc>().add(SearchQuerySubmitted(query.trim()));
    context.push(
      '/customer/search/results',
      extra: SearchRouteParams(
        query: query.trim(),
        category: _selectedCategory == 'Tudo' ? null : _selectedCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  'Pesquisa',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w700,
                    fontSize: 34,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (q) => _goToResults(context, q),
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 16,
                      color: AppColors.black,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'O que você procura hoje?',
                      hintStyle: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.placeholder,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
              ),
              // Categories
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        'Categorias',
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => CategoryChip(
                          label: _categories[i],
                          isSelected: _selectedCategory == _categories[i],
                          onTap: () {
                            setState(() => _selectedCategory = _categories[i]);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Recent searches
              BlocBuilder<SearchBloc, SearchState>(
                buildWhen: (prev, curr) =>
                    curr is SearchIdle && curr.recentSearches.isNotEmpty ||
                    curr is SearchIdle && curr.recentSearches.isEmpty,
                builder: (context, state) {
                  final recent = state is SearchIdle
                      ? state.recentSearches
                      : <String>[];
                  if (recent.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Buscas Recentes',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...recent.map(
                          (q) => Column(
                            children: [
                              _RecentSearchItem(
                                query: q,
                                onTap: () => _goToResults(context, q),
                                onRemove: () => context.read<SearchBloc>().add(
                                  SearchRecentItemRemoved(q),
                                ),
                              ),
                              const Divider(
                                color: Color(0xFFF1F5F9),
                                height: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSearchItem extends StatelessWidget {
  const _RecentSearchItem({
    required this.query,
    required this.onTap,
    required this.onRemove,
  });

  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            const Icon(Icons.history, size: 16, color: AppColors.placeholder),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                query,
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close,
                size: 14,
                color: AppColors.placeholder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
