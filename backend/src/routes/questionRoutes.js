const express = require('express');
const router = express.Router();
const { getAll, create, upvote, remove, getUserQuestions } = require('../controllers/questionController');
const { protect, optionalAuth } = require('../middleware/auth');

router.get('/', optionalAuth, getAll);
router.get('/user/:userId', optionalAuth, getUserQuestions);
router.post('/', protect, create);
router.post('/:id/upvote', protect, upvote);
router.delete('/:id', protect, remove);

const { getAnswers, createAnswer } = require('../controllers/answerController');
router.get('/:questionId/answers', optionalAuth, getAnswers);
router.post('/:questionId/answers', protect, createAnswer);

module.exports = router;
