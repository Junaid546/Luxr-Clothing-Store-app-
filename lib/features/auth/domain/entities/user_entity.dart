import 'package:equatable/equatable.dart';

/// User role enum for role-based access control
enum UserRole { admin, customer }

/// Extension to parse role from Firestore string
extension UserRoleExtension on UserRole {
  static UserRole fromString(String value) {
    return value == 'admin' ? UserRole.admin : UserRole.customer;
  }

  String get value => name;
}

/// Extension to calculate elite status based on total orders
extension EliteStatusExtension on int {
  String get eliteStatus {
    if (this >= 50) return 'PLATINUM';
    if (this >= 20) return 'GOLD';
    if (this >= 5) return 'SILVER';
    return 'BRONZE';
  }
}

/// User entity representing the authenticated user
/// Domain layer - pure Dart, no Flutter/Firebase imports
class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.role,
    this.fcmToken,
    required this.createdAt,
    required this.totalOrders,
    required this.eliteStatus,
    required this.emailVerified,
    this.notificationPrefs = const {
      'orderUpdates': true,
      'promotions': true,
      'newArrivals': true,
    },
  });
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final UserRole role;
  final String? fcmToken;
  final DateTime createdAt;
  final int totalOrders;
  final String eliteStatus;
  final bool emailVerified;
  final Map<String, bool> notificationPrefs;

  /// Check if user has admin role
  bool get isAdmin => role == UserRole.admin;

  /// Check if user has customer role
  bool get isCustomer => role == UserRole.customer;

  /// Create a copy with updated fields
  UserEntity copyWith({
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
    Map<String, bool>? notificationPrefs,
  }) {
    return UserEntity(
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
      notificationPrefs: notificationPrefs ?? this.notificationPrefs,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoUrl,
        role,
        fcmToken,
        createdAt,
        totalOrders,
        eliteStatus,
        emailVerified,
        notificationPrefs,
      ];
}
