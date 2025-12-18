import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../widgets/custom_button.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  List<Map<String, dynamic>> _cards = [
    {
      'id': '1',
      'type': 'visa',
      'number': '**** **** **** 1234',
      'holderName': '',
      'expiryDate': '12/26',
      'isDefault': true,
    },
    {
      'id': '2',
      'type': 'mada',
      'number': '**** **** **** 5678',
      'holderName': '',
      'expiryDate': '08/25',
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('بطاقاتي'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _showAddCardDialog();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _cards.isEmpty ? _buildEmptyState() : _buildCardsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card, size: 80, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'لا توجد بطاقات محفوظة',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف بطاقة دفع لإجراء حجوزاتك بسهولة',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'إضافة بطاقة',
            onPressed: () {
              _showAddCardDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        final card = _cards[index];
        return _buildCardWidget(card, index);
      },
    );
  }

  Widget _buildCardWidget(Map<String, dynamic> card, int index) {
    final isDefault = card['isDefault'] as bool;
    final cardType = card['type'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getCardColors(cardType),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getCardTypeName(cardType),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Icon(_getCardIcon(cardType), color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            card['number'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حامل البطاقة',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  Text(
                    card['holderName'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'صالح حتى',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  Text(
                    card['expiryDate'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'افتراضي',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isDefault)
                TextButton(
                  onPressed: () {
                    _setAsDefault(index);
                  },
                  child: const Text(
                    'تعيين كافتراضي',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              IconButton(
                onPressed: () {
                  _showCardOptions(index);
                },
                icon: const Icon(Icons.more_vert, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Color> _getCardColors(String cardType) {
    switch (cardType) {
      case 'visa':
        return [Colors.blue.shade600, Colors.blue.shade800];
      case 'mada':
        return [Colors.green.shade600, Colors.green.shade800];
      case 'mastercard':
        return [Colors.red.shade600, Colors.red.shade800];
      default:
        return [Colors.grey.shade600, Colors.grey.shade800];
    }
  }

  IconData _getCardIcon(String cardType) {
    switch (cardType) {
      case 'visa':
        return Icons.credit_card;
      case 'mada':
        return Icons.payment;
      case 'mastercard':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  String _getCardTypeName(String cardType) {
    switch (cardType) {
      case 'visa':
        return 'Visa';
      case 'mada':
        return 'مدى';
      case 'mastercard':
        return 'Mastercard';
      default:
        return 'بطاقة';
    }
  }

  void _setAsDefault(int index) {
    setState(() {
      for (var card in _cards) {
        card['isDefault'] = false;
      }
      _cards[index]['isDefault'] = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم تعيين البطاقة كافتراضية')));
  }

  void _showCardOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('تعديل'),
                onTap: () {
                  Navigator.pop(context);
                  _editCard(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('حذف'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteCard(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddCardDialog(
          onCardAdded: (card) {
            setState(() {
              _cards.add(card);
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إضافة البطاقة بنجاح')),
            );
          },
        );
      },
    );
  }

  void _editCard(int index) {
    // Implement edit card functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تعديل البطاقة قريباً')));
  }

  void _deleteCard(int index) {
    setState(() {
      _cards.removeAt(index);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حذف البطاقة')));
  }
}

class AddCardDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onCardAdded;

  const AddCardDialog({super.key, required this.onCardAdded});

  @override
  State<AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  String _cardType = 'visa';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة بطاقة جديدة'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _cardType,
                decoration: const InputDecoration(
                  labelText: 'نوع البطاقة',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'visa', child: Text('Visa')),
                  DropdownMenuItem(value: 'mada', child: Text('مدى')),
                  DropdownMenuItem(
                    value: 'mastercard',
                    child: Text('Mastercard'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _cardType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'رقم البطاقة',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم البطاقة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _holderNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم حامل البطاقة',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم حامل البطاقة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateController,
                      decoration: const InputDecoration(
                        labelText: 'تاريخ الانتهاء (MM/YY)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'مطلوب';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'مطلوب';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
            if (_formKey.currentState!.validate()) {
              final card = {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'type': _cardType,
                'number':
                    '**** **** **** ${_cardNumberController.text.substring(_cardNumberController.text.length - 4)}',
                'holderName': _holderNameController.text,
                'expiryDate': _expiryDateController.text,
                'isDefault': false,
              };
              widget.onCardAdded(card);
            }
          },
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
