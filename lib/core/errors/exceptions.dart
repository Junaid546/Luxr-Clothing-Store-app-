final class ServerException implements Exception {
  const ServerException([this.message = 'Server error occurred']);
  final String message;
}

final class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection']);
  final String message;
}

final class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}

final class NotFoundException implements Exception {
  const NotFoundException([this.message = 'Resource not found']);
  final String message;
}

final class PermissionException implements Exception {
  const PermissionException([this.message = 'Permission denied']);
  final String message;
}

final class StockException implements Exception {
  const StockException(this.message);
  final String message;
}

final class ValidationException implements Exception {
  const ValidationException(this.message);
  final String message;
}

final class CacheException implements Exception {
  const CacheException([this.message = 'Cache read error']);
  final String message;
}
