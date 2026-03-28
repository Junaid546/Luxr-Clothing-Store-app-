import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_engine.freezed.dart';

// ── Pagination State ──────────────────────────────────
@freezed
class PaginationState<T> with _$PaginationState<T> {
  const factory PaginationState({
    @Default([]) List<T> items,
    @Default(true) bool hasMore,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasError,
    @Default('') String errorMessage,
    Object? lastDocumentSnapshot, // Firestore cursor
    @Default(0) int pageIndex,
    @Default(0) int totalLoaded,
  }) = _PaginationState<T>;

  const PaginationState._();

  bool get isEmpty => !isLoading && !hasError && items.isEmpty;

  bool get isFirstLoad => pageIndex == 0 && isLoading;

  bool get canLoadMore => hasMore && !isLoading && !isLoadingMore;
}

// ── Pagination Controller ─────────────────────────────
// Abstract class — extend for each paginated list.
abstract class PaginationController<T> extends StateNotifier<PaginationState<T>> {
  PaginationController() : super(const PaginationState());

  // Page size for this controller
  int get pageSize => 20;

  // Override this to fetch data from Firestore
  Future<List<T>> fetchPage({
    required int limit,
    Object? lastDocument,
  });

  // Get Firestore snapshot cursor from item
  // Override if T provides document snapshot
  Object? getCursor(T item) => null;

  // ── Load first page ────────────────────────────────
  Future<void> loadFirstPage() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      hasError: false,
      items: [],
      lastDocumentSnapshot: null,
      pageIndex: 0,
      hasMore: true,
    );

    try {
      final items = await fetchPage(
        limit: pageSize,
        lastDocument: null,
      );

      state = state.copyWith(
        isLoading: false,
        items: items,
        hasMore: items.length >= pageSize,
        pageIndex: 1,
        totalLoaded: items.length,
        lastDocumentSnapshot: items.isNotEmpty ? getCursor(items.last) : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Load next page ─────────────────────────────────
  Future<void> loadNextPage() async {
    if (!state.canLoadMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final newItems = await fetchPage(
        limit: pageSize,
        lastDocument: state.lastDocumentSnapshot,
      );

      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...newItems],
        hasMore: newItems.length >= pageSize,
        pageIndex: state.pageIndex + 1,
        totalLoaded: state.totalLoaded + newItems.length,
        lastDocumentSnapshot: newItems.isNotEmpty ? getCursor(newItems.last) : state.lastDocumentSnapshot,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Refresh (pull-to-refresh) ──────────────────────
  Future<void> refresh() => loadFirstPage();

  // ── Optimistic UI Helpers ──────────────────────────
  void prependItem(T item) {
    state = state.copyWith(items: [item, ...state.items]);
  }

  void removeItem(bool Function(T) matcher) {
    state = state.copyWith(items: state.items.where((i) => !matcher(i)).toList());
  }

  void updateItem(bool Function(T) matcher, T Function(T) updater) {
    state = state.copyWith(
      items: state.items.map((i) => matcher(i) ? updater(i) : i).toList(),
    );
  }
}

// ── Scroll controller mixin for auto-load-more ────────
mixin PaginationScrollMixin<T extends StatefulWidget> on State<T> {
  late final ScrollController paginationScrollController;
  VoidCallback? _onLoadMore;

  void initPaginationScroll({
    required VoidCallback onLoadMore,
    double triggerOffset = 300, // px from bottom
  }) {
    _onLoadMore = onLoadMore;
    paginationScrollController = ScrollController();
    paginationScrollController.addListener(() {
      final position = paginationScrollController.position;
      if (position.pixels >= position.maxScrollExtent - triggerOffset) {
        _onLoadMore?.call();
      }
    });
  }

  @override
  void dispose() {
    paginationScrollController.dispose();
    super.dispose();
  }
}
