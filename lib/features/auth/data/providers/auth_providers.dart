import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stylecart/core/providers/firebase_providers.dart';
import 'package:stylecart/features/auth/domain/repositories/auth_repository.dart';
import 'package:stylecart/features/auth/domain/usecases/get_auth_state_usecase.dart';
import 'package:stylecart/features/auth/domain/usecases/register_with_email_usecase.dart';
import 'package:stylecart/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:stylecart/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:stylecart/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:stylecart/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:stylecart/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:stylecart/features/auth/domain/usecases/refresh_user_profile_usecase.dart';
import 'package:stylecart/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:stylecart/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:stylecart/features/auth/data/repositories/auth_repository_impl.dart';

// ── Data Source Provider ───────────────────────────────────────
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

// ── Repository Provider ───────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

// ── Use Case Providers ────────────────────────────────────────
final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) {
  return SignInWithEmailUseCase(ref.watch(authRepositoryProvider));
});

final registerWithEmailUseCaseProvider = Provider<RegisterWithEmailUseCase>((
  ref,
) {
  return RegisterWithEmailUseCase(ref.watch(authRepositoryProvider));
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((
  ref,
) {
  return SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final sendPasswordResetUseCaseProvider = Provider<SendPasswordResetUseCase>((
  ref,
) {
  return SendPasswordResetUseCase(ref.watch(authRepositoryProvider));
});

final getAuthStateUseCaseProvider = Provider<GetAuthStateUseCase>((ref) {
  return GetAuthStateUseCase(ref.watch(authRepositoryProvider));
});

// ── Auth State Stream Provider ─────────────────────────────────
// This is the main provider for observing auth state
final authStateProvider = StreamProvider.autoDispose((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

// ── Current User Provider ─────────────────────────────────────
// Convenience provider to get current user synchronously
final currentUserProvider = Provider.autoDispose((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(data: (user) => user);
});
