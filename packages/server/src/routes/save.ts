/**
 * routes/save.ts
 * Save/load routes for player game state.
 *
 * GET  /api/save/:slot   - Load a save slot (1-3)
 * PUT  /api/save/:slot   - Write/overwrite a save slot
 * GET  /api/save         - List all save slot summaries for the user
 */

import express from "express";
import type { Request, Response } from "express";
import { getDb } from "../db/init.js";
import { requireAuth } from "../middleware/auth.js";
import type { AuthenticatedRequest } from "../middleware/auth.js";
import {
  VALID_SLOTS,
  MAX_SAVE_BYTES,
} from "@pendulum/shared";
import type {
  SaveSlot,
  SaveSlotSummary,
  SaveSlotFull,
  SaveSuccessResponse,
  ApiError,
  GameSaveState,
} from "@pendulum/shared";

const router = express.Router();

/** All save routes require authentication. */
router.use(requireAuth);

/**
 * GET /api/save
 * Returns summary metadata for all save slots belonging to the user.
 * Missing slots are included with null data so the client can show empty slots.
 */
router.get("/", (req: Request, res: Response<SaveSlotSummary[]>) => {
  const db = getDb();
  const userId = (req as AuthenticatedRequest).user.id;
  const rows = db
    .prepare("SELECT slot, save_data, updated_at FROM saves WHERE user_id = ? ORDER BY slot ASC")
    .all(userId) as Array<{ slot: number; save_data: string; updated_at: number }>;

  const slotMap: Record<number, SaveSlotSummary> = {};
  for (const row of rows) {
    try {
      const data = JSON.parse(row.save_data) as Partial<GameSaveState>;
      slotMap[row.slot] = {
        slot: row.slot,
        updatedAt: row.updated_at,
        playtime: data.playtime ?? 0,
        location: data.currentMap ?? "Unknown",
        party: (data.party ?? []).map((c: { name: string; level: number }) => ({
          name: c.name,
          level: c.level,
        })),
      };
    } catch {
      slotMap[row.slot] = { slot: row.slot, updatedAt: row.updated_at, corrupted: true };
    }
  }

  const result = VALID_SLOTS.map((s: SaveSlot) => slotMap[s] ?? { slot: s, empty: true });
  res.json(result);
  return;
});

/**
 * GET /api/save/:slot
 * Returns the full save data for a specific slot.
 */
router.get("/:slot", (req: Request, res: Response<SaveSlotFull | ApiError>) => {
  const slotParam = req.params["slot"] ?? "";
  const slot = parseInt(typeof slotParam === "string" ? slotParam : String(slotParam), 10);
  if (!VALID_SLOTS.includes(slot as SaveSlot)) {
    res.status(400).json({ error: "Slot must be 1, 2, or 3" });
    return;
  }

  const db = getDb();
  const userId = (req as AuthenticatedRequest).user.id;
  const row = db
    .prepare("SELECT save_data, updated_at FROM saves WHERE user_id = ? AND slot = ?")
    .get(userId, slot) as { save_data: string; updated_at: number } | undefined;

  if (!row) {
    res.status(404).json({ error: "No save data found for this slot" });
    return;
  }

  let data: GameSaveState;
  try {
    data = JSON.parse(row.save_data) as GameSaveState;
  } catch {
    res.status(500).json({ error: "Save data is corrupted" });
    return;
  }

  res.json({ slot, updatedAt: row.updated_at, data });
  return;
});

/**
 * PUT /api/save/:slot
 * Writes (or overwrites) a save slot with the provided game state.
 * Body: full game state JSON object.
 */
router.put("/:slot", (req: Request, res: Response<SaveSuccessResponse | ApiError>) => {
  const slotParam = req.params["slot"] ?? "";
  const slot = parseInt(typeof slotParam === "string" ? slotParam : String(slotParam), 10);
  if (!VALID_SLOTS.includes(slot as SaveSlot)) {
    res.status(400).json({ error: "Slot must be 1, 2, or 3" });
    return;
  }

  const saveData: unknown = req.body;
  if (!saveData || typeof saveData !== "object" || Array.isArray(saveData)) {
    res.status(400).json({ error: "Save data must be a JSON object" });
    return;
  }

  const serialized = JSON.stringify(saveData);
  if (Buffer.byteLength(serialized, "utf8") > MAX_SAVE_BYTES) {
    res.status(413).json({ error: "Save data exceeds maximum allowed size" });
    return;
  }

  const db = getDb();
  const userId = (req as AuthenticatedRequest).user.id;
  db.prepare(`
    INSERT INTO saves (user_id, slot, save_data, updated_at)
    VALUES (?, ?, ?, unixepoch())
    ON CONFLICT(user_id, slot) DO UPDATE SET
      save_data  = excluded.save_data,
      updated_at = unixepoch()
  `).run(userId, slot, serialized);

  res.json({ success: true, slot });
  return;
});

export default router;
