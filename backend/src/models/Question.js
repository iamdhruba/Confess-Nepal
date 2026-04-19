const mongoose = require('mongoose');

const questionSchema = new mongoose.Schema(
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
    question: {
      type: String,
      required: true,
      trim: true,
      minlength: 3,
      maxlength: 500,
    },
    category: {
      type: String,
      default: 'General',
      enum: ['Deep', 'Life', 'Relationship', 'Funny', 'Career', 'Health', 'General'],
    },
    answerCount: {
      type: Number,
      default: 0,
    },
    upvotedBy: {
      type: [mongoose.Schema.Types.ObjectId],
      ref: 'User',
      default: [],
    },
    isHidden: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

questionSchema.index({ createdAt: -1 });
questionSchema.index({ upvotedBy: 1 });

module.exports = mongoose.model('Question', questionSchema);
