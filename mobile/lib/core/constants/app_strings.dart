/// Centralized user-facing strings across the VEWRA application.
class AppStrings {
  AppStrings._();

  // General
  static const String appName = 'VEWRA';
  static const String appTagline = 'Watch. Verify. Earn.';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String confirm = 'Confirm';
  static const String continueText = 'Continue';
  static const String seeAll = 'See All';
  static const String viewDetails = 'View Details';

  // Auth & Onboarding
  static const String welcomeTitle = 'Earn Rewards with Verified Content';
  static const String welcomeSubtitle =
      'Watch verified videos, complete interactive tasks, and get rewarded directly to your wallet.';
  static const String getStarted = 'Get Started';
  static const String login = 'Log In';
  static const String register = 'Create Account';
  static const String email = 'Email Address';
  static const String emailPlaceholder = 'name@example.com';
  static const String username = 'Username';
  static const String usernamePlaceholder = 'vewra_user';
  static const String password = 'Password';
  static const String passwordPlaceholder = '••••••••';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String forgotPasswordTitle = 'Reset Your Password';
  static const String forgotPasswordSubtitle =
      'Enter your email address and we\'ll send you a recovery link.';
  static const String sendResetLink = 'Send Reset Link';
  static const String resetLinkSent = 'Recovery email sent! Check your inbox.';
  static const String haveAccount = 'Already have an account? Log In';
  static const String noAccount = 'Don\'t have an account? Sign Up';
  static const String agreeTerms =
      'By signing up, you agree to the Terms of Service and Privacy Policy.';

  // Home Dashboard
  static const String greeting = 'Welcome back';
  static const String totalEarnings = 'Total Balance';
  static const String pendingRewards = 'Pending Rewards';
  static const String dailyGoal = 'Daily Goal';
  static const String tasksCompleted = 'Tasks Completed';
  static const String minutesWatched = 'Minutes Watched';
  static const String featuredTasks = 'Trending Tasks';
  static const String recommendedTasks = 'Recommended For You';
  static const String quickActions = 'Quick Actions';

  // Tasks
  static const String tasks = 'Tasks';
  static const String allTasks = 'All';
  static const String highReward = 'High Reward';
  static const String quickTasks = 'Quick 2-Min';
  static const String tech = 'Tech';
  static const String gaming = 'Gaming';
  static const String startTask = 'Start Task';
  static const String taskDetails = 'Task Details';
  static const String taskInstructions = 'Instructions';
  static const String searchInstructions = 'Search Keywords';
  static const String rewardInfo = 'Reward Payout';
  static const String duration = 'Duration';
  static const String startWatching = 'Start Watching & Verify';
  static const String howItWorks = 'How it works';
  static const String rule1 = '1. Tap Start Watching to launch YouTube in our secure viewer.';
  static const String rule2 = '2. Watch the video for the required duration without skipping.';
  static const String rule3 = '3. Rewards are verified and automatically credited to your wallet.';

  // Browser & Tracking
  static const String browser = 'VEWRA Viewer';
  static const String trackingActive = 'Tracking Active';
  static const String progress = 'Progress';
  static const String pauseTracking = 'Pause';
  static const String resumeTracking = 'Resume';
  static const String completeVerification = 'Verify & Claim Reward';
  static const String videoPlaybackDesc =
      'Secure tracking active. Keep video in viewport to accumulate rewards.';

  // Wallet
  static const String wallet = 'Wallet';
  static const String availableBalance = 'Available Balance';
  static const String lifetimeEarnings = 'Lifetime Earned';
  static const String withdraw = 'Withdraw';
  static const String convert = 'Convert';
  static const String history = 'History';
  static const String transactionHistory = 'Transaction History';
  static const String noTransactions = 'No transactions yet.';
  static const String noTransactionsDesc =
      'Complete tasks to start earning coins and view your payout records.';

  // Profile
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String membershipTier = 'Tier Status';
  static const String standardTier = 'Gold Explorer';
  static const String statsOverview = 'Statistics';
  static const String paymentMethods = 'Payment Methods';
  static const String referFriend = 'Refer a Friend';
  static const String helpSupport = 'Help & Support';

  // Settings
  static const String settings = 'Settings';
  static const String preferences = 'Preferences';
  static const String pushNotifications = 'Push Notifications';
  static const String soundEffects = 'Sound Effects';
  static const String darkMode = 'Dark Mode';
  static const String security = 'Security';
  static const String biometricLogin = 'Biometric Login';
  static const String changePassword = 'Change Password';
  static const String legal = 'Legal';
  static const String termsOfService = 'Terms of Service';
  static const String privacyPolicy = 'Privacy Policy';
  static const String logout = 'Log Out';
  static const String logoutConfirm = 'Are you sure you want to log out?';

  // Empty & Error States
  static const String emptyTasksTitle = 'No Tasks Available';
  static const String emptyTasksDesc = 'Check back shortly for new video tasks and opportunities.';
  static const String errorTitle = 'Something went wrong';
  static const String errorDesc = 'Failed to load content. Please check your internet connection.';
}
