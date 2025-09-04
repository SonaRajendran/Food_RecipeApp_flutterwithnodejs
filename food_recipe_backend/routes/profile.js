const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const knex = require('../db/knex');

const router = express.Router();

const uploadsDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure multer storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});

const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Only images are allowed!'), false);
  }
};

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 },
});

// POST /api/profile/upload
router.post('/upload', upload.single('profileImage'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded or invalid file type.' });
  }

  const imageUrl = `/uploads/${req.file.filename}`;
  try {
    const updated = await knex('users')
      .where({ id: 1 })
      .update({ profile_image_url: imageUrl });
    if (updated === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.status(200).json({ imageUrl });
  } catch (error) {
    console.error('Error updating profile image:', error);
    res.status(500).json({ error: 'Failed to save image URL to database.' });
  }
});

// GET /api/profile
router.get('/', async (req, res) => {
  try {
    const user = await knex('users').where({ id: 1 }).first();
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(user);
  } catch (error) {
    console.error('Error fetching profile:', error);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

// PUT /api/profile
router.put('/', async (req, res) => {
  const { name, email } = req.body;
  try {
    const updated = await knex('users')
      .where({ id: 1 })
      .update({ name, email, updated_at: knex.fn.now() });
    if (updated) {
      const user = await knex('users').where({ id: 1 }).first();
      res.json(user);
    } else {
      res.status(404).json({ error: 'User not found' });
    }
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

module.exports = router;
