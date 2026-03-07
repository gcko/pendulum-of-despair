/**
 * routes/auth.ts
 * Authentication routes: register and login.
 *
 * POST /api/auth/register  - Create a new account
 * POST /api/auth/login     - Authenticate and receive a JWT
 */

import express from "express";
import type { Request, Response } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { getDb } from "../db/init.js";
import { JWT_SECRET } from "../middleware/auth.js";
import {
  USERNAME_MIN,
  USERNAME_MAX,
  PASSPHRASE_MIN,
  PASSPHRASE_MAX,
} from "@pendulum/shared";
import type { AuthRequestBody, AuthResponse, ApiError } from "@pendulum/shared";

const router = express.Router();

const BCRYPT_ROUNDS = 12;
const TOKEN_TTL = "7d";

/**
 * Validates that a username contains only safe characters.
 */
function isValidUsername(username: string): boolean {
  return /^[a-zA-Z0-9_-]+$/.test(username);
}

/**
 * Issues a signed JWT for the given user.
 */
function signToken(user: { id: number; username: string }): string {
  return jwt.sign(
    { sub: user.id, username: user.username },
    JWT_SECRET,
    { expiresIn: TOKEN_TTL },
  );
}

/**
 * POST /api/auth/register
 * Body: { username: string, passphrase: string }
 * Creates a new user account and returns a JWT.
 */
router.post("/register", async (req: Request, res: Response<AuthResponse | ApiError>) => {
  const body = req.body as Partial<AuthRequestBody> | undefined;
  const username = body?.username;
  const passphrase = body?.passphrase;

  if (
    typeof username !== "string" ||
    typeof passphrase !== "string" ||
    username.length < USERNAME_MIN ||
    username.length > USERNAME_MAX ||
    !isValidUsername(username) ||
    passphrase.length < PASSPHRASE_MIN ||
    passphrase.length > PASSPHRASE_MAX
  ) {
    res.status(400).json({
      error:
        `Username must be ${USERNAME_MIN}\u2013${USERNAME_MAX} alphanumeric characters ` +
        `(underscores/hyphens allowed). Passphrase must be ${PASSPHRASE_MIN}\u2013${PASSPHRASE_MAX} characters.`,
    });
    return;
  }

  const db = getDb();

  const existing = db.prepare("SELECT id FROM users WHERE username = ?").get(username) as
    | { id: number }
    | undefined;
  if (existing) {
    res.status(409).json({ error: "Username already taken" });
    return;
  }

  const hash = await bcrypt.hash(passphrase, BCRYPT_ROUNDS);

  const result = db
    .prepare("INSERT INTO users (username, passphrase_hash) VALUES (?, ?)")
    .run(username, hash);

  const token = signToken({ id: Number(result.lastInsertRowid), username });
  res.status(201).json({ token, username });
  return;
});

/**
 * POST /api/auth/login
 * Body: { username: string, passphrase: string }
 * Validates credentials and returns a JWT.
 */
router.post("/login", async (req: Request, res: Response<AuthResponse | ApiError>) => {
  const body = req.body as Partial<AuthRequestBody> | undefined;
  const username = body?.username;
  const passphrase = body?.passphrase;

  if (typeof username !== "string" || typeof passphrase !== "string") {
    res.status(400).json({ error: "Username and passphrase are required" });
    return;
  }

  const db = getDb();
  const user = db
    .prepare("SELECT id, username, passphrase_hash FROM users WHERE username = ?")
    .get(username) as { id: number; username: string; passphrase_hash: string } | undefined;

  if (!user) {
    // Use constant-time comparison stub to avoid user enumeration via timing
    await bcrypt.compare(passphrase, "$2a$12$invalidhashpadding000000000000000000000000000000000000");
    res.status(401).json({ error: "Invalid username or passphrase" });
    return;
  }

  const valid = await bcrypt.compare(passphrase, user.passphrase_hash);
  if (!valid) {
    res.status(401).json({ error: "Invalid username or passphrase" });
    return;
  }

  const token = signToken({ id: user.id, username: user.username });
  res.json({ token, username: user.username });
  return;
});

export default router;
