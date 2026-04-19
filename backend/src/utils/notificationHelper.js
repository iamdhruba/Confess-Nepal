const Notification = require('../models/Notification');

/**
 * Utility to create a notification
 * @param {string} recipient - User ID who receives the notification
 * @param {object} sender - User object who triggered the notification
 * @param {string} type - Notification type (reaction, comment, etc.)
 * @param {string} message - Human readable message
 * @param {string} targetId - ID of the confession or question
 * @param {string} targetModel - 'Confession' or 'Question'
 */
const createNotification = async (recipient, sender, type, message, targetId, targetModel) => {
  try {
    // Don't notify if sender is the recipient
    if (recipient.toString() === sender._id.toString()) return;

    await Notification.create({
      recipient,
      sender: sender._id,
      senderName: sender.username,
      type,
      message,
      targetId,
      targetModel,
    });
  } catch (error) {
    console.error('Notification creation failed:', error.message);
  }
};

module.exports = { createNotification };
