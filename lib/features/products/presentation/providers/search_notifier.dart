// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylecart/features/products/data/providers/product_data_providers.dart';
import 'package:stylecart/features/products/domain/entities/product_entity.dart';

part 'search_notifier.freezed.dart';
part 'search_notifier.g.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    @Default('') String query,
    @Default([]) List<ProductEntity> results,
    @Default([]) List<String> recentSearches,
    @Default(false) bool isSearching,
    @Default(false) bool hasError,
    @Default('') String errorMessage,
  }) = _SearchState;
}

@riverpod
class SearchNotifier extends _$SearchNotifier {
  Timer? _debounceTimer;

  @override
  SearchState build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    _loadRecentSearches();
    return const SearchState();
  }

  // ── Search with debounce (300ms) ──────────────────
  void onQueryChanged(String query) {
    state = state.copyWith(query: query);
    _debounceTimer?.cancel();

    if (query.trim().length < 2) {
      state = state.copyWith(results: [], isSearching: false);
      return;
    }

    _debounceTimer = Timer(
      const Duration(milliseconds: 300),
      () => _performSearch(query),
    );
  }

  Future<void> _performSearch(String query) async {
    state = state.copyWith(isSearching: true, hasError: false);

    final result = await ref.read(searchProductsUseCaseProvider).call(query);

    result.fold(
      (failure) => state = state.copyWith(
        isSearching: false,
        hasError: true,
        errorMessage: failure.message,
      ),
      (products) => state = state.copyWith(
        isSearching: false,
        results: products,
      ),
    );
  }

  // ── Recent searches (SharedPreferences) ───────────
  Future<void> saveSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final recent = List<String>.from(
      prefs.getStringList('recent_searches') ?? [],
    );
    recent.remove(query); // remove duplicate
    recent.insert(0, query); // add to front
    final limited = recent.take(10).toList(); // max 10
    await prefs.setStringList('recent_searches', limited);
    state = state.copyWith(recentSearches: limited);
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList('recent_searches') ?? [];
    state = state.copyWith(recentSearches: recent);
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    state = state.copyWith(recentSearches: []);
  }

  void clearQuery() {
    state = state.copyWith(
      query: '',
      results: [],
      isSearching: false,
    );
  }
}
