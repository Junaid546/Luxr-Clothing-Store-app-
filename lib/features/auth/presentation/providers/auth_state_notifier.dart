import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:style_cart/core/usecases/usecase.dart';
import 'package:style_cart/features/auth/data/providers/auth_providers.dart';
import 'package:style_cart/features/notifications/data/providers/notification_providers.dart';
import 'package:style_cart/features/auth/domain/entities/user_entity.dart';
import 'package:style_cart/features/auth/domain/usecases/register_with_email_usecase.dart';
import 'package:style_cart/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:style_cart/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:style_cart/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:style_cart/features/auth/domain/usecases/sign_out_usecase.dart';

// ── Auth State ────────────────────────────────────────────────
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final UserEntity user;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

// ── Auth Notifier ───────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthInitial()) {
    _listenToAuthChanges();
  }
  final Ref _ref;

  void _listenToAuthChanges() {
    final repository = _ref.read(authRepositoryProvider);
    repository.authStateChanges.listen((user) async {
      if (user != null) {
        state = AuthAuthenticated(user);
        // FCM Initialization is now handled by fcmInitializerProvider in app.dart
      } else {
        state = const AuthUnauthenticated();
      }
    }, onError: (_) => state = const AuthUnauthenticated());
  }

  // ── Sign In with Email ────────────────────────────────────
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    final result = await _ref
        .read(signInWithEmailUseCaseProvider)
        .call(SignInWithEmailParams(email: email, password: password));
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  // ── Register ─────────────────────────────────────────────
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String confirmPassword,
    required String displayName,
  }) async {
    state = const AuthLoading();
    final result = await _ref
        .read(registerWithEmailUseCaseProvider)
        .call(
          RegisterParams(
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            displayName: displayName,
          ),
        );
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  // ── Google Sign In ───────────────────────────────────────
  Future<void> signInWithGoogle() async {
    state = const AuthLoading();
    final result = await _ref
        .read(signInWithGoogleUseCaseProvider)
        .call(NoParams());
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  // ── Sign Out ─────────────────────────────────────────────
  Future<void> signOut() async {
    state = const AuthLoading();
    final result = await _ref.read(signOutUseCaseProvider).call(NoParams());
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) async {
        final user = currentUser;
        if (user != null) {
          await _ref.read(fcmServiceProvider).clearToken(user.uid);
        }
        state = const AuthUnauthenticated();
      },
    );
  }

  // ── Password Reset ───────────────────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    state = const AuthLoading();
    final result = await _ref
        .read(sendPasswordResetUseCaseProvider)
        .call(PasswordResetParams(email: email));
    return result.fold(
      (failure) {
        state = AuthError(failure.message);
        return false;
      },
      (_) {
        state = const AuthUnauthenticated();
        return true;
      },
    );
  }

  // ── Helper: get current user ─────────────────────────────
  UserEntity? get currentUser {
    return switch (state) {
      AuthAuthenticated(:final user) => user,
      _ => null,
    };
  }
}

// ── Auth Notifier Provider ─────────────────────────────────
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(ref);
});

// ── Auth Redirect Status ────────────────────────────────────
enum AuthRedirectStatus { loading, customer, admin, unauthenticated }

final authRedirectStatusProvider = Provider<AuthRedirectStatus>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return switch (authState) {
    AuthInitial() => AuthRedirectStatus.loading,
    AuthLoading() => AuthRedirectStatus.loading,
    AuthAuthenticated(:final user) =>
      user.isAdmin ? AuthRedirectStatus.admin : AuthRedirectStatus.customer,
    AuthUnauthenticated() => AuthRedirectStatus.unauthenticated,
    AuthError() => AuthRedirectStatus.unauthenticated,
  };
});
