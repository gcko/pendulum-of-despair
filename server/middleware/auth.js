/**
 * middleware/auth.js
 * JWT verification middleware.
 * Attaches `req.user = { id, username }` when a valid token is present.
 */

'use strict';

const jwt = require('jsonwebtoken');

if (!process.env.JWT_SECRET) {
  if (process.env.NODE_ENV === 'production') {
    throw new Error('FATAL: JWT_SECRET environment variable is required in production');
  }
  console.warn('[WARN] JWT_SECRET not set — using insecure default. Do NOT use in production.');
}
const JWT_SECRET = process.env.JWT_SECRET || 'change-me-in-production';

/**
 * Express middleware that reads a Bearer token from the Authorization header,
 * verifies it, and attaches the decoded payload to `req.user`.
 * Responds with 401 if the token is missing or invalid.
 *
 * @param {import('express').Request}  req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
function requireAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;

  if (!token) {
    return res.status(401).json({ error: 'Authorization token required' });
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET);
    req.user = { id: payload.sub, username: payload.username };
    next();
  } catch {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}

module.exports = { requireAuth, JWT_SECRET };
