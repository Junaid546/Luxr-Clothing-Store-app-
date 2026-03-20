import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting auth state stream
/// Note: This is NOT a standard UseCase because it returns a Stream
class GetAuthStateUseCase {
  final AuthRepository _repository;

  const GetAuthStateUseCase(this._repository);

  /// Returns stream of UserEntity? - null when signed out
  Stream<UserEntity?> call() => _repository.authStateChanges;
}
