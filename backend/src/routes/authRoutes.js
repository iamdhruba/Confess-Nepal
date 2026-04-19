const express = require('express');
const router = express.Router();
const {
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
} = require('../controllers/authController');
const { protect } = require('../middleware/auth');

router.post('/device-register', deviceRegister);
router.post('/signup', signup);
router.post('/login', login);
router.post('/forgot-password', forgotPassword);
router.post('/verify-otp', verifyOtp);
router.post('/reset-password', resetPassword);

router.get('/me', protect, getMe);
router.patch('/update-profile', protect, updateProfile);
router.patch('/change-password', protect, changePassword);
router.patch('/regenerate-username', protect, regenerateUsername);

module.exports = router;
