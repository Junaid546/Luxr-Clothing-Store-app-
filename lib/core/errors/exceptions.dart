final class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error occurred']);
}

final class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);
}

final class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

final class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Resource not found']);
}

final class PermissionException implements Exception {
  final String message;
  const PermissionException([this.message = 'Permission denied']);
}

final class StockException implements Exception {
  final String message;
  const StockException(this.message);
}

final class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}

final class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache read error']);
}
