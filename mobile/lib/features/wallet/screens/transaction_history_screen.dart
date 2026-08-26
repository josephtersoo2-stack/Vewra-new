import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/feedback/app_empty_state.dart';
import '../../../models/transaction_model.dart';
import '../providers/wallet_provider.dart';
import '../widgets/transaction_item.dart';

/// Dedicated Full Transaction History Screen with filtering by All, Rewards, Withdrawals, Transfers.
class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Earnings, 2: Withdrawals, 3: Transfers

  List<TransactionModel> _filterTransactions(List<TransactionModel> list) {
    if (_selectedFilterIndex == 1) {
      return list.where((t) => t.isPositive).toList();
    } else if (_selectedFilterIndex == 2) {
      return list.where((t) => t.type == TransactionType.withdrawal || !t.isPositive).toList();
    } else if (_selectedFilterIndex == 3) {
      return list.where((t) => t.type == TransactionType.transfer).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final filtered = _filterTransactions(walletState.transactions);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction Ledger'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(walletProvider.notifier).loadWalletData(forceRefresh: true),
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.space16),
          children: [
            // Filter Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(0, 'All Activity'),
                  const SizedBox(width: 8),
                  _buildFilterChip(1, 'Rewards & Earnings'),
                  const SizedBox(width: 8),
                  _buildFilterChip(2, 'Payouts & Withdrawals'),
                  const SizedBox(width: 8),
                  _buildFilterChip(3, 'P2P Transfers'),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.space16),

            // Transactions Output
            if (walletState.isLoading && walletState.transactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (filtered.isEmpty)
              const AppEmptyState(
                icon: Icons.receipt_long_rounded,
                title: AppStrings.noTransactions,
                description: AppStrings.noTransactionsDesc,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppConstants.space10),
                itemBuilder: (context, index) {
                  return TransactionItem(transaction: filtered[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String title) {
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
