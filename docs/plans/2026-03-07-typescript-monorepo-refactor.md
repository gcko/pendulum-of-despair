# TypeScript Monorepo Refactor — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Convert the entire Pendulum of Despair codebase from plain JavaScript to a strict-TypeScript pnpm workspace monorepo with Vitest, Vite, and zero `any` types.

**Architecture:** pnpm workspace with three packages: `@pendulum/shared` (types/constants), `@pendulum/server` (Express API), and `@pendulum/client` (Phaser 3 + Vite). All packages use ESM, strict TypeScript 5.8, and Vitest. The server uses `tsx` for dev and `tsc` for production builds.

**Tech Stack:** TypeScript 5.8, pnpm 10 (corepack), Vite 6, Vitest, Phaser 3.80, Express 4, node:sqlite (Node 24+), tsx, supertest

---

## Task 1: Scaffold monorepo root and workspace config

**Files:**
- Create: `.naverc`
- Create: `pnpm-workspace.yaml`
- Create: `tsconfig.base.json`
- Create: `vitest.workspace.ts`
- Modify: `package.json` (root — currently does not exist at root)
- Modify: `.gitignore`

**Step 1: Create `.naverc`**

```
lts
```

**Step 2: Create root `package.json`**

```json
{
  "name": "pendulum-of-despair",
  "private": true,
  "type": "module",
  "packageManager": "pnpm@10.6.5",
  "engines": {
    "node": ">=24.0.0"
  },
  "scripts": {
    "build": "pnpm -r run build",
    "dev:server": "pnpm --filter @pendulum/server dev",
    "dev:client": "pnpm --filter @pendulum/client dev",
    "test": "vitest run",
    "test:watch": "vitest",
    "lint": "tsc -b --noEmit"
  }
}
```

**Step 3: Create `pnpm-workspace.yaml`**

```yaml
packages:
  - "packages/*"
```

**Step 4: Create `tsconfig.base.json`**

```json
{
  "compilerOptions": {
    "target": "ES2024",
    "module": "Node16",
    "moduleResolution": "Node16",
    "lib": ["ES2024"],
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": false,
    "forceConsistentCasingInFileNames": true,
    "verbatimModuleSyntax": true,
    "skipLibCheck": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "esModuleInterop": false,
    "isolatedModules": true,
    "resolveJsonModule": true
  }
}
```

**Step 5: Create `vitest.workspace.ts`**

```ts
import { defineWorkspace } from "vitest/config";

export default defineWorkspace(["packages/server", "packages/client"]);
```

**Step 6: Update `.gitignore`**

```
node_modules/
.env
*.db
*.sqlite
*.db-shm
*.db-wal
dist/
.DS_Store
coverage/
*.tsbuildinfo
.vite/
```

**Step 7: Enable corepack and install root deps**

Run:
```bash
corepack enable && corepack prepare pnpm@10.6.5 --activate
pnpm add -Dw vitest typescript
```

**Step 8: Commit**

```bash
git add -A
git commit -m "chore: scaffold pnpm workspace monorepo with TypeScript and Vitest config"
```

---

## Task 2: Create `@pendulum/shared` types package

**Files:**
- Create: `packages/shared/package.json`
- Create: `packages/shared/tsconfig.json`
- Create: `packages/shared/src/index.ts`
- Create: `packages/shared/src/types/api.ts`
- Create: `packages/shared/src/types/game.ts`
- Create: `packages/shared/src/types/index.ts`

**Step 1: Create `packages/shared/package.json`**

```json
{
  "name": "@pendulum/shared",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": {
      "import": "./src/index.ts",
      "types": "./src/index.ts"
    }
  },
  "scripts": {
    "build": "tsc",
    "typecheck": "tsc --noEmit"
  }
}
```

**Step 2: Create `packages/shared/tsconfig.json`**

```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src"]
}
```

**Step 3: Create `packages/shared/src/types/game.ts`**

Define all game-state types derived from the existing JSON data files and save structure:

```ts
/** Character stat block — maps to characters.json entries */
export interface CharacterStats {
  hp: number;
  maxHp: number;
  mp: number;
  maxMp: number;
  str: number;
  def: number;
  mag: number;
  mdef: number;
  spd: number;
  level: number;
  exp: number;
}

/** Party member as stored in save data */
export interface PartyMember {
  name: string;
  characterId: string;
  level: number;
  hp: number;
  mp: number;
  stats: CharacterStats;
  abilities: string[];
  equipment: Equipment;
  statusEffects: string[];
}

/** Equipment slots */
export interface Equipment {
  weapon: string | null;
  armor: string | null;
  accessory: string | null;
}

/** Inventory item with quantity */
export interface InventoryItem {
  id: string;
  qty: number;
}

/** Position on the world map */
export interface MapPosition {
  x: number;
  y: number;
}

/** Full game save state — the blob stored in the `saves` table */
export interface GameSaveState {
  party: PartyMember[];
  inventory: InventoryItem[];
  gp: number;
  worldFlags: Record<string, boolean>;
  currentMap: string;
  currentPosition: MapPosition;
  playtime: number;
}

/** Summary shown in the save slot listing */
export interface SaveSlotSummary {
  slot: number;
  updatedAt?: number;
  playtime?: number;
  location?: string;
  party?: Array<{ name: string; level: number }>;
  empty?: boolean;
  corrupted?: boolean;
}

/** Full save slot response (GET /api/save/:slot) */
export interface SaveSlotFull {
  slot: number;
  updatedAt: number;
  data: GameSaveState;
}

/** Enemy AI pattern types */
export type EnemyAiPattern =
  | "basic_attack"
  | "aggressive"
  | "defensive"
  | "magic_focus"
  | "pattern";

/** Enemy definition from enemies.json */
export interface EnemyDefinition {
  id: string;
  name: string;
  hp: number;
  mp: number;
  str: number;
  def: number;
  mag: number;
  mdef: number;
  spd: number;
  exp: number;
  gp: number;
  aiPattern: EnemyAiPattern;
  abilities: string[];
  weaknesses: string[];
  resistances: string[];
  steals: string[];
}

/** Ability definition from abilities.json */
export interface AbilityDefinition {
  id: string;
  name: string;
  type: "physical" | "magical" | "special" | "item";
  element?: string;
  power: number;
  mpCost: number;
  target: "single" | "all" | "self" | "ally" | "allAllies";
  description: string;
}

/** Item definition from items.json */
export interface ItemDefinition {
  id: string;
  name: string;
  type: "consumable" | "weapon" | "armor" | "accessory" | "key";
  description: string;
  effect?: Record<string, number>;
  stats?: Partial<CharacterStats>;
  price: number;
}
```

**Step 4: Create `packages/shared/src/types/api.ts`**

```ts
/** POST /api/auth/register & /api/auth/login request body */
export interface AuthRequestBody {
  username: string;
  passphrase: string;
}

/** POST /api/auth/register response (201) */
export interface AuthResponse {
  token: string;
  username: string;
}

/** JWT payload (decoded token) */
export interface JwtPayload {
  sub: number;
  username: string;
  iat: number;
  exp: number;
}

/** Generic API error response */
export interface ApiError {
  error: string;
}

/** PUT /api/save/:slot success response */
export interface SaveSuccessResponse {
  success: true;
  slot: number;
}

/** Health check response */
export interface HealthResponse {
  status: "ok";
}

/** Valid save slot numbers */
export type SaveSlot = 1 | 2 | 3;
export const VALID_SLOTS: readonly SaveSlot[] = [1, 2, 3] as const;
export const MAX_SAVE_BYTES = 512 * 1024;

/** Auth validation constants */
export const USERNAME_MIN = 3;
export const USERNAME_MAX = 32;
export const PASSPHRASE_MIN = 6;
export const PASSPHRASE_MAX = 128;
```

**Step 5: Create `packages/shared/src/types/index.ts`**

```ts
export * from "./api.js";
export * from "./game.js";
```

**Step 6: Create `packages/shared/src/index.ts`**

```ts
export * from "./types/index.js";
```

**Step 7: Verify it compiles**

Run:
```bash
cd packages/shared && pnpm exec tsc --noEmit
```
Expected: no errors

**Step 8: Commit**

```bash
git add packages/shared
git commit -m "feat: add @pendulum/shared types package with API and game-state types"
```

---

## Task 3: Convert server to TypeScript with Vitest

**Files:**
- Create: `packages/server/package.json`
- Create: `packages/server/tsconfig.json`
- Create: `packages/server/vitest.config.ts`
- Create: `packages/server/src/app.ts` (from `server/index.js`)
- Create: `packages/server/src/index.ts` (entry point)
- Create: `packages/server/src/db/init.ts` (from `server/db/init.js`)
- Create: `packages/server/src/routes/auth.ts` (from `server/routes/auth.js`)
- Create: `packages/server/src/routes/save.ts` (from `server/routes/save.js`)
- Create: `packages/server/src/middleware/auth.ts` (from `server/middleware/auth.js`)
- Create: `packages/server/src/__tests__/setup.ts` (from `server/jest.setup.js`)
- Create: `packages/server/src/__tests__/auth.test.ts` (from `server/__tests__/auth.test.js`)
- Create: `packages/server/src/__tests__/save.test.ts` (from `server/__tests__/save.test.js`)
- Create: `packages/server/.env.example`

**Step 1: Create `packages/server/package.json`**

```json
{
  "name": "@pendulum/server",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "build": "tsc",
    "dev": "tsx --watch src/index.ts",
    "start": "node dist/index.js",
    "test": "vitest run",
    "test:watch": "vitest",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@pendulum/shared": "workspace:*",
    "bcryptjs": "^2.4.3",
    "cors": "^2.8.5",
    "dotenv": "^16.4.5",
    "express": "^4.22.1",
    "express-rate-limit": "^7.2.0",
    "jsonwebtoken": "^9.0.2"
  },
  "devDependencies": {
    "@types/bcryptjs": "^2.4.6",
    "@types/cors": "^2.8.17",
    "@types/express": "^5.0.0",
    "@types/jsonwebtoken": "^9.0.9",
    "@types/supertest": "^6.0.2",
    "supertest": "^7.2.2",
    "tsx": "^4.19.0",
    "vitest": "^3.0.0"
  },
  "engines": {
    "node": ">=24.0.0"
  }
}
```

**Step 2: Create `packages/server/tsconfig.json`**

```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src"],
  "references": [{ "path": "../shared" }]
}
```

**Step 3: Create `packages/server/vitest.config.ts`**

```ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "node",
    setupFiles: ["src/__tests__/setup.ts"],
    include: ["src/__tests__/**/*.test.ts"],
  },
});
```

**Step 4: Create `packages/server/.env.example`**

```
JWT_SECRET=change-me-in-production
PORT=3000
DB_PATH=./game.db
CORS_ORIGIN=*
```

**Step 5: Create `packages/server/src/db/init.ts`**

```ts
import path from "node:path";
import { fileURLToPath } from "node:url";
import { DatabaseSync } from "node:sqlite";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DEFAULT_DB_PATH = process.env["DB_PATH"] ?? path.join(__dirname, "..", "..", "game.db");

let db: DatabaseSync | null = null;

export function getDb(dbPath?: string): DatabaseSync {
  if (db) return db;

  const targetPath = dbPath ?? DEFAULT_DB_PATH;
  db = new DatabaseSync(targetPath);

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

export function resetDb(): void {
  db = null;
}
```

**Step 6: Create `packages/server/src/middleware/auth.ts`**

```ts
import type { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import type { JwtPayload } from "@pendulum/shared";

if (!process.env["JWT_SECRET"]) {
  if (process.env["NODE_ENV"] === "production") {
    throw new Error("FATAL: JWT_SECRET environment variable is required in production");
  }
  console.warn("[WARN] JWT_SECRET not set — using insecure default. Do NOT use in production.");
}

export const JWT_SECRET: string = process.env["JWT_SECRET"] ?? "change-me-in-production";

/** Augment Express Request with typed user property */
export interface AuthenticatedRequest extends Request {
  user: { id: number; username: string };
}

export function requireAuth(req: Request, res: Response, next: NextFunction): void {
  const header = req.headers.authorization ?? "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;

  if (!token) {
    res.status(401).json({ error: "Authorization token required" });
    return;
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET) as JwtPayload;
    (req as AuthenticatedRequest).user = { id: payload.sub, username: payload.username };
    next();
  } catch {
    res.status(401).json({ error: "Invalid or expired token" });
  }
}
```

**Step 7: Create `packages/server/src/routes/auth.ts`**

```ts
import { Router } from "express";
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
  type AuthRequestBody,
  type AuthResponse,
  type ApiError,
} from "@pendulum/shared";

const router = Router();

const BCRYPT_ROUNDS = 12;
const TOKEN_TTL = "7d";

function isValidUsername(username: string): boolean {
  return /^[a-zA-Z0-9_-]+$/.test(username);
}

function signToken(user: { id: number; username: string }): string {
  return jwt.sign({ sub: user.id, username: user.username }, JWT_SECRET, {
    expiresIn: TOKEN_TTL,
  });
}

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
        `Username must be ${USERNAME_MIN}–${USERNAME_MAX} alphanumeric characters ` +
        `(underscores/hyphens allowed). Passphrase must be ${PASSPHRASE_MIN}–${PASSPHRASE_MAX} characters.`,
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
});

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
});

export default router;
```

**Step 8: Create `packages/server/src/routes/save.ts`**

```ts
import { Router } from "express";
import type { Request, Response } from "express";
import { getDb } from "../db/init.js";
import { requireAuth, type AuthenticatedRequest } from "../middleware/auth.js";
import {
  VALID_SLOTS,
  MAX_SAVE_BYTES,
  type SaveSlot,
  type SaveSlotSummary,
  type SaveSlotFull,
  type SaveSuccessResponse,
  type ApiError,
  type GameSaveState,
} from "@pendulum/shared";

const router = Router();

router.use(requireAuth);

router.get("/", (req: Request, res: Response<SaveSlotSummary[]>) => {
  const { id: userId } = (req as AuthenticatedRequest).user;
  const db = getDb();
  const rows = db
    .prepare("SELECT slot, save_data, updated_at FROM saves WHERE user_id = ? ORDER BY slot ASC")
    .all(userId) as Array<{ slot: number; save_data: string; updated_at: number }>;

  const slotMap = new Map<number, SaveSlotSummary>();
  for (const row of rows) {
    try {
      const data = JSON.parse(row.save_data) as Partial<GameSaveState>;
      slotMap.set(row.slot, {
        slot: row.slot,
        updatedAt: row.updated_at,
        playtime: data.playtime ?? 0,
        location: data.currentMap ?? "Unknown",
        party: (data.party ?? []).map((c) => ({ name: c.name, level: c.level })),
      });
    } catch {
      slotMap.set(row.slot, { slot: row.slot, updatedAt: row.updated_at, corrupted: true });
    }
  }

  const result = VALID_SLOTS.map((s) => slotMap.get(s) ?? { slot: s, empty: true });
  res.json(result);
});

router.get("/:slot", (req: Request, res: Response<SaveSlotFull | ApiError>) => {
  const slot = parseInt(req.params["slot"] ?? "", 10) as SaveSlot;
  if (!VALID_SLOTS.includes(slot)) {
    res.status(400).json({ error: "Slot must be 1, 2, or 3" });
    return;
  }

  const { id: userId } = (req as AuthenticatedRequest).user;
  const db = getDb();
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
});

router.put("/:slot", (req: Request, res: Response<SaveSuccessResponse | ApiError>) => {
  const slot = parseInt(req.params["slot"] ?? "", 10) as SaveSlot;
  if (!VALID_SLOTS.includes(slot)) {
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

  const { id: userId } = (req as AuthenticatedRequest).user;
  const db = getDb();
  db.prepare(`
    INSERT INTO saves (user_id, slot, save_data, updated_at)
    VALUES (?, ?, ?, unixepoch())
    ON CONFLICT(user_id, slot) DO UPDATE SET
      save_data  = excluded.save_data,
      updated_at = unixepoch()
  `).run(userId, slot, serialized);

  res.json({ success: true, slot });
});

export default router;
```

**Step 9: Create `packages/server/src/app.ts`**

```ts
import "dotenv/config";
import express from "express";
import cors from "cors";
import rateLimit from "express-rate-limit";
import authRouter from "./routes/auth.js";
import saveRouter from "./routes/save.js";

const app = express();

const corsOrigin = process.env["CORS_ORIGIN"] ?? "*";
app.use(cors({ origin: corsOrigin }));

app.use(express.json({ limit: "520kb" }));

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "Too many requests, please try again later" },
});

const generalLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 120,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "Too many requests, please try again later" },
});

app.use("/api/auth", authLimiter);
app.use("/api", generalLimiter);

app.use("/api/auth", authRouter);
app.use("/api/save", saveRouter);

app.get("/api/health", (_req, res) => {
  res.json({ status: "ok" });
});

app.use((_req, res) => {
  res.status(404).json({ error: "Not found" });
});

export default app;
```

**Step 10: Create `packages/server/src/index.ts`**

```ts
import { getDb } from "./db/init.js";
import app from "./app.js";

getDb();
const PORT = parseInt(process.env["PORT"] ?? "3000", 10);
app.listen(PORT, () => {
  console.log(`[server] Pendulum of Despair API listening on http://localhost:${PORT}`);
});
```

**Step 11: Create `packages/server/src/__tests__/setup.ts`**

```ts
process.env["DB_PATH"] = ":memory:";
process.env["JWT_SECRET"] = "test-secret-key";
process.env["NODE_NO_WARNINGS"] = "1";
```

**Step 12: Create `packages/server/src/__tests__/auth.test.ts`**

```ts
import { describe, test, expect, beforeEach, afterAll } from "vitest";
import request from "supertest";
import { resetDb } from "../db/init.js";
import app from "../app.js";

beforeEach(() => {
  resetDb();
});

afterAll(() => {
  resetDb();
});

describe("POST /api/auth/register", () => {
  test("creates a new user and returns a token", async () => {
    const res = await request(app)
      .post("/api/auth/register")
      .send({ username: "Terra", passphrase: "espers123" });

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty("token");
    expect(res.body.username).toBe("Terra");
  });

  test("rejects duplicate username (case-insensitive)", async () => {
    await request(app)
      .post("/api/auth/register")
      .send({ username: "Terra", passphrase: "espers123" });

    const res = await request(app)
      .post("/api/auth/register")
      .send({ username: "terra", passphrase: "different123" });

    expect(res.status).toBe(409);
    expect(res.body).toHaveProperty("error");
  });

  test("rejects username that is too short", async () => {
    const res = await request(app)
      .post("/api/auth/register")
      .send({ username: "ab", passphrase: "espers123" });

    expect(res.status).toBe(400);
  });

  test("rejects username with invalid characters", async () => {
    const res = await request(app)
      .post("/api/auth/register")
      .send({ username: "Terra Branford!", passphrase: "espers123" });

    expect(res.status).toBe(400);
  });

  test("rejects passphrase that is too short", async () => {
    const res = await request(app)
      .post("/api/auth/register")
      .send({ username: "Locke", passphrase: "hi" });

    expect(res.status).toBe(400);
  });

  test("rejects missing body fields", async () => {
    const res = await request(app)
      .post("/api/auth/register")
      .send({});

    expect(res.status).toBe(400);
  });
});

describe("POST /api/auth/login", () => {
  beforeEach(async () => {
    await request(app)
      .post("/api/auth/register")
      .send({ username: "Celes", passphrase: "magitek456" });
  });

  test("returns token on valid credentials", async () => {
    const res = await request(app)
      .post("/api/auth/login")
      .send({ username: "Celes", passphrase: "magitek456" });

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty("token");
    expect(res.body.username).toBe("Celes");
  });

  test("rejects wrong passphrase", async () => {
    const res = await request(app)
      .post("/api/auth/login")
      .send({ username: "Celes", passphrase: "wrongpass" });

    expect(res.status).toBe(401);
  });

  test("rejects unknown username", async () => {
    const res = await request(app)
      .post("/api/auth/login")
      .send({ username: "Kefka", passphrase: "chaos123" });

    expect(res.status).toBe(401);
  });

  test("rejects missing fields", async () => {
    const res = await request(app)
      .post("/api/auth/login")
      .send({ username: "Celes" });

    expect(res.status).toBe(400);
  });
});
```

**Step 13: Create `packages/server/src/__tests__/save.test.ts`**

```ts
import { describe, test, expect, beforeEach, afterAll } from "vitest";
import request from "supertest";
import { resetDb } from "../db/init.js";
import app from "../app.js";

let token: string;

const SAMPLE_SAVE = {
  party: [
    { name: "Terra", level: 5, hp: 120, mp: 60 },
    { name: "Locke", level: 5, hp: 110, mp: 20 },
  ],
  inventory: [{ id: "potion", qty: 3 }],
  worldFlags: { intro_complete: true },
  currentMap: "narshe",
  currentPosition: { x: 10, y: 8 },
  playtime: 900,
};

beforeEach(async () => {
  resetDb();
  const res = await request(app)
    .post("/api/auth/register")
    .send({ username: "Shadow", passphrase: "interceptor99" });
  token = res.body.token as string;
});

afterAll(() => {
  resetDb();
});

describe("GET /api/save", () => {
  test("returns three empty slots for a new user", async () => {
    const res = await request(app)
      .get("/api/save")
      .set("Authorization", `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(3);
    expect(res.body.every((s: { empty?: boolean }) => s.empty)).toBe(true);
  });

  test("requires authentication", async () => {
    const res = await request(app).get("/api/save");
    expect(res.status).toBe(401);
  });
});

describe("PUT /api/save/:slot", () => {
  test("saves data to slot 1", async () => {
    const res = await request(app)
      .put("/api/save/1")
      .set("Authorization", `Bearer ${token}`)
      .send(SAMPLE_SAVE);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
  });

  test("rejects invalid slot numbers", async () => {
    const res = await request(app)
      .put("/api/save/5")
      .set("Authorization", `Bearer ${token}`)
      .send(SAMPLE_SAVE);

    expect(res.status).toBe(400);
  });

  test("rejects array body", async () => {
    const res = await request(app)
      .put("/api/save/1")
      .set("Authorization", `Bearer ${token}`)
      .send([SAMPLE_SAVE]);

    expect(res.status).toBe(400);
  });

  test("requires authentication", async () => {
    const res = await request(app)
      .put("/api/save/1")
      .send(SAMPLE_SAVE);

    expect(res.status).toBe(401);
  });
});

describe("GET /api/save/:slot", () => {
  beforeEach(async () => {
    await request(app)
      .put("/api/save/2")
      .set("Authorization", `Bearer ${token}`)
      .send(SAMPLE_SAVE);
  });

  test("loads saved data from slot 2", async () => {
    const res = await request(app)
      .get("/api/save/2")
      .set("Authorization", `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body.slot).toBe(2);
    expect(res.body.data.currentMap).toBe("narshe");
    expect(res.body.data.playtime).toBe(900);
  });

  test("returns 404 for an empty slot", async () => {
    const res = await request(app)
      .get("/api/save/3")
      .set("Authorization", `Bearer ${token}`);

    expect(res.status).toBe(404);
  });

  test("reflects saved data in slot listing", async () => {
    const res = await request(app)
      .get("/api/save")
      .set("Authorization", `Bearer ${token}`);

    expect(res.status).toBe(200);
    const slot2 = res.body.find((s: { slot: number }) => s.slot === 2);
    expect(slot2.empty).toBeFalsy();
    expect(slot2.location).toBe("narshe");
    expect(slot2.playtime).toBe(900);
  });

  test("overwrites existing save on second PUT", async () => {
    await request(app)
      .put("/api/save/2")
      .set("Authorization", `Bearer ${token}`)
      .send({ ...SAMPLE_SAVE, playtime: 1800, currentMap: "opera_house" });

    const res = await request(app)
      .get("/api/save/2")
      .set("Authorization", `Bearer ${token}`);

    expect(res.body.data.playtime).toBe(1800);
    expect(res.body.data.currentMap).toBe("opera_house");
  });
});
```

**Step 14: Install deps and run tests**

Run:
```bash
cd /path/to/root && pnpm install
cd packages/server && pnpm test
```
Expected: all 15 tests pass

**Step 15: Commit**

```bash
git add packages/server
git commit -m "feat: convert server to TypeScript with Vitest, strict types, ESM"
```

---

## Task 4: Convert client to TypeScript with Vite

**Files:**
- Create: `packages/client/package.json`
- Create: `packages/client/tsconfig.json`
- Create: `packages/client/vite.config.ts`
- Create: `packages/client/vitest.config.ts`
- Move/convert: `client/index.html` → `packages/client/index.html` (update script tag)
- Convert: `client/src/main.js` → `packages/client/src/main.ts`
- Convert: all `client/src/scenes/*.js` → `packages/client/src/scenes/*.ts`
- Convert: all `client/src/systems/*.js` → `packages/client/src/systems/*.ts`
- Copy: all `client/src/data/*.json` → `packages/client/src/data/*.json`

**Step 1: Create `packages/client/package.json`**

```json
{
  "name": "@pendulum/client",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "test": "vitest run",
    "test:watch": "vitest",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@pendulum/shared": "workspace:*",
    "phaser": "^3.80.1"
  },
  "devDependencies": {
    "vite": "^6.0.0",
    "vitest": "^3.0.0"
  }
}
```

**Step 2: Create `packages/client/tsconfig.json`**

The client needs DOM lib and Vite-compatible module resolution:

```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "target": "ES2024",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "lib": ["ES2024", "DOM", "DOM.Iterable"],
    "outDir": "dist",
    "rootDir": "src",
    "verbatimModuleSyntax": true
  },
  "include": ["src"],
  "references": [{ "path": "../shared" }]
}
```

**Step 3: Create `packages/client/vite.config.ts`**

```ts
import { defineConfig } from "vite";

export default defineConfig({
  root: ".",
  build: {
    outDir: "dist",
    sourcemap: true,
  },
  server: {
    port: 8080,
    proxy: {
      "/api": "http://localhost:3000",
    },
  },
});
```

**Step 4: Create `packages/client/vitest.config.ts`**

```ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "node",
    include: ["src/**/*.test.ts"],
  },
});
```

**Step 5: Convert `index.html`**

Remove the CDN Phaser script tag, update the module entry point:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Pendulum of Despair</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Press+Start+2P&display=swap" rel="stylesheet" />
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html, body {
      width: 100%; height: 100%;
      background: #000011;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
      font-family: 'Press Start 2P', monospace;
    }
    #game-container { position: relative; }
    #game-container canvas { display: block; image-rendering: pixelated; image-rendering: crisp-edges; }
    #loading-screen {
      position: fixed; inset: 0;
      display: flex; flex-direction: column;
      align-items: center; justify-content: center;
      background: #000022; color: #4488ff;
      font-size: 10px; gap: 16px;
      z-index: 200;
      transition: opacity 0.5s;
    }
    #loading-screen.hidden { opacity: 0; pointer-events: none; }
  </style>
</head>
<body>
  <div id="loading-screen">
    <div style="font-size:18px;color:#aaccff;letter-spacing:4px">PENDULUM OF DESPAIR</div>
    <div id="loading-msg">Loading...</div>
  </div>
  <div id="game-container"></div>
  <script type="module" src="/src/main.ts"></script>
  <script>
    document.addEventListener('DOMContentLoaded', () => {
      const interval = setInterval(() => {
        const canvas = document.querySelector('#game-container canvas');
        if (canvas) {
          clearInterval(interval);
          const screen = document.getElementById('loading-screen');
          if (screen) screen.classList.add('hidden');
        }
      }, 200);
    });
  </script>
</body>
</html>
```

**Step 6: Convert each client source file to TypeScript**

Convert all `.js` files in `client/src/` to `.ts` in `packages/client/src/`:
- Replace `Phaser` global references with `import Phaser from "phaser"`
- Add proper type annotations to all scene classes, methods, and properties
- Replace `any` with specific types from `@pendulum/shared` or Phaser types
- Use `import type` for type-only imports
- Copy all JSON data files unchanged to `packages/client/src/data/`

Each scene file must:
- Import Phaser: `import Phaser from "phaser";`
- `export default class XScene extends Phaser.Scene { ... }`
- Type all class properties explicitly
- Type all method parameters and return values

Each system file must:
- Use types from `@pendulum/shared` (e.g., `PartyMember`, `InventoryItem`, `GameSaveState`)
- Export typed functions (no `any`)

**Note:** The full client conversion involves reading each scene/system file and converting it. The implementing agent must read each JS file, understand its API surface, and produce a typed `.ts` equivalent. The key files and their conversions:

- `main.js` → `main.ts`: Import Phaser, type the config as `Phaser.Types.Core.GameConfig`, remove `window.saveLoadModule` global (import directly where needed)
- `scenes/BootScene.js` → `scenes/BootScene.ts`: Type all texture generation helpers
- `scenes/TitleScene.js` → `scenes/TitleScene.ts`: Type DOM overlay elements, auth API calls
- `scenes/WorldMapScene.js` → `scenes/WorldMapScene.ts`: Type tile map data, player sprite, encounter logic
- `scenes/BattleScene.js` → `scenes/BattleScene.ts`: Type combatant arrays, ATB gauge state, action queue
- `scenes/DialogueScene.js` → `scenes/DialogueScene.ts`: Type dialogue data, typewriter state
- `systems/combat.js` → `systems/combat.ts`: Use `PartyMember`, `EnemyDefinition`, `AbilityDefinition` from shared
- `systems/inventory.js` → `systems/inventory.ts`: Use `InventoryItem`, `ItemDefinition`, `Equipment` from shared
- `systems/saveLoad.js` → `systems/saveLoad.ts`: Use `AuthRequestBody`, `AuthResponse`, `GameSaveState`, `SaveSlotSummary` from shared

**Step 7: Add client unit tests for combat and inventory systems**

Create `packages/client/src/systems/combat.test.ts`:
- Test damage calculation formulas
- Test ATB gauge fill rate
- Test EXP distribution

Create `packages/client/src/systems/inventory.test.ts`:
- Test add/remove items
- Test equipment stat bonuses

**Step 8: Install deps, typecheck, and run tests**

Run:
```bash
cd /path/to/root && pnpm install
pnpm --filter @pendulum/client typecheck
pnpm --filter @pendulum/client test
```

**Step 9: Commit**

```bash
git add packages/client
git commit -m "feat: convert client to TypeScript with Vite, Phaser via npm, add unit tests"
```

---

## Task 5: Clean up old files and finalize

**Files:**
- Delete: `server/` (entire old directory)
- Delete: `client/` (entire old directory)
- Modify: `README.md` (update for new structure)

**Step 1: Remove old JS directories**

```bash
rm -rf server/ client/
```

**Step 2: Update README.md**

Update the architecture section to reflect the new `packages/` structure, update Getting Started with pnpm commands, update test commands to use `pnpm test`, note Node 24+ requirement, mention `.naverc`.

**Step 3: Run full workspace test suite**

Run:
```bash
pnpm test
```
Expected: all tests pass (server + client)

**Step 4: Run full typecheck**

Run:
```bash
pnpm lint
```
Expected: zero TypeScript errors

**Step 5: Verify dev workflow**

Run:
```bash
pnpm dev:server &
pnpm dev:client &
# Verify both start without errors, then kill
```

**Step 6: Final commit**

```bash
git add -A
git commit -m "chore: remove old JS source, update README for TypeScript monorepo"
```

---

## Task 6: Create PR

Run:
```bash
gh pr create --title "refactor: TypeScript monorepo with strict types, Vitest, Vite, pnpm" \
  --body "$(cat <<'EOF'
## Summary
- Convert entire codebase from plain JavaScript to strict TypeScript 5.8 (zero `any`)
- Restructure as pnpm workspace monorepo: `@pendulum/shared`, `@pendulum/server`, `@pendulum/client`
- Replace Jest with Vitest for all tests
- Replace CDN Phaser with npm dependency + Vite build
- Add shared types package for API contracts and game state
- Add `.naverc` with `lts`, corepack pnpm 10
- Server uses ESM + tsx for dev, tsc for prod
- Client uses Vite 6 with dev proxy to server

## Test plan
- [ ] `pnpm install` succeeds
- [ ] `pnpm test` — all server and client tests pass
- [ ] `pnpm lint` — zero TypeScript errors
- [ ] `pnpm dev:server` starts Express on :3000
- [ ] `pnpm dev:client` starts Vite on :8080 with API proxy
- [ ] `pnpm build` produces dist/ in both server and client

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```
