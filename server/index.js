/**
 * index.js
 * Pendulum of Despair — Express API server
 *
 * Provides authentication (register/login) and save/load endpoints
 * for persistent game state. All game logic runs client-side in Phaser 3.
 *
 * Environment variables (see .env.example):
 *   PORT        – Port to listen on (default: 3000)
 *   JWT_SECRET  – Secret used to sign JWTs (REQUIRED in production)
 *   DB_PATH     – Path to SQLite file (default: ./game.db)
 *   CORS_ORIGIN – Allowed CORS origin (default: *)
 */

'use strict';

require('dotenv').config();

const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const { getDb } = require('./db/init');
const authRouter = require('./routes/auth');
const saveRouter = require('./routes/save');

const app = express();

// ── CORS ──────────────────────────────────────────────────────────────────────
const corsOrigin = process.env.CORS_ORIGIN || '*';
app.use(cors({ origin: corsOrigin }));

// ── Body parsing ──────────────────────────────────────────────────────────────
app.use(express.json({ limit: '520kb' })); // Slightly above 512KB save slot limit

// ── Rate limiting ─────────────────────────────────────────────────────────────
/** Tight limit on auth routes to prevent brute-force attacks */
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests, please try again later' },
});

/** General API limit */
const generalLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 120,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests, please try again later' },
});

app.use('/api/auth', authLimiter);
app.use('/api', generalLimiter);

// ── Routes ────────────────────────────────────────────────────────────────────
app.use('/api/auth', authRouter);
app.use('/api/save', saveRouter);

/** Health check */
app.get('/api/health', (_req, res) => res.json({ status: 'ok' }));

// ── 404 handler ───────────────────────────────────────────────────────────────
app.use((_req, res) => res.status(404).json({ error: 'Not found' }));

// ── Global error handler ──────────────────────────────────────────────────────
// eslint-disable-next-line no-unused-vars
app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

// ── Bootstrap DB & start ──────────────────────────────────────────────────────
if (require.main === module) {
  getDb(); // Ensures tables are created on startup
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`[server] Pendulum of Despair API listening on http://localhost:${PORT}`);
  });
}

module.exports = app;
