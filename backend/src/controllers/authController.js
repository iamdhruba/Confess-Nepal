const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const User = require('../models/User');
const { generateUsername } = require('../utils/usernameGenerator');
const { sendOtpEmail } = require('../utils/mailer');

const signToken = (userId) =>
  jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN,
  });

const sendToken = (res, user, statusCode) => {
  const token = signToken(user._id);
  user.password = undefined;
  res.status(statusCode).json({ token, user });
};

const isValidPassword = (p) =>
  p.length >= 8 && /[A-Z]/.test(p) && /[0-9]/.test(p);

// POST /api/auth/device-register
const deviceRegister = async (req, res) => {
  try {
    const { deviceId } = req.body;
    if (!deviceId || typeof deviceId !== 'string' || deviceId.length < 8 || deviceId.length > 128) {
      return res.status(400).json({ message: 'Invalid deviceId' });
    }
    // Strip anything that isn't alphanumeric, dash, or underscore
    const safeDeviceId = deviceId.replace(/[^a-zA-Z0-9_\-]/g, '');
    if (safeDeviceId.length < 8) {
      return res.status(400).json({ message: 'Invalid deviceId format' });
    }

    let user = await User.findOne({ deviceId: safeDeviceId });
    if (user) return sendToken(res, user, 200);

    user = await User.create({ deviceId: safeDeviceId, username: generateUsername() });
    sendToken(res, user, 201);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/auth/signup
const signup = async (req, res) => {
  try {
    const { deviceId, email, password, username } = req.body;

    if (!deviceId || !email || !password) {
      return res.status(400).json({ message: 'deviceId, email and password are required' });
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return res.status(400).json({ message: 'Invalid email address' });
    }
    if (!isValidPassword(password)) {
      return res.status(400).json({
        message: 'Password must be at least 8 characters with one uppercase letter and one number',
      });
    }

    const emailExists = await User.findOne({ email: email.toLowerCase() });
    if (emailExists) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    const safeDeviceId = String(deviceId).replace(/[^a-zA-Z0-9_\-]/g, '');
    let user = await User.findOne({ deviceId: safeDeviceId });
    if (user) {
      user.email = email.toLowerCase();
      user.password = password;
      if (username) user.username = username.trim().slice(0, 30);
      await user.save();
    } else {
      user = await User.create({
        deviceId: safeDeviceId,
        email: email.toLowerCase(),
        password,
        username: username ? username.trim().slice(0, 30) : generateUsername(),
      });
    }

    sendToken(res, user, 201);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/auth/login
const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    const user = await User.findOne({ email: String(email).toLowerCase() }).select('+password');
    if (!user || !user.password) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const isCorrect = await user.correctPassword(password);
    if (!isCorrect) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    sendToken(res, user, 200);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/auth/forgot-password
const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ message: 'Email is required' });

    const user = await User.findOne({ email: String(email).toLowerCase() })
      .select('+passwordResetOtp +passwordResetOtpExpires');

    if (!user) {
      return res.status(200).json({ message: 'If that email exists, an OTP has been sent' });
    }

    const otp = (crypto.randomInt(900000) + 100000).toString();
    user.passwordResetOtp = crypto.createHash('sha256').update(otp).digest('hex');
    user.passwordResetOtpExpires = new Date(Date.now() + 10 * 60 * 1000);
    await user.save({ validateBeforeSave: false });

    const emailConfigured = !!(process.env.EMAIL_USER && process.env.EMAIL_PASS);

    if (emailConfigured) {
      try {
        await sendOtpEmail(user.email, otp);
        return res.status(200).json({ message: 'OTP sent to your email' });
      } catch (emailErr) {
        user.passwordResetOtp = null;
        user.passwordResetOtpExpires = null;
        await user.save({ validateBeforeSave: false });
        return res.status(500).json({ message: 'Failed to send email. Please try again.' });
      }
    }

    // Email not configured — only expose OTP in development
    if (process.env.NODE_ENV !== 'production') {
      return res.status(200).json({ message: 'Dev mode: OTP generated', otp });
    }
    res.status(500).json({ message: 'Email service not configured' });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/auth/verify-otp
const verifyOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;
    if (!email || !otp) return res.status(400).json({ message: 'Email and OTP are required' });

    const hashedOtp = crypto.createHash('sha256').update(String(otp)).digest('hex');
    const user = await User.findOne({
      email: String(email).toLowerCase(),
      passwordResetOtp: hashedOtp,
      passwordResetOtpExpires: { $gt: Date.now() },
    }).select('+passwordResetOtp +passwordResetOtpExpires');

    if (!user) {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }

    res.status(200).json({ message: 'OTP verified', valid: true });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// POST /api/auth/reset-password
const resetPassword = async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;
    if (!email || !otp || !newPassword) {
      return res.status(400).json({ message: 'Email, OTP and new password are required' });
    }
    if (!isValidPassword(newPassword)) {
      return res.status(400).json({
        message: 'Password must be at least 8 characters with one uppercase letter and one number',
      });
    }

    const hashedOtp = crypto.createHash('sha256').update(String(otp)).digest('hex');
    const user = await User.findOne({
      email: String(email).toLowerCase(),
      passwordResetOtp: hashedOtp,
      passwordResetOtpExpires: { $gt: Date.now() },
    }).select('+passwordResetOtp +passwordResetOtpExpires');

    if (!user) {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }

    user.password = newPassword;
    user.passwordResetOtp = null;
    user.passwordResetOtpExpires = null;
    await user.save();

    sendToken(res, user, 200);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// PATCH /api/auth/update-profile
const updateProfile = async (req, res) => {
  try {
    const { username, bio } = req.body;
    const updates = {};
    if (username !== undefined) updates.username = String(username).trim().slice(0, 30);
    if (bio !== undefined) updates.bio = String(bio).trim().slice(0, 160);

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ message: 'Nothing to update' });
    }

    Object.assign(req.user, updates);
    await req.user.save();
    res.status(200).json({ user: req.user });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// PATCH /api/auth/change-password
const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    if (!currentPassword || !newPassword) {
      return res.status(400).json({ message: 'Current and new password are required' });
    }
    if (!isValidPassword(newPassword)) {
      return res.status(400).json({
        message: 'Password must be at least 8 characters with one uppercase letter and one number',
      });
    }

    const user = await User.findById(req.user._id).select('+password');
    if (!user.password) {
      return res.status(400).json({ message: 'No password set. Use signup to add one.' });
    }

    const isCorrect = await user.correctPassword(currentPassword);
    if (!isCorrect) {
      return res.status(401).json({ message: 'Current password is incorrect' });
    }

    user.password = newPassword;
    await user.save();
    sendToken(res, user, 200);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// PATCH /api/auth/regenerate-username
const regenerateUsername = async (req, res) => {
  try {
    req.user.username = generateUsername();
    await req.user.save();
    res.status(200).json({ username: req.user.username });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/auth/me
const getMe = async (req, res) => {
  res.status(200).json({ user: req.user });
};

module.exports = {
  deviceRegister,
  signup,
  login,
  forgotPassword,
  verifyOtp,
  resetPassword,
  updateProfile,
  changePassword,
  regenerateUsername,
  getMe,
};

