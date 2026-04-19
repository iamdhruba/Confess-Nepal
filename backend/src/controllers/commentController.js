const mongoose = require('mongoose');
const Comment = require('../models/Comment');
const Confession = require('../models/Confession');
const { createNotification } = require('../utils/notificationHelper');

const isValidId = (id) => mongoose.Types.ObjectId.isValid(id);

// GET /api/confessions/:confessionId/comments
const getComments = async (req, res) => {
  try {
    const { confessionId } = req.params;
    if (!isValidId(confessionId)) return res.status(400).json({ message: 'Invalid confessionId' });

    const topLevel = await Comment.find({
      confessionId,
      parentId: null,
      isHidden: false,
    })
      .sort({ upvotes: -1, createdAt: 1 })
      .lean();

    const topLevelIds = topLevel.map((c) => c._id);
    const replies = await Comment.find({
      confessionId,
      parentId: { $in: topLevelIds },
      isHidden: false,
    })
      .sort({ createdAt: 1 })
      .lean();

    const replyMap = {};
    replies.forEach((r) => {
      const key = r.parentId.toString();
      if (!replyMap[key]) replyMap[key] = [];
      replyMap[key].push({ ...r, replies: [] });
    });

    const nested = topLevel.map((c) => ({
      ...c,
      replies: replyMap[c._id.toString()] || [],
    }));

    res.status(200).json({ comments: nested });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/confessions/:confessionId/comments
const create = async (req, res) => {
  try {
    const { confessionId } = req.params;
    const { content, parentId } = req.body;

    if (!isValidId(confessionId)) return res.status(400).json({ message: 'Invalid confessionId' });
    if (!content || typeof content !== 'string' || content.trim().length < 1) {
      return res.status(400).json({ message: 'Content is required' });
    }
    if (parentId && !isValidId(parentId)) {
      return res.status(400).json({ message: 'Invalid parentId' });
    }

    const confession = await Confession.findById(confessionId);
    if (!confession || confession.isHidden) {
      return res.status(404).json({ message: 'Confession not found' });
    }

    let parent = null;
    if (parentId) {
      parent = await Comment.findById(parentId);
      if (!parent || parent.confessionId.toString() !== confessionId) {
        return res.status(400).json({ message: 'Invalid parent comment' });
      }
    }

    const trimmed = content.trim().slice(0, 500);
    const comment = await Comment.create({
      confessionId,
      authorId: req.user._id,
      anonymousName: req.user.username,
      content: trimmed,
      parentId: parentId || null,
    });

    confession.commentCount += 1;
    confession.computeTrendingScore();
    await confession.save();

    req.user.karma += 2;
    req.user.totalComments += 1;
    req.user.checkBadges();
    await req.user.save();

    await createNotification(
      confession.authorId,
      req.user,
      'comment',
      `commented on your confession: "${trimmed.substring(0, 30)}${trimmed.length > 30 ? '...' : ''}"`,
      confession._id,
      'Confession'
    );

    if (parent) {
      await createNotification(
        parent.authorId,
        req.user,
        'comment',
        'replied to your comment',
        confession._id,
        'Confession'
      );
    }

    res.status(201).json({ comment });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/comments/:id/upvote
const upvote = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) return res.status(400).json({ message: 'Invalid comment id' });
    const comment = await Comment.findById(req.params.id);
    if (!comment || comment.isHidden) {
      return res.status(404).json({ message: 'Comment not found' });
    }

    const userId = req.user._id;
    const alreadyUpvoted = comment.upvotedBy.some((id) => id.toString() === userId.toString());

    if (alreadyUpvoted) {
      comment.upvotedBy.pull(userId);
      comment.upvotes = Math.max(0, comment.upvotes - 1);
    } else {
      comment.upvotedBy.push(userId);
      comment.upvotes += 1;
    }

    await comment.save();
    res.status(200).json({ upvotes: comment.upvotes, hasUpvoted: !alreadyUpvoted });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// DELETE /api/comments/:id
const remove = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) return res.status(400).json({ message: 'Invalid comment id' });
    const comment = await Comment.findById(req.params.id);
    if (!comment) {
      return res.status(404).json({ message: 'Comment not found' });
    }

    if (comment.authorId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    await comment.deleteOne();

    await Confession.findByIdAndUpdate(comment.confessionId, {
      $inc: { commentCount: -1 },
    });

    res.status(200).json({ message: 'Comment deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = { getComments, create, upvote, remove };
