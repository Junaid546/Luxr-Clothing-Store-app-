import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with Google OAuth
/// No params needed - initiates OAuth flow
class SignInWithGoogleUseCase implements UseCase<UserEntity, NoParams> {
  final AuthRepository _repository;

  const SignInWithGoogleUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return _repository.signInWithGoogle();
  }
}
