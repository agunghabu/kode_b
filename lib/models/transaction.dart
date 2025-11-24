import 'movie.dart';

class Transaction {
  final String id;
  final Movie movie;
  final MovieSchedule schedule;
  final String buyerName;
  final int quantity;
  final String purchaseDate;
  final double totalPrice;
  final String paymentMethod;
  final String? cardNumber;
  String status;

  Transaction({
    required this.id,
    required this.movie,
    required this.schedule,
    required this.buyerName,
    required this.quantity,
    required this.purchaseDate,
    required this.totalPrice,
    required this.paymentMethod,
    this.cardNumber,
    this.status = 'completed',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movie': movie.toJson(),
      'schedule': schedule.toJson(),
      'buyerName': buyerName,
      'quantity': quantity,
      'purchaseDate': purchaseDate,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'cardNumber': cardNumber,
      'status': status,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      movie: Movie.fromJson(json['movie']),
      schedule: MovieSchedule.fromJson(json['schedule']),
      buyerName: json['buyerName'],
      quantity: json['quantity'],
      purchaseDate: json['purchaseDate'],
      totalPrice: json['totalPrice'],
      paymentMethod: json['paymentMethod'],
      cardNumber: json['cardNumber'],
      status: json['status'] ?? 'completed',
    );
  }

  String get maskedCardNumber {
    if (cardNumber == null || cardNumber!.length < 4) return '';
    return '**** **** **** ${cardNumber!.substring(cardNumber!.length - 4)}';
  }
}
