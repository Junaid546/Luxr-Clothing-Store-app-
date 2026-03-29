import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/theme/app_text_styles.dart';
import 'package:style_cart/core/constants/firestore_schema.dart';
import 'package:style_cart/features/home/data/models/banner_model.dart';
import 'package:style_cart/features/home/presentation/providers/home_providers.dart';
import 'package:style_cart/features/notifications/data/providers/notification_providers.dart';
import 'package:style_cart/features/notifications/presentation/widgets/notification_bell.dart';
import 'package:style_cart/features/notifications/presentation/widgets/notification_permission_dialog.dart';
import 'package:style_cart/features/products/presentation/providers/product_list_notifier.dart';
import 'package:style_cart/features/wishlist/presentation/providers/wishlist_notifier.dart';
import 'package:style_cart/shared/utils/wishlist_helper.dart';
import 'package:style_cart/shared/widgets/cards/product_card_widget.dart';
import 'package:style_cart/shared/widgets/section_header_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Show permission dialog after a short delay if not already shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotificationPermissions();
    });
  }

  void _checkNotificationPermissions() {
    // Check if the dialog has already been shown in this session
    final hasBeenShown = ref.read(notificationPermissionDialogShownProvider);
    if (hasBeenShown) return;

    // Mark as shown immediately to prevent race conditions during navigation
    ref.read(notificationPermissionDialogShownProvider.notifier).state = true;

    final fcmService = ref.read(fcmServiceProvider);

    // If not requested yet, show after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => NotificationPermissionDialog(
            onAllow: () {
              fcmService.requestPermission();
              Navigator.pop(context);
            },
            onSkip: () => Navigator.pop(context),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _AppBar()),
            SliverToBoxAdapter(child: _SearchBar()),
            SliverToBoxAdapter(child: _BannerCarousel()),
            SliverToBoxAdapter(child: _CategoryChips()),
            SliverToBoxAdapter(child: _FeaturedSection()),
            SliverToBoxAdapter(child: _NewArrivalsSection()),
            SliverToBoxAdapter(child: _TrendingBanner()),
            SliverToBoxAdapter(child: _BestSellersSection()),
            SliverToBoxAdapter(child: SizedBox(height: 32)), // Bottom padding
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App name
          Text(
            'LUXR',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),

          // Notification bell with live count badge
          const NotificationBell(),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 8),
      child: GestureDetector(
        onTap: () => _openHomeActionRoute(context, RouteNames.shop),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2A), // surface
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(Icons.search, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Search luxury fashion',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerCarousel extends ConsumerStatefulWidget {
  const _BannerCarousel();

  @override
  ConsumerState<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends ConsumerState<_BannerCarousel> {
  late PageController _pageController;
  Timer? _bannerTimer;
  int _currentPage = 0;
  List<BannerModel> _banners = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  void _setupTimer(List<BannerModel> banners) {
    if (_bannerTimer == null ||
        !_bannerTimer!.isActive ||
        _banners.length != banners.length) {
      _banners = banners;
      _bannerTimer?.cancel();
      if (_banners.length <= 1) return;

      _bannerTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        if (!mounted || !_pageController.hasClients) return;

        var nextPage = _currentPage + 1;
        if (nextPage >= _banners.length) {
          nextPage = 0;
        }

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(homeBannersProvider);

    return bannersAsync.when(
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();

        _setupTimer(banners);

        return Column(
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      _BannerCard(banner: banners[index]),
                      // Dot indicators positioned inside the banner block
                      Positioned(
                        bottom: 16,
                        right: 24,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            banners.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(left: 6),
                              width: _currentPage == i ? 24 : 8,
                              height: 4,
                              decoration: BoxDecoration(
                                color: _currentPage == i
                                    ? AppColors.gold
                                    : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => Shimmer.fromColors(
        baseColor: AppColors.backgroundCard,
        highlightColor: AppColors.backgroundElevated,
        child: Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          e.toString(),
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});
  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          // Full image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: banner.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorWidget: (context, url, error) =>
                  Container(color: AppColors.backgroundCard),
            ),
          ),
          // Gradient overlay (bottom)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.black26, Colors.transparent],
                ),
              ),
            ),
          ),
          // Content (bottom-left)
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () =>
                      _openHomeActionRoute(context, banner.actionRoute),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    banner.actionLabel.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends ConsumerStatefulWidget {
  const _CategoryChips();

  @override
  ConsumerState<_CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends ConsumerState<_CategoryChips> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          _CategoryChip(
            label: 'All',
            isSelected: selectedCategory == null,
            onTap: () {
              setState(() => selectedCategory = null);
              ref
                  .read(productListNotifierProvider.notifier)
                  .filterByCategory(null);
            },
          ),
          ...ProductCategory.all.map(
            (cat) => _CategoryChip(
              label: cat,
              isSelected: selectedCategory == cat,
              onTap: () {
                setState(() => selectedCategory = cat);
                ref
                    .read(productListNotifierProvider.notifier)
                    .filterByCategory(cat);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : const Color(0xFF1E1E2A),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.black : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _FeaturedSection extends ConsumerWidget {
  const _FeaturedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(featuredProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeaderWidget(
          title: 'Featured',
          actionLabel: 'See all',
          onActionTap: () => _openHomeActionRoute(context, RouteNames.shop),
        ),
        SizedBox(
          height: 350,
          child: productsAsync.when(
            data: (products) {
              if (products.isEmpty) return const SizedBox.shrink();
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 160,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Consumer(
                        builder: (context, ref, child) {
                          final isWishlisted = ref.watch(
                            isProductWishlistedProvider(
                              products[index].productId,
                            ),
                          );
                          return ProductCardWidget(
                            product: products[index],
                            imageAspectRatio: 2 / 3,
                            onTap: () => context.push(
                              RouteNames.productDetail.replaceAll(
                                ':productId',
                                products[index].productId,
                              ),
                            ),
                            isWishlisted: isWishlisted,
                            onWishlistTap: () =>
                                toggleWishlist(ref, context, products[index]),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: AppColors.backgroundCard,
                highlightColor: AppColors.backgroundElevated,
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                e.toString(),
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NewArrivalsSection extends ConsumerWidget {
  const _NewArrivalsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(newArrivalProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeaderWidget(
          title: 'New Arrivals',
          actionLabel: 'View all',
          onActionTap: () => _openHomeActionRoute(context, RouteNames.shop),
        ),
        productsAsync.when(
          data: (products) {
            if (products.isEmpty) return const SizedBox.shrink();
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.50,
              ),
              itemCount: min(products.length, 4),
              itemBuilder: (_, index) => Consumer(
                builder: (context, ref, child) {
                  final isWishlisted = ref.watch(
                    isProductWishlistedProvider(products[index].productId),
                  );
                  return ProductCardWidget(
                    product: products[index],
                    imageAspectRatio: 3 / 4,
                    onTap: () => context.push(
                      RouteNames.productDetail.replaceAll(
                        ':productId',
                        products[index].productId,
                      ),
                    ),
                    isWishlisted: isWishlisted,
                    onWishlistTap: () =>
                        toggleWishlist(ref, context, products[index]),
                  );
                },
              ),
            );
          },
          loading: () => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.58,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => Shimmer.fromColors(
              baseColor: AppColors.backgroundCard,
              highlightColor: AppColors.backgroundElevated,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              e.toString(),
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendingBanner extends StatelessWidget {
  const _TrendingBanner();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            children: [
              const Icon(Icons.diamond, color: AppColors.gold, size: 24),
              const SizedBox(width: 8),
              Text(
                'Trending Now',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/trending now card image.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: AppColors.backgroundCard),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          AppColors.gold.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'MUST HAVE',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.gold,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The Statement\nPiece',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              _openHomeActionRoute(context, RouteNames.shop),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            elevation: 8,
                            shadowColor: AppColors.gold.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Discover',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BestSellersSection extends ConsumerWidget {
  const _BestSellersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(bestSellerProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeaderWidget(
          title: 'Best Sellers',
          actionLabel: 'See all',
          onActionTap: () => _openHomeActionRoute(context, RouteNames.shop),
        ),
        SizedBox(
          height: 350,
          child: productsAsync.when(
            data: (products) {
              if (products.isEmpty) return const SizedBox.shrink();
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 160,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Consumer(
                        builder: (context, ref, child) {
                          final isWishlisted = ref.watch(
                            isProductWishlistedProvider(
                              products[index].productId,
                            ),
                          );
                          return ProductCardWidget(
                            product: products[index],
                            imageAspectRatio: 2 / 3,
                            onTap: () => context.push(
                              RouteNames.productDetail.replaceAll(
                                ':productId',
                                products[index].productId,
                              ),
                            ),
                            isWishlisted: isWishlisted,
                            onWishlistTap: () =>
                                toggleWishlist(ref, context, products[index]),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: AppColors.backgroundCard,
                highlightColor: AppColors.backgroundElevated,
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

void _openHomeActionRoute(BuildContext context, String route) {
  const shellRoutes = {
    RouteNames.home,
    RouteNames.shop,
    RouteNames.cart,
    RouteNames.wishlist,
    RouteNames.profile,
  };

  if (shellRoutes.contains(route)) {
    context.go(route);
    return;
  }

  context.push(route);
}
