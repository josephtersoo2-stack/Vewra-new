import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/features/rewards/screens/rewards_screen.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

void main() {
  testWidgets('RewardsScreen renders level card, sub-tabs, spins, missions, events, challenges, and unlocks', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RewardsScreen(),
      ),
    );

    // 1. Level & XP Progress
    expect(find.text('Rewards & XP Hub'), findsOneWidget);
    expect(find.text('LVL ${DummyDataService.currentUser.level}'), findsOneWidget);
    expect(find.text('XP Progress to Next Level'), findsOneWidget);

    // 2. Tab 0: Daily & Spins
    expect(find.text('7-Day Streak Rewards'), findsOneWidget);
    expect(find.text('Day 1'), findsOneWidget);
    expect(find.text('Day 7'), findsOneWidget);
    expect(find.text('Daily Fortune Wheel'), findsOneWidget);
    expect(find.text('Mystery Scratch Cards'), findsOneWidget);
    expect(find.text('Daily Missions & Quests'), findsOneWidget);

    // Claim daily reward action
    await tester.tap(find.text('Day 7'));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);

    // 3. Switch to Tab 1: Events & Ranks
    await tester.tap(find.text('Events & Ranks'));
    await tester.pump();

    expect(find.text(DummyDataService.activeTournament.title), findsOneWidget);
    expect(find.text('Top Earners Leaderboard'), findsOneWidget);
    expect(find.text('crypto_knight'), findsOneWidget);
    expect(find.text('Achievements & Badges'), findsOneWidget);
    expect(find.text('First Watch Verified'), findsOneWidget);

    // 4. Switch to Tab 2: Challenges & Unlocks
    await tester.tap(find.text('Challenges & Unlocks'));
    await tester.pump();

    expect(find.text('Active Challenges'), findsOneWidget);
    expect(find.text('Weekend Tech Explorer Sprint'), findsOneWidget);
    expect(find.text('Feature Unlock Progression'), findsOneWidget);
    expect(find.text(DummyDataService.featureUnlocks.first.featureName), findsOneWidget);
  });
}
