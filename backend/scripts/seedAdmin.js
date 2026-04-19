const mongoose = require('mongoose');
const User = require('../src/models/User');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '../.env') });

const seedAdmin = async () => {
  const adminEmail = process.env.ADMIN_EMAIL;
  const adminPassword = process.env.ADMIN_PASSWORD;
  const adminDeviceId = process.env.ADMIN_DEVICE_ID;

  if (!adminEmail || !adminPassword || !adminDeviceId) {
    console.error('Missing required env vars: ADMIN_EMAIL, ADMIN_PASSWORD, ADMIN_DEVICE_ID');
    process.exit(1);
  }

  try {
    await mongoose.connect(process.env.MONGODB_URI);

    let admin = await User.findOne({ email: adminEmail });

    if (admin) {
      admin.password = adminPassword;
      admin.role = 'admin';
      await admin.save();
      console.log('Admin updated successfully');
    } else {
      await User.create({
        deviceId: adminDeviceId,
        username: 'Admin',
        email: adminEmail,
        password: adminPassword,
        role: 'admin',
        isEmailVerified: true,
      });
      console.log('Admin created successfully');
    }

    process.exit(0);
  } catch (error) {
    console.error('Error seeding admin:', error.message);
    process.exit(1);
  }
};

seedAdmin();
