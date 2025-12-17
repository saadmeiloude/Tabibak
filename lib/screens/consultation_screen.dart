import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../core/constants/colors.dart';
import '../core/constants/mauritanian_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';

// ... other imports ...

class ConsultationScreen extends StatefulWidget {
  final Map<String, dynamic>? doctor;

  const ConsultationScreen({super.key, this.doctor});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  String _consultationType = 'video'; // 'video' or 'text'
  String _paymentMethod = 'credit_card'; // 'credit_card', 'mada', etc.
  List<XFile> _selectedImages = [];
  List<File> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      if (mounted) {
        setState(() {
          _nameController.text = user.fullName;
          _emailController.text = user.email;
          _phoneController.text = user.phone ?? '';
        });
      }
    }
  }

  // ... rest of the code ...

  void _processConsultation() {
    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Call API to create appointment
    // Assume doctor ID is in widget.doctor['id'], default to 1 if testing
    final int doctorId = widget.doctor?['id'] is int
        ? widget.doctor!['id']
        : int.tryParse(widget.doctor?['id'].toString() ?? '1') ?? 1;

    // Use current time + some buffer or selected time?
    // The screen doesn't seem to have date picker, it assumes "Start Consultation".
    // Let's assume it's an immediate booking (now).
    final now = DateTime.now();

    DataService.createAppointment(
      doctorId: doctorId,
      appointmentDate: now,
      appointmentTime: now,
      symptoms: _messageController.text,
      consultationType:
          'online', // Both video and text are online consultations
      durationMinutes: 30, // Default duration
    ).then((result) {
      Navigator.pop(context); // Close progress dialog

      if (result['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _consultationType == 'video'
                  ? 'تم تأكيد الاستشارة المرئية بنجاح!'
                  : 'تم تأكيد الاستشارة النصية بنجاح!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to home or appointments
        Navigator.pop(context);
        // Or specific route: Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'فشل حجز الاستشارة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use passed doctor data or defaults
    final doctorName = widget.doctor?['name'] ?? 'د. فاطمة الزهراء';
    final doctorSpecialty = widget.doctor?['specialty'] ?? 'طبيبة عامة';
    final doctorRating = widget.doctor?['rating'] ?? 4.8;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الاستشارة الطبية'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Handle profile
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Doctor Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            doctorSpecialty,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '$doctorRating',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Consultation Type
              const Text(
                'نوع الاستشارة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTypeOption(
                        label: 'مرئية (Zoom)',
                        icon: Icons.videocam,
                        value: 'video',
                      ),
                    ),
                    Expanded(
                      child: _buildTypeOption(
                        label: 'نصية',
                        icon: Icons.chat,
                        value: 'text',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields
              const Text(
                'الاسم الكامل',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: 'الاسم الكامل',
                controller: _nameController,
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الاسم الكامل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                hintText: 'البريد الإلكتروني',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'يرجى إدخال بريد إلكتروني صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                hintText: 'رقم الهاتف',
                controller: _phoneController,
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Message / Symptoms
              const Text(
                'الرسالة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'اشرح الأعراض التي تشعر بها...',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال وصف للأعراض';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Medical Attachments
              const Text(
                'المرفقات الطبية',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildAttachmentBox(
                      icon: Icons.upload_file,
                      label: 'رفع ملفات أو صور',
                      onTap: () {
                        _showUploadOptions(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Display selected images
                  ..._selectedImages.take(2).map((image) {
                    return Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(image.path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.remove(image);
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (_selectedImages.isEmpty) ...[
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.description, color: Colors.grey),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Payment Details
              const Text(
                'تفاصيل الدفع',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('سعر الاستشارة:'),
                        Text(
                          MauritanianConstants.formatPrice(
                            _consultationType == 'video'
                                ? MauritanianConstants.consultationPriceVideo
                                : MauritanianConstants.consultationPriceOnline,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _consultationType == 'video'
                                ? Colors.green
                                : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    if (_consultationType == 'video') ...[
                      const SizedBox(height: 8),
                      Text(
                        'استشارة مرئية عبر Zoom',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Text(
                        'استشارة نصية',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                    const Divider(height: 24),
                    InkWell(
                      onTap: () {
                        _showPaymentMethods(context);
                      },
                      child: Row(
                        children: [
                          const Text('طريقة الدفع'),
                          const Spacer(),
                          Icon(
                            _getPaymentMethodIcon(_paymentMethod),
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Start Button
              CustomButton(
                text: _consultationType == 'video'
                    ? 'ابدأ الاستشارة المرئية ودفع ${MauritanianConstants.formatPrice(MauritanianConstants.consultationPriceVideo)}'
                    : 'ابدأ الاستشارة النصية ودفع ${MauritanianConstants.formatPrice(MauritanianConstants.consultationPriceOnline)}',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _processConsultation();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required String label,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _consultationType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _consultationType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.primary) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentBox({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'رفع المرفقات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('التقاط صورة'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('اختيار من المعرض'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('اختيار ملف'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إضافة الصورة: ${image.name}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في اختيار الصورة: $e')));
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        setState(() {
          _selectedFiles.add(file);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إضافة الملف: ${result.files.single.name}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في اختيار الملف: $e')));
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'credit_card':
        return Icons.credit_card;
      case 'mada':
        return Icons.payment;
      case 'wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.credit_card;
    }
  }

  void _showPaymentMethods(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر طريقة الدفع',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('بطاقة ائتمانية'),
                trailing: Radio<String>(
                  value: 'credit_card',
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('مدى'),
                trailing: Radio<String>(
                  value: 'mada',
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('محفظة إلكترونية'),
                trailing: Radio<String>(
                  value: 'wallet',
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
