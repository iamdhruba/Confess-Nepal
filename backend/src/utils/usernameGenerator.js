const { randomInt } = require('crypto');

const adjectives = [
  'Lonely', 'Broken', 'Silent', 'Wandering', 'Lost',
  'Dreamy', 'Restless', 'Hidden', 'Midnight', 'Hopeful',
  'Fearless', 'Curious', 'Wild', 'Gentle', 'Burning',
  'Frozen', 'Dancing', 'Sleepy', 'Rebellious', 'Tender',
  'Chaotic', 'Peaceful', 'Bold', 'Shy', 'Misty',
  'Stormy', 'Golden', 'Fading', 'Glowing', 'Anonymous',
  'Secret', 'Mystic', 'Neon', 'Electric', 'Restless',
];

const locations = [
  'KTM', 'Pokhara', 'Lalitpur', 'Bhaktapur', 'Biratnagar',
  'Birgunj', 'Dharan', 'Butwal', 'Hetauda', 'Chitwan',
  'Nepalgunj', 'Itahari', 'Damak', 'Tansen', 'Janakpur',
  'Baglung', 'Gorkha', 'Palpa', 'Dhulikhel', 'Bandipur',
];

const nouns = [
  'Heart', 'Soul', 'Mind', 'Dream', 'Shadow',
  'Star', 'Moon', 'Rain', 'Storm', 'Fire',
  'River', 'Mountain', 'Wind', 'Cloud', 'Flame',
  'Echo', 'Whisper', 'Ghost', 'Phoenix', 'Wolf',
  'Tiger', 'Eagle', 'Lotus', 'Rose', 'Thorn',
  'Voice', 'Spirit', 'Rebel', 'Nomad', 'Voyager',
];

const pick = (arr) => arr[randomInt(arr.length)];

const generateUsername = () =>
  `${pick(adjectives)}_${pick(locations)}_${pick(nouns)}`;

module.exports = { generateUsername };
