import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/colors.dart';
import '../widgets/custom_button.dart';
import '../services/data_service.dart';
import '../services/availability_service.dart';
import '../models/time_slot.dart';
import 'package:intl/intl.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final AvailabilityService _availabilityService = AvailabilityService();
  bool _isLoadingAvailability = false;
  List<DoctorAvailability> _availability = [];
  int _selectedDateIndex = 0;
  TimeSlot? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final doctorIdRaw = widget.doctor['id'];
    if (doctorIdRaw == null) return;

    final int doctorId = doctorIdRaw is int
        ? doctorIdRaw
        : int.tryParse(doctorIdRaw.toString()) ?? 0;

    if (doctorId == 0) return;

    setState(() => _isLoadingAvailability = true);

    final today = DateTime.now();
    final endDate = today.add(const Duration(days: 3));

    final result = await _availabilityService.getDoctorAvailability(
      doctorId: doctorId,
      startDate: today,
      endDate: endDate,
    );

    if (mounted) {
      setState(() {
        if (result['success']) {
          _availability = result['availability'];
        }
        _isLoadingAvailability = false;
      });
    }
  }

  String _formatSlotTime(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    if (hour < 12) return '$hour:$minute ص';
    if (hour == 12) return '12:$minute م';
    return '${hour - 12}:$minute م';
  }

  String _getDayLabel(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year)
      return 'اليوم';
    final tomorrow = now.add(const Duration(days: 1));
    if (date.day == tomorrow.day &&
        date.month == tomorrow.month &&
        date.year == tomorrow.year)
      return 'غداً';
    return DateFormat('EEEE', 'ar').format(date);
  }

  String _getDateLabel(DateTime date) {
    return DateFormat('d MMMM', 'ar').format(date);
  }

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
              child: _isLoadingAvailability
                  ? const Center(child: CircularProgressIndicator())
                  : _availability.isEmpty
                  ? const Center(child: Text('لا توجد مواعيد متاحة حالياً'))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availability.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final avail = _availability[index];
                        final isSelected = _selectedDateIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDateIndex = index;
                              _selectedTimeSlot = null;
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
                                  _getDayLabel(DateTime.parse(avail.date)),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _getDateLabel(DateTime.parse(avail.date)),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white70
                                        : AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                                const Divider(),
                                avail.slots.isEmpty
                                    ? const Text(
                                        'مغلق',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        alignment: WrapAlignment.center,
                                        children: avail.slots.take(2).map((
                                          slot,
                                        ) {
                                          final timeStr = _formatSlotTime(
                                            slot.startTime,
                                          );
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              timeStr,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.green.shade700,
                                                fontWeight: FontWeight.bold,
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
