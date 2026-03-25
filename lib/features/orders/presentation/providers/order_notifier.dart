import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/auth/data/providers/auth_providers.dart';
import 'package:style_cart/features/orders/data/providers/order_providers.dart';
import 'package:style_cart/features/orders/domain/entities/order_entity.dart';
import 'package:style_cart/features/orders/domain/usecases/cancel_order_usecase.dart';
import 'package:style_cart/features/orders/domain/usecases/request_return_usecase.dart';

part 'order_notifier.freezed.dart';
part 'order_notifier.g.dart';

// ── My Orders State ───────────────────────────────────
@freezed
class MyOrdersState with _$MyOrdersState {
  const factory MyOrdersState({
    @Default([]) List<OrderEntity> orders,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasError,
    @Default('') String errorMessage,
    @Default('all') String activeFilter,
    @Default(true) bool hasMore,
    Object? lastDocument,
  }) = _MyOrdersState;
}

@riverpod
class MyOrdersNotifier extends _$MyOrdersNotifier {

  StreamSubscription<Either<Failure, List<OrderEntity>>>? _subscription;

  @override
  MyOrdersState build() {
    final user = ref.watch(currentUserProvider);
    if (user != null) _watchOrders(user.uid);
    ref.onDispose(() => _subscription?.cancel());
    return const MyOrdersState(isLoading: true);
  }

  void _watchOrders(String userId) {
    _subscription?.cancel();
    _subscription = ref
        .read(watchUserOrdersUseCaseProvider)
        .call(userId)
        .listen((result) {
          result.fold(
            (failure) => state = state.copyWith(
              isLoading: false,
              hasError: true,
              errorMessage: failure.message,
            ),
            (orders) {
              // Apply client-side filter
              final filtered = state.activeFilter == 'all'
                  ? orders
                  : orders.where((o) =>
                      o.status == state.activeFilter ||
                      // Group shipped + out_for_delivery
                      (state.activeFilter == 'shipped' &&
                       o.isShipped)
                    ).toList();

              state = state.copyWith(
                isLoading: false,
                orders: filtered,
              );
            },
          );
        });
  }

  void filterByStatus(String status) {
    state = state.copyWith(activeFilter: status, isLoading: true);
    final user = ref.read(currentUserProvider);
    if (user != null) _watchOrders(user.uid);
  }

  // ── Action: Cancel order ──────────────────────────
  Future<Either<Failure, void>> cancelOrder(
    OrderEntity order,
    String? reason,
  ) async {
    final userId = ref.read(currentUserProvider)?.uid ?? '';
    return ref.read(cancelOrderUseCaseProvider).call(
      CancelOrderParams(
        orderId: order.orderId,
        userId:  userId,
        items:   order.items,
        reason:  reason,
      ),
    );
  }

  // ── Action: Request return ────────────────────────
  Future<Either<Failure, void>> requestReturn(
    String orderId,
    String reason,
  ) async {
    final userId = ref.read(currentUserProvider)?.uid ?? '';
    return ref.read(requestReturnUseCaseProvider).call(
      RequestReturnParams(
        orderId: orderId,
        userId:  userId,
        reason:  reason,
      ),
    );
  }
}

// ── Single Order Tracking State ───────────────────────
@riverpod
class OrderTrackingNotifier
    extends _$OrderTrackingNotifier {

  StreamSubscription<Either<Failure, OrderEntity>>? _subscription;

  @override
  AsyncValue<OrderEntity> build(String orderId) {
    _watchOrder(orderId);
    ref.onDispose(() => _subscription?.cancel());
    return const AsyncValue.loading();
  }

  void _watchOrder(String orderId) {
    _subscription?.cancel();
    _subscription = ref
        .read(watchOrderUseCaseProvider)
        .call(orderId)
        .listen(
          (result) {
            result.fold(
              (failure) => state = AsyncValue.error(
                failure.message,
                StackTrace.current,
              ),
              (order) => state = AsyncValue.data(order),
            );
          },
          onError: (Object e, StackTrace st) =>
              state = AsyncValue.error(e, st),
        );
  }
}
