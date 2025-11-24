import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/movie.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import 'purchase_history_page.dart';

class PurchaseFormPage extends StatefulWidget {
  final Movie movie;
  final MovieSchedule schedule;

  const PurchaseFormPage({
    super.key,
    required this.movie,
    required this.schedule,
  });

  @override
  State<PurchaseFormPage> createState() => _PurchaseFormPageState();
}

class _PurchaseFormPageState extends State<PurchaseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  User? _currentUser;
  final _buyerNameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  String _paymentMethod = 'Cash';
  final _cardNumberController = TextEditingController();
  double _totalPrice = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _calculateTotal();
    _quantityController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _buyerNameController.dispose();
    _quantityController.dispose();
    _cardNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _storageService.getCurrentUser();
    setState(() {
      _currentUser = user;
      _buyerNameController.text = user?.fullName ?? '';
    });
  }

  void _calculateTotal() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _totalPrice = widget.movie.price * quantity;
    });
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Jumlah tiket wajib diisi';
    }
    final quantity = int.tryParse(value);
    if (quantity == null || quantity <= 0) {
      return 'Jumlah tiket harus lebih dari 0';
    }
    return null;
  }

  String? _validateCardNumber(String? value) {
    if (_paymentMethod == 'Kartu Debit/Kredit') {
      if (value == null || value.isEmpty) {
        return 'Nomor kartu wajib diisi';
      }
      if (!RegExp(r'^[0-9]{16}$').hasMatch(value)) {
        return 'Nomor kartu harus 16 digit angka';
      }
    }
    return null;
  }

  Future<void> _submitPurchase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      movie: widget.movie,
      schedule: widget.schedule,
      buyerName: _currentUser?.fullName ?? 'Unknown',
      quantity: int.parse(_quantityController.text),
      purchaseDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      totalPrice: _totalPrice,
      paymentMethod: _paymentMethod,
      cardNumber: _paymentMethod == 'Kartu Debit/Kredit'
          ? _cardNumberController.text
          : null,
      status: 'completed',
    );

    await _storageService.saveTransaction(transaction);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembelian tiket berhasil!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PurchaseHistoryPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        title: const Text('Form Pembelian Tiket'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: Colors.transparent,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(width: 1, color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            child: Image.asset(
                              'lib/assets/images/${widget.movie.id}.jpg',
                              fit: BoxFit.cover,
                              height: 110,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 10, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.movie.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Genre: ${widget.movie.genre}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Harga: ${_currencyFormat.format(widget.movie.price)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Jadwal: ${widget.schedule.time} - ${widget.schedule.date}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                enabled: false,
                controller: _buyerNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pembeli',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  enabled: false,
                  labelText: 'Tanggal Pembelian',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                onChanged: (value) => _validateQuantity(value),
                validator: _validateQuantity,
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Tiket',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
              ),
              const SizedBox(height: 16),
              DropdownMenu(
                width: double.infinity,
                initialSelection: _paymentMethod,
                dropdownMenuEntries: [
                  const DropdownMenuEntry(
                    leadingIcon: Icon(Icons.money),
                    value: 'Cash',
                    label: 'Cash',
                  ),
                  const DropdownMenuEntry(
                    leadingIcon: Icon(Icons.credit_card),
                    value: 'Kartu Debit/Kredit',
                    label: 'Kartu Debit/Kredit',
                  ),
                ],
                onSelected: (String? value) {
                  setState(() {
                    _paymentMethod = value!;
                    if (_paymentMethod == 'Cash') {
                      _cardNumberController.clear();
                    }
                  });
                },
                label: const Text('Metode Pembayaran'),
                leadingIcon: const Icon(Icons.payment),
              ),
              if (_paymentMethod == 'Kartu Debit/Kredit') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cardNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Kartu Debit/Kredit',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card),
                    helperText: '16 digit angka',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  validator: _validateCardNumber,
                ),
              ],
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(_totalPrice),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _submitPurchase,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Konfirmasi Pembelian',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
