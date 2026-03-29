import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/core/constants/firestore_schema.dart';
import 'package:style_cart/features/products/domain/entities/product_filter_entity.dart';
import 'package:style_cart/features/products/presentation/providers/product_list_notifier.dart';
import 'package:style_cart/features/products/presentation/providers/search_notifier.dart';
import 'package:style_cart/shared/widgets/cards/product_grid_widget.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  bool _isSearchMode = false;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    
    // Defer loading to avoid changing providers during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productListNotifierProvider.notifier).loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _sortLabel(String? sortBy) {
    if (sortBy == null || sortBy == 'newest') return 'Newest';
    if (sortBy == 'price_asc') return 'Price: Low to High';
    if (sortBy == 'price_desc') return 'Price: High to Low';
    if (sortBy == 'popular') return 'Most Popular';
    if (sortBy == 'rating') return 'Top Rated';
    return 'Newest';
  }

  String _priceRangeLabel(ProductFilter filter) {
    final min = filter.minPrice?.toInt() ?? 0;
    final max = filter.maxPrice?.toInt() ?? '5000+';
    return '\$$min - \$$max';
  }

  int _getActiveFilterCount(ProductFilter filter) {
    var count = 0;
    if (filter.category != null) count++;
    if (filter.minPrice != null || filter.maxPrice != null) count++;
    if (filter.isLimitedEdition ?? false) count++;
    return count;
  }

  void _showFilterSheet(BuildContext context, ProductFilter currentFilter) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FilterSheet(
        currentFilter: currentFilter,
        onApply: (newFilter) {
          ref.read(productListNotifierProvider.notifier).applyFilter(newFilter);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSortSheet(BuildContext context, ProductFilter currentFilter) {
    final sortOptions = {
      'newest': 'Newest',
      'price_asc': 'Price: Low to High',
      'price_desc': 'Price: High to Low',
      'rating': 'Top Rated',
      'popular': 'Most Popular'
    };

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Sort By', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...sortOptions.entries.map((entry) {
                final isSelected = currentFilter.sortBy == entry.key;
                return ListTile(
                  title: Text(entry.value, style: const TextStyle(color: Colors.white)),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () {
                    ref.read(productListNotifierProvider.notifier).sortBy(entry.key);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productListState = ref.watch(productListNotifierProvider);
    final searchState = ref.watch(searchNotifierProvider);
    final notifier = ref.read(productListNotifierProvider.notifier);
    final searchNotifier = ref.read(searchNotifierProvider.notifier);

    final filter = productListState.filter;
    final activeFilterCount = _getActiveFilterCount(filter);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // _SearchHeader
            _buildSearchHeader(activeFilterCount, filter, searchNotifier),

            // _ActiveFilterChips
            if (filter.isFiltered) _buildActiveFilterChips(filter, notifier),

            // _ResultsCountBar
            _buildResultsCountBar(productListState.products.length, filter),

            // Main Content
            Expanded(
              child: _isSearchMode
                  ? _buildSearchResults(searchState, searchNotifier)
                  : ProductGridWidget(
                      products: productListState.products,
                      isLoading: productListState.isLoading,
                      isLoadingMore: productListState.isLoadingMore,
                      hasError: productListState.hasError,
                      errorMessage: productListState.errorMessage,
                      onLoadMore: notifier.loadMore,
                      onRetry: notifier.refresh,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(int activeFilterCount, ProductFilter filter, SearchNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search luxury fashion',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          notifier.clearQuery();
                          setState(() => _isSearchMode = false);
                        },
                      )
                    : null,
              ),
              onChanged: (query) {
                setState(() => _isSearchMode = query.isNotEmpty);
                notifier.onQueryChanged(query);
              },
              textInputAction: TextInputAction.search,
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  notifier.saveSearch(query);
                }
                FocusScope.of(context).unfocus();
              },
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                onPressed: () => _showFilterSheet(context, filter),
              ),
              if (activeFilterCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$activeFilterCount',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChips(ProductFilter filter, ProductListNotifier notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (filter.category != null)
            _RemovableChip(
              label: filter.category!,
              onRemove: () => notifier.filterByCategory(null),
            ),
          if (filter.sortBy != 'newest')
            _RemovableChip(
              label: _sortLabel(filter.sortBy),
              onRemove: () => notifier.sortBy('newest'),
            ),
          if (filter.minPrice != null || filter.maxPrice != null)
            _RemovableChip(
              label: _priceRangeLabel(filter),
              onRemove: () => notifier.applyFilter(
                filter.copyWith(),
              ),
            ),
          if (filter.isFiltered)
            TextButton(
              onPressed: () => notifier.clearFilters(),
              child: const Text('Clear All', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsCountBar(int resultCount, ProductFilter filter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$resultCount Results',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          GestureDetector(
            onTap: () => _showSortSheet(context, filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Row(
                children: [
                  Text(
                    'SORT BY: ${_sortLabel(filter.sortBy)}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 0.5),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchState searchState, SearchNotifier searchNotifier) {
    // If we have search results properly integrated into searchState, use them.
    // Assuming searchState has `recentSearches`.
    if (_searchController.text.isEmpty && searchState.recentSearches.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Searches', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => searchNotifier.clearRecentSearches(),
                  child: const Text('Clear', style: TextStyle(color: AppColors.gold, fontSize: 12)),
                ),
              ],
            ),
          ),
          ...searchState.recentSearches.map((search) => ListTile(
                leading: const Icon(Icons.history, color: AppColors.textMuted, size: 20),
                title: Text(search, style: const TextStyle(color: Colors.white, fontSize: 14)),
                onTap: () {
                  _searchController.text = search;
                  searchNotifier.onQueryChanged(search);
                  setState(() => _isSearchMode = true);
                  // Call actual search if applicable
                },
              )),
        ],
      );
    }
    
    // Fallback: If query is not empty and we are simulating standard results:
    // In a real scenario, SearchNotifier might fetch separate products,
    // but the prompt hints that search changes the ProductGridWidget or SearchResults.
    // For now, if no recent searches and we're typed something, show an empty state or loading
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _RemovableChip extends StatelessWidget {

  const _RemovableChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: AppColors.primary, size: 14),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {

  const _FilterSheet({required this.currentFilter, required this.onApply});
  final ProductFilter currentFilter;
  final void Function(ProductFilter) onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late ProductFilter _localFilter;

  @override
  void initState() {
    super.initState();
    _localFilter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20).copyWith(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filters', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Category', style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ProductCategory.all.map((cat) {
                      final isSelected = _localFilter.category == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.gold,
                        backgroundColor: AppColors.backgroundDark,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _localFilter = _localFilter.copyWith(category: selected ? cat : null);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Price Range', style: TextStyle(color: Colors.white, fontSize: 16)),
                  RangeSlider(
                    values: RangeValues(
                      _localFilter.minPrice ?? 0,
                      _localFilter.maxPrice ?? 5000,
                    ),
                    max: 5000,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.backgroundDark,
                    onChanged: (values) {
                      setState(() {
                        _localFilter = _localFilter.copyWith(
                          minPrice: values.start,
                          maxPrice: values.end,
                        );
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${(_localFilter.minPrice ?? 0).toInt()}', style: const TextStyle(color: AppColors.textSecondary)),
                      Text('\$${(_localFilter.maxPrice ?? 5000).toInt()}', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('Limited Edition', style: TextStyle(color: Colors.white)),
                    activeThumbColor: AppColors.primary,
                    value: _localFilter.isLimitedEdition ?? false,
                    onChanged: (val) {
                      setState(() {
                        _localFilter = _localFilter.copyWith(isLimitedEdition: val ? true : null);
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _localFilter = const ProductFilter();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.textMuted),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('RESET', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => widget.onApply(_localFilter),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('APPLY FILTER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
