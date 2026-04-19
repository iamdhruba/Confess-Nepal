const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    deviceId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    username: {
      type: String,
      required: true,
      trim: true,
      maxlength: 30,
    },
    // Optional — only set if user chooses to register with email
    email: {
      type: String,
      default: null,
      lowercase: true,
      trim: true,
      sparse: true, // allows multiple null values
    },
    password: {
      type: String,
      default: null,
      select: false, // never returned in queries by default
    },
    isEmailVerified: {
      type: Boolean,
      default: false,
    },
    passwordResetOtp: {
      type: String,
      default: null,
      select: false,
    },
    passwordResetOtpExpires: {
      type: Date,
      default: null,
      select: false,
    },
    bio: {
      type: String,
      default: '',
      maxlength: 160,
      trim: true,
    },
    karma: {
      type: Number,
      default: 0,
    },
    streakDays: {
      type: Number,
      default: 0,
    },
    lastActiveDate: {
      type: Date,
      default: null,
    },
    badges: {
      type: [String],
      default: [],
    },
    totalConfessions: {
      type: Number,
      default: 0,
    },
    totalComments: {
      type: Number,
      default: 0,
    },
    role: {
      type: String,
      enum: ['user', 'admin'],
      default: 'user',
    },
  },
  { timestamps: true }
);

// Hash password before saving
userSchema.pre('save', async function (next) {
  if (!this.isModified('password') || !this.password) return next();
  // Guard against bcrypt DoS — truncate at 72 bytes
  if (this.password.length > 72) {
    const err = new Error('Password too long');
    err.statusCode = 400;
    return next(err);
  }
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

userSchema.methods.correctPassword = async function (candidate) {
  if (!this.password || !candidate) return false;
  return bcrypt.compare(candidate, this.password);
};

userSchema.methods.updateStreak = function () {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

  if (!this.lastActiveDate) {
    this.streakDays = 1;
    this.lastActiveDate = today;
    return;
  }

  const last = new Date(this.lastActiveDate);
  const lastDay = new Date(last.getFullYear(), last.getMonth(), last.getDate());
  const diffDays = Math.floor((today - lastDay) / (1000 * 60 * 60 * 24));

  if (diffDays === 0) return;
  if (diffDays === 1) {
    this.streakDays += 1;
  } else {
    this.streakDays = 1;
  }
  this.lastActiveDate = today;
};

userSchema.methods.checkBadges = function () {
  const earned = new Set(this.badges);

  if (this.totalConfessions >= 1) earned.add('Early Confessor');
  if (this.streakDays >= 7) earned.add('Streaker');
  if (this.karma >= 100) earned.add('Karma King');
  if (this.totalComments >= 50) earned.add('Top Listener');

  const hour = new Date().getHours();
  if (hour >= 0 && hour < 5) earned.add('Night Owl');

  this.badges = Array.from(earned);
};

module.exports = mongoose.model('User', userSchema);
