import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/core/widgets/cards/level_progress_card.dart';
import 'package:vewra_mobile/core/widgets/cards/reward_card.dart';
import 'package:vewra_mobile/core/widgets/cards/leaderboard_card.dart';
import 'package:vewra_mobile/core/widgets/cards/marketplace_card.dart';
import 'package:vewra_mobile/core/widgets/cards/verification_card.dart';
import 'package:vewra_mobile/core/widgets/cards/community_card.dart';

void main() {
  group('Retrofit Cards Component Tests', () {
    testWidgets('LevelProgressCard renders level, xp bar, and trust score', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LevelProgressCard(
              level: 14,
              currentXp: 2450,
              nextLevelXp: 3000,
              trustScore: 96,
              verificationStatus: 'Verified',
            ),
          ),
        ),
      );

      expect(find.text('LVL 14'), findsOneWidget);
      expect(find.text('2450 / 3000 XP'), findsOneWidget);
      expect(find.text('Trust 96%'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
    });

    testWidgets('RewardCard triggers onClaim on today reward', (WidgetTester tester) async {
      bool claimed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RewardCard(
              day: 7,
              rewardCoins: 300,
              isToday: true,
              isClaimed: false,
              onClaim: () => claimed = true,
            ),
          ),
        ),
      );

      expect(find.text('Day 7'), findsOneWidget);
      expect(find.text('+300'), findsOneWidget);

      await tester.tap(find.text('Day 7'));
      expect(claimed, isTrue);
    });

    testWidgets('LeaderboardCard renders rank, username, and coins', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LeaderboardCard(
              rank: 1,
              username: 'crypto_knight',
              coinsEarned: 48500,
              tierBadge: 'Champion',
            ),
          ),
        ),
      );

      expect(find.text('#1'), findsOneWidget);
      expect(find.text('crypto_knight'), findsOneWidget);
      expect(find.text('48500'), findsOneWidget);
      expect(find.text('Champion'), findsOneWidget);
    });

    testWidgets('MarketplaceCard renders title, price, and triggers redeem', (WidgetTester tester) async {
      bool redeemed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarketplaceCard(
              title: '\$10 Mobile Airtime',
              providerOrSeller: 'Global Telecom',
              category: 'Airtime',
              priceCoins: 1000,
              priceFiat: 10.00,
              description: 'Instant recharge',
              onBuy: () => redeemed = true,
            ),
          ),
        ),
      );

      expect(find.text('\$10 Mobile Airtime'), findsOneWidget);
      expect(find.text('1000 Coins'), findsOneWidget);
      expect(find.text('Redeem'), findsOneWidget);

      await tester.tap(find.text('Redeem'));
      expect(redeemed, isTrue);
    });

    testWidgets('VerificationCard renders requirements and triggers upgrade', (WidgetTester tester) async {
      bool upgraded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerificationCard(
              title: 'Trusted User',
              subtitle: 'High activity',
              withdrawalLimit: '\$5,000',
              requirements: const ['Government ID', '90+ Trust Score'],
              benefits: const ['High limits'],
              isUnlocked: false,
              onVerify: () => upgraded = true,
            ),
          ),
        ),
      );

      expect(find.text('Trusted User'), findsOneWidget);
      expect(find.text('Government ID'), findsOneWidget);
      expect(find.text('Upgrade to Trusted User'), findsOneWidget);

      await tester.tap(find.text('Upgrade to Trusted User'));
      expect(upgraded, isTrue);
    });

    testWidgets('CommunityCard renders post content and responds to like', (WidgetTester tester) async {
      bool liked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityCard(
              authorName: 'Marcus Chen',
              authorTier: 'Top Promoter',
              content: 'Check out the new challenge tasks!',
              categoryTag: 'Tips',
              likesCount: 38,
              commentsCount: 12,
              timeAgo: '2h ago',
              onLike: () => liked = true,
            ),
          ),
        ),
      );

      expect(find.text('Marcus Chen'), findsOneWidget);
      expect(find.text('Check out the new challenge tasks!'), findsOneWidget);
      expect(find.text('38'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      expect(liked, isTrue);
    });
  });
}
