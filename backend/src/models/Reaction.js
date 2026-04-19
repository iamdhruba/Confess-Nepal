const mongoose = require('mongoose');

const reactionSchema = new mongoose.Schema(
  {
    confessionId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Confession',
      required: true,
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    reactionType: {
      type: String,
      required: true,
      enum: ['relatable', 'stay_strong', 'wtf', 'funny'],
    },
  },
  { timestamps: true }
);

// One reaction type per user per confession
reactionSchema.index(
  { confessionId: 1, userId: 1, reactionType: 1 },
  { unique: true }
);

module.exports = mongoose.model('Reaction', reactionSchema);
