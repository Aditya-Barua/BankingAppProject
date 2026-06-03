import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth/auth_service.dart';
import '../../core/constants/colors.dart';

import '../transfer/transfer_screen.dart';
import '../payments/bill_payment_screen.dart';
import '../payments/check_deposit_screen.dart';
import '../transactions/transactions_screen.dart';
import '../settings/atm_locator_screen.dart';
import '../profile/profile_screen.dart';

import '../../core/providers/bank_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = context.read<AuthService>();
      final bankProvider = context.read<BankProvider>();
      if (authService.isAuthenticated) {
        final userId = authService.user!.uid;
        bankProvider.fetchUserData(userId);
        bankProvider.fetchTransactions(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SecureBank'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<BankProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () async {
              final authService = context.read<AuthService>();
              if (authService.isAuthenticated) {
                final userId = authService.user!.uid;
                await provider.fetchUserData(userId);
                await provider.fetchTransactions(userId);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(context, provider),
                  _buildBalanceCard(context, provider),
                  _buildQuickActions(context),
                  _buildRecentTransactions(context, provider),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransferScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TransactionHistoryScreen(),
              ),
            );
          } else if (index == 3) {
            // Settings or ATM Locator
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AtmLocatorScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transfer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'History',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'ATM'),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, BankProvider provider) {
    final user = provider.currentUser;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user != null ? 'Welcome, ${user.fullName}' : 'Welcome Back',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Check your account status today',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, BankProvider provider) {
    final user = provider.currentUser;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            user != null ? '\$${user.balance.toStringAsFixed(2)}' : '\$0.00',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                user != null
                    ? '**** **** **** ${user.accountNumber.substring(user.accountNumber.length - 4)}'
                    : '**** **** **** ****',
                style: const TextStyle(color: Colors.white70),
              ),
              const Icon(Icons.credit_card, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionItem(context, Icons.send, 'Transfer', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransferScreen()),
                );
              }),
              _buildActionItem(context, Icons.receipt, 'Bills', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BillPaymentScreen()),
                );
              }),
              _buildActionItem(context, Icons.camera_alt, 'Check', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckDepositScreen()),
                );
              }),
              _buildActionItem(context, Icons.more_horiz, 'More', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, BankProvider provider) {
    final transactions = provider.recentTransactions;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TransactionHistoryScreen(),
                    ),
                  );
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          transactions.isEmpty
              ? const Center(child: Text('No recent transactions'))
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length > 3 ? 3 : transactions.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isCredit = tx.type == 'credit';
                    
                    IconData icon;
                    if (isCredit) {
                      icon = Icons.arrow_downward;
                    } else if (tx.description.toLowerCase().contains('transfer')) {
                      icon = Icons.swap_horiz;
                    } else if (tx.description.toLowerCase().contains('bill')) {
                      icon = Icons.receipt;
                    } else {
                      icon = Icons.shopping_bag;
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.background,
                        child: Icon(
                          icon,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(tx.description),
                      subtitle: Text(tx.date.toString().substring(0, 10)),
                      trailing: Text(
                        '${isCredit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCredit ? AppColors.success : AppColors.error,
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
