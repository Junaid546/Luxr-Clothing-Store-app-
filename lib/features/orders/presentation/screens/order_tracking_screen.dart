import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/core/constants/firestore_schema.dart';
import 'package:style_cart/core/utils/extensions.dart';
import 'package:style_cart/features/orders/domain/entities/order_entity.dart';
import 'package:style_cart/features/orders/presentation/providers/order_notifier.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncOrder = ref.watch(orderTrackingNotifierProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: asyncOrder.when(
          loading: () => _buildLoading(),
          error: (e, _) => _buildError(e.toString(), ref),
          data: (order) => _buildTrackingContent(context, order),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
  }

  Widget _buildError(String error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: AppColors.error),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: Colors.white70)),
          TextButton(
            onPressed: () => ref.refresh(orderTrackingNotifierProvider(orderId)),
            child: const Text('Retry', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingContent(BuildContext context, OrderEntity order) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _TrackingAppBar(order: order)),
        SliverToBoxAdapter(child: _OrderHeader(order: order)),
        SliverToBoxAdapter(child: _StatusTimeline(order: order)),
        if (order.courier != null && order.courier!.name != null)
          SliverToBoxAdapter(child: _CourierCard(courier: order.courier!)),
        if (order.isShipped) SliverToBoxAdapter(child: _MapPlaceholder()),
        SliverToBoxAdapter(child: _OrderItemsList(order: order)),
        SliverToBoxAdapter(child: _PriceSummaryCard(order: order)),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _TrackingAppBar extends StatelessWidget {
  final OrderEntity order;
  const _TrackingAppBar({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Order Tracking',
                style: TextStyle(
                    fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  final OrderEntity order;
  const _OrderHeader({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.orderId}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _statusColor(order.status)),
                ),
                child: Text(
                  order.statusDisplay.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor(order.status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Placed on ${order.placedAt.toDisplayDate} · ${DateFormat('hh:mm a').format(order.placedAt)}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) => switch (status) {
        OrderStatus.delivered => AppColors.success,
        OrderStatus.cancelled => AppColors.error,
        OrderStatus.returned => AppColors.error,
        OrderStatus.shipped || OrderStatus.outForDelivery => AppColors.primary,
        OrderStatus.returnRequested => AppColors.warning,
        _ => AppColors.gold,
      };
}

class _StatusTimeline extends StatelessWidget {
  final OrderEntity order;
  const _StatusTimeline({required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (status: OrderStatus.pending, label: 'Order Placed', icon: Icons.shopping_bag_outlined),
      (status: OrderStatus.packed, label: 'Packed', icon: Icons.inventory_2_outlined),
      (status: OrderStatus.shipped, label: 'Shipped', icon: Icons.local_shipping_outlined),
      (status: OrderStatus.outForDelivery, label: 'Out for Delivery', icon: Icons.delivery_dining_outlined),
      (status: OrderStatus.delivered, label: 'Delivered', icon: Icons.check_circle_outline),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;

          // Check history
          final historyEntry = order.statusHistory
              .where((h) =>
                  h.status == step.status ||
                  (step.status == OrderStatus.packed &&
                      (h.status == OrderStatus.processing || h.status == OrderStatus.packed)))
              .lastOrNull;

          final stepIndex = index;
          final isCompleted = order.statusIndex > stepIndex ||
              (order.status == step.status && step.status == OrderStatus.delivered);

          final isCurrent = order.statusIndex == stepIndex &&
              (order.status != OrderStatus.delivered || step.status == OrderStatus.delivered);

          final isFuture = !isCompleted && !isCurrent;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _TimelineIcon(
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    icon: step.icon,
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 50,
                      color: isCompleted ? AppColors.primary : AppColors.borderDefault,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      step.label,
                      style: TextStyle(
                        fontSize: 16,
                        color: isFuture
                            ? Colors.white38
                            : isCompleted || isCurrent
                                ? AppColors.primary
                                : Colors.white,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (historyEntry != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          DateFormat('MMM dd, hh:mm a').format(historyEntry.timestamp),
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    if (isCurrent && step.status == OrderStatus.outForDelivery)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Estimated: ${order.courier?.estimatedTime ?? order.estimatedDelivery.displayRange}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    if (isFuture)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('Pending', style: TextStyle(color: Colors.white24, fontSize: 12)),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _TimelineIcon extends StatelessWidget {
  final bool isCompleted;
  final bool isCurrent;
  final IconData icon;

  const _TimelineIcon({
    required this.isCompleted,
    required this.isCurrent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? AppColors.primary
            : isCurrent
                ? Colors.transparent
                : AppColors.backgroundElevated,
        border: isCurrent ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: isCompleted
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : isCurrent
              ? const _PulsingDot()
              : Icon(icon, color: Colors.white38, size: 18),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _animation,
        child: Center(
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
}

class _CourierCard extends StatelessWidget {
  final CourierEntity courier;
  const _CourierCard({required this.courier});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COURIER INFORMATION',
            style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundElevated,
                ),
                child: const Icon(Icons.person, color: Colors.white38, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courier.name ?? 'Assigned Courier',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star, color: AppColors.gold, size: 14),
                        SizedBox(width: 4),
                        Text('4.9 (1.2k reviews)',
                            style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _CourierActionButton(icon: Icons.phone, onTap: () {}),
                  const SizedBox(width: 8),
                  _CourierActionButton(icon: Icons.message, onTap: () {}),
                ],
              ),
            ],
          ),
          if (courier.trackingNumber != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Tracking: ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                Text(
                  courier.trackingNumber!,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CourierActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CourierActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1E2E1E),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CustomPaint(
              size: Size.infinite,
              painter: _MapGridPainter(),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delivery_dining, color: Colors.white, size: 24),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.my_location, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'LIVE LOCATION',
                    style: TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, 0),
      Offset(size.width * 0.6, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _OrderItemsList extends StatelessWidget {
  final OrderEntity order;
  const _OrderItemsList({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Items Ordered',
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...order.items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      width: 56,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Size: ${item.size}  |  Color: ${item.color}  |  Qty: ${item.quantity}',
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item.lineTotal.toCurrencyString,
                    style: const TextStyle(
                        color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceSummaryCard extends StatelessWidget {
  final OrderEntity order;
  const _PriceSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', order.subtotal.toCurrencyString),
          const SizedBox(height: 8),
          _summaryRow(
            'Shipping',
            order.shippingCost == 0 ? 'FREE' : order.shippingCost.toCurrencyString,
            valueColor: order.shippingCost == 0 ? AppColors.success : null,
          ),
          if (order.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _summaryRow(
              'Discount',
              '-${order.discountAmount.toCurrencyString}',
              valueColor: AppColors.success,
            ),
          ],
          const Divider(color: AppColors.borderDefault, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              Text(
                order.total.toCurrencyString,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                order.paymentMethod == 'cod' ? Icons.payments_outlined : Icons.credit_card_outlined,
                color: Colors.white38,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                order.paymentMethod == 'cod' ? 'Cash on Delivery' : 'Online Payment',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: order.paymentStatus == 'paid'
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  order.paymentStatus.toUpperCase(),
                  style: TextStyle(
                    color: order.paymentStatus == 'paid' ? AppColors.success : AppColors.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
