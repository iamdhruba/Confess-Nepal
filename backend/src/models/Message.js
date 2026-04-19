const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema(
  {
    fromId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    toId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    fromUsername: { type: String, required: true },
    content: { type: String, required: true, maxlength: 500, trim: true },
    isRead: { type: Boolean, default: false },
    // Reference to the comment/confession that triggered the DM
    contextConfessionId: { type: mongoose.Schema.Types.ObjectId, ref: 'Confession', default: null },
  },
  { timestamps: true }
);

messageSchema.index({ toId: 1, createdAt: -1 });
messageSchema.index({ fromId: 1, toId: 1 });

module.exports = mongoose.model('Message', messageSchema);
