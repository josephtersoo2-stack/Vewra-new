/// User Model representing the profile and state of a VEWRA user.
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};

    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: profile['avatar']?.toString() ?? json['avatarUrl']?.toString(),
      membershipTier: json['membershipTier']?.toString() ??
          (profile['subscription_tier']?.toString() ?? 'Gold Explorer'),
      totalCoins: (profile['total_coins'] as num?)?.toInt() ??
          (json['totalCoins'] as num?)?.toInt() ??
          0,
      fiatBalance: double.tryParse(profile['fiat_balance']?.toString() ?? '') ??
          (json['fiatBalance'] as num?)?.toDouble() ??
          0.0,
      tasksCompleted: (profile['tasks_completed'] as num?)?.toInt() ??
          (json['tasksCompleted'] as num?)?.toInt() ??
          0,
      totalMinutesWatched: (json['totalMinutesWatched'] as num?)?.toInt() ?? 0,
      streakDays: (profile['streak_days'] as num?)?.toInt() ??
          (json['streakDays'] as num?)?.toInt() ??
          1,
      level: (profile['level'] as num?)?.toInt() ??
          (json['level'] as num?)?.toInt() ??
          1,
      xp: (profile['xp'] as num?)?.toInt() ??
          (json['xp'] as num?)?.toInt() ??
          0,
      xpNextLevel: (profile['xp_next_level'] as num?)?.toInt() ??
          (json['xpNextLevel'] as num?)?.toInt() ??
          1000,
      trustScore: (profile['trust_score'] as num?)?.toInt() ??
          (json['trustScore'] as num?)?.toInt() ??
          75,
      verificationStatus: profile['verification_status']?.toString() ??
          json['verificationStatus']?.toString() ??
          'Basic',
      subscriptionTier: profile['subscription_tier']?.toString() ??
          json['subscriptionTier']?.toString() ??
          'Free',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'membershipTier': membershipTier,
      'totalCoins': totalCoins,
      'fiatBalance': fiatBalance,
      'tasksCompleted': tasksCompleted,
      'totalMinutesWatched': totalMinutesWatched,
      'streakDays': streakDays,
      'level': level,
      'xp': xp,
      'xpNextLevel': xpNextLevel,
      'trustScore': trustScore,
      'verificationStatus': verificationStatus,
      'subscriptionTier': subscriptionTier,
    };
  }

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
