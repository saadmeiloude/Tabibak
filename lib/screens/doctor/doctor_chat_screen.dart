import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class DoctorChatScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const DoctorChatScreen({super.key, required this.patient});

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isVideoCallActive = false;
  bool _isMuted = false;
  bool _isCameraOff = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'السلام عليكم يا دكتور، أشعر ببعض الأعراض منذ يومين.',
      'isMe': false,
      'timestamp': '10:30',
    },
    {
      'text': 'وعليكم السلام، أهلاً بك. صف لي الأعراض بالتفصيل.',
      'isMe': true,
      'timestamp': '10:31',
    },
    {
      'text': 'أشعر بصداع مستمر ودوخة خفيفة، خاصة في الصباح.',
      'isMe': false,
      'timestamp': '10:32',
    },
    {
      'text': 'ممتاز. هل تعاني من أي أعراض أخرى مثل الغثيان أو القيء؟',
      'isMe': true,
      'timestamp': '10:33',
    },
    {
      'text': 'نعم، أشعر بغثيان خفيف أحياناً.',
      'isMe': false,
      'timestamp': '10:34',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _messageController.text.trim(),
          'isMe': true,
          'timestamp': _getCurrentTime(),
        });
      });

      _messageController.clear();
      _scrollToBottom();

      // Simulate patient response after a delay
      _simulatePatientResponse();
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

  void _simulatePatientResponse() {
    Future.delayed(const Duration(seconds: 2), () {
      final responses = [
        'شكراً لك يا دكتور، هل تحتاج أي معلومات إضافية؟',
        'نعم، أتحسن الآن بعد أخذ الدواء.',
        'سأتبع نصيحتك وأراجعك الأسبوع القادم إن شاء الله.',
        'بارك الله فيك يا دكتور.',
      ];

      final randomResponse =
          responses[DateTime.now().millisecond % responses.length];

      setState(() {
        _messages.add({
          'text': randomResponse,
          'isMe': false,
          'timestamp': _getCurrentTime(),
        });
      });

      _scrollToBottom();
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
      body: Column(
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

          // Chat Area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Video Call Toggle Button (when not in call)
                  if (!_isVideoCallActive)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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

                  // Messages List
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageBubble(
                          message['text'],
                          isMe: message['isMe'],
                          timestamp: message['timestamp'],
                        );
                      },
                    ),
                  ),

                  // Action Buttons Bar
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => _showAttachmentOptions(),
                          icon: const Icon(
                            Icons.attach_file,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'اكتب رسالتك هنا...',
                              border: InputBorder.none,
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
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
                  ),
                ],
              ),
            ),
          ),
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

  Widget _buildMessageBubble(
    String message, {
    required bool isMe,
    required String timestamp,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : Radius.zero,
                      bottomRight: !isMe
                          ? const Radius.circular(16)
                          : Radius.zero,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timestamp,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
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
              style: TextStyle(
                color: iconColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
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
            onPressed: () {
              if (noteController.text.trim().isNotEmpty) {
                setState(() {
                  _messages.add({
                    'text': '📝 ملاحظة: ${noteController.text.trim()}',
                    'isMe': true,
                    'timestamp': _getCurrentTime(),
                  });
                });
                _scrollToBottom();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إضافة الملاحظة بنجاح')),
                );
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
            onPressed: () {
              setState(() {
                _messages.add({
                  'text': '💊 تم إرسال وصفة طبية جديدة',
                  'isMe': true,
                  'timestamp': _getCurrentTime(),
                });
              });
              _scrollToBottom();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إرسال الوصفة بنجاح')),
              );
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

  void _sendAttachmentMessage(String message) {
    setState(() {
      _messages.add({
        'text': message,
        'isMe': true,
        'timestamp': _getCurrentTime(),
      });
    });
    _scrollToBottom();
  }
}
