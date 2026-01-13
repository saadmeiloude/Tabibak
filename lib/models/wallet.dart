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
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Wallet(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? json['userId']?.toString() ?? '0') ?? 0,
      balance: parseDouble(json['balance']),
      currency: json['currency']?.toString() ?? 'MRU',
      currencySymbol: json['currency_symbol']?.toString() ?? 'UM',
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      lastTransactionAt: (json['last_transaction_at'] ?? json['lastTransactionAt']) != null
          ? DateTime.tryParse((json['last_transaction_at'] ?? json['lastTransactionAt']).toString())
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : (json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'balance': balance,
      'currency': currency,
      'currencySymbol': currencySymbol,
      'isActive': isActive,
      'lastTransactionAt': lastTransactionAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get hasBalance => balance > 0;
  String get formattedBalance => '$currencySymbol ${balance.toStringAsFixed(2)}';
}

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
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return WalletTransaction(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      reference: json['reference']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amount: parseDouble(json['amount']),
      currency: json['currency']?.toString() ?? 'MRU',
      balanceBefore: parseDouble(json['balance_before'] ?? json['balanceBefore']),
      balanceAfter: parseDouble(json['balance_after'] ?? json['balanceAfter']),
      status: json['status']?.toString() ?? 'pending',
      paymentMethod: json['payment_method'] ?? json['paymentMethod'] ?? '',
      description: json['description']?.toString() ?? '',
      metadata: json['metadata'] is Map<String, dynamic> ? json['metadata'] : null,
      relatedUserName: json['related_user_name'] ?? json['relatedUserName'],
      relatedAppointmentId: int.tryParse(json['related_appointment_id']?.toString() ?? json['relatedAppointmentId']?.toString() ?? ''),
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      processedAt: (json['processed_at'] ?? json['processedAt']) != null
          ? DateTime.tryParse((json['processed_at'] ?? json['processedAt']).toString())
          : null,
    );
  }

  String get typeArabic {
    switch (type.toLowerCase()) {
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
    switch (status.toLowerCase()) {
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
