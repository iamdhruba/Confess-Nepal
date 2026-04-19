require('dotenv').config();
const app = require('./app');
const connectDB = require('./config/db');
const startCronJobs = require('./utils/cronJobs');

const PORT = process.env.PORT || 5000;

const startServer = async () => {
  await connectDB();
  startCronJobs();

  const server = app.listen(PORT, '0.0.0.0', () => {
    if (process.env.NODE_ENV !== 'production') {
      console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
    }
  });

  // Graceful shutdown on SIGTERM (Render redeploy) and SIGINT (Ctrl+C)
  const shutdown = () => {
    server.close(() => process.exit(0));
    setTimeout(() => process.exit(1), 10000); // force exit after 10s
  };
  process.on('SIGTERM', shutdown);
  process.on('SIGINT', shutdown);
};

startServer();
