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

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.membershipTier = 'Gold Explorer',
    this.totalCoins = 2450,
    this.fiatBalance = 24.50,
    this.tasksCompleted = 48,
    this.totalMinutesWatched = 240,
    this.streakDays = 5,
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
    );
  }
}
