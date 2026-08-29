import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/layout/app_scaffold.dart';
import '../../../core/widgets/layout/app_header.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../models/campaign_model.dart';
import '../providers/campaign_provider.dart';

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
  bool _isLoadingAction = false;

  @override
  void initState() {
    super.initState();
    _campaign = widget.initialCampaign ??
        CampaignModel(
          id: widget.campaignId ?? '',
          title: 'Loading Campaign...',
          campaignType: 'TASK',
          status: 'DRAFT',
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

  Future<void> _handleSubmitForReview() async {
    setState(() => _isLoadingAction = true);
    final success = await ref
        .read(campaignListProvider.notifier)
        .submitForReview(_campaign.id);
    if (!mounted) return;
    setState(() => _isLoadingAction = false);

    if (success) {
      setState(() {
        _campaign = _campaign.copyWith(
          status: 'PENDING_REVIEW',
          statusDisplay: 'Pending Review',
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Campaign submitted for administrative review!'),
          backgroundColor: AppColors.emerald,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit campaign for review.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handlePause() async {
    setState(() => _isLoadingAction = true);
    final success =
        await ref.read(campaignListProvider.notifier).pauseCampaign(_campaign.id);
    if (!mounted) return;
    setState(() => _isLoadingAction = false);

    if (success) {
      setState(() {
        _campaign = _campaign.copyWith(
          status: 'PAUSED',
          statusDisplay: 'Paused',
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Campaign has been paused.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_campaign.status);

    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: 'Campaign Details',
              subtitle: 'Unified Campaign Specification',
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

                  // Metrics & Financial Breakdown
                  AppCard(
                    padding: const EdgeInsets.all(AppConstants.space20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget & Timeline',
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
                                'Allocated Budget',
                                '\$${_campaign.budget.toStringAsFixed(2)}',
                                Icons.attach_money_rounded,
                              ),
                            ),
                            const SizedBox(width: AppConstants.space12),
                            Expanded(
                              child: _buildMetricTile(
                                'Campaign Status',
                                _campaign.statusDisplay,
                                Icons.info_outline_rounded,
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
                        if (_campaign.createdAt.isNotEmpty)
                          _buildInfoRow('Created At', _campaign.createdAt),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.space24),

                  // Action Buttons
                  if (_campaign.isDraft) ...[
                    AppButton(
                      text: 'Submit for Admin Review',
                      isLoading: _isLoadingAction,
                      onPressed: _handleSubmitForReview,
                    ),
                  ] else if (_campaign.isActive) ...[
                    AppButton(
                      text: 'Pause Campaign',
                      variant: AppButtonVariant.outlined,
                      isLoading: _isLoadingAction,
                      onPressed: _handlePause,
                    ),
                  ] else if (_campaign.isPendingReview) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.space16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              color: AppColors.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This campaign is under administrative review. Once approved, it will become Active.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.warning,
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
