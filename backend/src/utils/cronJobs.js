const cron = require('node-cron');
const Confession = require('../models/Confession');

const startCronJobs = () => {
  // Every hour: delete expired disappearing confessions
  cron.schedule('0 * * * *', async () => {
    try {
      const result = await Confession.deleteMany({
        isDisappearing: true,
        expiresAt: { $lte: new Date() },
      });
      if (result.deletedCount > 0 && process.env.NODE_ENV !== 'production') {
        console.log(`[CRON] Deleted ${result.deletedCount} expired confessions`);
      }
    } catch (error) {
      console.error('[CRON] Error deleting expired confessions:', error.message);
    }
  });

  // Every hour: recalculate trending scores
  cron.schedule('30 * * * *', async () => {
    try {
      const now = Date.now();
      const confessions = await Confession.find({ isHidden: false }, '_id reactions commentCount createdAt').lean();
      const bulkOps = confessions.map((c) => {
        const totalReactions =
          c.reactions.relatable + c.reactions.stay_strong + c.reactions.wtf + c.reactions.funny;
        const ageHours = (now - c.createdAt) / (1000 * 60 * 60);
        const recencyBonus = Math.max(0, 48 - ageHours) * 2;
        const trendingScore = totalReactions * 2 + c.commentCount * 3 + recencyBonus;
        return {
          updateOne: {
            filter: { _id: c._id },
            update: { $set: { trendingScore } },
          },
        };
      });
      if (bulkOps.length > 0) {
        await Confession.bulkWrite(bulkOps);
        if (process.env.NODE_ENV !== 'production') {
          console.log(`[CRON] Updated trending scores for ${bulkOps.length} confessions`);
        }
      }
    } catch (error) {
      console.error('[CRON] Error updating trending scores:', error.message);
    }
  });

  // Every day at midnight: pick confession of the day
  cron.schedule('0 0 * * *', async () => {
    try {
      // Clear previous cotd
      await Confession.updateMany(
        { isConfessionOfDay: true },
        { $set: { isConfessionOfDay: false } }
      );

      // Pick the top trending confession from last 24h
      const since = new Date(Date.now() - 24 * 60 * 60 * 1000);
      const top = await Confession.findOne({
        isHidden: false,
        createdAt: { $gte: since },
      }).sort({ trendingScore: -1 });

      if (top) {
        top.isConfessionOfDay = true;
        await top.save();
        if (process.env.NODE_ENV !== 'production') {
          console.log(`[CRON] New confession of the day: ${top._id}`);
        }
      }
    } catch (error) {
      console.error('[CRON] Error selecting confession of the day:', error.message);
    }
  });

  if (process.env.NODE_ENV !== 'production') {
    console.log('[CRON] All cron jobs started');
  }
};

module.exports = startCronJobs;
