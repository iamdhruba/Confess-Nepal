const mongoose = require('mongoose');
const Confession = require('../models/Confession');
const Reaction = require('../models/Reaction');
const User = require('../models/User');
const { createNotification } = require('../utils/notificationHelper');

const isValidId = (id) => mongoose.Types.ObjectId.isValid(id);

const VALID_REACTIONS = new Set(['relatable', 'stay_strong', 'wtf', 'funny']);

const parsePage = (page, limit) => {
  const p = Math.max(1, Number(page) || 1);
  const l = Math.min(50, Math.max(1, Number(limit) || 20));
  return { parsedPage: p, parsedLimit: l, skip: (p - 1) * l };
};

// Safe per-user flag helper — works with lean() objects
const attachUserFlags = (confessions, userId, userReactionMap = {}) => {
  const uid = userId ? userId.toString() : null;
  return confessions.map((c) => {
    const { savedBy, repostedBy, ...safe } = c;
    return {
      ...safe,
      userReactions: userReactionMap[c._id] || [],
      userSaved: uid ? (savedBy || []).some((id) => id.toString() === uid) : false,
      userReposted: uid ? (repostedBy || []).some((id) => id.toString() === uid) : false,
    };
  });
};

const buildReactionMap = async (confessionIds, userId) => {
  if (!userId) return {};
  const reactions = await Reaction.find({
    userId,
    confessionId: { $in: confessionIds },
  }).lean();
  const map = {};
  reactions.forEach((r) => {
    const key = r.confessionId.toString();
    if (!map[key]) map[key] = [];
    map[key].push(r.reactionType);
  });
  return map;
};

// GET /api/confessions
const getFeed = async (req, res) => {
  try {
    const { page, limit, mood, location } = req.query;
    const { parsedPage, parsedLimit, skip } = parsePage(page, limit);

    const filter = { isHidden: false };
    if (mood) filter.mood = String(mood).trim().slice(0, 50);
    if (location) filter.locationTag = String(location).trim().slice(0, 100);

    const [confessions, total] = await Promise.all([
      Confession.find(filter).sort({ createdAt: -1 }).skip(skip).limit(parsedLimit).lean(),
      Confession.countDocuments(filter),
    ]);

    const reactionMap = await buildReactionMap(confessions.map((c) => c._id), req.user?._id);
    const data = attachUserFlags(confessions, req.user?._id, reactionMap);

    res.status(200).json({ confessions: data, total, page: parsedPage, totalPages: Math.ceil(total / parsedLimit) });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/confessions/trending
const getTrending = async (req, res) => {
  try {
    const { location } = req.query;
    const filter = { isHidden: false };
    if (location) filter.locationTag = String(location).trim().slice(0, 100);

    const confessions = await Confession.find(filter).sort({ trendingScore: -1 }).limit(20).lean();
    const reactionMap = await buildReactionMap(confessions.map((c) => c._id), req.user?._id);
    const data = attachUserFlags(confessions, req.user?._id, reactionMap);

    res.status(200).json({ confessions: data });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/confessions/cotd
const getConfessionOfDay = async (req, res) => {
  try {
    const cotd = await Confession.findOne({ isConfessionOfDay: true, isHidden: false }).lean();
    if (!cotd) return res.status(200).json({ confession: null });

    const reactionMap = await buildReactionMap([cotd._id], req.user?._id);
    const [data] = attachUserFlags([cotd], req.user?._id, reactionMap);

    res.status(200).json({ confession: data });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/confessions/:id
const getOne = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) return res.status(400).json({ message: 'Invalid confession id' });
    const confession = await Confession.findById(req.params.id).lean();
    if (!confession || confession.isHidden) {
      return res.status(404).json({ message: 'Confession not found' });
    }

    const reactionMap = await buildReactionMap([confession._id], req.user?._id);
    const [data] = attachUserFlags([confession], req.user?._id, reactionMap);

    res.status(200).json({ confession: data });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/confessions
const create = async (req, res) => {
  try {
    const { content, mood, locationTag, isDisappearing } = req.body;

    if (!content || typeof content !== 'string' || content.trim().length < 3) {
      return res.status(400).json({ message: 'Content must be at least 3 characters' });
    }
    if (!mood || typeof mood !== 'string' || mood.trim().length === 0) {
      return res.status(400).json({ message: 'Mood is required' });
    }

    const confessionData = {
      authorId: req.user._id,
      anonymousName: req.user.username,
      content: content.trim().slice(0, 1000),
      mood: mood.trim().slice(0, 50),
      locationTag: locationTag ? String(locationTag).trim().slice(0, 100) : null,
      isDisappearing: isDisappearing || false,
    };

    if (isDisappearing) {
      confessionData.expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);
    }

    const confession = await Confession.create(confessionData);

    req.user.updateStreak();
    req.user.karma += 10;
    req.user.totalConfessions += 1;
    req.user.checkBadges();
    await req.user.save();

    res.status(201).json({ confession });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// DELETE /api/confessions/:id
const remove = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) return res.status(400).json({ message: 'Invalid confession id' });
    const confession = await Confession.findById(req.params.id);
    if (!confession) return res.status(404).json({ message: 'Confession not found' });

    if (confession.authorId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    await confession.deleteOne();
    req.user.totalConfessions = Math.max(0, req.user.totalConfessions - 1);
    await req.user.save();

    res.status(200).json({ message: 'Confession deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/confessions/:id/react
const react = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) return res.status(400).json({ message: 'Invalid confession id' });
    const { reactionType } = req.body;

    if (!VALID_REACTIONS.has(reactionType)) {
      return res.status(400).json({ message: 'Invalid reaction type' });
    }

    const confession = await Confession.findById(req.params.id);

    if (!confession || confession.isHidden) {
      return res.status(404).json({ message: 'Confession not found' });
    }

    const existing = await Reaction.findOne({
      confessionId: confession._id,
      userId: req.user._id,
      reactionType,
    });

    if (existing) {
      await existing.deleteOne();
      confession.reactions[reactionType] = Math.max(0, confession.reactions[reactionType] - 1);
    } else {
      await Reaction.create({ confessionId: confession._id, userId: req.user._id, reactionType });
      confession.reactions[reactionType] += 1;
      req.user.karma += 1;
      await req.user.save();
      await createNotification(confession.authorId, req.user, 'reaction', 'reacted to your confession', confession._id, 'Confession');
    }

    confession.computeTrendingScore();
    await confession.save();

    const userReactions = await Reaction.find({ confessionId: confession._id, userId: req.user._id }).lean();
    res.status(200).json({ reactions: confession.reactions, userReactions: userReactions.map((r) => r.reactionType) });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/confessions/user/:userId
const getUserConfessions = async (req, res) => {
  try {
    if (!isValidId(req.params.userId)) return res.status(400).json({ message: 'Invalid userId' });
    const { parsedPage, parsedLimit, skip } = parsePage(req.query.page, req.query.limit);

    const [confessions, total] = await Promise.all([
      Confession.find({ authorId: req.params.userId, isHidden: false }).sort({ createdAt: -1 }).skip(skip).limit(parsedLimit).lean(),
      Confession.countDocuments({ authorId: req.params.userId, isHidden: false }),
    ]);

    const reactionMap = await buildReactionMap(confessions.map((c) => c._id), req.user?._id);
    const data = attachUserFlags(confessions, req.user?._id, reactionMap);

    res.status(200).json({ confessions: data, total, page: parsedPage, totalPages: Math.ceil(total / parsedLimit) });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/confessions/search
const search = async (req, res) => {
  try {
    const { q } = req.query;
    const { parsedPage, parsedLimit, skip } = parsePage(req.query.page, req.query.limit);

    const filter = { isHidden: false };
    if (q) {
      // Escape regex special chars to prevent ReDoS
      const escaped = String(q).replace(/[.*+?^${}()|[\]\\]/g, '\\$&').slice(0, 100);
      filter.$or = [
        { content: { $regex: escaped, $options: 'i' } },
        { locationTag: { $regex: escaped, $options: 'i' } },
        { mood: { $regex: escaped, $options: 'i' } },
      ];
    }

    const [confessions, total] = await Promise.all([
      Confession.find(filter).sort({ createdAt: -1 }).skip(skip).limit(parsedLimit).lean(),
      Confession.countDocuments(filter),
    ]);

    const reactionMap = await buildReactionMap(confessions.map((c) => c._id), req.user?._id);
    const data = attachUserFlags(confessions, req.user?._id, reactionMap);

    res.status(200).json({ confessions: data, total, page: parsedPage, totalPages: Math.ceil(total / parsedLimit) });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/confessions/stats
const getStats = async (req, res) => {
  try {
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const fifteenMinAgo = new Date(Date.now() - 15 * 60 * 1000);

    const [todayCount, activeCount, trendingCount] = await Promise.all([
      Confession.countDocuments({ isHidden: false, createdAt: { $gte: startOfDay } }),
      Confession.countDocuments({ isHidden: false, createdAt: { $gte: fifteenMinAgo } }),
      Confession.countDocuments({ isHidden: false, trendingScore: { $gt: 0 } }),
    ]);

    res.status(200).json({ todayCount, activeCount, trendingCount });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/confessions/locations
const getLocations = async (req, res) => {
  try {
    const locations = await Confession.distinct('locationTag', { isHidden: false, locationTag: { $ne: null } });
    res.status(200).json({ locations });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/confessions/moods
const getMoods = async (req, res) => {
  try {
    const moods = await Confession.distinct('mood', { isHidden: false });
    res.status(200).json({ moods });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/confessions/:id/repost
const repost = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) return res.status(400).json({ message: 'Invalid confession id' });
    const confession = await Confession.findById(req.params.id);
    if (!confession || confession.isHidden) {
      return res.status(404).json({ message: 'Confession not found' });
    }
    const userId = req.user._id;
    const alreadyReposted = confession.repostedBy.some((id) => id.toString() === userId.toString());
    if (alreadyReposted) {
      confession.repostedBy.pull(userId);
      confession.repostCount = Math.max(0, confession.repostCount - 1);
    } else {
      confession.repostedBy.push(userId);
      confession.repostCount += 1;
      req.user.karma += 2;
      await req.user.save();
    }
    confession.computeTrendingScore();
    await confession.save();
    res.status(200).json({ repostCount: confession.repostCount, userReposted: !alreadyReposted });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/confessions/:id/save
const toggleSave = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) return res.status(400).json({ message: 'Invalid confession id' });
    const confession = await Confession.findById(req.params.id);
    if (!confession || confession.isHidden) {
      return res.status(404).json({ message: 'Confession not found' });
    }
    const userId = req.user._id;
    const alreadySaved = confession.savedBy.some((id) => id.toString() === userId.toString());
    if (alreadySaved) {
      confession.savedBy.pull(userId);
      confession.saveCount = Math.max(0, confession.saveCount - 1);
    } else {
      confession.savedBy.push(userId);
      confession.saveCount += 1;
    }
    await confession.save();
    res.status(200).json({ saveCount: confession.saveCount, saved: !alreadySaved });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/confessions/saved
const getSavedConfessions = async (req, res) => {
  try {
    const { parsedPage, parsedLimit, skip } = parsePage(req.query.page, req.query.limit);

    const [confessions, total] = await Promise.all([
      Confession.find({ savedBy: req.user._id, isHidden: false }).sort({ createdAt: -1 }).skip(skip).limit(parsedLimit).lean(),
      Confession.countDocuments({ savedBy: req.user._id, isHidden: false }),
    ]);

    const reactionMap = await buildReactionMap(confessions.map((c) => c._id), req.user._id);
    const data = attachUserFlags(confessions, req.user._id, reactionMap);

    res.status(200).json({ confessions: data, total, page: parsedPage, totalPages: Math.ceil(total / parsedLimit) });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/confessions/reposted
const getRepostedConfessions = async (req, res) => {
  try {
    const { parsedPage, parsedLimit, skip } = parsePage(req.query.page, req.query.limit);

    const [confessions, total] = await Promise.all([
      Confession.find({ repostedBy: req.user._id, isHidden: false }).sort({ createdAt: -1 }).skip(skip).limit(parsedLimit).lean(),
      Confession.countDocuments({ repostedBy: req.user._id, isHidden: false }),
    ]);

    const reactionMap = await buildReactionMap(confessions.map((c) => c._id), req.user._id);
    const data = attachUserFlags(confessions, req.user._id, reactionMap);

    res.status(200).json({ confessions: data, total, page: parsedPage, totalPages: Math.ceil(total / parsedLimit) });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = {
  getFeed,
  getTrending,
  getConfessionOfDay,
  getOne,
  create,
  remove,
  react,
  repost,
  toggleSave,
  getUserConfessions,
  getStats,
  search,
  getLocations,
  getMoods,
  getSavedConfessions,
  getRepostedConfessions,
};
