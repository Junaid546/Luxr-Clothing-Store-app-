import 'package:dartz/dartz.dart';

import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/core/usecases/usecase.dart';
import 'package:stylecart/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing out the current user
class SignOutUseCase implements UseCase<void, NoParams> {
  const SignOutUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.signOut();
  }
}
