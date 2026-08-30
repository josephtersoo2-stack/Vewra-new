class CreativePerformanceModel {
  final String mediaId;
  final String title;
  final String mediaType;
  final String mediaTypeDisplay;
  final String? fileUrl;
  final int impressions;
  final int clicks;
  final double ctr;
  final int? videoPlays;
  final int? completions;
  final double? completionRate;
  final double? avgWatchDuration;

  CreativePerformanceModel({
    required this.mediaId,
    required this.title,
    required this.mediaType,
    required this.mediaTypeDisplay,
    this.fileUrl,
    required this.impressions,
    required this.clicks,
    required this.ctr,
    this.videoPlays,
    this.completions,
    this.completionRate,
    this.avgWatchDuration,
  });

  factory CreativePerformanceModel.fromJson(Map<String, dynamic> json) {
    return CreativePerformanceModel(
      mediaId: json['media_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      mediaType: json['media_type'] as String? ?? '',
      mediaTypeDisplay: json['media_type_display'] as String? ?? '',
      fileUrl: json['file_url'] as String?,
      impressions: (json['impressions'] as num?)?.toInt() ?? 0,
      clicks: (json['clicks'] as num?)?.toInt() ?? 0,
      ctr: (json['ctr'] as num?)?.toDouble() ?? 0.0,
      videoPlays: (json['video_plays'] as num?)?.toInt(),
      completions: (json['completions'] as num?)?.toInt(),
      completionRate: (json['completion_rate'] as num?)?.toDouble(),
      avgWatchDuration: (json['avg_watch_duration'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'media_id': mediaId,
      'title': title,
      'media_type': mediaType,
      'media_type_display': mediaTypeDisplay,
      'file_url': fileUrl,
      'impressions': impressions,
      'clicks': clicks,
      'ctr': ctr,
      'video_plays': videoPlays,
      'completions': completions,
      'completion_rate': completionRate,
      'avg_watch_duration': avgWatchDuration,
    };
  }
}

class VideoMetricsModel {
  final int totalPlays;
  final int completions;
  final double completionRate;
  final double averageWatchDuration;

  VideoMetricsModel({
    required this.totalPlays,
    required this.completions,
    required this.completionRate,
    required this.averageWatchDuration,
  });

  factory VideoMetricsModel.fromJson(Map<String, dynamic> json) {
    return VideoMetricsModel(
      totalPlays: (json['total_plays'] as num?)?.toInt() ?? 0,
      completions: (json['completions'] as num?)?.toInt() ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      averageWatchDuration: (json['average_watch_duration'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_plays': totalPlays,
      'completions': completions,
      'completion_rate': completionRate,
      'average_watch_duration': averageWatchDuration,
    };
  }
}

class TimelinePointModel {
  final String date;
  final int impressions;
  final int clicks;

  TimelinePointModel({
    required this.date,
    required this.impressions,
    required this.clicks,
  });

  factory TimelinePointModel.fromJson(Map<String, dynamic> json) {
    return TimelinePointModel(
      date: json['date'] as String? ?? '',
      impressions: (json['impressions'] as num?)?.toInt() ?? 0,
      clicks: (json['clicks'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'impressions': impressions,
      'clicks': clicks,
    };
  }
}

class CampaignAnalyticsModel {
  final String campaignId;
  final String title;
  final String status;
  final int totalImpressions;
  final int uniqueViewers;
  final int totalClicks;
  final double clickThroughRate;
  final Map<String, dynamic> clicksBreakdown;
  final List<CreativePerformanceModel> creativesPerformance;
  final VideoMetricsModel videoMetrics;
  final List<TimelinePointModel> timeline;

  CampaignAnalyticsModel({
    required this.campaignId,
    required this.title,
    required this.status,
    required this.totalImpressions,
    required this.uniqueViewers,
    required this.totalClicks,
    required this.clickThroughRate,
    required this.clicksBreakdown,
    required this.creativesPerformance,
    required this.videoMetrics,
    required this.timeline,
  });

  factory CampaignAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final creatives = (json['creatives_performance'] as List<dynamic>?)
            ?.map((e) => CreativePerformanceModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final timelinePoints = (json['timeline'] as List<dynamic>?)
            ?.map((e) => TimelinePointModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return CampaignAnalyticsModel(
      campaignId: json['campaign_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalImpressions: (json['total_impressions'] as num?)?.toInt() ?? 0,
      uniqueViewers: (json['unique_viewers'] as num?)?.toInt() ?? 0,
      totalClicks: (json['total_clicks'] as num?)?.toInt() ?? 0,
      clickThroughRate: (json['click_through_rate'] as num?)?.toDouble() ?? 0.0,
      clicksBreakdown: (json['clicks_by_type'] as Map<String, dynamic>?) ?? {},
      creativesPerformance: creatives,
      videoMetrics: VideoMetricsModel.fromJson((json['video_metrics'] as Map<String, dynamic>?) ?? {}),
      timeline: timelinePoints,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaign_id': campaignId,
      'title': title,
      'status': status,
      'total_impressions': totalImpressions,
      'unique_viewers': uniqueViewers,
      'total_clicks': totalClicks,
      'click_through_rate': clickThroughRate,
      'clicks_by_type': clicksBreakdown,
      'creatives_performance': creativesPerformance.map((e) => e.toJson()).toList(),
      'video_metrics': videoMetrics.toJson(),
      'timeline': timeline.map((e) => e.toJson()).toList(),
    };
  }
}

class AdvertiserOverviewAnalyticsModel {
  final int totalCampaigns;
  final int activeCampaigns;
  final int totalImpressions;
  final int uniqueViewers;
  final int totalClicks;
  final double overallCtr;
  final List<dynamic> topCampaigns;

  AdvertiserOverviewAnalyticsModel({
    required this.totalCampaigns,
    required this.activeCampaigns,
    required this.totalImpressions,
    required this.uniqueViewers,
    required this.totalClicks,
    required this.overallCtr,
    required this.topCampaigns,
  });

  factory AdvertiserOverviewAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AdvertiserOverviewAnalyticsModel(
      totalCampaigns: (json['total_campaigns'] as num?)?.toInt() ?? 0,
      activeCampaigns: (json['active_campaigns'] as num?)?.toInt() ?? 0,
      totalImpressions: (json['total_impressions'] as num?)?.toInt() ?? 0,
      uniqueViewers: (json['unique_viewers'] as num?)?.toInt() ?? 0,
      totalClicks: (json['total_clicks'] as num?)?.toInt() ?? 0,
      overallCtr: (json['overall_ctr'] as num?)?.toDouble() ?? 0.0,
      topCampaigns: (json['top_campaigns'] as List<dynamic>?) ?? [],
    );
  }
}
