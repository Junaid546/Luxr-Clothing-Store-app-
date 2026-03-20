import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../domain/entities/user_entity.dart';

/// User data model for Firebase Firestore
/// Extends UserEntity (data layer CAN extend domain)
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoUrl,
    required super.role,
    super.fcmToken,
    required super.createdAt,
    required super.totalOrders,
    required super.eliteStatus,
    required super.emailVerified,
  });

  /// Create UserModel from Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      role: UserRoleExtension.fromString(
        data[FirestoreConstants.role] as String? ?? 'customer',
      ),
      fcmToken: data[FirestoreConstants.fcmToken] as String?,
      createdAt:
          (data[FirestoreConstants.createdAt] as Timestamp?)?.toDate() ??
          DateTime.now(),
      totalOrders: data[FirestoreConstants.totalOrders] as int? ?? 0,
      eliteStatus:
          (data[FirestoreConstants.totalOrders] as int? ?? 0).eliteStatus,
      emailVerified: data['emailVerified'] as bool? ?? false,
    );
  }

  /// Convert to Firestore Map for writes
  Map<String, dynamic> toFirestore() {
    return {
      FirestoreConstants.uid: uid,
      FirestoreConstants.email: email,
      FirestoreConstants.displayName: displayName,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.role: role.value,
      FirestoreConstants.fcmToken: fcmToken,
      'emailVerified': emailVerified,
      FirestoreConstants.totalOrders: totalOrders,
      FirestoreConstants.eliteStatus: eliteStatus,
    };
  }

  /// Generate initial document for NEW user registration
  static Map<String, dynamic> newUserDoc({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
    String? fcmToken,
  }) {
    return {
      FirestoreConstants.uid: uid,
      FirestoreConstants.email: email.trim().toLowerCase(),
      FirestoreConstants.displayName: displayName.trim(),
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.role: 'customer', // ALWAYS customer on registration
      FirestoreConstants.fcmToken: fcmToken,
      'emailVerified': false,
      FirestoreConstants.createdAt: FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      FirestoreConstants.totalOrders: 0,
      'totalSpent': 0.0,
      FirestoreConstants.eliteStatus: 'BRONZE',
      'wishlistCount': 0,
      'addresses': <Map<String, dynamic>>[],
      'notificationPrefs': {
        'orderUpdates': true,
        'promotions': true,
        'newArrivals': false,
      },
    };
  }

  /// Create copy with updated fields
  @override
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    String? fcmToken,
    DateTime? createdAt,
    int? totalOrders,
    String? eliteStatus,
    bool? emailVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      totalOrders: totalOrders ?? this.totalOrders,
      eliteStatus: eliteStatus ?? this.eliteStatus,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}
