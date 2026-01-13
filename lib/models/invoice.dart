import '../core/models/enums.dart';

class Invoice {
  final int id;
  final int? patientId;
  final int? doctorId;
  final String? patientName;
  final String? doctorName;
  final String service;
  final DateTime date;
  final double amount;
  final PaymentMethod paymentMethod;
  final InvoiceStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invoice({
    required this.id,
    this.patientId,
    this.doctorId,
    this.patientName,
    this.doctorName,
    required this.service,
    required this.date,
    required this.amount,
    this.paymentMethod = PaymentMethod.cash,
    this.status = InvoiceStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Invoice(
      id: int.parse(json['id'].toString()),
      patientId: json['patientId'] != null ? int.parse(json['patientId'].toString()) : null,
      doctorId: json['doctorId'] != null ? int.parse(json['doctorId'].toString()) : null,
      patientName: json['patientName'],
      doctorName: json['doctorName'],
      service: json['service'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      amount: parseDouble(json['amount']),
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == json['paymentMethod'].toString().toUpperCase(),
              orElse: () => PaymentMethod.cash)
          : PaymentMethod.cash,
      status: json['status'] != null
          ? InvoiceStatus.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == json['status'].toString().toUpperCase(),
              orElse: () => InvoiceStatus.pending)
          : InvoiceStatus.pending,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'patientName': patientName,
      'doctorName': doctorName,
      'service': service,
      'date': date.toIso8601String().split('T')[0],
      'amount': amount,
      'paymentMethod': paymentMethod.toString().split('.').last.toUpperCase(),
      'status': status.toString().split('.').last.toUpperCase(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isPaid => status == InvoiceStatus.paid;
  bool get isPending => status == InvoiceStatus.pending;
  bool get isOverdue => status == InvoiceStatus.overdue;
}
