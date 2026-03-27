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
import 'package:style_cart/core/utils/validators.dart';
import 'package:style_cart/core/utils/sanitizer.dart';
import 'package:style_cart/core/security/rate_limiter.dart';

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
    // ── Rate limit check ─────────────────────────────
    if (!RateLimiter.canAttemptLogin(email)) {
      state = const AuthError(
        'Too many login attempts. Please wait a moment before trying again.',
      );
      return;
    }

    // ── Input sanitization ────────────────────────────
    final sanitizedEmail = Sanitizer.sanitizeEmail(email);

    // ── Validation ────────────────────────────────────
    final emailError = Validators.validateEmail(sanitizedEmail);
    if (emailError != null) {
      state = AuthError(emailError);
      return;
    }

    state = const AuthLoading();
    final result = await _ref
        .read(signInWithEmailUseCaseProvider)
        .call(SignInWithEmailParams(
          email: sanitizedEmail,
          password: password,
        ));

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
    // ── Rate limit check ─────────────────────────────
    if (!RateLimiter.canAttemptRegistration()) {
      state = const AuthError(
        'Too many registration attempts. Please wait.',
      );
      return;
    }

    // ── Sanitize inputs ───────────────────────────────
    final sanitizedEmail = Sanitizer.sanitizeEmail(email);
    final sanitizedName = Sanitizer.sanitizeName(displayName);

    // ── Validate all fields ───────────────────────────
    final emailError = Validators.validateEmail(sanitizedEmail);
    if (emailError != null) {
      state = AuthError(emailError);
      return;
    }

    final nameError = Validators.validateDisplayName(sanitizedName);
    if (nameError != null) {
      state = AuthError(nameError);
      return;
    }

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      state = AuthError(passwordError);
      return;
    }

    if (password != confirmPassword) {
      state = const AuthError('Passwords do not match');
      return;
    }

    state = const AuthLoading();
    final result = await _ref
        .read(registerWithEmailUseCaseProvider)
        .call(
          RegisterParams(
            email: sanitizedEmail,
            password: password,
            confirmPassword: confirmPassword,
            displayName: sanitizedName,
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
    // ── Rate limit ────────────────────────────────────
    if (!RateLimiter.canRequestPasswordReset(email)) {
      state = const AuthError(
        'Password reset email already sent. Please check your inbox or wait 5 minutes.',
      );
      return false;
    }

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
