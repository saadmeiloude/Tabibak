import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/constants/mauritanian_constants.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../models/appointment.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Appointment> _activeOrders = [];
  List<Appointment> _completedOrders = [];
  List<Appointment> _cancelledOrders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      final result = await DataService.getUserAppointments(userId: user.id);

      if (result['success']) {
        final List<Appointment> allAppointments = result['appointments'];

        setState(() {
          _activeOrders = allAppointments
              .where((a) => a.status == 'pending' || a.status == 'confirmed')
              .toList();
          _completedOrders = allAppointments
              .where((a) => a.status == 'completed')
              .toList();
          _cancelledOrders = allAppointments
              .where((a) => a.status == 'cancelled')
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('طلباتي'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'نشطة'),
            Tab(text: 'مكتملة'),
            Tab(text: 'ملغية'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadOrders,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(_activeOrders, 'لا توجد طلبات نشطة'),
                _buildOrdersList(_completedOrders, 'لا توجد طلبات مكتملة'),
                _buildOrdersList(_cancelledOrders, 'لا توجد طلبات ملغية'),
              ],
            ),
    );
  }

  Widget _buildOrdersList(List<Appointment> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Appointment order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header with order ID and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'APT-${order.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(order.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Doctor info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.doctorName ?? 'طبيب غير معروف',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    // Specialty is not directly in Appointment model unless we updated list.php to join,
                    // but the model definition in data_service.dart might not have it mapped yet.
                    // For now we don't display specialty or display a placeholder if needed.
                    /*
                    Text(
                      'تخصص', 
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    */
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Order details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getTypeIcon(order.consultationType),
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _getTypeText(order.consultationType),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('yyyy-MM-dd').format(order.appointmentDate),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(order.appointmentTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Amount and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المبلغ: ${MauritanianConstants.formatPrice(order.feePaid)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Row(
                children: [
                  if (order.status == 'confirmed' || order.status == 'pending')
                    TextButton(
                      onPressed: () {
                        _cancelOrder(order.id);
                      },
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  /*
                  if (order.status == 'completed')
                    TextButton(
                      onPressed: () {
                        _rateOrder(order);
                      },
                      child: const Text(
                        'تقييم',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  */
                  TextButton(
                    onPressed: () {
                      _viewOrderDetails(order);
                    },
                    child: const Text(
                      'التفاصيل',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'مؤكد';
      case 'pending':
        return 'في الانتظار';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'online':
        return 'استشارة أونلاين';
      case 'in_person':
        return 'زيارة عيادة';
      default:
        return type;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'online':
        return Icons.videocam;
      case 'in_person':
        return Icons.local_hospital;
      default:
        return Icons.event;
    }
  }

  void _cancelOrder(int orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إلغاء الطلب'),
          content: const Text('هل أنت متأكد من إلغاء هذا الطلب؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('لا'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performCancelOrder(orderId);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('نعم، إلغاء'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performCancelOrder(int orderId) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await DataService.cancelAppointment(orderId);

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (result['success']) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إلغاء الطلب بنجاح')));
        _loadOrders(); // Reload list
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _viewOrderDetails(Appointment order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تفاصيل الطلب APT-${order.id}'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الطبيب: ${order.doctorName ?? "غير معروف"}'),
                Text('النوع: ${_getTypeText(order.consultationType)}'),
                Text(
                  'التاريخ: ${DateFormat('yyyy-MM-dd').format(order.appointmentDate)}',
                ),
                Text(
                  'الوقت: ${DateFormat('HH:mm').format(order.appointmentTime)}',
                ),
                Text(
                  'المبلغ: ${MauritanianConstants.formatPrice(order.feePaid)}',
                ),
                Text('الحالة: ${_getStatusText(order.status)}'),
                if (order.symptoms != null && order.symptoms!.isNotEmpty)
                  Text('الأعراض: ${order.symptoms}'),
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
}
