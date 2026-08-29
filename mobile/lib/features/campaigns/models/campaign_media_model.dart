class CampaignMediaModel {
  final String id;
  final String campaignId;
  final String mediaType;
  final String mediaTypeDisplay;
  final String fileUrl;
  final String? thumbnailUrl;
  final String title;
  final String description;
  final int fileSize;
  final String fileSizeFormatted;
  final String mimeType;
  final int? durationSeconds;
  final int? width;
  final int? height;
  final String status;
  final String statusDisplay;
  final String uploadedByEmail;
  final String createdAt;

  const CampaignMediaModel({
    required this.id,
    required this.campaignId,
    required this.mediaType,
    this.mediaTypeDisplay = '',
    required this.fileUrl,
    this.thumbnailUrl,
    required this.title,
    this.description = '',
    this.fileSize = 0,
    this.fileSizeFormatted = '',
    this.mimeType = '',
    this.durationSeconds,
    this.width,
    this.height,
    this.status = 'READY',
    this.statusDisplay = 'Ready',
    this.uploadedByEmail = '',
    this.createdAt = '',
  });

  bool get isVideo => mediaType.toUpperCase() == 'VIDEO';
  bool get isImage => mediaType.toUpperCase() == 'IMAGE';
  bool get isBanner => mediaType.toUpperCase() == 'BANNER';
  bool get isReady => status.toUpperCase() == 'READY';
  bool get isDisabled => status.toUpperCase() == 'DISABLED';

  String get dimensionsText {
    if (width != null && height != null) {
      return '${width}x$height';
    }
    return '';
  }

  factory CampaignMediaModel.fromJson(Map<String, dynamic> json) {
    return CampaignMediaModel(
      id: json['id']?.toString() ?? '',
      campaignId: json['campaign']?.toString() ?? '',
      mediaType: json['media_type']?.toString() ?? 'IMAGE',
      mediaTypeDisplay: json['media_type_display']?.toString() ??
          (json['media_type']?.toString() ?? 'Image Asset'),
      fileUrl: json['file_url']?.toString() ?? json['file']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString() ?? json['thumbnail']?.toString(),
      title: json['title']?.toString() ?? 'Media Asset',
      description: json['description']?.toString() ?? '',
      fileSize: (json['file_size'] as num?)?.toInt() ?? 0,
      fileSizeFormatted: json['file_size_formatted']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      status: json['status']?.toString() ?? 'READY',
      statusDisplay: json['status_display']?.toString() ??
          (json['status']?.toString() ?? 'Ready'),
      uploadedByEmail: json['uploaded_by_email']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign': campaignId,
      'media_type': mediaType,
      'media_type_display': mediaTypeDisplay,
      'file_url': fileUrl,
      'thumbnail_url': thumbnailUrl,
      'title': title,
      'description': description,
      'file_size': fileSize,
      'file_size_formatted': fileSizeFormatted,
      'mime_type': mimeType,
      'duration_seconds': durationSeconds,
      'width': width,
      'height': height,
      'status': status,
      'status_display': statusDisplay,
      'uploaded_by_email': uploadedByEmail,
      'created_at': createdAt,
    };
  }

  CampaignMediaModel copyWith({
    String? id,
    String? campaignId,
    String? mediaType,
    String? mediaTypeDisplay,
    String? fileUrl,
    String? thumbnailUrl,
    String? title,
    String? description,
    int? fileSize,
    String? fileSizeFormatted,
    String? mimeType,
    int? durationSeconds,
    int? width,
    int? height,
    String? status,
    String? statusDisplay,
    String? uploadedByEmail,
    String? createdAt,
  }) {
    return CampaignMediaModel(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      mediaType: mediaType ?? this.mediaType,
      mediaTypeDisplay: mediaTypeDisplay ?? this.mediaTypeDisplay,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      fileSize: fileSize ?? this.fileSize,
      fileSizeFormatted: fileSizeFormatted ?? this.fileSizeFormatted,
      mimeType: mimeType ?? this.mimeType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      width: width ?? this.width,
      height: height ?? this.height,
      status: status ?? this.status,
      statusDisplay: statusDisplay ?? this.statusDisplay,
      uploadedByEmail: uploadedByEmail ?? this.uploadedByEmail,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
