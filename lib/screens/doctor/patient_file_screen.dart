import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class PatientFileScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientFileScreen({super.key, required this.patient});

  @override
  State<PatientFileScreen> createState() => _PatientFileScreenState();
}

class _PatientFileScreenState extends State<PatientFileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patient['name'] ?? 'سارة عبدالله الأحمد';

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
      body: Column(
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
                      const Text(
                        'العمر: 34, الجنس: أنثى, فصيلة الدم: O+',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'الحساسية: البنسلين',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
                // Previous Visits
                _buildVisitsList(),
                // Reports
                _buildReportsList(),
                // Prescriptions
                _buildPrescriptionsList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show visit creation dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('إضافة زيارة جديدة'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'نوع الزيارة',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'الشكوى الرئيسية',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'التشخيص',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
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
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إضافة الزيارة بنجاح')),
                    );
                  },
                  child: const Text('إضافة'),
                ),
              ],
            ),
          );
        },
        heroTag: "patient_file_fab",
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVisitsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search
        TextField(
          decoration: InputDecoration(
            hintText: 'بحث في الزيارات',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Visit Items
        _buildVisitItem(
          title: 'فحص روتيني',
          description: 'الشكوى الرئيسية: صداع مستمر\nد. أحمد محمود - طبيب عام',
          date: '23 أكتوبر 2023',
        ),
        const SizedBox(height: 12),
        _buildVisitItem(
          title: 'متابعة حالة السكري',
          description:
              'الشكوى الرئيسية: ارتفاع مستوى السكر\nد. فاطمة الزهراء - غدد صماء',
          date: '15 أغسطس 2023',
        ),
        const SizedBox(height: 12),
        _buildVisitItem(
          title: 'استشارة جلدية',
          description: 'الشكوى الرئيسية: طفح جلدي\nد. يوسف علي - طبيب جلدية',
          date: '02 يونيو 2023',
        ),
      ],
    );
  }

  Widget _buildVisitItem({
    required String title,
    required String description,
    required String date,
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
                  description,
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search
        TextField(
          decoration: InputDecoration(
            hintText: 'بحث في التقارير',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Report Items
        _buildReportItem(
          title: 'تحليل الدم الشامل',
          type: 'تحليل مخبري',
          date: '15 نوفمبر 2024',
          doctor: 'د. أحمد محمد',
          status: 'جديد',
        ),
        const SizedBox(height: 12),
        _buildReportItem(
          title: 'أشعة سينية على الصدر',
          type: 'أشعة تشخيصية',
          date: '28 أكتوبر 2024',
          doctor: 'د. فاطمة الزهراء',
          status: 'مطابق',
        ),
        const SizedBox(height: 12),
        _buildReportItem(
          title: 'مخطط صدى القلب',
          type: 'أشعة تشخيصية',
          date: '10 أكتوبر 2024',
          doctor: 'د. يوسف علي',
          status: 'يحتاج متابعة',
        ),
      ],
    );
  }

  Widget _buildPrescriptionsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search
        TextField(
          decoration: InputDecoration(
            hintText: 'بحث في الوصفات',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Prescription Items
        _buildPrescriptionItem(
          medications: [
            {
              'name': 'باراسيتامول',
              'dosage': '500 مج',
              'frequency': 'كل 8 ساعات',
            },
            {
              'name': 'أوميبرازول',
              'dosage': '20 مج',
              'frequency': 'مرة واحدة يومياً',
            },
          ],
          date: '20 نوفمبر 2024',
          doctor: 'د. أحمد محمد',
          diagnosis: 'التهاب المعدة',
          duration: '7 أيام',
        ),
        const SizedBox(height: 12),
        _buildPrescriptionItem(
          medications: [
            {
              'name': 'ميتفورمين',
              'dosage': '850 مج',
              'frequency': 'مرتين يومياً',
            },
            {
              'name': 'جليكلازيد',
              'dosage': '30 مج',
              'frequency': 'مرة واحدة صباحاً',
            },
          ],
          date: '15 نوفمبر 2024',
          doctor: 'د. فاطمة الزهراء',
          diagnosis: 'السكري النوع الثاني',
          duration: 'مستمر',
        ),
      ],
    );
  }

  Widget _buildReportItem({
    required String title,
    required String type,
    required String date,
    required String doctor,
    required String status,
  }) {
    Color statusColor = Colors.blue;
    if (status == 'جديد') statusColor = Colors.green;
    if (status == 'يحتاج متابعة') statusColor = Colors.orange;

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
            child: const Icon(Icons.analytics, color: AppColors.primary),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$doctor • $date',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Handle report download/view
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري تحميل التقرير...')),
              );
            },
            icon: const Icon(Icons.download, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionItem({
    required List<Map<String, String>> medications,
    required String date,
    required String doctor,
    required String diagnosis,
    required String duration,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                diagnosis,
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
          const SizedBox(height: 8),
          Text(
            '$doctor • لمدة $duration',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          ...medications.map(
            (med) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${med['dosage']} • ${med['frequency']}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Handle medication details
                    },
                    icon: const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Handle prescription refill
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إرسال طلب تجديد الوصفة'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('تجديد'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Handle print prescription
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('جاري طباعة الوصفة...')),
                    );
                  },
                  icon: const Icon(Icons.print, size: 16),
                  label: const Text('طباعة'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
