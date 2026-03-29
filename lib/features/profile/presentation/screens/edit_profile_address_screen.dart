import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/core/utils/validators.dart';
import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:style_cart/features/profile/data/models/profile_address_model.dart';
import 'package:style_cart/features/profile/presentation/providers/profile_providers.dart';
import 'package:uuid/uuid.dart';

const _addressAccent = AppColors.primary;
const _addressSurface = AppColors.backgroundCard;
const _addressField = AppColors.backgroundElevated;

class EditProfileAddressScreen extends ConsumerStatefulWidget {
  const EditProfileAddressScreen({this.initialAddress, super.key});

  final ProfileAddressModel? initialAddress;

  @override
  ConsumerState<EditProfileAddressScreen> createState() =>
      _EditProfileAddressScreenState();
}

class _EditProfileAddressScreenState
    extends ConsumerState<EditProfileAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipCodeController;
  late final TextEditingController _countryController;

  bool _isDefault = false;
  bool _isSaving = false;

  bool get _isEditing => widget.initialAddress != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialAddress;
    _labelController = TextEditingController(text: initial?.label ?? 'Home');
    _fullNameController = TextEditingController(text: initial?.fullName ?? '');
    _phoneController = TextEditingController(text: initial?.phone ?? '');
    _streetController = TextEditingController(text: initial?.street ?? '');
    _cityController = TextEditingController(text: initial?.city ?? '');
    _stateController = TextEditingController(text: initial?.state ?? '');
    _zipCodeController = TextEditingController(text: initial?.zipCode ?? '');
    _countryController = TextEditingController(
      text: initial?.country ?? 'Pakistan',
    );
    _isDefault = initial?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) {
      return;
    }

    setState(() => _isSaving = true);

    final settings = await ref.read(profileSettingsProvider.future);
    final address = ProfileAddressModel(
      addressId: widget.initialAddress?.addressId ?? const Uuid().v4(),
      label: _labelController.text.trim(),
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zipCode: _zipCodeController.text.trim(),
      country: _countryController.text.trim(),
      isDefault: _isDefault,
    );

    final existing = [...settings.addresses];
    final updated =
        existing.where((item) => item.addressId != address.addressId).toList()
          ..add(address);

    final normalized = updated
        .map(
          (item) => item.copyWith(
            isDefault: address.isDefault
                ? item.addressId == address.addressId
                : item.isDefault,
          ),
        )
        .toList();

    final result = await ref
        .read(profileRepositoryProvider)
        .saveAddresses(userId: authState.user.uid, addresses: normalized);

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    result.fold((failure) => _showSnackBar(failure.message, isError: true), (
      _,
    ) {
      _showSnackBar(_isEditing ? 'Address updated.' : 'Address added.');
      context.pop();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : _addressAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Address' : 'New Address',
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
                _InfoCard(
                  title: 'Saved for effortless checkout',
                  subtitle:
                      'We will use this address anywhere you choose it later.',
                ),
                const SizedBox(height: 20),
                _ProfileFormField(
                  controller: _labelController,
                  label: 'Label',
                  hint: 'Home, Office, Studio',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Address label is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Label is too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _ProfileFormField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  validator: Validators.validateDisplayName,
                ),
                const SizedBox(height: 14),
                _ProfileFormField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 14),
                _ProfileFormField(
                  controller: _streetController,
                  label: 'Street Address',
                  maxLines: 2,
                  validator: Validators.validateStreet,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ProfileFormField(
                        controller: _cityController,
                        label: 'City',
                        validator: _validateRequiredField('City'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProfileFormField(
                        controller: _stateController,
                        label: 'State',
                        validator: _validateRequiredField('State'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ProfileFormField(
                        controller: _zipCodeController,
                        label: 'ZIP / Postal Code',
                        keyboardType: TextInputType.text,
                        validator: Validators.validateZipCode,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProfileFormField(
                        controller: _countryController,
                        label: 'Country',
                        validator: _validateRequiredField('Country'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile.adaptive(
                  value: _isDefault,
                  onChanged: (value) => setState(() => _isDefault = value),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  activeColor: _addressAccent,
                  title: const Text(
                    'Use as default delivery address',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'This address will be your first option in profile and checkout.',
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
            onPressed: _isSaving ? null : _saveAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: _addressAccent,
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
                : Text(_isEditing ? 'Save Changes' : 'Add Address'),
          ),
        ),
      ),
    );
  }

  FormFieldValidator<String> _validateRequiredField(String name) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$name is required';
      }
      return null;
    };
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _addressSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFormField extends StatelessWidget {
  const _ProfileFormField({
    required this.controller,
    required this.label,
    required this.validator,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: _addressField,
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
          borderSide: const BorderSide(color: _addressAccent, width: 1.4),
        ),
      ),
    );
  }
}
