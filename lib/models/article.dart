class Article {
  final int id;
  final String title;
  final String content;
  final String? category;
  final String? tags;
  final int? authorId;
  final bool published;
  final String? coverImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Article({
    required this.id,
    required this.title,
    required this.content,
    this.category,
    this.tags,
    this.authorId,
    this.published = false,
    this.coverImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'],
      tags: json['tags'],
      authorId: json['authorId'] != null ? int.parse(json['authorId'].toString()) : null,
      published: json['published'] == true || json['published'] == 1 || json['published'] == '1',
      coverImage: json['coverImage'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'tags': tags,
      'authorId': authorId,
      'published': published,
      'coverImage': coverImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  List<String> get tagList {
    if (tags == null || tags!.isEmpty) return [];
    return tags!.split(',').map((e) => e.trim()).toList();
  }

  bool get hasCoverImage => coverImage != null && coverImage!.isNotEmpty;
  String get excerpt => content.length > 150 ? '${content.substring(0, 150)}...' : content;
}
