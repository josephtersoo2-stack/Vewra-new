import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vewra_mobile/main.dart';
import 'package:vewra_mobile/core/constants/app_strings.dart';

void main() {
  testWidgets('App root smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: VewraApp(),
      ),
    );
    expect(find.text(AppStrings.appName), findsOneWidget);
  });
}
