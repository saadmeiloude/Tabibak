import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/colors.dart';
import '../widgets/custom_button.dart';
import '../services/data_service.dart';
import '../services/api_service.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  int _selectedDateIndex = 0;
  String? _selectedTimeSlot;

  // Mock data for appointments
  final List<Map<String, dynamic>> _dates = [
    {
      'day': 'اليوم',
      'date': '20 أكتوبر',
      'slots': ['10:00 ص', '11:30 ص'],
    },
    {
      'day': 'غداً',
      'date': '21 أكتوبر',
      'slots': ['11:30 ص', '4:00 م'],
    },
    {
      'day': 'الاثنين',
      'date': '22 أكتوبر',
      'slots': ['4:00 م', '5:30 م'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ملف الطبيب'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _shareDoctor(),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Doctor Header Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    // backgroundImage: AssetImage(widget.doctor['image']), // Use asset if available
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.doctor['name'] ?? 'د. خالد العتيبي',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.doctor['specialty'] ?? 'استشاري قلب وأوعية دموية',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.doctor['rating'] ?? 4.9}/5',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ' (${widget.doctor['reviews'] ?? 125} تعليق)',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Action Button
            CustomButton(
              text: 'حجز موعد',
              onPressed: () {
                // Navigate to Consultation Screen or Confirmation
                Navigator.pushNamed(
                  context,
                  '/booking-calendar',
                  arguments: widget.doctor,
                );
              },
            ),
            const SizedBox(height: 16),

            // Secondary Actions (Chat, Share)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('دردشة مباشرة'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareDoctor(),
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('مشاركة الملف'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'تقييم الطبيب',
              backgroundColor: Colors.amber.shade700,
              onPressed: () => _showRatingDialog(),
            ),
            const SizedBox(height: 32),

            // Available Appointments
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'المواعيد المتاحة',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _dates.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final dateInfo = _dates[index];
                  final isSelected = _selectedDateIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDateIndex = index;
                        _selectedTimeSlot =
                            null; // Reset time slot on date change
                      });
                    },
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dateInfo['day'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            dateInfo['date'],
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Divider(),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            alignment: WrapAlignment.center,
                            children: (dateInfo['slots'] as List<String>).map((
                              slot,
                            ) {
                              final isSlotSelected =
                                  _selectedTimeSlot == slot && isSelected;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedDateIndex = index;
                                    _selectedTimeSlot = slot;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSlotSelected
                                        ? AppColors.primary
                                        : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    slot,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSlotSelected
                                          ? Colors.white
                                          : Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Experience and Certificates (Expandable tiles)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'الخبرة والشهادات',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                children: const [
                  ExpansionTile(
                    title: Text('الخبرة'),
                    subtitle: Text('15 سنة خبرة في طب القلب'),
                    leading: Icon(Icons.work_outline, color: AppColors.primary),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('تفاصيل الخبرة...'),
                      ),
                    ],
                  ),
                  Divider(height: 1),
                  ExpansionTile(
                    title: Text('الشهادات'),
                    subtitle: Text(
                      'زمالة الكلية الأمريكية لأمراض القلب، دكتوراه في طب القلب',
                    ),
                    leading: Icon(
                      Icons.school_outlined,
                      color: AppColors.primary,
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('تفاصيل الشهادات...'),
                      ),
                    ],
                  ),
                  Divider(height: 1),
                  ExpansionTile(
                    title: Text('أماكن العمل'),
                    subtitle: Text('مستشفى الشيخ زايد، مركز نواكشوط الطبي'),
                    leading: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('تفاصيل أماكن العمل...'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _shareDoctor() {
    final String doctorName = widget.doctor['name'] ?? 'طبيب';
    final String specialty = widget.doctor['specialty'] ?? '';
    final String text =
        'مشاركة ملف الطبيب: $doctorName\nالتخصص: $specialty\nحمل تطبيق طبيبي للمزيد من التفاصيل.';
    Share.share(text);
  }

  void _showRatingDialog() {
    int localRating = 5;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('تقييم الطبيب'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < localRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            localRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reviewController,
                    decoration: const InputDecoration(
                      hintText: 'اكتب رأيك هنا...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await DataService.rateDoctor(
                      doctorId: widget.doctor['user_id'] ?? widget.doctor['id'],
                      rating: localRating,
                      reviewText: reviewController.text,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result['success']
                                ? 'تم التقييم بنجاح'
                                : 'فشل التقييم: ${result['message']}',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('إرسال'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
