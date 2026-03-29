import 'package:equatable/equatable.dart';
import 'package:style_cart/core/security/sensitive_data_guard.dart';

enum SavedPaymentMethodType { googlePlay, paypal, masterCard }

extension SavedPaymentMethodTypeX on SavedPaymentMethodType {
  String get value => switch (this) {
    SavedPaymentMethodType.googlePlay => 'google_play',
    SavedPaymentMethodType.paypal => 'paypal',
    SavedPaymentMethodType.masterCard => 'mastercard',
  };

  static SavedPaymentMethodType fromString(String value) {
    return switch (value) {
      'google_play' => SavedPaymentMethodType.googlePlay,
      'paypal' => SavedPaymentMethodType.paypal,
      _ => SavedPaymentMethodType.masterCard,
    };
  }
}

class SavedPaymentMethodModel extends Equatable {
  const SavedPaymentMethodModel({
    required this.methodId,
    required this.type,
    this.accountEmail,
    this.cardHolderName,
    this.cardLast4,
    this.expiryMonth,
    this.expiryYear,
    this.isDefault = false,
  });

  final String methodId;
  final SavedPaymentMethodType type;
  final String? accountEmail;
  final String? cardHolderName;
  final String? cardLast4;
  final int? expiryMonth;
  final int? expiryYear;
  final bool isDefault;

  factory SavedPaymentMethodModel.fromMap(Map<String, dynamic> map) {
    return SavedPaymentMethodModel(
      methodId: map['methodId'] as String? ?? '',
      type: SavedPaymentMethodTypeX.fromString(
        map['type'] as String? ?? 'mastercard',
      ),
      accountEmail: map['accountEmail'] as String?,
      cardHolderName: map['cardHolderName'] as String?,
      cardLast4: map['cardLast4'] as String?,
      expiryMonth: map['expiryMonth'] as int?,
      expiryYear: map['expiryYear'] as int?,
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'methodId': methodId,
      'type': type.value,
      'accountEmail': accountEmail,
      'cardHolderName': cardHolderName,
      'cardLast4': cardLast4,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'isDefault': isDefault,
    };
  }

  SavedPaymentMethodModel copyWith({
    String? methodId,
    SavedPaymentMethodType? type,
    String? accountEmail,
    String? cardHolderName,
    String? cardLast4,
    int? expiryMonth,
    int? expiryYear,
    bool? isDefault,
  }) {
    return SavedPaymentMethodModel(
      methodId: methodId ?? this.methodId,
      type: type ?? this.type,
      accountEmail: accountEmail ?? this.accountEmail,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardLast4: cardLast4 ?? this.cardLast4,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get title => switch (type) {
    SavedPaymentMethodType.googlePlay => 'Google Play',
    SavedPaymentMethodType.paypal => 'PayPal',
    SavedPaymentMethodType.masterCard => 'MasterCard',
  };

  String get subtitle => switch (type) {
    SavedPaymentMethodType.googlePlay =>
      accountEmail?.trim().isNotEmpty ?? false
          ? accountEmail!
          : 'Connected Google account',
    SavedPaymentMethodType.paypal =>
      accountEmail?.trim().isNotEmpty ?? false
          ? accountEmail!
          : 'PayPal wallet',
    SavedPaymentMethodType.masterCard =>
      'Expires ${_expiryLabel()} - $maskedCardNumber',
  };

  String get maskedCardNumber {
    final last4 = cardLast4?.trim() ?? '';
    return SensitiveDataGuard.maskCardNumber(last4.padLeft(16, '*'));
  }

  String _expiryLabel() {
    final month = expiryMonth?.toString().padLeft(2, '0') ?? '--';
    final year = expiryYear?.toString() ?? '--';
    return '$month/$year';
  }

  @override
  List<Object?> get props => [
    methodId,
    type,
    accountEmail,
    cardHolderName,
    cardLast4,
    expiryMonth,
    expiryYear,
    isDefault,
  ];
}
