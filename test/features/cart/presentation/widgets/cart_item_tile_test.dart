import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart_item.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_event.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_state.dart';
import 'package:ragro_mobile/features/cart/presentation/widgets/cart_item_tile.dart';

class _MockCartBloc extends MockBloc<CartEvent, CartState>
    implements CartBloc {}

void main() {
  late _MockCartBloc bloc;

  setUp(() {
    bloc = _MockCartBloc();
    when(() => bloc.state).thenReturn(const CartInitial());
  });

  CartItem buildItem({
    String unityType = 'kg',
    double quantity = 2,
    double unitPrice = 15.50,
  }) => CartItem(
    id: 'item-1',
    productId: 'prod-1',
    productName: 'Morango Orgânico',
    imageUrl: '',
    unitPrice: unitPrice,
    unityType: unityType,
    quantity: quantity,
    subtotal: unitPrice * quantity,
  );

  Widget buildSubject({
    required CartItem item,
    String producerId = 'farmer-1',
    void Function(String location, Object? extra)? onPush,
  }) {
    final router = GoRouter(
      initialLocation: '/cart',
      routes: [
        GoRoute(
          path: '/cart',
          builder: (_, __) => Scaffold(
            body: BlocProvider<CartBloc>.value(
              value: bloc,
              child: CartItemTile(item: item, producerId: producerId),
            ),
          ),
        ),
        GoRoute(
          path: '/customer/home/product/:productId',
          builder: (context, state) {
            onPush?.call(state.uri.toString(), state.extra);
            return const Scaffold(body: Text('product detail'));
          },
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  group('exibição', () {
    testWidgets(r'mostra "R$ X,XX / unityType" quando unityType existe', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(item: buildItem()));

      expect(find.text(r'R$ 15,50 / kg'), findsOneWidget);
    });

    testWidgets('mostra apenas o preço quando unityType vier vazio', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(item: buildItem(unityType: '')));

      expect(find.text(r'R$ 15,50'), findsOneWidget);
      expect(find.textContaining(' / '), findsNothing);
    });

    testWidgets('formata quantidade inteira sem casas decimais', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(item: buildItem()));

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('formata quantidade fracionária preservando significativos', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(item: buildItem(quantity: 2.5)));

      expect(find.text('2.5'), findsOneWidget);
    });
  });

  group('navegação', () {
    testWidgets(
      'tap no tile navega para /customer/home/product/{productId} passando '
      'producerId via extra (necessário para GET /producers/:p/products/:id)',
      (tester) async {
        String? pushedLocation;
        Object? pushedExtra;
        await tester.pumpWidget(
          buildSubject(
            item: buildItem(),
            producerId: 'farmer-42',
            onPush: (loc, extra) {
              pushedLocation = loc;
              pushedExtra = extra;
            },
          ),
        );

        await tester.tap(find.text('Morango Orgânico'));
        await tester.pumpAndSettle();

        expect(pushedLocation, '/customer/home/product/prod-1');
        expect(pushedExtra, 'farmer-42');
      },
    );

    testWidgets(
      'tap fica desabilitado quando producerId vier vazio (evita URL '
      'quebrada /producers//products/:id)',
      (tester) async {
        String? pushedLocation;
        await tester.pumpWidget(
          buildSubject(
            item: buildItem(),
            producerId: '',
            onPush: (loc, _) => pushedLocation = loc,
          ),
        );

        await tester.tap(find.text('Morango Orgânico'));
        await tester.pumpAndSettle();

        expect(pushedLocation, isNull);
      },
    );
  });

  group('mutações', () {
    testWidgets('botão "+" dispara CartItemQuantityUpdated com quantity+1', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(item: buildItem()));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      verify(
        () => bloc.add(
          const CartItemQuantityUpdated(cartItemId: 'item-1', quantity: 3),
        ),
      ).called(1);
    });

    testWidgets(
      'botão "-" com quantity>1 dispara CartItemQuantityUpdated com quantity-1',
      (tester) async {
        await tester.pumpWidget(buildSubject(item: buildItem(quantity: 3)));

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        verify(
          () => bloc.add(
            const CartItemQuantityUpdated(cartItemId: 'item-1', quantity: 2),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'botão "-" com quantity==1 dispara CartItemRemoved (PATCH < 1 violaria '
      'a validação do backend)',
      (tester) async {
        await tester.pumpWidget(buildSubject(item: buildItem(quantity: 1)));

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        verify(() => bloc.add(const CartItemRemoved('item-1'))).called(1);
      },
    );

    testWidgets('ícone de lixeira dispara CartItemRemoved', (tester) async {
      await tester.pumpWidget(buildSubject(item: buildItem()));

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      verify(() => bloc.add(const CartItemRemoved('item-1'))).called(1);
    });
  });
}
