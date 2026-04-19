const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema(
  {
    reportedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    targetType: {
      type: String,
      required: true,
      enum: ['confession', 'comment'],
    },
    targetId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
    },
    reason: {
      type: String,
      required: true,
      enum: [
        'Inappropriate content',
        'Harassment / Bullying',
        'Self-harm / Suicide',
        'Spam / Fake',
        'Other',
      ],
    },
  },
  { timestamps: true }
);

// One report per user per target
reportSchema.index(
  { reportedBy: 1, targetId: 1, targetType: 1 },
  { unique: true }
);

module.exports = mongoose.model('Report', reportSchema);
