const mongoose = require('mongoose');
const Report = require('../models/Report');
const Confession = require('../models/Confession');
const Comment = require('../models/Comment');

const VALID_REASONS = new Set([
  'Inappropriate content',
  'Harassment / Bullying',
  'Self-harm / Suicide',
  'Spam / Fake',
  'Other',
]);

// POST /api/reports
const create = async (req, res) => {
  try {
    const { targetType, targetId, reason } = req.body;

    if (!['confession', 'comment'].includes(targetType)) {
      return res.status(400).json({ message: 'Invalid target type' });
    }
    if (!targetId || !mongoose.Types.ObjectId.isValid(targetId)) {
      return res.status(400).json({ message: 'Invalid targetId' });
    }
    if (!reason || !VALID_REASONS.has(reason)) {
      return res.status(400).json({ message: 'Invalid reason' });
    }

    const Model = targetType === 'confession' ? Confession : Comment;
    const target = await Model.findById(targetId);
    if (!target) {
      return res.status(404).json({ message: 'Target not found' });
    }

    // Prevent duplicate reports from same user
    const existing = await Report.findOne({
      reportedBy: req.user._id,
      targetId,
      targetType,
    });
    if (existing) {
      return res.status(400).json({ message: 'Already reported' });
    }

    await Report.create({
      reportedBy: req.user._id,
      targetType,
      targetId,
      reason,
    });

    // Auto-hide if report threshold reached
    target.reportCount = (target.reportCount || 0) + 1;
    if (target.reportCount >= 5) {
      target.isHidden = true;
    }
    await target.save();

    res.status(201).json({ message: 'Report submitted' });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = { create };

