import '../models/user.dart';
import '../models/transaction.dart';
import 'database_helper.dart';

class StorageService {
  final _dbHelper = DatabaseHelper();

  Future<void> registerUser(User user) async {
    await _dbHelper.registerUser(user);
  }

  Future<List<User>> getUsers() async {
    return await _dbHelper.getUsers();
  }

  Future<bool> isEmailExists(String email) async {
    return await _dbHelper.isEmailExists(email);
  }

  Future<bool> isUsernameExists(String username) async {
    return await _dbHelper.isUsernameExists(username);
  }

  Future<User?> login(String identifier, String password) async {
    return await _dbHelper.login(identifier, password);
  }

  Future<void> setCurrentUser(User user) async {}

  Future<User?> getCurrentUser() async {
    return await _dbHelper.getCurrentUser();
  }

  Future<void> logout() async {
    await _dbHelper.logout();
  }

  Future<void> saveTransaction(Transaction transaction) async {
    await _dbHelper.saveTransaction(transaction);
  }

  Future<List<Transaction>> getTransactions() async {
    return await _dbHelper.getTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _dbHelper.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _dbHelper.deleteTransaction(transactionId);
  }

  Future<List<Transaction>> getActiveTransactions() async {
    return await _dbHelper.getActiveTransactions();
  }

  Future<List<Transaction>> getUserTransactions(String userName) async {
    return await _dbHelper.getUserTransactions(userName);
  }
}
