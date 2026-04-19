class NightMode {
  static bool get isNightTime {
    final hour = DateTime.now().hour;
    return hour >= 21 || hour < 5; // 9 PM to 5 AM
  }

  static String get greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 21) return 'Good evening';
    return 'Late night thoughts?';
  }

  static String get nightMessage {
    if (!isNightTime) return '';
    final messages = [
      '🌙 Night mode active — deeper confessions surface now',
      '🌃 The city sleeps, but your thoughts don\'t',
      '✨ Late night is when the realest confessions drop',
      '🌌 Anonymous after dark — speak your truth',
      '🔮 Midnight confessions hit different',
    ];
    return (messages..shuffle()).first;
  }
}
