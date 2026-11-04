import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:shortly_app/core/errors/failure.dart';
import 'package:shortly_app/features/ecommerce/order/domain/entities/ecommerce_order.dart';
import 'package:shortly_app/features/ecommerce/order/domain/repositories/order_repository.dart';
import 'package:shortly_app/features/ecommerce/order/domain/usecases/get_orders_usecase.dart';
import 'package:shortly_app/features/ecommerce/order/presentation/bloc/order_list/order_list_bloc.dart';
import 'package:shortly_app/features/ecommerce/order/presentation/bloc/order_list/order_list_event.dart';
import 'package:shortly_app/features/ecommerce/order/presentation/bloc/order_list/order_list_state.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late MockOrderRepository mockOrderRepository;
  late GetOrdersUseCase getOrdersUseCase;

  const testStatus = 'pending';

  final testOrders = <EcommerceOrder>[];

  OrderListBloc buildBloc() {
    return OrderListBloc(getOrdersUseCase: getOrdersUseCase);
  }

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    getOrdersUseCase = GetOrdersUseCase(mockOrderRepository);
  });

  group('OrderListBloc', () {
    test('initial state is OrderListInitial', () {
      final bloc = buildBloc();

      expect(bloc.state, equals(const OrderListInitial()));

      bloc.close();
    });

    blocTest<OrderListBloc, OrderListState>(
      'emits [OrderListLoading, OrderListLoaded] when request succeeds',
      build: () {
        when(
          () => mockOrderRepository.getOrders(status: null),
        ).thenAnswer((_) async => Right(testOrders));

        return buildBloc();
      },
      act: (bloc) => bloc.add(const OrderListRequested()),
      expect: () => [
        const OrderListLoading(),
        OrderListLoaded(orders: testOrders),
      ],
      verify: (_) {
        verify(() => mockOrderRepository.getOrders(status: null)).called(1);
      },
    );

    blocTest<OrderListBloc, OrderListState>(
      'emits loading and loaded states with the requested status',
      build: () {
        when(
          () => mockOrderRepository.getOrders(status: testStatus),
        ).thenAnswer((_) async => Right(testOrders));

        return buildBloc();
      },
      act: (bloc) => bloc.add(const OrderListRequested(status: testStatus)),
      expect: () => [
        const OrderListLoading(status: testStatus),
        OrderListLoaded(orders: testOrders, status: testStatus),
      ],
      verify: (_) {
        verify(
          () => mockOrderRepository.getOrders(status: testStatus),
        ).called(1);
      },
    );

    blocTest<OrderListBloc, OrderListState>(
      'emits OrderListFailure when request fails',
      build: () {
        when(
          () => mockOrderRepository.getOrders(status: null),
        ).thenAnswer((_) async => Left(ServerFailure('Unable to load orders')));

        return buildBloc();
      },
      act: (bloc) => bloc.add(const OrderListRequested()),
      expect: () => [
        const OrderListLoading(),
        isA<OrderListFailure>().having(
          (state) => state.message,
          'failure message',
          'Unable to load orders',
        ),
      ],
    );

    blocTest<OrderListBloc, OrderListState>(
      'preserves requested status when request fails',
      build: () {
        when(
          () => mockOrderRepository.getOrders(status: testStatus),
        ).thenAnswer((_) async => Left(ServerFailure('Unable to load orders')));

        return buildBloc();
      },
      act: (bloc) => bloc.add(const OrderListRequested(status: testStatus)),
      expect: () => [
        const OrderListLoading(status: testStatus),
        isA<OrderListFailure>()
            .having(
              (state) => state.message,
              'failure message',
              'Unable to load orders',
            )
            .having((state) => state.status, 'requested status', testStatus),
      ],
    );
  });
}
