import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/app/theme/app_text_styles.dart';
import 'package:style_cart/core/constants/firestore_schema.dart';
import 'package:style_cart/features/orders/domain/entities/order_entity.dart';

class AdminOrderCard extends StatelessWidget {

  const AdminOrderCard({
    required this.order, required this.onTap, required this.onUpdateStatus, super.key,
  });
  final OrderEntity order;
  final VoidCallback onTap;
  final void Function(String status) onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order ID & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${order.orderId}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusBadge(order.statusDisplay, statusColor),
                ],
              ),
              const SizedBox(height: 12),
              
              // Customer & Date
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    order.userName,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const Spacer(),
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM dd, yyyy').format(order.placedAt),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              const Divider(height: 24, color: Colors.white10),
              
              // Items Preview & Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${order.items.length} ${order.items.length == 1 ? 'Item' : 'Items'}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.items.map((i) => i.productName).join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              // Quick Actions
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (order.status != OrderStatus.delivered && 
                      order.status != OrderStatus.cancelled && 
                      order.status != OrderStatus.returned)
                    TextButton.icon(
                      onPressed: () => _showStatusPicker(context),
                      icon: const Icon(Icons.edit_note),
                      label: const Text('Move to Next Status'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    return switch (status) {
      OrderStatus.pending        => Colors.orange,
      OrderStatus.confirmed      => Colors.blue,
      OrderStatus.processing     => Colors.blueAccent,
      OrderStatus.packed         => Colors.cyan,
      OrderStatus.shipped        => Colors.indigoAccent,
      OrderStatus.outForDelivery => Colors.deepPurpleAccent,
      OrderStatus.delivered      => Colors.green,
      OrderStatus.cancelled      => Colors.red,
      OrderStatus.returnRequested=> Colors.amber,
      OrderStatus.returned       => Colors.brown,
      _                          => Colors.grey,
    };
  }

  void _showStatusPicker(BuildContext context) {
    final nextStatus = order.nextStatus;
    if (nextStatus == null) return;

    onUpdateStatus(nextStatus);
  }
}
