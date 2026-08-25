import 'package:flutter/material.dart';

/// Reward item slice for the daily Spin Wheel.
class SpinRewardModel {
  final String id;
  final String label;
  final int coins;
  final int xp;
  final IconData icon;
  final Color color;
  final String probabilityText;

  const SpinRewardModel({
    required this.id,
    required this.label,
    required this.coins,
    required this.xp,
    required this.icon,
    required this.color,
    required this.probabilityText,
  });
}

/// Scratch card item with hidden rewards.
class ScratchCardModel {
  final String id;
  final String title;
  final String subtitle;
  final int costCoins;
  final bool isFreeDaily;
  final int rewardCoins;
  final int rewardXp;
  final bool isScratched;
  final String rarity; // 'Common', 'Rare', 'Legendary'
  final Color cardColor;

  const ScratchCardModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.costCoins = 0,
    this.isFreeDaily = true,
    required this.rewardCoins,
    required this.rewardXp,
    this.isScratched = false,
    this.rarity = 'Rare',
    required this.cardColor,
  });
}

/// Model representing progressive feature unlocks based on Level, Verification, and Trust Score.
class FeatureUnlockModel {
  final String id;
  final String featureName;
  final String description;
  final IconData icon;
  final int requiredLevel;
  final String requiredVerification;
  final int requiredTrustScore;
  final bool isUnlocked;
  final int currentLevel;
  final int currentTrustScore;
  final String currentVerification;

  const FeatureUnlockModel({
    required this.id,
    required this.featureName,
    required this.description,
    required this.icon,
    required this.requiredLevel,
    required this.requiredVerification,
    required this.requiredTrustScore,
    this.isUnlocked = false,
    required this.currentLevel,
    required this.currentTrustScore,
    required this.currentVerification,
  });

  bool get isLevelMet => currentLevel >= requiredLevel;
  bool get isTrustMet => currentTrustScore >= requiredTrustScore;
}
