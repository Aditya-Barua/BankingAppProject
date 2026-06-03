import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final double balance;
  final String accountNumber;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.balance,
    required this.accountNumber,
    this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    double? balance,
    String? accountNumber,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      balance: balance ?? this.balance,
      accountNumber: accountNumber ?? this.accountNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    DateTime? date;
    if (data['createdAt'] is Timestamp) {
      date = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      date = DateTime.tryParse(data['createdAt']);
    }

    return UserModel(
      id: documentId,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      balance: (data['balance'] ?? 0.0).toDouble(),
      accountNumber: data['accountNumber'] ?? '',
      createdAt: date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'balance': balance,
      'accountNumber': accountNumber,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}

class TransactionModel {
  final String id;
  final String type; // 'credit' or 'debit'
  final String category; // 'transfer', 'bill', 'deposit'
  final double amount;
  final String description;
  final DateTime date;
  final String status;

  TransactionModel({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    required this.status,
  });

  factory TransactionModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    DateTime date;
    if (data['date'] is Timestamp) {
      date = (data['date'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      date = DateTime.tryParse(data['date']) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }

    return TransactionModel(
      id: documentId,
      type: data['type'] ?? 'debit',
      category: data['category'] ?? 'transfer',
      amount: (data['amount'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      date: date,
      status: data['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'category': category,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'status': status,
    };
  }
}
