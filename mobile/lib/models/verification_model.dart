/// Model representing verification tiers, requirements, and benefits
class VerificationTierModel {
  final String title;
  final String subtitle;
  final String withdrawalLimit;
  final List<String> requirements;
  final List<String> benefits;
  final bool isCurrent;
  final bool isUnlocked;

  const VerificationTierModel({
    required this.title,
    required this.subtitle,
    required this.withdrawalLimit,
    required this.requirements,
    required this.benefits,
    this.isCurrent = false,
    this.isUnlocked = false,
  });
}
