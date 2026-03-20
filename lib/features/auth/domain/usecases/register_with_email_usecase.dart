import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Parameters for registration use case
class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final String displayName;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.displayName,
  });

  @override
  List<Object> get props => [email, password, confirmPassword, displayName];
}

/// Use case for registering a new user with email and password
class RegisterWithEmailUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository _repository;

  const RegisterWithEmailUseCase(this._repository);

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
