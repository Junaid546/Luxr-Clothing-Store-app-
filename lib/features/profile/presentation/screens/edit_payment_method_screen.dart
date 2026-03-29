import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/core/utils/validators.dart';
import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:style_cart/features/profile/data/models/saved_payment_method_model.dart';
import 'package:style_cart/features/profile/presentation/providers/profile_providers.dart';
import 'package:uuid/uuid.dart';

const _paymentFormAccent = AppColors.primary;
const _paymentFormSurface = AppColors.backgroundCard;
const _paymentFormField = AppColors.backgroundElevated;

class EditPaymentMethodScreen extends ConsumerStatefulWidget {
  const EditPaymentMethodScreen({this.initialMethod, super.key});

  final SavedPaymentMethodModel? initialMethod;

  @override
  ConsumerState<EditPaymentMethodScreen> createState() =>
      _EditPaymentMethodScreenState();
}

class _EditPaymentMethodScreenState
    extends ConsumerState<EditPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  late SavedPaymentMethodType _selectedType;
  late final TextEditingController _emailController;
  late final TextEditingController _cardHolderController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _expiryMonthController;
  late final TextEditingController _expiryYearController;

  bool _isDefault = false;
  bool _isSaving = false;

  bool get _isEditing => widget.initialMethod != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialMethod;
    _selectedType = initial?.type ?? SavedPaymentMethodType.googlePlay;
    _emailController = TextEditingController(text: initial?.accountEmail ?? '');
    _cardHolderController = TextEditingController(
      text: initial?.cardHolderName ?? '',
    );
    _cardNumberController = TextEditingController(
      text: initial?.cardLast4 ?? '',
    );
    _expiryMonthController = TextEditingController(
      text: initial?.expiryMonth?.toString() ?? '',
    );
    _expiryYearController = TextEditingController(
      text: initial?.expiryYear?.toString() ?? '',
    );
    _isDefault = initial?.isDefault ?? false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    super.dispose();
  }

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) {
      return;
    }

    setState(() => _isSaving = true);
    final settings = await ref.read(profileSettingsProvider.future);

    final normalizedDigits = _cardNumberController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    final paymentMethod = SavedPaymentMethodModel(
      methodId: widget.initialMethod?.methodId ?? const Uuid().v4(),
      type: _selectedType,
      accountEmail: _selectedType == SavedPaymentMethodType.masterCard
          ? null
          : _emailController.text.trim(),
      cardHolderName: _selectedType == SavedPaymentMethodType.masterCard
          ? _cardHolderController.text.trim()
          : null,
      cardLast4: _selectedType == SavedPaymentMethodType.masterCard
          ? normalizedDigits.substring(normalizedDigits.length - 4)
          : null,
      expiryMonth: _selectedType == SavedPaymentMethodType.masterCard
          ? int.parse(_expiryMonthController.text.trim())
          : null,
      expiryYear: _selectedType == SavedPaymentMethodType.masterCard
          ? int.parse(_expiryYearController.text.trim())
          : null,
      isDefault: _isDefault,
    );

    final updated =
        settings.paymentMethods
            .where((method) => method.methodId != paymentMethod.methodId)
            .toList()
          ..add(paymentMethod);

    final normalized = updated
        .map(
          (method) => method.copyWith(
            isDefault: paymentMethod.isDefault
                ? method.methodId == paymentMethod.methodId
                : method.isDefault,
          ),
        )
        .toList();

    final result = await ref
        .read(profileRepositoryProvider)
        .savePaymentMethods(
          userId: authState.user.uid,
          paymentMethods: normalized,
        );

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    result.fold((failure) => _showSnackBar(failure.message, isError: true), (
      _,
    ) {
      _showSnackBar(
        _isEditing ? 'Payment method updated.' : 'Payment method added.',
      );
      context.pop();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : _paymentFormAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCard = _selectedType == SavedPaymentMethodType.masterCard;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Payment Method' : 'New Payment Method',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3D1010), AppColors.backgroundDark],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                const _MethodHintCard(),
                const SizedBox(height: 20),
                const Text(
                  'Select Type',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: SavedPaymentMethodType.values.map((type) {
                    final isSelected = _selectedType == type;
                    return ChoiceChip(
                      selected: isSelected,
                      label: Text(_paymentTypeLabel(type)),
                      selectedColor: _paymentFormAccent,
                      backgroundColor: _paymentFormField,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _selectedType = type),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                if (!isCard)
                  _PaymentField(
                    controller: _emailController,
                    label: _selectedType == SavedPaymentMethodType.googlePlay
                        ? 'Google Account Email'
                        : 'PayPal Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                if (isCard) ...[
                  _PaymentField(
                    controller: _cardHolderController,
                    label: 'Card Holder Name',
                    validator: Validators.validateDisplayName,
                  ),
                  const SizedBox(height: 14),
                  _PaymentField(
                    controller: _cardNumberController,
                    label: 'MasterCard Number',
                    keyboardType: TextInputType.number,
                    hint: _isEditing
                        ? 'Enter the full number or just the last 4 digits'
                        : 'We only save the last 4 digits',
                    validator: _validateCardNumber,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _PaymentField(
                          controller: _expiryMonthController,
                          label: 'Expiry Month',
                          keyboardType: TextInputType.number,
                          validator: _validateExpiryMonth,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PaymentField(
                          controller: _expiryYearController,
                          label: 'Expiry Year',
                          keyboardType: TextInputType.number,
                          validator: _validateExpiryYear,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                SwitchListTile.adaptive(
                  value: _isDefault,
                  onChanged: (value) => setState(() => _isDefault = value),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  activeColor: _paymentFormAccent,
                  title: const Text(
                    'Use as default payment method',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Your default method appears first anywhere we ask for payment.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _savePaymentMethod,
            style: ElevatedButton.styleFrom(
              backgroundColor: _paymentFormAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_isEditing ? 'Save Changes' : 'Add Payment Method'),
          ),
        ),
      ),
    );
  }

  String? _validateCardNumber(String? value) {
    final digits = value?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    final minLength =
        _isEditing &&
            widget.initialMethod?.type == SavedPaymentMethodType.masterCard
        ? 4
        : 16;

    if (digits.length < minLength) {
      return 'Enter a valid MasterCard number';
    }
    return null;
  }

  String? _validateExpiryMonth(String? value) {
    final month = int.tryParse(value?.trim() ?? '');
    if (month == null || month < 1 || month > 12) {
      return '1-12';
    }
    return null;
  }

  String? _validateExpiryYear(String? value) {
    final year = int.tryParse(value?.trim() ?? '');
    if (year == null || year < DateTime.now().year) {
      return 'Invalid year';
    }
    return null;
  }
}

class _MethodHintCard extends StatelessWidget {
  const _MethodHintCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _paymentFormSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Save only what you need',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'For cards we keep only the last 4 digits and expiry date. Sensitive details like CVV are never stored here.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _PaymentField extends StatelessWidget {
  const _PaymentField({
    required this.controller,
    required this.label,
    required this.validator,
    this.keyboardType,
    this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: _paymentFormField,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _paymentFormAccent, width: 1.4),
        ),
      ),
    );
  }
}

String _paymentTypeLabel(SavedPaymentMethodType type) {
  return switch (type) {
    SavedPaymentMethodType.googlePlay => 'Google Play',
    SavedPaymentMethodType.paypal => 'PayPal',
    SavedPaymentMethodType.masterCard => 'MasterCard',
  };
}
