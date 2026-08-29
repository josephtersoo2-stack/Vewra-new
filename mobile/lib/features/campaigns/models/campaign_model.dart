/// Model representing a Campaign in the VEWRA ecosystem.
class CampaignModel {
  final String id;
  final String title;
  final String campaignType;
  final String campaignTypeDisplay;
  final String status;
  final String statusDisplay;
  final double budget;
  final String description;
  final String? startDate;
  final String? endDate;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> ownerDetails;

  const CampaignModel({
    required this.id,
    required this.title,
    required this.campaignType,
    this.campaignTypeDisplay = '',
    required this.status,
    this.statusDisplay = '',
    required this.budget,
    this.description = '',
    this.startDate,
    this.endDate,
    this.createdAt = '',
    this.updatedAt = '',
    this.ownerDetails = const {},
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Campaign',
      campaignType: (json['campaign_type'] ?? json['type'] ?? 'TASK').toString(),
      campaignTypeDisplay: json['campaign_type_display']?.toString() ?? (json['campaign_type'] ?? 'Task Campaign').toString(),
      status: json['status']?.toString() ?? 'DRAFT',
      statusDisplay: json['status_display']?.toString() ?? (json['status'] ?? 'Draft').toString(),
      budget: double.tryParse(json['budget']?.toString() ?? '0') ?? 0.0,
      description: json['description']?.toString() ?? '',
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      ownerDetails: (json['owner_details'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'campaign_type': campaignType,
      'status': status,
      'budget': budget,
      'description': description,
      'start_date': startDate,
      'end_date': endDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  CampaignModel copyWith({
    String? id,
    String? title,
    String? campaignType,
    String? campaignTypeDisplay,
    String? status,
    String? statusDisplay,
    double? budget,
    String? description,
    String? startDate,
    String? endDate,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? ownerDetails,
  }) {
    return CampaignModel(
      id: id ?? this.id,
      title: title ?? this.title,
      campaignType: campaignType ?? this.campaignType,
      campaignTypeDisplay: campaignTypeDisplay ?? this.campaignTypeDisplay,
      status: status ?? this.status,
      statusDisplay: statusDisplay ?? this.statusDisplay,
      budget: budget ?? this.budget,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerDetails: ownerDetails ?? this.ownerDetails,
    );
  }

  bool get isDraft => status.toUpperCase() == 'DRAFT';
  bool get isPendingReview => status.toUpperCase() == 'PENDING_REVIEW';
  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isPaused => status.toUpperCase() == 'PAUSED';
  bool get isCompleted => status.toUpperCase() == 'COMPLETED';
  bool get isRejected => status.toUpperCase() == 'REJECTED';
}
