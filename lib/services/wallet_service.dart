import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/exceptions/api_exception.dart';
import '../models/wallet.dart';
import 'auth_service.dart';

class WalletService {
  // Helper to get user type safely
  static Future<String> _getUserType(int userId) async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user != null && user.id == userId) {
        return user.userType; // 'doctor' or 'patient'
      }
    } catch (_) {}
    return 'patient'; // Default fallback
  }

  // Get wallet balance and statistics
  // Get wallet balance and statistics
  static Future<Map<String, dynamic>> getWalletBalance(int userId) async {
    try {
      // Backend extracts userId from token
      final response = await ApiClient().get(
        '/wallets/balance',
        // queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Handle case where backend returns just the balance (e.g., 0 or 2000.0)
        if (data is num) {
          return {
            'success': true,
            'wallet': {
              'id': 0,
              'user_id': userId,
              'balance': data.toDouble(),
              'currency': 'MRU',
              'currency_symbol': 'UM',
              'is_active': true,
              'last_transaction_at': null,
              'created_at': DateTime.now().toIso8601String(),
            },
            'statistics': {
              'total_deposits': 0,
              'total_withdrawals': 0,
              'total_payments': 0,
              'total_transactions': 0
            }
          };
        }
        // Return Map if valid
        if (data is Map<String, dynamic>) {
          return data;
        }
        // Fallback for unexpected format
        throw Exception('تنسيق بيانات غير متوقع');
      } else {
        throw Exception('فشل في جلب بيانات المحفظة');
      }
    } catch (e) {
      // Handle "Wallet not found" by returning a default empty wallet
      // Check for both DioException (raw) and ApiException (processed)
      bool isNotFound = false;
      
      if (e is DioException && (e.response?.statusCode == 400 || e.response?.statusCode == 404)) {
        isNotFound = true;
      } else if (e is ApiException && (e.statusCode == 400 || e.statusCode == 404)) {
        isNotFound = true;
      }

      if (isNotFound) {
        print('Warning: Wallet not found, returning empty wallet. Error: $e');
        return {
          'success': true,
          'wallet': {
            'id': 0,
            'user_id': userId,
            'balance': 0.0,
            'currency': 'MRU',
            'currency_symbol': 'UM',
            'is_active': true,
            'last_transaction_at': null,
            'created_at': DateTime.now().toIso8601String(),
          },
          'statistics': {
            'total_deposits': 0,
            'total_withdrawals': 0,
            'total_payments': 0,
            'total_transactions': 0
          }
        };
      }
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Deposit money to wallet
  // Deposit money to wallet
  static Future<Map<String, dynamic>> deposit({
    required int userId,
    required double amount,
    String paymentMethod = 'card',
    String? description,
    String? phoneNumber,
  }) async {
    try {
      // final userType = await _getUserType(userId);
      final response = await ApiClient().post(
        '/wallets/deposit',
        data: {
          // 'userId': userId,
          // 'userType': userType,
          'amount': amount,
          'paymentMethod': paymentMethod,
          'description': description ?? 'إيداع رصيد',
          'phoneNumber': phoneNumber,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('فشل في إيداع المبلغ');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Request withdrawal
  static Future<Map<String, dynamic>> withdraw({
    required int userId,
    required double amount,
    required String withdrawalMethod,
    String? bankName,
    String? accountNumber,
    String? accountHolderName,
    String? mobileMoneyNumber,
  }) async {
    try {
      // final userType = await _getUserType(userId);
      final response = await ApiClient().post(
        '/wallets/withdraw',
        data: {
          // 'userId': userId,
          // 'userType': userType,
          'amount': amount,
          'withdrawalMethod': withdrawalMethod,
          'bankName': bankName,
          'accountNumber': accountNumber,
          'accountHolderName': accountHolderName,
          'mobileMoneyNumber': mobileMoneyNumber,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('فشل في إنشاء طلب السحب');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Get transaction history
  static Future<Map<String, dynamic>> getTransactions({
    required int userId,
    int limit = 50,
    int offset = 0,
    String? type,
    String? status,
  }) async {
    try {
      // Backend extracts userId from token
      final Map<String, dynamic> params = {
        // 'userId': userId, // Removed as per instruction
        'limit': limit,
        'offset': offset,
      };

      if (type != null) params['type'] = type;
      if (status != null) params['status'] = status;

      final response = await ApiClient().get(
        '/wallets/transactions',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('فشل في جلب المعاملات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }
}
