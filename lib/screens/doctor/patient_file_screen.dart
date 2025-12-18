import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';

import '../../widgets/custom_text_field.dart';

class PatientFileScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientFileScreen({super.key, required this.patient});

  @override
  State<PatientFileScreen> createState() => _PatientFileScreenState();
}

class _PatientFileScreenState extends State<PatientFileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _fullPatientData;
  List<dynamic> _visits = [];
  List<dynamic> _reports = [];
  List<dynamic> _prescriptions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPatientDetails();
  }

  Future<void> _loadPatientDetails() async {
    final patientId = widget.patient['id'] ?? widget.patient['patient_id'];
    if (patientId == null) return;

    final result = await DataService.getPatientDetails(
      int.parse(patientId.toString()),
    );

    if (mounted) {
      if (result['success']) {
        final data = result['data'];
        setState(() {
          _fullPatientData = data['patient'];
          _visits = data['visits'] ?? [];
          _reports = data['reports'] ?? [];
          _prescriptions = data['prescriptions'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to load details'),
          ),
        );
      }
    }
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'إضافة سجل جديد',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.medication, color: Colors.blue),
                title: const Text('وصفة طبية'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddRecordDialog('prescription', 'إضافة وصفة طبية');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.orange,
                ),
                title: const Text('تقرير / تشخيص'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddRecordDialog('diagnosis', 'إضافة تقرير طبي');
                },
              ),
              // Optional: Add Visit note as a generic record or different type
              // ListTile(
              //   leading:
              //       const Icon(Icons.calendar_today, color: Colors.teal),
              //   title: const Text('تسجيل زيارة (ملاحظة)'),
              //   onTap: () {
              //     Navigator.pop(context);
              //     _showAddRecordDialog(
              //       'consultation',
              //       'تسجيل ملاحظة زيارة',
              //     );
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }

  void _showAddRecordDialog(String type, String title) {
    final titleController = TextEditingController(
      text: type == 'prescription' ? 'وصفة طبية' : '',
    );
    final descriptionController = TextEditingController();
    final medicationsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // For Prescriptions, we usually want Diagnosis + Meds
                  // For Reports, Title + Description
                  if (type != 'prescription')
                    CustomTextField(
                      hintText: 'العنوان (مثال: تحليل دم، فحص دوري)',
                      controller: titleController,
                      prefixIcon: Icons.title,
                    ),

                  const SizedBox(height: 12),

                  if (type == 'prescription') ...[
                    CustomTextField(
                      hintText: 'التشخيص',
                      controller:
                          titleController, // Reuse title as diagnosis title if needed, or separate
                      // Actually, prescription schema has 'diagnosis' field.
                      // title field is required. Let's send "Prescription" as title and use this for Diagnosis.
                      prefixIcon: Icons.medical_services,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hintText: 'الأدوية (اسم الدواء - الجرعة)',
                      controller: medicationsController,
                      prefixIcon: Icons.medication_liquid,
                      keyboardType: TextInputType.multiline,
                    ),
                  ] else ...[
                    CustomTextField(
                      hintText: 'التفاصيل / الملاحظات',
                      controller: descriptionController,
                      prefixIcon: Icons.description,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final docTitle = type == 'prescription'
                    ? 'الوصفة الطبية'
                    : titleController.text;
                // If prescription, we use titleController for diagnosis or just general title?
                // Let's use titleController text as the 'diagnosis' or 'title'.
                // Backend requires 'title'.
                // If prescription, title = "Prescription" usually, and diagnosis is separate.

                _submitRecord(
                  type,
                  docTitle.isEmpty ? 'سجل طبي' : docTitle,
                  descriptionController.text,
                  titleController
                      .text, // Sending diagnosis here if prescription
                  medicationsController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRecord(
    String type,
    String title,
    String description,
    String diagnosis,
    String? medications,
  ) async {
    // Capture context before async gap
    final capturedContext = context;
    Navigator.pop(capturedContext); // Close dialog
    setState(() => _isLoading = true);

    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) throw Exception('User not logged in');

      final patientId = widget.patient['id'] ?? widget.patient['patient_id'];

      // Adjust fields based on type
      String finalTitle = title;
      String? finalDiagnosis = diagnosis;
      String? finalDescription = description;

      if (type == 'prescription') {
        finalTitle = 'وصفة طبية';
        finalDiagnosis = diagnosis; // User typed diagnosis in title field
        finalDescription = null;
      }

      final result = await DataService.createMedicalRecord(
        doctorId: user.id,
        patientId: int.parse(patientId.toString()),
        recordType: type,
        title: finalTitle,
        description: finalDescription,
        diagnosis: finalDiagnosis,
        medications: medications,
      );

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(
            capturedContext,
          ).showSnackBar(const SnackBar(content: Text('تمت الإضافة بنجاح')));
          _loadPatientDetails(); // Refresh
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(capturedContext).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'فشل الحفظ')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          capturedContext,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientName =
        _fullPatientData?['full_name'] ??
        widget.patient['full_name'] ??
        widget.patient['name'] ??
        'Unknown';
    final phone =
        _fullPatientData?['phone'] ?? widget.patient['phone'] ?? 'N/A';
    final email = _fullPatientData?['email'] ?? 'N/A';

    String ageStr = 'غير محدد';
    if (_fullPatientData?['date_of_birth'] != null) {
      try {
        final dob = DateTime.parse(_fullPatientData!['date_of_birth']);
        final age = DateTime.now().year - dob.year;
        ageStr = '$age';
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ملف المريض'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.orange.shade100,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.orange.shade400,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patientName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'العمر: $ageStr, الهاتف: $phone',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'البريد: $email',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'الزيارات السابقة'),
                    Tab(text: 'التقارير والتحاليل'),
                    Tab(text: 'الوصفات الطبية'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVisitsList(),
                      _buildReportsList(),
                      _buildPrescriptionsList(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        heroTag: "patient_file_fab",
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVisitsList() {
    if (_visits.isEmpty)
      return const Center(child: Text('لا توجد زيارات سابقة'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _visits.length,
      itemBuilder: (context, index) {
        final visit = _visits[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildVisitItem(
            title: visit['consultation_type'] ?? 'زيارة',
            description: visit['notes'] ?? 'لا توجد ملاحظات',
            date: visit['appointment_date'] ?? '',
            doctor: visit['doctor_name'] ?? '',
          ),
        );
      },
    );
  }

  Widget _buildVisitItem({
    required String title,
    required String description,
    required String date,
    required String doctor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$doctor\n$description',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    if (_reports.isEmpty) return const Center(child: Text('لا توجد تقارير'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildReportItem(
            title: report['title'],
            type: report['record_type'],
            date: report['record_date'],
            doctor: report['doctor_name'] ?? 'طبيبي',
            status: 'مكتمل',
          ),
        );
      },
    );
  }

  Widget _buildPrescriptionsList() {
    if (_prescriptions.isEmpty)
      return const Center(child: Text('لا توجد وصفات'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _prescriptions.length,
      itemBuilder: (context, index) {
        final item = _prescriptions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPrescriptionItem(
            diagnosis: item['diagnosis'] ?? item['title'],
            date: item['record_date'],
            doctor: item['doctor_name'] ?? 'طبيبي',
            medications: item['medications'] ?? '',
          ),
        );
      },
    );
  }

  Widget _buildReportItem({
    required String title,
    required String type,
    required String date,
    required String doctor,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.analytics, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('نوع: $type\nد. $doctor | $date'),
        trailing: Text(status, style: const TextStyle(color: Colors.green)),
      ),
    );
  }

  Widget _buildPrescriptionItem({
    required String diagnosis,
    required String date,
    required String doctor,
    required String medications,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.medication, color: Colors.red),
        title: Text(
          diagnosis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('د. $doctor | $date\n$medications'),
      ),
    );
  }
}
