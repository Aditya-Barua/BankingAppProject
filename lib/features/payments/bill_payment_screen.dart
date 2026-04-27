import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class BillPaymentScreen extends StatelessWidget {
  const BillPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bills = [
      {'name': 'Electricity', 'icon': Icons.electric_bolt, 'amount': 85.50},
      {'name': 'Water', 'icon': Icons.water_drop, 'amount': 32.20},
      {'name': 'Internet', 'icon': Icons.wifi, 'amount': 60.00},
      {'name': 'Phone', 'icon': Icons.phone_android, 'amount': 45.00},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Pay Bills')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bills.length,
        itemBuilder: (context, index) {
          final bill = bills[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.background,
                child: Icon(bill['icon'] as IconData, color: AppColors.primary),
              ),
              title: Text(bill['name'] as String),
              subtitle: Text(
                'Due: \$${(bill['amount'] as double).toStringAsFixed(2)}',
              ),
              trailing: ElevatedButton(
                onPressed: () =>
                    _showPaymentDialog(context, bill['name'] as String),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Pay'),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, String billName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pay $billName'),
        content: const Text('Confirm payment of this bill?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$billName paid successfully!')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
