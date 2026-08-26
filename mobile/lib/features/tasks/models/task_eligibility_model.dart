/// Represents the server-calculated task eligibility requirements.
class TaskEligibilityRequirements {
  final bool accountActive;
  final bool taskActive;
  final bool schedule;
  final bool capacity;
  final bool level;
  final bool trustScore;
  final bool verification;
  final bool dailyLimit;
  final bool repeatRule;

  const TaskEligibilityRequirements({
    this.accountActive = true,
    this.taskActive = true,
    this.schedule = true,
    this.capacity = true,
    this.level = true,
    this.trustScore = true,
    this.verification = true,
    this.dailyLimit = true,
    this.repeatRule = true,
  });

  factory TaskEligibilityRequirements.fromJson(Map<String, dynamic> json) {
    return TaskEligibilityRequirements(
      accountActive: json['account_active'] as bool? ?? true,
      taskActive: json['task_active'] as bool? ?? true,
      schedule: json['schedule'] as bool? ?? true,
      capacity: json['capacity'] as bool? ?? true,
      level: json['level'] as bool? ?? true,
      trustScore: json['trust_score'] as bool? ?? true,
      verification: json['verification'] as bool? ?? true,
      dailyLimit: json['daily_limit'] as bool? ?? true,
      repeatRule: json['repeat_rule'] as bool? ?? true,
    );
  }
}

class TaskEligibilityModel {
  final bool eligible;
  final List<String> reasons;
  final TaskEligibilityRequirements requirements;
  final String? activeAttemptId;

  const TaskEligibilityModel({
    required this.eligible,
    this.reasons = const [],
    this.requirements = const TaskEligibilityRequirements(),
    this.activeAttemptId,
  });

  factory TaskEligibilityModel.fromJson(Map<String, dynamic> json) {
    return TaskEligibilityModel(
      eligible: json['eligible'] as bool? ?? false,
      reasons: (json['reasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      requirements: json['requirements'] != null
          ? TaskEligibilityRequirements.fromJson(
              json['requirements'] as Map<String, dynamic>)
          : const TaskEligibilityRequirements(),
      activeAttemptId: json['active_attempt_id']?.toString(),
    );
  }
}
