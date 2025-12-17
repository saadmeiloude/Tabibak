import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/constants/mauritanian_constants.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _activeOrders = [];
  List<Map<String, dynamic>> _completedOrders = [];
  List<Map<String, dynamic>> _cancelledOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  void _loadOrders() {
    // Mock data for demonstration
    _activeOrders = [
      {
        'id': 'ORD-001',
        'type': 'استشارة',
        'doctorName': 'د. سارة أحمد',
        'specialty': 'طبيبة عامة',
        'date': '2024-12-10',
        'time': '14:00',
        'status': 'confirmed',
        'amount': 150,
      },
      {
        'id': 'ORD-002',
        'type': 'موعد عيادة',
        'doctorName': 'د. أحمد علي',
        'specialty': 'طب أسرة',
        'date': '2024-12-11',
        'time': '10:30',
        'status': 'pending',
        'amount': 200,
      },
    ];

    _completedOrders = [
      {
        'id': 'ORD-003',
        'type': 'استشارة',
        'doctorName': 'د. خالد عمر',
        'specialty': 'جلدية',
        'date': '2024-12-08',
        'time': '16:00',
        'status': 'completed',
        'amount': 180,
        'rating': 5,
      },
      {
        'id': 'ORD-004',
        'type': 'موعد عيادة',
        'doctorName': 'د. فاطمة الزهراء',
        'specialty': 'أطفال',
        'date': '2024-12-05',
        'time': '11:00',
        'status': 'completed',
        'amount': 220,
        'rating': 4,
      },
    ];

    _cancelledOrders = [
      {
        'id': 'ORD-005',
        'type': 'استشارة',
        'doctorName': 'د. محمد العتيبي',
        'specialty': 'عظام',
        'date': '2024-12-03',
        'time': '09:00',
        'status': 'cancelled',
        'amount': 250,
        'cancellationReason': 'تغيير في المواعيد',
      },
    ];
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(_activeOrders, 'لا توجد طلبات نشطة'),
          _buildOrdersList(_completedOrders, 'لا توجد طلبات مكتملة'),
          _buildOrdersList(_cancelledOrders, 'لا توجد طلبات ملغية'),
        ],
      ),
    );
  }

  Widget _buildOrdersList(
    List<Map<String, dynamic>> orders,
    String emptyMessage,
  ) {
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final type = order['type'] as String;
    final amount = order['amount'] as int;

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
                order['id'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(status),
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
                      order['doctorName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      order['specialty'],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
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
                Icon(_getTypeIcon(type), size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(
                  '${order['date']} - ${order['time']}',
                  style: TextStyle(color: AppColors.textSecondary),
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
                'المبلغ: ${MauritanianConstants.formatPrice(amount.toDouble())}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Row(
                children: [
                  if (status == 'confirmed' || status == 'pending')
                    TextButton(
                      onPressed: () {
                        _cancelOrder(order['id']);
                      },
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  if (status == 'completed' && order['rating'] == null)
                    TextButton(
                      onPressed: () {
                        _rateOrder(order);
                      },
                      child: const Text(
                        'تقييم',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
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

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'استشارة':
        return Icons.chat;
      case 'موعد عيادة':
        return Icons.local_hospital;
      default:
        return Icons.receipt;
    }
  }

  void _cancelOrder(String orderId) {
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

  void _performCancelOrder(String orderId) {
    // Find and move order from active to cancelled
    final orderIndex = _activeOrders.indexWhere(
      (order) => order['id'] == orderId,
    );
    if (orderIndex != -1) {
      final order = _activeOrders[orderIndex];
      order['status'] = 'cancelled';
      order['cancellationReason'] = 'ملغي بواسطة المستخدم';

      setState(() {
        _activeOrders.removeAt(orderIndex);
        _cancelledOrders.insert(0, order);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إلغاء الطلب بنجاح')));
    }
  }

  void _rateOrder(Map<String, dynamic> order) {
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تقييم الخدمة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('كيف كانت تجربتك مع ${order['doctorName']}؟'),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setDialogState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveRating(order, rating);
              },
              child: const Text('إرسال'),
            ),
          ],
        );
      },
    );
  }

  void _saveRating(Map<String, dynamic> order, double rating) {
    setState(() {
      order['rating'] = rating.toInt();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('شكراً لتقييمك: $rating نجوم')));
  }

  void _viewOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تفاصيل الطلب ${order['id']}'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الطبيب: ${order['doctorName']}'),
                Text('التخصص: ${order['specialty']}'),
                Text('النوع: ${order['type']}'),
                Text('التاريخ: ${order['date']}'),
                Text('الوقت: ${order['time']}'),
                Text(
                  'المبلغ: ${MauritanianConstants.formatPrice(order['amount'].toDouble())}',
                ),
                Text('الحالة: ${_getStatusText(order['status'])}'),
                if (order['rating'] != null)
                  Text('التقييم: ${order['rating']} نجوم'),
                if (order['cancellationReason'] != null)
                  Text('سبب الإلغاء: ${order['cancellationReason']}'),
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
