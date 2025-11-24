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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50,
              Colors.purple.shade50,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple.shade50,
                      Colors.purple.shade50,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.deepPurple.shade400,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Pembelian Tiket',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Movie Info Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'lib/assets/images/${widget.movie.id}.jpg',
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 140,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.movie.title,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple.shade900,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.category_rounded,
                                            size: 16,
                                            color: Colors.deepPurple.shade300,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.movie.genre,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.green.shade400,
                                              Colors.green.shade600,
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _currencyFormat
                                              .format(widget.movie.price),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.deepPurple.shade300,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              '${widget.schedule.time} - ${widget.schedule.date}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Buyer Name Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            enabled: false,
                            controller: _buyerNameController,
                            decoration: InputDecoration(
                              labelText: 'Nama Pembeli',
                              labelStyle: TextStyle(
                                color: Colors.deepPurple.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.deepPurple.shade400,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Purchase Date Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              enabled: false,
                              labelText: 'Tanggal Pembelian',
                              labelStyle: TextStyle(
                                color: Colors.deepPurple.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.calendar_today,
                                color: Colors.deepPurple.shade400,
                              ),
                            ),
                            child: Text(
                              DateFormat('yyyy-MM-dd').format(DateTime.now()),
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Quantity Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            onChanged: (value) => _validateQuantity(value),
                            validator: _validateQuantity,
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Jumlah Tiket',
                              labelStyle: TextStyle(
                                color: Colors.deepPurple.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.confirmation_number,
                                color: Colors.deepPurple.shade400,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Payment Method
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: DropdownMenu(
                            width: MediaQuery.of(context).size.width - 48,
                            initialSelection: _paymentMethod,
                            dropdownMenuEntries: [
                              DropdownMenuEntry(
                                leadingIcon: Icon(
                                  Icons.money,
                                  color: Colors.deepPurple.shade400,
                                ),
                                value: 'Cash',
                                label: 'Cash',
                              ),
                              DropdownMenuEntry(
                                leadingIcon: Icon(
                                  Icons.credit_card,
                                  color: Colors.deepPurple.shade400,
                                ),
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
                            label: Text(
                              'Metode Pembayaran',
                              style: TextStyle(
                                color: Colors.deepPurple.shade400,
                              ),
                            ),
                            leadingIcon: Icon(
                              Icons.payment,
                              color: Colors.deepPurple.shade400,
                            ),
                            inputDecorationTheme: InputDecorationTheme(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        if (_paymentMethod == 'Kartu Debit/Kredit') ...[
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _cardNumberController,
                              decoration: InputDecoration(
                                labelText: 'Nomor Kartu Debit/Kredit',
                                labelStyle: TextStyle(
                                  color: Colors.deepPurple.shade400,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(
                                  Icons.credit_card,
                                  color: Colors.deepPurple.shade400,
                                ),
                                helperText: '16 digit angka',
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 16,
                              validator: _validateCardNumber,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        // Total Price
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Pembayaran:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _currencyFormat.format(_totalPrice),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Submit Button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: FilledButton(
                            onPressed: _isLoading ? null : _submitPurchase,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              backgroundColor: Colors.deepPurple.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'Konfirmasi Pembelian',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
