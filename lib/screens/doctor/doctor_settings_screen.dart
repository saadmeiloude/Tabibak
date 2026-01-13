import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/config/api_config.dart';
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
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      // Fetch both User and Doctor data to ensure we have complete info
      final user = await AuthService.getCurrentUser();
      if (user == null) return; // Should not happen if logged in

      final result = await DataService.getDoctorProfile();
      
      final Map<String, dynamic> data = (result['success'] && result['data'] != null) 
          ? result['data'] 
          : {};
      
      if (mounted) {
        setState(() {
          _doctorData = data;
          
          // Name: Doctor Profile -> User Profile -> Empty
          final name = data['name'] ?? data['full_name'] ?? data['fullName'];
          _fullNameController.text = (name != null && name.toString().isNotEmpty) 
              ? name.toString() 
              : user.fullName;

          // Phone: Doctor Profile -> User Profile -> Empty
          final phone = data['phone'];
          _phoneController.text = (phone != null && phone.toString().isNotEmpty) 
              ? phone.toString() 
              : (user.phone ?? '');

          // Address: Doctor Clinic Address -> User Address -> Empty
          final address = data['clinic_address'] ?? data['clinicAddress'] ?? data['address'];
          _addressController.text = (address != null && address.toString().isNotEmpty) 
              ? address.toString() 
              : (user.address ?? '');

          // Specialization
          _specializationController.text = (data['specialty'] ?? data['specialization'] ?? '').toString();

          // Experience
          _experienceController.text = (data['experience_years'] ?? data['experienceYears'] ?? '0').toString();

          // Fees
          _feesController.text = (data['consultation_fee'] ?? data['consultationFee'] ?? '0').toString();

          // Education & Certifications
          _educationController.text = (data['education'] ?? '').toString();
          _certificationsController.text = (data['certifications'] ?? '').toString();
          _bioController.text = (data['bio'] ?? '').toString();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final trimmedName = _fullNameController.text.trim();
      final nameParts = trimmedName.split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Prepare data using keys that DataService expects (mostly camelCase or snake_case handled by service)
      final data = {
        'id': _doctorData?['id'],
        'userId': _doctorData?['userId'] ?? _doctorData?['user_id'],
        'name': trimmedName,
        'firstName': firstName,
        'lastName': lastName,
        'phone': _phoneController.text.trim(),
        'clinicAddress': _addressController.text.trim(),
        'specialty': _specializationController.text.trim(),
        'experienceYears': int.tryParse(_experienceController.text.trim()) ?? 0,
        'consultationFee': double.tryParse(_feesController.text.trim()) ?? 0.0,
        'education': _educationController.text.trim(),
        'certifications': _certificationsController.text.trim(),
        'bio': _bioController.text.trim(),
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
                    backgroundImage: _doctorData?['profile_image'] != null && _doctorData!['profile_image'].toString().isNotEmpty
                        ? NetworkImage(
                            _doctorData!['profile_image'].toString().startsWith('http')
                                ? _doctorData!['profile_image'].toString()
                                : '${ApiConfig.baseUrl}/${_doctorData!['profile_image'].toString().startsWith('/') ? _doctorData!['profile_image'].toString().substring(1) : _doctorData!['profile_image']}',
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
                        final messenger = ScaffoldMessenger.of(context);
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
                              final nameParts = currentUser.fullName.split(' ');
                              final updatedUser = User(
                                id: currentUser.id,
                                firstName: nameParts.isNotEmpty ? nameParts.first : '',
                                lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
                                email: currentUser.email,
                                phone: currentUser.phone,
                                role: currentUser.role,
                                verificationMethod: currentUser.verificationMethod,
                                isVerified: currentUser.isVerified,
                                isActive: currentUser.isActive,
                                createdAt: currentUser.createdAt,
                                updatedAt: currentUser.updatedAt,
                                avatarUrl: result['data']['profile_image'],
                                dateOfBirth: currentUser.dateOfBirth,
                                gender: currentUser.gender,
                                address: currentUser.address,
                                emergencyContact: currentUser.emergencyContact,
                              );
                              await AuthService.storeUser(updatedUser);
                            }

                            await _loadProfile(); // Refresh profile to show new image
                            if (!mounted) return;
                            
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('تم تحديث الصورة بنجاح'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            if (!mounted) return;
                            
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ?? 'فشل تحديث الصورة',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
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
            const SizedBox(height: 12),
            CustomTextField(
              hintText: loc?.about ?? 'نبذة شخصية',
              controller: _bioController,
              prefixIcon: Icons.info_outline,
              keyboardType: TextInputType.multiline,
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
