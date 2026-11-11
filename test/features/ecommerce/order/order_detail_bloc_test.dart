import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:shortly_app/core/errors/failure.dart';
import 'package:shortly_app/features/ecommerce/order/domain/entities/ecommerce_order.dart';
import 'package:shortly_app/features/ecommerce/order/domain/usecases/get_order_detail_usecase.dart';
import 'package:shortly_app/features/ecommerce/order/domain/usecases/cancel_order_usecase.dart';
import 'package:shortly_app/features/ecommerce/order/domain/usecases/confirm_order_delivered_usecase.dart';
import 'package:shortly_app/features/ecommerce/order/presentation/bloc/order_detail/order_detail_bloc.dart';
import 'package:shortly_app/features/ecommerce/order/presentation/bloc/order_detail/order_detail_event.dart';
import 'package:shortly_app/features/ecommerce/order/presentation/bloc/order_detail/order_detail_state.dart';

class MockGetOrderDetailUseCase extends Mock implements GetOrderDetailUseCase {}

class MockCancelOrderUseCase extends Mock implements CancelOrderUseCase {}

class MockConfirmOrderDeliveredUseCase extends Mock
    implements ConfirmOrderDeliveredUseCase {}

void main() {
  late MockGetOrderDetailUseCase mockGetOrderDetailUseCase;
  late MockCancelOrderUseCase mockCancelOrderUseCase;
  late MockConfirmOrderDeliveredUseCase mockConfirmOrderDeliveredUseCase;

  late OrderDetailBloc bloc;

  const orderId = 'order-001';
  const cancellationReason = 'Changed my mind';

  final pendingOrder = buildOrder(status: 'pending');
  final paidOrder = buildOrder(status: 'paid');
  final shippingOrder = buildOrder(status: 'shipping');
  final cancelledOrder = buildOrder(status: 'cancelled');
  final completedOrder = buildOrder(status: 'completed');

  OrderDetailBloc buildBloc() {
    return OrderDetailBloc(
      getOrderDetailUseCase: mockGetOrderDetailUseCase,
      cancelOrderUseCase: mockCancelOrderUseCase,
      confirmOrderDeliveredUseCase: mockConfirmOrderDeliveredUseCase,
    );
  }

  setUp(() {
    mockGetOrderDetailUseCase = MockGetOrderDetailUseCase();
    mockCancelOrderUseCase = MockCancelOrderUseCase();
    mockConfirmOrderDeliveredUseCase = MockConfirmOrderDeliveredUseCase();

    bloc = buildBloc();
  });

  tearDown(() async {
    await bloc.close();
  });

  group('OrderDetailBloc', () {
    test('initial state is OrderDetailInitial', () {
      expect(bloc.state, const OrderDetailInitial());
    });

    // Request order detail

    blocTest<OrderDetailBloc, OrderDetailState>(
      'emits Loading and Loaded when request succeeds',
      build: () {
        when(
          () => mockGetOrderDetailUseCase(orderId),
        ).thenAnswer((_) async => Right<Failure, EcommerceOrder>(pendingOrder));

        return buildBloc();
      },
      act: (bloc) => bloc.add(const OrderDetailRequested(orderId)),
      expect: () => [
        const OrderDetailLoading(),
        OrderDetailLoaded(pendingOrder),
      ],
      verify: (_) {
        verify(() => mockGetOrderDetailUseCase(orderId)).called(1);
      },
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'emits OrderDetailFailure when request fails',
      build: () {
        when(() => mockGetOrderDetailUseCase(orderId)).thenAnswer(
          (_) async => Left<Failure, EcommerceOrder>(
            ServerFailure('Unable to load order'),
          ),
        );

        return buildBloc();
      },
      act: (bloc) => bloc.add(const OrderDetailRequested(orderId)),
      expect: () => [
        const OrderDetailLoading(),
        const OrderDetailFailure('Unable to load order'),
      ],
    );

    // Cancel order

    blocTest<OrderDetailBloc, OrderDetailState>(
      'emits Cancelling and CancelSuccess when cancellation succeeds',
      build: () {
        when(
          () => mockCancelOrderUseCase(orderId, reason: cancellationReason),
        ).thenAnswer(
          (_) async => Right<Failure, EcommerceOrder>(cancelledOrder),
        );

        return buildBloc();
      },
      seed: () => OrderDetailLoaded(pendingOrder),
      act: (bloc) => bloc.add(
        const OrderCancelRequested(orderId, reason: cancellationReason),
      ),
      expect: () => [
        OrderDetailCancelling(pendingOrder),
        OrderDetailCancelSuccess(cancelledOrder),
      ],
      verify: (_) {
        verify(
          () => mockCancelOrderUseCase(orderId, reason: cancellationReason),
        ).called(1);
      },
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'emits CancelFailure when cancellation fails',
      build: () {
        when(() => mockCancelOrderUseCase(orderId, reason: null)).thenAnswer(
          (_) async => Left<Failure, EcommerceOrder>(
            ServerFailure('Unable to cancel order'),
          ),
        );

        return buildBloc();
      },
      seed: () => OrderDetailLoaded(pendingOrder),
      act: (bloc) => bloc.add(const OrderCancelRequested(orderId)),
      expect: () => [
        OrderDetailCancelling(pendingOrder),
        OrderDetailCancelFailure(
          order: pendingOrder,
          message: 'Unable to cancel order',
        ),
      ],
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'does not cancel when order status is shipping',
      build: () => buildBloc(),
      seed: () => OrderDetailLoaded(shippingOrder),
      act: (bloc) => bloc.add(const OrderCancelRequested(orderId)),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockCancelOrderUseCase(orderId, reason: null));
      },
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'does not cancel when no order is loaded',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const OrderCancelRequested(orderId)),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockCancelOrderUseCase(orderId, reason: null));
      },
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'allows cancellation when order status is paid',
      build: () {
        when(() => mockCancelOrderUseCase(orderId, reason: null)).thenAnswer(
          (_) async => Right<Failure, EcommerceOrder>(cancelledOrder),
        );

        return buildBloc();
      },
      seed: () => OrderDetailLoaded(paidOrder),
      act: (bloc) => bloc.add(const OrderCancelRequested(orderId)),
      expect: () => [
        OrderDetailCancelling(paidOrder),
        OrderDetailCancelSuccess(cancelledOrder),
      ],
    );

    // Confirm order delivered

    blocTest<OrderDetailBloc, OrderDetailState>(
      'emits Confirming and ConfirmDeliverySuccess when confirmation succeeds',
      build: () {
        when(() => mockConfirmOrderDeliveredUseCase(orderId)).thenAnswer(
          (_) async => Right<Failure, EcommerceOrder>(completedOrder),
        );

        return buildBloc();
      },
      seed: () => OrderDetailLoaded(shippingOrder),
      act: (bloc) => bloc.add(const OrderConfirmDeliveredRequested(orderId)),
      expect: () => [
        OrderDetailConfirmingDelivery(shippingOrder),
        OrderDetailConfirmDeliverySuccess(completedOrder),
      ],
      verify: (_) {
        verify(() => mockConfirmOrderDeliveredUseCase(orderId)).called(1);
      },
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'emits ConfirmDeliveryFailure when confirmation fails',
      build: () {
        when(() => mockConfirmOrderDeliveredUseCase(orderId)).thenAnswer(
          (_) async => Left<Failure, EcommerceOrder>(
            ServerFailure('Unable to confirm delivery'),
          ),
        );

        return buildBloc();
      },
      seed: () => OrderDetailLoaded(shippingOrder),
      act: (bloc) => bloc.add(const OrderConfirmDeliveredRequested(orderId)),
      expect: () => [
        OrderDetailConfirmingDelivery(shippingOrder),
        OrderDetailConfirmDeliveryFailure(
          order: shippingOrder,
          message: 'Unable to confirm delivery',
        ),
      ],
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'does not confirm delivery when order status is pending',
      build: () => buildBloc(),
      seed: () => OrderDetailLoaded(pendingOrder),
      act: (bloc) => bloc.add(const OrderConfirmDeliveredRequested(orderId)),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockConfirmOrderDeliveredUseCase(orderId));
      },
    );
  });
}

EcommerceOrder buildOrder({required String status}) {
  return EcommerceOrder(
    id: 'order-001',
    buyerId: 'buyer-001',
    shopId: 'shop-001',
    orderCode: 'ORD-001',
    status: status,
    subtotalAmount: 100000,
    discountAmount: 0,
    shippingAmount: 15000,
    totalAmount: 115000,
    currency: 'VND',
    addressSnapshot: const {},
  );
}
