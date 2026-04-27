import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

class BankProvider with ChangeNotifier {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = false;
  final bool _isMockMode = true;

  UserModel? get currentUser => _currentUser;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  bool get isLoading => _isLoading;

  Future<void> fetchUserData(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_isMockMode) {
        await Future.delayed(const Duration(seconds: 1));
        _currentUser = UserModel(
          id: userId,
          email: 'user@example.com',
          fullName: 'John Doe',
          balance: 12450.00,
          accountNumber: '1234567890',
        );
      } else {
        // final doc = await _firestore.collection('users').doc(userId).get();
        // if (doc.exists) {
        //   _currentUser = UserModel.fromMap(doc.data()!, doc.id);
        // }
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTransactions(String userId) async {
    try {
      if (_isMockMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        _recentTransactions = [
          TransactionModel(
            id: '1',
            type: 'debit',
            category: 'shopping',
            amount: 45.00,
            description: 'Grocery Store',
            date: DateTime.now(),
            status: 'completed',
          ),
          TransactionModel(
            id: '2',
            type: 'credit',
            category: 'transfer',
            amount: 150.00,
            description: 'Salary Deposit',
            date: DateTime.now().subtract(const Duration(days: 1)),
            status: 'completed',
          ),
        ];
      } else {
        // final snapshot = await _firestore...
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> transferFunds({
    required String fromUserId,
    required String toAccountNumber,
    required double amount,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_isMockMode) {
        await Future.delayed(const Duration(seconds: 2));
        // Mock successful transfer
        if (_currentUser != null) {
          _currentUser = UserModel(
            id: _currentUser!.id,
            email: _currentUser!.email,
            fullName: _currentUser!.fullName,
            balance: _currentUser!.balance - amount,
            accountNumber: _currentUser!.accountNumber,
          );
        }
      } else {
        // Real implementation...
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
