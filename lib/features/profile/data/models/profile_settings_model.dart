import 'package:equatable/equatable.dart';
import 'package:style_cart/features/profile/data/models/profile_address_model.dart';
import 'package:style_cart/features/profile/data/models/saved_payment_method_model.dart';

class ProfileSettingsModel extends Equatable {
  const ProfileSettingsModel({
    this.addresses = const [],
    this.paymentMethods = const [],
  });

  final List<ProfileAddressModel> addresses;
  final List<SavedPaymentMethodModel> paymentMethods;

  factory ProfileSettingsModel.fromUserDoc(Map<String, dynamic>? data) {
    final rawAddresses = data?['addresses'] as List? ?? const [];
    final rawPaymentMethods = data?['paymentMethods'] as List? ?? const [];

    return ProfileSettingsModel(
      addresses: rawAddresses
          .map(
            (item) => ProfileAddressModel.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      paymentMethods: rawPaymentMethods
          .map(
            (item) => SavedPaymentMethodModel.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }

  ProfileAddressModel? get defaultAddress {
    return addresses.cast<ProfileAddressModel?>().firstWhere(
          (address) => address?.isDefault ?? false,
          orElse: () => addresses.isNotEmpty ? addresses.first : null,
        );
  }

  SavedPaymentMethodModel? get defaultPaymentMethod {
    return paymentMethods.cast<SavedPaymentMethodModel?>().firstWhere(
          (method) => method?.isDefault ?? false,
          orElse: () => paymentMethods.isNotEmpty ? paymentMethods.first : null,
        );
  }

  @override
  List<Object?> get props => [addresses, paymentMethods];
}
