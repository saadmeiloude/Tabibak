class Review {
  final int id;
  final int doctorId;
  final int patientId;
  final int rating;
  final String? reviewText;
  final bool isAnonymous;
  final int? appointmentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.rating,
    this.reviewText,
    this.isAnonymous = false,
    this.appointmentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: int.parse(json['id'].toString()),
      doctorId: int.parse(json['doctorId'].toString()),
      patientId: int.parse(json['patientId'].toString()),
      rating: int.parse(json['rating'].toString()),
      reviewText: json['reviewText'],
      isAnonymous: json['isAnonymous'] == true || json['isAnonymous'] == 1 || json['isAnonymous'] == '1',
      appointmentId: json['appointmentId'] != null ? int.parse(json['appointmentId'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'rating': rating,
      'reviewText': reviewText,
      'isAnonymous': isAnonymous,
      'appointmentId': appointmentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isPositive => rating >= 4;
  bool get isNegative => rating <= 2;
}
