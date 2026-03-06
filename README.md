# Pendulum of Despair

> *Echoes of a Forgotten Age* — A browser-based JRPG inspired by the golden age of 16-bit RPGs (Final Fantasy IV/VI, Chrono Trigger, Secret of Mana).

---

## Architecture

```
pendulum-of-despair/
├── client/          # Phaser 3 browser game (ES modules, no bundler required)
│   ├── index.html   # Entry point — loads Phaser from CDN
│   └── src/
│       ├── main.js          # Phaser game config & scene list
│       ├── scenes/
│       │   ├── BootScene.js      # Asset loading & placeholder texture generation
│       │   ├── TitleScene.js     # Title screen + login/register UI
│       │   ├── WorldMapScene.js  # Tile-based overworld with encounter system
│       │   ├── BattleScene.js    # ATB combat (FF6-style)
│       │   └── DialogueScene.js  # FF6-style typewriter dialogue boxes
│       ├── systems/
│       │   ├── combat.js    # ATB gauge, damage formulas, enemy AI, levelling
│       │   ├── inventory.js # Item add/remove, equipment, stat bonuses
│       │   └── saveLoad.js  # REST API communication (auth + save/load)
│       └── data/
│           ├── characters.json   # Party member definitions & stat growth
│           ├── enemies.json      # Enemy roster with AI types
│           ├── items.json        # Consumables, weapons, armor
│           ├── abilities.json    # Spells, physical & special abilities
│           ├── dialogue.json     # Dialogue scripts with branching
│           └── maps/
│               └── overworld.json  # Tile map data & encounter tables
│
└── server/          # Node.js/Express REST API
    ├── index.js         # Server entry point, rate-limiting, CORS
    ├── db/init.js       # SQLite schema (node:sqlite built-in, Node ≥ 22.5)
    ├── routes/
    │   ├── auth.js      # POST /api/auth/register, POST /api/auth/login
    │   └── save.js      # GET/PUT /api/save/:slot, GET /api/save
    ├── middleware/
    │   └── auth.js      # JWT Bearer token verification
    └── __tests__/       # Jest + supertest integration tests
```

---

## Getting Started

### Server

```bash
cd server
npm install
cp .env.example .env        # Edit JWT_SECRET before deploying!
npm start                   # http://localhost:3000
```

> **Requires Node.js ≥ 22.5.0** (uses the built-in `node:sqlite` module).

### Client

Open `client/index.html` in a browser — no build step required.

For local development with the server, serve the `client/` directory with any static file server:

```bash
npx serve client
# or
python3 -m http.server 8080 --directory client
```

Then open `http://localhost:8080`. The client defaults to `http://localhost:3000` for the API.
To use a different API URL, set `window.GAME_API_BASE` before the module loads.

---

## API Reference

| Method | Endpoint                | Auth? | Description                        |
|--------|-------------------------|-------|------------------------------------|
| POST   | `/api/auth/register`    | No    | Create account, receive JWT        |
| POST   | `/api/auth/login`       | No    | Login, receive JWT                 |
| GET    | `/api/save`             | Yes   | List all save slot summaries       |
| GET    | `/api/save/:slot`       | Yes   | Load full save data (slot 1–3)     |
| PUT    | `/api/save/:slot`       | Yes   | Write/overwrite save data          |
| GET    | `/api/health`           | No    | Health check                       |

---

## Running Tests

```bash
cd server
npm test
```

---

## Game Systems

### ATB Battle (FF6-inspired)
- Each combatant has a speed-based ATB gauge (0–1000)
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

## Roadmap

- [x] Project scaffold & renderer (Phaser 3)
- [x] Tilemap rendering + player movement
- [x] ATB battle system
- [x] Character stats, levelling, abilities
- [x] Inventory & equipment system
- [x] Enemy AI & encounter system
- [x] Dialogue system with typewriter effect
- [x] User auth & save/load (backend)
- [ ] Town interiors & NPC conversations
- [ ] Dungeon maps with hazards
- [ ] Full ability/magic menu in battle
- [ ] Equipment management screen
- [ ] Title/pause menu screens
- [ ] Music & SFX (Web Audio API)
- [ ] Pixel art sprites & tilesets

