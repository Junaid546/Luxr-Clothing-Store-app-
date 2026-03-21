import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/core/usecases/usecase.dart';
import 'package:style_cart/core/utils/validators.dart';
import 'package:style_cart/features/auth/domain/entities/user_entity.dart';
import 'package:style_cart/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for sign in with email use case
class SignInWithEmailParams extends Equatable {
  const SignInWithEmailParams({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

/// Use case for signing in with email and password
class SignInWithEmailUseCase
    implements UseCase<UserEntity, SignInWithEmailParams> {
  const SignInWithEmailUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithEmailParams params) {
    // Validate email before calling repository
    final emailError = Validators.validateEmail(params.email);
    if (emailError != null) {
      return Future.value(Left(ValidationFailure(emailError)));
    }

    // Validate password is not empty
    if (params.password.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Password is required')),
      );
    }

    return _repository.signInWithEmail(
      email: params.email.trim().toLowerCase(),
      password: params.password,
    );
  }
}
