const express = require('express');
const router = express.Router();
const {
  getFeed,
  getTrending,
  getConfessionOfDay,
  getOne,
  create,
  remove,
  react,
  repost,
  toggleSave,
  getUserConfessions,
  getStats,
  search,
  getLocations,
  getMoods,
  getSavedConfessions,
  getRepostedConfessions,
} = require('../controllers/confessionController');
const { protect, optionalAuth } = require('../middleware/auth');

router.get('/locations', getLocations);
router.get('/moods', getMoods);
router.get('/search', optionalAuth, search);
router.get('/stats', getStats);
router.get('/saved', protect, getSavedConfessions);
router.get('/reposted', protect, getRepostedConfessions);
router.get('/trending', optionalAuth, getTrending);
router.get('/cotd', optionalAuth, getConfessionOfDay);
router.get('/user/:userId', optionalAuth, getUserConfessions);
router.get('/', optionalAuth, getFeed);
router.get('/:id', optionalAuth, getOne);
router.post('/', protect, create);
router.delete('/:id', protect, remove);
router.post('/:id/react', protect, react);
router.post('/:id/repost', protect, repost);
router.post('/:id/save', protect, toggleSave);

module.exports = router;
