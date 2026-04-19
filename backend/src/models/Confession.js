const mongoose = require('mongoose');

const confessionSchema = new mongoose.Schema(
  {
    authorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    anonymousName: {
      type: String,
      required: true,
      trim: true,
    },
    content: {
      type: String,
      required: true,
      trim: true,
      minlength: 3,
      maxlength: 1000,
    },
    mood: {
      type: String,
      required: true,
      trim: true,
    },
    locationTag: {
      type: String,
      default: null,
      trim: true,
    },
    reactions: {
      relatable: { type: Number, default: 0 },
      stay_strong: { type: Number, default: 0 },
      wtf: { type: Number, default: 0 },
      funny: { type: Number, default: 0 },
    },
    commentCount: {
      type: Number,
      default: 0,
    },
    isConfessionOfDay: {
      type: Boolean,
      default: false,
    },
    isDisappearing: {
      type: Boolean,
      default: false,
    },
    expiresAt: {
      type: Date,
      default: null,
      index: true,
    },
    trendingScore: {
      type: Number,
      default: 0,
      index: true,
    },
    reportCount: {
      type: Number,
      default: 0,
    },
    isHidden: {
      type: Boolean,
      default: false,
    },
    repostCount: {
      type: Number,
      default: 0,
    },
    repostedBy: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    }],
    saveCount: {
      type: Number,
      default: 0,
    },
    savedBy: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    }],
  },
  { timestamps: true }
);

// Index for feed queries
confessionSchema.index({ createdAt: -1 });
confessionSchema.index({ mood: 1, createdAt: -1 });
confessionSchema.index({ locationTag: 1, createdAt: -1 });
confessionSchema.index({ trendingScore: -1 });

// Compute trending score
confessionSchema.methods.computeTrendingScore = function () {
  const totalReactions =
    this.reactions.relatable +
    this.reactions.stay_strong +
    this.reactions.wtf +
    this.reactions.funny;

  const ageHours = (Date.now() - this.createdAt) / (1000 * 60 * 60);
  const recencyBonus = Math.max(0, 48 - ageHours) * 2;

  this.trendingScore =
    totalReactions * 2 + this.commentCount * 3 + recencyBonus;
};

module.exports = mongoose.model('Confession', confessionSchema);
