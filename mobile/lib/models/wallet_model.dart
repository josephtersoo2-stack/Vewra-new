/// Local Wallet Model representing balance, pending payouts, and lifetime earnings.
class WalletModel {
  final int balanceCoins;
  final double balanceFiat;
  final int pendingCoins;
  final double pendingFiat;
  final int lifetimeCoins;
  final double lifetimeFiat;
  final String currency;
  final String currencySymbol;

  const WalletModel({
    this.balanceCoins = 3450,
    this.balanceFiat = 34.50,
    this.pendingCoins = 450,
    this.pendingFiat = 4.50,
    this.lifetimeCoins = 18200,
    this.lifetimeFiat = 182.00,
    this.currency = 'USD',
    this.currencySymbol = '\$',
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final coinBal = (json['coin_balance'] as num?)?.toInt() ??
        (json['balanceCoins'] as num?)?.toInt() ??
        0;
    final cashBal = double.tryParse(json['cash_balance']?.toString() ?? '') ??
        (json['balanceFiat'] as num?)?.toDouble() ??
        (coinBal * 0.01);
    final pendCoins = (json['pending_coins'] as num?)?.toInt() ??
        (json['pendingCoins'] as num?)?.toInt() ??
        0;
    final pendFiat = double.tryParse(json['pending_cash']?.toString() ?? '') ??
        (json['pendingFiat'] as num?)?.toDouble() ??
        (pendCoins * 0.01);
    final lifeCoins = (json['lifetime_coins'] as num?)?.toInt() ??
        (json['lifetimeCoins'] as num?)?.toInt() ??
        coinBal;
    final lifeFiat = double.tryParse(json['lifetime_cash']?.toString() ?? '') ??
        (json['lifetimeFiat'] as num?)?.toDouble() ??
        (lifeCoins * 0.01);
    final curr = json['currency']?.toString() ?? 'USD';

    return WalletModel(
      balanceCoins: coinBal,
      balanceFiat: cashBal,
      pendingCoins: pendCoins,
      pendingFiat: pendFiat,
      lifetimeCoins: lifeCoins,
      lifetimeFiat: lifeFiat,
      currency: curr,
      currencySymbol: curr == 'EUR' ? '€' : (curr == 'GBP' ? '£' : '\$'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coin_balance': balanceCoins,
      'cash_balance': balanceFiat,
      'pending_coins': pendingCoins,
      'pending_cash': pendingFiat,
      'lifetime_coins': lifetimeCoins,
      'lifetime_cash': lifetimeFiat,
      'currency': currency,
    };
  }

  WalletModel copyWith({
    int? balanceCoins,
    double? balanceFiat,
    int? pendingCoins,
    double? pendingFiat,
    int? lifetimeCoins,
    double? lifetimeFiat,
    String? currency,
    String? currencySymbol,
  }) {
    return WalletModel(
      balanceCoins: balanceCoins ?? this.balanceCoins,
      balanceFiat: balanceFiat ?? this.balanceFiat,
      pendingCoins: pendingCoins ?? this.pendingCoins,
      pendingFiat: pendingFiat ?? this.pendingFiat,
      lifetimeCoins: lifetimeCoins ?? this.lifetimeCoins,
      lifetimeFiat: lifetimeFiat ?? this.lifetimeFiat,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }
}
