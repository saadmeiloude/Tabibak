import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../models/chat_message.dart';
import '../models/user.dart';
import '../services/websocket_service.dart';
import 'dart:async';

class PatientChatScreen extends StatefulWidget {
  final Map<String, dynamic> doctor; // Expects doctor info {id, name}

  const PatientChatScreen({super.key, required this.doctor});

  @override
  State<PatientChatScreen> createState() => _PatientChatScreenState();
}

class _PatientChatScreenState extends State<PatientChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final WebSocketService _webSocketService = WebSocketService();
  
  List<ChatMessage> _messages = [];
  User? _currentUser;
  String _roomId = '';
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _pollingTimer;
  StreamSubscription? _msgSubscription;

  @override
  void initState() {
    super.initState();
    _webSocketService.activate();
    _initChat();
  }

  Future<void> _initChat() async {
    _currentUser = await AuthService.getCurrentUser();
    
    final doctorId = widget.doctor['id'] ?? widget.doctor['doctor_id'];
    
    if (doctorId != null) {
      final roomResult = await _chatService.getChatRooms(); // Gets rooms for current patient
      if (roomResult['success']) {
        final rooms = roomResult['chatRooms'] as List<ChatRoom>;

        try {
          final room = rooms.firstWhere(
            (r) => r.doctorId == int.parse(doctorId.toString()),
          );
          _roomId = room.id;
          _webSocketService.subscribeToRoom(_roomId);
          _listenToMessages();
        } catch (e) {
          // Room not found, create it
          final createResult = await _chatService.createChatRoom(
            doctorId: int.parse(doctorId.toString()),
            patientId: _currentUser?.id ?? 0, // I am the patient
            senderId: _currentUser?.id,
          );
          
          if (createResult['success']) {
            final newRoom = createResult['chatRoom'] as ChatRoom;
            _roomId = newRoom.id;
            _webSocketService.subscribeToRoom(_roomId);
            _listenToMessages();
          } else {
             print('Could not find or create room.');
             _isLoading = false;
             setState(() {});
             return;
          }
        }
      }
    } else {
       print('Doctor ID missing');
       setState(() => _isLoading = false);
       return;
    }
    await _loadMessages();
    
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadMessages(silent: true));
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    
    final result = await _chatService.getMessages(roomId: _roomId);
    
    if (mounted) {
      setState(() {
        if (result['success']) {
          _messages = result['messages'];
        }
        _isLoading = false;
      });
      if (!silent) _scrollToBottom();
    }
  }

  void _listenToMessages() {
    _msgSubscription = _webSocketService.messageStream.listen((message) {
      if (message.roomId == _roomId) {
        if (mounted) {
          setState(() {
            if (!_messages.any((m) => m.id == message.id)) {
              _messages.add(message);
              _scrollToBottom();
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _msgSubscription?.cancel();
    _webSocketService.deactivate();
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    if (_roomId.isEmpty) return;

    final text = _messageController.text.trim();
    _messageController.clear();
    
    setState(() => _isSending = true);

    final result = await _chatService.sendMessage(
      roomId: _roomId,
      text: text,
    );

    if (mounted) {
      if (result['success']) {
        final newMessage = result['message'] as ChatMessage;
        setState(() {
          if (!_messages.any((m) => m.id == newMessage.id)) {
            _messages.add(newMessage);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = widget.doctor['name'] ?? 'الدكتور';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          doctorName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      // Use senderType or senderId to determine 'isMe'.
                      // Assuming Patient runs this, if senderType is PATIENT or senderId is me, it's me.
                      final isMe = message.senderId == _currentUser?.id;
                      return _buildMessageBubble(message, isMe);
                    },
                  ),
                ),
                _buildMessageInput(),
              ],
            ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك هنا...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey.shade100,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          _isSending 
            ? const SizedBox(width: 48, height: 48, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
            : Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
        ],
      ),
    );
  }
}
