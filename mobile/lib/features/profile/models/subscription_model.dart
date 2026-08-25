/// Model representing a subscription tier plan.
class SubscriptionTierModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final double monthlyPrice;
  final double annualPrice;
  final List<String> benefits;
  final bool active;

  const SubscriptionTierModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.benefits,
    this.active = true,
  });

  factory SubscriptionTierModel.fromJson(Map<String, dynamic> json) {
    final rawBenefits = json['benefits'];
    List<String> parsedBenefits = [];
    if (rawBenefits is List) {
      parsedBenefits = rawBenefits.map((e) => e.toString()).toList();
    }

    return SubscriptionTierModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? 'FREE',
      slug: json['slug']?.toString() ?? 'free',
      description: json['description']?.toString() ?? '',
      monthlyPrice: double.tryParse(json['monthly_price']?.toString() ?? '') ??
          (json['monthly_price'] as num?)?.toDouble() ??
          0.0,
      annualPrice: double.tryParse(json['annual_price']?.toString() ?? '') ??
          (json['annual_price'] as num?)?.toDouble() ??
          0.0,
      benefits: parsedBenefits,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'monthly_price': monthlyPrice,
      'annual_price': annualPrice,
      'benefits': benefits,
      'active': active,
    };
  }
}

/// Model representing the user's active membership subscription.
class UserSubscriptionModel {
  final int id;
  final SubscriptionTierModel tier;
  final bool isActive;
  final bool autoRenew;
  final DateTime? expiresAt;

  const UserSubscriptionModel({
    required this.id,
    required this.tier,
    this.isActive = true,
    this.autoRenew = false,
    this.expiresAt,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tier: json['tier'] != null
          ? SubscriptionTierModel.fromJson(json['tier'] as Map<String, dynamic>)
          : const SubscriptionTierModel(
              id: 0,
              name: 'FREE',
              slug: 'free',
              description: 'Standard plan',
              monthlyPrice: 0.0,
              annualPrice: 0.0,
              benefits: [],
            ),
      isActive: json['is_active'] as bool? ?? true,
      autoRenew: json['auto_renew'] as bool? ?? false,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
    );
  }
}
