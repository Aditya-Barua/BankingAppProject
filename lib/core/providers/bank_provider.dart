import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

class BankProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  bool get isLoading => _isLoading;

  Future<void> fetchUserData(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTransactions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(10)
          .get();

      _recentTransactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
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
      // In a real app, this would be a Firestore Transaction or Cloud Function
      // to ensure atomicity. For now, we update the local user balance.

      // Update local state for demo purposes
      if (_currentUser != null) {
        final newBalance = _currentUser!.balance - amount;

        await _firestore.collection('users').doc(fromUserId).update({
          'balance': newBalance,
        });

        // Record the transaction
        await _firestore.collection('transactions').add({
          'userId': fromUserId,
          'type': 'debit',
          'amount': amount,
          'description': 'Transfer to $toAccountNumber: $description',
          'date': FieldValue.serverTimestamp(),
          'status': 'completed',
        });

        _currentUser = UserModel(
          id: _currentUser!.id,
          email: _currentUser!.email,
          fullName: _currentUser!.fullName,
          balance: newBalance,
          accountNumber: _currentUser!.accountNumber,
        );
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
