import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:style_cart/core/providers/firebase_providers.dart';
import 'package:style_cart/features/auth/data/providers/auth_providers.dart';
import 'package:style_cart/features/products/data/providers/product_data_providers.dart';
import 'package:style_cart/features/profile/data/models/profile_settings_model.dart';
import 'package:style_cart/features/profile/data/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    firestore: ref.watch(firestoreProvider),
    imageRepository: ref.watch(imageRepositoryProvider),
  );
});

final profileSettingsProvider =
    StreamProvider.autoDispose<ProfileSettingsModel>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(const ProfileSettingsModel());
  }

  return ref.watch(profileRepositoryProvider).watchProfileSettings(user.uid);
});
