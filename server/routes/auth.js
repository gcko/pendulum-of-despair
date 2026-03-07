/**
 * routes/auth.js
 * Authentication routes: register and login.
 *
 * POST /api/auth/register  – Create a new account
 * POST /api/auth/login     – Authenticate and receive a JWT
 */

'use strict';

const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { getDb } = require('../db/init');
const { JWT_SECRET } = require('../middleware/auth');

const router = express.Router();

const BCRYPT_ROUNDS = 12;
const TOKEN_TTL = '7d';

/** Minimum username/passphrase constraints */
const USERNAME_MIN = 3;
const USERNAME_MAX = 32;
const PASSPHRASE_MIN = 6;
const PASSPHRASE_MAX = 128;

/**
 * Validates that a username contains only safe characters.
 * @param {string} username
 * @returns {boolean}
 */
function isValidUsername(username) {
  return /^[a-zA-Z0-9_-]+$/.test(username);
}

/**
 * Issues a signed JWT for the given user.
 * @param {{ id: number, username: string }} user
 * @returns {string}
 */
function signToken(user) {
  return jwt.sign(
    { sub: user.id, username: user.username },
    JWT_SECRET,
    { expiresIn: TOKEN_TTL }
  );
}

/**
 * POST /api/auth/register
 * Body: { username: string, passphrase: string }
 * Creates a new user account and returns a JWT.
 */
router.post('/register', async (req, res) => {
  const { username, passphrase } = req.body || {};

  if (
    typeof username !== 'string' ||
    typeof passphrase !== 'string' ||
    username.length < USERNAME_MIN ||
    username.length > USERNAME_MAX ||
    !isValidUsername(username) ||
    passphrase.length < PASSPHRASE_MIN ||
    passphrase.length > PASSPHRASE_MAX
  ) {
    return res.status(400).json({
      error:
        `Username must be ${USERNAME_MIN}–${USERNAME_MAX} alphanumeric characters ` +
        `(underscores/hyphens allowed). Passphrase must be ${PASSPHRASE_MIN}–${PASSPHRASE_MAX} characters.`,
    });
  }

  const db = getDb();

  const existing = db.prepare('SELECT id FROM users WHERE username = ?').get(username);
  if (existing) {
    return res.status(409).json({ error: 'Username already taken' });
  }

  const hash = await bcrypt.hash(passphrase, BCRYPT_ROUNDS);

  const result = db
    .prepare('INSERT INTO users (username, passphrase_hash) VALUES (?, ?)')
    .run(username, hash);

  const token = signToken({ id: Number(result.lastInsertRowid), username });
  return res.status(201).json({ token, username });
});

/**
 * POST /api/auth/login
 * Body: { username: string, passphrase: string }
 * Validates credentials and returns a JWT.
 */
router.post('/login', async (req, res) => {
  const { username, passphrase } = req.body || {};

  if (typeof username !== 'string' || typeof passphrase !== 'string') {
    return res.status(400).json({ error: 'Username and passphrase are required' });
  }

  const db = getDb();
  const user = db
    .prepare('SELECT id, username, passphrase_hash FROM users WHERE username = ?')
    .get(username);

  if (!user) {
    // Use constant-time comparison stub to avoid user enumeration via timing
    await bcrypt.compare(passphrase, '$2a$12$invalidhashpadding000000000000000000000000000000000000');
    return res.status(401).json({ error: 'Invalid username or passphrase' });
  }

  const valid = await bcrypt.compare(passphrase, user.passphrase_hash);
  if (!valid) {
    return res.status(401).json({ error: 'Invalid username or passphrase' });
  }

  const token = signToken({ id: user.id, username: user.username });
  return res.json({ token, username: user.username });
});

module.exports = router;
