import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/layout/app_header.dart';
import '../../../core/widgets/cards/marketplace_card.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../services/dummy_data_service.dart';

/// Screen showcasing the digital & utility marketplace: Airtime, Data, Gift Cards, Digital Products, and P2P Coin Marketplace.
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Airtime & Data',
    'Gift Cards',
    'Digital Products',
    'Coin Marketplace',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredItems = _selectedCategory == 'All'
        ? DummyDataService.marketplaceItems
        : DummyDataService.marketplaceItems
            .where((item) => item.category == _selectedCategory)
            .toList();

    return Scaffold(
      appBar: const AppHeader(
        title: 'Digital Marketplace',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenPaddingH,
          vertical: AppConstants.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner: P2P Coin & Service Economy
            AppCard(
              variant: AppCardVariant.gradient,
              padding: const EdgeInsets.all(AppConstants.space16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.space10),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.storefront_rounded, size: 24, color: AppColors.cyan),
                  ),
                  const SizedBox(width: AppConstants.space12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spend & Trade Coins',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Redeem gift cards, mobile airtime, digital goods, or trade coins with verified users.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.space20),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final bool isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppConstants.space8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primaryLight,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppConstants.borderRadiusFull,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: AppConstants.space20),

            // Marketplace Item Listings
            Text(
              '$_selectedCategory Items (${filteredItems.length})',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppConstants.space12),

            ...filteredItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.space12),
                child: MarketplaceCard(
                  title: item.title,
                  providerOrSeller: item.providerOrSeller,
                  category: item.category,
                  priceCoins: item.priceCoins,
                  priceFiat: item.priceFiat,
                  description: item.description,
                  discountTag: item.discountTag,
                  onBuy: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primary,
                        content: Text('Selected: ${item.title} (Simulated Redemption)'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
