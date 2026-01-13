class ChatRoom {
  final int id;
  final int? senderId;
  final int? receiverId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatRoom({
    required this.id,
    this.senderId,
    this.receiverId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: int.parse(json['id'].toString()),
      senderId: json['senderId'] != null ? int.parse(json['senderId'].toString()) : null,
      receiverId: json['receiverId'] != null ? int.parse(json['receiverId'].toString()) : null,
      isActive: json['isActive'] == true || json['isActive'] == 1 || json['isActive'] == '1',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
