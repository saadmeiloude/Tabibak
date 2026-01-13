import 'package:dio/dio.dart';
import '../exceptions/api_exception.dart';

class ErrorHandler {
  /// Convert DioException to user-friendly message
  static String getUserMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }

    if (error is DioException) {
      final apiException = handleDioException(error);
      return apiException.message;
    }

    return 'An unexpected error occurred. Please try again.';
  }

  /// Log error for debugging
  static void logError(dynamic error, {StackTrace? stackTrace}) {
    print('=== ERROR ===');
    print('Error: $error');
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
    print('=============');
  }

  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    if (error is NetworkException || error is TimeoutException) {
      return true;
    }

    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
             error.type == DioExceptionType.connectionTimeout ||
             error.type == DioExceptionType.sendTimeout ||
             error.type == DioExceptionType.receiveTimeout;
    }

    return false;
  }

  /// Check if error requires re-authentication
  static bool requiresReauth(dynamic error) {
    if (error is UnauthorizedException) {
      return true;
    }

    if (error is DioException) {
      return error.response?.statusCode == 401;
    }

    return false;
  }
}
