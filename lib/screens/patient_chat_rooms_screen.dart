import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../services/chat_service.dart';
import '../models/chat_message.dart';
import '../core/localization/app_localizations.dart';

class PatientChatRoomsScreen extends StatefulWidget {
  const PatientChatRoomsScreen({super.key});

  @override
  State<PatientChatRoomsScreen> createState() => _PatientChatRoomsScreenState();
}

class _PatientChatRoomsScreenState extends State<PatientChatRoomsScreen> {
  final ChatService _chatService = ChatService();
  List<ChatRoom> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    final result = await _chatService.getChatRooms();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _rooms = result['chatRooms'] ?? [];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc?.translate('message') ?? 'الرسائل'), // Same key if generic, or use hardcoded arabic
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRooms,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? Center(
                  child: Text(
                    loc?.translate('no_messages') ?? 'لا توجد رسائل بعد',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRooms,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) {
                      final room = _rooms[index];
                      return _buildRoomCard(room);
                    },
                  ),
                ),
    );
  }

  Widget _buildRoomCard(ChatRoom room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          // Display Doctor Name initial
          child: Text(
            room.doctorName.isNotEmpty ? room.doctorName[0].toUpperCase() : 'D',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          room.doctorName, // Display Doctor Name
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          room.lastMessage?.text ?? 'إبدء المحادثة الآن',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatDate(room.createdAt),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            if ((room.unreadCount ?? 0) > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Text(
                  '${room.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/patient-chat', // New route
            arguments: {
              'id': room.doctorId, 
              'name': room.doctorName, 
              'doctor_id': room.doctorId
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}';
  }
}
