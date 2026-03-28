import 'package:dartz/dartz.dart';

import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/core/usecases/usecase.dart';
import 'package:stylecart/features/auth/domain/entities/user_entity.dart';
import 'package:stylecart/features/auth/domain/repositories/auth_repository.dart';

/// Use case for refreshing user profile from Firestore
class RefreshUserProfileUseCase implements UseCase<UserEntity, NoParams> {
  const RefreshUserProfileUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return _repository.refreshUserProfile();
  }
}
