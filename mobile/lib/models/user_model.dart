import '../features/profile/models/preference_model.dart';
import '../features/profile/models/statistics_model.dart';

/// User Model representing the profile and state of a VEWRA user.
class UserModel {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String bio;
  final String country;
  final String city;
  final String language;
  final String currency;
  final String timezone;
  final String gender;
  final String? dateOfBirth;

  final String membershipTier;
  final int totalCoins;
  final double fiatBalance;
  final int tasksCompleted;
  final int totalMinutesWatched;
  final int streakDays;

  // Level, Trust & Verification
  final int level;
  final int xp;
  final int xpNextLevel;
  final int trustScore;
  final String verificationStatus; // e.g. 'Basic', 'Pending Review', 'Verified', 'Trusted'
  final String subscriptionTier; // e.g. 'FREE', 'PREMIUM', 'PRO', 'Creator'

  final UserPreferenceModel preferences;
  final UserStatisticsModel statistics;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.displayName = '',
    this.avatarUrl,
    this.bio = '',
    this.country = 'Global',
    this.city = '',
    this.language = 'en',
    this.currency = 'USD',
    this.timezone = 'UTC',
    this.gender = 'Unspecified',
    this.dateOfBirth,
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
    this.preferences = const UserPreferenceModel(),
    this.statistics = const UserStatisticsModel(),
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final prefsJson = json['preferences'] as Map<String, dynamic>? ?? {};
    final statsJson = json['statistics'] as Map<String, dynamic>? ?? {};

    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: profile['display_name']?.toString() ??
          json['displayName']?.toString() ??
          (json['username']?.toString() ?? ''),
      avatarUrl: profile['avatar']?.toString() ?? json['avatarUrl']?.toString(),
      bio: profile['bio']?.toString() ?? json['bio']?.toString() ?? '',
      country: profile['country']?.toString() ??
          json['country']?.toString() ??
          'Global',
      city: profile['city']?.toString() ?? json['city']?.toString() ?? '',
      language: profile['language']?.toString() ??
          json['language']?.toString() ??
          'en',
      currency: profile['currency']?.toString() ??
          json['currency']?.toString() ??
          'USD',
      timezone: profile['timezone']?.toString() ??
          json['timezone']?.toString() ??
          'UTC',
      gender: profile['gender']?.toString() ??
          json['gender']?.toString() ??
          'Unspecified',
      dateOfBirth: profile['date_of_birth']?.toString() ?? json['dateOfBirth']?.toString(),
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
      preferences: UserPreferenceModel.fromJson(prefsJson),
      statistics: UserStatisticsModel.fromJson(statsJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'country': country,
      'city': city,
      'language': language,
      'currency': currency,
      'timezone': timezone,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
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
      'preferences': preferences.toJson(),
      'statistics': statistics.toJson(),
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? country,
    String? city,
    String? language,
    String? currency,
    String? timezone,
    String? gender,
    String? dateOfBirth,
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
    UserPreferenceModel? preferences,
    UserStatisticsModel? statistics,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      city: city ?? this.city,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
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
      preferences: preferences ?? this.preferences,
      statistics: statistics ?? this.statistics,
    );
  }
}
