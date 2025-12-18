import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/data_service.dart';
import '../../core/localization/app_localizations.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    await DataService.init();
    final result = await DataService.getPatients();

    if (mounted) {
      setState(() {
        if (result['success']) {
          _patients = List<Map<String, dynamic>>.from(result['patients']);
          _filteredPatients = _patients;
        }
        _isLoading = false;
      });
    }
  }

  void _filterPatients(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredPatients = _patients;
      });
      return;
    }

    final filtered = _patients.where((patient) {
      final name = patient['full_name']?.toString().toLowerCase() ?? '';
      final phone = patient['phone']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase()) ||
          phone.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredPatients = filtered;
    });
  }

  Future<void> _showAddPatientDialog() async {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final ageController = TextEditingController();
    final genderController = TextEditingController();
    final bloodTypeController = TextEditingController();
    final allergiesController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)?.addNewPatientTitle ??
                'إضافة مريض جديد',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)?.patientNameLabel ??
                        'اسم المريض',
                    border: const OutlineInputBorder(),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: idController,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)?.patientIdLabel ??
                        'الرقم التعريفي',
                    border: const OutlineInputBorder(),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageController,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)?.ageLabel ?? 'العمر',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: genderController,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)?.genderLabel ?? 'الجنس',
                    border: const OutlineInputBorder(),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bloodTypeController,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)?.bloodTypeLabel ??
                        'فصيلة الدم',
                    border: const OutlineInputBorder(),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: allergiesController,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)?.allergiesLabel ??
                        'الحساسيات',
                    border: const OutlineInputBorder(),
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.cancel ?? 'إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    idController.text.isNotEmpty) {
                  // Using 'phone' as the ID for now as per backend requirement (or add separate ID field if DB supports it)
                  // The backend expects 'full_name' and 'phone'.
                  // We map user inputs to these fields.
                  final newPatient = {
                    'full_name': nameController.text,
                    'phone': idController
                        .text, // Using ID field input for Phone as it is unique
                    'date_of_birth': ageController.text.isNotEmpty
                        ? '${DateTime.now().year - int.parse(ageController.text)}-01-01'
                        : null,
                    // 'gender': genderController.text, // Backend needs to support this in create.php if not already
                    // 'blood_type': bloodTypeController.text,
                    // 'allergies': allergiesController.text,
                  };

                  final result = await DataService.savePatient(newPatient);

                  Navigator.of(context).pop();

                  if (mounted) {
                    if (result['success'] == true) {
                      // Check for boolean true
                      await _loadPatients();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)?.patientAddedSuccess ??
                                'تم إضافة المريض بنجاح',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result['message'] ??
                                result['error'] ??
                                AppLocalizations.of(
                                  context,
                                )?.patientAddedError ??
                                'فشل إضافة المريض',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: Text(AppLocalizations.of(context)?.add ?? 'إضافة'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.add, color: AppColors.primary, size: 30),
          onPressed: _showAddPatientDialog,
        ),
        title: Text(
          AppLocalizations.of(context)?.patientFiles ?? 'ملفات المرضى',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterPatients,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)?.searchPatientHint ??
                            'ابحث عن مريض بالاسم أو الرقم التعريفي...',
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredPatients.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(context)?.noPatientsFound ??
                                'لا توجد مرضى',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = _filteredPatients[index];
                            // Ensure API field mapping matches expectations
                            final name =
                                patient['full_name'] ??
                                patient['name'] ??
                                'Unknown';
                            final id =
                                patient['phone']?.toString() ??
                                patient['id']?.toString() ??
                                '#';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildPatientItem(
                                context,
                                name: name,
                                id: id,
                                patient: patient,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildPatientItem(
    BuildContext context, {
    required String name,
    required String id,
    required Map<String, dynamic> patient,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      child: ListTile(
        leading: const Icon(
          Icons.arrow_back_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
        trailing: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, color: Colors.grey),
        ),
        title: Text(
          name,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${AppLocalizations.of(context)?.patientIdDisplay ?? 'الرقم التعريفي: '}$id',
          textAlign: TextAlign.right,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/patient-file', arguments: patient);
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
