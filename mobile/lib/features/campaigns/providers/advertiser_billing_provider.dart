import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/advertiser_billing_service.dart';
import '../models/campaign_billing_models.dart';

final advertiserBillingServiceProvider = Provider<AdvertiserBillingService>((ref) {
  return AdvertiserBillingService();
});

final advertiserWalletProvider = FutureProvider.autoDispose<AdvertiserWalletModel>((ref) async {
  final service = ref.watch(advertiserBillingServiceProvider);
  return await service.getWallet();
});

final campaignSpendingProvider = FutureProvider.family.autoDispose<CampaignSpendingModel, String>((ref, campaignId) async {
  final service = ref.watch(advertiserBillingServiceProvider);
  return await service.getCampaignSpending(campaignId);
});

final billingHistoryProvider = FutureProvider.family.autoDispose<List<BillingChargeModel>, String?>((ref, campaignId) async {
  final service = ref.watch(advertiserBillingServiceProvider);
  return await service.getBillingHistory(campaignId: campaignId);
});

final financialReportProvider = FutureProvider.family.autoDispose<FinancialReportModel, String?>((ref, campaignId) async {
  final service = ref.watch(advertiserBillingServiceProvider);
  return await service.getFinancialReport(campaignId: campaignId);
});
