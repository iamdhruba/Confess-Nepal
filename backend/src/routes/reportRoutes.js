const express = require('express');
const router = express.Router();
const { create } = require('../controllers/reportController');
const { protect } = require('../middleware/auth');

router.post('/', protect, create);

module.exports = router;
