const express = require('express');
const router = express.Router({ mergeParams: true });
const { getComments, create, upvote, remove } = require('../controllers/commentController');
const { protect } = require('../middleware/auth');

// Mounted at /api/confessions/:confessionId/comments
router.get('/', getComments);
router.post('/', protect, create);

// Mounted at /api/comments
router.post('/:id/upvote', protect, upvote);
router.delete('/:id', protect, remove);

module.exports = router;
