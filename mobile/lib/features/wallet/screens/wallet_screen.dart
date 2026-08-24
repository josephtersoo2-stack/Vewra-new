import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../services/dummy_data_service.dart';
import '../../../models/transaction_model.dart';
import '../../../core/widgets/feedback/app_empty_state.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/transaction_item.dart';

/// Wallet & Earnings screen with balance breakdown and transaction history.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Earnings, 2: Withdrawals

  List<TransactionModel> get _filteredTransactions {
    final list = DummyDataService.transactions;
    if (_selectedFilterIndex == 1) {
      return list.where((t) => t.isPositive).toList();
    } else if (_selectedFilterIndex == 2) {
      return list.where((t) => !t.isPositive).toList();
    }
    return list;
  }

  void _showWithdrawModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppConstants.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Withdraw Funds',
                  style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.space16),
            Text(
              'Select preferred withdrawal method for your balance of \$34.50 (3,450 Coins):',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppConstants.space20),
            _buildPayoutOption(Icons.paypal, 'PayPal Instant Transfer', 'Min. \$10.00 (1,000 Coins)'),
            const SizedBox(height: AppConstants.space12),
            _buildPayoutOption(Icons.account_balance_rounded, 'Direct Bank Wire (ACH)', 'Min. \$25.00 (2,500 Coins)'),
            const SizedBox(height: AppConstants.space12),
            _buildPayoutOption(Icons.card_giftcard_rounded, 'Amazon E-Gift Card', 'Min. \$5.00 (500 Coins)'),
            const SizedBox(height: AppConstants.space24),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutOption(IconData icon, String name, String sub) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppConstants.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryLight, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.titleSmall),
                Text(sub, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = DummyDataService.currentWallet;
    final transactions = _filteredTransactions;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.space12),
          Text(
            AppStrings.wallet,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppConstants.space16),
          // Hero Balance Card
          WalletBalanceCard(
            wallet: wallet,
            onWithdraw: _showWithdrawModal,
            onConvert: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coins are automatically calculated at 100 Coins = \$1.00 USD')),
              );
            },
          ),
          const SizedBox(height: AppConstants.space24),
          // Transaction History Header & Filter Tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.transactionHistory,
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.space12),
          // Filter Chips
          Row(
            children: [
              _buildFilterTab(0, 'All'),
              const SizedBox(width: 8),
              _buildFilterTab(1, 'Earnings'),
              const SizedBox(width: 8),
              _buildFilterTab(2, 'Withdrawals'),
            ],
          ),
          const SizedBox(height: AppConstants.space16),
          // Transactions List
          transactions.isEmpty
              ? const AppEmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: AppStrings.noTransactions,
                  description: AppStrings.noTransactionsDesc,
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppConstants.space10),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return TransactionItem(transaction: tx);
                  },
                ),
          const SizedBox(height: AppConstants.space32),
        ],
      ),
    );
  }

  Widget _buildFilterTab(int index, String title) {
    final bool isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(title),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilterIndex = index);
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      side: BorderSide(
        color: isSelected ? AppColors.primaryLight : AppColors.border,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppConstants.borderRadiusFull,
      ),
      showCheckmark: false,
    );
  }
}
