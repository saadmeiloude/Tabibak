import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../../core/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';

class DoctorSettingsScreen extends StatefulWidget {
  const DoctorSettingsScreen({super.key});

  @override
  State<DoctorSettingsScreen> createState() => _DoctorSettingsScreenState();
}

class _DoctorSettingsScreenState extends State<DoctorSettingsScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _doctorData;

  // Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _feesController = TextEditingController();
  final _educationController = TextEditingController();
  final _certificationsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final result = await DataService.getDoctorProfile();
      if (result['success']) {
        final data = result['data'];
        setState(() {
          _doctorData = data;
          _fullNameController.text = data['full_name'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _addressController.text = data['address'] ?? '';
          _specializationController.text = data['specialization'] ?? '';
          _experienceController.text = (data['experience_years'] ?? '0')
              .toString();
          _feesController.text = (data['consultation_fee'] ?? '0').toString();
          _educationController.text = data['education'] ?? '';
          _certificationsController.text = data['certifications'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final data = {
        'full_name': _fullNameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'specialization': _specializationController.text,
        'experience_years': _experienceController.text,
        'consultation_fee': _feesController.text,
        'education': _educationController.text,
        'certifications': _certificationsController.text,
      };

      final result = await DataService.updateDoctorProfile(data);

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.saveChangesSuccess ??
                    'تم حفظ التغييرات بنجاح',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to update'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc?.profile ?? 'الملف الشخصي'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Language Switcher
          Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return PopupMenuButton<Locale>(
                icon: const Icon(Icons.language, color: AppColors.primary),
                onSelected: (Locale locale) {
                  languageService.changeLanguage(locale);
                },
                itemBuilder: (BuildContext context) =>
                    LanguageService.supportedLocales.map((Locale locale) {
                      return PopupMenuItem<Locale>(
                        value: locale,
                        child: Text(
                          locale.languageCode == 'ar' ? 'العربية' : 'Français',
                        ),
                      );
                    }).toList(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Image Placeholder
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _doctorData?['profile_image'] != null
                        ? NetworkImage(
                            '${ApiService.baseUrl}/${_doctorData!['profile_image']}',
                          )
                        : null,
                    child: _doctorData?['profile_image'] == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );

                        if (image != null) {
                          Map<String, dynamic> result;
                          if (kIsWeb) {
                            final bytes = await image.readAsBytes();
                            result = await DataService.saveProfileImage(
                              null,
                              bytes: bytes,
                              fileName: image.name,
                            );
                          } else {
                            result = await DataService.saveProfileImage(
                              image.path,
                            );
                          }

                          if (result['success']) {
                            // Update local user in AuthService so it persists
                            final currentUser =
                                await AuthService.getCurrentUser();
                            if (currentUser != null) {
                              final updatedUser = User(
                                id: currentUser.id,
                                fullName: currentUser.fullName,
                                email: currentUser.email,
                                phone: currentUser.phone,
                                userType: currentUser.userType,
                                verificationMethod:
                                    currentUser.verificationMethod,
                                isVerified: currentUser.isVerified,
                                createdAt: currentUser.createdAt,
                                profileImage: result['data']['profile_image'],
                                dateOfBirth: currentUser.dateOfBirth,
                                gender: currentUser.gender,
                                address: currentUser.address,
                                emergencyContact: currentUser.emergencyContact,
                              );
                              await AuthService.storeUser(updatedUser);
                            }

                            await _loadProfile(); // Refresh profile to show new image
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم تحديث الصورة بنجاح'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result['message'] ?? 'فشل تحديث الصورة',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
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
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(
              context,
              loc?.personalInfo ?? 'المعلومات الشخصية',
            ),
            CustomTextField(
              hintText: loc?.fullName ?? 'الاسم',
              controller: _fullNameController,
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              hintText: loc?.phone ?? 'الهاتف',
              controller: _phoneController,
              prefixIcon: Icons.phone,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              hintText: loc?.address ?? 'العنوان',
              controller: _addressController,
              prefixIcon: Icons.location_on,
            ),

            const SizedBox(height: 24),
            _buildSectionHeader(
              context,
              loc?.professionalInfo ?? 'المعلومات المهنية',
            ),
            CustomTextField(
              hintText: loc?.specialty ?? 'التخصص',
              controller: _specializationController,
              prefixIcon: Icons.work,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hintText: loc?.experience ?? 'الخبرة (سنوات)',
                    controller: _experienceController,
                    prefixIcon: Icons.timeline,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    hintText: loc?.consultationFeeHint ?? 'سعر الكشف',
                    controller: _feesController,
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            CustomTextField(
              hintText: loc?.educationQualifications ?? 'التعليم / المؤهلات',
              controller: _educationController,
              prefixIcon: Icons.school,
            ),

            const SizedBox(height: 12),
            CustomTextField(
              hintText: loc?.certificates ?? 'الشهادات',
              controller: _certificationsController,
              prefixIcon: Icons.card_membership,
            ),

            const SizedBox(height: 32),
            CustomButton(
              text: _isSaving
                  ? (loc?.loading ?? 'جاري الحفظ...')
                  : (loc?.saveChanges ?? 'حفظ التغييرات'),
              onPressed: _isSaving ? null : _saveProfile,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    var loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc?.logout ?? 'تسجيل الخروج'),
        content: Text(
          loc?.logoutConfirmation ?? 'هل أنت متأكد من تسجيل الخروج؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc?.cancel ?? 'إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _logout();
            },
            child: Text(
              loc?.logout ?? 'خروج',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
