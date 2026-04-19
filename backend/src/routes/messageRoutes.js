const express = require('express');
const router = express.Router();
const rateLimit = require('express-rate-limit');
const { sendMessage, getInbox, getUnreadCount, markRead } = require('../controllers/messageController');
const { protect } = require('../middleware/auth');

const dmLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 30,
  message: { message: 'Too many DMs sent, please slow down' },
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => req.method === 'OPTIONS',
});

router.post('/', protect, dmLimiter, sendMessage);
router.get('/inbox', protect, getInbox);
router.get('/unread-count', protect, getUnreadCount);
router.patch('/:id/read', protect, markRead);

module.exports = router;
