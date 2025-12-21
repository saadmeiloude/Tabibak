import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class WalletService {
  static const String baseUrl = 'http://localhost:8000/api/wallet';

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
  static Future<Map<String, dynamic>> getWalletBalance(int userId) async {
    try {
      final userType = await _getUserType(userId);
      final response = await http.get(
        Uri.parse(
          '$baseUrl/get_balance.php?user_id=$userId&user_type=$userType',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في جلب بيانات المحفظة');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Deposit money to wallet
  static Future<Map<String, dynamic>> deposit({
    required int userId,
    required double amount,
    String paymentMethod = 'card',
    String? description,
    String? phoneNumber,
  }) async {
    try {
      final userType = await _getUserType(userId);
      final response = await http.post(
        Uri.parse('$baseUrl/deposit.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'user_type': userType,
          'amount': amount,
          'payment_method': paymentMethod,
          'description': description ?? 'إيداع رصيد',
          'phone_number': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
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
      final userType = await _getUserType(userId);
      final response = await http.post(
        Uri.parse('$baseUrl/withdraw.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'user_type': userType,
          'amount': amount,
          'withdrawal_method': withdrawalMethod,
          'bank_name': bankName,
          'account_number': accountNumber,
          'account_holder_name': accountHolderName,
          'mobile_money_number': mobileMoneyNumber,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
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
      final userType = await _getUserType(userId);
      var uri = Uri.parse('$baseUrl/get_transactions.php');
      var params = {
        'user_id': userId.toString(),
        'user_type': userType,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (type != null) params['type'] = type;
      if (status != null) params['status'] = status;

      uri = uri.replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في جلب المعاملات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }
}

// Wallet model
class Wallet {
  final int id;
  final int userId;
  final double balance;
  final String currency;
  final String currencySymbol;
  final bool isActive;
  final DateTime? lastTransactionAt;
  final DateTime createdAt;

  Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.currency,
    required this.currencySymbol,
    required this.isActive,
    this.lastTransactionAt,
    required this.createdAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      userId: json['user_id'],
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'],
      currencySymbol: json['currency_symbol'],
      isActive: json['is_active'],
      lastTransactionAt: json['last_transaction_at'] != null
          ? DateTime.parse(json['last_transaction_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// Transaction model
class WalletTransaction {
  final int id;
  final String reference;
  final String type;
  final double amount;
  final String currency;
  final double balanceBefore;
  final double balanceAfter;
  final String status;
  final String paymentMethod;
  final String description;
  final Map<String, dynamic>? metadata;
  final String? relatedUserName;
  final int? relatedAppointmentId;
  final DateTime createdAt;
  final DateTime? processedAt;

  WalletTransaction({
    required this.id,
    required this.reference,
    required this.type,
    required this.amount,
    required this.currency,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.status,
    required this.paymentMethod,
    required this.description,
    this.metadata,
    this.relatedUserName,
    this.relatedAppointmentId,
    required this.createdAt,
    this.processedAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      reference: json['reference'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      balanceBefore: (json['balance_before'] as num).toDouble(),
      balanceAfter: (json['balance_after'] as num).toDouble(),
      status: json['status'],
      paymentMethod: json['payment_method'],
      description: json['description'],
      metadata: json['metadata'],
      relatedUserName: json['related_user_name'],
      relatedAppointmentId: json['related_appointment_id'],
      createdAt: DateTime.parse(json['created_at']),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'])
          : null,
    );
  }

  String get typeArabic {
    switch (type) {
      case 'deposit':
        return 'إيداع';
      case 'withdrawal':
        return 'سحب';
      case 'payment':
        return 'دفع';
      case 'refund':
        return 'استرداد';
      case 'transfer':
        return 'تحويل';
      case 'commission':
        return 'عمولة';
      default:
        return type;
    }
  }

  String get statusArabic {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'completed':
        return 'مكتمل';
      case 'failed':
        return 'فشل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
