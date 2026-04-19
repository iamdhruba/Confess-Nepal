const mongoose = require('mongoose');
const User = require('../models/User');
const Confession = require('../models/Confession');
const Question = require('../models/Question');

// GET /api/users/profile
const getMyProfile = async (req, res) => {
  try {
    const [confessionCount, questionCount] = await Promise.all([
      Confession.countDocuments({ authorId: req.user._id, isHidden: false }),
      Question.countDocuments({ authorId: req.user._id, isHidden: false }),
    ]);

    res.status(200).json({
      user: {
        ...req.user.toObject(),
        confessionCount,
        questionCount,
      },
    });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/users/:id/profile
const getProfile = async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ message: 'Invalid user id' });
    }
    const user = await User.findById(req.params.id)
      .select('username bio karma badges streakDays totalConfessions totalComments createdAt')
      .lean();

    if (!user) return res.status(404).json({ message: 'User not found' });

    const [confessionCount, questionCount] = await Promise.all([
      Confession.countDocuments({ authorId: user._id, isHidden: false }),
      Question.countDocuments({ authorId: user._id, isHidden: false }),
    ]);

    res.status(200).json({ user: { ...user, confessionCount, questionCount } });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = { getMyProfile, getProfile };

