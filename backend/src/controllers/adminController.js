const mongoose = require('mongoose');
const Confession = require('../models/Confession');
const Question = require('../models/Question');
const User = require('../models/User');

const isValidId = (id) => mongoose.Types.ObjectId.isValid(id);

// GET /api/admin/confessions
const getConfessions = async (req, res) => {
  try {
    const { page = 1, limit = 20, search, location, isHidden } = req.query;
    const filter = {};
    const parsedPage = Math.max(1, Number(page) || 1);
    const parsedLimit = Math.min(50, Math.max(1, Number(limit) || 20));

    if (search) {
      const escaped = String(search).replace(/[.*+?^${}()|[\]\\]/g, '\\$&').slice(0, 100);
      filter.content = { $regex: escaped, $options: 'i' };
    }
    if (location) filter.locationTag = String(location).trim().slice(0, 100);
    if (isHidden !== undefined) filter.isHidden = isHidden === 'true';

    const confessions = await Confession.find(filter)
      .sort({ createdAt: -1 })
      .skip((parsedPage - 1) * parsedLimit)
      .limit(parsedLimit)
      .lean();

    const total = await Confession.countDocuments(filter);

    res.status(200).json({
      confessions,
      total,
      page: parsedPage,
      totalPages: Math.ceil(total / parsedLimit),
    });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// PATCH /api/admin/confessions/:id/toggle-hide
const toggleHide = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) return res.status(400).json({ message: 'Invalid id' });
    const confession = await Confession.findById(req.params.id);
    if (!confession) return res.status(404).json({ message: 'Not found' });

    confession.isHidden = !confession.isHidden;
    await confession.save();

    res.status(200).json({ confession });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// PATCH /api/admin/confessions/:id/toggle-pin
const togglePin = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) return res.status(400).json({ message: 'Invalid id' });
    const confession = await Confession.findById(req.params.id);
    if (!confession) return res.status(404).json({ message: 'Not found' });

    if (!confession.isConfessionOfDay) {
      await Confession.updateMany({ isConfessionOfDay: true }, { isConfessionOfDay: false });
    }

    confession.isConfessionOfDay = !confession.isConfessionOfDay;
    await confession.save();

    res.status(200).json({ confession });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/admin/questions
const getQuestions = async (req, res) => {
  try {
    const { page = 1, limit = 20, isHidden } = req.query;
    const parsedPage = Math.max(1, Number(page) || 1);
    const parsedLimit = Math.min(50, Math.max(1, Number(limit) || 20));
    const filter = {};

    if (isHidden !== undefined) filter.isHidden = isHidden === 'true';

    const questions = await Question.find(filter)
      .sort({ createdAt: -1 })
      .skip((parsedPage - 1) * parsedLimit)
      .limit(parsedLimit)
      .lean();

    const total = await Question.countDocuments(filter);

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

// PATCH /api/admin/questions/:id/toggle-hide
const toggleHideQuestion = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) return res.status(400).json({ message: 'Invalid id' });
    const question = await Question.findById(req.params.id);
    if (!question) return res.status(404).json({ message: 'Not found' });

    question.isHidden = !question.isHidden;
    await question.save();

    res.status(200).json({ question });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/admin/stats
const getStats = async (req, res) => {
  try {
    const [totalUsers, totalConfessions, totalQuestions, totalKarma] = await Promise.all([
      User.countDocuments(),
      Confession.countDocuments(),
      Question.countDocuments(),
      User.aggregate([{ $group: { _id: null, sum: { $sum: '$karma' } } }]),
    ]);

    const topLocations = await Confession.aggregate([
      { $group: { _id: '$locationTag', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 5 },
    ]);

    const topMoods = await Confession.aggregate([
      { $group: { _id: '$mood', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 5 },
    ]);

    res.status(200).json({
      users: totalUsers,
      confessions: totalConfessions,
      questions: totalQuestions,
      karma: totalKarma[0]?.sum || 0,
      topLocations,
      topMoods,
    });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = {
  getConfessions,
  toggleHide,
  togglePin,
  getQuestions,
  toggleHideQuestion,
  getStats,
};

