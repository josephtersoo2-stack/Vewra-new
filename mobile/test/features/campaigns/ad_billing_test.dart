import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/features/campaigns/models/campaign_billing_models.dart';
import 'package:vewra_mobile/features/campaigns/data/advertisement_tracking_service.dart';

void main() {
  group('Campaign Billing & Monetisation Models Tests (Phase 5.5 Step 5)', () {
    test('AdvertiserWalletModel parse and serialize correctly', () {
      final json = {
        'id': 'wal-123',
        'advertiser_email': 'brand@vewra.com',
        'balance': 250.75,
        'currency': 'USD',
        'total_spent': 749.25,
        'created_at': '2026-08-30T12:00:00Z',
        'updated_at': '2026-08-30T14:30:00Z',
      };

      final wallet = AdvertiserWalletModel.fromJson(json);

      expect(wallet.id, 'wal-123');
      expect(wallet.advertiserEmail, 'brand@vewra.com');
      expect(wallet.balance, 250.75);
      expect(wallet.currency, 'USD');
      expect(wallet.totalSpent, 749.25);
      expect(wallet.createdAt, isNotNull);

      final map = wallet.toJson();
      expect(map['balance'], 250.75);
      expect(map['currency'], 'USD');
    });

    test('CampaignSpendingModel parse and calculate rates correctly', () {
      final json = {
        'campaign_id': 'camp-888',
        'campaign_title': 'Nike Air Summer Launch',
        'status': 'ACTIVE',
        'total_budget': 1000.00,
        'spent_amount': 350.50,
        'remaining_budget': 649.50,
        'percentage_used': 35.05,
        'daily_budget': 100.00,
        'daily_spent_amount': 24.50,
        'cpm_rate': 2.50,
        'cpc_rate': 0.15,
        'cpv_rate': 0.08,
      };

      final spending = CampaignSpendingModel.fromJson(json);

      expect(spending.campaignId, 'camp-888');
      expect(spending.totalBudget, 1000.00);
      expect(spending.spentAmount, 350.50);
      expect(spending.remainingBudget, 649.50);
      expect(spending.percentageUsed, 35.05);
      expect(spending.cpmRate, 2.50);
      expect(spending.cpcRate, 0.15);
      expect(spending.cpvRate, 0.08);
    });

    test('BillingChargeModel parse correctly', () {
      final json = {
        'id': 'chg-999',
        'advertiser_email': 'sponsor@vewra.com',
        'campaign': 'camp-888',
        'campaign_title': 'Nike Air Summer Launch',
        'event_type': 'VIDEO_COMPLETION',
        'amount': 0.0500,
        'reference_id': 'eng-session-001',
        'fraud_score': 5,
        'created_at': '2026-08-30T15:00:00Z',
      };

      final charge = BillingChargeModel.fromJson(json);

      expect(charge.id, 'chg-999');
      expect(charge.eventType, 'VIDEO_COMPLETION');
      expect(charge.amount, 0.05);
      expect(charge.fraudScore, 5);
    });

    test('FinancialReportModel parse comprehensive report correctly', () {
      final json = {
        'advertiser': 'sponsor@vewra.com',
        'wallet_balance': 500.0,
        'wallet_currency': 'USD',
        'total_spent_lifetime': 1200.0,
        'filtered_spent': 350.0,
        'total_charges_count': 1420,
        'campaigns_count': 1,
        'campaigns': [
          {
            'campaign_id': 'camp-888',
            'campaign_name': 'Nike Air Summer Launch',
            'status': 'ACTIVE',
            'impressions': 12000,
            'clicks': 420,
            'ctr': 3.5,
            'video_completions': 850,
            'video_completion_rate': 70.83,
            'amount_spent': 350.0,
            'total_budget': 1000.0,
            'remaining_budget': 650.0,
            'performance_score': 'A',
          }
        ],
      };

      final report = FinancialReportModel.fromJson(json);

      expect(report.advertiser, 'sponsor@vewra.com');
      expect(report.walletBalance, 500.0);
      expect(report.campaigns.length, 1);
      expect(report.campaigns.first.performanceScore, 'A');
      expect(report.campaigns.first.ctr, 3.5);
    });

    test('AdvertisementTrackingService reward eligibility evaluation', () {
      final service = AdvertisementTrackingService();

      // Case 1: Video watched >= 95%
      expect(
        service.evaluateRewardEligibility(
          watchedSeconds: 29.0,
          videoDuration: 30.0,
          clicked: false,
        ),
        isTrue,
      );

      // Case 2: Clicked
      expect(
        service.evaluateRewardEligibility(
          watchedSeconds: 5.0,
          videoDuration: 30.0,
          clicked: true,
        ),
        isTrue,
      );

      // Case 3: Incomplete watch (<95%) without click
      expect(
        service.evaluateRewardEligibility(
          watchedSeconds: 10.0,
          videoDuration: 30.0,
          clicked: false,
        ),
        isFalse,
      );
    });
  });
}
