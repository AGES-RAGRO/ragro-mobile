import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_event.dart';
import 'package:ragro_mobile/features/search/domain/entities/search_result.dart';
import 'package:ragro_mobile/features/search/presentation/bloc/search_bloc.dart';
import 'package:ragro_mobile/features/search/presentation/bloc/search_event.dart';
import 'package:ragro_mobile/features/search/presentation/bloc/search_state.dart';
import 'package:ragro_mobile/features/search/presentation/widgets/search_result_tile.dart';

class SearchRouteParams {
  const SearchRouteParams({required this.query, this.category});

  final String query;
  final String? category;
}

class SearchResultsPage extends StatelessWidget {
  const SearchResultsPage({required this.query, this.category, super.key});

  final String query;
  final String? category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SearchBloc>()
        ..add(SearchCategoryChanged(category))
        ..add(SearchQueryChanged(query)),
      child: _SearchResultsView(query: query, category: category),
    );
  }
}

class _SearchResultsView extends StatefulWidget {
  const _SearchResultsView({required this.query, this.category});

  final String query;
  final String? category;

  @override
  State<_SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<_SearchResultsView> {
  _SortDirection? _ratingSort;
  _SortDirection? _priceSort;
  _SortDirection? _distanceSort;

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
    final produtos = _applySorts(
      results.where((r) => r.type == SearchResultType.product).toList(),
    );
    final produtores = _applySorts(
      results.where((r) => r.type == SearchResultType.producer).toList(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            '${results.length} resultados encontrados',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: AppColors.darkGreen,
            ),
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _SearchDropdownFilter(
                label: 'Avaliação',
                isSelected: _ratingSort != null,
                onSelected: (value) {
                  setState(() => _ratingSort = value);
                },
              ),
              const SizedBox(width: 10),
              _SearchDropdownFilter(
                label: 'Preço',
                isSelected: _priceSort != null,
                onSelected: (value) {
                  setState(() => _priceSort = value);
                },
              ),
              const SizedBox(width: 10),
              _SearchDropdownFilter(
                label: 'Distância',
                isSelected: _distanceSort != null,
                onSelected: (value) {
                  setState(() => _distanceSort = value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            children: [
              _buildAllList(produtos: produtos, produtores: produtores),
              _buildList(produtos),
              _buildList(produtores),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllList({
    required List<SearchResult> produtos,
    required List<SearchResult> produtores,
  }) {
    if (produtos.isEmpty && produtores.isEmpty) {
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

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      children: [
        if (produtos.isNotEmpty) ...[
          const _ResultSectionLabel('Produtos'),
          ...produtos.map(
            (result) => SearchResultTile(
              result: result,
              onTap: () => _onResultTap(result),
              onAddToCart: result.type == SearchResultType.product
                  ? () => _onAddToCart(result)
                  : null,
            ),
          ),
        ],
        if (produtos.isNotEmpty && produtores.isNotEmpty)
          const SizedBox(height: 8),
        if (produtores.isNotEmpty) ...[
          const _ResultSectionLabel('Produtores'),
          ...produtores.map(
            (result) => SearchResultTile(
              result: result,
              onTap: () => _onResultTap(result),
            ),
          ),
        ],
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
        onTap: () => _onResultTap(items[i]),
        onAddToCart: items[i].type == SearchResultType.product
            ? () => _onAddToCart(items[i])
            : null,
      ),
    );
  }

  void _onResultTap(SearchResult result) {
    if (result.type == SearchResultType.product) {
      final producerId = _resolveProducerId(result);
      if (producerId == null) {
        _showNavigationError(
          'Nao foi possivel abrir este produto. Tente novamente em instantes.',
        );
        return;
      }

      context.push(
        '/customer/home/product/${result.id}',
        extra: producerId,
      );
      return;
    }

    final producerId = _resolveProducerId(result) ?? result.id;
    context.push('/customer/home/producer/$producerId');
  }

  void _onAddToCart(SearchResult result) {
    if (result.type != SearchResultType.product) return;
    getIt<CartBloc>().add(CartItemAdded(productId: result.id, quantity: 1));
    context.push('/customer/cart');
  }

  String? _resolveProducerId(SearchResult result) {
    final producerId = result.producerId?.trim();
    if (producerId == null || producerId.isEmpty) {
      return null;
    }
    return producerId;
  }

  void _showNavigationError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.darkGreen,
        ),
      );
  }

  List<SearchResult> _applySorts(List<SearchResult> source) {
    final sorted = List<SearchResult>.from(source);

    if (_ratingSort != null) {
      sorted.sort((a, b) {
        final aValue = a.rating ?? double.negativeInfinity;
        final bValue = b.rating ?? double.negativeInfinity;
        return _ratingSort == _SortDirection.ascending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      });
    }

    if (_priceSort != null) {
      sorted.sort((a, b) {
        final aValue = a.price ?? double.infinity;
        final bValue = b.price ?? double.infinity;
        return _priceSort == _SortDirection.ascending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      });
    }

    if (_distanceSort != null) {
      sorted.sort((a, b) {
        final aValue = a.distance ?? double.infinity;
        final bValue = b.distance ?? double.infinity;
        return _distanceSort == _SortDirection.ascending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      });
    }

    return sorted;
  }
}

enum _SortDirection { ascending, descending }

enum _SortMenuAction { ascending, descending, clear }

class _ResultSectionLabel extends StatelessWidget {
  const _ResultSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: AppColors.placeholder,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _SearchDropdownFilter extends StatelessWidget {
  const _SearchDropdownFilter({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<_SortDirection?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () async {
          final button = context.findRenderObject()! as RenderBox;
          final overlay =
              Overlay.of(context).context.findRenderObject()! as RenderBox;

          final value = await showMenu<_SortMenuAction>(
            context: context,
            position: RelativeRect.fromRect(
              Rect.fromPoints(
                button.localToGlobal(Offset.zero, ancestor: overlay),
                button.localToGlobal(
                  button.size.bottomRight(Offset.zero),
                  ancestor: overlay,
                ),
              ),
              Offset.zero & overlay.size,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            items: const [
              PopupMenuItem<_SortMenuAction>(
                value: _SortMenuAction.ascending,
                child: Text('Menor primeiro'),
              ),
              PopupMenuItem<_SortMenuAction>(
                value: _SortMenuAction.descending,
                child: Text('Maior primeiro'),
              ),
              PopupMenuDivider(),
              PopupMenuItem<_SortMenuAction>(
                value: _SortMenuAction.clear,
                child: Text('Limpar'),
              ),
            ],
          );

          switch (value) {
            case _SortMenuAction.ascending:
              onSelected(_SortDirection.ascending);
            case _SortMenuAction.descending:
              onSelected(_SortDirection.descending);
            case _SortMenuAction.clear:
              onSelected(null);
            case null:
              break;
          }
        },
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkGreen : AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? AppColors.darkGreen : const Color(0xFFD9E1D8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isSelected ? AppColors.white : AppColors.black,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: isSelected ? AppColors.white : AppColors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
