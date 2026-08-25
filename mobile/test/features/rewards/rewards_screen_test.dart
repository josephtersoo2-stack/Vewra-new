import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/features/rewards/screens/rewards_screen.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

void main() {
  testWidgets('RewardsScreen renders level card, daily streak, tournament, leaderboard, and achievements', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RewardsScreen(),
      ),
    );

    // Level & XP Progress
    expect(find.text('Rewards & XP Hub'), findsOneWidget);
    expect(find.text('LVL ${DummyDataService.currentUser.level}'), findsOneWidget);
    expect(find.text('XP Progress to Next Level'), findsOneWidget);

    // Daily Rewards
    expect(find.text('7-Day Streak Rewards'), findsOneWidget);
    expect(find.text('Day 1'), findsOneWidget);
    expect(find.text('Day 7'), findsOneWidget);

    // Tournament Banner
    expect(find.text(DummyDataService.activeTournament.title), findsOneWidget);

    // Leaderboard
    expect(find.text('Top Earners Leaderboard'), findsOneWidget);
    expect(find.text('crypto_knight'), findsOneWidget);

    // Achievements
    expect(find.text('Achievements & Badges'), findsOneWidget);
    expect(find.text('First Watch Verified'), findsOneWidget);

    // Claim daily reward action
    await tester.tap(find.text('Day 7'));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
