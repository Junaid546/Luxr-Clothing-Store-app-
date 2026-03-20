import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Parameters for sign in with email use case
class SignInWithEmailParams extends Equatable {
  final String email;
  final String password;

  const SignInWithEmailParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// Use case for signing in with email and password
class SignInWithEmailUseCase
    implements UseCase<UserEntity, SignInWithEmailParams> {
  final AuthRepository _repository;

  const SignInWithEmailUseCase(this._repository);

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
