const express = require('express');
const router = express.Router();
const { getNotifications, markAllAsRead, markAsRead } = require('../controllers/notificationController');
const { protect } = require('../middleware/auth');

router.use(protect);

router.get('/', getNotifications);
router.patch('/mark-read', markAllAsRead);
router.patch('/:id/mark-read', markAsRead);

module.exports = router;
