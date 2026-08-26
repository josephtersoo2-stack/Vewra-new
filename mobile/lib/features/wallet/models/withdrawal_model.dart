/// Model representing a user payout withdrawal request.
class WithdrawalModel {
  final String id;
  final double amount;
  final int coinsDeducted;
  final String currency;
  final String method;
  final String status;
  final String destination;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? processedAt;

  const WithdrawalModel({
    required this.id,
    required this.amount,
    required this.coinsDeducted,
    required this.currency,
    required this.method,
    required this.status,
    required this.destination,
    this.adminNotes,
    required this.createdAt,
    this.processedAt,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: json['id']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      coinsDeducted: (json['coins_deducted'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'USD',
      method: json['method']?.toString() ?? 'USDT',
      status: json['status']?.toString() ?? 'PENDING',
      destination: json['destination']?.toString() ?? '',
      adminNotes: json['admin_notes']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      processedAt: json['processed_at'] != null
          ? DateTime.tryParse(json['processed_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'coins_deducted': coinsDeducted,
      'currency': currency,
      'method': method,
      'status': status,
      'destination': destination,
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
    };
  }
}
