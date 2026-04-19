const mongoose = require('mongoose');
const Message = require('../models/Message');
const User = require('../models/User');
const { createNotification } = require('../utils/notificationHelper');

// POST /api/messages — send a DM to a user by their userId
const sendMessage = async (req, res) => {
  try {
    const { toUserId, content, contextConfessionId } = req.body;

    if (!toUserId || !mongoose.Types.ObjectId.isValid(toUserId)) {
      return res.status(400).json({ message: 'Invalid recipient' });
    }
    if (!content || content.trim().length < 1) {
      return res.status(400).json({ message: 'Message content is required' });
    }
    if (toUserId === req.user._id.toString()) {
      return res.status(400).json({ message: 'Cannot DM yourself' });
    }

    const recipient = await User.findById(toUserId);
    if (!recipient) return res.status(404).json({ message: 'User not found' });

    const message = await Message.create({
      fromId: req.user._id,
      toId: toUserId,
      fromUsername: req.user.username,
      content: content.trim().slice(0, 500),
      contextConfessionId: contextConfessionId && mongoose.Types.ObjectId.isValid(contextConfessionId)
        ? contextConfessionId
        : null,
    });

    await createNotification(
      toUserId,
      req.user,
      'dm',
      `sent you a message: "${message.content.substring(0, 40)}${message.content.length > 40 ? '...' : ''}"`,
      message._id,
      'Message'
    );

    res.status(201).json({ message });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/messages/inbox — get received messages
const getInbox = async (req, res) => {
  try {
    const messages = await Message.find({ toId: req.user._id })
      .sort({ createdAt: -1 })
      .limit(50)
      .lean();
    res.status(200).json({ messages });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// GET /api/messages/unread-count
const getUnreadCount = async (req, res) => {
  try {
    const count = await Message.countDocuments({ toId: req.user._id, isRead: false });
    res.status(200).json({ count });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// PATCH /api/messages/:id/read
const markRead = async (req, res) => {
  try {
    await Message.findOneAndUpdate(
      { _id: req.params.id, toId: req.user._id },
      { isRead: true }
    );
    res.status(200).json({ success: true });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = { sendMessage, getInbox, getUnreadCount, markRead };
