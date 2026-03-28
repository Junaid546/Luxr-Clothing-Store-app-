import 'package:flutter/material.dart';
import 'package:stylecart/app/theme/app_colors.dart';
import 'package:stylecart/features/orders/domain/entities/order_entity.dart';
import 'package:stylecart/core/constants/firestore_schema.dart';

class StatusUpdateDialog extends StatefulWidget {
  final OrderEntity order;
  final String nextStatus;
  final void Function(String? note, CourierEntity? courier) onConfirm;

  const StatusUpdateDialog({
    super.key,
    required this.order,
    required this.nextStatus,
    required this.onConfirm,
  });

  @override
  State<StatusUpdateDialog> createState() => _StatusUpdateDialogState();
}

class _StatusUpdateDialogState extends State<StatusUpdateDialog> {
  final _noteController = TextEditingController();
  final _courierNameController = TextEditingController();
  final _trackingController = TextEditingController();
  final _estTimeController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _courierNameController.dispose();
    _trackingController.dispose();
    _estTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isShipping = widget.nextStatus == OrderStatus.shipped;

    return AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Update to ${widget.nextStatus.toUpperCase()}',
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm status change for order #${widget.order.orderId}',
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Note Field
            const Text('Status Note (Optional)',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('e.g. Item is being packed'),
            ),

            if (isShipping) ...[
              const SizedBox(height: 20),
              const Divider(color: Colors.white10),
              const SizedBox(height: 12),
              const Text('Courier Information',
                  style: TextStyle(
                      color: AppColors.gold, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _label('Courier Name'),
              TextField(
                controller: _courierNameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('e.g. FedEx, DHL'),
              ),
              const SizedBox(height: 12),
              _label('Tracking Number'),
              TextField(
                controller: _trackingController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Tracking ID'),
              ),
              const SizedBox(height: 12),
              _label('Estimated Delivery Time'),
              TextField(
                controller: _estTimeController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('e.g. Tomorrow, 5 PM'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            CourierEntity? courier;
            if (isShipping) {
              courier = CourierEntity(
                name: _courierNameController.text.trim(),
                trackingNumber: _trackingController.text.trim(),
                estimatedTime: _estTimeController.text.trim(),
              );
            }
            widget.onConfirm(
              _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
              courier,
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Update Status'),
        ),
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        filled: true,
        fillColor: Colors.black26,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      );
}
