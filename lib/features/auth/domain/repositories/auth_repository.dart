// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering
import 'package:dartz/dartz.dart';

import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/features/auth/domain/entities/user_entity.dart';

/// Abstract repository interface for authentication operations
/// Domain layer contract - no implementation details
abstract interface class AuthRepository {
  /// Stream of auth state changes - emits UserEntity when authenticated, null when signed out
  Stream<UserEntity?> get authStateChanges;

  /// Get current authenticated user synchronously, or null if not authenticated
  UserEntity? get currentUser;

  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Register new user with email, password, and display name
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with Google OAuth
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign out current user
  Future<Either<Failure, void>> signOut();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail({required String email});

  /// Send email verification to current user
  Future<Either<Failure, void>> sendEmailVerification();

  /// Refresh user profile from Firestore
  Future<Either<Failure, UserEntity>> refreshUserProfile();

  /// Update FCM token for push notifications
  Future<Either<Failure, void>> updateFcmToken(String token);

  /// Delete user account and associated data
  Future<Either<Failure, void>> deleteAccount();
}


