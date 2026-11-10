import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:shortly_app/core/errors/failure.dart';
import 'package:shortly_app/features/ecommerce/cart/domain/entities/cart.dart';
import 'package:shortly_app/features/ecommerce/cart/domain/repositories/cart_repository.dart';
import 'package:shortly_app/features/ecommerce/cart/domain/usecases/get_cart_usecase.dart';
import 'package:shortly_app/features/ecommerce/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:shortly_app/features/ecommerce/cart/domain/usecases/update_cart_item_qty_usecase.dart';
import 'package:shortly_app/features/ecommerce/cart/presentation/bloc/cart_bloc.dart';
import 'package:shortly_app/features/ecommerce/cart/presentation/bloc/cart_event.dart';
import 'package:shortly_app/features/ecommerce/cart/presentation/bloc/cart_state.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockCartRepository mockCartRepository;
  late GetCartUseCase getCartUseCase;
  late UpdateCartItemQtyUseCase updateCartItemQtyUseCase;
  late RemoveCartItemUseCase removeCartItemUseCase;

  const testCart = Cart(id: 'cart-001', userId: 'user-001', items: []);

  const testItemId = 'item-001';

  CartBloc buildBloc() {
    return CartBloc(
      getCartUseCase: getCartUseCase,
      updateCartItemQtyUseCase: updateCartItemQtyUseCase,
      removeCartItemUseCase: removeCartItemUseCase,
    );
  }

  setUp(() {
    mockCartRepository = MockCartRepository();
    getCartUseCase = GetCartUseCase(mockCartRepository);
    updateCartItemQtyUseCase = UpdateCartItemQtyUseCase(mockCartRepository);
    removeCartItemUseCase = RemoveCartItemUseCase(mockCartRepository);
  });

  group('CartBloc', () {
    test('initial state is CartInitial', () {
      final bloc = buildBloc();

      expect(bloc.state, equals(const CartInitial()));

      bloc.close();
    });

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartLoaded] when cart request succeeds',
      build: () {
        when(
          () => mockCartRepository.getCart(),
        ).thenAnswer((_) async => const Right(testCart));

        return buildBloc();
      },
      act: (bloc) => bloc.add(const CartRequested()),
      expect: () => [const CartLoading(), const CartLoaded(cart: testCart)],
      verify: (_) {
        verify(() => mockCartRepository.getCart()).called(1);
      },
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartFailure] when cart request fails',
      build: () {
        when(
          () => mockCartRepository.getCart(),
        ).thenAnswer((_) async => Left(ServerFailure('Unable to load cart')));

        return buildBloc();
      },
      act: (bloc) => bloc.add(const CartRequested()),
      expect: () => [
        const CartLoading(),
        isA<CartFailure>().having(
          (state) => state.message,
          'failure message',
          'Unable to load cart',
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits updating and loaded states when quantity update succeeds',
      build: () {
        when(
          () =>
              mockCartRepository.updateCartItemQty(itemId: testItemId, qty: 2),
        ).thenAnswer((_) async => const Right(testCart));

        return buildBloc();
      },
      seed: () => const CartLoaded(cart: testCart),
      act: (bloc) =>
          bloc.add(const CartItemQtyChanged(itemId: testItemId, qty: 2)),
      expect: () => [
        const CartLoaded(cart: testCart, isUpdating: true),
        const CartLoaded(cart: testCart),
      ],
      verify: (_) {
        verify(
          () =>
              mockCartRepository.updateCartItemQty(itemId: testItemId, qty: 2),
        ).called(1);
      },
    );

    blocTest<CartBloc, CartState>(
      'emits CartFailure when quantity update fails',
      build: () {
        when(
          () =>
              mockCartRepository.updateCartItemQty(itemId: testItemId, qty: 2),
        ).thenAnswer(
          (_) async => Left(ServerFailure('Unable to update quantity')),
        );

        return buildBloc();
      },
      seed: () => const CartLoaded(cart: testCart),
      act: (bloc) =>
          bloc.add(const CartItemQtyChanged(itemId: testItemId, qty: 2)),
      expect: () => [
        const CartLoaded(cart: testCart, isUpdating: true),
        isA<CartFailure>().having(
          (state) => state.message,
          'failure message',
          'Unable to update quantity',
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits updating and loaded states when item removal succeeds',
      build: () {
        when(
          () => mockCartRepository.removeCartItem(testItemId),
        ).thenAnswer((_) async => const Right(testCart));

        return buildBloc();
      },
      seed: () => const CartLoaded(cart: testCart),
      act: (bloc) => bloc.add(const CartItemRemoved(testItemId)),
      expect: () => [
        const CartLoaded(cart: testCart, isUpdating: true),
        const CartLoaded(cart: testCart),
      ],
      verify: (_) {
        verify(() => mockCartRepository.removeCartItem(testItemId)).called(1);
      },
    );

    blocTest<CartBloc, CartState>(
      'emits CartFailure when item removal fails',
      build: () {
        when(
          () => mockCartRepository.removeCartItem(testItemId),
        ).thenAnswer((_) async => Left(ServerFailure('Unable to remove item')));

        return buildBloc();
      },
      seed: () => const CartLoaded(cart: testCart),
      act: (bloc) => bloc.add(const CartItemRemoved(testItemId)),
      expect: () => [
        const CartLoaded(cart: testCart, isUpdating: true),
        isA<CartFailure>().having(
          (state) => state.message,
          'failure message',
          'Unable to remove item',
        ),
      ],
    );
  });
}
