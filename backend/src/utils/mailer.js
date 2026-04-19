const nodemailer = require('nodemailer');

const getTransporter = () => nodemailer.createTransport({
  host: process.env.EMAIL_HOST,
  port: Number(process.env.EMAIL_PORT) || 587,
  secure: false,
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
  tls: {
    rejectUnauthorized: process.env.NODE_ENV === 'production',
  },
});

const sendOtpEmail = async (to, otp) => {
  await getTransporter().sendMail({
    from: process.env.EMAIL_FROM,
    to,
    subject: 'Your ConfessNepal OTP Code',
    text: `Your OTP is: ${otp}\n\nThis code expires in 10 minutes. Do not share it with anyone.`,
    html: `
      <div style="font-family:sans-serif;max-width:400px;margin:auto;padding:32px;background:#131313;border-radius:16px;color:#E7E5E4;">
        <h2 style="color:#FF4D94;margin-bottom:8px;">ConfessNepal</h2>
        <p style="color:#ACABAA;margin-bottom:24px;">Your password reset OTP:</p>
        <div style="background:#1F2020;border-radius:12px;padding:24px;text-align:center;letter-spacing:12px;font-size:32px;font-weight:800;color:#FF4D94;">
          ${otp}
        </div>
        <p style="color:#767575;font-size:12px;margin-top:24px;">Expires in 10 minutes. Do not share this code.</p>
      </div>
    `,
  });
};

module.exports = { sendOtpEmail };
