const mongoose = require('mongoose');
const Answer = require('../models/Answer');
const Question = require('../models/Question');
const { createNotification } = require('../utils/notificationHelper');

const isValidId = (id) => mongoose.Types.ObjectId.isValid(id);

// GET /api/questions/:questionId/answers
const getAnswers = async (req, res) => {
  try {
    if (!isValidId(req.params.questionId)) return res.status(400).json({ message: 'Invalid questionId' });
    const answers = await Answer.find({ questionId: req.params.questionId }).sort({ createdAt: 1 }).lean();
    res.status(200).json({ answers });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/questions/:questionId/answers
const createAnswer = async (req, res) => {
  try {
    const { content } = req.body;
    const { questionId } = req.params;

    if (!isValidId(questionId)) return res.status(400).json({ message: 'Invalid questionId' });
    if (!content || typeof content !== 'string' || !content.trim()) {
      return res.status(400).json({ message: 'Content is required' });
    }

    const question = await Question.findById(questionId);
    if (!question || question.isHidden) return res.status(404).json({ message: 'Question not found' });

    const trimmed = content.trim().slice(0, 1000);
    const answer = await Answer.create({
      questionId,
      authorId: req.user._id,
      anonymousName: req.user.username,
      content: trimmed,
    });

    question.answerCount += 1;
    await question.save();

    await createNotification(
      question.authorId,
      req.user,
      'answer',
      `replied to your question: "${trimmed.substring(0, 30)}${trimmed.length > 30 ? '...' : ''}"`,
      question._id,
      'Question'
    );

    res.status(201).json({ answer });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = { getAnswers, createAnswer };

