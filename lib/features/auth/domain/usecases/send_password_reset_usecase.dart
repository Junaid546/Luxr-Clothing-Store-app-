import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/extensions.dart';
import '../repositories/auth_repository.dart';

/// Parameters for password reset use case
class PasswordResetParams extends Equatable {
  final String email;

  const PasswordResetParams({required this.email});

  @override
  List<Object> get props => [email];
}

/// Use case for sending password reset email
class SendPasswordResetUseCase implements UseCase<void, PasswordResetParams> {
  final AuthRepository _repository;

  const SendPasswordResetUseCase(this._repository);

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
