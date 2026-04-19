const mongoose = require('mongoose');
const Question = require('../models/Question');
const { createNotification } = require('../utils/notificationHelper');

const isValidId = (id) => mongoose.Types.ObjectId.isValid(id);
const VALID_CATEGORIES = new Set(['Deep', 'Life', 'Relationship', 'Funny', 'Career', 'Health', 'General']);

// GET /api/questions?page=1&limit=20&category=Deep
const getAll = async (req, res) => {
  try {
    const { category } = req.query;
    const parsedPage = Math.max(1, Number(req.query.page) || 1);
    const parsedLimit = Math.min(50, Math.max(1, Number(req.query.limit) || 20));
    const skip = (parsedPage - 1) * parsedLimit;

    const filter = { isHidden: false };
    if (category && VALID_CATEGORIES.has(category)) filter.category = category;

    const [questionsRaw, total] = await Promise.all([
      Question.find(filter).sort({ createdAt: -1 }).skip(skip).limit(parsedLimit).lean(),
      Question.countDocuments(filter),
    ]);

    const questions = questionsRaw.map((q) => ({
      ...q,
      upvotes: q.upvotedBy ? q.upvotedBy.length : 0,
      hasUpvoted: req.user ? q.upvotedBy?.some(id => id.toString() === req.user._id.toString()) : false,
    }));

    res.status(200).json({
      questions,
      total,
      page: parsedPage,
      totalPages: Math.ceil(total / parsedLimit),
    });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/questions
const create = async (req, res) => {
  try {
    const { question, category } = req.body;

    if (!question || typeof question !== 'string' || question.trim().length < 3) {
      return res.status(400).json({ message: 'Question must be at least 3 characters' });
    }

    const safeCategory = VALID_CATEGORIES.has(category) ? category : 'General';

    const newQuestion = await Question.create({
      authorId: req.user._id,
      anonymousName: req.user.username,
      question: question.trim().slice(0, 500),
      category: safeCategory,
    });

    req.user.karma += 5;
    await req.user.save();

    res.status(201).json({ 
      question: { 
        ...newQuestion.toObject(), 
        upvotes: 0, 
        hasUpvoted: false 
      } 
    });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/questions/:id/upvote
const upvote = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) return res.status(400).json({ message: 'Invalid question id' });
    const q = await Question.findById(req.params.id);
    if (!q || q.isHidden) {
      return res.status(404).json({ message: 'Question not found' });
    }

    const userId = req.user._id;
    const upvotedIndex = q.upvotedBy.indexOf(userId);

    if (upvotedIndex > -1) {
      // Already upvoted, so remove it (toggle)
      q.upvotedBy.splice(upvotedIndex, 1);
    } else {
      q.upvotedBy.push(userId);

      await createNotification(
        q.authorId,
        req.user,
        'upvote',
        `upvoted your question`,
        q._id,
        'Question'
      );
    }

    await q.save();

    res.status(200).json({ 
      upvotes: q.upvotedBy.length,
      hasUpvoted: upvotedIndex === -1 
    });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// DELETE /api/questions/:id
const remove = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) return res.status(400).json({ message: 'Invalid question id' });
    const q = await Question.findById(req.params.id);
    if (!q) return res.status(404).json({ message: 'Question not found' });

    if (q.authorId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    await q.deleteOne();
    res.status(200).json({ message: 'Question deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/questions/user/:userId
const getUserQuestions = async (req, res) => {
  try {
    if (!isValidId(req.params.userId)) return res.status(400).json({ message: 'Invalid userId' });
    const questions = await Question.find({
      authorId: req.params.userId,
      isHidden: false,
    })
      .sort({ createdAt: -1 })
      .lean();

    res.status(200).json({ questions });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = { getAll, create, upvote, remove, getUserQuestions };

