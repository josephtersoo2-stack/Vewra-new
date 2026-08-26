import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../providers/wallet_provider.dart';

/// Dedicated Withdrawal Screen with multiple payout channels, fee estimates, and real-time submission.
class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _destinationController = TextEditingController();

  String _selectedMethod = 'USDT';

  final List<Map<String, dynamic>> _methods = [
    {
      'id': 'USDT',
      'name': 'USDT (TRC-20 / BEP-20)',
      'fee': '0% Network Fee',
      'min': 5.00,
      'icon': Icons.currency_bitcoin_rounded,
      'hint': 'Enter TRC-20 or BEP-20 Wallet Address',
    },
    {
      'id': 'PAYPAL',
      'name': 'PayPal Account',
      'fee': '2% Processing Fee',
      'min': 10.00,
      'icon': Icons.paypal_rounded,
      'hint': 'Enter your registered PayPal email address',
    },
    {
      'id': 'BANK',
      'name': 'Direct Bank Wire (SWIFT / IBAN)',
      'fee': '\$2.00 Fixed Flat Fee',
      'min': 25.00,
      'icon': Icons.account_balance_rounded,
      'hint': 'Enter IBAN / Account Number + Routing / SWIFT',
    },
    {
      'id': 'GIFTCARD',
      'name': 'Digital E-Gift Card (Amazon / Apple)',
      'fee': '0% Instant Code Delivery',
      'min': 5.00,
      'icon': Icons.card_giftcard_rounded,
      'hint': 'Enter destination delivery email address',
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _setPercentage(double fraction, double balance) {
    final target = (balance * fraction);
    _amountController.text = target.toStringAsFixed(2);
  }

  Future<void> _handleWithdraw(double balance) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final destination = _destinationController.text.trim();

    final success = await ref.read(walletProvider.notifier).submitWithdrawal(
      amount: amount,
      method: _selectedMethod,
      destination: destination,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal request submitted and queued for review!'),
          backgroundColor: AppColors.emerald,
        ),
      );
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else {
      final error = ref.read(walletProvider).errorMessage ?? 'Withdrawal failed.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final wallet = walletState.wallet;
    final selectedMethodData = _methods.firstWhere((m) => m['id'] == _selectedMethod);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Withdraw Funds'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.space16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Available Balance Card
              AppCard(
                variant: AppCardVariant.elevated,
                padding: const EdgeInsets.all(AppConstants.space16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available Balance', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          '\$${wallet.balanceFiat.toStringAsFixed(2)} ${wallet.currency}',
                          style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.emerald),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withValues(alpha: 0.15),
                        borderRadius: AppConstants.borderRadiusFull,
                      ),
                      child: Text(
                        '${wallet.balanceCoins} Coins',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.amber, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.space20),
              Text('Select Payout Method', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppConstants.space10),

              // Payout Methods Selection
              ...List.generate(_methods.length, (index) {
                final method = _methods[index];
                final isSelected = _selectedMethod == method['id'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.space8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedMethod = method['id'] as String),
                    borderRadius: AppConstants.borderRadiusMd,
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.space12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surface,
                        borderRadius: AppConstants.borderRadiusMd,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(method['icon'] as IconData, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(method['name'] as String, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                                Text(
                                  '${method['fee']} • Min \$${(method['min'] as double).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: 2,
                              ),
                              color: isSelected ? AppColors.primary : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Center(
                                    child: Icon(Icons.circle, size: 8, color: Colors.white),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: AppConstants.space16),
              Text('Withdrawal Amount (\$ USD)', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppConstants.space8),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  hintText: '0.00',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: AppConstants.borderRadiusMd,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                validator: (val) {
                  final parsed = double.tryParse(val?.trim() ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid amount';
                  }
                  final minAmount = selectedMethodData['min'] as double;
                  if (parsed < minAmount) {
                    return 'Minimum withdrawal for $_selectedMethod is \$${minAmount.toStringAsFixed(2)}';
                  }
                  if (parsed > wallet.balanceFiat) {
                    return 'Amount exceeds available balance (\$${wallet.balanceFiat.toStringAsFixed(2)})';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppConstants.space8),
              // Percentage Quick Fill Buttons
              Row(
                children: [
                  _buildFractionButton('25%', 0.25, wallet.balanceFiat),
                  const SizedBox(width: 8),
                  _buildFractionButton('50%', 0.50, wallet.balanceFiat),
                  const SizedBox(width: 8),
                  _buildFractionButton('75%', 0.75, wallet.balanceFiat),
                  const SizedBox(width: 8),
                  _buildFractionButton('MAX', 1.00, wallet.balanceFiat),
                ],
              ),

              const SizedBox(height: AppConstants.space20),
              Text('Destination Payout Details', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppConstants.space8),

              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
                  hintText: selectedMethodData['hint'] as String,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: AppConstants.borderRadiusMd,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Destination address or account is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppConstants.space24),

              // Submit Button
              AppButton(
                text: 'Confirm & Submit Payout',
                isLoading: walletState.isSubmitting,
                onPressed: () => _handleWithdraw(wallet.balanceFiat),
              ),
              const SizedBox(height: AppConstants.space24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFractionButton(String label, double fraction, double balance) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _setPercentage(fraction, balance),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: AppConstants.borderRadiusSm),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
