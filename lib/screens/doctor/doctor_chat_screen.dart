import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../models/chat_message.dart';
import '../../models/user.dart';
import '../../models/doctor.dart';
import '../../services/data_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/websocket_service.dart';
import 'dart:async';

class DoctorChatScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const DoctorChatScreen({super.key, required this.patient});

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final WebSocketService _webSocketService = WebSocketService(); // Added WebSocketService
  
  List<ChatMessage> _messages = [];
  User? _currentUser;
  String _roomId = '';
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _pollingTimer;
  StreamSubscription? _msgSubscription; // Added StreamSubscription

  bool _isVideoCallActive = false;
  bool _isMuted = false;
  bool _isCameraOff = false;

  @override
  void initState() {
    super.initState();
    _webSocketService.activate(); // Activate WebSocketService
    _initChat();
  }

  Future<void> _initChat() async {
    _currentUser = await AuthService.getCurrentUser();
    
    // In a real app, you'd get the roomId or create one for the patient
    // For now, we'll try to find a room by patientId or use a mock roomId
    final patientId = widget.patient['id'] ?? widget.patient['patient_id'];
    
    if (patientId != null) {
      final roomResult = await _chatService.getChatRooms();
      if (roomResult['success']) {
        final rooms = roomResult['chatRooms'] as List<ChatRoom>;

        // Fetch real doctor ID
        int realDoctorId = _currentUser?.id ?? 0;
        
        final doctorResult = await DataService.getDoctorProfile();
        if (doctorResult['success']) {
           realDoctorId = (doctorResult['doctor'] as Doctor).id;
        }

        try {
          final room = rooms.firstWhere(
            (r) => r.patientId == int.parse(patientId.toString()),
          );
          _roomId = room.id;
          _webSocketService.subscribeToRoom(_roomId);
          _listenToMessages();
        } catch (e) {
          // Room not found, try to create it
          final createResult = await _chatService.createChatRoom(
            doctorId: realDoctorId,
            patientId: int.parse(patientId.toString()),
            senderId: _currentUser?.id,
          );
          
          if (createResult['success']) {
            final newRoom = createResult['chatRoom'] as ChatRoom;
            _roomId = newRoom.id;
            _webSocketService.subscribeToRoom(_roomId);
            _listenToMessages();
          } else {
             // Handle creation failure or temporary state
             print('Could not find or create room. Using temporary local state.');
             // Do NOT set _roomId to a string that keeps failing requests
             // Just stop here or set a flag so we don't spam the API
             _isLoading = false;
             setState(() {});
             return;
          }
        }
      }
    } else {
       // Only for testing/debugging if patientId is missing
       // Don't set global_chat as it breaks backend
       print('Patient ID missing');
       setState(() => _isLoading = false);
       return;
    }
    await _loadMessages();
    
    // Start polling for new messages every 5 seconds
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
            // Avoid duplicates
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

    // Check if Room ID is valid
    if (_roomId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat room not initialized. Please try again later.')),
        );
        return;
    }

    final text = _messageController.text.trim();
    _messageController.clear();
    
    setState(() => _isSending = true);

    final result = await _chatService.sendMessage(
      roomId: _roomId,
      text: text,
    );

    if (mounted) {
      if (result['success']) {
        // Optimistically add message to UI to ensure visibility
        // This handles both Real Success (WebSocket might be slow) and Mock Fallback
        final newMessage = result['message'] as ChatMessage;
        
        setState(() {
          // Avoid duplicates if WebSocket already caught it
          if (!_messages.any((m) => m.id == newMessage.id)) {
            _messages.add(newMessage);
          }
        });
        
        // Only reload from server if NOT using a mock fallback
        // Reloading from server when server is down (mocking) would wipe the message
        if (result['isMock'] != true) {
           // Optional: _loadMessages(silent: true); 
           // We can skip this if we trust the returned message or WebSocket
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
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


  void _toggleVideoCall() {
    setState(() {
      _isVideoCallActive = !_isVideoCallActive;
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOff = !_isCameraOff;
    });
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patient['name'] ?? 'محمد أحمد';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          patientName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () {
            if (_isVideoCallActive) {
              _toggleVideoCall();
            } else {
              Navigator.pop(context);
            }
          },
          child: Text(
            _isVideoCallActive ? 'إنهاء' : 'رجوع',
            style: TextStyle(
              color: _isVideoCallActive ? Colors.red : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          if (_isVideoCallActive)
            IconButton(
              onPressed: () {
                // Show more options
                _showMoreOptions();
              },
              icon: const Icon(Icons.more_vert),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Video Call Area (when active)
                if (_isVideoCallActive)
                  Container(
                    height: 250,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Main Video (Patient) placeholder
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            color: _isCameraOff ? Colors.black87 : Colors.black12,
                            height: double.infinity,
                            width: double.infinity,
                            child: _isCameraOff
                                ? const Center(
                                    child: Icon(
                                      Icons.videocam_off,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                  )
                                : null,
                          ),
                        ),

                        // Doctor Mini View
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            width: 80,
                            height: 100,
                            decoration: BoxDecoration(
                              color: _isCameraOff ? Colors.black87 : Colors.black,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: _isCameraOff
                                ? const Center(
                                    child: Icon(
                                      Icons.videocam_off,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  )
                                : null,
                          ),
                        ),

                        // Call Status
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '00:15:42',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Call Controls
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildCallControl(
                                  _isCameraOff ? Icons.videocam : Icons.videocam_off,
                                  _isCameraOff
                                      ? Colors.grey.withOpacity(0.7)
                                      : Colors.blue,
                                  onTap: _toggleCamera,
                                ),
                                const SizedBox(width: 16),
                                _buildCallControl(
                                  Icons.call_end,
                                  Colors.red,
                                  size: 56,
                                  onTap: _toggleVideoCall,
                                ),
                                const SizedBox(width: 16),
                                _buildCallControl(
                                  _isMuted ? Icons.mic_off : Icons.mic,
                                  _isMuted
                                      ? Colors.grey.withOpacity(0.7)
                                      : Colors.blue,
                                  onTap: _toggleMute,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Video Call Toggle Button (when not in call)
                if (!_isVideoCallActive)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ElevatedButton.icon(
                      onPressed: _toggleVideoCall,
                      icon: const Icon(Icons.videocam),
                      label: const Text('بدء مكالمة فيديو'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),

                // Chat Area
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.senderId == _currentUser?.id;
                      return _buildMessageBubble(message, isMe);
                    },
                  ),
                ),

                // Quick Actions (only if not in video call)
                if (!_isVideoCallActive)
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildActionButton(
                          Icons.person,
                          'ملف المريض',
                          AppColors.secondary.withOpacity(0.1),
                          AppColors.secondary,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/patient-file',
                              arguments: widget.patient,
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          Icons.note_add,
                          'إضافة ملاحظة',
                          Colors.grey.shade100,
                          AppColors.textPrimary,
                          onTap: () => _showAddNoteDialog(),
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          Icons.medical_services,
                          'إرسال وصفة',
                          Colors.grey.shade100,
                          AppColors.textPrimary,
                          onTap: () => _showPrescriptionDialog(),
                        ),
                      ],
                    ),
                  ),

                // Message Input
                _buildMessageInput(),
              ],
            ),
    );
  }

  Widget _buildCallControl(
    IconData icon,
    Color color, {
    double size = 48,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
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
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message.sentAt),
              style: TextStyle(
                color: (isMe ? Colors.white : AppColors.textSecondary).withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
          IconButton(
            onPressed: () => _showAttachmentOptions(),
            icon: const Icon(Icons.attach_file, color: Colors.grey),
          ),
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

  Widget _buildActionButton(IconData icon, String label, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'خيارات إضافية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.screen_share),
              title: const Text('مشاركة الشاشة'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم بدء مشاركة الشاشة')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('تسجيل المكالمة'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم بدء تسجيل المكالمة')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog() {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة ملاحظة'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'اكتب ملاحظتك هنا...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (noteController.text.trim().isNotEmpty) {
                final text = '📝 ملاحظة: ${noteController.text.trim()}';
                Navigator.pop(context);
                
                setState(() => _isSending = true);
                final result = await _chatService.sendMessage(
                  roomId: _roomId,
                  text: text,
                  type: 'NOTE',
                );
                
                if (mounted) {
                  if (result['success']) {
                    await _loadMessages(silent: true);
                  }
                  setState(() => _isSending = false);
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showPrescriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إرسال وصفة طبية'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'اسم الدواء',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'الجرعة',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'عدد المرات يومياً',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = '💊 تم إرسال وصفة طبية جديدة';
              Navigator.pop(context);
              
              setState(() => _isSending = true);
              final result = await _chatService.sendMessage(
                roomId: _roomId,
                text: text,
              );
              
              if (mounted) {
                if (result['success']) {
                  await _loadMessages(silent: true);
                }
                setState(() => _isSending = false);
              }
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'إرفاق ملف',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                _sendAttachmentMessage('📷 تم إرسال صورة');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('اختيار من المعرض'),
              onTap: () {
                Navigator.pop(context);
                _sendAttachmentMessage('🖼️ تم إرسال صورة من المعرض');
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('إرسال ملف'),
              onTap: () {
                Navigator.pop(context);
                _sendAttachmentMessage('📄 تم إرسال ملف');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendAttachmentMessage(String text) async {
    setState(() => _isSending = true);
    final result = await _chatService.sendMessage(
      roomId: _roomId,
      text: text,
    );
    
    if (mounted) {
      if (result['success']) {
        await _loadMessages(silent: true);
      }
      setState(() => _isSending = false);
    }
  }
}
