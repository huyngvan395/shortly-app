import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:shortly_app/core/errors/exception.dart';
import 'package:shortly_app/core/errors/failure.dart';
import 'package:shortly_app/features/ecommerce/cart/data/datasources/cart_remote_datasource.dart';
import 'package:shortly_app/features/ecommerce/cart/data/models/cart_model.dart';
import 'package:shortly_app/features/ecommerce/cart/data/repositories/cart_repository_impl.dart';

class MockCartRemoteDataSource extends Mock implements CartRemoteDataSource {}

void main() {
  late MockCartRemoteDataSource mockRemoteDataSource;
  late CartRepositoryImpl repository;

  const testCartModel = CartModel(id: 'cart-001', userId: 'user-001');

  setUp(() {
    mockRemoteDataSource = MockCartRemoteDataSource();
    repository = CartRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('CartRepositoryImpl - getCart', () {
    test('returns Cart when remote data source succeeds', () async {
      when(
        () => mockRemoteDataSource.getCart(),
      ).thenAnswer((_) async => testCartModel);

      final result = await repository.getCart();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected Right'), (cart) {
        expect(cart.id, 'cart-001');
        expect(cart.userId, 'user-001');
      });

      verify(() => mockRemoteDataSource.getCart()).called(1);
    });

    test('returns AuthFailure when AuthException occurs', () async {
      when(
        () => mockRemoteDataSource.getCart(),
      ).thenAnswer((_) => Future.error(const AuthException('Unauthorized')));

      final result = await repository.getCart();

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Unauthorized');
      }, (_) => fail('Expected AuthFailure'));
    });

    test('returns ServerFailure when ServerException occurs', () async {
      when(
        () => mockRemoteDataSource.getCart(),
      ).thenAnswer((_) => Future.error(const ServerException('Server error')));

      final result = await repository.getCart();

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Server error');
      }, (_) => fail('Expected ServerFailure'));
    });

    test('returns UnknownFailure when unexpected exception occurs', () async {
      when(
        () => mockRemoteDataSource.getCart(),
      ).thenAnswer((_) => Future.error(Exception('Unexpected error')));

      final result = await repository.getCart();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected UnknownFailure'),
      );
    });
  });

  group('CartRepositoryImpl - addToCart', () {
    test('returns Cart when remote data source succeeds', () async {
      when(
        () => mockRemoteDataSource.addToCart(
          productId: 'product-001',
          variantId: null,
          qty: 2,
        ),
      ).thenAnswer((_) async => testCartModel);

      final result = await repository.addToCart(
        productId: 'product-001',
        qty: 2,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (cart) => expect(cart.id, 'cart-001'),
      );

      verify(
        () => mockRemoteDataSource.addToCart(
          productId: 'product-001',
          variantId: null,
          qty: 2,
        ),
      ).called(1);
    });

    test('returns AuthFailure when AuthException occurs', () async {
      when(
        () => mockRemoteDataSource.addToCart(
          productId: 'product-001',
          variantId: null,
          qty: 1,
        ),
      ).thenAnswer((_) => Future.error(const AuthException('Unauthorized')));

      final result = await repository.addToCart(productId: 'product-001');

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Unauthorized');
      }, (_) => fail('Expected AuthFailure'));
    });

    test('returns ServerFailure when ServerException occurs', () async {
      when(
        () => mockRemoteDataSource.addToCart(
          productId: 'product-001',
          variantId: null,
          qty: 1,
        ),
      ).thenAnswer((_) => Future.error(const ServerException('Server error')));

      final result = await repository.addToCart(productId: 'product-001');

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Server error');
      }, (_) => fail('Expected ServerFailure'));
    });

    test('returns UnknownFailure when unexpected exception occurs', () async {
      when(
        () => mockRemoteDataSource.addToCart(
          productId: 'product-001',
          variantId: null,
          qty: 1,
        ),
      ).thenAnswer((_) => Future.error(Exception('Unexpected error')));

      final result = await repository.addToCart(productId: 'product-001');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected UnknownFailure'),
      );
    });
  });

  group('CartRepositoryImpl - updateCartItemQty', () {
    test('returns Cart when remote data source succeeds', () async {
      when(
        () =>
            mockRemoteDataSource.updateCartItemQty(itemId: 'item-001', qty: 3),
      ).thenAnswer((_) async => testCartModel);

      final result = await repository.updateCartItemQty(
        itemId: 'item-001',
        qty: 3,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (cart) => expect(cart.id, 'cart-001'),
      );

      verify(
        () =>
            mockRemoteDataSource.updateCartItemQty(itemId: 'item-001', qty: 3),
      ).called(1);
    });

    test('returns AuthFailure when AuthException occurs', () async {
      when(
        () =>
            mockRemoteDataSource.updateCartItemQty(itemId: 'item-001', qty: 3),
      ).thenAnswer((_) => Future.error(const AuthException('Unauthorized')));

      final result = await repository.updateCartItemQty(
        itemId: 'item-001',
        qty: 3,
      );

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Unauthorized');
      }, (_) => fail('Expected AuthFailure'));
    });

    test('returns ServerFailure when ServerException occurs', () async {
      when(
        () =>
            mockRemoteDataSource.updateCartItemQty(itemId: 'item-001', qty: 3),
      ).thenAnswer((_) => Future.error(const ServerException('Server error')));

      final result = await repository.updateCartItemQty(
        itemId: 'item-001',
        qty: 3,
      );

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Server error');
      }, (_) => fail('Expected ServerFailure'));
    });

    test('returns UnknownFailure when unexpected exception occurs', () async {
      when(
        () =>
            mockRemoteDataSource.updateCartItemQty(itemId: 'item-001', qty: 3),
      ).thenAnswer((_) => Future.error(Exception('Unexpected error')));

      final result = await repository.updateCartItemQty(
        itemId: 'item-001',
        qty: 3,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected UnknownFailure'),
      );
    });
  });

  group('CartRepositoryImpl - removeCartItem', () {
    test('returns Cart when remote data source succeeds', () async {
      when(
        () => mockRemoteDataSource.removeCartItem('item-001'),
      ).thenAnswer((_) async => testCartModel);

      final result = await repository.removeCartItem('item-001');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (cart) => expect(cart.id, 'cart-001'),
      );

      verify(() => mockRemoteDataSource.removeCartItem('item-001')).called(1);
    });

    test('returns AuthFailure when AuthException occurs', () async {
      when(
        () => mockRemoteDataSource.removeCartItem('item-001'),
      ).thenAnswer((_) => Future.error(const AuthException('Unauthorized')));

      final result = await repository.removeCartItem('item-001');

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Unauthorized');
      }, (_) => fail('Expected AuthFailure'));
    });

    test('returns ServerFailure when ServerException occurs', () async {
      when(
        () => mockRemoteDataSource.removeCartItem('item-001'),
      ).thenAnswer((_) => Future.error(const ServerException('Server error')));

      final result = await repository.removeCartItem('item-001');

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Server error');
      }, (_) => fail('Expected ServerFailure'));
    });

    test('returns UnknownFailure when unexpected exception occurs', () async {
      when(
        () => mockRemoteDataSource.removeCartItem('item-001'),
      ).thenAnswer((_) => Future.error(Exception('Unexpected error')));

      final result = await repository.removeCartItem('item-001');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected UnknownFailure'),
      );
    });
  });
}
