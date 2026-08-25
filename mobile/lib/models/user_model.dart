/// Local User Model representing the profile and state of the current VEWRA user.
class UserModel {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String membershipTier;
  final int totalCoins;
  final double fiatBalance;
  final int tasksCompleted;
  final int totalMinutesWatched;
  final int streakDays;

  // Retrofit attributes for Level, Trust & Verification
  final int level;
  final int xp;
  final int xpNextLevel;
  final int trustScore;
  final String verificationStatus; // e.g. 'Basic', 'Verified', 'Trusted'
  final String subscriptionTier; // e.g. 'Free', 'Premium', 'Creator', 'Business'

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.membershipTier = 'Gold Explorer',
    this.totalCoins = 3450,
    this.fiatBalance = 34.50,
    this.tasksCompleted = 54,
    this.totalMinutesWatched = 320,
    this.streakDays = 7,
    this.level = 14,
    this.xp = 2450,
    this.xpNextLevel = 3000,
    this.trustScore = 96,
    this.verificationStatus = 'Verified',
    this.subscriptionTier = 'Premium',
  });

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    String? membershipTier,
    int? totalCoins,
    double? fiatBalance,
    int? tasksCompleted,
    int? totalMinutesWatched,
    int? streakDays,
    int? level,
    int? xp,
    int? xpNextLevel,
    int? trustScore,
    String? verificationStatus,
    String? subscriptionTier,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      membershipTier: membershipTier ?? this.membershipTier,
      totalCoins: totalCoins ?? this.totalCoins,
      fiatBalance: fiatBalance ?? this.fiatBalance,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      totalMinutesWatched: totalMinutesWatched ?? this.totalMinutesWatched,
      streakDays: streakDays ?? this.streakDays,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpNextLevel: xpNextLevel ?? this.xpNextLevel,
      trustScore: trustScore ?? this.trustScore,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
    );
  }
}
