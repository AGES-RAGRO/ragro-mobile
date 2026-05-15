import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart_item.dart';
import 'package:ragro_mobile/features/cart/domain/usecases/add_to_cart.dart';
import 'package:ragro_mobile/features/cart/domain/usecases/clear_cart.dart';
import 'package:ragro_mobile/features/cart/domain/usecases/get_cart.dart';
import 'package:ragro_mobile/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:ragro_mobile/features/cart/domain/usecases/update_cart_item_quantity.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_event.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_state.dart';

class _MockGetCart extends Mock implements GetCart {}

class _MockAddToCart extends Mock implements AddToCart {}

class _MockUpdateCartItemQuantity extends Mock
    implements UpdateCartItemQuantity {}

class _MockRemoveFromCart extends Mock implements RemoveFromCart {}

class _MockClearCart extends Mock implements ClearCart {}

void main() {
  late _MockGetCart getCart;
  late _MockAddToCart addToCart;
  late _MockUpdateCartItemQuantity updateQuantity;
  late _MockRemoveFromCart removeFromCart;
  late _MockClearCart clearCart;

  CartBloc buildBloc() => CartBloc(
    getCart,
    addToCart,
    updateQuantity,
    removeFromCart,
    clearCart,
  );

  const tItem = CartItem(
    id: 'item-1',
    productId: 'p-1',
    productName: 'Morango',
    imageUrl: '',
    unitPrice: 15.50,
    unityType: 'kg',
    quantity: 2,
    subtotal: 31,
  );

  const tCart = Cart(
    id: 'cart-1',
    producerId: 'farmer-1',
    farmName: 'Sítio Boa Vista',
    items: [tItem],
    totalAmount: 31,
  );

  const tEmptyCart = Cart.empty();

  setUp(() {
    getCart = _MockGetCart();
    addToCart = _MockAddToCart();
    updateQuantity = _MockUpdateCartItemQuantity();
    removeFromCart = _MockRemoveFromCart();
    clearCart = _MockClearCart();
  });

  group('CartStarted', () {
    blocTest<CartBloc, CartState>(
      'emite [Loading, Loaded] quando getCart retorna sucesso',
      build: () {
        when(() => getCart()).thenAnswer((_) async => tCart);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CartStarted()),
      expect: () => [const CartLoading(), const CartLoaded(tCart)],
    );

    blocTest<CartBloc, CartState>(
      'emite [Loading, Loaded(empty)] quando backend retorna 404 '
      '(carrinho vazio)',
      // O datasource já trata 404 como CartModel.empty(); aqui simulamos isso
      build: () {
        when(() => getCart()).thenAnswer((_) async => tEmptyCart);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CartStarted()),
      expect: () => [const CartLoading(), const CartLoaded(tEmptyCart)],
    );

    blocTest<CartBloc, CartState>(
      'emite [Loading, Failure] quando getCart lança ApiException',
      build: () {
        when(() => getCart()).thenThrow(const NetworkException());
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CartStarted()),
      expect: () => [
        const CartLoading(),
        const CartFailure('Sem conexão com a internet'),
      ],
    );
  });

  group('CartItemAdded', () {
    blocTest<CartBloc, CartState>(
      'sem cart prévio: emite [Loaded(novoCart)] após sucesso',
      build: () {
        when(
          () => addToCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async => tCart);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const CartItemAdded(productId: 'p-1', quantity: 2),
      ),
      expect: () => [const CartLoaded(tCart)],
      verify: (_) {
        verify(() => addToCart(productId: 'p-1', quantity: 2)).called(1);
      },
    );

    blocTest<CartBloc, CartState>(
      'com cart prévio: emite [Updating(prev), Loaded(novo)] após sucesso',
      build: () {
        when(
          () => addToCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async => tCart);
        return buildBloc();
      },
      seed: () => const CartLoaded(tEmptyCart),
      act: (bloc) => bloc.add(
        const CartItemAdded(productId: 'p-1', quantity: 2),
      ),
      expect: () => [
        const CartUpdating(tEmptyCart),
        const CartLoaded(tCart),
      ],
    );

    blocTest<CartBloc, CartState>(
      'com cart prévio: erro vira UpdateFailure preservando o cart anterior '
      '(ex: outro produtor / sem estoque)',
      build: () {
        when(
          () => addToCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenThrow(
          const UnknownApiException(
            'Não é permitido adicionar produtos de produtores diferentes.',
          ),
        );
        return buildBloc();
      },
      seed: () => const CartLoaded(tCart),
      act: (bloc) => bloc.add(
        const CartItemAdded(productId: 'p-2', quantity: 1),
      ),
      expect: () => [
        const CartUpdating(tCart),
        const CartUpdateFailure(
          tCart,
          'Não é permitido adicionar produtos de produtores diferentes.',
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'sem cart prévio: erro vira CartFailure (não há cart pra preservar)',
      build: () {
        when(
          () => addToCart(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenThrow(const NetworkException());
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const CartItemAdded(productId: 'p-1', quantity: 1),
      ),
      expect: () => [const CartFailure('Sem conexão com a internet')],
    );
  });

  group('CartItemQuantityUpdated', () {
    blocTest<CartBloc, CartState>(
      'chama updateQuantity com cartItemId (não productId) e emite '
      '[Updating, Loaded]',
      build: () {
        when(
          () => updateQuantity(
            cartItemId: any(named: 'cartItemId'),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async => tCart);
        return buildBloc();
      },
      seed: () => const CartLoaded(tCart),
      act: (bloc) => bloc.add(
        const CartItemQuantityUpdated(cartItemId: 'item-1', quantity: 3),
      ),
      expect: () => [const CartUpdating(tCart), const CartLoaded(tCart)],
      verify: (_) {
        verify(
          () => updateQuantity(cartItemId: 'item-1', quantity: 3),
        ).called(1);
        verifyNever(
          () => updateQuantity(cartItemId: 'p-1', quantity: any(named: 'quantity')),
        );
      },
    );
  });

  group('CartItemRemoved', () {
    blocTest<CartBloc, CartState>(
      'chama removeFromCart com cartItemId e emite [Updating, Loaded]',
      build: () {
        when(() => removeFromCart(any())).thenAnswer((_) async => tEmptyCart);
        return buildBloc();
      },
      seed: () => const CartLoaded(tCart),
      act: (bloc) => bloc.add(const CartItemRemoved('item-1')),
      expect: () => [
        const CartUpdating(tCart),
        const CartLoaded(tEmptyCart),
      ],
      verify: (_) {
        verify(() => removeFromCart('item-1')).called(1);
      },
    );
  });

  group('CartCleared', () {
    blocTest<CartBloc, CartState>(
      'chama clearCart e emite [Updating, Loaded(vazio)]',
      build: () {
        when(() => clearCart()).thenAnswer((_) async => tEmptyCart);
        return buildBloc();
      },
      seed: () => const CartLoaded(tCart),
      act: (bloc) => bloc.add(const CartCleared()),
      expect: () => [
        const CartUpdating(tCart),
        const CartLoaded(tEmptyCart),
      ],
    );
  });
}
