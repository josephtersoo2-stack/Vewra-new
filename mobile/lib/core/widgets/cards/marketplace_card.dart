import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../constants/app_constants.dart';
import 'app_card.dart';

/// Reusable Marketplace Card displaying product info, coin/fiat pricing, category, and redemption CTA.
class MarketplaceCard extends StatelessWidget {
  final String title;
  final String providerOrSeller;
  final String category;
  final int priceCoins;
  final double priceFiat;
  final String description;
  final String? discountTag;
  final VoidCallback? onBuy;

  const MarketplaceCard({
    super.key,
    required this.title,
    required this.providerOrSeller,
    required this.category,
    required this.priceCoins,
    required this.priceFiat,
    required this.description,
    this.discountTag,
    this.onBuy,
  });

  IconData get _categoryIcon {
    switch (category) {
      case 'Airtime & Data':
        return Icons.signal_cellular_alt_rounded;
      case 'Gift Cards':
        return Icons.card_giftcard_rounded;
      case 'Digital Products':
        return Icons.auto_awesome_rounded;
      case 'Coin Marketplace':
        return Icons.currency_exchange_rounded;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.standard,
      padding: const EdgeInsets.all(AppConstants.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category Icon, Provider, & Discount Tag
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.space8),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_categoryIcon, size: 18, color: AppColors.cyan),
              ),
              const SizedBox(width: AppConstants.space10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerOrSeller,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (discountTag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.18),
                    borderRadius: AppConstants.borderRadiusSm,
                  ),
                  child: Text(
                    discountTag!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.amber,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppConstants.space12),

          // Product Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppConstants.space12),

          // Footer: Price & Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monetization_on_rounded, size: 16, color: AppColors.amber),
                      const SizedBox(width: AppConstants.space4),
                      Text(
                        '$priceCoins Coins',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.amber,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '(\$${priceFiat.toStringAsFixed(2)})',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.space16,
                    vertical: AppConstants.space8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppConstants.borderRadiusMd,
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Redeem',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
