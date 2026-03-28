// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars, document_ignores, always_put_required_named_parameters_first, cascade_invocations, avoid_catches_without_on_clauses, use_if_null_to_convert_nulls_to_bools, omit_local_variable_types, directives_ordering
import 'package:dartz/dartz.dart';

import 'package:stylecart/core/errors/exceptions.dart';
import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/features/auth/domain/entities/user_entity.dart';
import 'package:stylecart/features/auth/domain/repositories/auth_repository.dart';
import 'package:stylecart/features/auth/data/datasources/auth_remote_datasource.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);
  final AuthRemoteDataSource _dataSource;

  // Cached current user (updated on every auth state change)
  UserEntity? _cachedUser;

  @override
  UserEntity? get currentUser => _cachedUser;

  // ── Auth state stream ────────────────────────────────────────
  @override
  Stream<UserEntity?> get authStateChanges {
    return _dataSource.firebaseAuthStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _cachedUser = null;
        return null;
      }
      try {
        final user = await _dataSource.getUserFromFirestore(firebaseUser.uid);
        _cachedUser = user;
        return user;
      } catch (_) {
        // User exists in Auth but not Firestore —
        // sign them out for safety
        await _dataSource.signOut();
        _cachedUser = null;
        return null;
      }
    });
  }

  // ── Sign In with Email ───────────────────────────────────────
  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.signInWithEmail(email, password);
      _cachedUser = user;
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── Register with Email ─────────────────────────────────────
  @override
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = await _dataSource.registerWithEmail(
        email,
        password,
        displayName,
      );
      _cachedUser = user;
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ── Sign In with Google ─────────────────────────────────────
  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await _dataSource.signInWithGoogle();
      _cachedUser = user;
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ── Sign Out ────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _dataSource.signOut();
      _cachedUser = null;
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ── Send Password Reset ─────────────────────────────────────
  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _dataSource.sendPasswordReset(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  // ── Send Email Verification ─────────────────────────────────
  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      await _dataSource.sendEmailVerification();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  // ── Refresh User Profile ────────────────────────────────────
  @override
  Future<Either<Failure, UserEntity>> refreshUserProfile() async {
    try {
      final uid =
          _cachedUser?.uid ?? (throw const AuthException('Not logged in'));
      final user = await _dataSource.getUserFromFirestore(uid);
      _cachedUser = user;
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    }
  }

  // ── Update FCM Token ────────────────────────────────────────
  @override
  Future<Either<Failure, void>> updateFcmToken(String token) async {
    try {
      final uid = _cachedUser?.uid;
      if (uid == null) return const Right(null);
      await _dataSource.updateFcmToken(uid, token);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ── Delete Account ──────────────────────────────────────────
  @override
  Future<Either<Failure, void>> deleteAccount() async {
    // Implementation in Phase 11 (Security)
    return const Right(null);
  }
}
