import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ad_placement_model.dart';
import '../providers/advertisement_tracking_provider.dart';

/// Modern, glassmorphic advertisement banner card for mobile surfaces with automatic impression & click telemetry.
class AdPlacementCard extends ConsumerStatefulWidget {
  final AdPlacementModel placement;
  final VoidCallback? onTap;
  final double? height;
  final bool autoRecordImpression;

  const AdPlacementCard({
    super.key,
    required this.placement,
    this.onTap,
    this.height = 140,
    this.autoRecordImpression = true,
  });

  @override
  ConsumerState<AdPlacementCard> createState() => _AdPlacementCardState();
}

class _AdPlacementCardState extends ConsumerState<AdPlacementCard> {
  bool _impressionRecorded = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoRecordImpression) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _recordImpression();
      });
    }
  }

  void _recordImpression() {
    if (_impressionRecorded) return;
    _impressionRecorded = true;
    final media = widget.placement.media;
    if (media != null && media.id.isNotEmpty) {
      ref.read(adTrackingNotifierProvider.notifier).recordImpression(
            campaignId: widget.placement.campaignId,
            placementId: widget.placement.id,
            mediaId: media.id,
          );
    }
  }

  void _handleTap() {
    final media = widget.placement.media;
    if (media != null && media.id.isNotEmpty) {
      ref.read(adTrackingNotifierProvider.notifier).recordClick(
            campaignId: widget.placement.campaignId,
            mediaId: media.id,
            clickType: 'BANNER_CLICK',
          );
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final media = widget.placement.media;

    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image / placeholder
                if (media?.fileUrl != null && media!.fileUrl.isNotEmpty)
                  Image.network(
                    media.fileUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildFallbackBackground(theme),
                  )
                else
                  _buildFallbackBackground(theme),

                // Gradient Overlay for text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(40),
                        Colors.black.withAlpha(200),
                      ],
                    ),
                  ),
                ),

                // Content Overlay
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Sponsored Badge & Location
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C5CE7).withAlpha(220),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'SPONSORED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (widget.placement.placementTypeDisplay.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(120),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.placement.placementTypeDisplay,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Bottom Row: Campaign & Creative Info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            media?.title.isNotEmpty == true
                                ? media!.title
                                : widget.placement.campaignTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (media?.description.isNotEmpty == true)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                media!.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackBackground(ThemeData theme) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D3436), Color(0xFF0984E3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.campaign_rounded, size: 48, color: Colors.white24),
      ),
    );
  }
}
