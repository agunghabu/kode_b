import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import 'edit_transaction_page.dart';

class PurchaseDetailPage extends StatefulWidget {
  final Transaction transaction;
  const PurchaseDetailPage({super.key, required this.transaction});

  @override
  State<PurchaseDetailPage> createState() => _PurchaseDetailPageState();
}

class _PurchaseDetailPageState extends State<PurchaseDetailPage> {
  final _storageService = StorageService();
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  late Transaction _transaction;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  Future<void> _cancelTransaction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembatalan'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan transaksi ini? '
          'Transaksi yang dibatalkan akan dihapus dari riwayat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storageService.deleteTransaction(_transaction.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil dibatalkan')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _editTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionPage(transaction: _transaction),
      ),
    );

    if (result != null && result is Transaction) {
      setState(() {
        _transaction = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        title: const Text('Detail Pembelian'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _editTransaction,
        icon: const Icon(Icons.edit_rounded),
        label: const Text("Edit Transaksi"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade300),
              child: Image.asset(
                'lib/assets/images/${_transaction.movie.id}.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _transaction.movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _transaction.movie.genre,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    'Jadwal Film',
                    '${_transaction.schedule.time} - ${_transaction.schedule.date}',
                  ),
                  const Divider(),
                  _buildDetailRow('Nama Pembeli', _transaction.buyerName),
                  const Divider(),
                  _buildDetailRow(
                    'Jumlah Tiket',
                    '${_transaction.quantity} tiket',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    'Tanggal Pembelian',
                    _transaction.purchaseDate,
                  ),
                  const Divider(),
                  _buildDetailRow(
                    'Metode Pembayaran',
                    _transaction.paymentMethod,
                  ),
                  if (_transaction.cardNumber != null) ...[
                    const Divider(),
                    _buildDetailRow(
                      'Nomor Kartu',
                      _transaction.maskedCardNumber,
                    ),
                  ],
                  const Divider(),
                  _buildDetailRow(
                    'Total Biaya',
                    _currencyFormat.format(_transaction.totalPrice),
                    isHighlighted: true,
                  ),
                  const Divider(),
                  _buildDetailRow(
                    'Status',
                    _transaction.status == 'completed'
                        ? 'Selesai'
                        : 'Dibatalkan',
                    statusColor: _transaction.status == 'completed'
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _cancelTransaction,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Batalkan Transaksi'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlighted = false,
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color:
                    statusColor ??
                    (isHighlighted ? Colors.green : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
