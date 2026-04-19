const express = require('express');
const router = express.Router();
const {
  getConfessions,
  toggleHide,
  togglePin,
  getQuestions,
  toggleHideQuestion,
  getStats,
} = require('../controllers/adminController');
const { protect, admin } = require('../middleware/auth');

// All admin routes are protected by role check
router.use(protect, admin);

router.get('/confessions', getConfessions);
router.patch('/confessions/:id/hide', toggleHide);
router.patch('/confessions/:id/pin', togglePin);
router.get('/questions', getQuestions);
router.patch('/questions/:id/hide', toggleHideQuestion);
router.get('/stats', getStats);

module.exports = router;
