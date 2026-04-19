require('dotenv').config();
const app = require('./app');
const connectDB = require('./config/db');
const startCronJobs = require('./utils/cronJobs');

const PORT = process.env.PORT || 5000;

const startServer = async () => {
  await connectDB();
  startCronJobs();

  app.listen(PORT, '0.0.0.0', () => {
    if (process.env.NODE_ENV !== 'production') {
      console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
    }
  });
};

startServer();
