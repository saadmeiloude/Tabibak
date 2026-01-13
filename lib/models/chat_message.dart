class ChatRoom {
  final String id;
  final int doctorId;
  final String doctorName;
  final int patientId;
  final String patientName;
  final int? appointmentId;
  final String status; // ACTIVE, CLOSED, ARCHIVED
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final ChatMessage? lastMessage;

  ChatRoom({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    this.appointmentId,
    this.status = 'ACTIVE',
    required this.createdAt,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.lastMessage,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }
    
    return ChatRoom(
      id: json['id'].toString(),
      doctorId: parseInt(json['doctorId'] ?? json['doctor_id']),
      doctorName: (() {
        final name = (json['doctorName'] ?? json['doctor_name'])?.toString();
        if (name != null && name != 'null' && name.isNotEmpty) return name;
        
        // Try to construct from parts
        final first = (json['doctorFirstName'] ?? json['doctor_first_name'] ?? '').toString();
        final last = (json['doctorLastName'] ?? json['doctor_last_name'] ?? '').toString();
        if (first.isNotEmpty || last.isNotEmpty) {
          return '$first $last'.trim();
        }
        
        // Try nested object
        if (json['doctor'] is Map) {
           final d = json['doctor'];
           // Check if doctor has nested 'user' object (common pattern)
           if (d['user'] is Map) {
             final u = d['user'];
             final uFirst = (u['firstName'] ?? u['first_name'] ?? '').toString();
             final uLast = (u['lastName'] ?? u['last_name'] ?? '').toString();
             if (uFirst.isNotEmpty || uLast.isNotEmpty) return '$uFirst $uLast'.trim();
           }
           
           final dFirst = (d['firstName'] ?? d['first_name'] ?? '').toString();
           final dLast = (d['lastName'] ?? d['last_name'] ?? '').toString();
           if (dFirst.isNotEmpty || dLast.isNotEmpty) return '$dFirst $dLast'.trim();
        }
        
        return 'Unknown Doctor';
      })(),
      patientId: parseInt(json['patientId'] ?? json['patient_id']),
      patientName: (() {
        final name = (json['patientName'] ?? json['patient_name'])?.toString();
        if (name != null && name != 'null' && name.isNotEmpty) return name;

        // Try to construct from parts
        final first = (json['patientFirstName'] ?? json['patient_first_name'] ?? '').toString();
        final last = (json['patientLastName'] ?? json['patient_last_name'] ?? '').toString();
        if (first.isNotEmpty || last.isNotEmpty) {
          return '$first $last'.trim();
        }
        
        return 'Unknown Patient';
      })(),
      appointmentId: json['appointmentId'] != null || json['appointment_id'] != null 
          ? parseInt(json['appointmentId'] ?? json['appointment_id']) 
          : null,
      status: (json['status'] ?? 'ACTIVE').toString(),
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      lastMessageAt: json['lastMessageAt'] != null || json['last_message_at'] != null
          ? DateTime.parse(json['lastMessageAt'] ?? json['last_message_at'])
          : null,
      unreadCount: parseInt(json['unreadCount'] ?? json['unread_count']),
      lastMessage: json['lastMessage'] != null
          ? ChatMessage.fromJson(json['lastMessage'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'appointmentId': appointmentId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'unreadCount': unreadCount,
      'lastMessage': lastMessage?.toJson(),
    };
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final int senderId;
  final String senderName;
  final String senderType; // PATIENT, DOCTOR
  final String text;
  final String type; // TEXT, IMAGE, FILE
  final String? fileUrl;
  final bool isRead;
  final DateTime sentAt;
  final DateTime? readAt;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.text,
    this.type = 'TEXT',
    this.fileUrl,
    this.isRead = false,
    required this.sentAt,
    this.readAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      roomId: (json['roomId'] ?? json['room_id'] ?? '').toString(),
      senderId: json['senderId'] ?? json['sender_id'] ?? 0,
      senderName: (json['senderName'] ?? json['sender_name'] ?? 'Unknown').toString(),
      senderType: (json['senderType'] ?? json['sender_type'] ?? 'USER').toString(),
      text: (json['text'] ?? json['content'] ?? json['message'] ?? json['body'] ?? '').toString(),
      type: (json['type'] ?? 'TEXT').toString(),
      fileUrl: json['fileUrl']?.toString() ?? json['file_url']?.toString(),
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      sentAt: DateTime.parse(json['sentAt'] ?? json['sent_at'] ?? DateTime.now().toIso8601String()),
      readAt: json['readAt'] != null || json['read_at'] != null
          ? DateTime.tryParse((json['readAt'] ?? json['read_at']).toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'text': text,
      'type': type,
      'fileUrl': fileUrl,
      'isRead': isRead,
      'sentAt': sentAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  bool get isMe => false; // Will be determined in UI based on current user
}
