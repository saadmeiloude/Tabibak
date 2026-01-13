import 'package:dio/dio.dart';

/// Base class for all API exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

/// 400 Bad Request
class BadRequestException extends ApiException {
  BadRequestException(String message, {dynamic data})
      : super(message, statusCode: 400, data: data);
}

/// 401 Unauthorized
class UnauthorizedException extends ApiException {
  UnauthorizedException(String message, {dynamic data})
      : super(message, statusCode: 401, data: data);
}

/// 403 Forbidden
class ForbiddenException extends ApiException {
  ForbiddenException(String message, {dynamic data})
      : super(message, statusCode: 403, data: data);
}

/// 404 Not Found
class NotFoundException extends ApiException {
  NotFoundException(String message, {dynamic data})
      : super(message, statusCode: 404, data: data);
}

/// 409 Conflict
class ConflictException extends ApiException {
  ConflictException(String message, {dynamic data})
      : super(message, statusCode: 409, data: data);
}

/// 500 Internal Server Error
class ServerException extends ApiException {
  ServerException(String message, {dynamic data})
      : super(message, statusCode: 500, data: data);
}

/// Network/Connection errors
class NetworkException extends ApiException {
  NetworkException(String message) : super(message, statusCode: null);
}

/// Timeout errors
class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message, statusCode: null);
}

/// Helper to convert DioException to custom ApiException
ApiException handleDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return TimeoutException('Request timeout. Please try again.');

    case DioExceptionType.connectionError:
      return NetworkException('No internet connection. Please check your network.');

    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      final message = error.response?.data?['message'] ?? 
                     error.response?.data?['error'] ?? 
                     'An error occurred';

      switch (statusCode) {
        case 400:
          return BadRequestException(message, data: error.response?.data);
        case 401:
          return UnauthorizedException(message, data: error.response?.data);
        case 403:
          return ForbiddenException(message, data: error.response?.data);
        case 404:
          return NotFoundException(message, data: error.response?.data);
        case 409:
          return ConflictException(message, data: error.response?.data);
        case 500:
        case 502:
        case 503:
          return ServerException(message, data: error.response?.data);
        default:
          return ApiException(message, statusCode: statusCode, data: error.response?.data);
      }

    case DioExceptionType.cancel:
      return ApiException('Request was cancelled');

    default:
      return ApiException(error.message ?? 'An unexpected error occurred');
  }
}
