import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/providers/bank_provider.dart';
import '../../core/constants/colors.dart';
import '../../core/models/models.dart';
import '../../services/auth/auth_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _refreshTransactions();
  }

  Future<void> _refreshTransactions() async {
    final authService = context.read<AuthService>();
    final bankProvider = context.read<BankProvider>();
    if (authService.isAuthenticated) {
      await bankProvider.fetchTransactions(authService.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BankProvider>();
    final transactions = provider.recentTransactions;
    final error = provider.transactionError;

    final filteredTransactions = _filter == 'All'
        ? transactions
        : transactions.where((t) => t.type.toLowerCase() == _filter.toLowerCase()).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: RefreshIndicator(
        onRefresh: _refreshTransactions,
        child: Column(
          children: [
            if (error != null && error.contains('https://console.firebase.google.com'))
              _buildIndexError(error),
            _buildFilters(),
            Expanded(
              child: filteredTransactions.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredTransactions.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, index) {
                        final tx = filteredTransactions[index];
                        return _buildTransactionItem(tx);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndexError(String error) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Action Required', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Firebase requires a composite index for this query. Please check your debug console or Firebase console to create it.'),
          const SizedBox(height: 4),
          SelectableText(
            error.substring(error.indexOf('https://')),
            style: const TextStyle(fontSize: 10, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView( // Use ListView so RefreshIndicator works
      children: const [
        SizedBox(height: 100),
        Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No transactions found', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: ['All', 'Credit', 'Debit'].map((f) {
          final isSelected = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _filter = f);
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    final isCredit = tx.type == 'credit';
    final format = DateFormat('MMM dd, yyyy');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.background,
        child: Icon(
          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
          color: isCredit ? AppColors.success : AppColors.error,
        ),
      ),
      title: Text(tx.description),
      subtitle: Text(format.format(tx.date)),
      trailing: Text(
        '${isCredit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isCredit ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }
}
