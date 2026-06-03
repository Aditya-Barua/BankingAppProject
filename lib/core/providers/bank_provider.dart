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

  String? _transactionError;
  String? get transactionError => _transactionError;

  Future<void> fetchTransactions(String userId) async {
    _transactionError = null;
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(50)
          .get();

      _recentTransactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      _transactionError = e.toString();

      // Fallback: try fetching without ordering if it's an index error
      if (e.toString().contains('failed-precondition') ||
          e.toString().contains('index')) {
        try {
          final fallbackSnapshot = await _firestore
              .collection('transactions')
              .where('userId', isEqualTo: userId)
              .limit(50)
              .get();

          _recentTransactions = fallbackSnapshot.docs
              .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
              .toList();

          // Sort locally as a fallback
          _recentTransactions.sort((a, b) => b.date.compareTo(a.date));
          notifyListeners();
        } catch (fallbackError) {
          debugPrint('Fallback fetch failed: $fallbackError');
        }
      } else {
        notifyListeners();
      }
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
      // 1. Find the recipient user by account number
      final recipientQuery = await _firestore
          .collection('users')
          .where('accountNumber', isEqualTo: toAccountNumber)
          .limit(1)
          .get();

      if (recipientQuery.docs.isEmpty) {
        throw Exception('Recipient account not found');
      }

      final recipientDoc = recipientQuery.docs.first;
      final recipientId = recipientDoc.id;
      final recipientData = recipientDoc.data();

      if (recipientId == fromUserId) {
        throw Exception('Cannot transfer to your own account');
      }

      // 2. Perform Firestore Transaction
      await _firestore.runTransaction((transaction) async {
        // Get fresh copies of both user documents
        final senderRef = _firestore.collection('users').doc(fromUserId);
        final recipientRef = _firestore.collection('users').doc(recipientId);

        final senderSnap = await transaction.get(senderRef);
        final recipientSnap = await transaction.get(recipientRef);

        if (!senderSnap.exists) throw Exception('Sender account not found');
        if (!recipientSnap.exists)
          throw Exception('Recipient account not found');

        final double currentSenderBalance =
            (senderSnap.data()?['balance'] ?? 0.0).toDouble();
        final double currentRecipientBalance =
            (recipientSnap.data()?['balance'] ?? 0.0).toDouble();

        if (currentSenderBalance < amount) {
          throw Exception('Insufficient funds');
        }

        // 3. Update balances
        transaction.update(senderRef, {
          'balance': currentSenderBalance - amount,
        });
        transaction.update(recipientRef, {
          'balance': currentRecipientBalance + amount,
        });

        // 4. Record Debit Transaction (for sender)
        final senderTransactionRef = _firestore
            .collection('transactions')
            .doc();
        transaction.set(senderTransactionRef, {
          'userId': fromUserId,
          'type': 'debit',
          'category': 'transfer',
          'amount': amount,
          'description': 'Transfer to $toAccountNumber: $description',
          'date': FieldValue.serverTimestamp(),
          'status': 'completed',
        });

        // 5. Record Credit Transaction (for recipient)
        final recipientTransactionRef = _firestore
            .collection('transactions')
            .doc();
        transaction.set(recipientTransactionRef, {
          'userId': recipientId,
          'type': 'credit',
          'category': 'transfer',
          'amount': amount,
          'description':
              'Received from ${_currentUser?.fullName ?? "Unknown"}: $description',
          'date': FieldValue.serverTimestamp(),
          'status': 'completed',
        });
      });

      // 6. Update local state
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          balance: _currentUser!.balance - amount,
        );
      }

      // Refresh transactions
      await fetchTransactions(fromUserId);
    } catch (e) {
      debugPrint('Transfer error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
