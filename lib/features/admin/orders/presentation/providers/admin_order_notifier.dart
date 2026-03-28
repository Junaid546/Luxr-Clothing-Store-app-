import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/features/auth/data/providers/auth_providers.dart';
import 'package:stylecart/features/orders/data/providers/order_providers.dart';
import 'package:stylecart/features/orders/domain/entities/order_entity.dart';
import 'package:stylecart/features/orders/domain/usecases/confirm_return_usecase.dart';
import 'package:stylecart/features/orders/domain/usecases/search_orders_usecase.dart';
import 'package:stylecart/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:stylecart/features/orders/domain/usecases/watch_order_usecase.dart';
import 'package:stylecart/core/constants/firestore_schema.dart';

part 'admin_order_notifier.freezed.dart';
part 'admin_order_notifier.g.dart';

@freezed
class AdminOrderState with _$AdminOrderState {
  const factory AdminOrderState({
    @Default([]) List<OrderEntity> orders,
    @Default(true) bool isLoading,
    @Default(false) bool isSaving,
    @Default(false) bool hasError,
    @Default('') String errorMessage,
    @Default('all') String activeTab,
    @Default('') String searchQuery,
  }) = _AdminOrderState;
}

@riverpod
class AdminOrderNotifier extends _$AdminOrderNotifier {
  StreamSubscription<Either<Failure, List<OrderEntity>>>? _subscription;

  @override
  AdminOrderState build() {
    Future.microtask(() => _watchOrders());
    ref.onDispose(() => _subscription?.cancel());
    return const AdminOrderState(isLoading: true);
  }

  void _watchOrders() {
    _subscription?.cancel();
    _subscription = ref
        .read(orderRepositoryProvider)
        .watchAllOrders(
          statusFilter: state.activeTab == 'all' ? null : state.activeTab,
          limit: 50,
        )
        .listen((Either<Failure, List<OrderEntity>> result) {
      result.fold(
        (Failure failure) => state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: failure.message,
        ),
        (List<OrderEntity> orders) => state = state.copyWith(
          isLoading: false,
          orders: orders,
        ),
      );
    });
  }

  void setTab(String tab) {
    if (state.activeTab == tab) return;
    state = state.copyWith(activeTab: tab, isLoading: true);
    _watchOrders();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  List<OrderEntity> get filteredOrders {
    if (state.searchQuery.isEmpty) return state.orders;

    final q = state.searchQuery.toLowerCase();
    return state.orders
        .where((OrderEntity o) =>
            o.orderId.toLowerCase().contains(q) ||
            o.userEmail.toLowerCase().contains(q) ||
            o.userName.toLowerCase().contains(q))
        .toList();
  }

  Future<Either<Failure, void>> updateStatus({
    required String orderId,
    required String status,
    String? note,
    CourierEntity? courier,
  }) async {
    state = state.copyWith(isSaving: true);

    final adminId = ref.read(currentUserProvider)?.uid ?? 'admin';
    final result = await ref.read(updateOrderStatusUseCaseProvider).call(
          UpdateOrderStatusParams(
            orderId: orderId,
            newStatus: status,
            updatedBy: adminId,
            note: note,
            courier: courier,
          ),
        );

    state = state.copyWith(isSaving: false);
    return result;
  }

  Future<Either<Failure, void>> confirmReturn(OrderEntity order) async {
    state = state.copyWith(isSaving: true);

    final adminId = ref.read(currentUserProvider)?.uid ?? 'admin';
    final result = await ref.read(confirmReturnUseCaseProvider).call(
          ConfirmReturnParams(
            orderId: order.orderId,
            items: order.items,
            adminId: adminId,
          ),
        );

    state = state.copyWith(isSaving: false);
    return result;
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    _watchOrders();
  }
}
