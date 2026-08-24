/// Formatting utility methods for currency, coins, numbers, and durations.
class Formatters {
  Formatters._();

  /// Formats coin count with comma separators, e.g. 1,250 Coins
  static String formatCoins(int coins) {
    final str = coins.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write(',');
      }
    }
    return '${buffer.toString().split('').reversed.join()} Coins';
  }

  /// Formats fiat currency e.g. $12.50
  static String formatCurrency(double amount, [String symbol = '\$']) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Formats minutes into standard duration string e.g. "3 mins" or "1h 15m"
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes mins';
    }
    final hours = minutes ~/ 60;
    final remainingMins = minutes % 60;
    if (remainingMins == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMins}m';
  }

  /// Formats seconds into mm:ss timer format
  static String formatTimer(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    final minsStr = mins.toString().padLeft(2, '0');
    final secsStr = secs.toString().padLeft(2, '0');
    return '$minsStr:$secsStr';
  }
}
