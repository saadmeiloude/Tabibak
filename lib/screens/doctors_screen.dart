import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/localization/app_localizations.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  String _selectedFilter = 'الكل';
  String _searchQuery = '';
  bool _isListView = true;

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _doctors = [
    {
      'name': 'dr_ahmed_elmi',
      'specialty': 'طبيب قلب',
      'distance': '2',
      'rating': 4.8,
      'reviews': 120,
      'price': 250,
      'image': 'assets/images/doctor1.png',
      'available': true,
    },
    {
      'name': 'dr_sara_ahmed',
      'specialty': 'طبيبة عامة',
      'distance': '1.5',
      'rating': 4.9,
      'reviews': 85,
      'price': 180,
      'image': 'assets/images/doctor2.png',
      'available': true,
    },
    {
      'name': 'dr_khaled_omar',
      'specialty': 'جلدية',
      'distance': '3',
      'rating': 4.7,
      'reviews': 95,
      'price': 220,
      'image': 'assets/images/doctor3.png',
      'available': false,
    },
    {
      'name': 'dr_fatima_zahra',
      'specialty': 'أطفال',
      'distance': '0.8',
      'rating': 4.9,
      'reviews': 150,
      'price': 200,
      'image': 'assets/images/doctor4.png',
      'available': true,
    },
    {
      'name': 'dr_mohamed_otaibi',
      'specialty': 'عظام',
      'distance': '2.5',
      'rating': 4.6,
      'reviews': 78,
      'price': 280,
      'image': 'assets/images/doctor5.png',
      'available': true,
    },
    {
      'name': 'dr_nora_saad',
      'specialty': 'أنف وأذن وحنجرة',
      'distance': '1.2',
      'rating': 4.8,
      'reviews': 110,
      'price': 240,
      'image': 'assets/images/doctor6.png',
      'available': false,
    },
  ];

  final List<String> _specialties = [
    'الكل',
    'طبيب قلب',
    'طبيبة عامة',
    'جلدية',
    'أطفال',
    'عظام',
    'أنف وأذن وحنجرة',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredDoctors {
    var loc = AppLocalizations.of(context);
    var filtered = _doctors.where((doctor) {
      final nameLocal = _getLocalizedName(context, doctor['name']);
      final specialtyLocal = _getLocalizedSpecialty(
        context,
        doctor['specialty'],
      );

      final matchesSearch =
          _searchQuery.isEmpty ||
          nameLocal.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          specialtyLocal.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter =
          _selectedFilter == 'الكل' || doctor['specialty'] == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();

    return filtered;
  }

  String _getLocalizedName(BuildContext context, String key) {
    var loc = AppLocalizations.of(context);
    switch (key) {
      case 'dr_ahmed_elmi':
        return loc?.drAhmedElmi ?? 'د. أحمد علمي';
      case 'dr_sara_ahmed':
        return loc?.drSaraAhmed ?? 'د. سارة أحمد';
      case 'dr_khaled_omar':
        return loc?.drKhaledOmar ?? 'د. خالد عمر';
      case 'dr_fatima_zahra':
        return loc?.drFatimaZahra ?? 'د. فاطمة الزهراء';
      case 'dr_mohamed_otaibi':
        return loc?.drMohamedOtaibi ?? 'د. محمد العتيبي';
      case 'dr_nora_saad':
        return loc?.drNoraSaad ?? 'د. نورا السعد';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
            Text(
              loc?.searchDoctors ?? 'البحث عن الأطباء',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 48), // Spacer
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText:
                      loc?.searchPlaceholder ?? 'ابحث عن الأطباء أو التخصصات',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _specialties.map((specialty) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(specialty),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Results count
            Text(
              '${_filteredDoctors.length} ${loc?.doctorsAvailable ?? "طبيب متاح"}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // View Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isListView = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isListView
                              ? AppColors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _isListView
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.view_list,
                                color: _isListView
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                loc?.listView ?? 'قائمة',
                                style: TextStyle(
                                  color: _isListView
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: _isListView
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isListView = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isListView
                              ? AppColors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: !_isListView
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map,
                                color: !_isListView
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                loc?.mapView ?? 'خريطة',
                                style: TextStyle(
                                  color: !_isListView
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: !_isListView
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Doctors List
            if (_isListView) _buildDoctorsList() else _buildMapView(),

            const SizedBox(height: 100), // Bottom padding for floating buttons
          ],
        ),
      ),
      floatingActionButton: _searchQuery.isNotEmpty || _selectedFilter != 'الكل'
          ? FloatingActionButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedFilter = 'الكل';
                });
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.clear, color: Colors.white),
            )
          : null,
    );
  }

  String _getLocalizedSpecialty(BuildContext context, String specialty) {
    var loc = AppLocalizations.of(context);
    switch (specialty) {
      case 'الكل':
        return loc?.all ?? 'الكل';
      case 'طبيب قلب':
        return loc?.cardiologist ?? 'طبيب قلب';
      case 'طبيبة عامة':
        return loc?.generalPractitioner ?? 'طبيبة عامة';
      case 'جلدية':
        return loc?.dermatologist ?? 'جلدية';
      case 'أطفال':
        return loc?.pediatrician ?? 'أطفال';
      case 'عظام':
        return loc?.orthopedist ?? 'عظام';
      case 'أنف وأذن وحنجرة':
        return loc?.entSpecialist ?? 'أنف وأذن وحنجرة';
      default:
        return specialty;
    }
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _getLocalizedSpecialty(context, label),
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorsList() {
    var loc = AppLocalizations.of(context);
    if (_filteredDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              loc?.noResults ?? 'لا توجد نتائج',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loc?.tryChangingFilters ?? 'جرب تغيير كلمات البحث أو المرشحات',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _filteredDoctors.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final doctor = _filteredDoctors[index];
        return _buildDoctorCard(doctor);
      },
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    var loc = AppLocalizations.of(context);
    final String currency = loc?.currencyMru ?? 'أوقية';
    final String km = loc?.kmUnit ?? 'كم';

    return Container(
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
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person, size: 30, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getLocalizedName(context, doctor['name']),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: doctor['available']
                                ? Colors.green.shade50
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            doctor['available']
                                ? (loc?.doctorAvailableStatus ?? 'متاح')
                                : (loc?.doctorUnavailableStatus ?? 'غير متاح'),
                            style: TextStyle(
                              color: doctor['available']
                                  ? Colors.green.shade700
                                  : Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _getLocalizedSpecialty(context, doctor['specialty']),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${loc?.nouakchott ?? 'نواكشوط'}، ${doctor['distance']} $km',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor['rating']} (${doctor['reviews']} ${loc?.reviews ?? 'تقييم'})',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price and Actions
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${loc?.price ?? 'السعر'}: ${doctor['price']} $currency',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: doctor['available']
                      ? () {
                          _showDoctorOptions(doctor);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: doctor['available']
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    foregroundColor: doctor['available']
                        ? Colors.white
                        : Colors.grey.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(loc?.bookAppointment ?? 'حجز موعد'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    var loc = AppLocalizations.of(context);
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              loc?.viewMap ?? 'عرض الخريطة',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loc?.mapComingSoon ?? 'سيتم عرض موقع الأطباء قريباً',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _showDoctorOptions(Map<String, dynamic> doctor) {
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
                doctor['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(loc?.bookAppointment ?? 'حجز موعد'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/booking-calendar',
                    arguments: doctor,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: Text(loc?.instantConsultation ?? 'استشارة فورية'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/consultation',
                    arguments: doctor,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(loc?.viewProfile ?? 'عرض الملف الشخصي'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/doctor-profile',
                    arguments: doctor,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
