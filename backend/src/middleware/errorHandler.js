const errorHandler = (err, req, res, next) => {
  // Never log full stack in production
  if (process.env.NODE_ENV !== 'production') console.error(err.stack);

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const messages = Object.values(err.errors).map((e) => e.message);
    return res.status(400).json({ message: messages.join(', ') });
  }

  // Mongoose duplicate key — don't expose field name in production
  if (err.code === 11000) {
    const field = process.env.NODE_ENV !== 'production'
      ? Object.keys(err.keyValue)[0]
      : 'value';
    return res.status(400).json({ message: `${field} already exists` });
  }

  // Mongoose cast error (invalid ObjectId)
  if (err.name === 'CastError') {
    return res.status(400).json({ message: 'Invalid ID format' });
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({ message: 'Invalid token' });
  }
  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({ message: 'Token expired' });
  }

  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    message: statusCode < 500 ? err.message : 'Internal server error',
  });
};

module.exports = errorHandler;
