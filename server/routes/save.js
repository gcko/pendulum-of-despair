/**
 * routes/save.js
 * Save/load routes for player game state.
 *
 * GET  /api/save/:slot   – Load a save slot (1–3)
 * PUT  /api/save/:slot   – Write/overwrite a save slot
 * GET  /api/save         – List all save slot summaries for the user
 */

'use strict';

const express = require('express');
const { getDb } = require('../db/init');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

/** All save routes require authentication. */
router.use(requireAuth);

const VALID_SLOTS = [1, 2, 3];
const MAX_SAVE_BYTES = 512 * 1024; // 512 KB per save slot

/**
 * GET /api/save
 * Returns summary metadata for all save slots belonging to the user.
 * Missing slots are included with null data so the client can show empty slots.
 */
router.get('/', (req, res) => {
  const db = getDb();
  const rows = db
    .prepare('SELECT slot, save_data, updated_at FROM saves WHERE user_id = ? ORDER BY slot ASC')
    .all(req.user.id);

  const slotMap = {};
  for (const row of rows) {
    try {
      const data = JSON.parse(row.save_data);
      slotMap[row.slot] = {
        slot: row.slot,
        updatedAt: row.updated_at,
        playtime: data.playtime || 0,
        location: data.currentMap || 'Unknown',
        party: (data.party || []).map((c) => ({ name: c.name, level: c.level })),
      };
    } catch {
      slotMap[row.slot] = { slot: row.slot, updatedAt: row.updated_at, corrupted: true };
    }
  }

  const result = VALID_SLOTS.map((s) => slotMap[s] || { slot: s, empty: true });
  return res.json(result);
});

/**
 * GET /api/save/:slot
 * Returns the full save data for a specific slot.
 */
router.get('/:slot', (req, res) => {
  const slot = parseInt(req.params.slot, 10);
  if (!VALID_SLOTS.includes(slot)) {
    return res.status(400).json({ error: 'Slot must be 1, 2, or 3' });
  }

  const db = getDb();
  const row = db
    .prepare('SELECT save_data, updated_at FROM saves WHERE user_id = ? AND slot = ?')
    .get(req.user.id, slot);

  if (!row) {
    return res.status(404).json({ error: 'No save data found for this slot' });
  }

  let data;
  try {
    data = JSON.parse(row.save_data);
  } catch {
    return res.status(500).json({ error: 'Save data is corrupted' });
  }

  return res.json({ slot, updatedAt: row.updated_at, data });
});

/**
 * PUT /api/save/:slot
 * Writes (or overwrites) a save slot with the provided game state.
 * Body: full game state JSON object.
 */
router.put('/:slot', (req, res) => {
  const slot = parseInt(req.params.slot, 10);
  if (!VALID_SLOTS.includes(slot)) {
    return res.status(400).json({ error: 'Slot must be 1, 2, or 3' });
  }

  const saveData = req.body;
  if (!saveData || typeof saveData !== 'object' || Array.isArray(saveData)) {
    return res.status(400).json({ error: 'Save data must be a JSON object' });
  }

  const serialized = JSON.stringify(saveData);
  if (Buffer.byteLength(serialized, 'utf8') > MAX_SAVE_BYTES) {
    return res.status(413).json({ error: 'Save data exceeds maximum allowed size' });
  }

  const db = getDb();
  db.prepare(`
    INSERT INTO saves (user_id, slot, save_data, updated_at)
    VALUES (?, ?, ?, unixepoch())
    ON CONFLICT(user_id, slot) DO UPDATE SET
      save_data  = excluded.save_data,
      updated_at = unixepoch()
  `).run(req.user.id, slot, serialized);

  return res.json({ success: true, slot });
});

module.exports = router;
