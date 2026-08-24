enum TransactionType { taskReward, withdrawal, referralBonus, dailyStreak }

enum TransactionStatus { completed, pending, failed }

/// Local Transaction Model representing earning and payout events.
class TransactionModel {
  final String id;
  final String title;
  final TransactionType type;
  final int amountCoins;
  final double amountFiat;
  final DateTime timestamp;
  final TransactionStatus status;
  final String? reference;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.type,
    required this.amountCoins,
    required this.amountFiat,
    required this.timestamp,
    this.status = TransactionStatus.completed,
    this.reference,
  });

  bool get isPositive =>
      type == TransactionType.taskReward ||
      type == TransactionType.referralBonus ||
      type == TransactionType.dailyStreak;
}
