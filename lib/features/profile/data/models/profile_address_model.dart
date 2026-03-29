import 'package:equatable/equatable.dart';
import 'package:style_cart/features/orders/data/models/order_model.dart';

class ProfileAddressModel extends Equatable {
  const ProfileAddressModel({
    required this.addressId,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.isDefault = false,
  });

  final String addressId;
  final String label;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;

  factory ProfileAddressModel.fromMap(Map<String, dynamic> map) {
    return ProfileAddressModel(
      addressId: map['addressId'] as String? ?? '',
      label: map['label'] as String? ?? 'Home',
      fullName: map['fullName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      street: map['street'] as String? ?? '',
      city: map['city'] as String? ?? '',
      state: map['state'] as String? ?? '',
      zipCode: map['zipCode'] as String? ?? '',
      country: map['country'] as String? ?? '',
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'addressId': addressId,
      'label': label,
      'fullName': fullName,
      'phone': phone,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'isDefault': isDefault,
    };
  }

  ShippingAddressModel toShippingAddress() {
    return ShippingAddressModel(
      fullName: fullName,
      phone: phone,
      street: street,
      city: city,
      state: state,
      zipCode: zipCode,
      country: country,
    );
  }

  ProfileAddressModel copyWith({
    String? addressId,
    String? label,
    String? fullName,
    String? phone,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
  }) {
    return ProfileAddressModel(
      addressId: addressId ?? this.addressId,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get shortAddress => '$street, $city';

  String get formatted => '$street, $city, $state $zipCode, $country';

  @override
  List<Object?> get props => [
    addressId,
    label,
    fullName,
    phone,
    street,
    city,
    state,
    zipCode,
    country,
    isDefault,
  ];
}
