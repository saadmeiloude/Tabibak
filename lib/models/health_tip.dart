class HealthTip {
  final int id;
  final String title;
  final String content;
  final String category; // GENERAL, NUTRITION, EXERCISE, MENTAL_HEALTH
  final String icon;
  final String date;
  final String language;
  final DateTime createdAt;

  HealthTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.icon = 'info',
    required this.date,
    this.language = 'fr',
    required this.createdAt,
  });

  factory HealthTip.fromJson(Map<String, dynamic> json) {
    return HealthTip(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      icon: json['icon'] ?? 'info',
      date: json['date'] as String,
      language: json['language'] ?? 'fr',
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'icon': icon,
      'date': date,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
