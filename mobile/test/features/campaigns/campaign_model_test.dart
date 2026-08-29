import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/features/campaigns/models/campaign_model.dart';

void main() {
  group('CampaignModel Tests', () {
    test('fromJson deserializes complete payload correctly', () {
      final json = {
        'id': 'c8f1e4b2-2938-4f21-815d-4f6c49801234',
        'title': 'Nike Air Promotion',
        'campaign_type': 'ADVERTISEMENT',
        'campaign_type_display': 'Advertisement Campaign',
        'status': 'ACTIVE',
        'status_display': 'Active',
        'budget': '1500.50',
        'description': 'Product promotion campaign for new sneakers.',
        'start_date': '2026-09-01T00:00:00Z',
        'end_date': '2026-09-30T23:59:59Z',
        'created_at': '2026-08-29T12:00:00Z',
        'updated_at': '2026-08-29T12:30:00Z',
        'owner_details': {
          'id': 'user-1',
          'email': 'nike@brand.com',
          'username': 'nike_official',
        },
      };

      final model = CampaignModel.fromJson(json);

      expect(model.id, 'c8f1e4b2-2938-4f21-815d-4f6c49801234');
      expect(model.title, 'Nike Air Promotion');
      expect(model.campaignType, 'ADVERTISEMENT');
      expect(model.status, 'ACTIVE');
      expect(model.budget, 1500.50);
      expect(model.description, 'Product promotion campaign for new sneakers.');
      expect(model.isActive, isTrue);
      expect(model.isDraft, isFalse);
      expect(model.ownerDetails['email'], 'nike@brand.com');
    });

    test('toJson serializes correctly', () {
      const model = CampaignModel(
        id: 'uuid-123',
        title: 'Task Campaign Test',
        campaignType: 'TASK',
        status: 'DRAFT',
        budget: 50.0,
        description: 'Test description',
      );

      final json = model.toJson();

      expect(json['id'], 'uuid-123');
      expect(json['title'], 'Task Campaign Test');
      expect(json['campaign_type'], 'TASK');
      expect(json['status'], 'DRAFT');
      expect(json['budget'], 50.0);
      expect(model.isDraft, isTrue);
    });

    test('copyWith updates state correctly', () {
      const model = CampaignModel(
        id: 'uuid-1',
        title: 'Original',
        campaignType: 'TASK',
        status: 'DRAFT',
        budget: 10.0,
      );

      final updated = model.copyWith(
        status: 'PENDING_REVIEW',
        statusDisplay: 'Pending Review',
        budget: 20.0,
      );

      expect(updated.id, 'uuid-1');
      expect(updated.title, 'Original');
      expect(updated.status, 'PENDING_REVIEW');
      expect(updated.budget, 20.0);
      expect(updated.isPendingReview, isTrue);
    });
  });
}
