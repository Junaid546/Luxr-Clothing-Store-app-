import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for refreshing user profile from Firestore
class RefreshUserProfileUseCase implements UseCase<UserEntity, NoParams> {
  final AuthRepository _repository;

  const RefreshUserProfileUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return _repository.refreshUserProfile();
  }
}
