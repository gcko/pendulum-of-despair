/**
 * app.ts
 * Pendulum of Despair - Express API application setup.
 *
 * Provides authentication (register/login) and save/load endpoints
 * for persistent game state. All game logic runs client-side in Phaser 3.
 */

import "dotenv/config";
import express from "express";
import type { Request, Response } from "express";
import cors from "cors";
import rateLimit from "express-rate-limit";
import authRouter from "./routes/auth.js";
import saveRouter from "./routes/save.js";
import type { HealthResponse, ApiError } from "@pendulum/shared";

const app = express();

// -- CORS --
const corsOrigin = process.env["CORS_ORIGIN"] ?? "*";
app.use(cors({ origin: corsOrigin }));

// -- Body parsing --
app.use(express.json({ limit: "520kb" })); // Slightly above 512KB save slot limit

// -- Rate limiting --
/** Tight limit on auth routes to prevent brute-force attacks */
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "Too many requests, please try again later" },
});

/** General API limit */
const generalLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 120,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "Too many requests, please try again later" },
});

app.use("/api/auth", authLimiter);
app.use("/api", generalLimiter);

// -- Routes --
app.use("/api/auth", authRouter);
app.use("/api/save", saveRouter);

/** Health check */
app.get("/api/health", (_req: Request, res: Response<HealthResponse>) => {
  res.json({ status: "ok" });
});

// -- 404 handler --
app.use((_req: Request, res: Response<ApiError>) => {
  res.status(404).json({ error: "Not found" });
});

export default app;
