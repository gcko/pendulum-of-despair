# Pendulum of Despair

> *Echoes of a Forgotten Age* — A browser-based JRPG inspired by the golden age of 16-bit RPGs (Final Fantasy IV/VI, Chrono Trigger, Secret of Mana).

---

## Architecture

TypeScript monorepo managed with pnpm workspaces.

```
pendulum-of-despair/
├── packages/
│   ├── shared/        # @pendulum/shared — shared types & constants
│   │   └── src/
│   │       ├── index.ts
│   │       └── types/         # Domain types (combat, inventory, save, etc.)
│   │
│   ├── server/        # @pendulum/server — Express REST API
│   │   └── src/
│   │       ├── index.ts       # Server entry point
│   │       ├── app.ts         # Express app setup, CORS, rate-limiting
│   │       ├── db/            # SQLite schema (node:sqlite built-in)
│   │       ├── routes/        # Auth & save endpoints
│   │       ├── middleware/     # JWT verification
│   │       └── __tests__/     # Vitest integration tests
│   │
│   └── client/        # @pendulum/client — Phaser 3 browser game (Vite)
│       └── src/
│           ├── main.ts        # Phaser game config & scene list
│           ├── scenes/        # Boot, Title, WorldMap, Battle, Dialogue
│           ├── systems/       # Combat, inventory, save/load
│           └── data/          # JSON data (characters, enemies, items, etc.)
│
├── tsconfig.base.json         # Shared TypeScript config (strict, no any)
├── vitest.config.ts           # Vitest root config
├── pnpm-workspace.yaml
└── package.json               # Root scripts & workspace orchestration
```

---

## Getting Started

### Prerequisites

- **Node.js >= 24.0.0** (uses the built-in `node:sqlite` module). A `.naverc` is included.
- **pnpm** — enabled via corepack: `corepack enable`

### Install & Run

```bash
pnpm install          # Install all workspace dependencies

pnpm dev:server       # Start the API server (http://localhost:3000)
pnpm dev:client       # Start the Vite dev server for the client

pnpm test             # Run the full test suite (Vitest)
pnpm lint             # TypeScript type-check (strict mode, no any)
```

---

## API Reference

| Method | Endpoint                | Auth? | Description                        |
|--------|-------------------------|-------|------------------------------------|
| POST   | `/api/auth/register`    | No    | Create account, receive JWT        |
| POST   | `/api/auth/login`       | No    | Login, receive JWT                 |
| GET    | `/api/save`             | Yes   | List all save slot summaries       |
| GET    | `/api/save/:slot`       | Yes   | Load full save data (slot 1-3)     |
| PUT    | `/api/save/:slot`       | Yes   | Write/overwrite save data          |
| GET    | `/api/health`           | No    | Health check                       |

---

## Game Systems

### ATB Battle (FF6-inspired)
- Each combatant has a speed-based ATB gauge (0-1000)
- Player input is requested when a party member's gauge fills
- Enemies act automatically via configurable AI patterns (`basic_attack`, `aggressive`, `defensive`, `magic_focus`, `pattern`)
- Damage formulas account for STR/DEF (physical) and MAG/MDEF (magical), elemental resistances/weaknesses, critical hits, and variance

### Save System
- Three save slots per user
- Auto-save on map entry and after battles
- Manual save at save points (in-game objects)
- Save data: party state, inventory, GP, world flags, current map/position, playtime

### Character Progression
- Level-based stat growth with per-character growth rates (inspired by FF6)
- EXP split equally among living party members
- Stat increases on level-up include randomized variance for replayability

---

## Design Inspirations

| Feature                      | Inspired by      |
|------------------------------|------------------|
| ATB gauge combat             | Final Fantasy VI |
| Character-driven story setup | Final Fantasy IV |
| Dark dialogue box UI         | Final Fantasy VI |
| Tile-based overworld         | Chrono Trigger   |
| Random encounters on tiles   | Final Fantasy VI |
| Steal mechanic               | Final Fantasy VI |
| Runic ability                | Final Fantasy VI |

---

## Tech Stack

- **Language:** TypeScript (strict mode, no `any`)
- **Testing:** Vitest
- **Server:** Express + SQLite (`node:sqlite`)
- **Client:** Phaser 3 + Vite
- **Monorepo:** pnpm workspaces with project references

---

## Roadmap

- [x] Project scaffold & renderer (Phaser 3)
- [x] Tilemap rendering + player movement
- [x] ATB battle system
- [x] Character stats, levelling, abilities
- [x] Inventory & equipment system
- [x] Enemy AI & encounter system
- [x] Dialogue system with typewriter effect
- [x] User auth & save/load (backend)
- [x] TypeScript monorepo refactor (pnpm workspaces, Vitest, strict types)
- [ ] Town interiors & NPC conversations
- [ ] Dungeon maps with hazards
- [ ] Full ability/magic menu in battle
- [ ] Equipment management screen
- [ ] Title/pause menu screens
- [ ] Music & SFX (Web Audio API)
- [ ] Pixel art sprites & tilesets
