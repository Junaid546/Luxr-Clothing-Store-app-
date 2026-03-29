import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:style_cart/features/profile/data/models/saved_payment_method_model.dart';
import 'package:style_cart/features/profile/presentation/providers/profile_providers.dart';

const _paymentsAccent = AppColors.primary;
const _paymentsSurface = AppColors.backgroundCard;
const _paymentsHighlight = AppColors.gold;

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  bool _isSaving = false;

  Future<void> _persistMethods(
    List<SavedPaymentMethodModel> paymentMethods, {
    required String successMessage,
  }) async {
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) {
      return;
    }

    setState(() => _isSaving = true);

    final result = await ref
        .read(profileRepositoryProvider)
        .savePaymentMethods(
          userId: authState.user.uid,
          paymentMethods: paymentMethods,
        );

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    result.fold(
      (failure) => _showSnackBar(failure.message, isError: true),
      (_) => _showSnackBar(successMessage),
    );
  }

  Future<void> _setDefaultMethod(SavedPaymentMethodModel paymentMethod) async {
    final settings = await ref.read(profileSettingsProvider.future);
    final updated = settings.paymentMethods
        .map(
          (method) => method.copyWith(
            isDefault: method.methodId == paymentMethod.methodId,
          ),
        )
        .toList();

    await _persistMethods(
      updated,
      successMessage: '${paymentMethod.title} is now your default method.',
    );
  }

  Future<void> _deleteMethod(SavedPaymentMethodModel paymentMethod) async {
    final settings = await ref.read(profileSettingsProvider.future);
    final updated = settings.paymentMethods
        .where((method) => method.methodId != paymentMethod.methodId)
        .toList();

    await _persistMethods(
      updated,
      successMessage: '${paymentMethod.title} removed.',
    );
  }

  Future<void> _confirmDelete(SavedPaymentMethodModel paymentMethod) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: _paymentsSurface,
            title: const Text(
              'Remove payment method',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Delete ${paymentMethod.title} from your saved payment methods?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldDelete) {
      await _deleteMethod(paymentMethod);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : _paymentsAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(profileSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Payment Methods',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _paymentsAccent,
        foregroundColor: Colors.white,
        onPressed: _isSaving
            ? null
            : () => context.push(RouteNames.profileEditPaymentMethod),
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('Add Method'),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3D1010), AppColors.backgroundDark],
          ),
        ),
        child: settingsAsync.when(
          data: (settings) {
            if (settings.paymentMethods.isEmpty) {
              return _EmptyPaymentState(
                icon: Icons.wallet_outlined,
                title: 'No saved payment methods',
                subtitle:
                    'Add Google Play, PayPal, or MasterCard details for a faster checkout experience.',
                buttonLabel: 'Add payment method',
                onTap: () => context.push(RouteNames.profileEditPaymentMethod),
              );
            }

            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                  children: [
                    const _PaymentHeroCard(),
                    const SizedBox(height: 16),
                    ...settings.paymentMethods.map(
                      (paymentMethod) => _PaymentMethodCard(
                        paymentMethod: paymentMethod,
                        onEdit: () => context.push(
                          RouteNames.profileEditPaymentMethod,
                          extra: paymentMethod,
                        ),
                        onDelete: () => _confirmDelete(paymentMethod),
                        onSetDefault: paymentMethod.isDefault
                            ? null
                            : () => _setDefaultMethod(paymentMethod),
                      ),
                    ),
                  ],
                ),
                if (_isSaving)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x66000000),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: _paymentsHighlight,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: _paymentsHighlight),
          ),
          error: (error, _) => _EmptyPaymentState(
            icon: Icons.error_outline,
            title: 'Could not load methods',
            subtitle: error.toString(),
            buttonLabel: 'Try again',
            onTap: () => ref.invalidate(profileSettingsProvider),
          ),
        ),
      ),
    );
  }
}

class _PaymentHeroCard extends StatelessWidget {
  const _PaymentHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A181B), Color(0xFF231012)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure your checkout flow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Save your favorite payment methods and choose the default one you reach for most.',
                  style: TextStyle(color: Colors.white70, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.paymentMethod,
    required this.onEdit,
    required this.onDelete,
    this.onSetDefault,
  });

  final SavedPaymentMethodModel paymentMethod;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSetDefault;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _paymentsSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: paymentMethod.isDefault ? _paymentsHighlight : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _paymentsAccent.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _paymentIcon(paymentMethod.type),
                  color: _paymentsHighlight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentMethod.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paymentMethod.subtitle,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (paymentMethod.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                  ),
                  child: const Text(
                    'DEFAULT',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white12),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                  ),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onSetDefault,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _paymentsAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                    disabledBackgroundColor: Colors.white10,
                  ),
                  child: Text(
                    paymentMethod.isDefault ? 'Saved' : 'Set Default',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: onDelete,
                style: IconButton.styleFrom(backgroundColor: Colors.white10),
                icon: const Icon(Icons.delete_outline, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyPaymentState extends StatelessWidget {
  const _EmptyPaymentState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _paymentsHighlight, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _paymentsAccent,
                foregroundColor: Colors.white,
              ),
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _paymentIcon(SavedPaymentMethodType type) {
  return switch (type) {
    SavedPaymentMethodType.googlePlay => Icons.play_circle_fill_rounded,
    SavedPaymentMethodType.paypal => Icons.account_balance_wallet_rounded,
    SavedPaymentMethodType.masterCard => Icons.credit_card_rounded,
  };
}
