import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import '../models/reward_model.dart';
import '../models/marketplace_model.dart';
import '../models/community_model.dart';
import '../models/verification_model.dart';
import '../models/mission_model.dart';
import '../models/challenge_model.dart';
import '../models/gamification_model.dart';

/// Centralized mock data service providing realistic placeholder datasets for Phase 1 UI.
class DummyDataService {
  DummyDataService._();

  static const UserModel currentUser = UserModel(
    id: 'usr_001',
    username: 'alex_developer',
    email: 'alex.dev@vewra.io',
    avatarUrl: null,
    membershipTier: 'Gold Explorer',
    totalCoins: 3450,
    fiatBalance: 34.50,
    tasksCompleted: 54,
    totalMinutesWatched: 320,
    streakDays: 7,
    level: 14,
    xp: 2450,
    xpNextLevel: 3000,
    trustScore: 96,
    verificationStatus: 'Verified',
    subscriptionTier: 'Premium',
  );

  static const WalletModel currentWallet = WalletModel(
    balanceCoins: 3450,
    balanceFiat: 34.50,
    pendingCoins: 450,
    pendingFiat: 4.50,
    lifetimeCoins: 18200,
    lifetimeFiat: 182.00,
    currencySymbol: '\$',
  );

  static final List<TaskModel> tasks = [
    const TaskModel(
      id: 'task_001',
      title: 'Top 10 Flutter 3.22 Features You Need To Know in 2026',
      channelName: 'TechVanguard',
      description:
          'Explore groundbreaking new UI widgets, compiler optimizations, and web performance improvements introduced in the latest Flutter ecosystem release.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600&auto=format&fit=crop&q=80',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      searchKeywords: 'Flutter 3.22 features deep dive tutorial 2026',
      rewardCoins: 120,
      rewardFiat: 1.20,
      durationMinutes: 4,
      category: 'Video Tasks',
    ),
    const TaskModel(
      id: 'task_002',
      title: 'Building Scalable AI Agent Workflows in Cloud Infrastructure',
      channelName: 'CloudArchitect Academy',
      description:
          'Comprehensive architectural breakdown of modern autonomous agents, event orchestration, and resilient multi-model pipelines.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600&auto=format&fit=crop&q=80',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      searchKeywords: 'AI autonomous agent architecture enterprise systems',
      rewardCoins: 250,
      rewardFiat: 2.50,
      durationMinutes: 8,
      category: 'Video Tasks',
    ),
    const TaskModel(
      id: 'task_003',
      title: 'Next-Gen Game Engine Graphics & Ray Tracing Benchmark',
      channelName: 'NextGen Gaming Lab',
      description:
          'Real-time photorealism testing on modern GPUs comparing Unreal Engine 5.5 and custom Vulkan rendering pipelines.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=600&auto=format&fit=crop&q=80',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      searchKeywords: 'Unreal Engine 5 ray tracing performance test 4k',
      rewardCoins: 80,
      rewardFiat: 0.80,
      durationMinutes: 2,
      category: 'Video Tasks',
    ),
    const TaskModel(
      id: 'task_004',
      title: 'Global Fintech & Digital Banking Survey 2026',
      channelName: 'Market Insights Global',
      description:
          'Answer 8 quick questions about mobile banking preferences and earn instant coin rewards.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=600&auto=format&fit=crop&q=80',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      searchKeywords: 'Global consumer fintech survey',
      rewardCoins: 150,
      rewardFiat: 1.50,
      durationMinutes: 3,
      category: 'Surveys',
    ),
    const TaskModel(
      id: 'task_005',
      title: 'Follow & Retweet VEWRA Ecosystem Weekly Community Update',
      channelName: 'VEWRA Official',
      description:
          'Follow the official VEWRA handle and amplify the weekly ecosystem progress update to earn bonus coins.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=600&auto=format&fit=crop&q=80',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      searchKeywords: 'VEWRA official social channels',
      rewardCoins: 90,
      rewardFiat: 0.90,
      durationMinutes: 1,
      category: 'Social Tasks',
    ),
    const TaskModel(
      id: 'task_006',
      title: 'Weekend Watch Streak Master Challenge (30 Mins)',
      channelName: 'VEWRA Tournaments',
      description:
          'Complete 30 cumulative watch minutes across any educational or gaming video tasks this weekend to earn a 2x bonus.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=600&auto=format&fit=crop&q=80',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      searchKeywords: 'Weekend watch streak tournament challenge',
      rewardCoins: 500,
      rewardFiat: 5.00,
      durationMinutes: 30,
      category: 'Challenges',
    ),
  ];

  static const List<String> taskCategories = [
    'All',
    'Video Tasks',
    'Surveys',
    'Social Tasks',
    'Challenges',
  ];

  static final List<TransactionModel> transactions = [
    TransactionModel(
      id: 'tx_001',
      title: 'Task Watch Reward',
      type: TransactionType.taskReward,
      amountCoins: 120,
      amountFiat: 1.20,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    TransactionModel(
      id: 'tx_002',
      title: '7-Day Streak Bonus',
      type: TransactionType.dailyStreak,
      amountCoins: 300,
      amountFiat: 3.00,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    TransactionModel(
      id: 'tx_003',
      title: 'USDT Crypto Withdrawal',
      type: TransactionType.withdrawal,
      amountCoins: 1000,
      amountFiat: 10.00,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TransactionModel(
      id: 'tx_004',
      title: 'Referral Commission',
      type: TransactionType.referralBonus,
      amountCoins: 500,
      amountFiat: 5.00,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
    TransactionModel(
      id: 'tx_005',
      title: 'Marketplace Redemption',
      type: TransactionType.withdrawal,
      amountCoins: 1000,
      amountFiat: 10.00,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // Daily Streak Check-in Mock Data
  static final List<DailyRewardModel> dailyRewards = [
    const DailyRewardModel(day: 1, rewardCoins: 50, isClaimed: true),
    const DailyRewardModel(day: 2, rewardCoins: 75, isClaimed: true),
    const DailyRewardModel(day: 3, rewardCoins: 100, isClaimed: true),
    const DailyRewardModel(day: 4, rewardCoins: 125, isClaimed: true),
    const DailyRewardModel(day: 5, rewardCoins: 150, isClaimed: true),
    const DailyRewardModel(day: 6, rewardCoins: 200, isClaimed: true),
    const DailyRewardModel(day: 7, rewardCoins: 300, isToday: true, isClaimed: false),
  ];

  // Leaderboard Mock Data
  static final List<LeaderboardEntryModel> leaderboardEntries = [
    const LeaderboardEntryModel(rank: 1, username: 'crypto_knight', coinsEarned: 48500, tierBadge: 'Champion'),
    const LeaderboardEntryModel(rank: 2, username: 'sarah_streamer', coinsEarned: 42100, tierBadge: 'Master'),
    const LeaderboardEntryModel(rank: 3, username: 'dev_ninja_99', coinsEarned: 39800, tierBadge: 'Diamond'),
    const LeaderboardEntryModel(rank: 4, username: 'alex_developer', coinsEarned: 3450, tierBadge: 'Gold Explorer', isCurrentUser: true),
    const LeaderboardEntryModel(rank: 5, username: 'vanguard_user', coinsEarned: 3100, tierBadge: 'Silver'),
  ];

  // Achievements Mock Data
  static final List<AchievementModel> achievements = [
    const AchievementModel(
      id: 'ach_01',
      title: 'First Watch Verified',
      description: 'Complete your first verified YouTube watch task.',
      rewardCoins: 100,
      progress: 1.0,
      isCompleted: true,
      iconName: 'play_arrow',
    ),
    const AchievementModel(
      id: 'ach_02',
      title: '7-Day Streak Master',
      description: 'Log in and claim rewards 7 consecutive days.',
      rewardCoins: 300,
      progress: 1.0,
      isCompleted: true,
      iconName: 'local_fire_department',
    ),
    const AchievementModel(
      id: 'ach_03',
      title: 'Century Watcher (100 Tasks)',
      description: 'Complete 100 verified tasks on the platform.',
      rewardCoins: 1000,
      progress: 0.54,
      isCompleted: false,
      iconName: 'military_tech',
    ),
    const AchievementModel(
      id: 'ach_04',
      title: 'Community Champion',
      description: 'Publish 5 helpful discussion posts with 10+ likes.',
      rewardCoins: 500,
      progress: 0.40,
      isCompleted: false,
      iconName: 'forum',
    ),
  ];

  // Weekly Tournament Mock Data
  static const CompetitionModel activeTournament = CompetitionModel(
    id: 'comp_01',
    title: 'Weekly Grand Prix Tournament',
    description: 'Earn the highest coins from verified tasks this week to claim top pool rewards!',
    prizePool: '10,000 Coins (\$100 USD)',
    timeLeft: '2d 14h left',
    userRank: 4,
    participantsCount: 1420,
  );

  // Digital Marketplace Catalog Mock Data
  static final List<MarketplaceItemModel> marketplaceItems = [
    const MarketplaceItemModel(
      id: 'item_01',
      title: '\$10 Mobile Airtime / Data',
      providerOrSeller: 'Global Telecom & eSIM',
      category: 'Airtime & Data',
      priceCoins: 1000,
      priceFiat: 10.00,
      imageUrl: 'https://images.unsplash.com/photo-1556742049-0a67c5574f73?w=600&auto=format&fit=crop&q=80',
      description: 'Instant mobile top-up and data bundles supported across 140+ countries.',
      discountTag: 'Popular',
    ),
    const MarketplaceItemModel(
      id: 'item_02',
      title: '\$25 Amazon Digital Gift Card',
      providerOrSeller: 'Amazon Direct Codes',
      category: 'Gift Cards',
      priceCoins: 2500,
      priceFiat: 25.00,
      imageUrl: 'https://images.unsplash.com/photo-1512909006721-3d6018887383?w=600&auto=format&fit=crop&q=80',
      description: 'Redeemable instantly for any products across global Amazon regional stores.',
      discountTag: 'Zero Fee',
    ),
    const MarketplaceItemModel(
      id: 'item_03',
      title: '\$50 Apple App Store & iTunes Card',
      providerOrSeller: 'Apple Digital Services',
      category: 'Gift Cards',
      priceCoins: 5000,
      priceFiat: 50.00,
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600&auto=format&fit=crop&q=80',
      description: 'Purchase apps, in-game items, music, movies, and iCloud subscriptions.',
    ),
    const MarketplaceItemModel(
      id: 'item_04',
      title: 'Full-Stack Flutter & AI Agent Starter Kit',
      providerOrSeller: 'Vewra Academy Creator',
      category: 'Digital Products',
      priceCoins: 1500,
      priceFiat: 15.00,
      imageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=600&auto=format&fit=crop&q=80',
      description: 'Production-ready starter template with state management, clean architecture, and API hooks.',
      discountTag: '50% OFF',
    ),
    const MarketplaceItemModel(
      id: 'item_05',
      title: 'Sell 2,500 VEWRA Coins (P2P Trade)',
      providerOrSeller: 'Verified Trader @Sarah99 (Trust 98%)',
      category: 'Coin Marketplace',
      priceCoins: 2500,
      priceFiat: 24.50,
      imageUrl: 'https://images.unsplash.com/photo-1621416894569-0f39ed31d247?w=600&auto=format&fit=crop&q=80',
      description: 'Instant escrow transfer to your USDT wallet upon trade confirmation.',
      discountTag: 'Instant Escrow',
    ),
    const MarketplaceItemModel(
      id: 'item_06',
      title: 'Buy 1,000 VEWRA Coins (Special Deal)',
      providerOrSeller: 'Ecosystem Liquidity Pool',
      category: 'Coin Marketplace',
      priceCoins: 1000,
      priceFiat: 9.50,
      imageUrl: 'https://images.unsplash.com/photo-1622979135225-d2ba269bc1df?w=600&auto=format&fit=crop&q=80',
      description: 'Save 5% on direct coin purchases for video promotion campaigns.',
      discountTag: 'Save 5%',
    ),
  ];

  // Community Posts Mock Data
  static final List<CommunityPostModel> communityPosts = [
    const CommunityPostModel(
      id: 'post_01',
      authorName: 'Marcus Chen',
      authorTier: 'Top Earner Tier 3',
      content:
          'Pro tip for new earners: completing the morning 4-task streak unlocks the 1.25x XP multiplier for the rest of the day! Don\'t miss out.',
      categoryTag: 'Earning Tips',
      likesCount: 38,
      commentsCount: 12,
      timeAgo: '2h ago',
      isLiked: true,
    ),
    const CommunityPostModel(
      id: 'post_02',
      authorName: 'Elena Rostova',
      authorTier: 'Verified Creator',
      content:
          'Launched my new tech tutorial video campaign on VEWRA today. Loving the analytics and engagement quality from verified watchers!',
      categoryTag: 'Creator Spotlight',
      likesCount: 54,
      commentsCount: 19,
      timeAgo: '5h ago',
    ),
    const CommunityPostModel(
      id: 'post_03',
      authorName: 'DevTeam Official',
      authorTier: 'Community Champion',
      content:
          'Welcome to the VEWRA Ecosystem! The weekly \$500 Grand Prix tournament is now live. Complete daily missions to climb the leaderboard.',
      categoryTag: 'Announcements',
      likesCount: 128,
      commentsCount: 45,
      timeAgo: '1d ago',
      isLiked: true,
    ),
  ];

  // Verification Tiers Mock Data
  static final List<VerificationTierModel> verificationTiers = [
    const VerificationTierModel(
      title: 'Basic User',
      subtitle: 'Email & Phone verified',
      withdrawalLimit: 'Max \$5 / month',
      requirements: ['Email Confirmation', 'Phone SMS OTP'],
      benefits: ['Earn from tasks', 'Access community feed'],
      isUnlocked: true,
    ),
    const VerificationTierModel(
      title: 'Verified User',
      subtitle: 'Government ID & Liveness Selfie verified',
      withdrawalLimit: 'Standard \$500 / month',
      requirements: ['Government Photo ID', 'Liveness Face Verification'],
      benefits: ['Standard withdrawal limits', 'Full Marketplace buying access', 'Priority task feeds'],
      isCurrent: true,
      isUnlocked: true,
    ),
    const VerificationTierModel(
      title: 'Trusted User',
      subtitle: 'High activity history & 90+ Trust Score',
      withdrawalLimit: 'High \$5,000+ / month',
      requirements: ['30+ days account age', '90+ Trust Score', '50+ verified tasks'],
      benefits: ['Highest withdrawal limits', 'P2P Coin Marketplace selling privileges', 'Creator campaign tools'],
      isUnlocked: false,
    ),
  ];

  // Daily Missions Mock Data
  static final List<MissionModel> dailyMissions = [
    const MissionModel(
      id: 'msn_01',
      title: 'Watch 3 Video Tasks',
      description: 'Engage with and verify 3 video tasks in the Earn feed.',
      rewardCoins: 75,
      rewardXp: 150,
      currentCount: 2,
      targetCount: 3,
      category: 'Daily',
    ),
    const MissionModel(
      id: 'msn_02',
      title: 'Complete 1 Survey',
      description: 'Share feedback in a sponsored market research survey.',
      rewardCoins: 100,
      rewardXp: 200,
      currentCount: 1,
      targetCount: 1,
      isCompleted: true,
      category: 'Daily',
    ),
    const MissionModel(
      id: 'msn_03',
      title: 'Daily Check-in Streak',
      description: 'Claim your consecutive daily retention reward.',
      rewardCoins: 50,
      rewardXp: 100,
      currentCount: 1,
      targetCount: 1,
      isCompleted: true,
      isClaimed: true,
      category: 'Daily',
    ),
    const MissionModel(
      id: 'msn_04',
      title: 'Like 2 Community Posts',
      description: 'Interact with fellow earners in the Community Hub.',
      rewardCoins: 30,
      rewardXp: 50,
      currentCount: 1,
      targetCount: 2,
      category: 'Daily',
    ),
    const MissionModel(
      id: 'msn_05',
      title: 'Weekly 25-Task Marathon',
      description: 'Complete 25 verified tasks within 7 days.',
      rewardCoins: 500,
      rewardXp: 1000,
      currentCount: 18,
      targetCount: 25,
      category: 'Milestone',
    ),
  ];

  // Challenges Mock Data
  static final List<ChallengeModel> challenges = [
    const ChallengeModel(
      id: 'ch_01',
      title: 'Weekend Tech Explorer Sprint',
      description: 'Watch 45 cumulative minutes of Tech & AI videos this weekend to unlock the exclusive Tech Pioneer badge.',
      rewardCoins: 400,
      rewardXp: 600,
      rewardBadge: 'Tech Pioneer 2026',
      participantsCount: 840,
      timeLeft: '1d 18h left',
      progress: 0.65,
      isJoined: true,
      goalMetric: '29 / 45 Minutes',
    ),
    const ChallengeModel(
      id: 'ch_02',
      title: 'Speed Earner: 5 Tasks in 1 Hour',
      description: 'Complete 5 high-speed video verifications within 60 minutes.',
      rewardCoins: 250,
      rewardXp: 400,
      participantsCount: 320,
      timeLeft: '18h left',
      progress: 0.40,
      isJoined: false,
      goalMetric: '2 / 5 Tasks',
    ),
    const ChallengeModel(
      id: 'ch_03',
      title: 'Global Community Goal: 100k Hours Watched',
      description: 'All VEWRA users pool together to watch 100,000 hours this week. Unlocks a 2x coin multiplier event for all players!',
      rewardCoins: 1000,
      rewardXp: 2000,
      rewardBadge: 'Global Contributor',
      participantsCount: 14250,
      timeLeft: '3d left',
      progress: 0.78,
      isCommunityChallenge: true,
      isJoined: true,
      goalMetric: '78,400 / 100,000 Hours',
    ),
    const ChallengeModel(
      id: 'ch_04',
      title: 'Creator Community: 500 Video Campaigns',
      description: 'Creators launch 500 video promotion campaigns to boost global watch pool.',
      rewardCoins: 750,
      rewardXp: 1500,
      participantsCount: 410,
      timeLeft: '4d left',
      progress: 0.88,
      isCommunityChallenge: true,
      isJoined: false,
      goalMetric: '440 / 500 Campaigns',
    ),
  ];

  // Spin Wheel Rewards Mock Data
  static const List<SpinRewardModel> spinRewards = [
    SpinRewardModel(
      id: 'spin_01',
      label: '50 Coins',
      coins: 50,
      xp: 50,
      icon: Icons.monetization_on_rounded,
      color: Color(0xFF6366F1),
      probabilityText: '35% Chance',
    ),
    SpinRewardModel(
      id: 'spin_02',
      label: '100 Coins',
      coins: 100,
      xp: 100,
      icon: Icons.stars_rounded,
      color: Color(0xFF06B6D4),
      probabilityText: '25% Chance',
    ),
    SpinRewardModel(
      id: 'spin_03',
      label: '2x XP Boost',
      coins: 20,
      xp: 300,
      icon: Icons.bolt_rounded,
      color: Color(0xFF10B981),
      probabilityText: '15% Chance',
    ),
    SpinRewardModel(
      id: 'spin_04',
      label: '250 Coins',
      coins: 250,
      xp: 250,
      icon: Icons.card_giftcard_rounded,
      color: Color(0xFFF59E0B),
      probabilityText: '12% Chance',
    ),
    SpinRewardModel(
      id: 'spin_05',
      label: '500 Coins',
      coins: 500,
      xp: 500,
      icon: Icons.military_tech_rounded,
      color: Color(0xFFEC4899),
      probabilityText: '8% Chance',
    ),
    SpinRewardModel(
      id: 'spin_06',
      label: 'Jackpot Mystery Box',
      coins: 1000,
      xp: 1000,
      icon: Icons.diamond_rounded,
      color: Color(0xFFFFB800),
      probabilityText: '5% Chance',
    ),
  ];

  // Scratch Cards Mock Data
  static final List<ScratchCardModel> scratchCards = [
    const ScratchCardModel(
      id: 'scratch_01',
      title: 'Daily Gold Scratch Card',
      subtitle: 'Free daily scratch • Win up to 500 Coins',
      costCoins: 0,
      isFreeDaily: true,
      rewardCoins: 200,
      rewardXp: 250,
      rarity: 'Rare',
      cardColor: AppColors.amber,
    ),
    const ScratchCardModel(
      id: 'scratch_02',
      title: 'Diamond Earner Scratch Card',
      subtitle: 'VIP Card • Win up to 2,500 Coins',
      costCoins: 100,
      isFreeDaily: false,
      rewardCoins: 750,
      rewardXp: 800,
      rarity: 'Legendary',
      cardColor: AppColors.cyan,
    ),
  ];

  // Feature Unlock Progression Mock Data
  static final List<FeatureUnlockModel> featureUnlocks = [
    const FeatureUnlockModel(
      id: 'feat_01',
      featureName: 'P2P Coin Marketplace (Seller Mode)',
      description: 'Create sell offers and trade VEWRA coins directly with other verified community members.',
      icon: Icons.currency_exchange_rounded,
      requiredLevel: 5,
      requiredVerification: 'Verified Tier',
      requiredTrustScore: 80,
      isUnlocked: true,
      currentLevel: 14,
      currentTrustScore: 96,
      currentVerification: 'Verified',
    ),
    const FeatureUnlockModel(
      id: 'feat_02',
      featureName: 'Creator Hub Campaign Studio',
      description: 'Upload YouTube video links, set watch budgets, target viewer demographics, and track analytics.',
      icon: Icons.video_library_rounded,
      requiredLevel: 10,
      requiredVerification: 'Verified Tier',
      requiredTrustScore: 85,
      isUnlocked: true,
      currentLevel: 14,
      currentTrustScore: 96,
      currentVerification: 'Verified',
    ),
    const FeatureUnlockModel(
      id: 'feat_03',
      featureName: 'High-Stakes Tournament League',
      description: 'Participate in \$1,000+ weekly grand competitions and unlock custom badge cosmetics.',
      icon: Icons.emoji_events_rounded,
      requiredLevel: 20,
      requiredVerification: 'Trusted Tier',
      requiredTrustScore: 95,
      isUnlocked: false,
      currentLevel: 14,
      currentTrustScore: 96,
      currentVerification: 'Verified',
    ),
    const FeatureUnlockModel(
      id: 'feat_04',
      featureName: 'AI Strategy Advisor (Pro Mode)',
      description: 'Autonomous AI assistant that analyzes earning trends and recommends highest-yield task categories.',
      icon: Icons.smart_toy_rounded,
      requiredLevel: 25,
      requiredVerification: 'Trusted Tier',
      requiredTrustScore: 98,
      isUnlocked: false,
      currentLevel: 14,
      currentTrustScore: 96,
      currentVerification: 'Verified',
    ),
  ];
}
