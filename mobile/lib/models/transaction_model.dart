enum TransactionType { taskReward, withdrawal, referralBonus, dailyStreak, transfer, purchase, sale, promotion, bonus, adjustment }

enum TransactionStatus { completed, pending, failed, cancelled, processing, rejected }

/// Unified Transaction Model representing earning, transfer, and payout events.
class TransactionModel {
  final String id;
  final String title;
  final TransactionType type;
  final int amountCoins;
  final double amountFiat;
  final DateTime timestamp;
  final TransactionStatus status;
  final String? reference;
  final String? description;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.type,
    required this.amountCoins,
    required this.amountFiat,
    required this.timestamp,
    this.status = TransactionStatus.completed,
    this.reference,
    this.description,
  });

  factory TransactionModel.fromCoinJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?)?.toInt() ?? 0;
    final txTypeStr = json['transaction_type']?.toString().toUpperCase() ?? 'REWARD';
    final desc = json['description']?.toString() ?? 'Coin Transaction';
    final ref = json['reference']?.toString();
    final dateStr = json['created_at']?.toString();
    final dt = dateStr != null ? DateTime.tryParse(dateStr) ?? DateTime.now() : DateTime.now();

    TransactionType type = TransactionType.taskReward;
    if (txTypeStr == 'TRANSFER') {
      type = TransactionType.transfer;
    } else if (txTypeStr == 'WITHDRAWAL') {
      type = TransactionType.withdrawal;
    } else if (txTypeStr == 'BONUS') {
      type = TransactionType.dailyStreak;
    } else if (txTypeStr == 'PURCHASE') {
      type = TransactionType.purchase;
    } else if (txTypeStr == 'SALE') {
      type = TransactionType.sale;
    } else if (txTypeStr == 'PROMOTION') {
      type = TransactionType.promotion;
    }

    return TransactionModel(
      id: json['id']?.toString() ?? '',
      title: desc,
      type: type,
      amountCoins: amount.abs(),
      amountFiat: (amount.abs() * 0.01),
      timestamp: dt,
      status: TransactionStatus.completed,
      reference: ref,
      description: desc,
    );
  }

  factory TransactionModel.fromCashJson(Map<String, dynamic> json) {
    final amount = double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0;
    final txTypeStr = json['transaction_type']?.toString().toUpperCase() ?? 'REWARD';
    final statusStr = json['status']?.toString().toUpperCase() ?? 'COMPLETED';
    final desc = json['description']?.toString() ?? 'Cash Transaction';
    final ref = json['reference']?.toString();
    final dateStr = json['created_at']?.toString();
    final dt = dateStr != null ? DateTime.tryParse(dateStr) ?? DateTime.now() : DateTime.now();

    TransactionStatus status = TransactionStatus.completed;
    if (statusStr == 'PENDING') status = TransactionStatus.pending;
    if (statusStr == 'FAILED') status = TransactionStatus.failed;
    if (statusStr == 'CANCELLED') status = TransactionStatus.cancelled;

    TransactionType type = TransactionType.taskReward;
    if (txTypeStr == 'WITHDRAWAL') type = TransactionType.withdrawal;
    if (txTypeStr == 'DEPOSIT') type = TransactionType.bonus;

    return TransactionModel(
      id: json['id']?.toString() ?? '',
      title: desc,
      type: type,
      amountCoins: (amount.abs() * 100).toInt(),
      amountFiat: amount.abs(),
      timestamp: dt,
      status: status,
      reference: ref,
      description: desc,
    );
  }

  bool get isPositive =>
      type == TransactionType.taskReward ||
      type == TransactionType.referralBonus ||
      type == TransactionType.dailyStreak ||
      type == TransactionType.bonus ||
      type == TransactionType.sale;
}
