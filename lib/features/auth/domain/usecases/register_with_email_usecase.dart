import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/core/usecases/usecase.dart';
import 'package:stylecart/core/utils/validators.dart';
import 'package:stylecart/features/auth/domain/entities/user_entity.dart';
import 'package:stylecart/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for registration use case
class RegisterParams extends Equatable {
  const RegisterParams({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.displayName,
  });
  final String email;
  final String password;
  final String confirmPassword;
  final String displayName;

  @override
  List<Object> get props => [email, password, confirmPassword, displayName];
}

/// Use case for registering a new user with email and password
class RegisterWithEmailUseCase implements UseCase<UserEntity, RegisterParams> {
  const RegisterWithEmailUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) {
    // Validate email
    final emailError = Validators.validateEmail(params.email);
    if (emailError != null) {
      return Future.value(Left(ValidationFailure(emailError)));
    }

    // Validate password strength
    final passwordError = Validators.validatePassword(params.password);
    if (passwordError != null) {
      return Future.value(Left(ValidationFailure(passwordError)));
    }

    // Validate password confirmation
    if (params.password != params.confirmPassword) {
      return Future.value(
        const Left(ValidationFailure('Passwords do not match')),
      );
    }

    // Validate display name
    final nameError = Validators.validateName(params.displayName);
    if (nameError != null) {
      return Future.value(Left(ValidationFailure(nameError)));
    }

    return _repository.registerWithEmail(
      email: params.email.trim().toLowerCase(),
      password: params.password,
      displayName: params.displayName.trim(),
    );
  }
}
