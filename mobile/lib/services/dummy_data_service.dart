import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';

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
      category: 'Tech',
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
      category: 'High Reward',
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
      category: 'Quick 2-Min',
    ),
    const TaskModel(
      id: 'task_004',
      title: 'Mastering Clean Architecture with Riverpod & Dart 3',
      channelName: 'Mobile Crafted',
      description:
          'Step-by-step practical implementation of dependency injection, repository patterns, and immutable state management.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=600&auto=format&fit=crop&q=80',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      searchKeywords: 'Flutter clean architecture repository riverpod guide',
      rewardCoins: 160,
      rewardFiat: 1.60,
      durationMinutes: 5,
      category: 'Tech',
    ),
    const TaskModel(
      id: 'task_005',
      title: 'Cyberpunk 2077 Ultra Modded 8K Cinematic Showcase',
      channelName: 'HyperVisuals',
      description:
          'Experience Night City transformed with over 300 path tracing mods and ultra photorealistic texture overhauls.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=600&auto=format&fit=crop&q=80',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      searchKeywords: 'Cyberpunk path tracing mod 8k gameplay ultra settings',
      rewardCoins: 95,
      rewardFiat: 0.95,
      durationMinutes: 3,
      category: 'Gaming',
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
      title: 'PayPal Withdrawal Transfer',
      type: TransactionType.withdrawal,
      amountCoins: 1000,
      amountFiat: 10.00,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      status: TransactionStatus.completed,
      reference: 'PP-98234-X',
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
    'High Reward',
    'Quick 2-Min',
    'Tech',
    'Gaming',
  ];
}
