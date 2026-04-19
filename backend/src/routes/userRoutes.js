const express = require('express');
const router = express.Router();
const { getMyProfile, getProfile } = require('../controllers/userController');
const { protect } = require('../middleware/auth');

router.get('/profile', protect, getMyProfile);
router.get('/:id/profile', getProfile);

module.exports = router;
