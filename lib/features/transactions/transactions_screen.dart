import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/providers/bank_provider.dart';
import '../../core/constants/colors.dart';
import '../../core/models/models.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<BankProvider>().recentTransactions;
    final filteredTransactions = _filter == 'All'
        ? transactions
        : transactions.where((t) => t.type.toLowerCase() == _filter.toLowerCase()).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: filteredTransactions.isEmpty
                ? const Center(child: Text('No transactions found'))
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
