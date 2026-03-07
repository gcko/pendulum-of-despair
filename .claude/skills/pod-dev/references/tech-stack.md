# Tech Stack Reference -- Pendulum of Despair

## Architecture

**pnpm workspace monorepo** with three packages:

| Package | Name | Purpose |
|---------|------|---------|
| `packages/shared` | `@pendulum/shared` | Shared types and constants |
| `packages/server` | `@pendulum/server` | Express REST API with auth + save system |
| `packages/client` | `@pendulum/client` | Phaser 3 game client with Vite |

Build order: `shared` must be built before `server` or `client` (handled by
`predev:*` and `pretest` scripts via `pnpm run build:shared`).

**Node.js requirement:** >= 24.0.0 (uses built-in `node:sqlite`).

---

## Frontend (`@pendulum/client`)

### Renderer: Phaser 3

Phaser 3 (`phaser@^3.90`) provides:
- Scene management (title screen, overworld, battle, menus as separate scenes)
- Tilemap support via Tiled JSON format (`.tmj`)
- Sprite/animation management
- Input handling (keyboard, gamepad)
- Camera system (scrolling viewport for overworld/dungeons)
- Built-in asset loader (images, audio, tilemaps)

### Bundler: Vite 7

Development server and production builds via `vite@^7.0`. Port 8080 for dev.

### UI Overlays: HTML + CSS

Battle menus, dialogue boxes, inventory screens, and the HUD are HTML/CSS
layered *over* the canvas -- not drawn in Phaser. This keeps UI logic clean and
makes it easy to style with CSS variables.

**Dialogue box styling target:**
```css
/* Inspired by FF6's iconic blue gradient boxes */
background: linear-gradient(180deg, #1a2a6c, #0d1440);
border: 2px solid #aaaacc;
color: #ffffff;
font-family: 'Press Start 2P', monospace;
font-size: 8px;
line-height: 1.8;
padding: 12px 16px;
```

### Fonts

- **Primary:** [Press Start 2P](https://fonts.google.com/specimen/Press+Start+2P)
  (Google Fonts, free) -- for UI, dialogue, menus
- **Fallback:** Any monospace bitmap font

---

## Backend (`@pendulum/server`)

### Purpose

The backend is **intentionally thin** -- it exists only for:
1. User authentication (create account, login, issue session token)
2. Save data persistence (read/write JSON blob per user)

All game logic runs client-side. The backend is stateless between requests.

### Stack

- **Framework:** Express 5 (`express@^5.0`)
- **Database:** `node:sqlite` (built-in Node.js 24+ module, no npm dependency)
- **Auth:** bcryptjs (`bcryptjs@^3.0`) + JWT (`jsonwebtoken@^9.0`)
- **Dev runner:** tsx (`tsx@^4.21`) with `--watch` for hot reload
- **Rate limiting:** `express-rate-limit@^8.0`
- **CORS:** `cors@^2.8`
- **Config:** `dotenv@^17.0`

```
packages/server/src/
  index.ts          # Express app entry
  routes/
    auth.ts         # POST /register, POST /login
    save.ts         # GET /save, PUT /save
  middleware/
    auth.ts         # JWT verification middleware
  db/
    init.ts         # SQLite schema (users + saves tables)
```

### Authentication Design

- **No email required.** Username + passphrase only.
- Passphrase hashed with bcryptjs (cost factor 12)
- Session token: signed JWT, 7-day expiry, stored in `httpOnly` cookie
- No OAuth, no magic links, no complexity

### Database Schema

Using `node:sqlite` with `:memory:` for tests, file-based for production:

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  passphrase_hash TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE saves (
  user_id INTEGER REFERENCES users(id),
  slot INTEGER DEFAULT 1,
  data TEXT NOT NULL,               -- JSON blob
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, slot)
);
```

### API Surface

```
POST   /api/auth/register     { username, passphrase } -> { token }
POST   /api/auth/login        { username, passphrase } -> { token }
GET    /api/save              (auth) -> { data: SaveState }
PUT    /api/save              (auth) { data: SaveState } -> { ok }
```

---

## Shared Package (`@pendulum/shared`)

Pure TypeScript types and constants. Built with `tsc` to `dist/`. Exported via
package.json `exports` field. No runtime dependencies.

---

## Testing: Vitest 4

- Workspace-level config runs all tests via `pnpm test`
- Per-package test commands: `pnpm --filter @pendulum/server test`
- Server tests use `node:sqlite` with `:memory:` for isolation
- Integration tests use `supertest@^7.2` for HTTP assertions
- Pre-commit hook runs `vitest related` on affected files only

---

## Dev Tooling

| Tool | Version | Purpose |
|------|---------|---------|
| pnpm | 10.30+ | Package manager (corepack-managed) |
| TypeScript | ^5.9 | Type checking (strict, no `any`) |
| Vitest | ^4.0 | Test runner |
| Vite | ^7.0 | Client bundler + dev server |
| tsx | ^4.21 | Server dev runner with watch |
| Husky | ^9.1 | Git hooks (pre-commit: typecheck + vitest related) |
| supertest | ^7.2 | HTTP integration testing |

---

## Game Data Format

All game content is stored as **JSON files** under `packages/client/src/data/`.
These are loaded by Phaser's asset loader at scene start.

### Current layout
```
packages/client/src/data/
  abilities.json
  characters.json
  dialogue.json
  enemies.json
  items.json
  maps/
    overworld.json
```

As the project grows, data files may be organized into subdirectories and maps
may migrate to Tiled JSON format (`.tmj`). For now, most data files are flat
in the `data/` directory with maps in a `maps/` subdirectory.

### JSON conventions

- Every data file includes a `"_comment"` top-level key describing its structure
- IDs are always strings (e.g., `"enemy_001"`) -- not integers -- for readability
- Damage formulas use string expressions evaluated at runtime, not hardcoded numbers

Example enemy entry:
```json
{
  "_comment": "Enemy definitions. damage_formula uses vars: atk, def, level",
  "enemy_001": {
    "name": "Magitek Armor",
    "hp": 530,
    "mp": 50,
    "stats": { "atk": 14, "def": 10, "mag": 8 },
    "abilities": ["fire_beam", "ice_beam"],
    "steal": "tonic",
    "exp": 60,
    "gil": 25,
    "sprite": "magitek_armor"
  }
}
```

---

## Out of Scope (current phase)

- Multiplayer or co-op
- Mobile-native (responsive web is fine; no React Native / Capacitor)
- Procedurally generated content -- hand-crafted maps and story only
- 3D rendering of any kind
- Microtransactions or monetization
- Serverless deployment (Cloudflare Workers, Vercel Edge) -- Express-first for now
