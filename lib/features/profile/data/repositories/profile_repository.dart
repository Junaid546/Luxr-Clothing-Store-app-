import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:style_cart/core/constants/firestore_constants.dart';
import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/products/domain/repositories/image_repository.dart';
import 'package:style_cart/features/profile/data/models/profile_address_model.dart';
import 'package:style_cart/features/profile/data/models/profile_settings_model.dart';
import 'package:style_cart/features/profile/data/models/saved_payment_method_model.dart';

class ProfileRepository {
  ProfileRepository({
    required FirebaseFirestore firestore,
    required ImageRepository imageRepository,
  }) : _firestore = firestore,
       _imageRepository = imageRepository;

  final FirebaseFirestore _firestore;
  final ImageRepository _imageRepository;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(FirestoreConstants.users);

  Stream<ProfileSettingsModel> watchProfileSettings(String userId) {
    return _usersRef.doc(userId).snapshots().map(
          (doc) => ProfileSettingsModel.fromUserDoc(doc.data()),
        );
  }

  Future<Either<Failure, void>> saveAddresses({
    required String userId,
    required List<ProfileAddressModel> addresses,
  }) async {
    try {
      await _usersRef.doc(userId).update({
        FirestoreConstants.addresses: _normalizeAddresses(addresses)
            .map((address) => address.toMap())
            .toList(),
        FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } on FirebaseException catch (error) {
      return Left(_mapFirestoreFailure(error));
    } on Object catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> savePaymentMethods({
    required String userId,
    required List<SavedPaymentMethodModel> paymentMethods,
  }) async {
    try {
      await _usersRef.doc(userId).update({
        FirestoreConstants.paymentMethods:
            _normalizePaymentMethods(paymentMethods)
                .map((method) => method.toMap())
                .toList(),
        FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } on FirebaseException catch (error) {
      return Left(_mapFirestoreFailure(error));
    } on Object catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  Future<Either<Failure, String>> uploadProfilePhoto({
    required String userId,
    required String localPath,
  }) async {
    final uploadResult = await _imageRepository.uploadProfilePhoto(
      localPath: localPath,
      userId: userId,
    );

    if (uploadResult.isLeft()) {
      return Left(uploadResult.swap().getOrElse(() => const ServerFailure()));
    }

    final photoUrl = uploadResult.getOrElse(() => '');

    try {
      await _usersRef.doc(userId).update({
        FirestoreConstants.photoUrl: photoUrl,
        FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
      });
      return Right(photoUrl);
    } on FirebaseException catch (error) {
      return Left(_mapFirestoreFailure(error));
    } on Object catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  List<ProfileAddressModel> _normalizeAddresses(
    List<ProfileAddressModel> addresses,
  ) {
    final hasDefault = addresses.any((address) => address.isDefault);

    return addresses.asMap().entries.map((entry) {
      final index = entry.key;
      final address = entry.value;
      return address.copyWith(
        isDefault: hasDefault ? address.isDefault : index == 0,
      );
    }).toList();
  }

  List<SavedPaymentMethodModel> _normalizePaymentMethods(
    List<SavedPaymentMethodModel> paymentMethods,
  ) {
    final hasDefault = paymentMethods.any((method) => method.isDefault);

    return paymentMethods.asMap().entries.map((entry) {
      final index = entry.key;
      final method = entry.value;
      return method.copyWith(
        isDefault: hasDefault ? method.isDefault : index == 0,
      );
    }).toList();
  }

  Failure _mapFirestoreFailure(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => const PermissionFailure(
          'You do not have permission to update this profile.',
        ),
      'unavailable' => const NetworkFailure(
          'Could not reach the server. Check your internet connection.',
        ),
      _ => ServerFailure(
          error.message ?? 'Profile update failed. Please try again.',
        ),
    };
  }
}
