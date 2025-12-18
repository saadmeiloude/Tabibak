import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/data_service.dart';

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

  @override
  Widget build(BuildContext context) {
    // Fallback to widget.patient if full data not loaded yet
    final patientName =
        _fullPatientData?['full_name'] ??
        widget.patient['full_name'] ??
        widget.patient['name'] ??
        'Unknown';
    final phone =
        _fullPatientData?['phone'] ?? widget.patient['phone'] ?? 'N/A';
    final email = _fullPatientData?['email'] ?? 'N/A';

    // Calculate age if DOB exists
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
                // Patient Info
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

                // Tabs
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
        onPressed: () {
          // Here user can add visit/record (Link logic)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يمكنك إضافة سجل جديد لربط المريض')),
          );
        },
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
    // Using same or similar item builder
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
            doctor: report['doctor_name'],
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
            doctor: item['doctor_name'],
            medications:
                item['medications'] ??
                '', // Assuming string or JSON string, simplified for now
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
      ),
      child: ListTile(
        leading: const Icon(Icons.analytics, color: Colors.blue),
        title: Text(title),
        subtitle: Text('$type - $doctor\n$date'),
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
      ),
      child: ListTile(
        leading: const Icon(Icons.medication, color: Colors.red),
        title: Text(diagnosis),
        subtitle: Text('$doctor - $date\n$medications'),
      ),
    );
  }
}
