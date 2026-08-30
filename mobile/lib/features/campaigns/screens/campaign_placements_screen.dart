import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ad_placement_model.dart';
import '../models/campaign_model.dart';
import '../providers/ad_placement_provider.dart';
import '../widgets/ad_placement_card.dart';

/// Screen allowing advertisers / managers to inspect and manage ad placements for a campaign.
class CampaignPlacementsScreen extends ConsumerStatefulWidget {
  final CampaignModel campaign;

  const CampaignPlacementsScreen({
    super.key,
    required this.campaign,
  });

  @override
  ConsumerState<CampaignPlacementsScreen> createState() =>
      _CampaignPlacementsScreenState();
}

class _CampaignPlacementsScreenState
    extends ConsumerState<CampaignPlacementsScreen> {
  String _selectedStatus = 'ALL';
  String _selectedType = 'ALL';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placementsAsync = ref.watch(campaignPlacementsProvider(widget.campaign.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.campaign.title} Placements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(campaignPlacementsProvider(widget.campaign.id).notifier)
                  .loadPlacements(
                    status: _selectedStatus == 'ALL' ? null : _selectedStatus,
                    type: _selectedType == 'ALL' ? null : _selectedType,
                  );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All Statuses', 'ALL', _selectedStatus, (val) {
                  setState(() => _selectedStatus = val);
                  _reload();
                }),
                _buildFilterChip('Active', 'ACTIVE', _selectedStatus, (val) {
                  setState(() => _selectedStatus = val);
                  _reload();
                }),
                _buildFilterChip('Paused', 'PAUSED', _selectedStatus, (val) {
                  setState(() => _selectedStatus = val);
                  _reload();
                }),
                _buildFilterChip('Draft', 'DRAFT', _selectedStatus, (val) {
                  setState(() => _selectedStatus = val);
                  _reload();
                }),
                _buildFilterChip('Disabled', 'DISABLED', _selectedStatus, (val) {
                  setState(() => _selectedStatus = val);
                  _reload();
                }),
                const SizedBox(width: 8),
                _buildFilterChip('All Locations', 'ALL', _selectedType, (val) {
                  setState(() => _selectedType = val);
                  _reload();
                }),
                _buildFilterChip('Home Feed', 'HOME_FEED', _selectedType, (val) {
                  setState(() => _selectedType = val);
                  _reload();
                }),
                _buildFilterChip('Header', 'HEADER', _selectedType, (val) {
                  setState(() => _selectedType = val);
                  _reload();
                }),
                _buildFilterChip('Popup', 'POPUP', _selectedType, (val) {
                  setState(() => _selectedType = val);
                  _reload();
                }),
              ],
            ),
          ),

          // Placements list
          Expanded(
            child: placementsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load placements: $err',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _reload,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (placements) {
                if (placements.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.campaign_outlined, size: 56, color: theme.disabledColor),
                          const SizedBox(height: 12),
                          Text(
                            'No advertisement placements found.',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Configure placements to serve your approved creative assets.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: placements.length,
                  itemBuilder: (context, index) {
                    final placement = placements[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdPlacementCard(
                          placement: placement,
                          onTap: () => _showPlacementDetails(placement),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Priority: P-${placement.priority}  •  ${placement.status}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  if (placement.isActive)
                                    TextButton.icon(
                                      icon: const Icon(Icons.pause_circle_outline, size: 16),
                                      label: const Text('Pause'),
                                      onPressed: () => _pausePlacement(placement.id),
                                    )
                                  else if (placement.isPaused || placement.isDraft)
                                    TextButton.icon(
                                      icon: const Icon(Icons.play_circle_outline, size: 16),
                                      label: const Text('Activate'),
                                      onPressed: () => _activatePlacement(placement.id),
                                    ),
                                  if (!placement.isDisabled)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                      onPressed: () => _disablePlacement(placement.id),
                                    )
                                  else
                                    IconButton(
                                      icon: const Icon(Icons.restore, size: 18, color: Colors.green),
                                      onPressed: () => _restorePlacement(placement.id),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 16),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String selectedValue,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = value == selectedValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(value),
      ),
    );
  }

  void _reload() {
    ref.read(campaignPlacementsProvider(widget.campaign.id).notifier).loadPlacements(
          status: _selectedStatus == 'ALL' ? null : _selectedStatus,
          type: _selectedType == 'ALL' ? null : _selectedType,
        );
  }

  Future<void> _activatePlacement(String id) async {
    try {
      await ref.read(campaignPlacementsProvider(widget.campaign.id).notifier).activatePlacement(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Placement activated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to activate placement: $e')),
        );
      }
    }
  }

  Future<void> _pausePlacement(String id) async {
    try {
      await ref.read(campaignPlacementsProvider(widget.campaign.id).notifier).pausePlacement(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Placement paused.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pause placement: $e')),
        );
      }
    }
  }

  Future<void> _disablePlacement(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disable Placement'),
        content: const Text('Disable this placement? It will no longer deliver ads to users.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ref.read(campaignPlacementsProvider(widget.campaign.id).notifier).disablePlacement(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Placement disabled.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to disable placement: $e')),
        );
      }
    }
  }

  Future<void> _restorePlacement(String id) async {
    try {
      await ref.read(campaignPlacementsProvider(widget.campaign.id).notifier).restorePlacement(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Placement restored.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to restore placement: $e')),
        );
      }
    }
  }

  void _showPlacementDetails(AdPlacementModel placement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Placement Details',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Location', placement.placementTypeDisplay.isNotEmpty ? placement.placementTypeDisplay : placement.placementType),
              _buildDetailRow('Priority', 'P-${placement.priority}'),
              _buildDetailRow('Status', placement.status),
              _buildDetailRow('Creative Asset', placement.media?.title ?? 'N/A'),
              _buildDetailRow('Asset Type', placement.media?.mediaTypeDisplay ?? 'N/A'),
              if (placement.startDate != null) _buildDetailRow('Start Date', placement.startDate!),
              if (placement.endDate != null) _buildDetailRow('End Date', placement.endDate!),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
