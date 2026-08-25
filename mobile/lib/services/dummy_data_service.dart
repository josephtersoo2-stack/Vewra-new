import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import '../models/reward_model.dart';
import '../models/marketplace_model.dart';
import '../models/community_model.dart';
import '../models/verification_model.dart';

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
      title: 'Follow & Share VEWRA Official Community Channel',
      channelName: 'VEWRA Official',
      description:
          'Join our global creator network, share our launch announcement, and verify your invite link.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=600&auto=format&fit=crop&q=80',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      searchKeywords: 'VEWRA official community challenge',
      rewardCoins: 300,
      rewardFiat: 3.00,
      durationMinutes: 5,
      category: 'Social Tasks',
    ),
    const TaskModel(
      id: 'task_006',
      title: '5-Day Watch Streak Master Challenge',
      channelName: 'VEWRA Gamification Hub',
      description:
          'Complete at least 3 video tasks every day for 5 consecutive days to unlock a 500 coin bonus prize.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=600&auto=format&fit=crop&q=80',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      searchKeywords: 'VEWRA 5-day streak challenge',
      rewardCoins: 500,
      rewardFiat: 5.00,
      durationMinutes: 10,
      category: 'Challenges',
    ),
  ];

  static final List<TransactionModel> transactions = [
    TransactionModel(
      id: 'tx_001',
      title: 'Task: Flutter 3.22 Deep Dive',
      type: TransactionType.taskReward,
      amountCoins: 120,
      amountFiat: 1.20,
      timestamp: DateTime.now().subtract(const Duration(minutes: 42)),
      status: TransactionStatus.completed,
    ),
    TransactionModel(
      id: 'tx_002',
      title: '7-Day Streak Bonus',
      type: TransactionType.dailyStreak,
      amountCoins: 200,
      amountFiat: 2.00,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      status: TransactionStatus.completed,
    ),
    TransactionModel(
      id: 'tx_003',
      title: 'USDT Crypto Withdrawal Transfer',
      type: TransactionType.withdrawal,
      amountCoins: 1000,
      amountFiat: 10.00,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      status: TransactionStatus.completed,
      reference: 'TX-USDT-98234-X',
    ),
    TransactionModel(
      id: 'tx_004',
      title: 'Friend Referral Bonus (emma_99)',
      type: TransactionType.referralBonus,
      amountCoins: 500,
      amountFiat: 5.00,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      status: TransactionStatus.completed,
    ),
    TransactionModel(
      id: 'tx_005',
      title: 'Task: Unreal Engine 5 Benchmark',
      type: TransactionType.taskReward,
      amountCoins: 80,
      amountFiat: 0.80,
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      status: TransactionStatus.completed,
    ),
  ];

  static List<String> taskCategories = [
    'All',
    'Video Tasks',
    'Surveys',
    'Social Tasks',
    'Challenges',
  ];

  // Daily Check-in Streak Mock Data
  static final List<DailyRewardModel> dailyRewards = [
    const DailyRewardModel(day: 1, rewardCoins: 50, isClaimed: true),
    const DailyRewardModel(day: 2, rewardCoins: 60, isClaimed: true),
    const DailyRewardModel(day: 3, rewardCoins: 75, isClaimed: true),
    const DailyRewardModel(day: 4, rewardCoins: 90, isClaimed: true),
    const DailyRewardModel(day: 5, rewardCoins: 120, isClaimed: true),
    const DailyRewardModel(day: 6, rewardCoins: 150, isClaimed: true),
    const DailyRewardModel(day: 7, rewardCoins: 300, isClaimed: false, isToday: true),
  ];

  // Leaderboard Mock Data
  static final List<LeaderboardEntryModel> leaderboardEntries = [
    const LeaderboardEntryModel(
      rank: 1,
      username: 'crypto_knight',
      coinsEarned: 48500,
      tierBadge: 'Champion',
    ),
    const LeaderboardEntryModel(
      rank: 2,
      username: 'sarah_creator',
      coinsEarned: 42100,
      tierBadge: 'Diamond',
    ),
    const LeaderboardEntryModel(
      rank: 3,
      username: 'dev_master99',
      coinsEarned: 38900,
      tierBadge: 'Platinum',
    ),
    const LeaderboardEntryModel(
      rank: 4,
      username: 'alex_developer',
      coinsEarned: 3450,
      tierBadge: 'Gold Explorer',
      isCurrentUser: true,
    ),
    const LeaderboardEntryModel(
      rank: 5,
      username: 'marcus_tech',
      coinsEarned: 3100,
      tierBadge: 'Gold Explorer',
    ),
  ];

  // Achievements Mock Data
  static final List<AchievementModel> achievements = [
    const AchievementModel(
      id: 'ach_1',
      title: 'First Watch Verified',
      description: 'Complete your first video task with 100% watch verification.',
      rewardCoins: 100,
      progress: 1.0,
      isCompleted: true,
      iconName: 'check_circle',
    ),
    const AchievementModel(
      id: 'ach_2',
      title: 'Streak Master (7 Days)',
      description: 'Check in and complete tasks for 7 consecutive days.',
      rewardCoins: 250,
      progress: 1.0,
      isCompleted: true,
      iconName: 'local_fire_department',
    ),
    const AchievementModel(
      id: 'ach_3',
      title: 'Century Watcher (100 Tasks)',
      description: 'Successfully complete 100 verified tasks on VEWRA.',
      rewardCoins: 500,
      progress: 0.54,
      isCompleted: false,
      iconName: 'military_tech',
    ),
    const AchievementModel(
      id: 'ach_4',
      title: 'Community Champion',
      description: 'Post 10 high-engagement contributions in community discussions.',
      rewardCoins: 300,
      progress: 0.30,
      isCompleted: false,
      iconName: 'forum',
    ),
  ];

  // Tournament / Competition Mock Data
  static const CompetitionModel activeTournament = CompetitionModel(
    id: 'comp_01',
    title: 'Weekly Creator & Watcher Grand Prix',
    description: 'Compete against global users for top watch time and engagement score.',
    prizePool: '\$500 Cash + 50,000 Coins',
    timeLeft: '2d 14h 32m',
    participantsCount: 1420,
    userRank: 12,
  );

  // Marketplace Items Mock Data
  static final List<MarketplaceItemModel> marketplaceItems = [
    const MarketplaceItemModel(
      id: 'mkt_01',
      title: '\$10 Mobile Airtime & Data Top-Up',
      providerOrSeller: 'Global Telecom Network',
      category: 'Airtime & Data',
      priceCoins: 1000,
      priceFiat: 10.00,
      imageUrl: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=600&auto=format&fit=crop&q=80',
      description: 'Instant recharge voucher valid across 120+ countries and carriers.',
      discountTag: 'Popular',
    ),
    const MarketplaceItemModel(
      id: 'mkt_02',
      title: '\$25 Amazon Digital Gift Card',
      providerOrSeller: 'Amazon Digital Codes',
      category: 'Gift Cards',
      priceCoins: 2500,
      priceFiat: 25.00,
      imageUrl: 'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?w=600&auto=format&fit=crop&q=80',
      description: 'Redeemable for millions of products with instant delivery to email.',
      discountTag: 'Top Seller',
    ),
    const MarketplaceItemModel(
      id: 'mkt_03',
      title: '\$20 Steam / Gaming Wallet Code',
      providerOrSeller: 'Valve Gaming Network',
      category: 'Gift Cards',
      priceCoins: 2000,
      priceFiat: 20.00,
      imageUrl: 'https://images.unsplash.com/photo-1612287233200-58045a165979?w=600&auto=format&fit=crop&q=80',
      description: 'Add instant funds to your Steam wallet for games and DLCs.',
    ),
    const MarketplaceItemModel(
      id: 'mkt_04',
      title: 'AI Video Prompting & Creator Masterclass',
      providerOrSeller: 'Vewra Academy',
      category: 'Digital Products',
      priceCoins: 1500,
      priceFiat: 15.00,
      imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600&auto=format&fit=crop&q=80',
      description: 'Comprehensive 4-hour video course with verified completion certificate.',
      discountTag: 'Exclusive',
    ),
    const MarketplaceItemModel(
      id: 'mkt_05',
      title: 'P2P Coin Trade: 5,000 Coins -> USDT',
      providerOrSeller: 'Verified Seller (Trust Score 99)',
      category: 'Coin Marketplace',
      priceCoins: 5000,
      priceFiat: 50.00,
      imageUrl: 'https://images.unsplash.com/photo-1621416894569-0f39ed31d247?w=600&auto=format&fit=crop&q=80',
      description: 'Escrow protected coin trade with instant crypto transfer upon confirmation.',
      discountTag: 'Escrow Active',
    ),
  ];

  // Community Posts Mock Data
  static final List<CommunityPostModel> communityPosts = [
    const CommunityPostModel(
      id: 'post_01',
      authorName: 'Marcus Chen',
      authorTier: 'Top Promoter',
      content:
          'Just hit a 14-day streak on VEWRA! The new high-reward video tasks are super engaging. Make sure to claim your daily check-in bonus every morning!',
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
}
