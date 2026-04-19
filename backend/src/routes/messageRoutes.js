const express = require('express');
const router = express.Router();
const { sendMessage, getInbox, getUnreadCount, markRead } = require('../controllers/messageController');
const { protect } = require('../middleware/auth');

router.post('/', protect, sendMessage);
router.get('/inbox', protect, getInbox);
router.get('/unread-count', protect, getUnreadCount);
router.patch('/:id/read', protect, markRead);

module.exports = router;
