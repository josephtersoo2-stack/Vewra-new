/// Model representing user application preferences and notifications settings.
class UserPreferenceModel {
  final String theme;
  final String language;
  final bool notificationEnabled;
  final bool emailNotifications;
  final bool pushNotifications;

  const UserPreferenceModel({
    this.theme = 'dark',
    this.language = 'en',
    this.notificationEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
  });

  factory UserPreferenceModel.fromJson(Map<String, dynamic> json) {
    return UserPreferenceModel(
      theme: json['theme']?.toString() ?? 'dark',
      language: json['language']?.toString() ?? 'en',
      notificationEnabled: json['notification_enabled'] as bool? ?? true,
      emailNotifications: json['email_notifications'] as bool? ?? true,
      pushNotifications: json['push_notifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'notification_enabled': notificationEnabled,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
    };
  }

  UserPreferenceModel copyWith({
    String? theme,
    String? language,
    bool? notificationEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
  }) {
    return UserPreferenceModel(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }
}
