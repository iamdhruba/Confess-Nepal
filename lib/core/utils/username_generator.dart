import 'dart:math';

class UsernameGenerator {
  static final _random = Random();

  static const _adjectives = [
    'Lonely', 'Broken', 'Silent', 'Wandering', 'Lost',
    'Dreamy', 'Restless', 'Hidden', 'Midnight', 'Hopeful',
    'Fearless', 'Curious', 'Wild', 'Gentle', 'Burning',
    'Frozen', 'Dancing', 'Sleepy', 'Rebellious', 'Tender',
    'Chaotic', 'Peaceful', 'Bold', 'Shy', 'Misty',
    'Stormy', 'Golden', 'Fading', 'Glowing', 'Wandering',
    'Anonymous', 'Secret', 'Mystic', 'Neon', 'Electric',
  ];

  static const _locations = [
    'KTM', 'Pokhara', 'Lalitpur', 'Bhaktapur', 'Biratnagar',
    'Birgunj', 'Dharan', 'Butwal', 'Hetauda', 'Chitwan',
    'Nepalgunj', 'Itahari', 'Damak', 'Tansen', 'Janakpur',
    'Baglung', 'Gorkha', 'Palpa', 'Dhulikhel', 'Bandipur',
  ];

  static const _nouns = [
    'Heart', 'Soul', 'Mind', 'Dream', 'Shadow',
    'Star', 'Moon', 'Rain', 'Storm', 'Fire',
    'River', 'Mountain', 'Wind', 'Cloud', 'Flame',
    'Echo', 'Whisper', 'Ghost', 'Phoenix', 'Wolf',
    'Tiger', 'Eagle', 'Lotus', 'Rose', 'Thorn',
    'Voice', 'Spirit', 'Rebel', 'Nomad', 'Voyager',
  ];

  static String generate() {
    final adj = _adjectives[_random.nextInt(_adjectives.length)];
    final loc = _locations[_random.nextInt(_locations.length)];
    final noun = _nouns[_random.nextInt(_nouns.length)];
    return '${adj}_${loc}_$noun';
  }

  static String generateShort() {
    final adj = _adjectives[_random.nextInt(_adjectives.length)];
    final noun = _nouns[_random.nextInt(_nouns.length)];
    return '${adj}_$noun';
  }
}
