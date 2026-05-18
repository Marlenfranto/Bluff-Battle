class AppConstants {
  AppConstants._();

  // Breakpoints
  static const double mobileBreakpoint = 900;

  // Game Rules
  static const int correctPoints = 1;
  static const int wrongPoints = -1;

  // Validation
  static const int minStatementLength = 10;
  static const int maxStatementLength = 200;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // QR
  static const String qrPrefix = 'TTL_GAME:';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String scansCollection = 'scans';
  static const String answersCollection = 'answers';
  static const String eventsCollection = 'events';

  // Rank Tiers
  static const Map<String, int> rankTiers = {
    'Beginner': 0,
    'Detective': 11,
    'Investigator': 26,
    'Mastermind': 51,
  };

  static String getRankForScore(int score) {
    if (score >= rankTiers['Mastermind']!) return 'Mastermind';
    if (score >= rankTiers['Investigator']!) return 'Investigator';
    if (score >= rankTiers['Detective']!) return 'Detective';
    return 'Beginner';
  }

  static String getRankEmoji(String rank) {
    switch (rank) {
      case 'Mastermind':
        return '🧠';
      case 'Investigator':
        return '🔍';
      case 'Detective':
        return '🕵️';
      default:
        return '🌱';
    }
  }

  // Achievements
  static const int streakBronze = 3;
  static const int streakSilver = 5;
  static const int streakGold = 10;

  // LinkedIn URL pattern
  static final RegExp linkedInPattern = RegExp(
    r'^https?:\/\/(www\.)?linkedin\.com\/in\/[\w-]+\/?$',
    caseSensitive: false,
  );

  static bool isValidLinkedInUrl(String url) {
    return linkedInPattern.hasMatch(url);
  }
}
