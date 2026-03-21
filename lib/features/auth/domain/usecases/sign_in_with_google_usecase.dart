import 'package:dartz/dartz.dart';

import 'package:style_cart/core/errors/failures.dart';
import 'package:style_cart/core/usecases/usecase.dart';
import 'package:style_cart/features/auth/domain/entities/user_entity.dart';
import 'package:style_cart/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing in with Google OAuth
/// No params needed - initiates OAuth flow
class SignInWithGoogleUseCase implements UseCase<UserEntity, NoParams> {
  const SignInWithGoogleUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return _repository.signInWithGoogle();
  }
}
