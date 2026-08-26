import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../../../models/transaction_model.dart';
import '../../../core/widgets/feedback/app_empty_state.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../providers/wallet_provider.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/transaction_item.dart';
import 'withdraw_screen.dart';
import 'transaction_history_screen.dart';

/// Wallet & Earnings screen with live balances from walletProvider, trade shortcuts, pending rewards, and real-time transaction ledger.
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Earnings, 2: Withdrawals

  List<TransactionModel> _getFilteredTransactions(List<TransactionModel> list) {
    if (_selectedFilterIndex == 1) {
      return list.where((t) => t.isPositive).toList();
    } else if (_selectedFilterIndex == 2) {
      return list.where((t) => t.type == TransactionType.withdrawal || !t.isPositive).toList();
    }
    return list;
  }

  void _showTradeModal(bool isBuy) {
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
                  isBuy ? 'Buy VEWRA Coins' : 'Sell VEWRA Coins (P2P)',
                  style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.space12),
            Text(
              isBuy
                  ? 'Purchase coins securely using Debit/Credit, Apple Pay, or Crypto.'
                  : 'Sell coins directly on the verified P2P Escrow Marketplace.',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppConstants.space20),
            Container(
              padding: const EdgeInsets.all(AppConstants.space16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppConstants.borderRadiusMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBuy ? 'Quick Bundle: 1,000 Coins' : 'Trade Offer: 2,500 Coins',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  Text(
                    isBuy ? '\$10.00 USD' : '\$24.50 USDT',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.amber),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.space20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.marketplace);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.space12),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppConstants.borderRadiusMd,
                  ),
                ),
                child: Text(isBuy ? 'Explore Coin Packages' : 'Open P2P Marketplace'),
              ),
            ),
            const SizedBox(height: AppConstants.space16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final wallet = walletState.wallet;
    final transactions = _getFilteredTransactions(walletState.transactions);

    return RefreshIndicator(
      onRefresh: () => ref.read(walletProvider.notifier).loadWalletData(forceRefresh: true),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.space12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.wallet,
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (walletState.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.space16),

            // 1. Hero Balance Card
            WalletBalanceCard(
              wallet: wallet,
              onWithdraw: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WithdrawScreen()),
                );
              },
              onConvert: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coins are automatically calculated at 100 Coins = \$1.00 USD')),
                );
              },
            ),

            const SizedBox(height: AppConstants.space16),

            // 2. Quick Action Grid: Buy Coins, Sell Coins, Marketplace, Withdraw
            Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    title: 'Buy Coins',
                    icon: Icons.add_circle_outline_rounded,
                    iconColor: AppColors.emerald,
                    onTap: () => _showTradeModal(true),
                  ),
                ),
                const SizedBox(width: AppConstants.space8),
                Expanded(
                  child: _buildActionBtn(
                    title: 'Sell Coins',
                    icon: Icons.currency_exchange_rounded,
                    iconColor: AppColors.amber,
                    onTap: () => _showTradeModal(false),
                  ),
                ),
                const SizedBox(width: AppConstants.space8),
                Expanded(
                  child: _buildActionBtn(
                    title: 'Withdraw',
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: AppColors.primaryLight,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WithdrawScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.space8),
                Expanded(
                  child: _buildActionBtn(
                    title: 'Shop',
                    icon: Icons.storefront_rounded,
                    iconColor: AppColors.cyan,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.marketplace),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.space16),

            // 3. Pending Rewards Breakdown
            AppCard(
              variant: AppCardVariant.standard,
              padding: const EdgeInsets.all(AppConstants.space14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.space8),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hourglass_top_rounded, size: 20, color: AppColors.amber),
                  ),
                  const SizedBox(width: AppConstants.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pending Watch Rewards: ${wallet.pendingCoins} Coins',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Text(
                          'Auto-unlocks in 24 hours after watch verification.',
                          style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '(\$${wallet.pendingFiat.toStringAsFixed(2)})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.amber,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.space24),

            // 4. Transaction History Header & View All
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.transactionHistory,
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()),
                    );
                  },
                  child: const Text('View Ledger', style: TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.space8),

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
                    itemCount: transactions.take(10).length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppConstants.space10),
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return TransactionItem(transaction: tx);
                    },
                  ),
            const SizedBox(height: AppConstants.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppConstants.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.space10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppConstants.borderRadiusMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(height: AppConstants.space4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
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
