import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/transaction.dart' as model;
import '../models/movie.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cinema_ticket.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        address TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        movieData TEXT NOT NULL,
        scheduleData TEXT NOT NULL,
        buyerName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        purchaseDate TEXT NOT NULL,
        totalPrice REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        cardNumber TEXT,
        status TEXT NOT NULL
      )
    ''');
  }

  Future<int> registerUser(User user) async {
    final db = await database;
    return await db.insert('users', {
      'fullName': user.fullName,
      'email': user.email,
      'address': user.address,
      'phoneNumber': user.phoneNumber,
      'username': user.username,
      'password': user.password,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User(
        fullName: maps[i]['fullName'],
        email: maps[i]['email'],
        address: maps[i]['address'],
        phoneNumber: maps[i]['phoneNumber'],
        username: maps[i]['username'],
        password: maps[i]['password'],
      );
    });
  }

  Future<bool> isEmailExists(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.toLowerCase()],
    );
    return result.isNotEmpty;
  }

  Future<bool> isUsernameExists(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'LOWER(username) = ?',
      whereArgs: [username.toLowerCase()],
    );
    return result.isNotEmpty;
  }

  Future<User?> login(String identifier, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: '(LOWER(email) = ? OR LOWER(username) = ?) AND password = ?',
      whereArgs: [identifier.toLowerCase(), identifier.toLowerCase(), password],
    );

    if (result.isNotEmpty) {
      final user = User(
        fullName: result[0]['fullName'],
        email: result[0]['email'],
        address: result[0]['address'],
        phoneNumber: result[0]['phoneNumber'],
        username: result[0]['username'],
        password: result[0]['password'],
      );
      await setCurrentUser(result[0]['id']);
      return user;
    }
    return null;
  }

  Future<void> setCurrentUser(int userId) async {
    final db = await database;
    await db.delete('sessions');
    await db.insert('sessions', {'userId': userId});
  }

  Future<User?> getCurrentUser() async {
    final db = await database;
    final List<Map<String, dynamic>> sessions = await db.query('sessions');

    if (sessions.isEmpty) return null;

    final userId = sessions[0]['userId'];
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (users.isEmpty) return null;

    return User(
      fullName: users[0]['fullName'],
      email: users[0]['email'],
      address: users[0]['address'],
      phoneNumber: users[0]['phoneNumber'],
      username: users[0]['username'],
      password: users[0]['password'],
    );
  }

  Future<void> logout() async {
    final db = await database;
    await db.delete('sessions');
  }

  Future<void> saveTransaction(model.Transaction transaction) async {
    final db = await database;
    await db.insert('transactions', {
      'id': transaction.id,
      'movieData': jsonEncode(transaction.movie.toJson()),
      'scheduleData': jsonEncode(transaction.schedule.toJson()),
      'buyerName': transaction.buyerName,
      'quantity': transaction.quantity,
      'purchaseDate': transaction.purchaseDate,
      'totalPrice': transaction.totalPrice,
      'paymentMethod': transaction.paymentMethod,
      'cardNumber': transaction.cardNumber,
      'status': transaction.status,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<model.Transaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');

    return List<model.Transaction>.generate(maps.length, (i) {
      return model.Transaction(
        id: maps[i]['id'],
        movie: Movie.fromJson(jsonDecode(maps[i]['movieData'])),
        schedule: MovieSchedule.fromJson(jsonDecode(maps[i]['scheduleData'])),
        buyerName: maps[i]['buyerName'],
        quantity: maps[i]['quantity'],
        purchaseDate: maps[i]['purchaseDate'],
        totalPrice: maps[i]['totalPrice'],
        paymentMethod: maps[i]['paymentMethod'],
        cardNumber: maps[i]['cardNumber'],
        status: maps[i]['status'],
      );
    });
  }

  Future<void> updateTransaction(model.Transaction transaction) async {
    final db = await database;
    await db.update(
      'transactions',
      {
        'movieData': jsonEncode(transaction.movie.toJson()),
        'scheduleData': jsonEncode(transaction.schedule.toJson()),
        'buyerName': transaction.buyerName,
        'quantity': transaction.quantity,
        'purchaseDate': transaction.purchaseDate,
        'totalPrice': transaction.totalPrice,
        'paymentMethod': transaction.paymentMethod,
        'cardNumber': transaction.cardNumber,
        'status': transaction.status,
      },
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(String transactionId) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [transactionId],
    );
  }

  Future<List<model.Transaction>> getActiveTransactions() async {
    final transactions = await getTransactions();
    return transactions.where((t) => t.status == 'completed').toList();
  }

  Future<List<model.Transaction>> getUserTransactions(String userName) async {
    final transactions = await getTransactions();
    return transactions
        .where((t) => t.status == 'completed' && t.buyerName == userName)
        .toList();
  }
}
