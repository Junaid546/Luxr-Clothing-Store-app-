import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stylecart/app/theme/app_colors.dart';
import 'package:stylecart/core/providers/firebase_providers.dart';
import 'package:stylecart/features/auth/data/providers/auth_providers.dart';

class AdminSendNotificationScreen extends ConsumerStatefulWidget {
  const AdminSendNotificationScreen({super.key});

  @override
  ConsumerState<AdminSendNotificationScreen> createState() =>
      _AdminSendNotificationScreenState();
}

class _AdminSendNotificationScreenState
    extends ConsumerState<AdminSendNotificationScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _userIdController = TextEditingController();

  String _selectedType = 'promotion';
  String _targetAudience = 'all'; // 'all' | 'specific_user'
  String? _targetRoute;
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.trim().isEmpty) {
      _showError('Title is required');
      return;
    }
    if (_bodyController.text.trim().isEmpty) {
      _showError('Message body is required');
      return;
    }
    if (_targetAudience == 'specific_user' &&
        _userIdController.text.trim().isEmpty) {
      _showError('User UID is required for specific target');
      return;
    }

    setState(() => _isSending = true);

    try {
      // Write notification request to Firestore
      // A Cloud Function would pick this up to send real FCM
      await ref.read(firestoreProvider).collection('admin_notifications').add({
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'type': _selectedType,
        'targetAudience': _targetAudience,
        'targetUserId': _targetAudience == 'specific_user'
            ? _userIdController.text.trim()
            : null,
        'data': {
          'type': _selectedType,
          'route': _targetRoute,
        },
        'status': 'pending',
        'sentBy': ref.read(currentUserProvider)?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification queued for delivery!'),
            backgroundColor: AppColors.successTeal,
          ),
        );
        // Reset form
        _titleController.clear();
        _bodyController.clear();
        _userIdController.clear();
        setState(() {
          _targetRoute = null;
          _isSending = false;
        });
      }
    } catch (e) {
      setState(() => _isSending = false);
      _showError('Failed to send: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FormLabel(title: 'Notification Type', textTheme: textTheme),
            const SizedBox(height: 10),
            _TypeSelector(
              selected: _selectedType,
              onSelected: (val) => setState(() => _selectedType = val),
            ),
            const SizedBox(height: 20),
            _FormLabel(title: 'Send To', textTheme: textTheme),
            const SizedBox(height: 10),
            _AudienceSelector(
              selected: _targetAudience,
              onSelected: (val) => setState(() => _targetAudience = val),
            ),
            if (_targetAudience == 'specific_user') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  hintText: 'Enter user UID...',
                ),
              ),
            ],
            const SizedBox(height: 20),
            _FormLabel(title: 'Title', textTheme: textTheme),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'e.g. Flash Sale: 20% Off!',
              ),
              maxLength: 65,
            ),
            const SizedBox(height: 12),
            _FormLabel(title: 'Message', textTheme: textTheme),
            const SizedBox(height: 10),
            TextField(
              controller: _bodyController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Write your content here...',
              ),
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 12),
            _FormLabel(
                title: 'Deep Link Route (optional)', textTheme: textTheme),
            const SizedBox(height: 10),
            TextField(
              onChanged: (v) => setState(() => _targetRoute = v),
              decoration: const InputDecoration(
                hintText: 'e.g. /shop or /product/abc123',
              ),
            ),
            const SizedBox(height: 24),
            _NotificationPreviewCard(
              title: _titleController.text,
              body: _bodyController.text,
              type: _selectedType,
              textTheme: textTheme,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isSending ? null : _sendNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_outlined, color: Colors.white),
              label: Text(
                _isSending ? 'Sending...' : 'Send Notification',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String title;
  final TextTheme textTheme;
  const _FormLabel({required this.title, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: textTheme.labelLarge?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _TypeSelector({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final types = [
      ('promotion', 'Promotion', Icons.local_offer_outlined, AppColors.gold),
      (
        'new_arrival',
        'New Arrival',
        Icons.new_releases_outlined,
        AppColors.successTeal
      ),
      ('system', 'System', Icons.settings_suggest_outlined, AppColors.warning),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: types.map((t) {
          final isSelected = selected == t.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(t.$2),
              onSelected: (_) => onSelected(t.$1),
              avatar:
                  Icon(t.$3, color: isSelected ? Colors.white : t.$4, size: 16),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AudienceSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _AudienceSelector({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('All Customers',
              style: TextStyle(color: Colors.white)),
          value: 'all',
          groupValue: selected,
          onChanged: (v) => onSelected(v!),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          title: const Text('Specific User (by UID)',
              style: TextStyle(color: Colors.white)),
          value: 'specific_user',
          groupValue: selected,
          onChanged: (v) => onSelected(v!),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class _NotificationPreviewCard extends StatelessWidget {
  final String title;
  final String body;
  final String type;
  final TextTheme textTheme;

  const _NotificationPreviewCard({
    required this.title,
    required this.body,
    required this.type,
    required this.textTheme,
  });

  Color _getTypeColor(String type) {
    switch (type) {
      case 'promotion':
        return AppColors.gold;
      case 'new_arrival':
        return AppColors.successTeal;
      case 'system':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'promotion':
        return Icons.local_offer;
      case 'new_arrival':
        return Icons.new_releases;
      case 'system':
        return Icons.settings_suggest;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(type);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LIVE PREVIEW',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 1.5,
              )),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getTypeIcon(type), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('StyleCart',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 10)),
                    Text(
                      title.isEmpty ? 'Notification Title' : title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      body.isEmpty
                          ? 'Notification message content appears here.'
                          : body,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
