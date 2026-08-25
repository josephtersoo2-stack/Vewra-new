import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/features/rewards/widgets/spin_wheel_card.dart';
import 'package:vewra_mobile/features/rewards/widgets/scratch_card_widget.dart';
import 'package:vewra_mobile/features/rewards/widgets/missions_section.dart';
import 'package:vewra_mobile/features/rewards/widgets/challenges_section.dart';
import 'package:vewra_mobile/features/rewards/widgets/feature_unlock_card.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

void main() {
  group('Gamification Retention Widgets Tests', () {
    testWidgets('SpinWheelCard renders title, odds info dialog, and triggers spin', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SpinWheelCard(),
            ),
          ),
        ),
      );

      expect(find.text('Daily Fortune Wheel'), findsOneWidget);
      expect(find.text('Spin Now'), findsOneWidget);
      expect(find.text('1 Free Spin Ready'), findsOneWidget);

      // Open odds modal
      await tester.tap(find.byIcon(Icons.info_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Possible Wheel Rewards'), findsOneWidget);
      expect(find.text('Jackpot Mystery Box'), findsOneWidget);

      // Close modal
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Trigger spin
      await tester.tap(find.text('Spin Now'));
      await tester.pump();
      expect(find.text('Spinning...'), findsOneWidget);

      // Advance animation
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Congratulations!'), findsOneWidget);
      expect(find.text('Claim Reward'), findsOneWidget);

      // Dismiss winner dialog
      await tester.tap(find.text('Claim Reward'));
      await tester.pumpAndSettle();
      expect(find.text('Congratulations!'), findsNothing);
    });

    testWidgets('ScratchCardWidget reveals reward on tap and triggers callback', (WidgetTester tester) async {
      bool claimed = false;
      final card = DummyDataService.scratchCards.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScratchCardWidget(
              card: card,
              onClaim: () => claimed = true,
            ),
          ),
        ),
      );

      expect(find.text(card.title), findsOneWidget);
      expect(find.text('TAP TO SCRATCH & REVEAL'), findsOneWidget);

      // Tap to reveal
      await tester.tap(find.text('TAP TO SCRATCH & REVEAL'));
      await tester.pump();

      expect(find.text('Reward Unlocked!'), findsOneWidget);
      expect(find.text('+${card.rewardCoins} Coins & +${card.rewardXp} XP'), findsOneWidget);
      expect(claimed, isTrue);
    });

    testWidgets('MissionsSection displays daily objectives and claims reward', (WidgetTester tester) async {
      final missions = DummyDataService.dailyMissions;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MissionsSection(missions: missions),
            ),
          ),
        ),
      );

      expect(find.text('Daily Missions & Quests'), findsOneWidget);
      expect(find.text('Watch 3 Video Tasks'), findsOneWidget);
      expect(find.text('Claim'), findsOneWidget); // for completed mission

      // Tap claim
      await tester.tap(find.text('Claim'));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('ChallengesSection filters personal vs community challenges and joins', (WidgetTester tester) async {
      final challenges = DummyDataService.challenges;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ChallengesSection(challenges: challenges),
            ),
          ),
        ),
      );

      expect(find.text('Active Challenges'), findsOneWidget);
      expect(find.text('Weekend Tech Explorer Sprint'), findsOneWidget);
      expect(find.text('Join Challenge'), findsWidgets);

      // Filter by Community
      await tester.tap(find.text('Community'));
      await tester.pump();
      expect(find.text('Global Community Goal: 100k Hours Watched'), findsOneWidget);

      // Join unjoined challenge in community tab
      await tester.tap(find.text('Join Challenge').first);
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('FeatureUnlockCard renders locked and unlocked requirements checklist', (WidgetTester tester) async {
      final unlock = DummyDataService.featureUnlocks.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeatureUnlockCard(unlock: unlock),
          ),
        ),
      );

      expect(find.text(unlock.featureName), findsOneWidget);
      expect(find.text('UNLOCKED'), findsOneWidget);
      expect(find.text('Level ${unlock.requiredLevel}'), findsOneWidget);
      expect(find.text('${unlock.requiredTrustScore}% Trust'), findsOneWidget);
    });
  });
}
