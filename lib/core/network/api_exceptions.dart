/// Base class for API-layer exceptions.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Session expired. Please log in again.'])
      : super(message, statusCode: 401);
}

class ConflictException extends ApiException {
  ConflictException(String message) : super(message, statusCode: 409);
}

class NotFoundException extends ApiException {
  NotFoundException([String message = 'Resource not found.'])
      : super(message, statusCode: 404);
}

class BadRequestException extends ApiException {
  BadRequestException([String message = 'Invalid request. Please check your input.'])
      : super(message, statusCode: 400);
}

class ServerException extends ApiException {
  ServerException([String message = 'Something went wrong. Please try again later.'])
      : super(message, statusCode: 500);
}

class NetworkException extends ApiException {
  NetworkException([String message = 'Unable to connect to the server. Check your internet.'])
      : super(message);
}
