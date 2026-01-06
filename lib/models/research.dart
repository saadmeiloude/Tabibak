class Research {
  final int id;
  final int doctorId;
  final String title;
  final String? summary;
  final String? content;
  final String? attachmentUrl;
  final String? category;
  final String? tags;
  final bool isPublished;
  final String? doctorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Research({
    required this.id,
    required this.doctorId,
    required this.title,
    this.summary,
    this.content,
    this.attachmentUrl,
    this.category,
    this.tags,
    required this.isPublished,
    this.doctorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Research.fromJson(Map<String, dynamic> json) {
    return Research(
      id: int.parse(json['id'].toString()),
      doctorId: int.parse(json['doctor_id'].toString()),
      title: json['title'],
      summary: json['summary'],
      content: json['content'],
      attachmentUrl: json['attachment_url'],
      category: json['category'],
      tags: json['tags'],
      isPublished:
          json['is_published'] == 1 ||
          json['is_published'] == '1' ||
          json['is_published'] == true,
      doctorName: json['doctor_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'title': title,
      'summary': summary,
      'content': content,
      'attachment_url': attachmentUrl,
      'category': category,
      'tags': tags,
      'is_published': isPublished,
      'doctor_name': doctorName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
