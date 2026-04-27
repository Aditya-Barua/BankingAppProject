class UserModel {
  final String id;
  final String email;
  final String fullName;
  final double balance;
  final String accountNumber;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.balance,
    required this.accountNumber,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      balance: (data['balance'] ?? 0.0).toDouble(),
      accountNumber: data['accountNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'balance': balance,
      'accountNumber': accountNumber,
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

  factory TransactionModel.fromMap(Map<String, dynamic> data, String documentId) {
    return TransactionModel(
      id: documentId,
      type: data['type'] ?? 'debit',
      category: data['category'] ?? 'transfer',
      amount: (data['amount'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      status: data['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}
