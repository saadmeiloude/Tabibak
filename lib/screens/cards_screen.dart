import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../widgets/custom_button.dart';
import '../services/api_service.dart';
import '../core/localization/app_localizations.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  Future<void> _fetchCards() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.request(
        endpoint: 'api/cards/list.php',
        method: 'GET',
        requiresAuth: true,
      );
      final result = ApiService.handleResponse(response);
      if (result['success']) {
        setState(() {
          _cards = List<Map<String, dynamic>>.from(result['data']);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showError(result['error'] ?? 'Failed to load cards');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc?.myCards ?? 'بطاقاتي'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              if (loc != null) _showAddCardDialog(loc);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
          ? _buildEmptyState(loc)
          : _buildCardsList(loc),
    );
  }

  Widget _buildEmptyState(AppLocalizations? loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card, size: 80, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            loc?.noCardsFound ?? 'لا توجد بطاقات محفوظة',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc?.addCardHint ?? 'أضف بطاقة دفع لإجراء حجوزاتك بسهولة',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: loc?.addCardTitle ?? 'إضافة بطاقة',
            onPressed: () {
              if (loc != null) _showAddCardDialog(loc);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardsList(AppLocalizations? loc) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        final card = _cards[index];
        return _buildCardWidget(card, index, loc);
      },
    );
  }

  Widget _buildCardWidget(
    Map<String, dynamic> card,
    int index,
    AppLocalizations? loc,
  ) {
    final isDefault = (card['is_default'] == 1 || card['is_default'] == '1');
    final cardType = card['card_type'] as String;

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
                _getCardTypeName(cardType, loc),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Icon(_getCardIcon(cardType), color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            card['card_number_masked'] ?? card['number'] ?? '',
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
                    loc?.cardHolderShort ?? 'حامل البطاقة',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  Text(
                    card['holder_name'] ?? card['holderName'] ?? '',
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
                    loc?.validThru ?? 'صالح حتى',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  Text(
                    card['expiry_date'] ?? card['expiryDate'] ?? '',
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
              child: Text(
                loc?.defaultLabel ?? 'افتراضي',
                style: const TextStyle(
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
                    _setAsDefault(card['id']);
                  },
                  child: Text(
                    loc?.setAsDefaultLabel ?? 'تعيين كافتراضي',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              IconButton(
                onPressed: () {
                  _showCardOptions(index, loc);
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
      case 'mastercard':
        return Icons.credit_card;
      case 'mada':
        return Icons.payment;
      default:
        return Icons.credit_card;
    }
  }

  String _getCardTypeName(String cardType, AppLocalizations? loc) {
    switch (cardType) {
      case 'visa':
        return loc?.visaLabel ?? 'Visa';
      case 'mada':
        return loc?.madaLabel ?? 'مدى';
      case 'mastercard':
        return loc?.mastercardLabel ?? 'Mastercard';
      default:
        return loc?.cardLabel ?? 'بطاقة';
    }
  }

  Future<void> _setAsDefault(dynamic id) async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/cards/set_default.php',
        method: 'POST',
        data: {'id': id},
        requiresAuth: true,
      );
      final result = ApiService.handleResponse(response);
      if (result['success']) {
        _showSuccess(
          AppLocalizations.of(context)?.cardDefaultSuccess ??
              'تم تعيين البطاقة كافتراضية',
        );
        _fetchCards();
      } else {
        _showError(result['error'] ?? 'Operation failed');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showCardOptions(int index, AppLocalizations? loc) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(loc?.delete ?? 'حذف'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteCard(_cards[index]['id']);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCardDialog(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddCardDialog(
          onCardAdded: (card) {
            Navigator.pop(context);
            _fetchCards();
            _showSuccess(loc.cardAddedSuccess);
          },
        );
      },
    );
  }

  Future<void> _deleteCard(dynamic id) async {
    try {
      final response = await ApiService.request(
        endpoint: 'api/cards/delete.php',
        method: 'POST',
        data: {'id': id},
        requiresAuth: true,
      );
      final result = ApiService.handleResponse(response);
      if (result['success']) {
        _showSuccess(
          AppLocalizations.of(context)?.cardDeletedSuccess ?? 'تم حذف البطاقة',
        );
        _fetchCards();
      } else {
        _showError(result['error'] ?? 'Delete failed');
      }
    } catch (e) {
      _showError(e.toString());
    }
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
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.request(
        endpoint: 'api/cards/create.php',
        method: 'POST',
        data: {
          'card_type': _cardType,
          'card_number': _cardNumberController.text,
          'holder_name': _holderNameController.text,
          'expiry_date': _expiryDateController.text,
        },
        requiresAuth: true,
      );
      final result = ApiService.handleResponse(response);
      if (result['success']) {
        widget.onCardAdded(result['data']);
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to add card'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(loc?.addCardTitle ?? 'إضافة بطاقة جديدة'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _cardType,
                decoration: InputDecoration(
                  labelText: loc?.cardTypeLabel ?? 'نوع البطاقة',
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'visa',
                    child: Text(loc?.visaLabel ?? 'Visa'),
                  ),
                  DropdownMenuItem(
                    value: 'mada',
                    child: Text(loc?.madaLabel ?? 'مدى'),
                  ),
                  DropdownMenuItem(
                    value: 'mastercard',
                    child: Text(loc?.mastercardLabel ?? 'Mastercard'),
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
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc?.cardNumberLabel ?? 'رقم البطاقة',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc?.error ?? 'يرجى إدخال رقم البطاقة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _holderNameController,
                decoration: InputDecoration(
                  labelText: loc?.cardHolderNameLabel ?? 'اسم حامل البطاقة',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc?.error ?? 'يرجى إدخال اسم حامل البطاقة';
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
                      decoration: InputDecoration(
                        labelText:
                            loc?.expiryDateLabel ?? 'تاريخ الانتهاء (MM/YY)',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc?.error ?? 'مطلوب';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: loc?.cvvLabel ?? 'CVV',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc?.error ?? 'مطلوب';
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
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(loc?.cancel ?? 'إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(loc?.add ?? 'إضافة'),
        ),
      ],
    );
  }
}
