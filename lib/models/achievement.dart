enum AchievementType { totalScans, correctGuesses, streak, connections }

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int requiredValue;
  final AchievementType type;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredValue,
    required this.type,
  });

  static const List<Achievement> predefined = [
    Achievement(
      id: 'first_scan',
      title: 'First Contact',
      description: 'Scan your first QR code',
      icon: '👋',
      requiredValue: 1,
      type: AchievementType.totalScans,
    ),
    Achievement(
      id: 'scan_5',
      title: 'Social Butterfly',
      description: 'Scan 5 participants',
      icon: '🦋',
      requiredValue: 5,
      type: AchievementType.totalScans,
    ),
    Achievement(
      id: 'scan_10',
      title: 'Networker',
      description: 'Scan 10 participants',
      icon: '🌐',
      requiredValue: 10,
      type: AchievementType.totalScans,
    ),
    Achievement(
      id: 'scan_25',
      title: 'Connector',
      description: 'Scan 25 participants',
      icon: '🔗',
      requiredValue: 25,
      type: AchievementType.totalScans,
    ),
    Achievement(
      id: 'correct_3',
      title: 'Lie Detector',
      description: 'Guess correctly 3 times',
      icon: '🔍',
      requiredValue: 3,
      type: AchievementType.correctGuesses,
    ),
    Achievement(
      id: 'correct_10',
      title: 'Truth Seeker',
      description: 'Guess correctly 10 times',
      icon: '🕵️',
      requiredValue: 10,
      type: AchievementType.correctGuesses,
    ),
    Achievement(
      id: 'correct_25',
      title: 'Human Polygraph',
      description: 'Guess correctly 25 times',
      icon: '🧠',
      requiredValue: 25,
      type: AchievementType.correctGuesses,
    ),
    Achievement(
      id: 'streak_3',
      title: 'Hat Trick',
      description: 'Get 3 correct guesses in a row',
      icon: '🎯',
      requiredValue: 3,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'streak_5',
      title: 'On Fire',
      description: 'Get 5 correct guesses in a row',
      icon: '🔥',
      requiredValue: 5,
      type: AchievementType.streak,
    ),
    Achievement(
      id: 'connections_5',
      title: 'Growing Network',
      description: 'Make 5 connections',
      icon: '🤝',
      requiredValue: 5,
      type: AchievementType.connections,
    ),
    Achievement(
      id: 'connections_20',
      title: 'Super Connector',
      description: 'Make 20 connections',
      icon: '⭐',
      requiredValue: 20,
      type: AchievementType.connections,
    ),
  ];
}

class AchievementProgress {
  final Achievement achievement;
  final int currentValue;

  const AchievementProgress({
    required this.achievement,
    required this.currentValue,
  });

  bool get isUnlocked => currentValue >= achievement.requiredValue;

  double get progress =>
      (currentValue / achievement.requiredValue).clamp(0.0, 1.0);
}
