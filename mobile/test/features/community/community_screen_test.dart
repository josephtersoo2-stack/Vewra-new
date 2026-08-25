import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/features/community/screens/community_screen.dart';
import 'package:vewra_mobile/services/dummy_data_service.dart';

void main() {
  testWidgets('CommunityScreen renders banner, discussion feeds, tag chips, and like button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CommunityScreen(),
      ),
    );

    expect(find.text('VEWRA Community Hub'), findsOneWidget);
    expect(find.text('Connect with Global Earners'), findsOneWidget);
    expect(find.text('Post'), findsOneWidget);

    // Filter tags (FilterChip widgets)
    expect(find.widgetWithText(FilterChip, 'All'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Earning Tips'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Creator Spotlight'), findsOneWidget);

    // Posts
    expect(find.text(DummyDataService.communityPosts.first.authorName), findsOneWidget);

    // Like action
    await tester.tap(find.byIcon(Icons.favorite_rounded).first);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
