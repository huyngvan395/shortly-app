import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:shortly_app/core/errors/exception.dart';
import 'package:shortly_app/core/errors/failure.dart';
import 'package:shortly_app/features/ecommerce/order/data/datasources/order_remote_datasource.dart';
import 'package:shortly_app/features/ecommerce/order/data/models/ecommerce_order_model.dart';
import 'package:shortly_app/features/ecommerce/order/data/repositories/order_repository_impl.dart';

class MockOrderRemoteDataSource extends Mock implements OrderRemoteDataSource {}

void main() {
  late MockOrderRemoteDataSource remoteDataSource;
  late OrderRepositoryImpl repository;

  const testOrderModel = EcommerceOrderModel(
    id: 'order-001',
    buyerId: 'user-001',
    shopId: 'shop-001',
    orderCode: 'ORD-001',
    status: 'pending',
    subtotalAmount: 100000,
    discountAmount: 0,
    shippingAmount: 15000,
    totalAmount: 115000,
    currency: 'VND',
    addressSnapshot: {},
  );

  setUp(() {
    remoteDataSource = MockOrderRemoteDataSource();
    repository = OrderRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  group('getOrders', () {
    test('returns list of orders when successful', () async {
      when(
        () => remoteDataSource.getOrders(status: null),
      ).thenAnswer((_) async => [testOrderModel]);

      final result = await repository.getOrders();

      expect(result.isRight(), true);

      result.fold((_) => fail('Expected a list of orders'), (orders) {
        expect(orders.length, 1);
        expect(orders.first.id, 'order-001');
        expect(orders.first.buyerId, 'user-001');
        expect(orders.first.orderCode, 'ORD-001');
        expect(orders.first.totalAmount, 115000);
      });

      verify(() => remoteDataSource.getOrders(status: null)).called(1);
    });

    test('passes status filter to remote data source', () async {
      when(
        () => remoteDataSource.getOrders(status: 'pending'),
      ).thenAnswer((_) async => [testOrderModel]);

      final result = await repository.getOrders(status: 'pending');

      expect(result.isRight(), true);

      verify(() => remoteDataSource.getOrders(status: 'pending')).called(1);
    });

    test('returns AuthFailure when AuthException is thrown', () async {
      when(
        () => remoteDataSource.getOrders(status: null),
      ).thenAnswer((_) => Future.error(const AuthException('Please sign in')));

      final result = await repository.getOrders();

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Please sign in');
      }, (_) => fail('Expected AuthFailure'));
    });

    test('returns ServerFailure when ServerException is thrown', () async {
      when(
        () => remoteDataSource.getOrders(status: null),
      ).thenAnswer((_) => Future.error(const ServerException('Server error')));

      final result = await repository.getOrders();

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Server error');
      }, (_) => fail('Expected ServerFailure'));
    });

    test('returns UnknownFailure when unexpected error occurs', () async {
      when(
        () => remoteDataSource.getOrders(status: null),
      ).thenAnswer((_) => Future.error(Exception('Unexpected error')));

      final result = await repository.getOrders();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected UnknownFailure'),
      );
    });
  });

  group('getOrderDetail', () {
    const orderId = 'order-001';

    test('returns order detail when successful', () async {
      when(
        () => remoteDataSource.getOrderDetail(orderId),
      ).thenAnswer((_) async => testOrderModel);

      final result = await repository.getOrderDetail(orderId);

      expect(result.isRight(), true);

      result.fold((_) => fail('Expected order detail'), (order) {
        expect(order.id, 'order-001');
        expect(order.buyerId, 'user-001');
        expect(order.orderCode, 'ORD-001');
        expect(order.totalAmount, 115000);
      });

      verify(() => remoteDataSource.getOrderDetail(orderId)).called(1);
    });

    test('returns AuthFailure when AuthException is thrown', () async {
      when(
        () => remoteDataSource.getOrderDetail(orderId),
      ).thenAnswer((_) => Future.error(const AuthException('Please sign in')));

      final result = await repository.getOrderDetail(orderId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Please sign in');
      }, (_) => fail('Expected AuthFailure'));
    });

    test('returns NotFoundFailure when NotFoundException is thrown', () async {
      when(() => remoteDataSource.getOrderDetail(orderId)).thenAnswer(
        (_) => Future.error(const NotFoundException('Order not found')),
      );

      final result = await repository.getOrderDetail(orderId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<NotFoundFailure>());
        expect(failure.message, 'Order not found');
      }, (_) => fail('Expected NotFoundFailure'));
    });

    test('returns ServerFailure when ServerException is thrown', () async {
      when(
        () => remoteDataSource.getOrderDetail(orderId),
      ).thenAnswer((_) => Future.error(const ServerException('Server error')));

      final result = await repository.getOrderDetail(orderId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Server error');
      }, (_) => fail('Expected ServerFailure'));
    });

    test('returns UnknownFailure when unexpected error occurs', () async {
      when(
        () => remoteDataSource.getOrderDetail(orderId),
      ).thenAnswer((_) => Future.error(Exception('Unexpected error')));

      final result = await repository.getOrderDetail(orderId);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected UnknownFailure'),
      );
    });
  });

  group('cancelOrder', () {
    const orderId = 'order-001';

    test('returns updated order when cancellation succeeds', () async {
      when(
        () => remoteDataSource.cancelOrder(orderId),
      ).thenAnswer((_) async => testOrderModel);

      final result = await repository.cancelOrder(orderId);

      expect(result.isRight(), true);

      result.fold((_) => fail('Expected updated order'), (order) {
        expect(order.id, 'order-001');
        expect(order.orderCode, 'ORD-001');
        expect(order.status, 'pending');
      });

      verify(() => remoteDataSource.cancelOrder(orderId)).called(1);
    });

    test('returns AuthFailure when AuthException is thrown', () async {
      when(
        () => remoteDataSource.cancelOrder(orderId),
      ).thenAnswer((_) => Future.error(const AuthException('Please sign in')));

      final result = await repository.cancelOrder(orderId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Please sign in');
      }, (_) => fail('Expected AuthFailure'));
    });

    test('returns NotFoundFailure when NotFoundException is thrown', () async {
      when(() => remoteDataSource.cancelOrder(orderId)).thenAnswer(
        (_) => Future.error(const NotFoundException('Order not found')),
      );

      final result = await repository.cancelOrder(orderId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<NotFoundFailure>());
        expect(failure.message, 'Order not found');
      }, (_) => fail('Expected NotFoundFailure'));
    });

    test('returns ServerFailure when ServerException is thrown', () async {
      when(
        () => remoteDataSource.cancelOrder(orderId),
      ).thenAnswer((_) => Future.error(const ServerException('Server error')));

      final result = await repository.cancelOrder(orderId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Server error');
      }, (_) => fail('Expected ServerFailure'));
    });

    test('returns UnknownFailure when unexpected error occurs', () async {
      when(
        () => remoteDataSource.cancelOrder(orderId),
      ).thenAnswer((_) => Future.error(Exception('Unexpected error')));

      final result = await repository.cancelOrder(orderId);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected UnknownFailure'),
      );
    });
  });

  group('confirmOrderDelivered', () {
    const orderId = 'order-001';

    const completedOrderModel = EcommerceOrderModel(
      id: 'order-001',
      buyerId: 'user-001',
      shopId: 'shop-001',
      orderCode: 'ORD-001',
      status: 'completed',
      subtotalAmount: 100000,
      discountAmount: 0,
      shippingAmount: 15000,
      totalAmount: 115000,
      currency: 'VND',
      addressSnapshot: {},
    );

    test('returns completed order when confirmation succeeds', () async {
      when(
        () => remoteDataSource.confirmOrderDelivered(orderId),
      ).thenAnswer((_) async => completedOrderModel);

      final result = await repository.confirmOrderDelivered(orderId);

      expect(result.isRight(), isTrue);

      result.fold((_) => fail('Expected completed order'), (order) {
        expect(order.id, orderId);
        expect(order.status, 'completed');
        expect(order.orderCode, 'ORD-001');
      });

      verify(() => remoteDataSource.confirmOrderDelivered(orderId)).called(1);
    });

    test('returns AuthFailure when AuthException occurs', () async {
      when(
        () => remoteDataSource.confirmOrderDelivered(orderId),
      ).thenAnswer((_) => Future.error(const AuthException('Please sign in')));

      final result = await repository.confirmOrderDelivered(orderId);

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Please sign in');
      }, (_) => fail('Expected AuthFailure'));
    });

    test('returns NotFoundFailure when NotFoundException occurs', () async {
      when(() => remoteDataSource.confirmOrderDelivered(orderId)).thenAnswer(
        (_) => Future.error(const NotFoundException('Order not found')),
      );

      final result = await repository.confirmOrderDelivered(orderId);

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<NotFoundFailure>());
        expect(failure.message, 'Order not found');
      }, (_) => fail('Expected NotFoundFailure'));
    });

    test('returns ServerFailure when ServerException occurs', () async {
      when(
        () => remoteDataSource.confirmOrderDelivered(orderId),
      ).thenAnswer((_) => Future.error(const ServerException('Server error')));

      final result = await repository.confirmOrderDelivered(orderId);

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Server error');
      }, (_) => fail('Expected ServerFailure'));
    });

    test('returns UnknownFailure when unexpected exception occurs', () async {
      when(
        () => remoteDataSource.confirmOrderDelivered(orderId),
      ).thenAnswer((_) => Future.error(Exception('Unexpected error')));

      final result = await repository.confirmOrderDelivered(orderId);

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<UnknownFailure>());
      }, (_) => fail('Expected UnknownFailure'));
    });
  });
}
