# Client Package Instructions (@pendulum/client)

## Overview

Phaser 3 browser game client built with Vite. JRPG inspired by 16-bit golden age (FF4/VI, Chrono Trigger, Secret of Mana).

## Architecture

```
packages/client/
  index.html          # Entry HTML (Phaser canvas container)
  src/
    main.ts           # Phaser config and game initialization
    scenes/           # Phaser scenes (game states)
    systems/          # Game systems (combat, inventory, etc.)
    data/             # JSON game data (maps, enemies, items, dialogue)
  vite.config.ts      # Vite build config
  vitest.config.ts    # Test config
```

## Key Patterns

### Phaser 3
- Canvas-based rendering via Phaser 3.90.0
- Scene-based architecture (each game screen is a Scene)
- Game systems are modular classes used by scenes

### Vite
- Vite 7 for development and production builds
- Dev server on port 8080
- API proxy to `http://localhost:3000` for `/api/*` routes
- Source maps enabled in production builds

### Game Data
- JSON files for all game content (maps, enemies, items, dialogue)
- Human-readable with `_comment` fields explaining structure
- Loaded by Phaser's asset loader or imported directly

### Testing
- Vitest in Node environment (no DOM needed for game logic tests)
- Focus on game systems and data validation
- Phaser rendering is not unit-tested (integration/E2E later)

## Build & Run

```bash
pnpm run build:shared        # Must build shared types first
pnpm --filter @pendulum/client dev      # Development with HMR
pnpm --filter @pendulum/client test     # Run tests
pnpm --filter @pendulum/client run typecheck  # Type check
pnpm --filter @pendulum/client build    # Production build
```

## Visual Style

- SNES-era 16-bit aesthetic (240p logical resolution, pixel-perfect scaling)
- Press Start 2P font (or custom bitmap font)
- HTML/CSS overlays for menus, HUD, dialogue boxes — styled retro
- Reference: FF6 screenshots in `.claude/skills/pod-dev/references/ff6_screenshots/`

## Coding Standards

- Strict TypeScript — no `any` types
- ESM with Bundler module resolution (Vite handles it)
- Import from `@pendulum/shared` for shared types
- Keep files modular — no file over ~300 lines before suggesting a split
- JSDoc all public functions
