/**
 * middleware/auth.ts
 * JWT verification middleware.
 * Attaches `req.user = { id, username }` when a valid token is present.
 */

import jwt from "jsonwebtoken";
import type { Request, Response, NextFunction } from "express";
import type { JwtPayload } from "@pendulum/shared";

export interface AuthenticatedRequest extends Request {
  user: { id: number; username: string };
}

if (!process.env["JWT_SECRET"]) {
  if (process.env["NODE_ENV"] === "production") {
    throw new Error("FATAL: JWT_SECRET environment variable is required in production");
  }
  console.warn("[WARN] JWT_SECRET not set — using insecure default. Do NOT use in production.");
}
export const JWT_SECRET: string = process.env["JWT_SECRET"] ?? "change-me-in-production";

/**
 * Express middleware that reads a Bearer token from the Authorization header,
 * verifies it, and attaches the decoded payload to `req.user`.
 * Responds with 401 if the token is missing or invalid.
 */
export function requireAuth(req: Request, res: Response, next: NextFunction): void {
  const header = req.headers.authorization ?? "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;

  if (!token) {
    res.status(401).json({ error: "Authorization token required" });
    return;
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET) as unknown as JwtPayload;
    (req as AuthenticatedRequest).user = { id: payload.sub, username: payload.username };
    next();
  } catch {
    res.status(401).json({ error: "Invalid or expired token" });
    return;
  }
}
