import '../core/models/enums.dart';

class Transaction {
  final int id;
  final int walletId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String? description;
  final String? referenceId;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.type,
    this.status = TransactionStatus.pending,
    this.description,
    this.referenceId,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Transaction(
      id: int.parse(json['id'].toString()),
      walletId: int.parse(json['walletId'].toString()),
      amount: parseDouble(json['amount']),
      type: json['type'] != null
          ? TransactionType.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == json['type'].toString().toUpperCase(),
              orElse: () => TransactionType.payment)
          : TransactionType.payment,
      status: json['status'] != null
          ? TransactionStatus.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == json['status'].toString().toUpperCase(),
              orElse: () => TransactionStatus.pending)
          : TransactionStatus.pending,
      description: json['description'],
      referenceId: json['referenceId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'amount': amount,
      'type': type.toString().split('.').last.toUpperCase(),
      'status': status.toString().split('.').last.toUpperCase(),
      'description': description,
      'referenceId': referenceId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isDeposit => type == TransactionType.deposit;
  bool get isWithdrawal => type == TransactionType.withdrawal;
  bool get isPayment => type == TransactionType.payment;
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isPending => status == TransactionStatus.pending;
  bool get isFailed => status == TransactionStatus.failed;
  
  String get formattedAmount {
    final sign = isDeposit ? '+' : '-';
    return '$sign\$${amount.toStringAsFixed(2)}';
  }
}
