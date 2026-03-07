/**
 * db/init.ts
 * Initializes the SQLite database schema for Pendulum of Despair.
 * Uses the built-in `node:sqlite` module (Node.js >= 22.5.0 required).
 * Creates the `users` and `saves` tables if they don't already exist.
 */

import { DatabaseSync } from "node:sqlite";
import { fileURLToPath } from "node:url";
import * as path from "node:path";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

/** Path to the SQLite file (can be overridden via DB_PATH env var). */
const DB_PATH = process.env["DB_PATH"] ?? path.join(__dirname, "..", "..", "game.db");

let db: DatabaseSync | null = null;

/**
 * Returns a singleton SQLite Database instance.
 * @param dbPath - Optional path override (used in tests).
 */
export function getDb(dbPath?: string): DatabaseSync {
  if (db) return db;
  db = new DatabaseSync(dbPath ?? DB_PATH);

  // Enable WAL mode for better concurrent read performance (skip for in-memory DBs)
  const targetPath = dbPath ?? DB_PATH;
  if (targetPath !== ":memory:") {
    db.exec("PRAGMA journal_mode = WAL;");
  }
  db.exec("PRAGMA foreign_keys = ON;");

  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id        INTEGER PRIMARY KEY AUTOINCREMENT,
      username  TEXT    NOT NULL UNIQUE COLLATE NOCASE,
      passphrase_hash TEXT NOT NULL,
      created_at INTEGER NOT NULL DEFAULT (unixepoch())
    );

    CREATE TABLE IF NOT EXISTS saves (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      slot       INTEGER NOT NULL DEFAULT 1,
      save_data  TEXT    NOT NULL,
      updated_at INTEGER NOT NULL DEFAULT (unixepoch()),
      UNIQUE(user_id, slot)
    );
  `);

  return db;
}

/**
 * Resets the singleton (used between tests to get a fresh in-memory DB).
 */
export function resetDb(): void {
  db = null;
}
