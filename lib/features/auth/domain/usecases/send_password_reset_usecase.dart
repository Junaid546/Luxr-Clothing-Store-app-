import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/core/usecases/usecase.dart';
import 'package:stylecart/core/utils/extensions.dart';
import 'package:stylecart/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for password reset use case
class PasswordResetParams extends Equatable {
  const PasswordResetParams({required this.email});
  final String email;

  @override
  List<Object> get props => [email];
}

/// Use case for sending password reset email
class SendPasswordResetUseCase implements UseCase<void, PasswordResetParams> {
  const SendPasswordResetUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(PasswordResetParams params) {
    // Validate email before calling repository
    if (!params.email.isValidEmail) {
      return Future.value(
        const Left(ValidationFailure('Enter a valid email address')),
      );
    }

    return _repository.sendPasswordResetEmail(
      email: params.email.trim().toLowerCase(),
    );
  }
}
