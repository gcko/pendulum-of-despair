# Tech Stack Reference — Pendulum of Despair

## Frontend

### Renderer: Phaser.js v3
The preferred rendering engine. Phaser provides:
- Scene management (title screen, overworld, battle, menus as separate scenes)
- Tilemap support via Tiled JSON format (`.tmj`) — use this for all maps
- Sprite/animation management
- Input handling (keyboard, gamepad)
- Camera system (scrolling viewport for overworld/dungeons)
- Built-in asset loader (images, audio, tilemaps)

**When to suggest an alternative to Phaser:**
- If the user wants a purely DOM-based approach (slower but more accessible)
- If bundle size is a hard constraint and only basic canvas rendering is needed

### UI Overlays: HTML + CSS
Battle menus, dialogue boxes, inventory screens, and the HUD are HTML/CSS
layered *over* the canvas — not drawn in Phaser. This keeps UI logic clean and
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
  (Google Fonts, free) — for UI, dialogue, menus
- **Fallback:** Any monospace bitmap font

---

## Backend

### Purpose
The backend is **intentionally thin** — it exists only for:
1. User authentication (create account, login, issue session token)
2. Save data persistence (read/write JSON blob per user)

All game logic runs client-side. The backend is stateless between requests.

### Preferred Stack
**Option A — Node.js + Express (recommended for development):**
```
server/
├── index.js          # Express app entry
├── routes/
│   ├── auth.js       # POST /register, POST /login
│   └── save.js       # GET /save, PUT /save
├── middleware/
│   └── auth.js       # JWT verification middleware
└── db/
    └── schema.sql    # SQLite schema (users + saves tables)
```

**Option B — Serverless (recommended for deployment):**
- Cloudflare Workers + Workers KV — free tier is generous, global edge CDN
- Vercel Edge Functions + Vercel KV
- Either works; confirm with user before building

### Authentication Design
- **No email required.** Username + passphrase only.
- Passphrase hashed with bcrypt (cost factor 12)
- Session token: signed JWT, 7-day expiry, stored in `httpOnly` cookie
- No OAuth, no magic links, no complexity

```sql
-- Minimal schema
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  passphrase_hash TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE saves (
  user_id INTEGER REFERENCES users(id),
  slot INTEGER DEFAULT 1,           -- allow multiple save slots later
  data TEXT NOT NULL,               -- JSON blob
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, slot)
);
```

### API Surface
```
POST   /api/auth/register     { username, passphrase } → { token }
POST   /api/auth/login        { username, passphrase } → { token }
GET    /api/save              (auth) → { data: SaveState }
PUT    /api/save              (auth) { data: SaveState } → { ok }
```

---

## Game Data Format

All game content is stored as **JSON files** under `src/data/`. These are
loaded by Phaser's asset loader at scene start.

### Naming conventions
```
src/data/
├── maps/
│   ├── overworld.tmj         # Tiled map JSON
│   └── town-figaro.tmj
├── enemies/
│   └── enemies.json
├── items/
│   └── items.json
├── characters/
│   └── party.json
└── dialogue/
    └── act1.json
```

### JSON conventions
- Every data file includes a `"_comment"` top-level key describing its structure
- IDs are always strings (e.g., `"enemy_001"`) — not integers — for readability
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
- Procedurally generated content — hand-crafted maps and story only
- 3D rendering of any kind
- Microtransactions or monetization
