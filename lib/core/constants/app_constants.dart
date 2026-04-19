class AppConstants {
  AppConstants._();

  static const int maxConfessionChars = 1000;
  static const int minConfessionChars = 3;
  static const int minQuestionChars = 3;

  static const List<String> moods = ['sad', 'love', 'funny', 'dark', 'confused'];

  static const Map<String, String> moodLabels = {
    'sad': 'Sad 😢',
    'love': 'Love 💕',
    'funny': 'Funny 😂',
    'dark': 'Dark 🌑',
    'confused': 'Confused 🤔',
  };

  static const List<String> locations = [
    'Kathmandu',
    'Pokhara',
    'Lalitpur',
    'Bhaktapur',
    'Biratnagar',
    'Birgunj',
    'Dharan',
    'Butwal',
    'Hetauda',
    'Chitwan',
    'Nepalgunj',
    'Itahari',
    'Damak',
    'Janakpur',
  ];

  static const List<String> questionCategories = [
    'Deep',
    'Life',
    'Relationship',
    'Funny',
    'Career',
    'Health',
  ];
}
