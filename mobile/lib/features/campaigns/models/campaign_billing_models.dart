class AdvertiserWalletModel {
  final String id;
  final String advertiserEmail;
  final double balance;
  final String currency;
  final double totalSpent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdvertiserWalletModel({
    required this.id,
    required this.advertiserEmail,
    required this.balance,
    required this.currency,
    required this.totalSpent,
    this.createdAt,
    this.updatedAt,
  });

  factory AdvertiserWalletModel.fromJson(Map<String, dynamic> json) {
    return AdvertiserWalletModel(
      id: json['id'] ?? '',
      advertiserEmail: json['advertiser_email'] ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'advertiser_email': advertiserEmail,
      'balance': balance,
      'currency': currency,
      'total_spent': totalSpent,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class CampaignSpendingModel {
  final String campaignId;
  final String campaignTitle;
  final String status;
  final double totalBudget;
  final double spentAmount;
  final double remainingBudget;
  final double percentageUsed;
  final double dailyBudget;
  final double dailySpentAmount;
  final double cpmRate;
  final double cpcRate;
  final double cpvRate;
  final DateTime? startDate;
  final DateTime? endDate;

  CampaignSpendingModel({
    required this.campaignId,
    required this.campaignTitle,
    required this.status,
    required this.totalBudget,
    required this.spentAmount,
    required this.remainingBudget,
    required this.percentageUsed,
    required this.dailyBudget,
    required this.dailySpentAmount,
    required this.cpmRate,
    required this.cpcRate,
    required this.cpvRate,
    this.startDate,
    this.endDate,
  });

  factory CampaignSpendingModel.fromJson(Map<String, dynamic> json) {
    return CampaignSpendingModel(
      campaignId: json['campaign_id'] ?? '',
      campaignTitle: json['campaign_title'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      totalBudget: (json['total_budget'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (json['spent_amount'] as num?)?.toDouble() ?? 0.0,
      remainingBudget: (json['remaining_budget'] as num?)?.toDouble() ?? 0.0,
      percentageUsed: (json['percentage_used'] as num?)?.toDouble() ?? 0.0,
      dailyBudget: (json['daily_budget'] as num?)?.toDouble() ?? 0.0,
      dailySpentAmount: (json['daily_spent_amount'] as num?)?.toDouble() ?? 0.0,
      cpmRate: (json['cpm_rate'] as num?)?.toDouble() ?? 2.00,
      cpcRate: (json['cpc_rate'] as num?)?.toDouble() ?? 0.10,
      cpvRate: (json['cpv_rate'] as num?)?.toDouble() ?? 0.05,
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaign_id': campaignId,
      'campaign_title': campaignTitle,
      'status': status,
      'total_budget': totalBudget,
      'spent_amount': spentAmount,
      'remaining_budget': remainingBudget,
      'percentage_used': percentageUsed,
      'daily_budget': dailyBudget,
      'daily_spent_amount': dailySpentAmount,
      'cpm_rate': cpmRate,
      'cpc_rate': cpcRate,
      'cpv_rate': cpvRate,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }
}

class BillingChargeModel {
  final String id;
  final String advertiserEmail;
  final String campaignId;
  final String campaignTitle;
  final String eventType;
  final double amount;
  final String referenceId;
  final int fraudScore;
  final DateTime createdAt;

  BillingChargeModel({
    required this.id,
    required this.advertiserEmail,
    required this.campaignId,
    required this.campaignTitle,
    required this.eventType,
    required this.amount,
    required this.referenceId,
    required this.fraudScore,
    required this.createdAt,
  });

  factory BillingChargeModel.fromJson(Map<String, dynamic> json) {
    return BillingChargeModel(
      id: json['id'] ?? '',
      advertiserEmail: json['advertiser_email'] ?? '',
      campaignId: json['campaign'] ?? '',
      campaignTitle: json['campaign_title'] ?? '',
      eventType: json['event_type'] ?? 'IMPRESSION',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      referenceId: json['reference_id'] ?? '',
      fraudScore: json['fraud_score'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'advertiser_email': advertiserEmail,
      'campaign': campaignId,
      'campaign_title': campaignTitle,
      'event_type': eventType,
      'amount': amount,
      'reference_id': referenceId,
      'fraud_score': fraudScore,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class FinancialReportModel {
  final String advertiser;
  final double walletBalance;
  final String walletCurrency;
  final double totalSpentLifetime;
  final double filteredSpent;
  final int totalChargesCount;
  final int campaignsCount;
  final List<CampaignPerformanceItemModel> campaigns;

  FinancialReportModel({
    required this.advertiser,
    required this.walletBalance,
    required this.walletCurrency,
    required this.totalSpentLifetime,
    required this.filteredSpent,
    required this.totalChargesCount,
    required this.campaignsCount,
    required this.campaigns,
  });

  factory FinancialReportModel.fromJson(Map<String, dynamic> json) {
    return FinancialReportModel(
      advertiser: json['advertiser'] ?? '',
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      walletCurrency: json['wallet_currency'] ?? 'USD',
      totalSpentLifetime: (json['total_spent_lifetime'] as num?)?.toDouble() ?? 0.0,
      filteredSpent: (json['filtered_spent'] as num?)?.toDouble() ?? 0.0,
      totalChargesCount: json['total_charges_count'] ?? 0,
      campaignsCount: json['campaigns_count'] ?? 0,
      campaigns: (json['campaigns'] as List<dynamic>? ?? [])
          .map((c) => CampaignPerformanceItemModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CampaignPerformanceItemModel {
  final String campaignId;
  final String campaignName;
  final String status;
  final int impressions;
  final int clicks;
  final double ctr;
  final int videoCompletions;
  final double videoCompletionRate;
  final double amountSpent;
  final double totalBudget;
  final double remainingBudget;
  final String performanceScore;

  CampaignPerformanceItemModel({
    required this.campaignId,
    required this.campaignName,
    required this.status,
    required this.impressions,
    required this.clicks,
    required this.ctr,
    required this.videoCompletions,
    required this.videoCompletionRate,
    required this.amountSpent,
    required this.totalBudget,
    required this.remainingBudget,
    required this.performanceScore,
  });

  factory CampaignPerformanceItemModel.fromJson(Map<String, dynamic> json) {
    return CampaignPerformanceItemModel(
      campaignId: json['campaign_id'] ?? '',
      campaignName: json['campaign_name'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      impressions: json['impressions'] ?? 0,
      clicks: json['clicks'] ?? 0,
      ctr: (json['ctr'] as num?)?.toDouble() ?? 0.0,
      videoCompletions: json['video_completions'] ?? 0,
      videoCompletionRate: (json['video_completion_rate'] as num?)?.toDouble() ?? 0.0,
      amountSpent: (json['amount_spent'] as num?)?.toDouble() ?? 0.0,
      totalBudget: (json['total_budget'] as num?)?.toDouble() ?? 0.0,
      remainingBudget: (json['remaining_budget'] as num?)?.toDouble() ?? 0.0,
      performanceScore: json['performance_score'] ?? 'C',
    );
  }
}
