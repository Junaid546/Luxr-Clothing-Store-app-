sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

final class StockFailure extends Failure {
  const StockFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache read error']);
}
