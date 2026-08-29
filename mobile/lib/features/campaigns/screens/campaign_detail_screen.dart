import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/layout/app_scaffold.dart';
import '../../../core/widgets/layout/app_header.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../models/campaign_model.dart';

class CampaignDetailScreen extends ConsumerStatefulWidget {
  final CampaignModel? initialCampaign;
  final String? campaignId;

  const CampaignDetailScreen({
    super.key,
    this.initialCampaign,
    this.campaignId,
  });

  @override
  ConsumerState<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends ConsumerState<CampaignDetailScreen> {
  late CampaignModel _campaign;

  @override
  void initState() {
    super.initState();
    _campaign = widget.initialCampaign ??
        CampaignModel(
          id: widget.campaignId ?? '',
          title: 'Loading Campaign...',
          campaignType: 'TASK',
          status: 'ACTIVE',
          budget: 0.0,
        );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return AppColors.emerald;
      case 'PENDING_REVIEW':
        return AppColors.warning;
      case 'PAUSED':
        return AppColors.textSecondary;
      case 'REJECTED':
        return AppColors.error;
      case 'COMPLETED':
        return AppColors.primaryLight;
      case 'DRAFT':
      default:
        return AppColors.textTertiary;
    }
  }

  void _handleParticipate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ You are now participating in this campaign! Complete tasks to earn rewards.'),
        backgroundColor: AppColors.emerald,
      ),
    );
    Navigator.pushNamed(context, AppRoutes.tasks);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_campaign.status);

    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(
              title: 'Campaign Details',
              subtitle: 'Earn & Promotional Campaign',
              showBackButton: true,
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Status Card
                  AppCard(
                    padding: const EdgeInsets.all(AppConstants.space20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusSm),
                              ),
                              child: Text(
                                _campaign.campaignTypeDisplay,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusSm),
                                border: Border.all(
                                    color: statusColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                _campaign.statusDisplay,
                                style: AppTypography.labelSmall.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.space16),
                        Text(
                          _campaign.title,
                          style: AppTypography.headlineMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (_campaign.description.isNotEmpty) ...[
                          const SizedBox(height: AppConstants.space12),
                          Text(
                            _campaign.description,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.space16),

                  // Metrics & Timeline
                  AppCard(
                    padding: const EdgeInsets.all(AppConstants.space20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Campaign Overview',
                          style: AppTypography.headlineSmall.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppConstants.space16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricTile(
                                'Campaign Pool',
                                '\$${_campaign.budget.toStringAsFixed(2)}',
                                Icons.account_balance_wallet_outlined,
                              ),
                            ),
                            const SizedBox(width: AppConstants.space12),
                            Expanded(
                              child: _buildMetricTile(
                                'Status',
                                _campaign.statusDisplay,
                                Icons.check_circle_outline_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.space16),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: AppConstants.space12),
                        _buildInfoRow('Campaign ID', _campaign.id),
                        if (_campaign.startDate != null)
                          _buildInfoRow('Start Date', _campaign.startDate!),
                        if (_campaign.endDate != null)
                          _buildInfoRow('End Date', _campaign.endDate!),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.space24),

                  // Participate Action Button for Earn Users
                  if (_campaign.isActive) ...[
                    AppButton(
                      text: 'Participate in Campaign',
                      prefixIcon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 20),
                      onPressed: _handleParticipate,
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.space16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This campaign is ${_campaign.statusDisplay.toLowerCase()}. Participation is currently closed.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryLight),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
