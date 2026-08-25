enum MarketplaceCategory {
  airtimeData,
  giftCards,
  digitalProducts,
  coinMarketplace,
}

/// Model representing items available in the VEWRA digital & utility marketplace
class MarketplaceItemModel {
  final String id;
  final String title;
  final String providerOrSeller;
  final String category;
  final int priceCoins;
  final double priceFiat;
  final String imageUrl;
  final String description;
  final String? discountTag;
  final double rating;

  const MarketplaceItemModel({
    required this.id,
    required this.title,
    required this.providerOrSeller,
    required this.category,
    required this.priceCoins,
    required this.priceFiat,
    required this.imageUrl,
    required this.description,
    this.discountTag,
    this.rating = 4.9,
  });
}
