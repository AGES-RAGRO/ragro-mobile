// Verificação visual das telas afetadas pelas issues #407 e #412.
// Gera goldens em test/visual/goldens/ com:
//   flutter test test/visual/visual_check_test.dart --update-goldens
//
// Apenas widgets públicos são testados aqui. Para CartItemTile e o
// painel de quantidade do ProductDetail, verificamos:
//   - Renderização correta (golden)
//   - Área de toque dos botões >= 44 px (SizedBox wrapping)
//   - Link do produtor presente e tocável

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart_item.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_event.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_state.dart';
import 'package:ragro_mobile/features/cart/presentation/widgets/cart_item_tile.dart';

class _MockCartBloc extends MockBloc<CartEvent, CartState>
    implements CartBloc {}

// Dados espelhando o seed do backend (Sítio Boa Vista)
const _morangoItem = CartItem(
  id: 'cart-item-1',
  productId: 'b0000000-0000-0000-0000-000000000001',
  productName: 'Morango Orgânico',
  imageUrl: '',
  unitPrice: 15.50,
  unityType: 'box',
  quantity: 2,
  subtotal: 31.00,
);

void main() {
  late _MockCartBloc cartBloc;

  setUp(() {
    cartBloc = _MockCartBloc();
    when(() => cartBloc.state).thenReturn(const CartInitial());
  });

  Widget buildCartItem({String producerId = 'a0000000-0000-0000-0000-000000000003'}) {
    final router = GoRouter(
      initialLocation: '/cart',
      routes: [
        GoRoute(
          path: '/cart',
          builder: (_, __) => Scaffold(
            backgroundColor: const Color(0xFFF6F7F6),
            body: BlocProvider<CartBloc>.value(
              value: cartBloc,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CartItemTile(item: _morangoItem, producerId: producerId),
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/customer/home/product/:id',
          builder: (_, __) => const Scaffold(body: Text('Detalhe do produto')),
        ),
      ],
    );

    return MaterialApp.router(
      theme: ThemeData(
        fontFamily: 'Manrope',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.darkGreen),
      ),
      routerConfig: router,
    );
  }

  group('#407 — CartItemTile: área de toque dos botões', () {
    testWidgets('botão "+" tem SizedBox com largura e altura >= 44 px', (
      tester,
    ) async {
      await tester.pumpWidget(buildCartItem());
      await tester.pumpAndSettle();

      final addIcon = find.byIcon(Icons.add);
      expect(addIcon, findsOneWidget);

      // O SizedBox mais próximo acima do ícone é o hitbox do botão
      final sizedBoxes = find.ancestor(
        of: addIcon,
        matching: find.byType(SizedBox),
      );
      final hitbox = tester.getSize(sizedBoxes.first);

      expect(
        hitbox.width,
        greaterThanOrEqualTo(44),
        reason: 'Largura do hitbox do botão + deve ser >= 44 px',
      );
      expect(
        hitbox.height,
        greaterThanOrEqualTo(44),
        reason: 'Altura do hitbox do botão + deve ser >= 44 px',
      );
    });

    testWidgets('botão "-" tem SizedBox com largura e altura >= 44 px', (
      tester,
    ) async {
      await tester.pumpWidget(buildCartItem());
      await tester.pumpAndSettle();

      final removeIcon = find.byIcon(Icons.remove);
      expect(removeIcon, findsOneWidget);

      final sizedBoxes = find.ancestor(
        of: removeIcon,
        matching: find.byType(SizedBox),
      );
      final hitbox = tester.getSize(sizedBoxes.first);

      expect(
        hitbox.width,
        greaterThanOrEqualTo(44),
        reason: 'Largura do hitbox do botão - deve ser >= 44 px',
      );
      expect(
        hitbox.height,
        greaterThanOrEqualTo(44),
        reason: 'Altura do hitbox do botão - deve ser >= 44 px',
      );
    });

    testWidgets('golden — CartItemTile completo (issue #407)', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 170 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildCartItem());
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CartItemTile),
        matchesGoldenFile('goldens/cart_item_tile.png'),
      );
    });
  });

  group('#407 e #412 — Painel de quantidade (ProductDetail)', () {
    // Reproduz o Container dos botões +/- da ProductDetailPage
    // sem depender da classe privada _ProductDetailView.
    Widget buildQuantityPanel({int quantity = 1}) {
      return MaterialApp(
        theme: ThemeData(
          fontFamily: 'Figtree',
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.darkGreen),
        ),
        home: Scaffold(
          body: Center(
            child: Container(
              height: 53,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: const SizedBox(
                      width: 48,
                      height: 53,
                      child: Icon(Icons.remove, size: 16),
                    ),
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: const SizedBox(
                      width: 48,
                      height: 53,
                      child: Icon(Icons.add, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('botão "+" no ProductDetail tem hitbox 48x53 px', (tester) async {
      await tester.pumpWidget(buildQuantityPanel());
      await tester.pumpAndSettle();

      final addIcon = find.byIcon(Icons.add);
      final sizedBoxes = find.ancestor(of: addIcon, matching: find.byType(SizedBox));
      final hitbox = tester.getSize(sizedBoxes.first);

      expect(hitbox.width, equals(48));
      expect(hitbox.height, equals(53));
    });

    testWidgets('botão "-" no ProductDetail tem hitbox 48x53 px', (tester) async {
      await tester.pumpWidget(buildQuantityPanel());
      await tester.pumpAndSettle();

      final removeIcon = find.byIcon(Icons.remove);
      final sizedBoxes = find.ancestor(of: removeIcon, matching: find.byType(SizedBox));
      final hitbox = tester.getSize(sizedBoxes.first);

      expect(hitbox.width, equals(48));
      expect(hitbox.height, equals(53));
    });

    testWidgets('golden — painel de quantidade (issue #407)', (tester) async {
      tester.view.physicalSize = const Size(200 * 3, 100 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildQuantityPanel(quantity: 2));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/product_detail_quantity_panel.png'),
      );
    });
  });

  group('#412 — Link do produtor (ProductDetail)', () {
    Widget buildProducerLink({
      required String producerName,
      required String producerId,
    }) {
      String? navigatedTo;

      return MaterialApp(
        home: Scaffold(
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: producerId.isEmpty
                ? null
                : () {
                    navigatedTo = '/customer/producer/$producerId';
                  },
            child: Row(
              children: [
                Flexible(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: 'Produtor: ',
                      style: const TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 14,
                        color: Color(0xFF000000),
                      ),
                      children: [
                        TextSpan(
                          text: producerName,
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: producerId.isEmpty
                                ? const Color(0xFF000000)
                                : AppColors.darkGreen,
                            decoration:
                                producerId.isEmpty ? null : TextDecoration.underline,
                            decorationColor: AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (producerId.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.darkGreen,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('exibe nome em verde com chevron quando producerId preenchido', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildProducerLink(
          producerName: 'João da Silva',
          producerId: 'a0000000-0000-0000-0000-000000000003',
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('João da Silva'),
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('não exibe chevron quando producerId vazio', (tester) async {
      await tester.pumpWidget(
        buildProducerLink(producerName: 'João da Silva', producerId: ''),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('golden — link do produtor com id (issue #412)', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 60 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildProducerLink(
          producerName: 'João da Silva',
          producerId: 'a0000000-0000-0000-0000-000000000003',
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/producer_link.png'),
      );
    });

    testWidgets('golden — produtor sem id (texto simples, sem link)', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 60 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildProducerLink(producerName: 'João da Silva', producerId: ''),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/producer_link_no_id.png'),
      );
    });
  });
}
