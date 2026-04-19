const Notification = require('../models/Notification');

const VALID_TARGET_MODELS = new Set(['Confession', 'Question', 'Message']);

const createNotification = async (recipient, sender, type, message, targetId, targetModel) => {
  try {
    if (!recipient || !sender?._id) return;
    if (recipient.toString() === sender._id.toString()) return;
    if (!VALID_TARGET_MODELS.has(targetModel)) return;

    await Notification.create({
      recipient,
      sender: sender._id,
      senderName: sender.username,
      type,
      message: String(message).slice(0, 200),
      targetId,
      targetModel,
    });
  } catch (error) {
    // Notification failures should never crash the main request
    if (process.env.NODE_ENV !== 'production') {
      console.error('Notification creation failed:', error.message);
    }
  }
};

module.exports = { createNotification };
