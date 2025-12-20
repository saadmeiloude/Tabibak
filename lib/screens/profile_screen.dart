import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../core/constants/colors.dart';
import '../widgets/custom_button.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import '../core/localization/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  String? _profileImagePath;
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    final settings = DataService.getNotificationSettings();

    if (user != null) {
      if (mounted) {
        setState(() {
          _userName = user.fullName;
          _userEmail = user.email;
          _userPhone = user.phone ?? '';
          _profileImagePath = user.profileImage;

          _notificationsEnabled = settings['notifications']!;
          _emailNotifications = settings['email']!;
          _smsNotifications = settings['sms']!;

          _nameController.text = _userName;
          _emailController.text = _userEmail;
          _phoneController.text = _userPhone;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.profile ?? 'الملف الشخصي'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _showEditProfileDialog();
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Info Card
            Container(
              padding: const EdgeInsets.all(24),
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
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.amber.shade100,
                        backgroundImage: _profileImagePath != null
                            ? (_profileImagePath!.startsWith('http') ||
                                      _profileImagePath!.startsWith('uploads/')
                                  ? NetworkImage(
                                          _profileImagePath!.startsWith('http')
                                              ? _profileImagePath!
                                              : '${ApiService.baseUrl}/$_profileImagePath',
                                        )
                                        as ImageProvider
                                  : FileImage(File(_profileImagePath!)))
                            : null,
                        child: _profileImagePath == null
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.amber.shade700,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: InkWell(
                          onTap: () {
                            _showImagePickerDialog();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userEmail,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      _showEditProfileDialog();
                    },
                    child: const Text(
                      'تعديل الملف الشخصي',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Medical Records Section
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                appLocalizations?.medicalRecords ?? 'سجلاتي الصحية',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
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
              child: ListTile(
                leading: const Icon(
                  Icons.upload_file,
                  color: AppColors.textSecondary,
                ),
                title: Text(
                  appLocalizations?.uploadMedicalReportsAction ??
                      'رفع تقارير طبية',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showUploadMedicalRecords();
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
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
              child: ListTile(
                leading: const Icon(
                  Icons.history,
                  color: AppColors.textSecondary,
                ),
                title: Text(
                  appLocalizations?.medicalRecordsHistory ??
                      'تاريخ السجلات الطبية',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showMedicalRecordsHistory();
                },
              ),
            ),
            const SizedBox(height: 24),

            // Options List
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                appLocalizations?.settings ?? 'الإعدادات',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
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
                  _buildListTile(
                    context,
                    Icons.person_outline,
                    appLocalizations?.myAccount ?? 'حسابي',
                    () => _showEditProfileDialog(),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    context,
                    Icons.shopping_bag_outlined,
                    appLocalizations?.myOrders ?? 'طلباتي',
                    () => _showMyOrders(),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(
                      appLocalizations?.notificationSettings ?? 'الإشعارات',
                    ),
                    value: _notificationsEnabled,
                    onChanged: (value) async {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      await DataService.saveNotificationSettings(
                        notifications: _notificationsEnabled,
                        emailNotifications: _emailNotifications,
                        smsNotifications: _smsNotifications,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'الإشعارات ${value ? "مفعلة" : "ملغية"}',
                          ),
                        ),
                      );
                    },
                    secondary: const Icon(Icons.notifications_none_outlined),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(
                      appLocalizations?.emailNotifications ??
                          'إشعارات البريد الإلكتروني',
                    ),
                    value: _emailNotifications,
                    onChanged: (value) async {
                      setState(() {
                        _emailNotifications = value;
                      });
                      await DataService.saveNotificationSettings(
                        notifications: _notificationsEnabled,
                        emailNotifications: _emailNotifications,
                        smsNotifications: _smsNotifications,
                      );
                    },
                    secondary: const Icon(Icons.email_outlined),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(
                      appLocalizations?.smsNotifications ??
                          'إشعارات الرسائل النصية',
                    ),
                    value: _smsNotifications,
                    onChanged: (value) async {
                      setState(() {
                        _smsNotifications = value;
                      });
                      await DataService.saveNotificationSettings(
                        notifications: _notificationsEnabled,
                        emailNotifications: _emailNotifications,
                        smsNotifications: _smsNotifications,
                      );
                    },
                    secondary: const Icon(Icons.sms_outlined),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    context,
                    Icons.credit_card_outlined,
                    appLocalizations?.myCards ?? 'بطاقاتي',
                    () => _showMyCards(),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    context,
                    Icons.help_outline,
                    appLocalizations?.help ?? 'المساعدة والدعم',
                    () => _showHelpDialog(),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    context,
                    Icons.info_outline,
                    appLocalizations?.about ?? 'حول التطبيق',
                    () => _showAboutDialog(),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    context,
                    Icons.settings_outlined,
                    appLocalizations?.settings ?? 'الإعدادات',
                    () => _showSettingsDialog(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            CustomButton(
              text: AppLocalizations.of(context)?.logout ?? 'تسجيل الخروج',
              onPressed: () {
                _showLogoutDialog();
              },
              backgroundColor: Colors.red,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog() {
    _nameController.text = _userName;
    _emailController.text = _userEmail;
    _phoneController.text = _userPhone;

    var loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc?.editProfileTitle ?? 'تعديل الملف الشخصي'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: loc?.fullName ?? 'الاسم الكامل',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: loc?.email ?? 'البريد الإلكتروني',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: loc?.phone ?? 'رقم الهاتف',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(loc?.cancel ?? 'إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = _nameController.text;
                final newEmail = _emailController.text;
                final newPhone = _phoneController.text;

                final result = await DataService.saveUserProfile(
                  name: newName,
                  email: newEmail,
                  phone: newPhone,
                );

                if (mounted) {
                  if (result['success']) {
                    setState(() {
                      _userName = newName;
                      _userEmail = newEmail;
                      _userPhone = newPhone;
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          loc?.saveChangesSuccess ?? 'تم حفظ التغييرات بنجاح',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'فشل حفظ التغييرات'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(loc?.save ?? 'حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _showImagePickerDialog() {
    var loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc?.pickProfileImage ?? 'اختر صورة الملف الشخصي',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(loc?.takePhoto ?? 'التقاط صورة'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickProfileImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(loc?.pickFromGallery ?? 'اختيار من المعرض'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickProfileImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        // Show loading or optimistic update
        setState(() {
          // On web, we can't easily use FileImage, so we wait for the server path
          // or use a temporary blob URL.
          if (!kIsWeb) {
            _profileImagePath = image.path;
          }
        });

        Map<String, dynamic> result;
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          result = await DataService.saveProfileImage(
            null,
            bytes: bytes,
            fileName: image.name,
          );
        } else {
          result = await DataService.saveProfileImage(image.path);
        }

        if (result['success'] == true) {
          final newPath = result['data']['profile_image'];

          // Update local user in AuthService so it persists
          final currentUser = await AuthService.getCurrentUser();
          if (currentUser != null) {
            final updatedUser = User(
              id: currentUser.id,
              fullName: currentUser.fullName,
              email: currentUser.email,
              phone: currentUser.phone,
              userType: currentUser.userType,
              verificationMethod: currentUser.verificationMethod,
              isVerified: currentUser.isVerified,
              createdAt: currentUser.createdAt,
              profileImage: newPath, // Update the path
              dateOfBirth: currentUser.dateOfBirth,
              gender: currentUser.gender,
              address: currentUser.address,
              emergencyContact: currentUser.emergencyContact,
            );
            await AuthService.storeUser(updatedUser);
          }

          if (mounted) {
            setState(() {
              _profileImagePath = newPath;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث صورة الملف الشخصي بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'فشل تحديث الصورة'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)?.error}: $e')),
        );
      }
    }
  }

  void _showUploadMedicalRecords() {
    var loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc?.uploadMedicalReports ?? 'رفع التقارير الطبية',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: Text(loc?.uploadNewFile ?? 'رفع ملف جديد'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickMedicalFile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(loc?.takePhoto ?? 'التقاط صورة'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickReportImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickMedicalFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        final platformFile = result.files.single;
        Map<String, dynamic> apiResult;

        if (kIsWeb) {
          apiResult = await DataService.saveMedicalRecord(
            platformFile.name,
            null,
            bytes: platformFile.bytes,
          );
        } else {
          apiResult = await DataService.saveMedicalRecord(
            platformFile.name,
            platformFile.path!,
          );
        }

        if (mounted) {
          if (apiResult['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppLocalizations.of(context)?.fileUploaded}: ${platformFile.name}',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(apiResult['message'] ?? 'فشل رفع الملف'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)?.error}: $e')),
        );
      }
    }
  }

  Future<void> _pickReportImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        Map<String, dynamic> apiResult;
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          apiResult = await DataService.saveMedicalRecord(
            image.name,
            null,
            bytes: bytes,
          );
        } else {
          apiResult = await DataService.saveMedicalRecord(
            image.name,
            image.path,
          );
        }

        if (mounted) {
          if (apiResult['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppLocalizations.of(context)?.fileUploaded}: ${image.name}',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(apiResult['message'] ?? 'فشل رفع الصورة'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)?.error}: $e')),
        );
      }
    }
  }

  void _showMedicalRecordsHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('السجلات الطبية'),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<MedicalRecord>>(
              future: DataService.getMedicalRecords(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('خطأ: ${snapshot.error}');
                }

                final records = snapshot.data ?? [];

                if (records.isEmpty) {
                  return const Text('لا توجد سجلات طبية');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return ListTile(
                      leading: const Icon(Icons.description),
                      title: Text(record.title),
                      subtitle: Text(
                        record.recordDate.toIso8601String().split('T')[0],
                      ),
                      onTap: () {
                        // In a real app, you'd open the file
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('فتح: ${record.title}')),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  void _showMyOrders() {
    Navigator.pushNamed(context, '/orders');
  }

  void _showMyCards() {
    Navigator.pushNamed(context, '/cards');
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('المساعدة والدعم'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'كيف يمكننا مساعدتك؟',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text('• حجز المواعيد'),
                Text('• إدارة الاستشارات'),
                Text('• الدعم التقني'),
                Text('• الفوترة والدفع'),
                SizedBox(height: 16),
                Text(
                  'للتواصل معنا:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('الهاتف: 800-123-4567'),
                Text('البريد: support@tabibek.com'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إغلاق'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // In a real app, you'd open email app
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فتح تطبيق البريد...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('إرسال رسالة'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حول التطبيق'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تطبيبي',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('الإصدار 1.0.0'),
                SizedBox(height: 16),
                Text(
                  'تطبيق طبي متكامل لحجز المواعيد والاستشارات الطبية مع أفضل الأطباء.',
                ),
                SizedBox(height: 16),
                Text('الميزات:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• حجز المواعيد'),
                Text('• الاستشارات الطبية'),
                Text('• إدارة السجلات الطبية'),
                Text('• نظام دفع آمن'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<LanguageService>(
          builder: (context, languageService, child) {
            final appLocalizations = AppLocalizations.of(context);
            return AlertDialog(
              title: Text(appLocalizations?.settings ?? 'الإعدادات'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(appLocalizations?.language ?? 'اللغة'),
                      subtitle: Text(languageService.currentLanguageName),
                      trailing: DropdownButton<Locale>(
                        value: languageService.currentLocale,
                        underline: const SizedBox(),
                        onChanged: (Locale? newLocale) {
                          if (newLocale != null) {
                            languageService.changeLanguage(newLocale);
                          }
                        },
                        items: LanguageService.supportedLocales.map((
                          Locale locale,
                        ) {
                          return DropdownMenuItem<Locale>(
                            value: locale,
                            child: Text(
                              languageService.getLanguageName(
                                locale.languageCode,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(appLocalizations?.close ?? 'إغلاق'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)?.logoutConfirmationTitle ??
                'تسجيل الخروج',
          ),
          content: Text(
            AppLocalizations.of(context)?.logoutConfirmation ??
                'هل أنت متأكد من تسجيل الخروج؟',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.cancel ?? 'إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthService.logout();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                AppLocalizations.of(context)?.logout ?? 'تسجيل الخروج',
              ),
            ),
          ],
        );
      },
    );
  }
}
