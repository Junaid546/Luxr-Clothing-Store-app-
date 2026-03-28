import 'package:stylecart/features/auth/domain/entities/user_entity.dart';
import 'package:stylecart/features/auth/domain/repositories/auth_repository.dart';

/// Use case for getting auth state stream
/// Note: This is NOT a standard UseCase because it returns a Stream
class GetAuthStateUseCase {
  const GetAuthStateUseCase(this._repository);
  final AuthRepository _repository;

  /// Returns stream of UserEntity? - null when signed out
  Stream<UserEntity?> call() => _repository.authStateChanges;
}
