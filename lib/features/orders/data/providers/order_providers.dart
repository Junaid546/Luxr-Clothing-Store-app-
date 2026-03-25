import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/providers/firebase_providers.dart';
import 'package:style_cart/features/orders/data/repositories/order_repository_impl.dart';
import 'package:style_cart/features/orders/domain/repositories/order_repository.dart';
import 'package:style_cart/features/orders/domain/usecases/cancel_order_usecase.dart';
import 'package:style_cart/features/orders/domain/usecases/confirm_return_usecase.dart';
import 'package:style_cart/features/orders/domain/usecases/get_all_orders_usecase.dart';
import 'package:style_cart/features/orders/domain/usecases/get_user_orders_usecase.dart';
import 'package:style_cart/features/orders/domain/usecases/request_return_usecase.dart';
import 'package:style_cart/features/orders/domain/usecases/search_orders_usecase.dart';
import 'package:style_cart/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:style_cart/features/orders/domain/usecases/watch_order_usecase.dart';
import 'package:style_cart/features/orders/domain/usecases/watch_user_orders_usecase.dart';

part 'order_providers.g.dart';

@riverpod
OrderRepository orderRepository(OrderRepositoryRef ref) =>
    OrderRepositoryImpl(ref.watch(firestoreProvider));

// ── Use Case Providers ────────────────────────────────────────

@riverpod
WatchOrderUseCase watchOrderUseCase(
  WatchOrderUseCaseRef ref,
) => WatchOrderUseCase(ref.watch(orderRepositoryProvider));

@riverpod
WatchUserOrdersUseCase watchUserOrdersUseCase(
  WatchUserOrdersUseCaseRef ref,
) => WatchUserOrdersUseCase(
       ref.watch(orderRepositoryProvider));

@riverpod
GetUserOrdersUseCase getUserOrdersUseCase(
  GetUserOrdersUseCaseRef ref,
) => GetUserOrdersUseCase(
       ref.watch(orderRepositoryProvider));

@riverpod
CancelOrderUseCase cancelOrderUseCase(
  CancelOrderUseCaseRef ref,
) => CancelOrderUseCase(ref.watch(orderRepositoryProvider));

@riverpod
RequestReturnUseCase requestReturnUseCase(
  RequestReturnUseCaseRef ref,
) => RequestReturnUseCase(
       ref.watch(orderRepositoryProvider));

@riverpod
UpdateOrderStatusUseCase updateOrderStatusUseCase(
  UpdateOrderStatusUseCaseRef ref,
) => UpdateOrderStatusUseCase(
       ref.watch(orderRepositoryProvider));

@riverpod
ConfirmReturnUseCase confirmReturnUseCase(
  ConfirmReturnUseCaseRef ref,
) => ConfirmReturnUseCase(
       ref.watch(orderRepositoryProvider));

@riverpod
GetAllOrdersUseCase getAllOrdersUseCase(
  GetAllOrdersUseCaseRef ref,
) => GetAllOrdersUseCase(
       ref.watch(orderRepositoryProvider));

@riverpod
SearchOrdersUseCase searchOrdersUseCase(
  SearchOrdersUseCaseRef ref,
) => SearchOrdersUseCase(
       ref.watch(orderRepositoryProvider));
