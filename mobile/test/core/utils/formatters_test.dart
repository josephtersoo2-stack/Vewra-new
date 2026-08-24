import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('formatCoins formats number with commas', () {
      expect(Formatters.formatCoins(1250), '1,250 Coins');
      expect(Formatters.formatCoins(500), '500 Coins');
      expect(Formatters.formatCoins(1000000), '1,000,000 Coins');
    });

    test('formatCurrency formats decimal fiat amount', () {
      expect(Formatters.formatCurrency(12.5), '\$12.50');
      expect(Formatters.formatCurrency(0.8), '\$0.80');
      expect(Formatters.formatCurrency(100.0), '\$100.00');
    });

    test('formatDuration formats minutes into readable format', () {
      expect(Formatters.formatDuration(5), '5 mins');
      expect(Formatters.formatDuration(60), '1h');
      expect(Formatters.formatDuration(75), '1h 15m');
    });

    test('formatTimer formats seconds into mm:ss', () {
      expect(Formatters.formatTimer(45), '00:45');
      expect(Formatters.formatTimer(125), '02:05');
    });
  });
}
