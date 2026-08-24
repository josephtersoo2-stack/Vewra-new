/// Local Wallet Model representing balance, pending payouts, and lifetime earnings.
class WalletModel {
  final int balanceCoins;
  final double balanceFiat;
  final int pendingCoins;
  final double pendingFiat;
  final int lifetimeCoins;
  final double lifetimeFiat;
  final String currencySymbol;

  const WalletModel({
    this.balanceCoins = 2450,
    this.balanceFiat = 24.50,
    this.pendingCoins = 320,
    this.pendingFiat = 3.20,
    this.lifetimeCoins = 14800,
    this.lifetimeFiat = 148.00,
    this.currencySymbol = '\$',
  });

  WalletModel copyWith({
    int? balanceCoins,
    double? balanceFiat,
    int? pendingCoins,
    double? pendingFiat,
    int? lifetimeCoins,
    double? lifetimeFiat,
    String? currencySymbol,
  }) {
    return WalletModel(
      balanceCoins: balanceCoins ?? this.balanceCoins,
      balanceFiat: balanceFiat ?? this.balanceFiat,
      pendingCoins: pendingCoins ?? this.pendingCoins,
      pendingFiat: pendingFiat ?? this.pendingFiat,
      lifetimeCoins: lifetimeCoins ?? this.lifetimeCoins,
      lifetimeFiat: lifetimeFiat ?? this.lifetimeFiat,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }
}
