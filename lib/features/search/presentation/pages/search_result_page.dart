import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/search/domain/entities/search_result.dart';
import 'package:ragro_mobile/features/search/presentation/bloc/search_bloc.dart';
import 'package:ragro_mobile/features/search/presentation/bloc/search_event.dart';
import 'package:ragro_mobile/features/search/presentation/bloc/search_state.dart';
import 'package:ragro_mobile/features/search/presentation/widgets/category_chip.dart';
import 'package:ragro_mobile/features/search/presentation/widgets/search_result_tile.dart';

class SearchResultsPage extends StatelessWidget {
  const SearchResultsPage({required this.query, super.key});

  final String query;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SearchBloc>()..add(SearchQueryChanged(query)),
      child: _SearchResultsView(query: query),
    );
  }
}

class _SearchResultsView extends StatefulWidget {
  const _SearchResultsView({required this.query});

  final String query;

  @override
  State<_SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<_SearchResultsView> {
  String? _selectedFilter;

  static const _filters = ['Avaliação', 'Preço', 'Distância'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          toolbarHeight: 80,
          titleSpacing: 12,
          centerTitle: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.darkGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RESULTADOS PARA',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: AppColors.placeholder,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '"${widget.query}"',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            labelColor: AppColors.darkGreen,
            unselectedLabelColor: AppColors.placeholder,
            indicatorColor: AppColors.darkGreen,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            labelStyle: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            tabs: [
              Tab(text: 'Todos'),
              Tab(text: 'Produtos'),
              Tab(text: 'Produtores'),
            ],
          ),
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            return switch (state) {
              SearchIdle() => const SizedBox.shrink(),
              SearchLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.darkGreen),
              ),
              SearchLoaded(:final results) =>
                results.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum resultado encontrado.',
                          style: TextStyle(color: AppColors.placeholder),
                        ),
                      )
                    : _buildTabs(results),
              SearchFailure(:final message) => Center(
                child: Text(
                  message,
                  style: const TextStyle(color: AppColors.placeholder),
                ),
              ),
            };
          },
        ),
      ),
    );
  }

  Widget _buildTabs(List<SearchResult> results) {
    final todos = results;
    final produtos = results
        .where((r) => r.type == SearchResultType.product)
        .toList();
    final produtores = results
        .where((r) => r.type == SearchResultType.producer)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            '${results.length} resultados encontrados perto de você',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: AppColors.darkGreen,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _filters.map((filter) {
              final isLast = filter == _filters.last;
              return Row(
                children: [
                  CategoryChip(
                    label: filter,
                    isSelected: _selectedFilter == filter,
                    onTap: () => setState(() {
                      _selectedFilter = _selectedFilter == filter
                          ? null
                          : filter;
                    }),
                  ),
                  if (!isLast) const SizedBox(width: 12),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            children: [
              _buildList(todos),
              _buildList(produtos),
              _buildList(produtores),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList(List<SearchResult> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum resultado encontrado.',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            color: AppColors.placeholder,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: items.length,
      itemBuilder: (_, i) => SearchResultTile(
        result: items[i],
        onTap: () {
          // TODO(codex): navegar para detalhe.
        },
      ),
    );
  }
}
