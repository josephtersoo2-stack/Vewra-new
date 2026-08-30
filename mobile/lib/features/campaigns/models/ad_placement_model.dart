import 'campaign_media_model.dart';

/// Represents a configured and delivered Campaign Advertisement Placement.
class AdPlacementModel {
  final String id;
  final String placementType;
  final String placementTypeDisplay;
  final int priority;
  final String campaignId;
  final String campaignTitle;
  final String campaignStatus;
  final CampaignMediaModel? media;
  final String? startDate;
  final String? endDate;
  final String status;
  final String statusDisplay;
  final String createdByEmail;
  final String createdAt;

  const AdPlacementModel({
    required this.id,
    required this.placementType,
    this.placementTypeDisplay = '',
    this.priority = 10,
    required this.campaignId,
    this.campaignTitle = '',
    this.campaignStatus = 'ACTIVE',
    this.media,
    this.startDate,
    this.endDate,
    this.status = 'ACTIVE',
    this.statusDisplay = 'Active',
    this.createdByEmail = '',
    this.createdAt = '',
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isPaused => status.toUpperCase() == 'PAUSED';
  bool get isDraft => status.toUpperCase() == 'DRAFT';
  bool get isDisabled => status.toUpperCase() == 'DISABLED';

  bool get isHomeFeed => placementType.toUpperCase() == 'HOME_FEED';
  bool get isHeader => placementType.toUpperCase() == 'HEADER';
  bool get isFooter => placementType.toUpperCase() == 'FOOTER';
  bool get isPopup => placementType.toUpperCase() == 'POPUP';
  bool get isVideoPreroll => placementType.toUpperCase() == 'VIDEO_PREROLL';
  bool get isTaskFeed => placementType.toUpperCase() == 'TASK_FEED';

  factory AdPlacementModel.fromJson(Map<String, dynamic> json) {
    CampaignMediaModel? mediaObj;
    if (json['media'] != null && json['media'] is Map<String, dynamic>) {
      mediaObj = CampaignMediaModel.fromJson(json['media'] as Map<String, dynamic>);
    } else if (json['media_details'] != null && json['media_details'] is Map<String, dynamic>) {
      mediaObj = CampaignMediaModel.fromJson(json['media_details'] as Map<String, dynamic>);
    }

    return AdPlacementModel(
      id: json['id']?.toString() ?? '',
      placementType: json['placement_type']?.toString() ?? 'HOME_FEED',
      placementTypeDisplay: json['placement_type_display']?.toString() ?? '',
      priority: json['priority'] is int ? json['priority'] as int : int.tryParse(json['priority']?.toString() ?? '10') ?? 10,
      campaignId: json['campaign_id']?.toString() ?? json['campaign']?.toString() ?? '',
      campaignTitle: json['campaign_title']?.toString() ?? '',
      campaignStatus: json['campaign_status']?.toString() ?? 'ACTIVE',
      media: mediaObj,
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
      statusDisplay: json['status_display']?.toString() ?? 'Active',
      createdByEmail: json['created_by_email']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placement_type': placementType,
      'placement_type_display': placementTypeDisplay,
      'priority': priority,
      'campaign_id': campaignId,
      'campaign_title': campaignTitle,
      'campaign_status': campaignStatus,
      'media': media?.toJson(),
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'status_display': statusDisplay,
      'created_by_email': createdByEmail,
      'created_at': createdAt,
    };
  }

  AdPlacementModel copyWith({
    String? id,
    String? placementType,
    String? placementTypeDisplay,
    int? priority,
    String? campaignId,
    String? campaignTitle,
    String? campaignStatus,
    CampaignMediaModel? media,
    String? startDate,
    String? endDate,
    String? status,
    String? statusDisplay,
    String? createdByEmail,
    String? createdAt,
  }) {
    return AdPlacementModel(
      id: id ?? this.id,
      placementType: placementType ?? this.placementType,
      placementTypeDisplay: placementTypeDisplay ?? this.placementTypeDisplay,
      priority: priority ?? this.priority,
      campaignId: campaignId ?? this.campaignId,
      campaignTitle: campaignTitle ?? this.campaignTitle,
      campaignStatus: campaignStatus ?? this.campaignStatus,
      media: media ?? this.media,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      statusDisplay: statusDisplay ?? this.statusDisplay,
      createdByEmail: createdByEmail ?? this.createdByEmail,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
