import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/wallet_service.dart';
import '../services/auth_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Wallet? _wallet;
  Map<String, dynamic>? _statistics;
  List<WalletTransaction> _transactions = [];
  bool _isLoading = true;
  bool _isLoadingTransactions = false;
  String? _error;

  final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'ar');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWalletData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWalletData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      final response = await WalletService.getWalletBalance(user.id);

      if (response['success']) {
        setState(() {
          _wallet = Wallet.fromJson(response['wallet']);
          _statistics = response['statistics'];
          _isLoading = false;
        });
        _loadTransactions();
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTransactions() async {
    if (_wallet == null) return;

    setState(() {
      _isLoadingTransactions = true;
    });

    try {
      final response = await WalletService.getTransactions(
        userId: _wallet!.userId,
        limit: 50,
      );

      if (response['success']) {
        setState(() {
          _transactions = (response['transactions'] as List)
              .map((t) => WalletTransaction.fromJson(t))
              .toList();
          _isLoadingTransactions = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingTransactions = false;
      });
    }
  }

  void _showDepositDialog() async {
    final user = await AuthService.getCurrentUser();
    final amountController = TextEditingController();
    final phoneController = TextEditingController(text: user?.phone ?? '');
    String selectedMethod = 'Bankily';

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('شحن الرصيد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'المبلغ (أوقية)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'طريقة الدفع (تطبيق بنكي):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedMethod,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Bankily', child: Text('Bankily')),
                    DropdownMenuItem(value: 'Masrvi', child: Text('Masrvi')),
                    DropdownMenuItem(value: 'Bimbank', child: Text('Bimbank')),
                    DropdownMenuItem(value: 'Sedad', child: Text('Sedad')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedMethod = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف المرتبط',
                    hintText: 'أدخل رقم هاتفك في التطبيق البنكي',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'سيتم إرسال طلب الدفع إلى تطبيق $selectedMethod المرتبط برقم هاتفك.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                final phone = phoneController.text.trim();

                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الرجاء إدخال مبلغ صحيح')),
                  );
                  return;
                }

                if (phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الرجاء إدخال رقم الهاتف')),
                  );
                  return;
                }

                Navigator.pop(context);
                await _processDeposit(amount, selectedMethod, phone);
              },
              child: const Text('شحن'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processDeposit(
    double amount,
    String method,
    String phone,
  ) async {
    if (_wallet == null) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Simulate a small delay for "Processing" with external bank
      await Future.delayed(const Duration(seconds: 1));

      final response = await WalletService.deposit(
        userId: _wallet!.userId,
        amount: amount,
        paymentMethod: method,
        phoneNumber: phone,
        description: 'إيداع عبر $method (هاتف: $phone)',
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'تم إرسال طلب الدفع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        _loadWalletData();
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showWithdrawalDialog() {
    final amountController = TextEditingController();
    String selectedMethod = 'bank_transfer';
    final bankNameController = TextEditingController();
    final accountNumberController = TextEditingController();
    final accountHolderController = TextEditingController();
    final mobileNumberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('سحب الرصيد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'المبلغ (أوقية)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.attach_money),
                    helperText: 'الحد الأدنى: 100 أوقية',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'طريقة السحب:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  title: const Text('تحويل بنكي'),
                  value: 'bank_transfer',
                  groupValue: selectedMethod,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedMethod = value!;
                    });
                  },
                ),
                if (selectedMethod == 'bank_transfer') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: bankNameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم البنك',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: accountNumberController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الحساب',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: accountHolderController,
                    decoration: const InputDecoration(
                      labelText: 'اسم صاحب الحساب',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                RadioListTile<String>(
                  title: const Text('محفظة إلكترونية'),
                  value: 'mobile_money',
                  groupValue: selectedMethod,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedMethod = value!;
                    });
                  },
                ),
                if (selectedMethod == 'mobile_money') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: mobileNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم المحفظة',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount < 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('الحد الأدنى للسحب هو 100 أوقية'),
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                await _processWithdrawal(
                  amount: amount,
                  method: selectedMethod,
                  bankName: bankNameController.text,
                  accountNumber: accountNumberController.text,
                  accountHolder: accountHolderController.text,
                  mobileNumber: mobileNumberController.text,
                );
              },
              child: const Text('سحب'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processWithdrawal({
    required double amount,
    required String method,
    String? bankName,
    String? accountNumber,
    String? accountHolder,
    String? mobileNumber,
  }) async {
    if (_wallet == null) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final response = await WalletService.withdraw(
        userId: _wallet!.userId,
        amount: amount,
        withdrawalMethod: method,
        bankName: bankName,
        accountNumber: accountNumber,
        accountHolderName: accountHolder,
        mobileMoneyNumber: mobileNumber,
      );

      Navigator.pop(context); // Close loading dialog

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.green,
          ),
        );
        _loadWalletData();
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحفظة'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الرصيد', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'المعاملات', icon: Icon(Icons.receipt_long)),
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
                    onPressed: _loadWalletData,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [_buildBalanceTab(), _buildTransactionsTab()],
            ),
    );
  }

  Widget _buildBalanceTab() {
    if (_wallet == null) return const SizedBox();

    return RefreshIndicator(
      onRefresh: _loadWalletData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الرصيد الحالي',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _currencyFormat.format(_wallet!.balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _wallet!.currencySymbol,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showDepositDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('شحن'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1E88E5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showWithdrawalDialog,
                          icon: const Icon(Icons.remove),
                          label: const Text('سحب'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistics
            if (_statistics != null) ...[
              const Text(
                'الإحصائيات',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'إجمالي الإيداعات',
                      _statistics!['total_deposits'] ?? 0,
                      Icons.arrow_downward,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'إجمالي السحوبات',
                      _statistics!['total_withdrawals'] ?? 0,
                      Icons.arrow_upward,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'إجمالي المدفوعات',
                      _statistics!['total_payments'] ?? 0,
                      Icons.payment,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'عدد المعاملات',
                      _statistics!['total_transactions'] ?? 0,
                      Icons.receipt,
                      Colors.purple,
                      isCount: true,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    dynamic value,
    IconData icon,
    Color color, {
    bool isCount = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isCount
                ? value.toString()
                : '${_currencyFormat.format(value)} ${_wallet!.currencySymbol}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: _isLoadingTransactions
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text('لا توجد معاملات بعد'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return _buildTransactionCard(transaction);
              },
            ),
    );
  }

  Widget _buildTransactionCard(WalletTransaction transaction) {
    final isPositive =
        transaction.type == 'deposit' || transaction.type == 'refund';
    final color = isPositive ? Colors.green : Colors.red;
    final icon = _getTransactionIcon(transaction.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          transaction.typeArabic,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.description),
            const SizedBox(height: 4),
            Text(
              DateFormat(
                'yyyy-MM-dd HH:mm',
                'ar',
              ).format(transaction.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              'المرجع: ${transaction.reference}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isPositive ? '+' : '-'}${_currencyFormat.format(transaction.amount)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                transaction.statusArabic,
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(transaction.status),
                ),
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'deposit':
        return Icons.arrow_downward;
      case 'withdrawal':
        return Icons.arrow_upward;
      case 'payment':
        return Icons.payment;
      case 'refund':
        return Icons.refresh;
      case 'transfer':
        return Icons.swap_horiz;
      case 'commission':
        return Icons.percent;
      default:
        return Icons.receipt;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
